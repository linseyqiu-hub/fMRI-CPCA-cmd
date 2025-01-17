% command-line demo scripts
warning('off','all')
%% add fmri-cpca folder and all subfolders into matlab path
addpath(genpath('/Users/wsu/cpca_1.2.2.23/'));
% work folder
baseDIR = '/Users/wsu/example_data_Multiple_Groups_Subjects_Runs';

%% create scan list
Create_File_List(baseDIR, 'fsn*img');

%% create Z matrix
Create_ZData_Matrix(baseDIR, 'fileName', 'files.txt', 'maskName', 'mask.img');

%% Normalize Z matrix
process_subject_normalization_cmd(baseDIR,'linearRegress',1,'quadraticRegress',1,'meanCenter',1,'standardize',1)

%% initialize G matrix and read timing data
% Get number of conditions from user with validation
while true
    num_conditions = input('Enter the number of conditions (must be a positive integer): ');
    if ~isempty(num_conditions) && isnumeric(num_conditions) && num_conditions > 0 && mod(num_conditions, 1) == 0
        break;
    else
        fprintf('Invalid input. Please enter a positive integer.\n');
    end
end

% Get condition names from user
conditions = cell(1, num_conditions);
for i = 1:num_conditions
    while true
        conditions{i} = input(sprintf('Enter name for condition %d (non-empty string): ', i), 's');
        if ~isempty(conditions{i}) && ischar(conditions{i})
            break;
        else
            fprintf('Invalid input. Please enter a non-empty string.\n');
        end
    end
end

% Display conditions for verification
fprintf('\nConditions entered:\n');
for i = 1:num_conditions
    fprintf('%d. %s\n', i, conditions{i});
end

% Confirm with user
while true
    confirm = input('\nAre these conditions correct? (y/n): ', 's');
    if strcmpi(confirm, 'y')
        break;
    elseif strcmpi(confirm, 'n')
        fprintf('Please enter the conditions again.\n');
        for i = 1:num_conditions
            while true
                conditions{i} = input(sprintf('Enter name for condition %d (non-empty string): ', i), 's');
                if ~isempty(conditions{i}) && ischar(conditions{i})
                    break;
                else
                    fprintf('Invalid input. Please enter a non-empty string.\n');
                end
            end
        end
    else
        fprintf('Invalid input. Please enter y or n.\n');
    end
end

% Get number of runs with validation
while true
    num_runs = input('Enter the number of runs (must be a positive integer): ');
    if ~isempty(num_runs) && isnumeric(num_runs) && num_runs > 0 && mod(num_runs, 1) == 0
        break;
    else
        fprintf('Invalid input. Please enter a positive integer.\n');
    end
end

% Initialize GH structure with user inputs
GH = structure_define('gheader');
GH.condition_name = conditions;

% Get bins with validation
while true
    GH.bins = input('Enter the number of time bins (must be a positive integer): ');
    if ~isempty(GH.bins) && isnumeric(GH.bins) && GH.bins > 0 && mod(GH.bins, 1) == 0
        break;
    else
        fprintf('Invalid input. Please enter a positive integer.\n');
    end
end

% Get TR with validation
while true
    GH.TR = input('Enter the TR (timing rate) (must be a positive number): ');
    if ~isempty(GH.TR) && isnumeric(GH.TR) && GH.TR > 0
        break;
    else
        fprintf('Invalid input. Please enter a positive number.\n');
    end
end

% Get inScans with validation
while true
    GH.inScans = input('Enter timing type (1 for Scans, 0 for seconds): ');
    if ~isempty(GH.inScans) && isnumeric(GH.inScans) && (GH.inScans == 0 || GH.inScans == 1)
        break;
    else
        fprintf('Invalid input. Please enter either 0 or 1.\n');
    end
end

% Get normalize_me with validation
while true
    GH.normalize_me = input('Normalize G matrix? (1 for yes, 0 for no): ');
    if ~isempty(GH.normalize_me) && isnumeric(GH.normalize_me) && (GH.normalize_me == 0 || GH.normalize_me == 1)
        break;
    else
        fprintf('Invalid input. Please enter either 0 or 1.\n');
    end
end

% Get timing inputs for each condition and run
timing = cell(1, num_conditions * num_runs);
for run = 1:num_runs
    for cond = 1:num_conditions
        while true
            try
                input_str = input(sprintf('Enter space-separated timing values for Run %d, Condition %s: ', run, conditions{cond}), 's');
                % Convert string input to array of numbers
                timing_values = str2num(input_str); %#ok<ST2NM>
                if ~isempty(timing_values) && isnumeric(timing_values)
                    timing{(run-1)*num_conditions + cond} = input_str;
                    break;
                else
                    fprintf('Invalid input. Please enter space-separated numbers.\n');
                end
            catch
                fprintf('Invalid input. Please enter space-separated numbers.\n');
            end
        end
    end
end

% Create timing onsets template
create_onsets_template_cmd(baseDIR, GH, timing);

%% create G matrix
Create_GMatrix(baseDIR, GH, 'timing_onsets_template.txt')

%% regress G matrix
RegressG(baseDIR, 'G');

%% extract, rotate and flip components
% Get number of components with validation
while true
    num_components = input('Enter the number of components to extract (must be a positive integer): ');
    if ~isempty(num_components) && isnumeric(num_components) && num_components > 0 && mod(num_components, 1) == 0
        break;
    else
        fprintf('Invalid input. Please enter a positive integer.\n');
    end
end

Extract_Rotate_Components(baseDIR, num_components, 'E', 'G')

% rotate components
valid_methods = {'varimax', 'promax', 'hrfmax', 'orthomax', 'quartimax', 'equimax', 'hrf-procrustes', 'procrustes'};
fprintf('\nAvailable rotation methods: %s\n', strjoin(valid_methods, ', '));

while true
    rot_method = {input('Enter rotation method: ', 's')};
    if ~isempty(rot_method{1}) && ischar(rot_method{1}) && any(strcmp(rot_method{1}, valid_methods))
        break;
    else
        fprintf('Invalid input. Please enter one of the available rotation methods.\n');
    end
end

Extract_Rotate_Components(baseDIR, num_components, 'R', 'G', rot_method)

% flip the sign of loading with validation
while true
    comp_to_flip = input(sprintf('Enter component number to flip (0 for none, 1 to %d): ', num_components));
    if isnumeric(comp_to_flip) && comp_to_flip >= 0 && comp_to_flip <= num_components && mod(comp_to_flip, 1) == 0
        break;
    else
        fprintf('Invalid input. Please enter a number between 0 and %d.\n', num_components);
    end
end

if comp_to_flip > 0
    Flip_Component(baseDIR, comp_to_flip);
end

%%option tools
% please run this if you moved the data
% Z_path_repair_cmd(baseDIR);