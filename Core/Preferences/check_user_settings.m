function check_user_settings()
% --- 
% --- load current user preferences data and modify to 
% --- current data design [1.1]
% --- 
% --- creates a default user preferences file if none present
% --- 

  user_options = [];
  % --- load existing user_settings db
  optmat = [ constant_define( 'CONFIG_PATH' ) constant_define( 'CONFIG_FILE' ) ];
  if exist( optmat, 'file' )
    load( optmat );
  else
    % --- set default options ( see structure_define for details )
    user_options = structure_define( 'optional_settings' );
    save( optmat, 'user_options' );
    return;
  end
  
  if isfield( user_options, 'db_version' )
      
    current_db_ver = constant_define( 'OPT_DB_VER' );
    if strcmp( current_db_ver, user_options.db_version )
      return    % --- user options db is current version

    % --- % update user options to current version
    else
      
     user_old = user_options;
     user_options = structure_define( 'optional_settings' );
     
     if ~isfield( user_old, 'default_ROI_vox' )
       user_options.general.default_ROI_vox  = fieldContent( user_old, 'default_ROI_vox', 10 );  
     else
       user_options.general.default_ROI_vox  = fieldContent( user_old.general, 'default_ROI_vox', 10 );  
     end                                                                                                        % --- +[1.11]
     
%     if ~isfield( user_options, 'gray_white_split' ),  user_options.general.gray_white_split  = 0;  end        % --- +[1.12] -[1.15]
%     if ~isfield( user_options, 'remove_ventricles' ),  user_options.general.remove_ventricles  = 1;  end      % --- +[1.13] -[1.14]

     user_options.general.max_partition_mem       =  fieldContent( user_old.general, 'max_partition_mem', 0 );  
     user_options.general.cache_percent           =  fieldContent( user_old.general, 'cache_percent', 0 );   
     user_options.general.duplicate_images        =  fieldContent( user_old.general, 'duplicate_images', 0 );  
     user_options.general.large_variable_creation =  fieldContent( user_old.general, 'large_variable_creation', [ 0 0; 0 0 ] );
     user_options.general.calculate_altPR         =  fieldContent( user_old.general, 'calculate_altPR', 0 );     
     user_options.general.fisherXform             =  fieldContent( user_old.general, 'fisherXform', 0 );       
     user_options.general.MissingSourceTiming     =  fieldContent( user_old.general, 'MissingSourceTiming', 0 );    
     user_options.general.whole_brain             =  fieldContent( user_old.general, 'whole_brain', 1 );        % --- +[1.15]
     user_options.general.gray_matter             =  fieldContent( user_old.general, 'gray_matter', 0 );        % --- +[1.15]
     user_options.general.white_matter            =  fieldContent( user_old.general, 'white_matter', 0 );       % --- +[1.15]
 
     user_options.threshold.active                =  fieldContent( user_old.threshold, 'active',[0 1 1 1 0] );
     user_options.threshold.values                =  fieldContent( user_old.threshold, 'values', [1 5 10 20 30] );  
     user_options.threshold.default_only          =  fieldContent( user_old.threshold, 'default_only', 0 );  
     user_options.threshold.default               =  fieldContent( user_old.threshold, 'default', 3 );            

     user_options.precision.log                   =  fieldContent( user_old.precision, 'log','%.2f' );
     user_options.precision.ccf                   =  fieldContent( user_old.precision, 'ccf', '%.5f');
     user_options.precision.stats                 =  fieldContent( user_old.precision, 'stats', '%.2f' );
     user_options.precision.default               =  fieldContent( user_old.precision, 'default', '%.4f' );
     
     user_options.cluster.minimum_mm3             =  fieldContent( user_old.cluster, 'minimum_mm3', 500 );
     user_options.cluster.create_masks            =  fieldContent( user_old.cluster, 'create_masks', 1 );
     user_options.cluster.calculate_mean          =  fieldContent( user_old.cluster, 'calculate_mean', 0 );
     user_options.cluster.calculate_median        =  fieldContent( user_old.cluster, 'calculate_median', 0' );

     save( optmat, 'user_options' );
     
    end

  % --- update original version of db
  else
    db = user_options;
    user_options = structure_define( 'optional_settings' );
    
    if isfield( db, 'max_partition_mem' ),  user_options.general.max_partition_mem  = db.max_partition_mem;  end
    if isfield( db, 'cache_percent' ),  user_options.general.cache_percent  = db.cache_percent;  end
    if isfield( db, 'duplicate_images' ),  user_options.general.duplicate_images  = db.duplicate_images;  end
    if isfield( db, 'calculate_altPR' ),  user_options.general.calculate_altPR  = db.calculate_altPR;  end
    if isfield( db, 'fisherXform' ),  user_options.general.fisherXform  = db.fisherXform;  end
    if isfield( db, 'MissingSourceTiming' ),  user_options.general.MissingSourceTiming  = db.MissingSourceTiming;  end
    if isfield( db, 'large_variable_creation' ),  user_options.general.large_variable_creation  = db.large_variable_creation;  end

    if isfield( db, 'active_thresholds' ),  user_options.threshold.active  = db.active_thresholds;  end
    if isfield( db, 'threshold_values' ),  user_options.threshold.values  = db.threshold_values;  end
    if isfield( db, 'threshold_default' ),  user_options.threshold.default  = db.threshold_default;  end
    if isfield( db, 'threshold_default_only' ),  user_options.threshold.default_only  = db.threshold_default_only;  end

    if isfield( db, 'stats_decimals' ),  user_options.precision.log  = db.stats_decimals;
                                        user_options.precision.ccf  = db.stats_decimals;
                                        user_options.precision.stats  = db.stats_decimals;
                                        user_options.precision.default  = db.gen_decimals;
    end
    
    if isfield( db, 'cluster_minimum_mm3' ),  user_options.cluster.minimum_mm3  = db.cluster_minimum_mm3;  end
    save( optmat, 'user_options' );
    
  end
  
end

