function recreate_g_images_alt_vr( rotation_params, nd, comps_to_flip, log_fid, pop )
%function recreate_g_images_alt_vr( fi, cdir )

%  create the bold data images of G components 

global Zheader scan_information 

  if ( nargin < 2 ) 
    nd = scan_information.processing.model.process.components(1);
  end;
  if ( nargin < 3 )  comps_to_flip = 0;  end;
  if ( nargin < 4 )  log_fid = 0;  end;
  if ( nargin < 5 )  pop = [];  end;
  if ~strcmp( class(pop), 'cpca_progress' )
    pop = []; 
  end

  noParms = struct( 'empty', 1 );
  Txt = 'Recreating Images';

  dcomponent_directory = fs_path( 'subject', 'output', nd, 0, rotation_params );
  component_directory = [pwd filesep dcomponent_directory];

%  component_loadings = [];

  if ( comps_to_flip == 0 )
    start_component = 1;
    end_component = nd;
    of_these_components = 1:nd;
  else
    start_component = comps_to_flip;
    end_component = comps_to_flip;
    of_these_components = comps_to_flip;
  end;

%  MNI = struct( 'component', [] );

  for subjectNo = 1:Zheader.num_subjects

    if isfield( rotation_params, 'defaults' )
       theseParms = rotation_params.defaults;
    end;

    theseParms.var = 'MNI';
    MNI_out = fs_filename( 'txt', 'G', rotation_params.method, theseParms );
    MNI_display = [dcomponent_directory MNI_out];
%    MNI_output = [component_directory MNI_out];

    stats = struct ( ...
      'loadings', 0, ...
      'min_value', 0, ...
      'max_value', 0 );

    image_directory = fs_path( 'subject', 'images', nd, subjectNo, rotation_params );
    subject_directory = fs_path( 'subject', 'subject', nd, subjectNo, rotation_params );
 
    VR_input = fs_filename( 'alt_vr', 'G', rotation_params.method, rotation_params.defaults );
%    VR_input = [component_directory VR_input];

    this_comp_dir = image_directory;

    load( [subject_directory VR_input], 'VR', 'ep', 'cvar*', 'component_loadings' );

    active_thresholds = zeros( 1, size(ep(1).percentiles,1) );
    threshold_values = active_thresholds;

    for ii = 1:size(ep(1).percentiles, 1)		% -- data set may have thresholds different from active list
      if ep(1).percentiles(ii).cutoff > 0 
        active_thresholds(ii) = 1;
        threshold_values(ii) = ep(1).percentiles(ii).cutoff;
      end;
    end;

    mni_file = fs_filename( 'loadings', 'G', rotation_params.method, rotation_params.defaults );
%    load_file = [image_directory load_file];
    load( [image_directory mni_file],  'MNI' );

    for FrequencyNo = 1:max(scan_information.frequencies,1)
      start_col = (FrequencyNo - 1) * Zheader.total_columns + 1;
      end_col = start_col + Zheader.total_columns - 1;
      ftag = frequency_tag(FrequencyNo) ;

%      eval( [ 'thisVR = alt_VR_S' num2str(subjectNo) '(:,start_col:end_col)'';' ] );
      thisVR = VR(:,start_col:end_col)';
%      for component_no = start_component:end_component
      for component_no = 1:nd

        loadings = [];
        Sts = ['Component ' num2str(component_no) ' of ' num2str(nd)];
        if ~isempty(pop)
          pop.setMessage( Txt, Sts, '' );
        end;

        % -----------------------------------------------
        % compose file names for images
        % -----------------------------------------------  
        cmpParms = rotation_params.defaults;
        cmpParms.component = component_no;
        cmpParms.subject = subjectNo;

        filename = fs_filename( 'subject_img', 'G', rotation_params.method, cmpParms );
        filename = strrep( filename, '.img', [ftag '.img'] );
        if scan_information.mask.niiSingle   filename = strrep( filename, '.img', '.nii' );  end;
        
        if ( any( of_these_components == component_no ) )
          fprintf( '---------------------------------------------------------\n   image: %s\n', filename );
          fprintf( 'location: %s\n\n', image_directory );
%        end

          % ----------------------------------------
          % --- we use the mask as the template for saving the component images ---
          % ----------------------------------------

          component_image = scan_information.mask;
          TempComp = thisVR(:,component_no);

          if ~isempty(pop)
            pop.setMessage( Txt, Sts, 'Calculating Loadings' );
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


          component_loadings(component_no) = loadings;

          err = write_cpca_image( image_directory, filename, TempComp, scan_information.mask );
          if ( ~isempty( err ) )
            show_message( 'Error Writing Image', err );
            return;
          end;

        end;

%        cmp_file = fs_filename( 'mat', 'G', rotation_params.method, rotation_params.defaults );
%        load( [subject_directory cmp_file], 'component_loadings' );

        % recreate the file at the onset, but append additional component MNI data
        if component_no == 1  mode = 'w'; else mode = 'a+'; end;
        MNI_output = [subject_directory MNI_out]
        fid = fopen( MNI_output, mode );

        if ( component_no == 1 )
            text_file_header( nd, fid, 0, component_directory, MNI_out )
        end;

        print_formatted_ep( ep(component_no), component_no, fid, 0 );
        show_VR_loadings( component_loadings(component_no), cvariance_rotated_tot, component_no, fid, 0 );

        thr = constant_define( 'PREFERENCES', 'threshold.default', 3 );
        if isfield( MNI', 'component' )
          show_clusters( 'positive', MNI.component(component_no).threshold(thr).pos, 0, fid, MNI_output, component_no );
          show_clusters( 'negative', MNI.component(component_no).threshold(thr).neg, 0, fid, MNI_output, component_no );
        else
          show_clusters( 'positive', MNI.component(component_no).threshold(thr).pos, 0, fid, MNI_output, component_no );
          show_clusters( 'negative', MNI.component(component_no).threshold(thr).neg, 0, fid, MNI_output, component_no );
        end;
        
        if ( fid)  fclose(fid); end;

      end;  % rinse and repeat for each component

    end;  % -- each frequency

    save( [subject_directory VR_input], 'component_loadings', '-append', '-v7.3' );

  end;  % -- each subject



