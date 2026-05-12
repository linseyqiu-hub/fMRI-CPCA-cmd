function stage2()
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
 
STATE_FILE = 'pipeline_state.mat';
 
% ── Load state ────────────────────────────────────────────
if ~exist(STATE_FILE, 'file')
    fprintf('\nNo pipeline state found. Run >> stage1 first.\n\n');
    return;
end
state = load_state(STATE_FILE);
 
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
addpath(genpath(state.config.cpcaDIR));
 
try
 
    % Step 1: Normalize Z-data matrix
    fprintf('\n1. Normalizing Z-data matrix...\n');
    process_subject_normalization_cmd(state.config.baseDIR, ...
        'linearRegress',    state.config.linearRegress, ...
        'quadraticRegress', state.config.quadraticRegress, ...
        'meanCenter',       state.config.meanCenter, ...
        'standardize',      state.config.standardize);
 
    if isfield(state.config, 'movementRegress') && state.config.movementRegress
        process_subject_normalization_cmd(state.config.baseDIR, 'movementRegress', 1);
    end
 
    if isfield(state.config, 'userCovariants') && ~isempty(state.config.userCovariants)
        process_subject_normalization_cmd(state.config.baseDIR, 'userCovariants', state.config.userCovariants);
    end
    fprintf('   Completed: Z matrix normalized.\n');
 
    % Step 2: Initialize G header
    fprintf('\n2. Initializing G matrix header...\n');
    GH = structure_define('gheader');
    GH.condition_name = state.config.condition_names;
    GH.bins           = state.config.bins;
    GH.TR             = state.config.TR;
    GH.inScans        = state.config.inScans;
    GH.normalize_me   = state.config.normalize_G;
 
    % Step 3: Parse timing
    fprintf('\n3. Parsing timing onsets...\n');
    timing = parse_timing(state.config.baseDIR, ...
        state.config.num_subjects, ...
        state.config.num_runs, ...
        state.config.num_conditions);
    fprintf('   Completed: Timing parsed.\n');
 
    % Step 4: Create timing onsets template
    fprintf('\n4. Creating timing onsets template...\n');
    create_onsets_template_cmd(state.config.baseDIR, GH, timing);
    fprintf('   Completed: timing_onsets_template.txt created.\n');
 
    % Step 5: Create G matrix
    fprintf('\n5. Creating G matrix...\n');
    Create_GMatrix(state.config.baseDIR, GH, 'timing_onsets_template.txt');
    fprintf('   Completed: G matrix created.\n');
 
    % Step 6: Regress G matrix
    fprintf('\n6. Regressing G matrix...\n');
    RegressG(state.config.baseDIR, 'G');
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
 
catch ME
    state.status.stage2        = 'failed';
    state.timestamps.stage2_end = datestr(now);
    save_state(STATE_FILE, state);
    fprintf('\nStage 2 failed: %s\n', ME.message);
    fprintf('Error at line %d in %s\n', ME.stack(1).line, ME.stack(1).name);
    rethrow(ME);
end
 
end
