function g_images_rotated_alt_vr_cmd(Zheader, scan_information,  rotation_params, subjectNo, nd, log_fid, mask_registry )
%  create the bold data images of G components 

  if ( nargin < 5 ) 
    nd = scan_information.processing.model.process.components(1);
  end
  if ( nargin < 6 ),  log_fid = 0;  end
  if nargin < 7,  mask_registry = 0;   end

  nvox = Zheader.total_columns;
  ind = [];
  if mask_registry > 0
    [~, ind] = mask_registrations( scan_information.mask, mask_registry );
    nvox = numel( ind );
  end
  
  if ~(rotation_params.defaults.subject_stats || scan_information.processing.model.process.subject_specific_rotated )
    return
  end

  dcomponent_directory = fs_path( 'subject', 'output', nd, 0, rotation_params );
  component_directory = [pwd filesep dcomponent_directory];


  MNI = struct( 'component', []);
  component_loadings = [];

  theseParms = rotation_params.defaults;
  theseParms.var = 'MNI';
  theseParms.subject = subjectNo;

  MNI_out = fs_filename( 'txt', 'G', rotation_params.method, theseParms );
  MNI_output = [component_directory MNI_out];

  VR = [];
  

  % if ~isempty(pop)
  %   if ~(scan_information.isMulFreq == 1)	% --- bypass cluster data on meg data for now
  %     pop.setIterations( max(scan_information.frequencies, 1) * nd * (sum(constant_define( 'PREFERENCES', 'threshold.active' )) * 2), pop.SECONDARY );
  %   else
  %     pop.setIterations( max(scan_information.frequencies, 1) * nd * sum(constant_define( 'PREFERENCES', 'threshold.active' )), pop.SECONDARY );
  %   end;
  disp( 'Component Images: ' );
  % end;

  has_dir = fs_create_path( 'subject', 'images', nd, subjectNo, rotation_params );
  if ( has_dir )

    image_directory = fs_path( 'subject', 'images', nd, subjectNo, rotation_params );
    output_directory = fs_path( 'subject', 'subject', nd, subjectNo, rotation_params );
 
    VR_file = fs_filename( 'alt_vr', 'G', rotation_params.method, rotation_params.defaults );
      
    VR = [];
    ep = [];
    
    eval( [ 'load( ''' [component_directory VR_file] ''', ''alt_VR_S' num2str(subjectNo) ''', ''ep_' num2str(subjectNo) ''', ''cvariance*'' );' ] );
    eval( [ 'VR = alt_VR_S' num2str(subjectNo) '; '] );
    eval( [ 'ep = ep_' num2str(subjectNo) ';' ] );
    clear ep_*;
      
    load_file = fs_filename( 'loadings', 'G', rotation_params.method, rotation_params.defaults );
    load_file = [image_directory load_file];
    initialize_mat_file( load_file );

    for FrequencyNo=1:max(scan_information.frequencies, 1)

      start_col = (FrequencyNo - 1) * nvox + 1;
      end_col = start_col + nvox - 1;
      thisVR = VR(:,start_col:end_col)';

      ftag = frequency_tag_cmd(FrequencyNo, scan_information) ;

      for component_no = 1:nd

       Sts = ['Component ' num2str(component_no ) ];
       loadings = [];

       fprintf('%s Creating Images for Subject', Sts );


 
        % -----------------------------------------------
        % compose file names for images
        % -----------------------------------------------  
        component_mask = scan_information.mask; 
        component_image = thisVR(:,component_no);
        cmpParms = rotation_params.defaults;
        cmpParms.component = component_no;
        cmpParms.subject = subjectNo;

        filename = fs_filename( 'subject_img', 'G', rotation_params.method, cmpParms );
        filename = strrep( filename, '.img', [ftag '.img' ] );
        if scan_information.mask.niiSingle,   filename = strrep( filename, '.img', '.nii' );  end

        % if ~isempty(pop)
        %   pop.setIterations( size( ep(1).percentiles, 1) * sum(constant_define( 'PREFERENCES', 'threshold.active' )), pop.SECONDARY ) ;
        % end

        [loadings.pos, loadings.neg] = calculate_loadings( component_image );
 
        loadings.pos.threshold = [];
        loadings.neg.threshold = [];

        for ii = 1:size( ep(1).percentiles, 1) 
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
          fprintf( 'Error Writing Image: %s', err );
          return;
        end

        % recreate the file at the onset, but append additional component MNI data
        if component_no == 1,  mode = 'w'; else mode = 'a+'; end
        fid = fopen( [component_directory MNI_out], mode );

         if ( component_no == 1 )
           text_file_header_cmd(Zheader,scan_information, nd, fid, 0, component_directory, MNI_out, rotation_params.Aindex, nvox );
%           pca_summary( sumDiag, ['GC' constant_define( 'REGISTRATION_SUMMARY_TAG', mask_registry)], cvariance_rotated_tot, fid, tsum );
         end

        print_formatted_ep( ep, component_no, fid, log_fid );
        show_VR_loadings( loadings, cvariance_rotated_tot, component_no, fid, log_fid );
        
        if ~(scan_information.isMulFreq == 1)	% --- bypass cluster data on meg data for now

          clusters = struct( 'threshold', []);

          fprintf('%s Clusters\n', Sts );

          for thr = 1:size( ep(1).percentiles, 1 )

            if is_active_threshold(thr)
 

              fprintf('%s Clusters @ %s  %\n', Sts,num2str(ep(component_no).percentiles(thr).cutoff) );

              cl = list_clusters( [image_directory filename], ep(component_no).percentiles( thr ).threshold );

              peak_mni = peak_coordinates( [image_directory filename], ep(component_no).percentiles( thr ).threshold );

              component = cell2struct( peak_mni, {'pos','neg'}, 2 );
              cl.pos = add_cluster_peaks( cl.pos, component.pos );
              cl.neg = add_cluster_peaks( cl.neg, component.neg );
 
              cl = calc_cluster_masks_cmd(scan_information, cl );  

            else
              cl = struct ( 'pos', [], 'neg', [] );
            end

            clusters.threshold = [clusters.threshold; cl];
            if thr == constant_define( 'PREFERENCES', 'threshold.default' ) && is_active_threshold(thr)
              show_clusters_cmd( 'positive', clusters.threshold(thr).pos, log_fid, fid, MNI_output, component_no );
              show_clusters_cmd( 'negative', clusters.threshold(thr).neg, log_fid, fid, MNI_output, component_no );
            end

          end

          MNI.component = [MNI.component; clusters];

        end

       if ( fid),  fclose(fid); end

        component_loadings = [component_loadings; loadings];

      end  % rinse and repeat for each component
    end  % rinse and repeat for each frequency range

    vr_file = [output_directory VR_file];
    initialize_mat_file( vr_file );
    save( vr_file, 'component_loadings', 'VR', 'ep', '-append', '-v7.3' );

    if ~(scan_information.isMulFreq == 1)	% --- bypass cluster data on meg data for now
      save( load_file, 'MNI', '-append', '-v7.3' );

      if mask_registry == 0   % --- cluster info only on whole brain for now
      
        if  constant_define( 'PREFERENCES', 'cluster.calculate_mean' , 0 ) || ...
            constant_define( 'PREFERENCES', 'cluster.calculate_median' , 0 )
          rotation_params.nd = nd;
          write_subject_cluster_data_cmd(Zheader, rotation_params, VR, MNI, subjectNo );
        end
      end
    end

  end  % -- dir existence



