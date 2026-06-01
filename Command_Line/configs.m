%% configs.m - CPCA Analysis Configuration File
% This file defines all parameters for the CPCA analysis

% Initialize empty config structure
config = struct();

% Base directory of fMRI-CPCA script
config.cpcaDIR = 'D:\fMRI-CPCA\fMRI-CPCA-cmd'; % Should be PATH/cpca_1.2.2.23

% Base directory containing your data
config.baseDIR = 'D:\fMRI-CPCA\Example_Data_2MergedTasks';

% Output directory (optional)
% If empty, output will be placed in baseDIR (legacy behaviour)
% If specified, all fMRI-CPCA output will be placed here instead
config.outputDIR = 'D:\fMRI-CPCA\mergedOutPut';  % e.g., 'D:\fMRI-CPCA\output'

% File wildcard for scan selection (e.g., 'swa*nii' or 'fsn*img')
config.filewildcard = '*nii';

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
config.condition_names = {'4Letters_NoDelay', '4Letters_2Delay', '6Letters_NoDelay', '6Letters_2Delay', 'pain_standard_high', 'pain_standard_low', 'pain_reg-up_high', 'pain_reg-up_low', 'pain_reg-down_high', 'pain_reg-down_low'};  % List of condition names
config.bins = 8;        % Number of time bins
config.TR = 3;          % Timing rate
config.inScans = 1;     % 1 for Scans timing, 0 for seconds
config.normalize_G = 1; % 1 to normalize G matrix, 0 to not normalize

% Timing parameters
config.num_subjects = 7;    % Number of subjects
config.num_runs = 9;        % Number of runs per subject
config.num_conditions = 10;  % Number of conditions

% Component extraction parameters
config.solutions(1).num_components = 2;
config.solutions(1).rotation_method = 'varimax';
config.solutions(1).components_to_flip.unrotated = [1];      % flip component 1 in unrotated
config.solutions(1).components_to_flip.rotated   = [1 2];    % flip components 1 and 2 in varimax

config.solutions(2).num_components = 3;
config.solutions(2).rotation_method = 'varimax';
config.solutions(2).components_to_flip.unrotated = [];       % no flips in unrotated
config.solutions(2).components_to_flip.rotated   = [2];      % flip component 2 in varimax only