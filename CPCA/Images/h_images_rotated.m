function h_images_rotated( funcs, rotation_settings, nd, log_fid, pop )
%  create the bold data images of G components 

global Zheader scan_information 
% --- Primary Iterations
% --- nd * max(scan_information.frequencies, 1)

  if ( nargin < 2 ) 
    nd = scan_information.processing.H_model.process.components(1);
  end;
  if ( nargin < 3 )  log_fid = 0;  end;
  if ( nargin < 4 )  pop = [];  end;
  if ~strcmp( class(pop), 'cpca_progress' )
    pop = []; 
  end

%  showPR = 1;
%  if strcmp( rotation_settings.htype, 'GC' )
%    showPR = 0;
%  end;

  noParms = struct( 'model', rotation_settings.model, 'mode', rotation_settings.htype );
  mniParms = struct( 'model', 'H', 'mode', rotation_settings.htype, 'var', 'MNI', 'component', 0, 'text', '' );

  dcomponent_directory = fs_path( 'rotated', 'output', nd, 0, rotation_settings );
  component_directory = [pwd filesep dcomponent_directory];

  txt_file = fs_filename( 'txt', rotation_settings.htype, rotation_settings.method, rotation_settings.defaults );
  text_file = [component_directory txt_file];

  MNI = struct( 'component', [] );

  component_loadings = [];

  theseParms = rotation_settings.defaults;
  theseParms.var = 'MNI';
  MNI_output = fs_filename( 'txt', rotation_settings.htype, rotation_settings.method, theseParms );
  MNI_display = [dcomponent_directory MNI_output];
  MNI_output = [component_directory MNI_output];

  stats = struct ( ...
    'loadings', 0, ...
    'min_value', 0, ...
    'max_value', 0 );

  Txt = sprintf( 'Creating Images', nd );

  [has_dir image_directory] = fs_create_path( 'rotated', 'images', nd, 0, rotation_settings );

  if ( has_dir )

    if ~isempty(pop)
      pop.setMessage( 'Creating Images' );
    end;

    load( Zheader.Limits.path );
    
    sumDiag = 0;
