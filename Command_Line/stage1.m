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
    cd(config.baseDIR);
    Create_File_List(config.baseDIR, config.filewildcard);
    cd(config.cpcaDIR);
    fprintf('   Completed: files.txt created.\n');
 
    % Step 2: Create Z-data matrix + mask
    fprintf('\n2. Creating mask and ZInfo...\n');
    if isfield(config, 'createMask') && config.createMask
        cd(config.baseDIR);
        Create_ZData_Matrix(config.baseDIR, ...
            'fileName',   'files.txt', ...
            'maskName',   config.maskName, ...
            'maskMethod', config.maskMethod);
        cd(config.cpcaDIR);
    else
        cd(config.baseDIR);
        Create_ZData_Matrix(config.baseDIR, ...
            'fileName', 'files.txt', ...
            'maskName', config.maskName);
        cd(config.cpcaDIR);
    end
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

    % Validate each solution
    solution_required_fields = {'num_components'};
    valid_rotation_methods = {'varimax', 'promax', 'hrfmax', 'orthomax', 'quartimax', 'equamax', 'procrustes'};

for s = 1:length(config.solutions)
    sol = config.solutions(s);

    % Check required fields exist
    for f = 1:length(solution_required_fields)
        if ~isfield(sol, solution_required_fields{f})
            error('Solution %d is missing required field: %s', s, solution_required_fields{f});
        end
    end

    % Validate num_components is a positive integer
    if ~isnumeric(sol.num_components) || sol.num_components < 1 || floor(sol.num_components) ~= sol.num_components
        error('Solution %d: num_components must be a positive integer, got: %g', s, sol.num_components);
    end

    % Validate rotation_method only if provided
    if isfield(sol, 'rotation_method')
        if ~ischar(sol.rotation_method) || ~ismember(sol.rotation_method, valid_rotation_methods)
            error('Solution %d: invalid rotation_method "%s". Must be one of: %s', ...
                s, sol.rotation_method, strjoin(valid_rotation_methods, ', '));
        end
    end

    % Validate components_to_flip only if provided
    if isfield(sol, 'components_to_flip')
        if ~isnumeric(sol.components_to_flip)
            error('Solution %d: components_to_flip must be a numeric vector (use [] for none)', s);
        end
        if any(sol.components_to_flip > sol.num_components) || any(sol.components_to_flip < 1)
            error('Solution %d: components_to_flip contains out-of-range indices (must be between 1 and %d)', ...
                s, sol.num_components);
        end
    end

end
    

end

function display_parameters(config)
    fprintf('\n==== CPCA Analysis Parameters ====\n');
    fprintf('Base CPCA Directory: %s\n', config.cpcaDIR);
    fprintf('Base Directory: %s\n', config.baseDIR);
    fprintf('File Wildcard: %s\n', config.filewildcard);
    fprintf('Mask Name: %s\n', config.maskName);
    if isfield(config, 'createMask') && config.createMask
        fprintf('Mask Creation Method: %d\n', config.maskMethod);
    end
    fprintf('Conditions: %s\n', strjoin(config.condition_names, ', '));
    fprintf('Time Bins: %d\n', config.bins);
    fprintf('TR: %g\n', config.TR);
    fprintf('Timing in Scans: %d\n', config.inScans);
    fprintf('Normalize G Matrix: %d\n', config.normalize_G);

    % Display each solution
    fprintf('Solutions (%d total):\n', length(config.solutions));
    for s = 1:length(config.solutions)
        sol = config.solutions(s);
        fprintf('  Solution %d:\n', s);
        fprintf('    Number of Components: %d\n', sol.num_components);
        if isfield(sol, 'rotation_method') && ~isempty(sol.rotation_method)
            fprintf('    Rotation Method: %s\n', sol.rotation_method);
        end
        if isfield(sol, 'components_to_flip') && ~isempty(sol.components_to_flip)
            fprintf('    Components to Flip: %s\n', num2str(sol.components_to_flip));
        end
    end

    fprintf('==============================\n\n');
end
