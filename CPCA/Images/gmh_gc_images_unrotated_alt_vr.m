function gmh_gc_images_unrotated_alt_vr( nd, log_fid, pop )
%  create the bold data images of G components 

global Zheader scan_information 

  if ( nargin < 1 ) 
    nd = scan_information.processing.model.process.components(1);
  end;
  if ( nargin < 2 ) log_fid = 0; end; 
  if ( nargin < 3 )  pop = [];  end;
  if ~strcmp( class(pop), 'cpca_progress' )
    pop = []; 
  end

  if ~scan_information.processing.GMH_model.subject_specific == 1
    return
  end;

  Txt = 'Imaging Subject Specific components';
  if ~isempty(pop)
    pop.setMessages( Txt, '', '' );
  end;

  load( Zheader.Limits.path );
  [H_ID H_Segments] = H_path_spec( Hheader, 'GMH' );
  noParms = struct( 'model', 'H', 'mode', 'GMH', 'method', 'unrotated', 'htype', 'GC', 'hindex',  H_ID );
  dcomponent_directory = fs_path( 'subject', 'output', nd, 0, noParms );
  component_directory = [pwd filesep dcomponent_directory];

  % --- total component MNI coords and masks
  comp_image_directory = fs_path( 'unrotated', 'images', nd, 0, noParms  );

  mni_file = fs_filename( 'mat', 'G', 'unrotated', noParms );
  mni_file = [comp_image_directory 'image-loadings_' mni_file];

  noParms.var = 'MNI';
  MNI_out = fs_filename( 'txt', 'GC', 'unrotated', noParms );
  MNI_output = [component_directory MNI_out];

  stats = struct ( ...
    'loadings', 0, ...
    'min_value', 0, ...
    'max_value', 0 );

  for subjectNo = 1:Zheader.num_subjects

    sid = subject_id( subjectNo );
    if ~isempty(pop)
      pop.setParticipant( subjectNo, Zheader.num_subjects, sid );
    end;

    MNI = struct( 'component', [] );
    component_loadings = [];

    has_dir = fs_create_path( 'subject', 'images', nd, subjectNo, noParms );
    if ( has_dir )

      image_directory = fs_path( 'subject', 'images', nd, subjectNo, noParms );
      output_directory = fs_path( 'subject', 'subject', nd, subjectNo, noParms );
 
      VR_File = fs_filename( 'alt_vr', 'GC', 'unrotated', [] );

      this_comp_dir = image_directory;
      
      VR = [];
      ep = [];

      load( [component_directory VR_File], ['alt_VR_S' num2str(subjectNo)], ['ep_' num2str(subjectNo)] );
      eval( [ 'VR = alt_VR_S' num2str(subjectNo) '; '] );
      eval( [ 'ep = ep_' num2str(subjectNo) ';' ] );
      clear alt_VR_S*;

      load_file = fs_filename( 'loadings', 'GC', 'unrotated', [] );
      load_file = [image_directory load_file];
      initialize_mat_file( load_file );

      for FrequencyNo=1:max(scan_information.frequencies, 1)

        start_col = (FrequencyNo - 1) * Zheader.total_columns + 1;
        end_col = start_col + Zheader.total_columns - 1;
        thisVR = VR(:,start_col:end_col)';

        ftag = frequency_tag(FrequencyNo) ;
        if scan_information.frequencies > 1
          if ~isempty(pop)
            pop.setFrequency( FrequencyNo, scan_information.frequencies );
          end;
        end;

        for component_no = 1:nd

          Sts = ['Component ' num2str(component_no) ' of ' num2str(nd)];
          if ~isempty(pop)
            pop.setMessage( Sts );
          end;

          cmpParms = struct( 'component', component_no, 'subject', subjectNo );

          % ----------------------------------------
          % --- we use the mask as the template for saving the component images ---
          % ----------------------------------------

          TempComp = thisVR(:,component_no);

          % -----------------------------------------------
          % compose file names for images
          % -----------------------------------------------  

          filename = fs_filename( 'subject_img', 'GC', 'unrotated', cmpParms );
          filename = strrep( filename, '.img', [ftag '.img' ] );
          if scan_information.mask.niiSingle   filename = strrep( filename, '.img', '.nii' );  end;

          if ~isempty(pop)
            pop.setComment( 'Calculating Loadings' );
            pop.setIterations( size( ep(1).percentiles, 1) ) ;
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


          if ~scan_information.isMulFreq	% --- bypass cluster data on meg data for now

            eval( ['ep = ep_' num2str(subjectNo) ';' ] );

            clusters = struct( 'threshold', []);
            if ~isempty(pop)
              pop.setComment( 'Calculating Clusters' );
              pop.setIterations( size( ep(1).percentiles, 1) * 5 ) ;
            end;

            for thr = 1:size( ep(1).percentiles, 1 )

              if is_active_threshold(thr)
 
                if ~isempty(pop)
                  pop.setComment(  ['Calculating Clusters @ ' num2str(ep(1).percentiles(thr).cutoff) '%'] );
                end;

                cl = list_clusters( [image_directory filename], ep(component_no).percentiles( thr ).threshold );
                if ~isempty(pop)
                  pop.increment();
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
                  pop.increment();
                end;
                cl = calc_cluster_masks( cl );  
                if ~isempty(pop)
                  pop.increment();
                end;

              else
                cl = struct ( 'pos', [], 'neg', [] );
              end;

              clusters.threshold = [clusters.threshold; cl];
              if thr == constant_define( 'PREFERENCES', 'threshold.default', 3 ) & is_active_threshold(thr)
                show_clusters( 'positive', clusters.threshold(thr).pos, log_fid, 0,  MNI_output, component_no );
                show_clusters( 'negative', clusters.threshold(thr).neg, log_fid, 0,  MNI_output, component_no );
              end;

            end;

            MNI.component = [MNI.component; clusters];

          end;

        end;  % rinse and repeat for each component

      end;  % rinse and repeat for each frequency

      save( [component_directory VR_File], 'component_loadings', 'VR', 'ep', '-append', '-v7.3' );

      if ~scan_information.isMulFreq	% --- bypass cluster data on meg data for now

        % --- preserve subject specific MNI data, but perform stats on full component clusters
        save( load_file, 'MNI', '-append', '-v7.3' );

        parms = struct( 'htype', 'GC', 'mode', 'GMH', 'method', 'unrotated', 'defaults', struct( 'empty', 1 ), 'fs', 'unrotated', 'model', 'H', 'nd', nd, 'hindex',  H_ID );
        write_subject_cluster_data( parms, VR, MNI, subjectNo );

      end;


    end;  % -- dir existence

  end;  % -- each subject


