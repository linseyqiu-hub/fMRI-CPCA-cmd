function unlock_force(stage_name)
%UNLOCK_FORCE Non-interactively release a stuck 'pending' session lock.
%
%   unlock_force('stage2')
%
%   Run from INSIDE the run folder (= outputDIR), on the LOGIN node:
%
%       cd /scratch/st-toddwood-1/$USER/<run folder>
%       matlab -nodisplay -batch "unlock_force('stage2')"
%
%   Why this exists: a TIMEOUT / FAILED / kill on a compute node never runs
%   the stage's catch block, so status stays 'pending' forever. Interactive
%   unlock.m blocks on input(), which -batch cannot answer, and allocating a
%   compute node for a millisecond flag flip is disproportionate.
%
%   Only ever moves 'pending' -> 'failed'. It does not delete results, does
%   not touch any other stage, and refuses anything that is not pending.
%
%   Check the job's actual fate BEFORE using this:
%       sacct -j <jobid>          (jobid is in logs/<stage>_<jobid>.out)
%     RUNNING            -> do not touch, the job is alive
%     TIMEOUT / FAILED   -> unlock_force, then resubmit
%     COMPLETED, pending -> died after writing results, before save_state
%                           -> unlock_force, then resubmit
%
%   See also UNLOCK.

    VALID_STAGES = {'stage1', 'stage2', 'stage3', 'stage4', 'mask_report'};

    % --- Validate input ---------------------------------------------------
    if nargin < 1 || ~(ischar(stage_name) || isstring(stage_name))
        error('unlock_force:badInput', ...
              'Usage: unlock_force(''stage2''). Valid stages: %s', ...
              strjoin(VALID_STAGES, ', '));
    end
    stage_name = char(stage_name);

    if ~ismember(stage_name, VALID_STAGES)
        error('unlock_force:unknownStage', ...
              'Unknown stage ''%s''. Valid stages: %s', ...
              stage_name, strjoin(VALID_STAGES, ', '));
    end

    % --- Locate state file via pwd (run folder) ---------------------------
    STATE_FILE = fullfile(pwd, 'pipeline_state.mat');

    if ~isfile(STATE_FILE)
        fprintf('No pipeline_state.mat in %s -- nothing to unlock.\n', pwd);
        return;
    end

    S = load(STATE_FILE);
    if ~isfield(S, 'state') || ~isfield(S.state, 'status')
        error('unlock_force:badState', ...
              '%s does not contain a valid state struct.', STATE_FILE);
    end
    state = S.state;

    if ~isfield(state.status, stage_name)
        fprintf('Stage ''%s'' has no entry in the state file -- nothing to unlock.\n', ...
                stage_name);
        return;
    end

    % --- Only ever pending -> failed --------------------------------------
    current = state.status.(stage_name);

    if ~strcmp(current, 'pending')
        fprintf('Stage ''%s'' is not locked (status: %s) -- nothing to do.\n', ...
                stage_name, current);
        return;
    end

    state.status.(stage_name) = 'failed'; %#ok<STRNU>
    save(STATE_FILE, 'state');

    fprintf('Force-unlocked ''%s'': pending -> failed\n', stage_name);
    fprintf('State file: %s\n', STATE_FILE);
    fprintf('You can now resubmit:  cpca-submit %s\n', stage_name);
end

