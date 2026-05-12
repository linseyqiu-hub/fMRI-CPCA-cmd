function stage4()
% stage4 - Run Stage 4: Flip components
%
% Usage: >> stage4
%
% Stage 4 covers:
%   - Flip_Component : flip specified components
%
% Set config.components_to_flip in configs.m before running.
% Leave empty [] to skip flipping.
 
STATE_FILE = 'pipeline_state.mat';
 
% ── Load state ────────────────────────────────────────────
if ~exist(STATE_FILE, 'file')
    fprintf('\nNo pipeline state found. Run >> stage1 first.\n\n');
    return;
end
state = load_state(STATE_FILE);
 
% ── Prerequisite check ────────────────────────────────────
if ~strcmp(state.status.stage3, 'done')
    fprintf('\nStage 3 must be completed before running Stage 4.\n');
    fprintf('Current status: stage3 = %s\n\n', state.status.stage3);
    return;
end
 
% ── Lock check ────────────────────────────────────────────
if strcmp(state.status.stage4, 'pending')
    fprintf('\nStage 4 is locked (status: pending).\n');
    fprintf('This means a previous run crashed mid-stage.\n');
    fprintf('Run >> unlock to reset and retry.\n\n');
    return;
end
 
% ── Check components_to_flip ──────────────────────────────
if ~isfield(state.config, 'components_to_flip') || isempty(state.config.components_to_flip)
    fprintf('\nNo components specified to flip (config.components_to_flip is empty).\n');
    fprintf('Edit configs.m and set config.components_to_flip = [x, y, ...].\n');
    fprintf('Then rerun >> stage4.\n\n');
    return;
end
 
% ── Acquire lock ──────────────────────────────────────────
fprintf('\n==== Stage 4: Flip Components ====\n');
state.status.stage4           = 'pending';
state.current_stage           = 4;
state.timestamps.stage4_start = datestr(now);
save_state(STATE_FILE, state);
 
% ── Add CPCA toolbox to path ──────────────────────────────
addpath(genpath(state.config.cpcaDIR));
 
try
 
    fprintf('\n1. Flipping components: [%s]...\n', num2str(state.config.components_to_flip));
    for comp = state.config.components_to_flip
        Flip_Component(state.config.baseDIR, comp);
        fprintf('   Component %d flipped.\n', comp);
    end
    fprintf('   Completed: All specified components flipped.\n');
 
    % ── Release lock — mark done ───────────────────────────
    state.status.stage4        = 'done';
    state.timestamps.stage4_end = datestr(now);
    save_state(STATE_FILE, state);
 
    fprintf('\n==== Stage 4 Complete ====\n');
    fprintf('Pipeline complete! All 4 stages finished successfully.\n\n');
 
catch ME
    state.status.stage4        = 'failed';
    state.timestamps.stage4_end = datestr(now);
    save_state(STATE_FILE, state);
    fprintf('\nStage 4 failed: %s\n', ME.message);
    fprintf('Error at line %d in %s\n', ME.stack(1).line, ME.stack(1).name);
    rethrow(ME);
end
 
end

