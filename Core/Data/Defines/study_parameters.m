function st = study_parameters()

  st = [];

  
  st.Revision = struct ( ...
        'header_version', constant_define( 'DATA_MODEL' ), ...    % header structure design version 
        'cpca_version',   structure_define( 'REVISION' ), ...     % version number of application creating data
        'edit_version',   '' ...                                  % version number of application last editing data
  );


  st.General = struct ( ...
        'location',      '', ...                                  % path to main folder of study 
        'num_subjects',   0, ...                                  % number of subjects
        'num_runs',       0, ... 			                        % number of runs per subject
        'min_runs',       0, ... 			                        % number of runs per subject
        'active_runs',    0, ... 		                           % total number of active runs
        'num_Z_arrays',   1, ... 		                           % number of Z separations ( for multiple frequencies processing) 
        'total_scans',    0, ...			                           % total number of scans per .img files on disk
        'total_columns',  0, ...		                              % maximum number of columns by subject - these should match
        'max_scans',      0, ...                                  % maximum number of subject scan images subject
        'min_scans',      0, ...                                  % minimum number of subject scan images subject
        'multi_frequeny', 0, ...                                  % flag indicaring multiple frequency data ranges
        'frequencies',    1, ...                                  % number of defined frequency ranges ( min 1 if none defined )
        'frequency_labels', '', ...                               % labelling of frequency ranges
        'timeseries', struct( 'subject', [], 'vector', [] ), ...  % row count per subject  2.,8 adds conditions [] per run
        'partitions', structure_define( 'PARTITIONING' ) ...         % Z data column partitioning information
  );
     
  st.Models = struct ( ...     
        'G',          structure_define( 'MODELMATRICES' ), ...    % G matrix ( Model ) Information
        'A',          structure_define( 'MODELMATRICES' ), ... 	% A matrix ( Contrast ) information
        'H',          structure_define( 'MODELMATRICES' ) ... 		% H matrix ( Voxel Components ) Information
  );


  st.Stats = struct ( ...
        'tsums',  struct ( ...
          'rfac',                  [0 0 0 0], ...                   % vector for accumulated regression factors ( linear, quadratic, head and user )
          'with_trends',      0, ...                           % sum of squares - normalized original data
          'linear_trends',    0, ...                           % sum of squares - linear trends removed from Z
          'quadratic_trends', 0, ...                           % sum of squares - quadratic trends removed from Z
          'user_trends',      0, ...                           % sum of squares - user defined covariant trends removed from Z
          'hm_trends',        0, ...                           % sum of squares - head movement trends removed from Z
          'trends',           0, ...                           % sum of squares - all trends removed from Z
          'tsum',                  0 ...                            % sum of squares - Z with trends removed
        ) ...
  );


  st.Groups = struct ( ...
        'num_groups', 0, ...                                      % number of defined subject groups
        'group_list', [] ...                                      % list of each defined group parameters
   );


  st.Source = struct ( ...
        'base_dir',        '', ...                                % root directory of scan data
        'list_spec',       '', ...                                % file specifaction wildcard for scan selection
        'subj_dir',        [], ...
        'frequency_dirs',  [], ...                                % this determines path to frequency scans     
        'subject_dirs',    [], ...                                % for path to scans construction             
        'run_dirs',        [], ...                                % for path to scans construction when runs    
        'scandir_format',  '', ...                                % format template for scan path construction  
        'file_list',       '', ...                                % full path of text file list to be parsed
        'subject_id',      [], ...                                % list of subject ID's
        'duplicate_id',     0, ...                                % flag for subject IDs containing duplications  
        'rp_count',         0, ...                                % number of rp_ files discovered
        'tt_count',         0 ...                                 % number of trial_timings files discovered
   );


  st.Mask = new_image_struct() ;

  
  st.Conditions = struct ( ...
        'name',  [], ...
        'subject',  [], ...
        'encoded',  [], ...
        'allEncoded',  0, ...
        'nonEncoded',  0, ...
        'sp',  [] ...
   );


  st.Timing = struct ( ...
        'image_read_average',  0.0700, ...
        'normalize_average',  35.0100, ...
        'save_average',        7.7300,  ...
        'mean_centered',       0,  ...
        'normalized',          0  ...
   );
        

