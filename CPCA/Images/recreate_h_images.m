function recreate_h_images( rotation_settings, model, nd, log_fid )
%function recreate_h_images( rotation_settings, fi, cdir )
%  create the bold data images of G components 

global Zheader scan_information 

% H_nd3_promax_oblique_i500_p2.00_g1.00.mat
% 3_components/

  if ( nargin < 2 ) return; end; 
  if ( nargin < 3 ) nd = scan_information.processing.model.process.components(1);   end;
  if ( nargin < 4 )  log_fid = 0;  end;

  noParms = struct( 'empty', 1 );

  dcomponent_directory = fs_path( 'rotated', 'output', nd, 0, rotation_settings );
  component_directory = [pwd filesep dcomponent_directory];

  MNI = [];
  component_loadings = [];

  theseParms = rotation_settings.defaults;
  theseParms.var = 'MNI';
  MNI_output = fs_filename( 'txt', model, rotation_settings.method, theseParms );
  MNI_display = [dcomponent_directory MNI_output];
  MNI_output = [component_directory MNI_output];

  stats = struct ( ...
    'loadings', 0, ...
    'min_value', 0, ...
    'max_value', 0 );

  image_directory = fs_path( 'rotated', 'images', nd, 0, rotation_settings );

  in_file = fs_filename( 'mat', model, rotation_settings.method, rotation_settings.defaults );
  in_file = [component_directory in_file];

  load( in_file, 'VR', 'ep' );
  V = VR;

  load_file = fs_filename( 'loadings', model, rotation_settings.method, rotation_settings.defaults );
  load_file = [image_directory load_file];
  initialize_mat_file( load_file );
  save( load_file, 'nd', '-append', '-v7.3' );

%  if ( ~isempty( funcs.memory_stats ) ) funcs.memory_stats(); end;

  for FrequencyNo = 1:scan_information.frequencies
    start_col = (FrequencyNo - 1) * Zheader.total_columns + 1;
    end_col = start_col + Zheader.total_columns - 1;
    ftag = frequency_tag(FrequencyNo);

    thisVR = V(start_col:end_col,:);

    for component_no = 1:nd

