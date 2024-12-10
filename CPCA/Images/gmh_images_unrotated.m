function gmh_images_unrotated( nd, log_fid, GMH_Part, pop )
%  create the bold data images of G components 

global Zheader scan_information 
% --- Primary Iterations
% --- nd * max(scan_information.frequencies, 1)

  if ( nargin < 1 ) 
    nd = scan_information.processing.model.process.components(1);
  end;

  if ( nargin < 2 ) log_fid = 0; end; 
  if ( nargin < 3 ) GMH_Part = 'GMH'; end; 
  if ( nargin < 4 ) pop = []; end; 
  if ~strcmp( class(pop), 'cpca_progress' )
    pop = []; 
  end


  load( Zheader.Limits.path );
  [H_ID H_Segments] = H_path_spec( Hheader, 'GMH' );

  noParms = struct( 'model', 'H', 'mode', 'GMH', 'htype', GMH_Part, 'hindex',  H_ID );
  mniParms = struct( 'model', 'H', 'mode', 'GMH', 'var', 'MNI', 'component', 0, 'text', '', 'hindex',  H_ID );

  dcomponent_directory = fs_path( 'unrotated', 'output', nd, 0,  noParms  );
  component_directory = [ pwd filesep dcomponent_directory ];

  txt_file = fs_filename( 'txt', GMH_Part, 'unrotated', mniParms );
  text_file = [component_directory txt_file];

  MNI = struct( 'component', [] );
 
  component_loadings = [];

  stats = struct ( ...
    'loadings', 0, ...
    'min_value', 0, ...
    'max_value', 0 );

  Txt = ['Extracting ' num2str(nd) ' components from GMH:' GMH_Part] ;

  [has_dir image_directory] = fs_create_path( 'unrotated', 'images', nd, 0, noParms );
  if ( has_dir )

    if ~isempty(pop)
      pop.setMessage( 'Creating Images' );
    end;

    switch GMH_Part
      case 'GMH'
        htyp = 'GMH';
      case 'GnotH'
        htyp = 'GC';
      case 'HnotG'
        htyp = 'BH';
    end
    
    sumDiag = 0;
    eval( ['sumDiag = Hheader.model(Hheader.Hindex).sum_diagonal.' htyp ';'] );

    in_file = fs_filename( 'mat', GMH_Part, 'unrotated', noParms );
    load( [component_directory in_file], 'VR', 'PR*', 'ep', 'cvariance*' );

    load_file = fs_filename( 'loadings', GMH_Part, 'unrotated', noParms );
    initialize_mat_file( [image_directory load_file] );

    print_and_log( log_fid, '\n---------------------------------------------------------\nCreating non rotated Images:\n');

    for FrequencyNo = 1:max(scan_information.frequencies,1)
      start_col = (FrequencyNo - 1) * Zheader.total_columns + 1;
      end_col = start_col + Zheader.total_columns - 1;
      ftag = frequency_tag(FrequencyNo);

      thisVR = VR(start_col:end_col,:);

      for component_no = 1:nd % --= 

        loadings = [];
        Sts = ['Component ' num2str(component_no) ' of ' num2str(nd)];
        if ~isempty(pop)
          pop.setComment( Sts );
        end;

        cmpParms = struct( 'component', component_no, 'text', ftag );

        component_image = scan_information.mask; % --= 
        TempComp = thisVR(:,component_no);

        % -----------------------------------------------
        % compose file names for images
        % -----------------------------------------------
        filename = fs_filename( 'img', GMH_Part, ['unrotated' ftag], cmpParms );
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
        if component_no == 1  mode = 'w'; else mode = 'a+'; end;
        fid = fopen( text_file, mode );

        if ( component_no == 1 )
          text_file_header( nd, fid, 0, component_directory, txt_file );
          H_matrix_header(Hheader, fid);
          pca_summary( sumDiag, GMH_Part, cvariance_rotated_tot, fid );
        end;

        print_formatted_ep( ep, component_no, fid, log_fid );
        show_VR_loadings( loadings, cvariance_rotated_tot, component_no, fid, log_fid );

        if ( fid)  fclose(fid); end;

        if ~isempty( PRh )
          mniParms.component = component_no;
          mniParms.text = ftag;
          mniParms.var = 'Predictor_Weights';
          mni_file = fs_filename( 'txt', GMH_Part, 'unrotated', mniParms );

          fid = fopen( [component_directory mni_file], 'w' );
          text_file_header( nd, fid, 0, component_directory, mni_file );
          H_matrix_header(Hheader, fid);
          pca_summary( sumDiag, GMH_Part, cvariance_rotated_tot, fid );
          print_formatted_ep( ep, component_no, fid, 0 );

          % --- normalized H will have non determinable results in PRh, but the loadings
          % --- from all voxels for that region of H will be identiac and determinable
          % --- so utilize the value from VR as the PR value for H  
          H = load_H_matrix( Hheader, 1 );
          Hheader.thisH = H(start_col:end_col,:);
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
