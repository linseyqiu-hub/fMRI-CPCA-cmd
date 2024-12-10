function const = constant_define( constant, variable, default )
% data structure format changes
% +-------------------------------------------------------------
% | model       | rev  | Date   | Notes
% +-------------+------+--------+-------------------------------
% | OPT_DB_VER  | 1.10 |        | Initial implementation
% | OPT_DB_VER  | 1.11 | Apr 25 |   + general.default_ROI_vox
% | OPT_DB_VER  | 1.12 | May 23 |   + general.WG_split
% | OPT_DB_VER  | 1.13 | May 28 |   + no ventricle switch
% | OPT_DB_VER  | 1.14 | May 29 |   - no ventricle switch
% | OPT_DB_VER  | 1.15 | Jun 05 |   + whole/gray/white selectors
% +-------------+------+--------+-------------------------------

  const = [];
  
  if nargin < 2,  variable = [];  end
  if nargin < 3,  default  = [];  end
  
  % --- if no parameter, return the empty structure
  if nargin == 0,     return;     end;


  switch upper( constant )
    % --- User Setting dada model version
    % --- ------------------------------------
    case 'OPT_DB_VER',          const = '1.15';  return;

    % --- current application revision number
    % --- ------------------------------------
    case 'REVISION_MAJOR',      const = 1.2;	return;
    case 'REVISION_MINOR',      const = 2;	return;	
    case 'REVISION_EDIT',       const = 23;	return;
    case 'REVISION_RELEASE',    const = '-dev';	return;
    case 'REVISION_DATE',       const = 'May 1, 2024';	return;


    case 'REVISION',            const = structure_define('REVISION');  return;
        
    case 'VERSION_NUMBER',  ...
      const = [ ...
        dec2hex( constant_define( 'REVISION_MAJOR' ) *10, 2) ... 
        dec2hex( constant_define( 'REVISION_MINOR' ), 2)     ...
        dec2hex( constant_define( 'REVISION_EDIT' ), 2)      ...
      ];
      return;

    case 'REVISION_NUMBER',  ...
      const = [ ...
        num2str( constant_define( 'REVISION_MAJOR' ), '%.1f' ) '.'   ...
        num2str( constant_define( 'REVISION_MINOR' ), '%d' )         ...
        num2str( constant_define( 'REVISION_EDIT' ), '(%02d)' )      ...
                 constant_define( 'REVISION_RELEASE' )         ...
      ];
