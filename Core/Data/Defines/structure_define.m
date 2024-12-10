function st = structure_define( strucName )

  st = [];

  % --- if no parameter, return the empty structure
  if nargin == 0
    return;
  end;


  switch lower( strucName )

    % --- --------------------------------------
    % --- current application revision number
    % --- --------------------------------------
    case 'revision'
      st = struct ( ...                 % cpca revision major.minor.release.(edit)r
        'major',   constant_define( 'REVISION_MAJOR' ), ...
        'minor',   constant_define( 'REVISION_MINOR' ), ...
        'edit',    constant_define( 'REVISION_EDIT' ), ...
        'release', constant_define( 'REVISION_RELEASE' ) ...
      );	
      return;

    % --- --------------------------------------
    % --- flagged application revision numbers
    % --- --------------------------------------
    case 'lowest_revision'
      st = struct ( ...                 % cpca revision major.minor.release.(edit)r
        'major',   1.0, ...
        'minor',   0, ...
        'edit',    00, ...
        'release', '' ...
      );	
      return;
      
    case 'reapply_revision'
      st = struct ( ...                 % cpca revision major.minor.release.(edit)r
        'major',   1.0, ...
        'minor',   0, ...
        'edit',    00, ...
        'release', '' ...
      );	
      return;

    % --- --------------------------------------
    % --- initial settings for main window GUI
    % --- --------------------------------------
    case 'gui'
      st = struct( ...			
        'object', 0, ...                % --- Java object reference holder
        'size', [800, 500], ...			% --- initial size parameters
        'location', [200, 200], ...		% --- initial location parameters
        'title', '' ...                 % --- Window title
      );
      return;
    
    % --- --------------------------------------
    % --- settings for opening splash screen
    % --- --------------------------------------
    case 'splash'
      st = struct( ...                  
        'object', [], ...               % --- Java object reference holder
        'size', constant_define( 'SPLASH_IMAGE_SIZE' ), ...	
        'status', 0, ...                % --- Java object for status container updates
        'depth',  100, ...              % --- depth of status window
        'lastCall', 0, ...              % --- timer to maintain a minimum length of display on hide call
        'logofile', [ constant_define( 'SPLASH_IMAGE_PATH' ) constant_define( 'SPLASH_IMAGE_FILE' ) ] ...
      );
      return;

    % --- --------------------------------------
    % --- settings for stats window loading
    % --- --------------------------------------
    case 'stats_loader'
      st = struct( ...                  
        'object', [], ...               % --- Java object reference holder
        'label', [], ...                % --- Java object reference holder
        'size', constant_define( 'SDELAY_IMAGE_SIZE' ), ...	
        'status', 0, ...                % --- Java object for status container updates
        'depth',  50, ...               % --- depth of status window
        'action',  'show', ...			% --- set to 'hide' when done
        'lastCall', 0, ...              % --- timer to maintain a minimum length of display on hide call
        'text', 'Confirming valid data . . .', ...	% --- timer to maintain a minimum length of display on hide call
        'logofile', [ constant_define( 'SDELAY_IMAGE_PATH' ) constant_define( 'SDELAY_IMAGE_FILE' ) ] ...
      );
      return;

      
      
    % --- --------------------------------------
    % --- settings for stats window loading
    % --- --------------------------------------
    case 'message_window'
      st = struct( ...                  % --- application splash screen settings
        'object', [], ...               % --- Java object reference holder
        'label', [], ...                % --- Java object reference holder
        'size', [500, 100], ...	        % --- default initial window size
        'maxlen', 32, ...               % --- maximum character lenngth of message per line 
        'depth',  50, ...               % --- depth of status window
        'title', 'Generic Message', ...	% --- these last two are ignores as they are passed as parameters
        'message', 'as for how large a message goes here, well that is anyones guess, or so most would assume it appears to be . . .' ...
      );
      return;
      
    % --- --------------------------------------
    % --- Header structure for G
    % --- --------------------------------------
    case 'gheader'
      st = struct( ...                  
        'model_type',  constant_define( 'FIR_MODEL' ), ...
        'conditions', 0, ...                        % --- number of conditions
        'tb_based', 1, ...                          % --- flag to indicate G predicated on time bins ( 0 here allows 0 time bins)
        'bins', 0, ...                              % --- number of time bins
        'TR', 1, ...                                % --- Timing Rate
        'displacement', 1.5, ...		            % --- displacement from event (in seconds ) to seek HRF response
        'mean_tr', 0.0, ...                         % --- holder for mean of fractional TR of all timings
        'inScans', constant_define( 'TR_IN_SCANS' ), ...
        'path_to_segs', '', ...			            % --- path to the segmented ouptut
        'GZheader', structure_define( 'GZHEADER' ), ...
        'applied_to', '', ...			            % --- source of Z data G has been applied to
        'date_applied', '', ...			            % --- date G applied to Z data
        'source', '', ...                           % --- source of G data, either a G.mat or timing onsets file
        'prefix', 'G', ...                          % --- struct may be used for GA, H etc...
        'raw', 'Graw', ...                          % --- name of raw segment var
        'norm', 'Gnorm', ...			            % --- name of normalized segment var
        'condition_name', [], ...		            % --- condition names
        'Description', '', ...			            % --- Description of Model
        'Import_File', '', ...			            % --- File timing onsets were imported from
        'illformed', 0, ...                         % --- flag bad ranked G'*G  (rcond>eps+10%)
        'subjects', [], ...                         % --- list of subjects that show ill-formed G results
        'subject_encoded', [], ...		            % --- number of conditions encoded per subject
        'has_ROI', 0, ...	        	            % --- ROI masks defined as G
        'use_ROI', 0 ...	        	            % --- Use an ROI mask defined as G
      );
      return;

    % --- --------------------------------------
    % --- Header structure for G GZheader
    % --- --------------------------------------
    case 'gzheader'
      st = struct( ...                  
        'path_to_segs', '', ...                     % --- path to data
        'prefix', 'GZ', ...                         % --- 
        'columns', 0, ...                           % --- unused
        'runs', 0, ...                              % --- unused
        'rsum', [0 0 0 0 0], ...                    % --- [ 05-15-2014] Registered mask information
        'subjects', 0, ...                          % --- unused
        'sum_diagonal', 0 ...                       % --- sum of squares of data
      );
      return;

    % --- --------------------------------------
    % --- Header structure for G from ROI region info
    % --- --------------------------------------
    case 'groi'
      st = struct( ...                  
        'mask', struct(  ...
          'image', '', ...                          % --- mask image G derived from
          'desc',  '', ...                          % --- short description of ROI
          'id',    '', ...                          % --- unique ID to identify analysis results
          'path',  '', ...                          % --- path to file containg indexes from mask
          'file',  '', ...                          % --- name of file containing indexes
          'size',  [], ...                          % --- size of derived G
          'sum_diagonal', 0, ...                    % --- GC sum diagonal from analysis
          'tsum_ZTrim', 0 ...                       % --- revised Ztrimmed sum diagonal from analysis
        ), ...
        'Rindex', 0 ...                 			% index into mask structure for analysis
      );
      return;
      
    % --- --------------------------------------
    % --- Header structure for A
    % --- --------------------------------------
    case 'aheader'
      st = struct( ...                  
        'model', struct( ...
          'id', '', ...                             % --- char label for each contrast model
          'descr', '', ...                          % --- quick short description for clarity
          'contrasts', 0, ...                       % --- number of defined contrasts
          'bins', 0, ...                            % --- number of bins per contrast
          'contrast_name', [], ...                  % --- contrast names
          'path', '', ...                           % --- path to file(s) containing A variable
          'var', '', ...                            % --- name of variable within file
          'mat_x', 0, ...                           % --- depth of A matrix
          'mat_y', 0, ...                           % --- width of A matrix
          'path_to_G', '', ...                      % --- path to precalulated GA data 
          'path_to_GA', '', ...                     % --- path to applied segment output directory
          'path_to_GAA', '', ...                    % --- path to applied segment output directory
          'sd', [ 0 0 ] ...                         % --- sum_diagonal values [ GA GnotA]
        ), ...
        'Aindex', 1 ...
      );
      return;
      
      
      
    % --- --------------------------------------
    % --- Header structure for H
    % --- --------------------------------------
    case 'hheader'
      st = struct ( ...
        'model', struct( ...
          'id', '', ...                             % --- char label for each model
          'unique_H', 1, ...                        % --- toggle between unique and individual H
          'use_VR', 1, ...                          % --- use existing VR values as H
          'path', '', ...                           % --- path to file(s) containing H variable
          'file', '', ...                           % --- name of file containing H variable
          'var', '', ...                            % --- name of variable within file
          'size', [0 0], ...                        % --- size of H variable
          'path_to_segs', struct( 'ZH', '', 'EH', '', 'GMH', '' ), ...
          'partitions', [], ... 	% BH(Z)   BH(E)     GMH      GMH      GMH   
          'sum_diagonal', struct ( 'ZH', 0, 'EH', 0, 'GMH', 0, 'BH', 0, 'GC', 0 ), ...
          'options', [], ...
          'isRegionalH', 0 ...                      % --- defined by talairach region per column
        ), ...
        'HH', [], ...
        'hh', [], ...
        'Hindex', 1 ...
     );
     return
  
     
    % --- --------------------------------------
    % --- Subject group structure
    % --- --------------------------------------
    case 'subject_group'
      st = struct ( ...
        'name', '', ...                 % --- label identifier of group
        'subjectcount', 0, ...
        'subjectdepth', 0, ...
        'subjectlist', '', ...
        'tsum', 0, ...
        'tsum_removed', 0 ...
     );
     return

    % --- --------------------------------------
    % --- basic data for command window textual progress bar usage
    % --- --------------------------------------
    case 'prog_bar'
      st = struct( ...
        'length', 15, ...               % length of internal bar
        'space', ' ', ...               % character to use as unprocessed percentage
        'indicator', '=', ...           % character to use as processed percentage
        'border', struct( ...
          'left', '[', ...              % character to use at left border
          'right', ']') ...             % character to use at right border
      );

  
    % --- --------------------------------------
    % --- Header structure for rotation definitions
    % --- --------------------------------------
    case 'rotations'
      st = struct( ...
        'method', '', ...
        'description', '', ...
        'parameters', struct ( ...
          'power', 0, ...
          'iterations', 0,... 
          'oblique', 0, ...
          'gamma', 0, ...
          'orthogonal_output', 0, ...
          'apply_to_ur', 0, ...	
          'alternate_ur', 0, ...
          'normalize', 0, ...
          'HRF', 0, ...
          'use_T', 0, ...,			
          'load_state', 0, ...,			
          'special', [] ...
        ), ...
        'defaults', struct ( ...
          'power', 0, ...
          'iterations', 0,... 
          'oblique', 0, ...
          'gamma', 0, ...
          'orthogonal_output', 0, ...
          'subject_stats', 0, ...
          'apply_to_ur', 0, ...		
          'alternate_ur', 0, ...
          'normalize', 0, ...
          'calc_variance', 1, ...
          'reltol', 0, ...
          'text', '', ...,			
          'T_mat', [], ...		
          'T_orient', [], ...
          'hrf_file', '', ...
          'hrf_mat', ''...
        ) ...
      );
      return

    % --- --------------------------------------
    % --- User Settings Options - aka preferences
    % --- --------------------------------------
    case 'optional_settings'
      st = struct( ...
        'db_version',                   constant_define( 'OPT_DB_VER' ), ...              % --- preferences db version number
        'general', struct( ...
            'max_partition_mem',        500, ...                % --- maximum amount of memory per partition
            'cache_percent',            20, ...                 % --- what percent to clear user cache at ( linx only )
            'default_ROI_vox',          10, ...                 % --- default number of voxels for final ROI G selection
            'large_variable_creation',  [0 0; 0 0], ...         % --- flag to indicate GC/E  BH/E creation ( default is not to create )
            'duplicate_images',         0, ...                  % --- legacy no longer used - create duplicate images 
            'calculate_altPR',          0, ...                  % --- legacy no longer used - crate a second PR using different calculation
            'fisherXform',              0, ...                  % --- produce fisher transformed images in addition to normal ones
            'MissingSourceTiming',      0, ...                  % --- mask creation - display when source timing files missing 
            'whole_brain',              1, ...                  % --- whole brain analysis
            'gray_matter',              0, ...                  % --- gray matter only
            'white_matter',             0), ...                 % --- white matter only
        'threshold', struct( ...
            'active',                  [0 1  1  1  0], ...      % --- vector of active threshold percentages [ 1% 5% 10% 20% 30% ]
            'values',                  [1 5 10 20 30], ...      % --- threshold amount values
            'default_only',   0, ...                            % --- calculate only th default threshold
            'default',        3), ...                           % --- threshold used as default
        'precision', struct( ...
		    'log', '%.2f', ...                                  % --- format specifiers for decimal precision
			'ccf', '%.5f', ...                                  % --- stats window correlation coefficient display
			'stats', '%.2f', ...                                % --- stats window normal data display
			'default', '%.4f'), ... 
        'cluster', struct( ...
            'minimum_mm3',       500, ...                       % --- minimum number of voxel cluster must have before being written
	        'create_masks',      1, ...                         % --- flag to indicate create clkustrer masks
	        'calculate_mean',    0, ...                         % --- flag to write cluster mean/median data files ( either one writes both )       
	        'calculate_median',  0 ) ...                        % ---    writing these files will add up to 10 minutes oer subject
      );
      return;
      
    % --- --------------------------------------
    % --- basic structure for GMH Processing flags
    % --- --------------------------------------
    case 'gmh_options'
      st = struct( ...
       'GMH', struct( 'apply', 0, 'regress', 0, 'extract', 0, 'components', [], 'rotate', 0, 'rotation', [], 'write', 0 ), ...
       'BH', struct( 'apply', 0, 'regress', 0, 'extract', 0, 'components', [], 'rotate', 0, 'rotation', [], 'write', 0 ), ...
       'GC', struct( 'apply', 0, 'regress', 0, 'extract', 0, 'components', [], 'rotate', 0, 'rotation', [], 'write', 0 ), ...
       'E', struct( 'apply', 0, 'write', 0 ), ...
       'vars', struct( 'ZH', 0, 'Qg', 0, 'Qh', 0), ...
       'exists', struct( 'ZH', 0, 'Qg', 0, 'Qh', 0, 'GMH', 0, 'BH', 0, 'GC', 0, 'E', 0 ), ...
       'ow_flag', 0, ...
       'overwrite', 0 ...
     );
     return

    case 'model_creation'
      st = struct ( ...
        'model_type', 0, ...			% the type of model to create 0 = FIR, 1 = HRF  - only support FIR for now
        'conditions', 0, ...			% number of conditions
        'bins', 0, ...                  % number of timing bins
        'TR', 0, ...                    % TR in seconds - number of seconds per 3D volume scan
        'inScans', 0, ...               % if timing vectors are in scans set to 1, otherwise leave at 0
        'condition_name', {''});		% note : convert seconds to scans = onset / TR, otherwise onset * TR
    return         

    case 'sudostruct'
      st = struct( ...
        'user', '', ...
        'group', '', ...
        'confirmed', 0 );      
    return

    case 'env_struct'
      st = struct( ...
        'user',     [], ...
        'username', [], ...
        'sudouser', [], ...
        'isSudo', 0, ...
        'isRoot', 0 );
    return
    
    
    case 'sums'
      st = struct( ...
        'SS', struct ( ...
           'Explained', 0, ...
           'pct', 0 ...
        ), ...
        'ND', struct ( ...
           'Explained', 0, ...
           'pct', 0, ...
           'pct_tsum', 0 ...
        ), ...
        'LD', struct ( ...
          'SS', struct ( ...
             'Explained', 0, ...
             'pct', 0 ...
          ), ...
          'ND', struct ( ...
             'Explained', 0, ...
             'pct', 0, ...
             'pct_tsum', 0 ...
          ) ...
        ) ...
      );
      return
      

    case 'partitioning'                 % structure to hold column partition data
      st = struct( ...
        'count', 0, ...                 % --- number of defined columns               
        'width', 0, ...                 % --- width in voxels of columns
        'last', 0, ...                  % --- width in voxels of last column
        'mem', 0, ...                   % --- memory consumption of partition
        'columns', [], ...              % --- vector of each column width for iteration
        'partitioned', 0, ...           % --- flag indicating data has been partitioned
        'max_sz', 0 );                  % --- unused
    return

    
    case 'modelmatrices'                % --- structure for Gheader, Aheader etc usage 
      st = struct( ...
        'file_exists', 0, ...           % --- flag indicating specified file exists
        'path', '', ...                 % --- full path to hader file
        'mat_exists', 0, ...            % --- flag indicating required specified variable name ( Gheader etc... ) exists
        'hdr_exists', 0, ...            % --- flag indicating Model header exists
        'mat', '', ...                  % --- name of variable in file used as header
        'mat_x', 0, ...                 % --- extents of defined model  ( time series )
        'mat_y', 0 );                   % --- extents of defined model  ( bins )
    return
    
    case 'image_struct'                 % --- structure to hold image data
      st = struct( ...
        'header', [], ...               % --- image header ( see NIFTI specifiactions )
        'image', [], ...                % --- full image data from iamge file            
        'vol', [], ...                  % --- image volume data ( per SPM 8 )
        'niiSingle', 0, ...             % --- flag indicating a single nii file
        'file', '', ...                 % --- name of file image data retrieved from
        'ind', [], ...                  % --- indexes of non zero image data locations
        'x', 0, ...                     % --- number of voxels in image
        'y', 0, ...                     % --- number of images retrieved
        'tal_index', [], ...            % --- unused - phased out
        'MNI', [] );                    % --- MNI coordinate for each voxel
    return
    
    
    case 'mask_struct'                 % --- structure to hold image data
      st = struct( ...
        'header', [], ...               % --- image header ( see NIFTI specifiactions )
        'image', [], ...                % --- full image data from iamge file            
        'vol', [], ...                  % --- image volume data ( per SPM 8 )
        'niiSingle', 0, ...             % --- flag indicating a single nii file
        'file', '', ...                 % --- name of file image data retrieved from
        'ind', [], ...                  % --- indexes of non zero image data locations
        'x', 0, ...                     % --- number of voxels in image
        'y', 0, ...                     % --- number of images retrieved
        'isRegistered', 0, ...          % --- flag mask is region encoded
        'tal_index', [], ...            % --- unused - phased out
        'MNI', [] );                    % --- MNI coordinate for each voxel
    return
    
  end;

  
