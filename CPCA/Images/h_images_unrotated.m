function h_images_unrotated( nd, model, log_fid, pop  )
%  create the bold data images of G components 

global Zheader scan_information 

  if ( nargin < 2 ) return; end; 
  if ( nargin < 3 ) log_fid = 0; end; 
  if ( nargin < 4 )  pop = 0;  end;
  if ~strcmp( class(pop), 'cpca_progress' )
    pop = []; 
  end


  showPR = 0;
  if strcmp( model, 'ZH' ) | strcmp( model, 'EH' )
    showPR = 1;
  end;
  
  load( Zheader.Limits.path );

  [H_ID H_Segments] = H_path_spec( Hheader, model );

  noParms = struct( 'model', 'H', 'mode', model, 'hindex',  H_ID );
  mniParms = struct( 'model', 'H', 'mode', model, 'var', 'MNI', 'component', 0, 'text', '' );

  gcomponent_directory = fs_path( 'unrotated', 'output', nd, 0,  struct( 'model', 'G')  );
  dcomponent_directory = fs_path( 'unrotated', 'output', nd, 0,  noParms  );
  component_directory = [ pwd filesep dcomponent_directory ];

  [path in_file] = split_path( Zheader.Limits.path, filesep );

%  if strcmp( model, 'GMH' ) 
    fn_text = model;
%  else
%    fn_text = [ 'H' model];
%  end;

  txt_file = fs_filename( 'txt', fn_text, 'unrotated', mniParms );
  text_file = [component_directory txt_file];

  MNI = struct( 'component', [] );
 
  component_loadings = [];

  stats = struct ( ...
    'loadings', 0, ...
    'min_value', 0, ...
    'max_value', 0 );

  Txt = sprintf( 'Creating Images', nd );

  [has_dir image_directory] = fs_create_path( 'unrotated', 'images', nd, 0, noParms );
  if ( has_dir )

    if ~isempty(pop)
      pop.setMessage( 'Creating Images' );
    end;

    sumDiag = 0;
    eval( ['sumDiag = Hheader.model(Hheader.Hindex).sum_diagonal.' model ';'] );

    in_file = fs_filename( 'mat', fn_text, 'unrotated', noParms );
    load( [component_directory in_file] , 'VR', 'PR*', 'ep', 'cvariance*', 'betas_c_pos', 'betas_c_neg', 'tsum' );

    load_file = fs_filename( 'loadings', fn_text, 'unrotated', noParms );
    initialize_mat_file( [image_directory load_file] );

    print_and_log( log_fid, '\n---------------------------------------------------------\nCreating non rotated Images:\n');

    for FrequencyNo = 1:max(scan_information.frequencies,1)
      start_col = (FrequencyNo - 1) * Zheader.total_columns + 1;
      end_col = start_col + Zheader.total_columns - 1;
      ftag = frequency_tag(FrequencyNo);

      thisVR = VR(start_col:end_col,:);

      for component_no = 1:nd % --= 

        if showPR
          mniParms.component = component_no;
          mniParms.text = ftag;
          mniParms.var = 'Predictor_Weights';
          txt_file = fs_filename( 'txt', fn_text, 'unrotated', mniParms );
          text_file = [component_directory txt_file];
        end;
        
        loadings = [];
        Sts = ['Component ' num2str(component_no) ' of ' num2str(nd)];
        if ~isempty(pop)
          pop.setComment( Sts );
        end;

        cmpParms = struct( 'component', component_no );

        % ----------------------------------------
        % --- we use the mask as the template for saving the component images ---
        % ----------------------------------------

        component_image = scan_information.mask; % --= 
        TempComp = thisVR(:,component_no);

        % -----------------------------------------------
        % compose file names for images
        % -----------------------------------------------
        filename = fs_filename( 'img', fn_text, ['unrotated' ftag], cmpParms );
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
        if (component_no == 1 & ~showPR) | showPR  mode = 'w'; else mode = 'a+'; end;
        fid = fopen( text_file, mode );

        if component_no == 1 | showPR
          text_file_header( nd, fid, 0, component_directory, txt_file );
          H_matrix_header(Hheader, fid);
          pca_summary( sumDiag, model, cvariance_rotated_tot, fid, tsum );
        end;

        print_formatted_ep( ep, component_no, fid, log_fid );
        if ~showPR
          show_VR_loadings( loadings, cvariance_rotated_tot, component_no, fid, log_fid );
        else
          H = load_H_matrix( Hheader, 1 );  
          Hheader.thisH = H(start_col:end_col,:);
          show_PR_weights(PRh(:,component_no), thisVR(:,component_no), Hheader, 1, fid )
          clear Hheader.thisH;
        end;
        if ( fid)  fclose(fid); end;

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
