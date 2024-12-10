function g_images_rotated_cmd(Zheader, scan_information, rotation_params, nd, log_fid, GAtyp, mask_registry  )
%  create the bold data images of G components 

% --- Primary Iterations
% --- nd * max(scan_information.frequencies, 1)
  VR = [];
  
  if ( nargin < 4 ) 
    nd = scan_information.processing.model.process.components(1);
  end
  if nargin < 5,  log_fid = 0;   end
  if nargin < 6,  GAtyp = 'G';   end
  if nargin < 7,  mask_registry = 0;   end

  isROI = strcmp( GAtyp, 'ROI' );

%  mask_registry = reg * constant_define( 'PREFERENCES', 'general.gray_white_split' );
  ind = [];
  if mask_registry > 0
    [~, ind] = mask_registrations( scan_information.mask, mask_registry );
  end

  nvox = Zheader.total_columns;
  if ~isempty( ind )
    nvox = numel( ind );
  end

  noParms = struct( 'model', 'G' );
  if ~isfield( rotation_params, 'Aindex' )
    rotation_params.Aindex = 0;
  end
  
  if ~strcmp( GAtyp, 'G' )
    load( Zheader.Contrast.path );
    if rotation_params.Aindex > 1
      noParms.hindex = strrep( [ filesep Aheader.model( rotation_params.Aindex ).id ], ' ', '_' );
    end
  end

  if ~isfield( rotation_params, 'Aindex' )
    rotation_params.Aindex = 0;
  end

  component_directory = fs_path( 'rotated', 'output', nd, 0, rotation_params );
  component_directory = [pwd filesep component_directory];

  component_loadings = [];
  MNI = struct( 'component', [] );

%   if mask_registry > 0
     rotation_params.defaults.reg =  mask_registry;
     rotation_params.defaults.regTag = constant_define( 'REGISTRATION_TAG', mask_registry );
