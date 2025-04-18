%% fMRI-CPCA Analysis Script
% This script performs fMRI-CPCA analysis using parameters from a config file called "configs.m"

function run_cpca_analysis(config_file)
    % Check if config file is provided
    if nargin < 1
        [file, path] = uigetfile({'*.m'}, 'Select CPCA configuration file');
        if isequal(file, 0)
            error('No configuration file selected. Analysis aborted.');
        end
        config_file = fullfile(path, file);
    end
    
    % Suppress warnings
    warning('off', 'all');
    
    % Load configuration
    try
        run(config_file);
        fprintf('Configuration loaded from: %s\n', config_file);
    catch ME
        error('Error loading configuration file: %s\n%s', config_file, ME.message);
    end
    
    % Add CPCA folders to path (modify as needed)
    fprintf('Adding CPCA libraries to MATLAB path...\n');
    % Get script directory
    script_dir = fileparts(mfilename('fullpath'));
    % Add CPCA library assuming it's in a subfolder of script directory
    cpca_path = fullfile(script_dir, 'cpca_lib');
    if ~exist(cpca_path, 'dir')
        % If not found, prompt user to select CPCA library path
        cpca_path = uigetdir(script_dir, 'Select the fMRI-CPCA library folder');
        if isequal(cpca_path, 0)
            error('CPCA library folder not selected. Analysis aborted.');
        end
    end
    addpath(genpath(cpca_path));
    
    % Validate configuration parameters
    validate_config(config);
    
    % Display analysis parameters
    display_parameters(config);
    
    % Confirm if the user wants to continue
    if ~confirm_analysis()
        fprintf('Analysis cancelled by user.\n');
        return;
    end
    
    % Execute CPCA analysis
    execute_cpca_analysis(config);
    
    fprintf('CPCA analysis completed successfully!\n');
end

function validate_config(config)
    % Validate essential parameters
    required_fields = {'baseDIR', 'filewildcard', 'condition_names', 'bins', 'TR', 'inScans', 'normalize_G', ...
                     'num_subjects', 'num_runs', 'num_conditions', 'num_components'};
    
    for i = 1:length(required_fields)
        if ~isfield(config, required_fields{i})
            error('Configuration missing required field: %s', required_fields{i});
        end
    end
    
    % Check if base directory exists
    if ~exist(config.baseDIR, 'dir')
        error('Base directory does not exist: %s', config.baseDIR);
    end
end

function display_parameters(config)
    fprintf('\n==== CPCA Analysis Parameters ====\n');
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

function confirmed = confirm_analysis()
    response = input('Continue with CPCA analysis? [y/n]: ', 's');
    confirmed = isempty(response) || lower(response(1)) == 'y';
end

function execute_cpca_analysis(config)
    try
        % Step 1: Create scan list
        fprintf('\n1. Creating scan list...\n');
        Create_File_List(config.baseDIR, config.filewildcard);
        fprintf('   Completed: Scan list created.\n');
        
        % Step 2: Create Z-data matrix
        fprintf('\n2. Creating Z-data matrix...\n');
        if isfield(config, 'createMask') && config.createMask
            Create_ZData_Matrix(config.baseDIR, 'fileName', 'files.txt', 'maskName', config.maskName, 'maskMethod', config.maskMethod);
        else
            Create_ZData_Matrix(config.baseDIR, 'fileName', 'files.txt', 'maskName', config.maskName);
        end
        fprintf('   Completed: Z-data matrix created.\n');
        
        % Step 3: Normalize Z-data matrix
        fprintf('\n3. Normalizing Z-data matrix...\n');
        process_subject_normalization_cmd(config.baseDIR, ...
            'linearRegress', config.linearRegress, ...
            'quadraticRegress', config.quadraticRegress, ...
            'meanCenter', config.meanCenter, ...
            'standardize', config.standardize);
        
        if isfield(config, 'movementRegress') && config.movementRegress
            process_subject_normalization_cmd(config.baseDIR, 'movementRegress', 1);
        end
        
        if isfield(config, 'userCovariants') && ~isempty(config.userCovariants)
            process_subject_normalization_cmd(config.baseDIR, 'userCovariants', config.userCovariants);
        end
        fprintf('   Completed: Z-data matrix normalized.\n');
        
        % Step 4: Initialize G matrix
        fprintf('\n4. Initializing G matrix...\n');
        GH = structure_define('gheader');
        GH.condition_name = config.condition_names;
        GH.bins = config.bins;
        GH.TR = config.TR;
        GH.inScans = config.inScans;
        GH.normalize_me = config.normalize_G;
        
        % Parse timing information
        timing = parse_timing(config.baseDIR, config.num_subjects, config.num_runs, config.num_conditions);
        
        % Create timing onsets template
        create_onsets_template_cmd(config.baseDIR, GH, timing);
        fprintf('   Completed: G matrix initialized.\n');
        
        % Step 5: Create G matrix
        fprintf('\n5. Creating G matrix...\n');
        Create_GMatrix(config.baseDIR, GH, 'timing_onsets_template.txt');
        fprintf('   Completed: G matrix created.\n');
        
        % Step 6: Regress G matrix
        fprintf('\n6. Regressing G matrix...\n');
        RegressG(config.baseDIR, 'G');
        fprintf('   Completed: G matrix regressed.\n');
        
        % Step 7: Extract components
        fprintf('\n7. Extracting components...\n');
        Extract_Rotate_Components(config.baseDIR, config.num_components, 'E', 'G');
        fprintf('   Completed: Components extracted.\n');
        
        % Step 8: Rotate components (if specified)
        if isfield(config, 'rotation_method') && ~isempty(config.rotation_method)
            fprintf('\n8. Rotating components using %s...\n', config.rotation_method);
            rot_method = {config.rotation_method};
            Extract_Rotate_Components(config.baseDIR, config.num_components, 'R', 'G', rot_method);
            fprintf('   Completed: Components rotated.\n');
        end
        
        % Step 9: Flip components (if specified)
        if isfield(config, 'components_to_flip') && ~isempty(config.components_to_flip)
            fprintf('\n9. Flipping specified components...\n');
            for comp = config.components_to_flip
                Flip_Component(config.baseDIR, comp);
                fprintf('   Component %d flipped.\n', comp);
            end
            fprintf('   Completed: Components flipped.\n');
        end
        
    catch ME
        fprintf('\nError during CPCA analysis: %s\n', ME.message);
        fprintf('Error at line %d in function %s\n', ME.stack(1).line, ME.stack(1).name);
        rethrow(ME);
    end
end