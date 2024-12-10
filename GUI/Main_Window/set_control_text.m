function control_text = set_control_text() 
% set the default textual phrasing of GUI controls
%
% to reset the text of available controls, change the 'text' structure element to the desired text
%
%  eg control_text = vertcat( control_text, struct ( ...
%     'control','btn_ChangeDirectory', 	'text', 'YOUR TEXT', 	'description','text of Change Directory button' ) );
%
% the descriptions are only there to give you a hint of what control you're looking at

% ---------------------------------
% System Panel
% ---------------------------------

control_text = [];

control_text = vertcat( control_text, struct ( ...
  'control','lbl_Available', 		'text', 'Available', 	'description','text of Avialable title display label' ) );

control_text = vertcat( control_text, struct ( ...
  'control','lbl_Estimated', 		'text', 'Estimated', 	'description','text of Estimated title display label' ) );

control_text = vertcat( control_text, struct ( ...
  'control','lbl_Memory', 		'text', 'Memory', 	'description','text of Memory Consumption row title' ) );


control_text = vertcat( control_text, struct ( ...
  'control','lbl_DriveSpace', 		'text', 'Drive Space', 	'description','text of Drive Consumption row title' ) );



control_text = vertcat( control_text, struct ( ...
  'control','lbl_EstimatedTime', 	'text', ' Needed Time:', 'description','text of estimated time display label' ) );

control_text = vertcat( control_text, struct ( ...
  'control','btn_FileList', 		'text', 'Create List', 	'description','text of create file list button' ) );

control_text = vertcat( control_text, struct ( ...
  'control','btn_ChangeDirectory', 	'text', 'CD', 		'description','text of Change Directory button' ) );


% ---------------------------------
% Subject Panel
% ---------------------------------

control_text = struct ( ...
  'control','SubjectSelect', 		'text', 'Select', 	'description','text of select subjects button');

control_text = struct ( ...
  'control','btn_EditZ0', 		'text', 'Info', 	'description','text of Z editor button');

control_text = struct ( ...
  'control','btn_verify_scans', 	'text', 'Verify', 	'description','text of scan verification call');

%control_text = struct ( ...
%  'control','lbl_SubjectLocation', 	'text', 'Location', 	'description','text of subject data location display');


%control_text = struct ( ...
%  'control','lbl_Subjects', 		'text', 'Subjects', 	'description','text of number of subjects label');

%control_text = struct ( ...	
%  'control','lbl_Runs', 		'text', 'Runs',		'description','text of number of Runs label');

control_text = struct ( ...
  'control','lbl_NumScans', 		'text', 'Total scans:', 	'description','text of number of scans label');

%control_text = struct ( ...
%  'control','lbl_NumVoxels', 		'text', 'Voxels', 	'description','text of number of voxels label');

control_text = struct ( ...
  'control','lbl_Segments', 		'text', 'Partitions', 	'description','text of number of column partitions');

%control_text = struct ( ...
%  'control','lbl_MinScans', 		'text', 'Mn', 		'description','text of minimum scans in a subject label');

%control_text = struct ( ...
%  'control','lbl_MaxScans', 		'text', 'Mx', 		'description','text of maximum scans in a subject label');

%control_text = struct ( ...
%  'control','chk_ScanDirExists', 	'text', 'Exists', 	'description','text of subject data direcory exists label');

%control_text = struct ( ...
%  'control','chk_MeanCentered', 	'text', 'Mean Centered', 'description','text of subject data Mean Centered label');

%control_text = struct ( ...
%  'control','chk_Normalized', 		'text', 'Standardized',	'description','text of subject data Normalized label');


%control_text = struct ( ...
%  'control','btn_SelectMask', 		'text', 'Mask', 	'description','text of select Mask button');

%control_text = struct ( ...
%  'control','txt_MaskDimensions', 	'text', 'Dimesnions', 	'description','text of Mask dimensions label');


% ---------------------------------
% Model Panel
% ---------------------------------

%control_text = vertcat( control_text, struct ( ...
%  'control','btn_createG', 		'text', 'Create', 	'description','text of G Creation button' ) );

%control_text = vertcat( control_text, struct ( ...
%  'control','btn_SelectG', 		'text', 'Select', 	'description','text of G Selection button' ) );

control_text = vertcat( control_text, struct ( ...
  'control','lbl_GConditions', 	'text', 'Conditions:', 	'description','text of G Conditions display label' ) );

control_text = vertcat( control_text, struct ( ...
  'control','lbl_GTimeBins', 		'text', 'Time Bins:', 	'description','text of time bins display label' ) );

%control_text = vertcat( control_text, struct ( ...
%  'control','btn_PlotOptions', 	'text', 'Plot Options', 'description','text of G Plot Options button' ) );

%control_text = vertcat( control_text, struct ( ...
%  'control','btn_PlotG_UR', 		'text', 'Plot', 	'description','text of G Plot button' ) );


%control_text = vertcat( control_text, struct ( ...
%  'control','Btn_SelectA', 		'text', 'Select', 	'description','text of A Selection button' ) );

