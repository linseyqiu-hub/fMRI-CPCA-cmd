function unlock()
% unlock - Release stuck pending stage locks
%
% Usage: >> unlock
%
% Use this when a stage is stuck in 'pending' status due to a crash.
% Resets stuck stages to 'failed' so they can be rerun.
 
STATE_FILE = 'pipeline_state.mat';
 
% ── Load state ────────────────────────────────────────────
if ~exist(STATE_FILE, 'file')
    fprintf('\nNo pipeline state found. Nothing to unlock.\n\n');
    return;
end
state = load_state(STATE_FILE);
 
% ── Find stuck stages ─────────────────────────────────────
stuck = {};
for i = 1:length(state.stages)
    name = state.stages{i};
    if strcmp(state.status.(name), 'pending')
        stuck{end+1} = name;
    end
end
 
if isempty(stuck)
    fprintf('\nNo stages are locked (no pending stages found).\n\n');
    return;
end
 
% ── Show stuck stages ─────────────────────────────────────
fprintf('\nThe following stages are locked (pending):\n');
for i = 1:length(stuck)
    fprintf('  [%d] %s\n', i, stuck{i});
end
fprintf('  [0] Cancel\n\n');
 
% ── Ask which to unlock ───────────────────────────────────
choice = input('Which stage to unlock? Enter number: ');
 
if isempty(choice) || choice == 0
    fprintf('Cancelled. No changes made.\n\n');
    return;
end
 
if choice < 1 || choice > length(stuck)
    fprintf('Invalid choice. No changes made.\n\n');
    return;
end
 
% ── Reset to failed ───────────────────────────────────────
stage_name = stuck{choice};
state.status.(stage_name) = 'failed';
save_state(STATE_FILE, state);
 
fprintf('\nUnlocked: %s reset from pending → failed.\n', stage_name);
fprintf('You can now rerun >> %s\n\n', stage_name);
 
end

