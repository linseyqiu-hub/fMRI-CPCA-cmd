function img = cpca_read_vol( P, voln )
%function img = cpca_read_vol( P, vols )
% -----------------------------------------------
% borrowed from SPM spm_hread(), spm_vol, spm_slice_vol etc..
%
%  P		file name of image to read ( single image only )
%%  vols		optional parameter - set 1 to return image in slice format
%%		default is to return image as linear horizontal vector
% return 
%  hdr      	image header
%  image    	the retrived image in linear or slice format
%  vol	    	a structure containing image header volume information
% 
% if unable to open or obtain image information, the image will be empty
% and the description of the error will be returned in hdr.error
%
% eg: [hdr image] = read_image_file( this_image );
%     if ( isempty( image )
%        warn( hdr.error );  
%        return;
%     end;
%
%  V - a vector of structures containing image volume information.
%  The elements of the structures are:
%        V.fname - the filename of the image.
%        V.dim   - the x, y and z dimensions of the volume
%        V.dt    - A 1x2 array.  First element is datatype (see spm_type).
%                  The second is 1 or 0 depending on the endian-ness.
%        V.mat   - a 4x4 affine transformation matrix mapping from
%                  voxel coordinates to real world coordinates.
%        V.pinfo - plane info for each plane of the volume.
%               V.pinfo(1,:) - scale for each plane
%               V.pinfo(2,:) - offset for each plane
%                  The true voxel intensities of the jth image are given
%                  by: val*V.pinfo(1,j) + V.pinfo(2,j)
%               V.pinfo(3,:) - offset into image (in bytes).
%                  If the size of pinfo is 3x1, then the volu../../../../Data/example data 1.0.2/example_data_Single_Subject/s01/fsnruna_F001.hdrme is assumed
%                  to be contiguous and each plane has the same scalefactor
%                  and offset.
% -----------------------------------------------

  if nargin < 2  
    voln = 1; 
  end;

  img = new_image_struct();

% -----------------------------------------------
% notes:
% if the scl_slope field is non zero, then each voxel value in the dataset should be scaled as
%  y = scl_slope * value + scl_inter
% -----------------------------------------------

  P     = deblank(P);
  H	= P;
  q     = length(H);
  if q>=4 && H(q - 3) == '.'; H = H(1:(q - 4)); end
  H     = [H '.hdr'];

  [fid, ~] = cpca_open_image( H );			% returns 0 if .hdr file does not exist

  if ( fid > 0 )
    img.header = cpca_read_header( fid );		% read in the associated .hdr file
  else

    [fid, ~] = cpca_open_image( P );		% open the .img or .nii file

    if ( fid > 0 )
      img.header = cpca_read_header( fid );		% read in the header information

      if ( ~ nifti_single_file( img.header ) )	% not flagged as a nifti combined file?
        img.header.error = [ 'no header file associated with image file ' P ];
        return;
      end;

    else
      img.header.error = [ 'unable to open file ' P ];
      return;
    end

  end;

  if ( ~nifti_version( img.header ) )
    [img.header, img.vol] = cpca_analyse_vol(P);      	% retrieve volume information
  else
    img.vol = spm8_vol(P)';
%    [h img.vol] = cpca_nifti_vol(P);        	        % retrieve volume information
  end;

  [~, img.image] = cpca_read_image(P, voln);         		% retrieve the linear image

  % --- trim out any superfluous spaces, or empty fields with a space in them

  img.header.data_type = strtrim( img.header.data_type );
  img.header.db_name = strtrim( img.header.db_name );
  img.header.regular = strtrim( img.header.regular );
  img.header.dim_info = strtrim( img.header.dim_info );
  img.header.description = strtrim( img.header.description );
  img.header.aux_file = strtrim( img.header.aux_file );
  img.header.intent_name = strtrim( img.header.intent_name );
  img.header.magic = strtrim( img.header.magic );

  % --- nifti single file may use extended header information
%  if isfield( h.header, 'nii_ext' )       img.header.nii_ext = h.header.nii_ext;   end;
%  if ( vols > 0 )
%    img.image = reshape( img.image, img.vol.dim );
%  end;

  img.niiSingle = nifti_single_file( img.header );

  img.ind = find( img.image );
  [img.x, img.y] = size( img.ind );
  
