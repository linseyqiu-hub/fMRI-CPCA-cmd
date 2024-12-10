function [img image] = cpca_read_image( P, voln )
%function [hdr image] = cpca_read_image( P )
% -----------------------------------------------
% borrowed from SPM spm_hread()
% will return a structure containing image header volume information
% 
% if unable to open or obtain image information, the image will be empty
% and the description of the error will be returned in hdr.error
%
% eg: [hdr image] = read_image_file( this_image );
%     if ( isempty( image )
%        warn( hdr.error );  
%        return;
%     end;
% -----------------------------------------------

  img = [];

% -----------------------------------------------
% notes:
% if the scl_slope field is non zero, then each voxel value in the dataset should be scaled as
%  y = scl_slope * value + scl_inter
% -----------------------------------------------

  P     = deblank(P);
  H	= P;
  q     = length(H);
  if q>=4 & H(q - 3) == '.'; H = H(1:(q - 4)); end
  H     = [H '.hdr'];

  image = [];

  [fid endian] = cpca_open_image( H );		% returns 0 if .hdr file does not exist

  if ( fid > 0 )
    img.header = cpca_read_header( fid );		% read in the associated .hdr file
  else

    [fid endian] = cpca_open_image( P );	% open the .img or .nii file

    if ( fid < 0 )
      img.header.error = [ 'file corrupted ' P ];
      return;
    else
    
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
    end
  end;

  img.header.endian = endian;

  fid = fopen(P,'r',endian);	
  if (fid > 0)
	
    if ( nifti_single_file( img.header ) )
      fseek( fid, img.header.sizeof_hdr, 'bof' );
      img.header.nii_ext = fread(fid,4,'uchar')';

      vol_offset = (voln - 1 ) * prod( img.header.dim(2:4) );
      fseek( fid, img.header.vox_offset + vol_offset, 'bof' );
    end;

    [SCALE DCOFF] = scaling_values( img.header );

%    image=(fread(fid,prod(hdr.dim(2:4)),spm_5_type(hdr.datatype))*SCALE)+DCOFF;
% --- Logical error on original read scaling
% --- where the scaling was applied to the data type precision and not the value read
% --- resulting in an unpredictable precision value ( uint16, 32 etc... )
% --- from nifti format:
% --- If the scl_slope is non-zero then each voxel value in the dataset should be
% --- scaled as [ y = scl_slope * x + scl_inter ]
% --- where x = voxel value stored, y = 'true' voxel value

    dtyp = cpca_data_type( img.header.datatype );
    src_prec = lower(dtyp.analyse);
    if length( src_prec ) == 0
      src_prec = lower(dtyp.nifti);
    end;

    image=( fread( fid, prod( img.header.dim(2:4) ), src_prec ) );
    if ( SCALE + DCOFF  ~= 0 )
      image = image * SCALE + DCOFF;
    end;

    fclose( fid );

  end;


