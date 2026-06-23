function stage3()
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
javaaddpath(fullfile(config.cpcaDIR, 'Core', 'Java', 'cpca_progress.jar'));
javaaddpath(fullfile(config.cpcaDIR, 'Core', 'Java', 'TalairachRegions.jar'));
% resolve output directory
if isfield(config, 'outputDIR') && ~isempty(config.outputDIR)
       outputDIR = config.outputDIR;
   else
       outputDIR = config.baseDIR;
end
 
try
   cleanup_stage3(outputDIR);

% Loop over each solution
for s = 1:length(config.solutions)
    sol = config.solutions(s);

    fprintf('\n==== Solution %d/%d: %d components ====\n', s, length(config.solutions), sol.num_components);

    % Step 1: Extract components
    fprintf('\n1. Extracting components...\n');
    cd(outputDIR);
    Extract_Rotate_Components(config.baseDIR, sol.num_components, 'E', 'G',outputDIR);
    cd(config.cpcaDIR);
    fprintf('   Completed: %d components extracted.\n', sol.num_components);

   if isfield(sol, 'rotation_method') && ~isempty(sol.rotation_method)
        fprintf('\n2. Rotating components using %s...\n', sol.rotation_method);

        if strcmpi(sol.rotation_method, 'hrfmax')

        % --- resolve iterations (optional, default 500000)
            if isfield(sol, 'hrfmax_iterations') && ~isempty(sol.hrfmax_iterations)
                hrfmax_iterations = sol.hrfmax_iterations;
            else
                hrfmax_iterations = 500000;
            end

        % --- resolve shapes
            if isfield(sol, 'hrfmax_events') && ~isempty(sol.hrfmax_events)
                % Case 1: generate from cognitive events
                fprintf('   Generating shapes.mat from hrfmax_events...\n');
                shapes = generate_shapes_cmd(sol.hrfmax_events, config.bins, config.TR);
                shapes_path = fullfile(outputDIR, 'hrfmax_shapes.mat'); % TODO: move to solution-specific folder once naming convention is resolved
                save(shapes_path, 'shapes');
                fprintf('   Saved: %s\n', shapes_path);

            elseif isfield(sol, 'hrfmax_shapes_path') && ~isempty(sol.hrfmax_shapes_path)
            % Case 2: use pre-built shapes file
                if ~exist(sol.hrfmax_shapes_path, 'file')
                    error('[Stage 3] hrfmax_shapes_path does not exist on disk: %s', sol.hrfmax_shapes_path);
                end
                if ~isfield(sol, 'hrfmax_shapes_var') || isempty(sol.hrfmax_shapes_var)
                    error('[Stage 3] hrfmax_shapes_path is set but hrfmax_shapes_var is missing.');
                end
                shapes_path = sol.hrfmax_shapes_path;

            else
                % Case 3: neither defined — hard error
                error('[Stage 3] hrfmax requires either hrfmax_events or hrfmax_shapes_path to be defined.');
            end

        % --- build rot_method struct
            rot_method = {struct('method',     'hrfmax', ...
                                'hrf_file',   shapes_path, ...
                                'hrf_mat',    'shapes', ...
                                'iterations', hrfmax_iterations)};
        else
            % non-hrfmax — string as before
            rot_method = {sol.rotation_method};
        end

        cd(outputDIR);
        Extract_Rotate_Components(config.baseDIR, sol.num_components, 'R', 'G', outputDIR, rot_method);
        cd(config.cpcaDIR);
        fprintf('   Completed: Components rotated.\n');
    else
        fprintf('\n2. No rotation method specified for solution %d — skipping rotation.\n', s);
    end

 end

% ── Release lock — mark done ───────────────────────────
state.status.stage3         = 'done';
state.current_stage         = 3;
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