%                 constant_define( 'REVISION_DATE' )                  ...
      return;

      
      
    % --- flagged revision numbers
    % --- ------------------------------------

    case 'LOWEST_REVISION',            const = structure_define('LOWEST_REVISION');  return;
    case 'REAPPLY_REVISION',           const = structure_define('REAPPLY_REVISION');  return;

    case 'DATA_MODEL',                 const = '3.41';                                return;

    % --- values for mask type identifiers
    % --- ------------------------------------
    case 'MASK_GRAY_MATTER',                const = 1;                                return;
    case 'MASK_WHITE_MATTER',               const = 2;                                return;
    case 'MASK_VENTRICLES',                 const = 3;                                return;
    case 'MASK_BRAIN_STEM',                 const = 4;                                return;
    case 'MASK_CEREBELLUM',                 const = 5;                                return;
    case 'MASK_REGISTRATIONS',              const = 5;                                return;
        
    % --- internal Java handling
    % --- ------------------------------------
    case 'JAVA_PATH',           const = [cpca_path() 'Core' filesep 'Java' filesep ];	return;
    case 'INSTALLED_JAR',       const = {'cpca_progress.jar'} ;	return;
                                   % --- {'TalairachRegions.jar'} - removed Feb, 2014
    case 'WIN_MEM_TOOL',        const = [cpca_path() 'Core' filesep 'System' filesep 'memchk' filesep ];	return;
    
    % --- application logo and splash screens                                         
    % --- ------------------------------------
    case 'SPLASH_IMAGE_SIZE',   const = [592, 211];	return;
    case 'SPLASH_IMAGE_FILE',   const = 'cnos.png';	return;
    case 'SPLASH_IMAGE_PATH',   const = [cpca_path() 'GUI' filesep 'Splash_Screens' filesep 'Images' filesep ];	return;
        
    case 'SDELAY_IMAGE_SIZE',   const = [267, 100];	return;
    case 'SDELAY_IMAGE_FILE',   const = 'cnos_th.png';	return;
    case 'SDELAY_IMAGE_PATH',   const = [cpca_path() 'GUI' filesep 'Splash_Screens' filesep 'Images' filesep ];	return;
    case 'SDELAY_SET_TEXT',     const = 'Checking output directories . . .';	return;
        
    % --- mask constants
    % --- ------------------------------------
    case 'MNI_1MM_MASK_FILE',   const = [cpca_path() 'GUI' filesep 'Mask_Creation' filesep 'HO_MNI_1mm.mat' ];	return;
    case 'MNI_1MM_MASK_REV',   const = [cpca_path() 'GUI' filesep 'Mask_Creation' filesep 'HO_MNI_1mm_rev2.mat' ];	return;
    case 'MASK_REDUCTION',      const = 5;	return;

    % --- Model constants
    % --- ------------------------------------
    case 'FIR_MODEL',           const = 0;	return;
    case 'HRF_MODEL',           const = 1;	return;
    case 'TR_IN_SCANS',     	const = 1;	return;
    case 'TR_IN_SECONDS',     	const = 0;	return;

    case 'G_TEMPLATE_NAME',    	const = 'timing_onsets_template.txt';	return;
    case 'G_IMPORT_NAME',    	const = 'timing_onsets_imported.txt';	return;
 
    % --- General constants
    % --- ------------------------------------
    case 'EIG_COUNT',     		const = 15;	return;		% --- parameter for perform_svd when array too large to use internal
    case 'PARTITION_MAX',     	
        const = user_option('max_partition_mem');  
        if isempty( const )
            const = 500;
        end
        return;

    case 'SOURCE_TIMING_SPEC',  const = 'trial_onsets*.txt';	return;		% --- filespec to seek for trial timings in source data
    case 'RB_PARAMETER_SPEC',   const = 'rp_*.txt';		return;		% --- filespec to seek SPM rigid boy parameter files in source data
    case 'GMH_OPTIONS',         const = structure_define(constant);	return;
 
    case 'CONFIG_PATH',  		const = [cpca_config_directory() filesep];	return;
    case 'CONFIG_FILE',  		const = 'user_settings.mat';	return;
    case 'RULES_PATH',  		const = [cpca_path() 'Core' filesep 'Rules' filesep];	return;
    case 'TOOLS_PATH',  		const = [cpca_path() 'Core' filesep 'Tools' filesep];	return;

    case 'NON_ENCODED_COND_FLAG',  		const = -99999.99;	return;
    case 'SIZE_QWORD',          const = 10;  return;
    case 'SIZE_MB',             const = 1024000;  return;
    case 'SIZE_KB',             const = 1024;  return;

    case 'INPUT_DLG_SIZE',      const = [5 80];  return;  % the row/column count for default description entries
        
    % --- Mask Registration to Harvard Oxford Atlas
    % --- ------------------------------------
    case 'REGISTRATION_TAG', 
        
      regTags = [ {''}, {'G'}, {'W'} ];
      x = variable;
      if ~isnumeric( x ),  x = 0;  end
      if x > 2,              x = 0;  end
      const = char( regTags(x+1));  
      return
 
    case 'REGISTRATION_SUMMARY_TAG', 
        
      regTags = [ {''}, {' Gm'}, {' Wm'} ];
      x = variable;
      if ~isnumeric( x ),  x = 0;  end
      if x > 2,              x = 0;  end
      const = char( regTags(x+1));  
      return

    case 'REGISTRATION_TYPE', 
        
      regTags = [ {''}, {' Gray'}, {' White'} ];
      x = variable;
      if ~isnumeric( x ),  x = 0;  end
      if x > 2,              x = 0;  end
      const = char( regTags(x+1));  
      return

    case 'REGISTRATION_FULL', 
        
      regTags = [ {''}, {' Gray Matter'}, {' White Matter'} ];
      x = variable;
      if ~isnumeric( x ),  x = 0;  end
      if x > 2,              x = 0;  end
      const = char( regTags(x+1));  
      return
      
    % --- Preferences settings
    % --- ------------------------------------
    case 'USER_SETTING',        const = constant_define( 'PREFERENCES', variable, default );  return;
    case 'PREFERENCES',         
      if strcmpi( variable, 'LOAD' )
        optmat = [ constant_define( 'CONFIG_PATH' ) constant_define( 'CONFIG_FILE' ) ];
        load( optmat );
        if exist( 'user_options', 'var' )
          const = user_options;
        end
      else
        const = user_option( variable );
        if isempty( const )
          const = default;
        end
      end

      return
      
    case 'STATE', 
      if isempty( variable )
        const = 'off';
        return
      end;
      
      switch variable
          case 0,           const = 'off';  return;  
          case 1,           const = 'on';  return;
      end
      const = 'off';
      return

    % --- Predefined Color definitions
    % --- ------------------------------------
      
    case 'COLOR_ORANGE',    const = [0.976 0.925 0.722];  return;
    case 'COLOR_GREEN',     const = [0.643 0.812 0.624];  return;
    case 'COLOR_BLUE',      const = [0.8   0.8   1.0  ];  return;
    case 'COLOR_GREY',      const = [0.8   0.8   0.8  ];  return;
    case 'COLOR_YELLOW',    const = [0.8   0.8   0.0  ];  return;
    case 'COLOR_RED',       const = [0.84  0.16  0.0  ];  return;
    case 'COLOR_ERR',       const = [1.0   0.8   0.8  ];  return;
    case 'COLOR_WARN',      const = [1.0   0.8   0.8  ];  return;
    case 'COLOR_INACTIVE',  const = [0.502 0.502 0.502];  return;
    case 'COLOR_ACTIVE',    const = [0.0   0.0   0.0  ];  return;

    % --- output file system retrieval
    % --- ------------------------------------
    case 'OUTPUT_FS',  % --- file system paths    
        const = [];
        study_path = study_filesys_arch();
        if isfield( study_path.path, variable )
          pth = ['const = study_path.path.' variable '.' default ];
          eval( [pth ';'] );
        end
    return;

    case 'OUTPUT_FT',    % --- file types   
        const = [];
        study_path = study_filesys_arch();
        if isfield( study_path.filetype, variable )
          pth = ['const = study_path.filetype.' variable ];
          eval( [pth ';'] );
        end
    return;
    
    
    % --- randomly select one of 3 Lorem text options
    % --- ------------------------------------
    case 'LOREM' 
       n = max(uint16(rand()*2)+ 1, 1 );
       lorem_text = [ ...
       {'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'} ...
       {'Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?'} ...
       {'At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident, similique sunt in culpa qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio cumque nihil impedit quo minus id quod maxime placeat facere possimus, omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet ut et voluptates repudiandae sint et molestiae non recusandae. Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat.'}];
       const = char(lorem_text( n ));
       return
   
       
  end;

  
