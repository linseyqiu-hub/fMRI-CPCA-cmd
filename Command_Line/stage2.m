function stage2()
original_dir = pwd;
% stage2 - Run Stage 2:  regression
%
% Usage: >> stage2
%
% Stage 2 covers:
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
    fprintf('Run >> unlock_force(''stage2'') to reset and retry.\n\n');
    return;
end
 
% ── Acquire lock ──────────────────────────────────────────
fprintf('\n==== Stage 2: Z G Regression ====\n');
state.status.stage2           = 'pending';
state.current_stage           = 2;
state.timestamps.stage2_start = datestr(now);
save_state(STATE_FILE, state);
 
% ── Add CPCA toolbox to path ──────────────────────────────
addpath(genpath(config.cpcaDIR));
% resolve output directory
if isfield(config, 'outputDIR') && ~isempty(config.outputDIR)
       outputDIR = config.outputDIR;
   else
       outputDIR = config.baseDIR;
end
try
    cleanup_stage2(outputDIR);
    % Step 1: Regress G matrix
    fprintf('\n1. Regressing G matrix...\n');
    cd(outputDIR);
    RegressG(config.baseDIR, 'G', outputDIR);
    cd(config.cpcaDIR);
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
    cd(original_dir);
    fprintf('>>> When satisfied, run: >> stage3\n\n');
 
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
