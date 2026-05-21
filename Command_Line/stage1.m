function stage1()
% stage1 - Run Stage 1: Create scan list + Z-data matrix + mask verification
%
% Usage: >> stage1
%
% Stage 1 covers:
%   - Create_File_List      : scan list (files.txt)
%   - Create_ZData_Matrix   : mask creation + ZInfo.mat
%
% QC gate after Stage 1:
%   - Inspect mask_verification.txt
%   - Inspect mask visually in FSL/MRIcron
%   - If satisfied, run >> stage2
 
clear; clc; close all;
restoredefaultpath;
 
% Suppress warnings
warning('off', 'all');
 
STATE_FILE = fullfile(pwd, 'pipeline_state.mat');
 
% ── Load config ───────────────────────────────────────────
config_file = 'configs.m';
try
    run(config_file);
    fprintf('Configuration loaded from: %s\n', config_file);
catch ME
    error('Error loading configuration file: %s\n%s', config_file, ME.message);
end
original_dir = pwd;
% ── Validate config ───────────────────────────────────────
validate_config(config);
 
% ── Display parameters ────────────────────────────────────
display_parameters(config);

% ── Initialize fresh state ────────────────────────────────
state = init_state();
 
% ── Acquire lock ──────────────────────────────────────────
fprintf('\n==== Stage 1: Scan List + Mask Creation ====\n');
state.status.stage1          = 'pending';
state.current_stage          = 1;
state.timestamps.stage1_start = datestr(now);
save_state(STATE_FILE, state);


 
try
    % ── Add CPCA toolbox to path ──────────────────────────────
    addpath(genpath(config.cpcaDIR));
    % Step 1: Create scan list
    fprintf('\n1. Creating scan list...\n');
    % resolve output directory
    if isfield(config, 'outputDIR') && ~isempty(config.outputDIR)
        outputDIR = config.outputDIR;
    else
        outputDIR = config.baseDIR;
    end
    cd(outputDIR);
% Step 1: Create scan list
    fprintf('\n1. Creating scan list...\n');
    Create_File_List(config.baseDIR, config.filewildcard, outputDIR);
    fprintf('   Completed: files.txt created.\n');
    cd(config.cpcaDIR);
 
    % Step 2: Create Z-data matrix + mask
    fprintf('\n2. Creating mask and ZInfo...\n');
    if isfield(config, 'createMask') && config.createMask
        Create_ZData_Matrix(config.baseDIR, ...
            'fileName',   'files.txt', ...
            'maskName',   config.maskName, ...
            'maskMethod', config.maskMethod, ...
            'output_dir', outputDIR);
    else
        Create_ZData_Matrix(config.baseDIR, ...
            'fileName', 'files.txt', ...
            'maskName', config.maskName, ...
            'output_dir', outputDIR);
    end
cd(config.cpcaDIR);
    fprintf('   Completed: ZInfo.mat and mask created.\n');
 
    % ── Release lock — mark done ───────────────────────────
    state.status.stage1        = 'done';
    state.current_stage        = 1;
    state.timestamps.stage1_end = datestr(now);
    save_state(STATE_FILE, state);
 
    fprintf('\n==== Stage 1 Complete ====\n');
    fprintf('>>> MANUAL QC: Inspect mask before proceeding.\n');
    fprintf('    - mask_verification.txt\n');
    fprintf('    - mask visually in FSL/MRIcron\n');
    fprintf('>>> When satisfied, run: >> stage2\n\n');
    cd(original_dir);
 
catch ME
    state.status.stage1        = 'failed';
    state.timestamps.stage1_end = datestr(now);
    save_state(STATE_FILE, state);
    fprintf('\nStage 1 failed: %s\n', ME.message);
    fprintf('Error at line %d in %s\n', ME.stack(1).line, ME.stack(1).name);
    cd(original_dir);
    rethrow(ME);
end
 
end

