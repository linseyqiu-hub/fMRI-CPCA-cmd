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
% Inside stage1.m, right after restoredefaultpath:
restoredefaultpath
%thisFile = mfilename('fullpath');           % full path to stage1.m itself
%[thisDir, ~, ~] = fileparts(thisFile);      % .../fMRI-CPCA-cmd/Command_Line
%pipelineRoot = fileparts(thisDir);          % .../fMRI-CPCA-cmd  (one level up)
%addpath(genpath(pipelineRoot))
 
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

    % Step 2: Fill up config.m
    files_txt_path = fullfile(outputDIR, 'files.txt');
    config = generate_config(config, files_txt_path);
    % ── Display parameters ────────────────────────────────────
    display_parameters(config);
    % Step 3: Create Z-data matrix + mask
    fprintf('\n2. Creating mask and ZInfo...\n');
    if isfield(config, 'createMask') && config.createMask
        Create_ZData_Matrix(config.baseDIR, ...
            'fileName',   'files.txt', ...
            'maskName',   config.maskName, ...
            'maskMethod', config.maskMethod, ...
            'output_dir', outputDIR, ...
            'removeVentricles', config.removeVentricles);
    else
        Create_ZData_Matrix(config.baseDIR, ...
            'fileName', 'files.txt', ...
            'maskName', config.maskName, ...
            'output_dir', outputDIR);
    end
    if ~strcmp(outputDIR, config.baseDIR)
        mv_mat = fullfile(config.baseDIR, 'mask_verification.mat');
        mv_txt = fullfile(config.baseDIR, 'mask_verification.txt');
    
        if exist(mv_mat, 'file')
            copyfile(mv_mat, fullfile(outputDIR, 'mask_verification.mat'));
            delete(mv_mat);
        end
        if exist(mv_txt, 'file')
            copyfile(mv_txt, fullfile(outputDIR, 'mask_verification.txt'));
            delete(mv_txt);
        end
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
    % Validate manually-filled config fields only.
    % Auto-derived fields (num_subjects, num_runs, num_conditions,
    % condition_names, subject_conditions) are NOT validated here —
    % they are deterministically produced by generate_config and
    % guaranteed correct if that function succeeds.

    % ── Required manual fields ────────────────────────────────────────────
    required_fields = { ...
        'cpcaDIR', ...
        'baseDIR', ...
        'filewildcard', ...
        'bins', ...
        'TR', ...
        'inScans', ...
        'normalize_G', ...
        'solutions' ...
    };

    for i = 1:length(required_fields)
        if ~isfield(config, required_fields{i})
            error('Configuration missing required field: %s', required_fields{i});
        end
    end

    % ── Path existence checks ─────────────────────────────────────────────
    if ~exist(config.cpcaDIR, 'dir')
        error('CPCA directory does not exist: %s', config.cpcaDIR);
    end

    if ~exist(config.baseDIR, 'dir')
        error('Base directory does not exist: %s', config.baseDIR);
    end

    if isfield(config, 'outputDIR') && ~isempty(config.outputDIR)
        if ~exist(config.outputDIR, 'dir')
            error('Output directory does not exist: %s', config.outputDIR);
        end
    end

    % ── Scalar parameter checks ───────────────────────────────────────────
    if ~isnumeric(config.bins) || config.bins < 1 || floor(config.bins) ~= config.bins
        error('config.bins must be a positive integer, got: %g', config.bins);
    end

    if ~isnumeric(config.TR) || config.TR <= 0
        error('config.TR must be a positive number, got: %g', config.TR);
    end

    if ~ismember(config.inScans, [0 1])
        error('config.inScans must be 0 or 1, got: %g', config.inScans);
    end

    if ~ismember(config.normalize_G, [0 1])
        error('config.normalize_G must be 0 or 1, got: %g', config.normalize_G);
    end

    % ── Mask fields (conditional) ─────────────────────────────────────────
    if ~isfield(config, 'maskName') || isempty(config.maskName)
        error('config.maskName is required and must be non-empty.');
    end

    if isfield(config, 'createMask') && config.createMask
        if ~isfield(config, 'maskMethod') || isempty(config.maskMethod)
            error('config.maskMethod is required when config.createMask = 1.');
        end
    end

    % ── Solutions ─────────────────────────────────────────────────────────
    if isempty(config.solutions)
        error('config.solutions must contain at least one solution.');
    end

    valid_rotation_methods = {'varimax', 'promax', 'hrfmax', 'orthomax', 'quartimax', 'equamax', 'procrustes'};

    for s = 1:length(config.solutions)
        sol = config.solutions(s);

        % num_components (required)
        if ~isfield(sol, 'num_components')
            error('Solution %d is missing required field: num_components', s);
        end
        if ~isnumeric(sol.num_components) || sol.num_components < 1 || floor(sol.num_components) ~= sol.num_components
            error('Solution %d: num_components must be a positive integer, got: %g', s, sol.num_components);
        end

        % rotation_method (optional)
        if isfield(sol, 'rotation_method')
            if ~ischar(sol.rotation_method) || isempty(sol.rotation_method)
                error('Solution %d: rotation_method is specified but empty. Either remove the field or set a valid method: %s', ...
                    s, strjoin(valid_rotation_methods, ', '));
            end
            if ~ismember(sol.rotation_method, valid_rotation_methods)
                error('Solution %d: invalid rotation_method "%s". Must be one of: %s', ...
                    s, sol.rotation_method, strjoin(valid_rotation_methods, ', '));
            end
        end

        % components_to_flip (optional)
        if isfield(sol, 'components_to_flip')
            if ~isstruct(sol.components_to_flip)
                error('Solution %d: components_to_flip must be a struct with fields .unrotated and/or .rotated', s);
            end

            flip_fields = fieldnames(sol.components_to_flip);
            valid_flip_keys = {'unrotated', 'rotated'};
            for f = 1:length(flip_fields)
                key = flip_fields{f};
                if ~ismember(key, valid_flip_keys)
                    error('Solution %d: components_to_flip has unknown key "%s". Only "unrotated" and "rotated" are allowed.', s, key);
                end
            end

            if isfield(sol.components_to_flip, 'unrotated')
                validate_flip_indices(sol.components_to_flip.unrotated, sol.num_components, s, 'unrotated');
            end

            if isfield(sol.components_to_flip, 'rotated')
                if ~isfield(sol, 'rotation_method')
                    error('Solution %d: components_to_flip.rotated is specified but rotation_method is not defined.', s);
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
    % Called AFTER generate_config — all fields including auto-derived ones are present.
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
if isfield(config, 'removeVentricles')
if config.removeVentricles
            fprintf('Ventricles          : Excluded\n');
else
            fprintf('Ventricles          : Included\n');
end
end
    fprintf('Time Bins           : %d\n', config.bins);
    fprintf('TR                  : %g\n', config.TR);
    fprintf('Timing in Scans     : %d\n', config.inScans);
    fprintf('Normalize G Matrix  : %d\n', config.normalize_G);
% Auto-derived fields
    fprintf('Num Subjects        : %d\n', config.num_subjects);
    fprintf('Num Runs (max)      : %d\n', config.num_runs);
    fprintf('Num Conditions      : %d\n', config.num_conditions);
    fprintf('Conditions          : %s\n', strjoin(config.condition_names, ', '));
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