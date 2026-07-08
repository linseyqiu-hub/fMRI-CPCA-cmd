%% configs.m - CPCA Analysis Configuration File
% This file defines all parameters for the CPCA analysis

% Initialize empty config structure
config = struct();

% Base directory of fMRI-CPCA script
config.cpcaDIR = 'D:\fMRI-CPCA\fMRI-CPCA-cmd'; % Should be PATH/cpca_1.2.2.23

% Base directory containing your data
config.baseDIR = 'D:\fMRI-CPCA\NITRC-multi-file-downloads (1)\example_data_Single_Subject';

% Output directory (optional)
% If empty, output will be placed in baseDIR (legacy behaviour)
% If specified, all fMRI-CPCA output will be placed here instead
config.outputDIR = 'D:\fMRI-CPCA\singleRunOutPut';  % e.g., 'D:\fMRI-CPCA\output'

% File wildcard for scan selection (e.g., 'swa*nii' or 'fsn*img')
config.filewildcard = 'fsn*img';

% Mask parameters
config.maskName = 'mask.img';  % Name of the mask file
config.createMask = 1;  % 1 to create a new mask, 0 to use existing mask
config.maskMethod = 2;  % 1-Global mean threshold; 2-Harvard Oxford MNI coordinates
config.removeVentricles = 1; % 1 to exclude ventricles, 0 to include ventricles

% Normalization parameters
config.linearRegress = 1;      % 1-On, 0-Off
config.quadraticRegress = 1;   % 1-On, 0-Off
config.movementRegress = 0;    % 1-On, 0-Off
config.userCovariants = '';    % Filename for user-defined covariants (leave empty if none)
config.meanCenter = 1;         % 1-On, 0-Off
config.standardize = 1;        % 1-On, 0-Off


% G matrix parameters
config.bins = 8;        % Number of time bins
config.TR = 3;          % Timing rate
config.inScans = 1;     % 1 for Scans timing, 0 for seconds
config.normalize_G = 1; % 1 to normalize G matrix, 0 to not normalize






% --- Solution 1: nd = 2 ---
config.solutions(1).num_components               = 2;
config.solutions(1).rotation_method               = 'hrfmax';
config.solutions(1).hrfmax_iterations             = 100000;
config.solutions(1).hrfmax_events(1).onset        = 0;
config.solutions(1).hrfmax_events(1).duration     = 500;
config.solutions(1).hrfmax_events(1).description  = 'visual onset';
config.solutions(1).hrfmax_events(2).onset        = 500;
config.solutions(1).hrfmax_events(2).duration     = 1000;
config.solutions(1).hrfmax_events(2).description  = 'visual display';
config.solutions(1).hrfmax_events(3).onset        = 1500;
config.solutions(1).hrfmax_events(3).duration     = 1000;
config.solutions(1).hrfmax_events(3).description  = 'response process';
% event 4 omitted — evaluation process excluded
config.solutions(1).components_to_flip.unrotated  = [1 2];
config.solutions(1).components_to_flip.rotated    = [1 2];

% --- Solution 2: nd = 3 ---
config.solutions(2).num_components               = 3;
config.solutions(2).rotation_method               = 'hrfmax';
config.solutions(2).hrfmax_iterations             = 100000;
config.solutions(2).hrfmax_events(1).onset        = 0;
config.solutions(2).hrfmax_events(1).duration     = 500;
config.solutions(2).hrfmax_events(1).description  = 'visual onset';
config.solutions(2).hrfmax_events(2).onset        = 500;
config.solutions(2).hrfmax_events(2).duration     = 1000;
config.solutions(2).hrfmax_events(2).description  = 'visual display';
config.solutions(2).hrfmax_events(3).onset        = 1500;
config.solutions(2).hrfmax_events(3).duration     = 1000;
config.solutions(2).hrfmax_events(3).description  = 'response process';
config.solutions(2).components_to_flip.unrotated  = [1 2];
config.solutions(2).components_to_flip.rotated    = [1 2];

% --- Solution 3: nd = 4 ---
config.solutions(3).num_components               = 4;
config.solutions(3).rotation_method               = 'hrfmax';
config.solutions(3).hrfmax_iterations             = 100000;
config.solutions(3).hrfmax_events(1).onset        = 0;
config.solutions(3).hrfmax_events(1).duration     = 500;
config.solutions(3).hrfmax_events(1).description  = 'visual onset';
config.solutions(3).hrfmax_events(2).onset        = 500;
config.solutions(3).hrfmax_events(2).duration     = 1000;
config.solutions(3).hrfmax_events(2).description  = 'visual display';
config.solutions(3).hrfmax_events(3).onset        = 1500;
config.solutions(3).hrfmax_events(3).duration     = 1000;
config.solutions(3).hrfmax_events(3).description  = 'response process';
config.solutions(3).components_to_flip.unrotated  = [1 2];   % placeholder — confirm once nd=4 run exists
config.solutions(3).components_to_flip.rotated    = [1 2];   % placeholder — confirm once nd=4 run exists

% --- Solution 4: nd = 5 ---
config.solutions(4).num_components               = 5;
config.solutions(4).rotation_method               = 'hrfmax';
config.solutions(4).hrfmax_iterations             = 100000;
config.solutions(4).hrfmax_events(1).onset        = 0;
config.solutions(4).hrfmax_events(1).duration     = 500;
config.solutions(4).hrfmax_events(1).description  = 'visual onset';
config.solutions(4).hrfmax_events(2).onset        = 500;
config.solutions(4).hrfmax_events(2).duration     = 1000;
config.solutions(4).hrfmax_events(2).description  = 'visual display';
config.solutions(4).hrfmax_events(3).onset        = 1500;
config.solutions(4).hrfmax_events(3).duration     = 1000;
config.solutions(4).hrfmax_events(3).description  = 'response process';
config.solutions(4).components_to_flip.unrotated  = [1 2];   % placeholder — confirm once nd=5 run exists
config.solutions(4).components_to_flip.rotated    = [1 2];   % placeholder — confirm once nd=5 run exists






%% ── Auto-generated by generate_config (do not edit manually) ──
config.num_subjects   = 1;
config.num_runs       = 1;
config.num_conditions = 4;
config.condition_names = { ...
    '2_Letters', ...
    '4_Letters', ...
    '6_Letters', ...
    '8_Letters'  ...
};
config.subject_conditions{1} = { [1  2  3  4] };  % s01: (no run subfolder)
%% ── End auto-generated ──
