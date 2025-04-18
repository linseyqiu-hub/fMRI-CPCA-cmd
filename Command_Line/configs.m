% CPCA Analysis Configuration File
% Edit parameters below to customize your analysis

% Base directory containing your data
config.baseDIR = 'Z:\Path\To\Your\Data';

% File wildcard for scan selection (e.g., 'swa*nii' or 'fsn*img')
config.filewildcard = 'swa*nii';

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
config.condition_names = {'CONDITION1', 'CONDITION2'};  % List of condition names
config.bins = 8;        % Number of time bins
config.TR = 2;          % Timing rate
config.inScans = 1;     % 1 for Scans timing, 0 for seconds
config.normalize_G = 1; % 1 to normalize G matrix, 0 to not normalize

% Timing parameters
config.num_subjects = 6;    % Number of subjects
config.num_runs = 1;        % Number of runs per subject
config.num_conditions = 2;  % Number of conditions

% Component extraction parameters
config.num_components = 2;  % Number of components to extract
config.rotation_method = 'varimax';  % Rotation method: varimax, promax, hrfmax, orthomax, quartimax, equamax, procrustes
config.components_to_flip = [];  % List of component indices to flip (e.g., [2] to flip second component)