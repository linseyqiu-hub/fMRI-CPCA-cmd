function recreate_gmh_images( rotation_params, model, nd, comps_to_flip, log_fid, pop )
%function recreate_h_images( rotation_params, fi, cdir )
%  create the bold data images of G components 

global Zheader scan_information 
% --- Primary Iterations
% --- nd * max(scan_information.frequencies, 1)

  if ( nargin < 4 ) return; end; 
  if ( nargin < 5 )  log_fid = 0;  end;
  if ( nargin < 6 )  pop = [];  end;
  if ~strcmp( class(pop), 'cpca_progress' )
    pop = []; 
  end

  noParms = struct( 'empty', 1 );

  dcomponent_directory = fs_path( 'rotated', 'output', nd, 0, rotation_params );
  component_directory = [pwd filesep dcomponent_directory];

  if ( comps_to_flip == 0 )
    start_component = 1;
    end_component = nd;
    of_these_components = 1:nd;
  else
    start_component = comps_to_flip;
    end_component = comps_to_flip;
    of_these_components = comps_to_flip;
  end;

  if isfield( rotation_params, 'defaults' )
    theseParms = rotation_params.defaults;
  end;

  if ~scan_information.isMulFreq	% --- bypass cluster data on meg data for now
    theseParms.var = 'MNI';
  end;

  MNI_out = fs_filename( 'txt', model, rotation_params.method, theseParms );
  MNI_output = [component_directory MNI_out];

  stats = struct ( ...
    'loadings', 0, ...
    'min_value', 0, ...
    'max_value', 0 );

  Txt = 'Recreating Images';

  image_directory = fs_path( 'rotated', 'images', nd, 0, rotation_params );

  in_file = fs_filename( 'mat', model, rotation_params.method, rotation_params.defaults );
%  in_file = [component_directory in_file];

  load( [component_directory in_file], 'VR', 'ep', 'component_loadings', 'cvariance*' );
  load( Zheader.Model.path, 'Gheader');

  sumDiag = 0;
  if ~strcmp( rotation_params.model, 'G' )
    load( Zheader.Limits.path );
    eval( ['sumDiag = Hheader.model(Hheader.Hindex).sum_diagonal.' rotation_params.htype ';' ] );  
  else
    sumDiag = Gheader.GZheader.sum_diagonal;
  end;

  load_file = fs_filename( 'loadings', model, rotation_params.method, rotation_params.defaults );
  load_file = [image_directory load_file];
  load( load_file, 'MNI');

%  if ( ~isempty( funcs.memory_stats ) ) funcs.memory_stats(); end;

  active_thresholds = zeros( 1, size(ep(1).percentiles,1) );
  threshold_values = active_thresholds;

  for ii = 1:size(ep(1).percentiles, 1)		% -- data set may have thresholds different from active list
    if ep(1).percentiles(ii).cutoff > 0 
      active_thresholds(ii) = 1;
      threshold_values(ii) = ep(1).percentiles(ii).cutoff;
    end;
  end;

  for FrequencyNo = 1:max(scan_information.frequencies,1)
    start_col = (FrequencyNo - 1) * Zheader.total_columns + 1;
    end_col = start_col + Zheader.total_columns - 1;
    ftag = frequency_tag(FrequencyNo) ;

    thisVR = VR(start_col:end_col,:);

    for component_no = 1:nd

      loadings = [];
      Sts = ['Component ' num2str(component_no) ' of ' num2str(nd)];
      if ~isempty(pop)
        pop.setComment( Sts );
      end;

%      if ( ~isempty( funcs.clear_cache ) )  funcs.clear_cache(pop); funcs.memory_stats(); end;

      % ----------------------------------------
      % --- we use the mask as the template for saving the component images ---
      % ----------------------------------------

      TempComp = thisVR(:,component_no);

      % -----------------------------------------------
      % compose file names for images
      % -----------------------------------------------
      cmpParms = rotation_params.defaults;
      cmpParms.component = component_no;
      cmpParms.text = ftag;

      filename = fs_filename( 'img', model, rotation_params.method, cmpParms );
      filename = strrep( filename, '.img', [ftag '.img'] );
      if scan_information.mask.niiSingle   filename = strrep( filename, '.img', '.nii' );  end;

      if ( any( of_these_components == component_no ) )
        fprintf( '---------------------------------------------------------\n   image: %s\n', filename );
        fprintf( 'location: %s\n\n', image_directory );
%      end

        if ~isempty(pop)
          pop.setComment( [Sts ' Calculating Loadings'] );
          pop.setIterations( num_global_thresholds() * 6, pop.SECONDARY ) ;
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

        component_loadings(component_no) = loadings;

        err = write_cpca_image( image_directory, filename, TempComp, scan_information.mask );
        if ( ~isempty( err ) )
          show_message( 'Error Writing Image', err );
          return;
        end;

      end;

      % recreate the file at the onset, but append additional component MNI data
      if component_no == 1  mode = 'w'; else mode = 'a+'; end;
      fid = fopen( MNI_output, mode );

      if ( component_no == 1 )
        text_file_header( nd, fid, 0, component_directory, MNI_out );
        if rotation_params.model == 'H'
          H_matrix_header(Hheader, fid);
        end;
        
        pca_summary( sumDiag, rotation_params.htype, cvariance_rotated_tot, fid );
      end;
      print_formatted_ep( ep, component_no, fid, 0 );
      show_VR_loadings( component_loadings(component_no), cvariance_rotated_tot, component_no, fid, 0 );

      thr = constant_define( 'PREFERENCES', 'threshold.default', 3 );
%      show_clusters( 'positive', MNI.component(component_no).threshold(thr).pos, 0, fid, MNI_out );
%      show_clusters( 'negative', MNI.component(component_no).threshold(thr).neg, 0, fid, MNI_out );
      
      if ( fid)  fclose(fid); end;

     end;  % rinse and repeat for each component

  end;    % rinse and repeat for each frequency range

  if ~scan_information.isMulFreq	% --- bypass cluster data on meg data for now
    save( load_file, 'MNI', '-append', '-v7.3');
  end;

  save( [component_directory in_file], 'component_loadings', '-append', '-v7.3' );