%   end

  theseParms = rotation_params.defaults;
  theseParms.var = 'MNI';
  ftext = GAtyp;
  if strcmp( GAtyp, 'GAA' ) 
    ftext = 'GnotA';
  end
  
  [thresholds, files, displays] = threshold_txts(ftext, theseParms, component_directory, rotation_params.method);

  [has_dir, image_directory] = fs_create_path( 'rotated', 'images', nd, 0, rotation_params );

  if ( has_dir )

    in_file = fs_filename( 'mat', GAtyp, rotation_params.method, rotation_params.defaults );

    load( [component_directory in_file], 'VR', 'ep', 'cvariance*', 'betas_c_pos', 'betas_c_neg' );
    load( Zheader.Model.path ,'Gheader');

    load_file = fs_filename( 'loadings', GAtyp, rotation_params.method, rotation_params.defaults );
    load_file = [image_directory load_file];
    initialize_mat_file( load_file );

    tsum = Zheader.tsum;
    if ~strcmp( GAtyp, 'G' )
      load( Zheader.Contrast.path );
      sumDiag = Aheader.model( Aheader.Aindex).sd(1+strcmp(GAtyp, 'GAA' ));
    else
      sumDiag = Gheader.GZheader.sum_diagonal;
      switch mask_registry
        case 1
          sumDiag = Gheader.GZheader.rsum(1) + sum(Gheader.GZheader.rsum(4:5));
          tsum = Zheader.rsum(1) + sum(Zheader.rsum(4:5));
        case 2
          sumDiag = Gheader.GZheader.rsum(2);
          tsum = Zheader.rsum(2);
      end
    end

    print_and_log( log_fid, '\n---------------------------------------------------------\nCreating rotated Images:\n');

    for FrequencyNo = 1:max(scan_information.frequencies, 1)
      start_col = (FrequencyNo - 1) * nvox + 1;
      end_col = start_col + nvox - 1;
      ftag = frequency_tag_cmd(FrequencyNo,scan_information);

      thisVR = VR(start_col:end_col,:);
 
      for component_no = 1:nd

        loadings = [];
        Sts = ['Component ' num2str(component_no) ' of ' num2str(nd)];

        % -----------------------------------------------
        % compose file names for images
        % -----------------------------------------------
        cmpParms = rotation_params.defaults;
        cmpParms.component = component_no;
        cmpParms.text = ftag;

        component_mask = scan_information.mask; % --= 
        if isROI
          component_image = zeros( size(component_mask.ind) );
          component_image(indexes.Zindex) = thisVR(:,component_no);
        else
          component_image = thisVR(:,component_no);
        end
      
        ftext = GAtyp;
        if strcmp( GAtyp, 'GAA' ),  ftext = 'GnotA';        end

        filename = fs_filename( 'img', [ '_' ftext ], rotation_params.method, cmpParms );
        filename = strrep( filename, '.img', [ftag '.img'] );
        if scan_information.mask.niiSingle,   filename = strrep( filename, '.img', '.nii' );  end;
        fprintf( '---------------------------------------------------------\n   image: %s\n', filename );
        fprintf( 'location: %s\n\n', image_directory );

        fprintf('%s Calculating Loadings\n', Sts );


        [loadings.pos, loadings.neg] = calculate_loadings( component_image );

        loadings.pos.threshold = [];
        loadings.neg.threshold = [];

        for ii = 1:num_global_thresholds()
          p = struct ( 'loadings', 0, 'min', 0, 'max', 0, 'mean', 0 );
          n = struct ( 'loadings', 0, 'min', 0, 'max', 0, 'mean', 0 );
          if is_active_threshold(ii)
            [p, n] = calculate_loadings( component_image, ep(component_no).percentiles(ii).threshold );
          end
          loadings.pos.threshold = [loadings.pos.threshold; p ];
          loadings.neg.threshold = [loadings.neg.threshold; n ];

        end

        if ~isempty( ind )
          img = component_image;
          component_image = zeros( size( component_mask.ind ) );
          component_image( ind ) = img;
        end
        err = write_cpca_image( image_directory, filename, component_image, component_mask );
        if ( ~isempty( err ) )
          fprintf( 'Error Writing Image: %s \n', err );
          return;
        end

        
        % recreate the file at the onset, but append additional component MNI data
        if (component_no == 1)

            ftext = [ GAtyp 'C'];
            if strcmp( GAtyp, 'GA' ) 
              ftext = GAtyp;
            end
            if strcmp( GAtyp, 'GAA' ) 
              ftext = 'GnotA';
            end
        end
        
        threshold_tops_cmd(Zheader,scan_information,displays, nd, component_directory, rotation_params.Aindex, ...
              nvox, sumDiag, ftext, mask_registry, cvariance_rotated_tot, ...
              tsum, ep, component_no, log_fid, loadings, files);

        clusters = struct( 'threshold', []);

        if ~(scan_information.isMulFreq == 1)	% --- bypass cluster data on meg data for now
          for thr = 1:num_global_thresholds()
              if is_active_threshold(thr)
                  disp( 'Calculating Clusters' );
                  % pop.setIterations(  size( ep(1).percentiles, 1) * sum(constant_define( 'PREFERENCES', 'threshold.active' )), pop.SECONDARY ) ;
                  % pop.setComment( [Sts ' Calculating Clusters @ ' num2str(ep(1).percentiles(thr).cutoff) '%'] );


                  cl = list_clusters( [image_directory filename], ep(component_no).percentiles( thr ).threshold );
                  peak_mni = peak_coordinates( [image_directory filename], ep(component_no).percentiles( thr ).threshold );


                  component = cell2struct( peak_mni, {'pos','neg'}, 2 );
                  cl.pos = add_cluster_peaks( cl.pos, component.pos );
                  cl.neg = add_cluster_peaks( cl.neg, component.neg );
                  cl = calc_cluster_masks_cmd(scan_information, cl );


                  clusters.threshold = [clusters.threshold; cl];

                  fid = files(thr);

                  threshold_print_mni_cmd(log_fid,component_no,fid,displays,thresholds,clusters, thr);

              else
                  cl = struct ( 'pos', [], 'neg', [] );
                  clusters.threshold = [clusters.threshold; cl];
              end
          end

          MNI.component = [MNI.component; clusters];

        end

        component_loadings = [component_loadings; loadings];

      
      end  % rinse and repeat for each frequency range
    end  % rinse and repeat for each component

    for thr = 1:num_global_thresholds()
      fid = files(thr);
      if ( fid),  fclose(fid); end
    end
    
    save( [component_directory in_file], 'component_loadings', '-append', '-v7.3' );

    if ~scan_information.isMulFreq	% --- bypass cluster data on meg data for now
      save( load_file, 'MNI', '-append', '-v7.3' );
    end
    
  end  % output directory exists

  

