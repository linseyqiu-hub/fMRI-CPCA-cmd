pwfunction stage3()
original_dir = pwd;
% stage3 - Run Stage 3: Component extraction and rotation
%
% Usage: >> stage3
%
% Stage 3 covers:
%   - Extract_Rotate_Components : extract components
%   - Extract_Rotate_Components : rotate components (if rotation_method set)
%
% QC gate after Stage 3:
%   - Inspect component maps
%   - Identify which components need flipping
%   - Set config.components_to_flip in configs.m
%   - If satisfied, run >> stage4
 
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
if ~strcmp(state.status.stage2, 'done')
    fprintf('\nStage 2 must be completed before running Stage 3.\n');
    fprintf('Current status: stage2 = %s\n\n', state.status.stage2);
    return;
end
 
% ── Lock check ────────────────────────────────────────────
if strcmp(state.status.stage3, 'pending')
    fprintf('\nStage 3 is locked (status: pending).\n');
    fprintf('This means a previous run crashed mid-stage.\n');
    fprintf('Run >> unlock to reset and retry.\n\n');
    return;
end
 
% ── Acquire lock ──────────────────────────────────────────
fprintf('\n==== Stage 3: Component Extraction + Rotation ====\n');
state.status.stage3           = 'pending';
state.current_stage           = 3;
state.timestamps.stage3_start = datestr(now);
save_state(STATE_FILE, state);
 
% ── Add CPCA toolbox to path ──────────────────────────────
addpath(genpath(config.cpcaDIR));
 
try
    cleanup_stage3(config.baseDIR);
    % Step 1: Extract components
    fprintf('\n1. Extracting components...\n');
    cd(config.baseDIR);
    Extract_Rotate_Components(config.baseDIR, config.num_components, 'E', 'G');
    cd(config.cpcaDIR);
    fprintf('   Completed: %d components extracted.\n', config.num_components);
 
    % Step 2: Rotate components (if specified)
    if isfield(config, 'rotation_method') && ~isempty(config.rotation_method)
        fprintf('\n2. Rotating components using %s...\n', config.rotation_method);
        rot_method = {config.rotation_method};
        cd(config.baseDIR);
        Extract_Rotate_Components(config.baseDIR, config.num_components, 'R', 'G', rot_method);
        cd(config.cpcaDIR);
        fprintf('   Completed: Components rotated.\n');
    else
        fprintf('\n2. No rotation method specified — skipping rotation.\n');
    end
 
    % ── Release lock — mark done ───────────────────────────
    state.status.stage3        = 'done';
    state.current_stage        = 3;
    state.timestamps.stage3_end = datestr(now);
    save_state(STATE_FILE, state);
 
    fprintf('\n==== Stage 3 Complete ====\n');
    fprintf('>>> MANUAL QC: Inspect component maps before proceeding.\n');
    fprintf('    - Identify which components need flipping\n');
    fprintf('    - Update config.components_to_flip in configs.m\n');
    fprintf('>>> When satisfied, run: >> stage4\n\n');
    cd(original_dir);
 
catch ME
    state.status.stage3        = 'failed';
    state.timestamps.stage3_end = datestr(now);
    save_state(STATE_FILE, state);
    fprintf('\nStage 3 failed: %s\n', ME.message);
    fprintf('Error at line %d in %s\n', ME.stack(1).line, ME.stack(1).name);
    cd(original_dir);
    rethrow(ME);
end
 
end

