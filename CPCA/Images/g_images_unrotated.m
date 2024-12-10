function g_images_unrotated( nd, log_fid, pop, GAtyp, mask_registry  )
%  create the bold data images of G components 

global Zheader scan_information
% --- Primary Iterations
% --- nd * max(scan_information.frequencies, 1)

  if ( nargin < 1 ) 
    nd = scan_information.processing.model.process.components(1);
  end;

  if nargin < 2,  log_fid = 0; end; 
  if nargin < 3,  pop = 0;  end;
  if nargin < 4,  GAtyp = 'G';   end;
  if nargin < 5,  mask_registry = 0;   end;
  if ~isa( pop, 'cpca_progress' ),     pop = [];   end

  ind = [];
  if mask_registry > 0
    [~, ind] = mask_registrations( scan_information.mask, mask_registry );
  end
  
  
  Aidx = 0;
  noParms = struct( 'model', 'G', 'reg', mask_registry, 'regTag', constant_define( 'REGISTRATION_TAG', mask_registry ) );
  mniParms = struct( 'var', 'MNI', 'reg', mask_registry, 'regTag', constant_define( 'REGISTRATION_TAG', mask_registry ) );
  nvox = Zheader.total_columns;
  isROI = strcmp( GAtyp, 'ROI' );

  
  if isROI
    load( 'G_ROI' );
    noParms.hindex = strrep( [ filesep 'ROI' filesep G_ROI.mask( G_ROI.Rindex).id ], ' ', '_' );
    noParms.model = 'G';
    noParms.ROIGZ = [ noParms.model filesep strrep( G_ROI.mask( G_ROI.Rindex).id, ' ', '_' ) filesep 'GZsegs'];

    indexes = load( [ 'ROI' filesep 'data' filesep 'ROI_' num2str(G_ROI.Rindex, '%02d') '_' strrep( G_ROI.mask( G_ROI.Rindex).id, ' ', '_' ) ] );
    nvox = nvox - size( indexes.Gindex, 1 );

    tsum = G_ROI.mask( G_ROI.Rindex).tsum_ZTrim;
    
  else
    tsum = Zheader.tsum; % --= 
      
    if ~strcmp( GAtyp, 'G' )
      load( Zheader.Contrast.path );
      Aidx = Aheader.Aindex;
      if Aheader.Aindex > 1
        noParms.hindex = strrep( [ filesep Aheader.model( Aheader.Aindex).id ], ' ', '_' );
      end
    end
    
    if ~isempty( ind )
      nvox = numel( ind );
    end
    
  end
  
  dcomponent_directory = fs_path( 'unrotated', 'output', nd, 0,  noParms  );
  component_directory = [ pwd filesep dcomponent_directory ];

  component_loadings = [];

  MNI = struct( 'component', [] );
  
  ftext = GAtyp;
  if strcmp( GAtyp, 'GAA' ) 
    ftext = 'GnotA';
  end;
  
  [thresholds, files, displays] = threshold_txts(ftext, mniParms, component_directory, 'unrotated');

  VR = [];
  
  [has_dir, image_directory] = fs_create_path( 'unrotated', 'images', nd, 0, noParms  );
  if ( has_dir )

    if ~isempty(pop)
      pop.setMessage( 'Creating Images' );
    end;

    in_file = fs_filename( 'mat', GAtyp, 'unrotated', noParms );
    load( [component_directory in_file], 'VR', 'ep', 'cvariance*', 'betas_c_pos', 'betas_c_neg' );

    load_file = fs_filename( 'loadings', GAtyp, 'unrotated', noParms );
    initialize_mat_file( [image_directory load_file] );

    if isROI
      sd =  G_ROI.mask( G_ROI.Rindex ).sum_diagonal;
    else
      if ~strcmp( GAtyp, 'G' )
        load( Zheader.Contrast.path );
        sd = Aheader.model( Aheader.Aindex).sd(1+strcmp(GAtyp, 'GAA' ));
      else
        load( Zheader.Model.path, 'Gheader' );
        sd = Gheader.GZheader.sum_diagonal;
        if ~isempty( ind )
          switch mask_registry
              case 1
                sd = Gheader.GZheader.rsum(1) + sum(Gheader.GZheader.rsum(4:5));
                tsum = Zheader.rsum(1) + sum(Zheader.rsum(4:5));
              case 2
                sd = Gheader.GZheader.rsum(2);
                tsum = Zheader.rsum(2);
          end
        end  
        
      end
    end
    
    print_and_log( log_fid, '\n---------------------------------------------------------\nCreating non rotated Images:\n');

    for FrequencyNo = 1:max(scan_information.frequencies,1)
      start_col = (FrequencyNo - 1) * nvox + 1;
      end_col = start_col + nvox - 1;
      ftag = frequency_tag(FrequencyNo);

      thisVR = VR(start_col:end_col,:);

      for component_no = 1:nd % --= 

        loadings = [];
        Sts = ['Component ' num2str(component_no) ' of ' num2str(nd)];
        if ~isempty(pop)
          pop.setComment( Sts );
        end;


        noParms.component =  component_no;

        % ----------------------------------------
        % --- we use the mask as the template for saving the component images ---
        % ----------------------------------------

        component_mask = scan_information.mask; % --= 
        if isROI
          component_image = zeros( size(component_mask.ind) );
          component_image(indexes.Zindex) = thisVR(:,component_no);
        else
          component_image = thisVR(:,component_no);
        end;
          
        % -----------------------------------------------
        % compose file names for images
        % -----------------------------------------------
        ftext = GAtyp;
        if strcmp( GAtyp, 'GAA' ) 
          ftext = 'GnotA';
        end;
        filename = fs_filename( 'img', [ '_' ftext], ['unrotated' ftag], noParms );
        if component_mask.niiSingle,   filename = strrep( filename, '.img', '.nii' );  end;

        fprintf( '---------------------------------------------------------\n   image: %s\n', filename );
        fprintf( 'location: %s\n\n', image_directory );

        if ~isempty(pop)
          pop.setComment( [Sts ' Calculating Loadings'] );
          pop.setIterations( size( ep(1).percentiles, 1) * num_global_thresholds(), pop.SECONDARY ) ;
        end;

        [loadings.pos, loadings.neg] = calculate_loadings( component_image );

        loadings.pos.threshold = [];
        loadings.neg.threshold = [];

        for ii = 1:num_global_thresholds()
          p = struct ( 'loadings', 0, 'min', 0, 'max', 0, 'mean', 0 );
          n = struct ( 'loadings', 0, 'min', 0, 'max', 0, 'mean', 0 );
          if is_active_threshold(ii)
            [p, n] = calculate_loadings( component_image, ep(component_no).percentiles(ii).threshold );
          end;
          loadings.pos.threshold = [loadings.pos.threshold; p ];
          loadings.neg.threshold = [loadings.neg.threshold; n ];

          if ~isempty(pop)
            pop.increment();
          end;
        end;

        if ~isempty( ind )
          img = component_image;
          component_image = zeros( size( component_mask.ind ) );
          component_image( ind ) = img;
        end
        err = write_cpca_image( image_directory, filename, component_image, component_mask );
        if ( ~isempty( err ) )
          str = [ 'Image: ' image_directory filename '<br>Error: ' err ];
          show_message( 'Error Writing Image', str );
          return;
        end;

        % recreate the file at the onset, but append additional component MNI data
        if ( component_no == 1 )
          
          if strcmp( GAtyp, 'G' ) 
            ftext = [ GAtyp 'C'];
          end;
        end;
        
        threshold_tops(displays, nd, component_directory, Aidx, ...
              nvox, sd, ftext, mask_registry, cvariance_rotated_tot, ...
              tsum, ep, component_no, log_fid, loadings, files);

