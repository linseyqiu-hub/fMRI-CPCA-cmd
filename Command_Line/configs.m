%% configs.m - CPCA Analysis Configuration File
% This file defines all parameters for the CPCA analysis

% Initialize empty config structure
config = struct();

% Base directory of fMRI-CPCA script
config.cpcaDIR = '/media/abhijit.chinchani/My Passport/Abhijit/fMRI_Analysis/fMRI_CPCA_cmd/fMRI_CPCA_CMD_Abhijit/code/fMRI-CPCA-cmd/'; % Should be PATH/cpca_1.2.2.23

% Base directory containing your data
config.baseDIR = '/media/abhijit.chinchani/My Passport/Abhijit/fMRI_Analysis/fMRI_CPCA_cmd/fMRI_CPCA_CMD_Abhijit/data/example_data_1/example_data_Multiple_Groups_Subjects_Runs/';

% File wildcard for scan selection (e.g., 'swa*nii' or 'fsn*img')
config.filewildcard = 'fsn*img';

% Mask parameters
config.maskName = 'mask.img';  % Name of the mask file
config.createMask = 1;  % 1 to create a new mask, 0 to use existing mask
config.maskMethod = 1;  % 1-Global mean threshold; 2-Harvard Oxford MNI coordinates

% Normalization parameters
config.linearRegress = 1;      % 1-On, 0-Off
config.quadraticRegress = 1;   % 1-On, 0-Off
config.movementRegress = 0;    % 1-On, 0-Off
config.userCovariants = '';    % Filename for user-defined covariants (leave empty if none)
config.meanCenter = 1;         % 1-On, 0-Off
config.standardize = 1;        % 1-On, 0-Off

% G matrix parameters
config.condition_names = {'2_letters', '4_letters', '6_letters', '8_letters'};  % List of condition names
config.bins = 8;        % Number of time bins
config.TR = 3;          % Timing rate
config.inScans = 1;     % 1 for Scans timing, 0 for seconds
config.normalize_G = 1; % 1 to normalize G matrix, 0 to not normalize

% Timing parameters
config.num_subjects = 4;    % Number of subjects
config.num_runs = 2;        % Number of runs per subject
config.num_conditions = 4;  % Number of conditions

% Component extraction parameters
config.num_components = 2;  % Number of components to extract
config.rotation_method = 'varimax';  % Rotation method: varimax, promax, hrfmax, orthomax, quartimax, equamax, procrustes
config.components_to_flip = [];  % List of component indices to flip (e.g., [2] to flip second component)