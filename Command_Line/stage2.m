function stage2()
original_dir = pwd;
% stage2 - Run Stage 2: Z normalization + G matrix creation + regression
%
% Usage: >> stage2
%
% Stage 2 covers:
%   - process_subject_normalization_cmd : normalize Z matrix
%   - parse_timing                      : read timing onsets
%   - create_onsets_template_cmd        : build timing template
%   - Create_GMatrix                    : build G matrix
%   - RegressG                          : regress G from Z
%
% QC gate after Stage 2:
%   - Inspect Singular Values scree plot
%   - Set config.num_components accordingly
%   - If satisfied, run >> stage3
 
STATE_FILE = fullfile(pwd, 'pipeline_state.mat');
 
% ── Load state ────────────────────────────────────────────
if ~exist(STATE_FILE, 'file')
    fprintf('\nNo pipeline state found. Run >> stage1 first.\n\n');
    return;
end
state = load_state(STATE_FILE);
% ── Load config ───────────────────────────────────────────
config_file = 'configs.m';
try
    run(config_file);
    fprintf('Configuration loaded from: %s\n', config_file);
catch ME
    error('Error loading configuration file: %s\n%s', config_file, ME.message);
end
 
% ── Prerequisite check ────────────────────────────────────
if ~strcmp(state.status.stage1, 'done')
    fprintf('\nStage 1 must be completed before running Stage 2.\n');
    fprintf('Current status: stage1 = %s\n\n', state.status.stage1);
    return;
end
 
% ── Lock check ────────────────────────────────────────────
if strcmp(state.status.stage2, 'pending')
    fprintf('\nStage 2 is locked (status: pending).\n');
    fprintf('This means a previous run crashed mid-stage.\n');
    fprintf('Run >> unlock to reset and retry.\n\n');
    return;
end
 
% ── Acquire lock ──────────────────────────────────────────
fprintf('\n==== Stage 2: Z Normalization + G Matrix + Regression ====\n');
state.status.stage2           = 'pending';
state.current_stage           = 2;
state.timestamps.stage2_start = datestr(now);
save_state(STATE_FILE, state);
 
% ── Add CPCA toolbox to path ──────────────────────────────
addpath(genpath(config.cpcaDIR));
 
try
 
    % Step 1: Normalize Z-data matrix
    fprintf('\n1. Normalizing Z-data matrix...\n');
    process_subject_normalization_cmd(config.baseDIR, ...
        'linearRegress',    config.linearRegress, ...
        'quadraticRegress', config.quadraticRegress, ...
        'meanCenter',       config.meanCenter, ...
        'standardize',      config.standardize);
 
    if isfield(config, 'movementRegress') && config.movementRegress
        process_subject_normalization_cmd(config.baseDIR, 'movementRegress', 1);
    end
 
    if isfield(config, 'userCovariants') && ~isempty(config.userCovariants)
        process_subject_normalization_cmd(config.baseDIR, 'userCovariants', config.userCovariants);
    end
    fprintf('   Completed: Z matrix normalized.\n');
 
    % Step 2: Initialize G header
    fprintf('\n2. Initializing G matrix header...\n');
    GH = structure_define('gheader');
    GH.condition_name = config.condition_names;
    GH.bins           = config.bins;
    GH.TR             = config.TR;
    GH.inScans        = config.inScans;
    GH.normalize_me   = config.normalize_G;
 
    % Step 3: Parse timing
    fprintf('\n3. Parsing timing onsets...\n');
    timing = parse_timing(config.baseDIR, ...
        config.num_subjects, ...
        config.num_runs, ...
        config.num_conditions);
    fprintf('   Completed: Timing parsed.\n');
 
    % Step 4: Create timing onsets template
    fprintf('\n4. Creating timing onsets template...\n');
    create_onsets_template_cmd(config.baseDIR, GH, timing);
    fprintf('   Completed: timing_onsets_template.txt created.\n');
 
    % Step 5: Create G matrix
    fprintf('\n5. Creating G matrix...\n');
    Create_GMatrix(config.baseDIR, GH, 'timing_onsets_template.txt');
    fprintf('   Completed: G matrix created.\n');
 
    % Step 6: Regress G matrix
    fprintf('\n6. Regressing G matrix...\n');
    RegressG(config.baseDIR, 'G');
    fprintf('   Completed: G matrix regressed.\n');
 
    % ── Release lock — mark done ───────────────────────────
    state.status.stage2        = 'done';
    state.current_stage        = 2;
    state.timestamps.stage2_end = datestr(now);
    save_state(STATE_FILE, state);
 
    fprintf('\n==== Stage 2 Complete ====\n');
    fprintf('>>> MANUAL QC: Inspect scree plot before proceeding.\n');
    fprintf('    - Singular Values.png\n');
    fprintf('    - Update config.num_components in configs.m\n');
    fprintf('>>> When satisfied, run: >> stage3\n\n');
    cd(original_dir);
 
catch ME
    state.status.stage2        = 'failed';
    state.timestamps.stage2_end = datestr(now);
    save_state(STATE_FILE, state);
    fprintf('\nStage 2 failed: %s\n', ME.message);
    fprintf('Error at line %d in %s\n', ME.stack(1).line, ME.stack(1).name);
    cd(original_dir);
    rethrow(ME);
end
 
end