%    eval( ['sumDiag = Hheader.model(Hheader.Hindex).sum_diagonal.' rotation_settings.htype ';'] );
    if isfield( Hheader.model(Hheader.Hindex).sum_diagonal, rotation_settings.htype )
      eval( ['sumDiag = Hheader.model(Hheader.Hindex).sum_diagonal.' rotation_settings.htype ';' ] );  
    end;
    switch rotation_settings.htype
        case 'GMH'
          sumDiag = Hheader.model(Hheader.Hindex).sum_diagonal.GMH;
        case 'GnotH'
          sumDiag = Hheader.model(Hheader.Hindex).sum_diagonal.GC;
        case 'HnotG'
          sumDiag = Hheader.model(Hheader.Hindex).sum_diagonal.BH;
    end

    in_file = fs_filename( 'mat', rotation_settings.htype, rotation_settings.method, rotation_settings.defaults );
    load( [component_directory in_file] , 'VR', 'PR*', 'ep', 'cvariance*', 'betas_c_pos', 'betas_c_neg' );
    
    load_file = fs_filename( 'loadings', rotation_settings.htype, rotation_settings.method, rotation_settings.defaults );
    initialize_mat_file( [image_directory load_file] );
  
    print_and_log( log_fid, '\n---------------------------------------------------------\nCreating rotated Images:\n');

    if ( ~isempty( funcs.memory_stats ) ) funcs.memory_stats(); end;

    for FrequencyNo = 1:max(scan_information.frequencies, 1)
      start_col = (FrequencyNo - 1) * Zheader.total_columns + 1;
      end_col = start_col + Zheader.total_columns - 1;
      ftag = frequency_tag(FrequencyNo);

      thisVR = VR(start_col:end_col,:);

      for component_no = 1:nd

        loadings = [];
        Sts = ['Component ' num2str(component_no) ' of ' num2str(nd)];
        if ~isempty(pop)
          pop.setComment( Sts );
        end;

        rotation_settings.defaults.component = component_no;

        % ----------------------------------------
        % --- we use the mask as the template for saving the component images ---
        % ----------------------------------------

        component_image = scan_information.mask; % --= 
        TempComp = thisVR(:,component_no);

        % -----------------------------------------------
        % compose file names for images
        % -----------------------------------------------
        filename = fs_filename( 'img', rotation_settings.htype, [rotation_settings.method ftag], rotation_settings.defaults );
        if scan_information.mask.niiSingle   filename = strrep( filename, '.img', '.nii' );  end;

        fprintf( '---------------------------------------------------------\n   image: %s\n', filename );
        fprintf( 'location: %s\n\n', image_directory );

        if ~isempty(pop)
          pop.setComment( [Sts ' Calculating Loadings'] );
          pop.setIterations( size( ep(1).percentiles, 1) * num_global_thresholds(), pop.SECONDARY ) ;
        end;

        [loadings.pos loadings.neg] = calculate_loadings( TempComp );

        loadings.pos.threshold = [];
        loadings.neg.threshold = [];

        for ii = 1:num_global_thresholds()
          p = struct ( 'loadings', 0, 'min', 0, 'max', 0, 'mean', 0 );
          n = struct ( 'loadings', 0, 'min', 0, 'max', 0, 'mean', 0 );
          if is_active_threshold(ii)
            [p n] = calculate_loadings( TempComp, ep(component_no).percentiles(ii).threshold );
          end;
          loadings.pos.threshold = [loadings.pos.threshold; p ];
          loadings.neg.threshold = [loadings.neg.threshold; n ];

          if ~isempty(pop)
            pop.increment();
          end;
        end;

        err = write_cpca_image( image_directory, filename, TempComp, scan_information.mask );
        if ( ~isempty( err ) )
          show_message( 'Error Writing Image', err );
          return;
        end;

        % recreate the file at the onset, but append additional component MNI data
        if component_no == 1 mode = 'w'; else mode = 'a+'; end;
        fid = fopen( MNI_output, mode );

        if component_no == 1 % ---| showPR
          text_file_header( nd, fid, 0, component_directory, txt_file );
          pca_summary( sumDiag, rotation_settings.mode, cvariance_rotated_tot, fid );
        end;

        print_formatted_ep( ep, component_no, fid, log_fid );
        show_VR_loadings( loadings, cvariance_rotated_tot, component_no, fid, log_fid );
        
        if ( fid)  fclose(fid); end;

        if ~isempty( PRh ) & ~strcmp( rotation_settings.mode, 'GMH')  % -- only produce HRF for GMH::GMH or GMH::GC
          mniParms.component = component_no;
          mniParms.text = ftag;
          mniParms.var = 'H_Predictor_Weights';
          mni_file = fs_filename( 'txt', rotation_settings.htype, rotation_settings.method, mniParms );

          fid = fopen( [component_directory mni_file], 'w' );
          text_file_header( nd, fid, 0, component_directory, mni_file );
          pca_summary( sumDiag, rotation_settings.htype, cvariance_rotated_tot, fid );
          print_formatted_ep( ep, component_no, fid, 0 );
          show_PR_weights( PRh(:,component_no), thisVR(:,component_no), Hheader, 1, fid );

          if ( fid)  fclose(fid); end;
        end;


        component_loadings = [component_loadings; loadings];

        if ~isempty(pop)
          pop.increment();
        end;
      
      end;  % rinse and repeat for each frequency range
    end;  % rinse and repeat for each component

    save( [component_directory in_file], 'component_loadings', '-append', '-v7.3' );

    if ~scan_information.isMulFreq	% --- bypass cluster data on meg data for now
      save( [image_directory load_file], 'MNI', '-append', '-v7.3' );
    end;

    if ~isempty(pop)
      pop.setComment(  '' );
    end;
    
  end;  % output directory exists

  if ~isempty(pop)
    pop.setComment( '' );
    pop.setMessage( '' );
  end;
