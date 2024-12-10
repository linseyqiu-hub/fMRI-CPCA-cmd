% command-line demo scripts
warning('off','all')
%% add fmri-cpca folder and all subfolders into matlab path
addpath(genpath('/Users/wsu/cpca_1.2.2.23/'));
% work folder
baseDIR = '/Users/wsu/example_data_Multiple_Groups_Subjects_Runs';
%% create scan list
% make sure the baseDIR does not have other folders except the folders with
% scans. this command will remove processed stuffs completely. You can
% skip this command if you like to keep processed data.
%
% function Create_File_List(subject_dir,filewildcard,output_dir,filename,isMulFreq)
%
% --- uses 3 levels of directories to determine scan grouping, particpant
% --- lists and session numbers.  Will also allow for multiple frequency
% --- range MEG/EEG beamformed images.
% ---
% --- input:
% ---     subject_dir: specify the folder that contains the fMRI scans,
% ----     filewildcard: scan list wildcard specification, supports .img and
% ---                    .nii format, for example 'fsn*.img'
% ---      output_dir: output folder for the text file, if not provided, the
% ----                 output_dir is same as subject_dri
% ---      filename: specify the name of text file, if not
% ---                provided, the default name is 'files.txt'
% ---      isMulFreq: 1 if multiple frequencies, if not provided, the
% ---                 default is 0
Create_File_List(baseDIR, 'fsn*img');
%% create Z matrix
%
%function Create_ZData_Matrix(base_dir,varargin)
%
% --- input:
% ---     base_dir: specify work folder,
% ---     fileName: list file created from Create_File_List command
% ---     maskName: mask file name, default 'mask.img' 
% ---         if maskMethod is provided, it will create a new mask
% ---         or else, assume the mask is existing
% ---     maskMethod: mask creation method, 1-Global mean threshold; 2-Harvard Oxford MNI coordinates   
% --- example usage: Create_ZData_Matrix(baseDIR) 
% ---                Create_ZData_Matrix(baseDIR, 'fileName', 'files.txt', 'maskName', 'mask.img','maskMethod',2);
 Create_ZData_Matrix(baseDIR, 'fileName', 'files.txt', 'maskName', 'mask.img');

%% Normalize Z matrix
%
%function process_subject_normalization_cmd(base_dir,varargin)
%
% --- input:
% ---     base_dir: specify work folder,
% --      linearRegress: 1- On (default), 0 - Off
% --      quadraticRegress: 1- On (default), 0 - Off
% --      movementRegress: 1- On, 0 - Off (default), looking for rp{...}.txt file
% --      userCovariants: filename for user define covariants
% --      meanCenter: 1- On (default), 0 - Off
% --      standardize: 1- On (default), 0 - Off
% --- example usage: 
% ---  process_subject_normalization_cmd(baseDIR)
process_subject_normalization_cmd(baseDIR,'linearRegress',1,'quadraticRegress',1,'meanCenter',1,'standardize',1)

%% initailize G matrix
GH = structure_define('gheader');
GH.condition_name = {'2_letters', '4_letters', '6_letters', '8_letters'};% --- conditon list
GH.bins = 8; %time Bins
GH.TR = 3; %timing Rate
GH.inScans = 1; %Timing in Seconds or Scans: 1 for Scans, 0 for seconds?
GH.normalize_me = 1; %Normalize G matrix: 1 for yes, 0 for no
timing = {'55.269 79.07 89.12 118.57 123.27 138.01 163.45 179.19 189.25', ...
          '5.03 10.38 20.77 69.68 74.38 108.52 132.99 158.43 199.29', ...
          '15.74 25.79 40.54 143.37 148.73 168.81 173.83 183.89 194.269', ...
          '30.49 35.84 45.24 59.96 64.66 84.1 94.48 113.21 128.29'};% --- timimg onsets
% create timing osets template, the output file name is timing_onsets_template.txt
create_onsets_template_cmd(baseDIR,GH,timing);
%% creat G matrix
% function Create_GMatrix(base_dir,GH, filename )
% ---  input:
% ---        GH: GH struction defined in the previous step
% ---        filename: timing onsets file created from the previous step
Create_GMatrix(baseDIR,GH, 'timing_onsets_template.txt' )
%% regress G matrix
% function RegressG(base_dir, model)
RegressG(baseDIR, 'G'); % good for G model only
%% extract, rotate and flip components
% function Extract_Rotate_Components(base_dir, numcomps, EorR, model, rot_method)
Extract_Rotate_Components(baseDIR, 2, 'E', 'G')  % two components
% rotate components
rot_method = {'varimax'};% supported roation methods: varimax, promax, hrfmax (need
% shapes.mat),orthomax, quartimax, equimax, hrf-procrustes and procrustes
Extract_Rotate_Components(baseDIR, 2, 'R', 'G', rot_method)  % rotate extracted two components
%flip the sign of loading
Flip_Component(baseDIR, 2); % flip the second component, only can filp one compoent each time

%%option tools
% please run this if you moved the data
% Z_path_repair_cmd(baseDIR);