%control_text = vertcat( control_text, struct ( ...
%  'control','btn_SelectH', 		'text', 'Select', 	'description','text of H Selection button' ) );

%control_text = vertcat( control_text, struct ( ...
%  'control','btn_SelectP', 		'text', 'Select', 	'description','text of P Selection button' ) );

%control_text = vertcat( control_text, struct ( ...
%  'control','btn_SelectD', 		'text', 'Select', 	'description','text of D Selection button' ) );



% ---------------------------------
% Processing Panel
% ---------------------------------

%control_text = vertcat( control_text, struct ( ...
%  'control','btn_run_subject_process', 	'text', ' Normalize', 		'description','text of toggle button for subject processes' ) );

control_text = vertcat( control_text, struct ( ...
  'control','chk_create_z', 		'text', ' Create Z', 		'description','text of checkbox perform create Z from Subject Data' ) );

control_text = vertcat( control_text, struct ( ...
  'control','chk_linear_regress', 	'text', ' Linear', 		'description','text of checkbox apply Linear regression to Subject Data' ) );

control_text = vertcat( control_text, struct ( ...
  'control','chk_quad_regress', 	'text', ' Quadratic', 	        'description','text of checkbox apply Quadratic regression to Subject Data' ) );

control_text = vertcat( control_text, struct ( ...
  'control','chk_mean_center', 		'text', ' Mean Center', 	'description','text of checkbox apply mean centering to Subject Data' ) );

control_text = vertcat( control_text, struct ( ...
  'control','chk_standardize', 		'text', ' Standardize', 	'description','text of checkbox apply standard deviation to Subject Data' ) );

control_text = vertcat( control_text, struct ( ...
  'control','chk_create_ZZ', 		'text', ' Create ZZ''', 	'description','text of checkbox perform create Z*Z'' from Subject Data' ) );

% ---------------------------------


%control_text = vertcat( control_text, struct ( ...
%  'control','btn_run_ga_process', 	'text', ' G', 		'description','text of toggle button for G/A processes' ) );

control_text = vertcat( control_text, struct ( ...
  'control','chk_apply_G', 		'text', ' Regress', 		'description','text of checkbox perform apply G to Z' ) );

control_text = vertcat( control_text, struct ( ...
  'control','chk_extract_g', 		'text', ' Extract Components', 		'description','text of checkbox perform extract components from G' ) );

control_text = vertcat( control_text, struct ( ...
  'control','chk_apply_ga', 		'text', ' Activate A', 		'description','text of checkbox perform apply GA to Z' ) );

control_text = vertcat( control_text, struct ( ...
  'control','chk_extract_ga', 		'text', ' Extract Components', 		'description','text of checkbox perform extract components from GA' ) );

control_text = vertcat( control_text, struct ( ...
  'control','chk_apply_gaa', 		'text', ' Activate ~A', 	'description','text of checkbox perform apply GAA'' to Z' ) );


% ---------------------------------


%control_text = vertcat( control_text, struct ( ...
%  'control','btn_run_h_process', 	'text', 'H',	 			'description','text of toggle button for H processes' ) );

control_text = vertcat( control_text, struct ( ...
  'control','chk_apply_gh', 		'text', ' Regress', 		'description','text of checkbox perform H explained by G' ) );

control_text = vertcat( control_text, struct ( ...
  'control','chk_apply_gah', 		'text', ' Exp. by GA', 		'description','text of checkbox perform H explained by GA' ) );

control_text = vertcat( control_text, struct ( ...
  'control','chk_apply_gaah', 		'text', ' ~Exp. by A', 		'description','text of checkbox perform H explained by G but not by A' ) );

control_text = vertcat( control_text, struct ( ...
  'control','chk_extract_h', 		'text', ' Extract', 		'description','text of checkbox perform extract components from G*ZH' ) );

% ---------------------------------

%control_text = vertcat( control_text, struct ( ...
%  'control','btn_run_GMh_process', 	'text', 'GMH',	 		'description','text of toggle button for GMH processes' ) );

control_text = vertcat( control_text, struct ( ...
  'control','chk_apply_gmh', 		'text', ' Regress',	 	'description','text of apply GMH check box' ) );

% ---------------------------------

control_text = vertcat( control_text, struct ( ...
  'control','btn_run_pd_process', 	'text', ' P D', 		'description','text of toggle button for PD processes' ) );

control_text = vertcat( control_text, struct ( ...
  'control','chk_apply_pd', 		'text', ' Regress', 		'description','text of checkbox perform apply PD to ZZ' ) );

control_text = vertcat( control_text, struct ( ...
  'control','chk_extract_pd', 		'text', ' Extract', 		'description','text of checkbox perform extract components from PD' ) );


% ---------------------------------
% Run Processes button
% ---------------------------------

control_text = vertcat( control_text, struct ( ...
  'control','btn_PerformCPCA',	 	'text', 'RUN', 			'description','text of RUN button' ) );


