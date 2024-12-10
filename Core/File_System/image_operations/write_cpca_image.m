function err = write_cpca_image( image_directory, image_name, image_data, image_mask )

  err = [];

  component_image = image_mask;

  dim = component_image.vol.dim;
  component_image.vol= component_image.vol(1);
  component_image.image = zeros( prod( dim ), 1);	% --- storage area for finale written image --
  component_image.image( component_image.ind ) = image_data;		% --- placing data vector into proper positions of mask ---
  component_image.image = reshape( component_image.image ,dim);	% --- and reshaping the result to the mask volume dimensions ---

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
  component_image.vol.fname = [image_directory image_name ];

  if isfield( component_image.header, 'scl_slope')
    component_image.header.scl_slope = 1;
  end;
    
  component_image.vol.pinfo(1) = 1;
  component_image.vol.private.dat.dtype = dtype;

  component_image.header.vox_offset = 0;
  component_image.header.magic = 'ni1';
  component_image.header.regular = 'r'; % --= 
  component_image.header.glmax = max(component_image.image); % --= 
  component_image.header.glmin = min(component_image.image); % --= 

  err = cpca_write_vols( component_image );
  if ( ~isempty( err ) )
    return;
  end;

  if ( isunix ) & constant_define( 'PREFERENCES', 'general.duplicate_images' )

    x = exist( [ image_directory 'duplicates'] , 'dir' );
    if ( x ~= 7 )  % the directory does not exist
      eval( [ 'mkdir ''' image_directory 'duplicates'''] );
    end;

    component_image.vol.fname = [image_directory 'duplicates' filesep image_name ];

    err = cpca_write_vols( component_image );
    if ( ~isempty( err ) )
      return;
    end;
  end;  


  if constant_define( 'PREFERENCES', 'general.fisherXform' )

    x = exist( [ image_directory 'fisher'] , 'dir' );
    if ( x ~= 7 )  % the directory does not exist
      eval( [ 'mkdir ''' image_directory 'fisher'''] );
    end;

    component_image.vol.fname = [image_directory 'fisher' filesep image_name ];

    component_image.image = zeros( prod( component_image.vol.dim ), 1);	% --- storage area for finale written image --
    component_image.image( component_image.ind ) = image_data;		% --- placing data vector into proper positions of mask ---

    for xx = 1:size(component_image.image, 1 )
      component_image.image(xx) = 0.5 * log( (1 + component_image.image(xx) ) / ( 1 - component_image.image(xx) ) );
    end;

    component_image.image = reshape( component_image.image ,component_image.vol.dim);	% --- and reshaping the result to the mask volume dimensions ---

    err = cpca_write_vols( component_image );

  end;


