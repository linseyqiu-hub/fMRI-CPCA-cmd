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
    Create_File_List(config.baseDIR, config.filewildcard);
    fprintf('   Completed: files.txt created.\n');
 
    % Step 2: Create Z-data matrix + mask
    fprintf('\n2. Creating mask and ZInfo...\n');
    if isfield(config, 'createMask') && config.createMask
        Create_ZData_Matrix(config.baseDIR, ...
            'fileName',   'files.txt', ...
            'maskName',   config.maskName, ...
            'maskMethod', config.maskMethod);
    else
        Create_ZData_Matrix(config.baseDIR, ...
            'fileName', 'files.txt', ...
            'maskName', config.maskName);
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
                     'num_subjects', 'num_runs', 'num_conditions', 'num_components'};
    
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
    
end

function display_parameters(config)
    fprintf('\n==== CPCA Analysis Parameters ====\n');
    fprintf('Base CPCA Directory: %s\n', config.cpcaDIR)
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
    fprintf('Number of Components: %d\n', config.num_components);
    if isfield(config, 'rotation_method') && ~isempty(config.rotation_method)
        fprintf('Rotation Method: %s\n', config.rotation_method);
    end
    fprintf('==============================\n\n');
end