%      if ( ~isempty( funcs.clear_cache ) )  funcs.clear_cache(); funcs.memory_stats(); end;

      % ----------------------------------------
      % --- we use the mask as the template for saving the component images ---
      % ----------------------------------------

      component_image = scan_information.mask;

      TempComp = thisVR(:,component_no);

      % -----------------------------------------------
      % compose file names for images
      % -----------------------------------------------
      cmpParms = rotation_settings.defaults;
      cmpParms.component = component_no;
      cmpParms.text = ftag;

      filename = fs_filename( 'img', model, rotation_settings.method, cmpParms );
      if scan_information.mask.niiSingle   filename = strrep( filename, '.img', '.nii' );  end;

      % -----------------------------------------------
      % mricron on *nix seems to hang when loading image twice
      % so we will create a secondary set of images to avoid this
      % -----------------------------------------------
      if ( isunix )
        nixcopy = [image_directory 'duplicates/' filename ];
      end;

      filename = [image_directory filename] ;

      indpos=find(TempComp >= 0);
      stats.min_value = min(TempComp(indpos));
      stats.max_value = max(TempComp(indpos));
      stats.loadings = size(indpos,1);

      threshold = ep(component_no).percentiles(2).threshold;	% top 5% of component weights
      ind5pos=find(TempComp >= threshold);
      if ~isempty( ind5pos )
        stats.mean_value = mean(TempComp(ind5pos));
      else
        stats.mean_value = 0;
      end;

      print_and_log( log_fid, '\nimage: %s\n', MNI_display );
      print_and_log( log_fid, 'The number of positive loadings is %10.3f \n\tmax: %f \n', ... 
         stats.loadings, stats.max_value );

      eval( [ 'image_stats_' num2str(component_no) ftag ' = stats;' ] );

      indpos=find(TempComp < 0);
      stats.min_value = max(TempComp(indpos));
      stats.max_value = min(TempComp(indpos));
      stats.loadings = size(indpos,1);

      ind5pos=find(TempComp <= (threshold * -1 ));
      if ~isempty( ind5pos )
        stats.mean_value = mean(TempComp(ind5pos));
      else
        stats.mean_value = 0;
      end;

      print_and_log( log_fid, 'The number of negative loadings is %10.3f \n\t min: %f\n', ... 
         stats.loadings, stats.max_value );

      eval( [ 'image_stats_' num2str(component_no) ftag ' = [ image_stats_' num2str(component_no) ftag ' stats];' ] );
      eval( [ 'component_loadings = [component_loadings; image_stats_' num2str(component_no) ftag '];' ] );

      apnd = ''; if ( component_no > 1 ) apnd = '-append'; end;		% append if required
      eval( ['save( ''' load_file ''', ''image_stats_' num2str(component_no) '*'', ''-append'', ''-v7.3'' )' ] );

      component_image.image = zeros( prod( component_image.vol.dim ), 1);	% --- storage area for finale written image --
      component_image.image( component_image.ind ) = TempComp;		% --- placing data vector into proper positions of mask ---
      component_image.image = reshape( component_image.image ,component_image.vol.dim);	% --- and reshaping the result to the mask volume dimensions ---

      dtyp = cpca_data_type( 'double' );
      src_prec = dtyp.analyse;
      if length( src_prec ) == 0
        src_prec = dtyp.nifti;
      end;
      if isBigendian()  en = 'LE'; else en = 'BE'; end;
      dtype = [src_prec '-' en];

      component_image.vol.dt = [dtyp.conversion isBigendian()];			% we default data type to signed double (float 64 )
      component_image.header.datatype = dtyp.conversion;
      component_image.header.bitpix = dtyp.bits;
      component_image.vol.fname = filename;

      if isfield( component_image.header, 'scl_slope')
        component_image.header.scl_slope = 1;
      end;
    
      component_image.vol.pinfo(1) = 1;
%      component_image.vol.private.dat.dtype = dtype;
      err = cpca_write_vols( component_image );
      if ( ~isempty( err ) )
        show_message( 'Error Writing Image', err );
        return;
      end;

      if ( isunix )

        x = exist( [ image_directory 'duplicates/'] , 'dir' );
        if ( x ~= 7 )  % the directory does not exist
         eval( [ 'mkdir ''' image_directory 'duplicates'''] );
        end;

        component_image.vol.fname = nixcopy;

        nixcopy = strrep( nixcopy, '.img', '_copy.*' );
        eval( ['delete ' nixcopy ] );

        err = cpca_write_vols( component_image );
        if ( ~isempty( err ) )
          show_message( 'Error Writing Image', err );
          return;
        end;
      end;

      % recreate the file at the onset, but append additional component MNI data
      if component_no == 1  mode = 'w'; else mode = 'a+'; end;
      fid = fopen( MNI_output, mode );

      if ( component_no == 1 )
        fprintf( fid, 'created: %s - cpca %s\n', date, constant_define( 'REVISION_NUMBER' ) );
        fprintf( fid, 'original location: %s\n', component_directory );
        fprintf( fid, '------------------------------------------\n' );
      else
        print_and_log( log_fid, '\n\n' );
        if (fid)  fprintf(fid, '\n\n' ); end;
      end;

      print_and_log( log_fid, '\nMNI coordinates for cluster peaks at 5%% threshold for component %d\n', component_no );
      if (fid)  fprintf(fid, '\nMNI coordinates for cluster peaks at 5%% threshold for component %d\n', component_no ); end;

      clusters = list_clusters( filename, ep(component_no).percentiles(2).threshold );

      peak_mni = peak_coordinates( filename, ep(component_no).percentiles(2).threshold );
      component = cell2struct( peak_mni, {'pos','neg'}, 2 );

      clusters.pos = add_cluster_peaks( clusters.pos, component.pos );
      clusters.neg = add_cluster_peaks( clusters.neg, component.neg );

      show_clusters( 'positive', clusters.pos, log_fid, fid, MNI_output, component_no );
      show_clusters( 'negative', clusters.neg, log_fid, fid, MNI_output, component_no );

      if ( fid)  fclose(fid); end;

      clusters = calc_cluster_masks( clusters );

      MNI = [MNI; clusters ];

    end;  % rinse and repeat for each component

  end;    % rinse and repeat for each frequency range

  eval( ['save( ''' load_file ''', ''MNI'', ''-append'', ''-v7.3'' )' ] );
  eval( ['save( ''' in_file ''', ''component_loadings'', ''-append'', ''-v7.3'' )' ] );