function validate_config(config)
    % Validate essential parameters
    required_fields = {'cpcaDIR', 'baseDIR', 'filewildcard', 'condition_names', 'bins', 'TR', 'inScans', 'normalize_G', ...
                     'num_subjects', 'num_runs', 'num_conditions', 'solutions'};
    
    for i = 1:length(required_fields)
        if ~isfield(config, required_fields{i})
            error('Configuration missing required field: %s', required_fields{i});
        end
    end
    
    % Check if cpca directory exists
    if ~exist(config.cpcaDIR, 'dir')
        error('CPCA directory does not exist: %s', config.cpcaDIR);
    end
    
    % Check if base directory exists
    if ~exist(config.baseDIR, 'dir')
        error('Base directory does not exist: %s', config.baseDIR);
    end

    % Validate outputDIR only if specified
    if isfield(config, 'outputDIR') && ~isempty(config.outputDIR)
        if ~exist(config.outputDIR, 'dir')
            error('Output directory does not exist: %s', config.outputDIR);
        end
    end

    % Validate solutions
    if isempty(config.solutions)
        error('config.solutions must contain at least one solution.');
    end

    valid_rotation_methods = {'varimax', 'promax', 'hrfmax', 'orthomax', 'quartimax', 'equamax', 'procrustes'};

    for s = 1:length(config.solutions)
        sol = config.solutions(s);

        % --- num_components (required) ---
        if ~isfield(sol, 'num_components')
            error('Solution %d is missing required field: num_components', s);
        end
        if ~isnumeric(sol.num_components) || sol.num_components < 1 || floor(sol.num_components) ~= sol.num_components
            error('Solution %d: num_components must be a positive integer, got: %g', s, sol.num_components);
        end

        % --- rotation_method (optional) ---
        % If field is absent: no rotation (valid)
        % If field is present: must be non-empty and a valid method
        if isfield(sol, 'rotation_method')
            if ~ischar(sol.rotation_method) || isempty(sol.rotation_method)
                error('Solution %d: rotation_method is specified but empty. Either remove the field entirely or set a valid method: %s', ...
                    s, strjoin(valid_rotation_methods, ', '));
            end
            if ~ismember(sol.rotation_method, valid_rotation_methods)
                error('Solution %d: invalid rotation_method "%s". Must be one of: %s', ...
                    s, sol.rotation_method, strjoin(valid_rotation_methods, ', '));
            end
        end

        % --- components_to_flip (optional) ---
        if isfield(sol, 'components_to_flip')
            if ~isstruct(sol.components_to_flip)
                error('Solution %d: components_to_flip must be a struct with fields .unrotated and/or .rotated', s);
            end

            % Only allow 'unrotated' and 'rotated' as valid keys
            flip_fields = fieldnames(sol.components_to_flip);
            valid_flip_keys = {'unrotated', 'rotated'};
            for f = 1:length(flip_fields)
                key = flip_fields{f};
                if ~ismember(key, valid_flip_keys)
                    error('Solution %d: components_to_flip has unknown key "%s". Only "unrotated" and "rotated" are allowed.', s, key);
                end
            end

            % Validate unrotated flip indices
            if isfield(sol.components_to_flip, 'unrotated')
                validate_flip_indices(sol.components_to_flip.unrotated, sol.num_components, s, 'unrotated');
            end

            % Validate rotated flip indices
            if isfield(sol.components_to_flip, 'rotated')
                if ~isfield(sol, 'rotation_method')
                    error('Solution %d: components_to_flip.rotated is specified but rotation_method is not defined. Cannot flip rotated components without a rotation method.', s);
                end
                validate_flip_indices(sol.components_to_flip.rotated, sol.num_components, s, 'rotated');
            end
        end
    end
end


function validate_flip_indices(indices, num_components, sol_idx, label)
    if ~isnumeric(indices)
        error('Solution %d: components_to_flip.%s must be a numeric vector (use [] for none)', ...
            sol_idx, label);
    end
    if ~isempty(indices)
        if any(indices < 1) || any(indices > num_components)
            error('Solution %d: components_to_flip.%s contains out-of-range indices. Must be between 1 and %d.', ...
                sol_idx, label, num_components);
        end
        if length(unique(indices)) ~= length(indices)
            error('Solution %d: components_to_flip.%s contains duplicate indices.', ...
                sol_idx, label);
        end
    end
end


function display_parameters(config)
    fprintf('\n==== CPCA Analysis Parameters ====\n');
    fprintf('Base CPCA Directory : %s\n', config.cpcaDIR);
    fprintf('Base Directory      : %s\n', config.baseDIR);

    if isfield(config, 'outputDIR') && ~isempty(config.outputDIR)
        fprintf('Output Directory    : %s\n', config.outputDIR);
    else
        fprintf('Output Directory    : (default — same as baseDIR)\n');
    end

    fprintf('File Wildcard       : %s\n', config.filewildcard);
    fprintf('Mask Name           : %s\n', config.maskName);
    if isfield(config, 'createMask') && config.createMask
        fprintf('Mask Creation Method: %d\n', config.maskMethod);
    end
    fprintf('Conditions          : %s\n', strjoin(config.condition_names, ', '));
    fprintf('Time Bins           : %d\n', config.bins);
    fprintf('TR                  : %g\n', config.TR);
    fprintf('Timing in Scans     : %d\n', config.inScans);
    fprintf('Normalize G Matrix  : %d\n', config.normalize_G);
    fprintf('Num Subjects        : %d\n', config.num_subjects);
    fprintf('Runs per Subject    : %d\n', config.num_runs);
    fprintf('Num Conditions      : %d\n', config.num_conditions);

    fprintf('\nSolutions (%d total):\n', length(config.solutions));
    for s = 1:length(config.solutions)
        sol = config.solutions(s);
        fprintf('  Solution %d:\n', s);
        fprintf('    Components      : %d\n', sol.num_components);

        if isfield(sol, 'rotation_method')
            fprintf('    Rotation Method : %s\n', sol.rotation_method);
        else
            fprintf('    Rotation Method : none\n');
        end

        if isfield(sol, 'components_to_flip')
            if isfield(sol.components_to_flip, 'unrotated') && ~isempty(sol.components_to_flip.unrotated)
                fprintf('    Flip Unrotated  : [%s]\n', num2str(sol.components_to_flip.unrotated));
            else
                fprintf('    Flip Unrotated  : none\n');
            end
            if isfield(sol.components_to_flip, 'rotated') && ~isempty(sol.components_to_flip.rotated)
                fprintf('    Flip Rotated    : [%s]\n', num2str(sol.components_to_flip.rotated));
            else
                fprintf('    Flip Rotated    : none\n');
            end
        else
            fprintf('    Flip Unrotated  : none\n');
            fprintf('    Flip Rotated    : none\n');
        end
    end

    fprintf('==================================\n\n');
end