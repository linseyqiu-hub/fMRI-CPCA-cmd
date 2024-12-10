function g_images_unrotated_alt_vr( nd, subjectNo, log_fid, pop, mask_registry )
%  create the bold data images of G components 
global Zheader scan_information 

  if ~scan_information.processing.model.process.subject_specific == 1
    return
  end;

  if nargin < 1 
    nd = scan_information.processing.model.process.components(1);
  end;

  if nargin < 3, log_fid = 0; end; 
  if nargin < 4,  pop = [];  end;
  if nargin < 5,  mask_registry = 0;   end;
  if ~isa( pop, 'cpca_progress' ),     pop = [];   end
  VR = [];
  
  nvox = Zheader.total_columns;
  ind = [];
  if mask_registry > 0
    [~, ind] = mask_registrations( scan_information.mask, mask_registry );
    nvox = numel( ind );
  end
  
  noParms = struct( 'model', 'G', 'method', 'unrotated', 'reg', mask_registry, 'regTag', constant_define( 'REGISTRATION_TAG', mask_registry ) );

  component_directory = fs_path( 'subject', 'subject', nd, subjectNo, noParms );
  
  if ~isempty(pop)
    if ~isMultiFrequency()	% --- bypass cluster data on meg data for now
      pop.setIterations( max(scan_information.frequencies, 1) * nd * ( sum(constant_define( 'PREFERENCES', 'threshold.active' )) * 2 ), pop.SECONDARY );
    else
      pop.setIterations( max(scan_information.frequencies, 1) * nd * sum(constant_define( 'PREFERENCES', 'threshold.active' )), pop.SECONDARY );
    end;
    pop.setComment( 'Component Images: ' );
  end;

  theseParms = noParms;
  theseParms.var = 'MNI';
  theseParms.subject = subjectNo;
  
  mni_directory = fs_path( 'subject', 'output', nd, 0, noParms );
  mni_directory = [pwd filesep mni_directory];

  MNI_out = fs_filename( 'txt', 'G', 'unrotated', theseParms );
  MNI_output = [mni_directory MNI_out];

  MNI = struct( 'component', [] );
  component_loadings = [];

  has_dir = fs_create_path( 'subject', 'images', nd, subjectNo, noParms );
  if ( has_dir )

    image_directory = fs_path( 'subject', 'images', nd, subjectNo, noParms );
 
    VR_file = fs_filename( 'alt_vr', 'G', 'unrotated', noParms );   %  [] );
    load( [component_directory VR_file], 'VR', 'ep', 'cvariance*' );

%    load_file = fs_filename( 'loadings', 'G', 'unrotated', [] );
    load_file = fs_filename( 'loadings', 'G', 'unrotated', noParms );
    load_file = [image_directory load_file];
    initialize_mat_file( load_file );

    for FrequencyNo=1:max(scan_information.frequencies, 1)

      start_col = (FrequencyNo - 1) * nvox + 1;
      end_col = start_col + nvox - 1;
      ftag = frequency_tag(FrequencyNo) ;

      thisVR = VR(:,start_col:end_col)';

      for component_no = 1:nd

        Sts = ['Component ' num2str(component_no ) ];
          
        loadings = [];

        if ~isempty(pop)
          pop.setComment( [ Sts ' Creating Images for Subject'] );
        end;

        % -----------------------------------------------
        % compose file names for images
        % -----------------------------------------------  
        component_mask = scan_information.mask; % --= 
        component_image = thisVR(:,component_no);
        cmpParms = noParms;
        cmpParms.component = component_no;
        cmpParms.subject = subjectNo;  

        filename = fs_filename( 'subject_img', 'G', 'unrotated', cmpParms );
        filename = strrep( filename, '.img', [ftag '.img' ] );
        if scan_information.mask.niiSingle,   filename = strrep( filename, '.img', '.nii' );  end;

        if ~isempty(pop)
          pop.setIterations( size( ep(1).percentiles, 1) * sum(constant_define( 'PREFERENCES', 'threshold.active' )), pop.SECONDARY ) ;
        end;

        [loadings.pos, loadings.neg] = calculate_loadings( component_image );

        loadings.pos.threshold = [];
        loadings.neg.threshold = [];

        for ii = 1:size( ep(1).percentiles, 1) 
          p = struct ( 'loadings', 0, 'min', 0, 'max', 0, 'mean', 0 );
          n = struct ( 'loadings', 0, 'min', 0, 'max', 0, 'mean', 0 );
          if is_active_threshold(ii)
            [p, n] = calculate_loadings( component_image, ep(component_no).percentiles(ii).threshold );
          end;
          loadings.pos.threshold = [loadings.pos.threshold; p ];
          loadings.neg.threshold = [loadings.neg.threshold; n ];

          if ~isempty(pop)
           pop.increment( pop.SECONDARY );
          end;

        end;

        if ~isempty( ind )
          img = component_image;
          component_image = zeros( size( component_mask.ind ) );
          component_image( ind ) = img;
        end
        err = write_cpca_image( image_directory, filename, component_image, component_mask );
        if ( ~isempty( err ) )
          show_message( 'Error Writing Image', err );
          return;
        end;

        % recreate the file at the onset, but append additional component MNI data
        if component_no == 1,  mode = 'w'; else mode = 'a+'; end;
        fid = fopen( [mni_directory MNI_out], mode );

         if ( component_no == 1 )
           text_file_header( nd, fid, 0, component_directory, MNI_out, 0, nvox );
