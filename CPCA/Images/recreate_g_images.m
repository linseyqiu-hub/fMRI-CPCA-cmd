function recreate_g_images( rotation_params, nd, comps_to_flip, pop, GAtyp, mask_registry )
%  create the bold data images of G components 

global Zheader scan_information 
% --- Primary Iterations
% --- nd * max(scan_information.frequencies, 1)

  if ( nargin < 2 ) 
    nd = scan_information.processing.model.process.components(1);
  end;
  if nargin < 3,  comps_to_flip = 0;  end;
  if nargin < 4,  pop = [];  end;
  if nargin < 5,     GAtyp = 'G';  end;
  if nargin < 6,  mask_registry = 0;   end;

  if ~isa( pop, 'cpca_progress' ),      pop = [];    end

  ind = [];
  if mask_registry > 0
    [~, ind] = mask_registrations( scan_information.mask, mask_registry );
  end
  
  nvox = Zheader.total_columns;
  if ~isempty( ind )
    nvox = numel( ind );
  end
  rotation_params.defaults.reg = mask_registry;
  rotation_params.defaults.regTag = constant_define( 'REGISTRATION_TAG', mask_registry );

  noParms = struct( 'empty', 1 );
  isROI = strcmp( GAtyp, 'ROI' );

  if ~strcmp( GAtyp, 'G' )
    load( Zheader.Contrast.path );
    if rotation_params.Aindex > 1
      noParms.hindex = strrep( [ filesep Aheader.model( rotation_params.Aindex).id ], ' ', '_' );
    end
  end

  if ~isfield( rotation_params, 'Aindex' )
    rotation_params.Aindex = 0;
  end;
  
  dcomponent_directory = fs_path( 'rotated', 'output', nd, 0, rotation_params );
  component_directory = [pwd filesep dcomponent_directory];

  if ( comps_to_flip == 0 )
    of_these_components = 1:nd;
  else
    of_these_components = comps_to_flip;
  end;

  if isfield( rotation_params, 'defaults' )
    theseParms = rotation_params.defaults;
  end;

  ftext = GAtyp;
  if strcmp( GAtyp, 'GAA' ),     ftext = 'GnotA';  end
   
  theseParms.var = 'MNI';
  
  [thresholds, files, displays] = threshold_txts(ftext, theseParms, component_directory, rotation_params.method);

  VR = [];

  image_directory = fs_path( 'rotated', 'images', nd, 0, rotation_params );

  in_file = fs_filename( 'mat', GAtyp, rotation_params.method, rotation_params.defaults );

  load( [component_directory in_file], 'VR', 'ep', 'cvariance*', 'betas_c_pos', 'betas_c_neg', 'component_loadings' );
  load( Zheader.Model.path, 'Gheader' );

  tsum = Zheader.tsum;
  if ~strcmp( GAtyp, 'G' )
    load( Zheader.Contrast.path )
    sumDiag = Aheader.model( rotation_params.Aindex).sd(1+strcmp(GAtyp, 'GAA' ));
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

  load_file = fs_filename( 'loadings', GAtyp, rotation_params.method, rotation_params.defaults );
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
    start_col = (FrequencyNo - 1) * nvox + 1;
    end_col = start_col + nvox - 1;
    ftag = frequency_tag(FrequencyNo) ;

    thisVR = VR(start_col:end_col,:);

    for component_no = 1:nd

      loadings = [];
      Sts = ['Component ' num2str(component_no) ' of ' num2str(nd)];
      if ~isempty(pop)
        pop.setComment( Sts );
      end;

      % -----------------------------------------------
      % compose file names for images
      % we need to rewrite the MNI data files, meaning we need to recalc from all components
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
      end;
      
      ftext = GAtyp;
      if strcmp( GAtyp, 'GAA' ),         ftext = 'GnotA';       end

      filename = fs_filename( 'img', [ '_' ftext ], rotation_params.method, cmpParms );
      filename = strrep( filename, '.img', [ftag '.img'] );
      if component_mask.niiSingle,   filename = strrep( filename, '.img', '.nii' );  end;

      if ( any( of_these_components == component_no ) )
        fprintf( '---------------------------------------------------------\n   image: %s\n', filename );
        fprintf( 'location: %s\n\n', image_directory );

        if ~isempty(pop)
          pop.setComment( [Sts ' Calculating Loadings'] );
          pop.setIterations( num_global_thresholds() * 6, pop.SECONDARY ) ;
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

        component_loadings(component_no) = loadings;

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

      end;

      % recreate the file at the onset, but append additional component MNI data
      
      if ( component_no == 1 )
        ftext = [ GAtyp 'C'];
        if strcmp( GAtyp, 'GA' ) 
          ftext = GAtyp;
        end;
        if strcmp( GAtyp, 'GAA' ) 
          ftext = 'GnotA';
        end;
      end;

      threshold_tops(displays, nd, component_directory, rotation_params.Aindex, ...
              nvox, sumDiag, ftext, mask_registry, cvariance_rotated_tot, ...
              tsum, ep, component_no, 0, component_loadings(component_no), files);

      if ~isMultiFrequency()
          for thr = 1:num_global_thresholds()
              if is_active_threshold(thr)
                fid = files(thr);
                threshold_print_mni(0,component_no,fid,displays,thresholds,MNI.component(component_no), thr);                  
              end
          end
      end;

    end;  % rinse and repeat for each component
  end;  % rinse and repeat for each frequency Range

  
  for thr = 1:num_global_thresholds()
    fid = files(thr);
    if ( fid),  fclose(fid); end;
  end
    
  save( [component_directory in_file], 'component_loadings', '-append', '-v7.3' );
  if ~scan_information.isMulFreq
    save( load_file, 'MNI', '-append', '-v7.3');
  end;
  
 

