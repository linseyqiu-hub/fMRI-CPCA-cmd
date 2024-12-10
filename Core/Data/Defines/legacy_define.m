function st = legacy_define( strucName )
% ---
% --- create legacy style structures for compatibilty
% --- during redefinition of studyInfo structure
% ---
% --- will be retained for conversion of legacy structures (ZInfo)
% --- after redployment




  st = [];

  % --- if no parameter, return the empty structure
  if nargin == 0
    return;
  end;


  switch lower( strucName )
    % --- --------------------------------------
    % --- legacy values from original global structure
    % --- --------------------------------------
    case 'legacy'
      st = struct( ...
        'g_index', 14, ...                	% number of entries (rows) in the GAZ records
        'g_mat', 1, ...                   	% offset into zh.GAZ for G matrix information
        'p_mat', 2, ...                   	% offset into zh.GAZ for P matrix information
        'd_mat', 3, ...                   	% offset into zh.GAZ for D matrix information
        'a_mat', 4, ...                  	% offset into zh.GAZ for A matrix information
        'h_mat', 5, ...                   	% offset into zh.GAZ for H matrix information
        'ga_mat', 6, ...                 	% offset into zh.GAZ for GA matrix information
        'gz_mat', 7, ...                 	% offset into zh.GAZ for GA'Z matrix information
        'gaz_mat', 8, ...                 	% offset into zh.GAZ for GA'Z matrix information
        'gaa_mat', 9, ...                 	% offset into zh.GAZ for GAA matrix information
        'gaaz_mat', 10,...                  % offset into zh.GAZ for GAAZ matrix information
        'gzh_mat', 11,...                   % offset into zh.GAZ for GA'*Z*H matrix information
        'gazh_mat', 12,...                  % offset into zh.GAZ for GA'*Z*H matrix information
        'gaazh_mat', 13,...                 % offset into zh.GAZ for GAA'*Z*H matrix information
        'model_mat', 14, ...
        'size_QWORD', 10, ...               % --- replaced with constant_define( 'SIZE_QWORD')
        'size_MB', 1024000, ...             % --- replaced with constant_define( 'SIZE_MB')
        'size_KB', 1024 ...                 % --- replaced with constant_define( 'SIZE_KB')
     );
     return

     case 'scan_information'
       st = struct ( ...
        'NumSubjects', 0, ...
        'NumRuns', 0, ... 
        'MinRuns', 0, ... 
        'NumGroups', 0, ... 
        'isMulFreq', 0, ... 			% flag to indicate this is meg processed data [2.93]
        'frequencies', 0, ...			% the number of meg frequencies scanned       [2.93]
        'freq_names', '', ...			% user can change names for display purposes  [2.93]
        'freq_dirs', [], ...			% this determines path to frequency scans     [2.93]
        'BaseDir', '', ...
        'ListSpec', '', ... 
        'DirChar', '/', ...           	% the directory specifier defaults to unix style 
        'SubjDir', [], ...
        'SubjectDirs', [], ...		% for path to scans construction              [2.93]
        'run_dirs', [], ...			% for path to scans construction when runs    [2.93]
        'scandir_format', '', ...		% format template for scan path construction  [2.93]
        'FileList', '', ...			% full path of text file list to be parsed
        'SubjectID', [], ...			% list of subject ID's
        'duplicate_IDs', 0, ...		% flag for subject IDs containing duplications [2.96] 
        'GroupList', [], ...
        'hm_regress_dir', [], ...		% the directory head movement regression text files located in
        'tags', struct ( ...			% vars for processing file list section tags
          'subjects', 'subjects', ...		% text from file tagging variable as number of subjects
          'basedir', 'base_directory', ...	% text from file tagging variable as base directory ...
          'listspec', 'list', ...		% text from file tagging variable as file list spec
          'runs', 'runs', ...			% text from file tagging variable as subject runs count
          'subjectdir', 'sdir' ), ...		% text from file tagging variable as subject sub directories
        'processing', struct ( ...		% main holder for processing control
          'subjects', struct ( ...		% processing subject scans
            'apply',        0, ...		  % apply any of the subject processes to the subject scans
            'normalized',   '', ...		  % container for date of normalization
            'rp_count',     0, ...		  % number of valid rp_*.txt files in scan directories
            'rp_width',     0, ...		  % width of data set in rp file for comparison to others
            'run_count',   0, ...               % total number of run directories for all subjects  [3.03]
            'tt_count',     0, ...		  % number of valid trial_tim*.txt files in scan directories [3.41]
            'process', struct ( ...		  % processing subset Subject data
              'create_Z',   0, ...		    % flag whether to read and/or reprocess raw scanned image data	
              'mean_center',0, ...		    % flag whether to mean center the raw data
              'standardize',0, ...		    % flag whether to apply STD to raw data
              'extract_clusters',0, ...	    % flag whether to extract specified cluser voexl from pre normalized Z data
              'apply_regression',    0, ...	    % flag whether to apply regression to raw data
              'movement_regress',    0, ...	    %  - apply head movement regression to raw data
              'linear_regress',    0, ...	    %  - linear regression to raw data
              'quadratic_regress', 0, ...	    %  - apply quadratic regression to raw data
              'user_covariants', 0, ...	    %  - apply user covaiant regression to raw data
              'user_covariants_file', '', ...	    %  - apply user covaiant regression from file
              'create_ZZ',  0, ...		    % flag whether to create a Z*Z' matrix
              'resume', 0, ...    	      	      % flag to resume from last successfull position
              'last_subject', 0) ...    	      % last subject number successfully normalized 
          ), ...				
          'model', struct ( ...		% processing subset G/A Model application
            'apply',        0, ...		  % apply any of the Model processes to the data
            'parameters', structure_define( 'MODEL_CREATION' ), ...	  % G model  parameter information
            'process', struct ( ...		  % processing subset G/GA data
              'group_index', 0, ...	    	    % index into group subject list vector ( 0 = all subjects )
              'apply_g',    0, ...	    	    % apply the G model to the data
              'apply_ga',   0, ...	    	    % apply the GA model to the data
              'apply_gaa', 0, ...	    	    % apply the GAA model to the data ( orthoganal not explained by A )
              'extract_g',  0, ...	  	    % extract components from the G regression data - ignored: now rotation
              'subject_specific',  0, ...	    % extract subject specific information  [ 2.95 ]
              'subject_specific_rotated',  0, ... % apply subject specific to all defined rotations  [ 3.01 ]
              'rotate_g',   0, ...	  	    % rotate components extracted in G application
              'extract_ga', 0, ...	  	    % extract components from the GA regression data
              'components', 0, ...	   	    % number of components to extract
              'svd', 1, ...	   	            % svd process flag for each defined componet count
              'component_name', {''}), ...	    % The names of the components for plot titles - not used in G creation, used in plotting
            'applied', struct ( ...		  % processing subset G/GA data
              'apply_g',    0, ...	    	    % applied the G model to the data
              'resume_g', struct ( ...	    % allow resumption of G application
        	    'resume', 0, ...    	      	      % flag to process from last successfull subject GZ/C creation
      	        'last_subject', 0, ...    	      % last subject number successfully created for GZ and C
                'CC', 0, ...			      % [ 3.40 ] full C * C' array successfuly created
                'Eigs', 0 , ...		      % [ 3.40 ] Eigenvalues of C * C' array successfuly calculated
              'Reprocess', []), ...		      % [ 3.40 ] List of subjects to reprocess
              'apply_ga',   0, ...	    	    % applied the GA model to the data
              'apply_gaa', 0, ...	    	    % applied the GAA model to the data ( orthoganal not explained by A )
              'extract_g',  0, ...	  	    % extracted components from the G regression data      
              'rotate_g',  0, ...	  	    % extracted components have been rotated
              'extract_ga', 0), ...	    	    % extracted components from the G regression data
            'rotation',  [] ... 		  % rotation settings applied to model
          ), ...				
          'H_model', struct ( ...		% processing subset H Model application
            'apply',   0, ...		  	  % apply any of the H Model processes to the data
            'extract', 0, ...	  	    	  % extract components from the H regression data
            'rotate',  0, ...	 	 	    % rotate extracted components
            'path_to_segs', '', ...		    % path to where G*ZH segment data resides
            'process', struct ( ...		    % processing subset H data
              'hz',   0, ...	    	    	      % apply/rotate HZ
              'he',   0, ...	    	   	      % apply/rotate HE
              'components', 0, ...	   	      % number of components to extract from HZ/HE
              'component_name', {''}), ...	      % The names of the components for plot titles - not used in G creation, used in plotting
            'applied', struct ( ...		    % processing subset G/GA data
              'resume_h', struct ( ...	    % allow resumption of G application
           	  'resume', 0, ...    	      	      % flag to priocess from last successfull position
      	      'last_subject', 0, ...    	      % last subject number successfully applied 
      	      'B_calculated', 0, ...    	      % B matrix successfully calculated
      	      'BB_created', 0 ), ...    	      % B*B matrix successfully created
            'apply_hz',   0, ...	    	    % apply H to Z
            'apply_he',   0, ...	    	    % apply H to E
            'extract_hz',   0, ...	    	    % extract H to Z
            'extract_he',   0, ...	    	    % extract H to E
            'rotate_hz',   0, ...	    	    % rotate H to Z
            'rotate_he',   0, ...	    	    % rotate H to E
            'rotation',  [] ... 		  % rotation settings applied to H 
            ) ...				
          ), ...				
          'GMH_model', struct ( ...		% processing subset H Model application
            'apply',   0, ...		  	  % apply any of the H Model processes to the data
            'extract', 0, ...	  	    	  % extract components from the H regression data
            'rotate',  0, ...	 	 	    % rotate extracted components
            'subject_specific',  0, ...	    % extract subject specific information  [ 2.95 ]
            'subject_specific_rotated',  0, ... % apply subject specific to all defined rotations  [ 3.01 ]
            'path_to_segs', '', ...		    % path to where G*ZH segment data resides
            'options', structure_define( 'GMH_OPTIONS' ), ...	    % gmh variable and output options  [ 3.31 ]
            'process', struct ( ...		    % processing subset H data
              'gmh',  0, ...	    	    	      % apply/rotate GMH
              'components', 0, ...	              % number of components to extract from GMH
              'component_name', {''}), ...	      % The names of the components for plot titles - not used in G creation, used in plotting
            'applied', struct ( ...		    % processing subset G/GA data
              'started', 0, ...		
              'completed', 0, ...		
              'resume', 0, ...
              'var_prep', struct( 'Qg', 0, 'Qh', 0 ), ...
              'regression', struct( 'GMH', 0, 'BH', 0, 'GC',  struct( 'HC', 0, 'C', struct( 'last_subject', 0, 'last_freq', 0 ), 'bb', 0 ) ), ...
              'gmh',    0, ...	    	    % applied the G model to the GZ data
              'extract',  0, ...	  	    % extracted components from the G*ZH regression data
              'rotate',  0, ...	  	    % extracted components have been rotated
              'rotation',  [] ) ... 		  % rotation settings applied to H 
          ), ...				
          'PD_model', struct ( ...		% processing subset PD Model application
            'apply',        0, ...	  	  % apply any of the PD Model processes to the data
            'process', struct ( ...		  % processing subset H data
              'apply_pd',   0, ...	    	    % apply the PD model to the data
              'extract',    0, ...	  	    % extract components from the PD regression data
              'components', 0, ...	   	    % number of components to extract
              'component_name', {''}) ...	    % The names of the components for plot titles - not used in G creation, used in plotting
          ) ...
        ), ...				% end of structure processing
        'scan_subjects', 1, ...           	% flag to scan all subjects
        'read_subject_images', 1, ...         % flag to read all subject images
        'mean_center_subjects', 0, ...    	% flag to normalize each subject
        'normalize_subjects', 0, ...      	% flag to normalize each subject
        'ZZ_process', 1, ...      		% flag to create ZZ Segments
        'apply_ga', 0, ...			% flag to apply GAZ processing 
        'ga_processes', struct( ...		% the process components of GAZ calculations
          'model', 0, ...             	  % apply the GA model to the normlized Z data
          'a_not_explained', 0, ...             % determine A not explained by GA
          'extract_components', 0, ...    	  % extract components
          'create_images', 0), ...           	  % create images from GAZ data
        'apply_pd', 0, ...			% flag to apply PDZZ processing 
        'apply_h', 0, ...			% flag to apply GAZH processing 
        'images', struct( ...			% fklags to indicate whether to display imapges and plots
          'show', 0, ...	    	  	  % display images and plots associated master switch
          'show_G', 0, ...    	  	  % display images and plots associated with G
          'show_A', 0, ...    	  	  % display images and plots associated with A and GA
          'show_H', 0, ...    	  	  % display images and plots associated with G A and GA
          'show_PD', 0, ...    	  	  % display images and plots associated with PD
          'show_Weights', 0, ...    	  	  % display plots for weights
          'show_Scores', 0, ...    	  	  % display plots for Scores
          'show_Loadings', 0), ...   	  	  % display plots for Loadings
        'system_timers', 0, ...           	% holds the mean averages for operational time estimates
        'image_read_average', 0.07, ...	% average image read time in seconds
        'normalize_average', 35.01, ...	% average normalization rate ( rows per second )
        'save_average', 7.73, ...         	% average save rate ( rows per second )
        'this_timer', '', ...             	% generic process timer for adjusting system averages
        'raw_data', struct( ...
          'header', '' ...			% stores header for one of the raw data images
        ), ... 
        'mask', structure_define( 'mask_struct' ) ); % --- changed from new_image_struct() );  05-15-2014
    return
    
    case 'process_info'
      st = struct( ...
        'sys', '_nix', ...			% generic holder for system type ( '_pc', '_mac', '_nix' )
        'is64bit', 0, ...			% indicates if MATLAB uses 64 bit libraries
        'HDF5', '', ...			% 64 bit = ' -V7.3' - can utilize 2Gb+ file/matrix structures
        'hasCacheDrop', 0, ...		% flag to indicate ability to flush Linux kernel cache buffers
        'cache_buffer', ' /proc/sys/vm/drop_caches', ...	% name of cache buffer drop file
        'isRoot', 0, ...			% flag to indicate current user is logged in or su root
        'sudoUser', '', ...			% flag to indicate current user can sudo - allows to flush caches
        'sudo', structure_define( 'SUDOSTRUCT' ), ...		% structure containing sudo user name and group for file ownership changing is run as sudo
        'createZ', 1, ...			% flag to indicate creation of initial Z matrices from subject scans
        'imaged_to', 'S%d', ...		% printf filename format for saving scan images
        'save_mc', 1, ...			% flag for saving mean-centered data 
        'save_mc_as', 'Z%d_mc', ...		% printf filename format for saving mean-centered data
        'save_norm', 1, ...			% flag for saving normalized data 
        'save_norm_as', 'Z%d', ...		% printf filename format for saving normlized data
        'done_bar', struct( ...		% displayed progress done bar settings
          'length', 15, ...			% length of internal bar
          'space', ' ', ...			% character to use as unprocessed percentage
          'indicator', '=', ...		% character to use as processed percentage
          'border', struct( ...
            'left', '[', ...			% character to use at left border
            'right', ']') ...  		% character to use at right border
          ), ...
        'control_text', [] ...		% contains text content of controls on GUI
      );
      return

      
    case 'zheader'
      st = struct( ...
        'header_version', constant_define( 'DATA_MODEL' ), ... 	% header structure design version
        'cpca_version', structure_define( 'REVISION' ), ... 	% version number of application creating data
        'edit_version', '', ... 		% version number of application last editing data
        'cluster_data', 0, ... 		% flag Zheader as header for cluster sub processing
        'num_subjects', 0, ... 		% number of subjects
        'num_runs', 0, ... 			% number of runs per subject
        'active_runs', 0, ... 		% total number of active runs
        'num_Z_arrays', 1, ... 		% number of Z separations ( for MEG multiple frequencies processing) [2.93]
        'Z_array_names', {''}, ... 		% name of each of Z separation - initial segment is always blank for normal [2.93]
        'memory_limit', 0, ...		% user selected memory limit ( in GB )
        'total_scans', 0, ...			% total number of scans per .img files on disk
        'total_columns', 0, ...		% maximum number of columns by subject - these should match
        'partitions', structure_define( 'PARTITIONING' ), ... % Z data column partitioning information
        'original_partitions', structure_define( 'PARTITIONING' ), ... % Z data column partitioning information for original data
        'max_scans', 0, ...			% maximum number of scan images per subject
        'min_scans', 0, ...			% minimum number of scan images per subject
        'timeseries', struct( 'subject', [] ), ...	% row count per subject  2.,8 adds conditions [] per run
        'conditions', struct( ...		% [2.8] subjects must have the same conditions ( runs may use different )
          'Names', [], ...			  % all condition names ( each subject must encode all conditions )
          'subject', [], ...   		  % subject(n).Runs []  each encoded condition per subject run
          'encoded', [], ...   		  % logical flag for all defined conditions encoded per subject
          'allEncoded', 0, ...   		  % total number of encoded conditions 
          'nonEncoded', 0, ...   		  % total number of non encoded conditions 
          'sp', []), ...			  % start row of each condition by subject ( add bin number )
        'ts_vector', [], ...			% vector of time series per subject for linear regression
        'rfac', [0 0 0 0], ...		% vector for accumulated regression factors ( linear, quadratic, head and user )
        'tsum_with_trends', 0, ...		% singular sum of squares for normalized original data
        'tsum_linear_trends', 0, ...		% singular sum of squares for linear trends removed from Z
        'tsum_quadratic_trends', 0, ...	% singular sum of squares for quadratic trends removed from Z
        'tsum_user_trends', 0, ...		% singular sum of squares for user defined covariant trends removed from Z
        'tsum_hm_trends', 0, ...		% singular sum of squares for head movementt trends removed from Z
        'tsum_trends', 0, ...			% singular sum of squares for all trends removed from Z
        'tsum', 0, ...			    % singular sum of squares for Z with trends removed
        'rsum', [0, 0, 0, 0, 0], ...	% singular sum of squares for Z ( Gray, White, Ventricle, Brainstem, Cerebellum )
        'tsum_E', 0, ...			% singular sum of squares for Z - GC
        'tsum_HE', 0, ...			% singular sum of squares for Z - HB
        'tsum_clusters', 0, ...		% singular sum of squares for linear trends of clusters removed from Z
        'MeanCentered', 0, ...		% subject data has been mean centered
        'Normalized', 0, ...			% subject data has been normalized
        'older_Z', 0, ...			% user has selected an older Z file for applying models to
        'Z_File', legacy_define( 'ZD' ), ...			% info on variable in older file to use
        'Z_Directory', '', ...		% directory of saved subject data (for later different model application )
        'Z_Original', '', ...			% stores original Z directory for cluster sub processing
        'Description', {''}, ...		% user defined description of Z data, or processed portion
        'Model', structure_define( 'MODELMATRICES' ), ...		% G matrix ( Model ) Information
        'P', structure_define( 'MODELMATRICES' ), ...		% P matrix ( PD ) Information
        'D', structure_define( 'MODELMATRICES' ), ...		% D matrix ( PD ) Information
        'Contrast', structure_define( 'MODELMATRICES' ), ... 	% A matrix ( Contrast ) information
        'Limits', structure_define( 'MODELMATRICES' ), ... 		% H matrix ( Voxel Components ) Information
        'NumComponents_GA', 0, ...		% stores number of components to extract for GAZ
        'NumComponents_H', 0, ...		% stores number of components to extract for GAHZ
        'pct_threshold', 2, ...               % global percentile thresholds at: 1 = 1%  2 = 5 %   3 = 10%)			
        'pct_value', [1 5 10 20 30], ...      % global percentile thresholds display values			
        'ZZ', struct ( ...			% information on processed ZZ data during normalization
          'segments', 0, ...
          'ts_per_segment', 0, ...
          'padding_value', 0 ... 
        ), ...
        'summaries', struct ( ...		% contains the processed GA/H summaries
          'GZ', structure_define( 'SUMS' ), ...			% G' * Z Summaries
          'GAZ', structure_define( 'SUMS' ), ...			% GA' * Z Summaries
          'GAAZ', structure_define( 'SUMS' ), ...			% G' * (A'*A) * Z Summaries
          'GZH', structure_define( 'SUMS' ), ...			% G' * Z *H Summaries
          'GAZH', structure_define( 'SUMS' ), ...			% GA' * Z * H Summaries
          'GAAZH', structure_define( 'SUMS' ) ...			% G' * (A'*A) * Z * H Summaries
        ), ...
        'GAZ', [] );  			% information on G/A/Z matrices

    
    case 'zd'
      st = struct( ...
        'name', '', ...			% name of Z file
        'directory', '', ...			% directory Z file located in
        'variable', '', ...			% struct containing variable info
        'mean_centered', 0, ...		% flag set if data is mean centered
        'normalized', 0 );			% flag set if data is normalized
    return
    
    
  end
  

end