%          pca_summary( sd, ftext, cvariance_rotated_tot, fid, tsum );

      clusters = struct( 'threshold', []);
        
     if ~isMultiFrequency()	% --- bypass cluster data on meg data for now

      for thr = 1:num_global_thresholds()
          if is_active_threshold(thr)
 
              if ~isempty(pop)
                pop.setIterations( sum(constant_define( 'PREFERENCES', 'threshold.active' )) * 5, pop.SECONDARY ) ;
              end;

 
              if ~isempty(pop)
                pop.setComment( [Sts ' Calculating Clusters @ ' num2str(ep(1).percentiles(thr).cutoff) '%'] );
              end;

              cl = list_clusters( [image_directory filename], ep(component_no).percentiles( thr ).threshold );
              if ~isempty(pop)
                pop.increment( );
              end;

              peak_mni = peak_coordinates( [image_directory filename], ep(component_no).percentiles( thr ).threshold );
              if ~isempty(pop)
                pop.increment();
              end;

              component = cell2struct( peak_mni, {'pos','neg'}, 2 );
              cl.pos = add_cluster_peaks( cl.pos, component.pos );
              if ~isempty(pop)
                pop.increment();
              end;
              cl.neg = add_cluster_peaks( cl.neg, component.neg );
              if ~isempty(pop)
                pop.increment( pop.SECONDARY);
              end;
              cl = calc_cluster_masks( cl );
              if ~isempty(pop)
                pop.increment();
              end;

            clusters.threshold = [clusters.threshold; cl];
            
            fid = files(thr);

            threshold_print_mni(log_fid,component_no,fid,displays,thresholds,clusters, thr);

            else
              cl = struct ( 'pos', [], 'neg', [] );
              clusters.threshold = [clusters.threshold; cl];
            end;
          end;

          MNI.component = [MNI.component; clusters];
          
          if ~isempty(pop)
            pop.setComment( '');
          end;

        end;
        
        component_loadings = [component_loadings; loadings];

        if ~isempty(pop)
          pop.increment();
        end;
      
      end;  % rinse and repeat for each frequency range
    end;  % rinse and repeat for each component

    for thr = 1:num_global_thresholds()
        fid = files(thr);
        if ( fid),  fclose(fid); end;
    end
    
    save( [component_directory in_file], 'component_loadings', '-append', '-v7.3' );

    if ~scan_information.isMulFreq	% --- bypass cluster data on meg data for now
      save( [image_directory load_file], 'MNI', 'mask_registry', '-append', '-v7.3' );
    end;

    if ~isempty(pop)
      pop.setComment(  '' );
    end;
    
  end;  % output directory exists

  if ~isempty(pop)
    pop.setComment( '' );
    pop.setMessage( '' );
  end;