%           pca_summary( sumDiag, ['GC' constant_define( 'REGISTRATION_SUMMARY_TAG', mask_registry)], cvariance_rotated_tot, fid, tsum );
         end;

        print_formatted_ep( ep, component_no, fid, log_fid );
        show_VR_loadings( loadings, cvariance_rotated_tot, component_no, fid, log_fid );

        if ~isMultiFrequency()	% --- bypass cluster data on meg data for now

          clusters = struct( 'threshold', []);
          if ~isempty(pop)
            pop.setComment( [Sts ' Clusters'] );
            pop.setIterations( num_active_thresholds() * 5, pop.SECONDARY ) ;
          end;

          for thr = 1:size( ep(1).percentiles, 1 )

            if is_active_threshold(thr)
 
              if ~isempty(pop)
                pop.setComment(  [Sts ' Clusters @ ' num2str(ep(1).percentiles(thr).cutoff) '%'] );
              end;

              cl = list_clusters( [image_directory filename], ep(component_no).percentiles( thr ).threshold );
              if ~isempty(pop)
                pop.increment( pop.SECONDARY );
              end;
              peak_mni = peak_coordinates( [image_directory filename], ep(component_no).percentiles( thr ).threshold );
              if ~isempty(pop)
                pop.increment( pop.SECONDARY );
              end;
              component = cell2struct( peak_mni, {'pos','neg'}, 2 );
              cl.pos = add_cluster_peaks( cl.pos, component.pos );
              if ~isempty(pop)
                pop.increment( pop.SECONDARY );
              end;
              cl.neg = add_cluster_peaks( cl.neg, component.neg );
              if ~isempty(pop)
                pop.increment( pop.SECONDARY );
              end;
              cl = calc_cluster_masks( cl );  
              if ~isempty(pop)
                pop.increment( pop.SECONDARY );
              end;

            else
              cl = struct ( 'pos', [], 'neg', [] );
            end;

            clusters.threshold = [clusters.threshold; cl];
            if thr == constant_define( 'PREFERENCES', 'threshold.default' ) && is_active_threshold(thr)
              show_clusters( 'positive', clusters.threshold(thr).pos, log_fid, fid,  MNI_output, component_no );
              show_clusters( 'negative', clusters.threshold(thr).neg, log_fid, fid,  MNI_output, component_no );
            end;

          end;

          MNI.component = [MNI.component; clusters];

        end;

        if ( fid)  fclose(fid); end;
        
        component_loadings = [component_loadings; loadings];
        if ~isempty(pop)
          pop.increment( pop.PRIMARY );
        end;

      end;  % rinse and repeat for each component
    end;  % rinse and repeat for each frequency range

    save( [component_directory VR_file], 'component_loadings', 'VR', 'ep', '-append', '-v7.3' );

    if ~isMultiFrequency()	% --- bypass cluster data on meg data for now
      save( load_file, 'MNI', '-append', '-v7.3' );

      if mask_registry == 0   % --- cluster info only on whole brain for now
        parms = struct( 'htype', 'G', 'method', 'unrotated', 'defaults', struct( 'empty', 1 ), 'fs', 'unrotated', 'model', 'G', 'nd', nd );
        write_subject_cluster_data( parms, VR, MNI, subjectNo, pop );
      end
      
    end;

  end;  % -- dir existence


