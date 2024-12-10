function create_new_image( data, filename, mask )
% create_new_image( data, filename, mask )

%to produce an image from the voxel data

%mask = source_mask;

%produce the Z voxel index into the mask
mask.ind = find( mask.image );

%  use the original mask from scan reading
component_image = mask; 


component_image.image = zeros( prod( component_image.vol.dim ), 1);	% --= storage area for final written image --
component_image.image( component_image.ind ) = data;		% --= placing data vector into proper positions of mask ---
component_image.image = reshape( component_image.image ,component_image.vol.dim); % --= and reshaping the result to the mask volume dimensions ---

dtyp = cpca_data_type( 'double' ); % --= 
src_prec = dtyp.analyse; % --= 
if length( src_prec ) == 0 % --= 
  src_prec = dtyp.nifti; % --= 
end; % --= 

if isBigendian()  en = 'LE'; else en = 'BE'; end; % --= 
dtype = [src_prec '-' en]; % --= 

component_image.vol.dt = [dtyp.conversion isBigendian()];		% --= we default data type to signed double (float 64 )
component_image.header.datatype = dtyp.conversion; % --= 
component_image.header.bitpix = dtyp.bits; % --= 

component_image.vol.fname = filename; % --= 

if isfield( component_image.header, 'scl_slope') % --= 
  component_image.header.scl_slope = 1; % --= 
end; % --= 

component_image.vol.pinfo(1) = 1; % --= 
component_image.vol.private.dat.dtype = dtype; 

err = cpca_write_vols( component_image ); % --= 
if ( ~isempty( err ) )
  show_message( 'Image Write Error', err );
end;



