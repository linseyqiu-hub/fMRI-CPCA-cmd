function stage1()
% stage1 - Run Stage 1: Scan list, mask creation, Z normalization, and G matrix construction
%
% Usage: >> stage1
%
% Stage 1 covers:
%   - Create_File_List                  : scan list (files.txt)
%   - Create_ZData_Matrix               : mask creation + ZInfo.mat
%   - process_subject_normalization_cmd : Z matrix normalization (Z/, mask_used.*)
%   - structure_define('gheader')       : G matrix header initialization
%   - parse_timing                      : timing onset parsing
%   - create_onsets_template_cmd        : timing_onsets_template.txt
%   - Create_GMatrix                    : G matrix construction
%                                          (Gsegs/, Gheader.mat, timing_onsets_imported.txt)
%
% QC gate after Stage 1:
%   - Inspect mask_verification.txt
%   - Inspect mask visually in FSL/MRIcron
%   - Inspect timing_onsets_imported.txt against timing_onsets_template.txt
%     to confirm onsets were parsed/matched correctly before running Stage 2 regression
%   - If satisfied, run >> stage2

clear; clc; close all;
% Inside stage1.m, right after restoredefaultpath:
%restoredefaultpath
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
% ── Add CPCA toolbox to path ──────────────────────────────
addpath(genpath(config.cpcaDIR));
original_dir = pwd;
% ── Validate config ───────────────────────────────────────
validate_config(config);


% ── Initialize fresh state ────────────────────────────────
state = init_state();

% ── Acquire lock ──────────────────────────────────────────
fprintf('\n==== Stage 1: Scan List, Mask Creation, Z Normalization, G Matrix ====\n');
state.status.stage1          = 'pending';
state.current_stage          = 1;
state.timestamps.stage1_start = datestr(now);
save_state(STATE_FILE, state);



try
    
    % Step 1: Create scan list
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

    % Fill up config with auto-derived fields (subjects/runs/conditions)
    files_txt_path = fullfile(outputDIR, 'files.txt');
    config = generate_config(config, files_txt_path);
    % ── Display parameters ────────────────────────────────────
    display_parameters(config);
    % Step 2: Create Z-data matrix + mask
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
     % Step 3: Normalize Z-data matrix
    fprintf('\n3. Normalizing Z-data matrix...\n');
    cd(outputDIR);
    process_subject_normalization_cmd(config.baseDIR, ...
        'linearRegress',    config.linearRegress, ...
        'quadraticRegress', config.quadraticRegress, ...
        'meanCenter',       config.meanCenter, ...
        'standardize',      config.standardize, ...
        'output_dir',       outputDIR);

    cd(config.cpcaDIR);
    if isfield(config, 'movementRegress') && config.movementRegress
        process_subject_normalization_cmd(config.baseDIR, ...
            'movementRegress', 1, ...
            'output_dir',      outputDIR);
    end

    if isfield(config, 'userCovariants') && ~isempty(config.userCovariants)
        process_subject_normalization_cmd(config.baseDIR, ...
            'userCovariants', config.userCovariants, ...
            'output_dir',     outputDIR);
    end
    if ~strcmp(outputDIR, config.baseDIR)
        mask_img = fullfile(config.baseDIR, 'mask_used.img');
        mask_hdr = fullfile(config.baseDIR, 'mask_used.hdr');
    
        if exist(mask_img, 'file')
            copyfile(mask_img, fullfile(outputDIR, 'mask_used.img'));
            delete(mask_img);
        end
        if exist(mask_hdr, 'file')
            copyfile(mask_hdr, fullfile(outputDIR, 'mask_used.hdr'));
            delete(mask_hdr);
        end
    end
    fprintf('   Completed: Z matrix normalized.\n');

    % Step 4: Initialize G header
    fprintf('\n4. Initializing G matrix header...\n');
    GH = structure_define('gheader');
    GH.condition_name = config.condition_names;
    GH.bins           = config.bins;
    GH.TR             = config.TR;
    GH.inScans        = config.inScans;
    GH.normalize_me   = config.normalize_G;

    % Step 5: Parse timing
    fprintf('\n5. Parsing timing onsets...\n');
    cd(config.baseDIR);
    load(fullfile(outputDIR, 'ZInfo.mat'), 'Zheader', 'scan_information');
    timing = parse_timing(config.baseDIR, ...
        config.num_subjects, ...
        config.num_runs, ...
        config.num_conditions, ...
        config.subject_conditions, ...
        config.condition_names, ...
        scan_information);
    cd(config.cpcaDIR);
    fprintf('   Completed: Timing parsed.\n');
    for s = 1:config.num_subjects
        subj_id = subject_id_cmd(s, scan_information);
        fprintf('Subject %d: subj_id = "%s"\n', s, subj_id);
        for r = 1:length(config.subject_conditions{s})
            if ~iscellstr(scan_information.SubjDir(s, r))
                continue;
            end
            run_id = determine_runID_cmd(s, r, scan_information);
            cond_indices = config.subject_conditions{s}{r};
            fprintf('  Run %d: run_id = "%s", cond_indices = %s\n', r, run_id, mat2str(cond_indices));
            cond_name = config.condition_names{cond_indices(1)};
            pattern = [subj_id '_' run_id '_' cond_name];
            fprintf('  Pattern: "%s"\n', pattern);
        end
    end

    % Step 6: Create timing onsets template
    fprintf('\n6. Creating timing onsets template...\n');
    cd(outputDIR);
    create_onsets_template_cmd(config.baseDIR, GH, timing, outputDIR, config.subject_conditions);
    cd(config.cpcaDIR);
    fprintf('   Completed: timing_onsets_template.txt created.\n');

    % Step 7: Create G matrix
    fprintf('\n7. Creating G matrix...\n');
    cd(outputDIR);
    Create_GMatrix(config.baseDIR, GH, fullfile(outputDIR, 'timing_onsets_template.txt'), outputDIR);
    cd(config.cpcaDIR);
    fprintf('   Completed: G matrix created.\n');


    % ── Release lock — mark done ───────────────────────────
    state.status.stage1        = 'done';
    state.current_stage        = 1;
    state.timestamps.stage1_end = datestr(now);
    save_state(STATE_FILE, state);

    fprintf('\n==== Stage 1 Complete ====\n');
    fprintf('>>> MANUAL QC: Inspect mask and onsets before proceeding.\n');
    fprintf('    - mask_verification.txt\n');
    fprintf('    - mask visually in FSL/MRIcron\n');
    fprintf('    - timing_onsets_imported.txt vs. timing_onsets_template.txt\n');
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
        if isfield(sol, 'rotation_method') && ~isempty(sol.rotation_method)
            if ~ischar(sol.rotation_method)
                error('Solution %d: rotation_method must be a string. Got: %s', s, class(sol.rotation_method));
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
                if isfield(sol, 'rotation_method') && ~isempty(sol.rotation_method) ...
                        && ~ismember(sol.rotation_method, valid_rotation_methods)
                    error('Solution %d: components_to_flip.rotated is specified but rotation_method "%s" is invalid. Must be one of: %s', ...
                        s, sol.rotation_method, strjoin(valid_rotation_methods, ', '));
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
if isfield(sol, 'rotation_method') && ~isempty(sol.rotation_method)
            fprintf('    Rotation Method : %s\n', sol.rotation_method);
else
            fprintf('    Rotation Method : varimax (default)\n');
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