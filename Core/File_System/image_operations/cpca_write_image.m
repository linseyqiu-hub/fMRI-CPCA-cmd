function errmsg = cpca_write_image( img )
% write out a voxel image file for mricron
% write operation dependant upon proper mask loaded via GUI
% returns [stats error] on write
%
% stats is a structure containing
%  loadings: n
%  min_value: n
%  max_value: n
%
% syntax:
% err = cpca_write_image( filename, data )
% if ~isempty( err )
%   display error message
%   abort or return etc...
% end;

global scan_information

  errmsg = '';

  % ------------------------------------------
  % retrieve the mask volume information
  % ------------------------------------------
  if ( isempty( img.file ) )
    errmsg = ['No mask file found for writing image ' filename ];
    return;
  end;

  % ------------------------------------------
  % retrieve the mask 
  % ------------------------------------------
  if ( isempty( img.image ) )
    errmsg = ['No mask image found for writing image ' filename ];
    return;
  end;

  % ------------------------------------------
  % flag mask file format nifti or analyse
  % ------------------------------------------
  is_nii = nifti_version( img.header ) ~= 0;

  if ( is_nii )

    % ------------------------------------------
    % interesting logic in spm_write_vol
    % if the pinfo(1) field is non zero, the image will not be rescaled
    % which may result in a file full of zero values being written
    % setting pinfo(1) to zero will cause the image to be rescaled using the 
    % default values of [1 0 0];
    % ------------------------------------------

    spm_create_vol(img.vol);
    spm_write_vol(img.vol,img.image);

  else

    [DIM VOX SCALE TYPE OFFSET ORIGIN DESCRIP] = spm_5_hread(scan_information.mask.file);

    fid = fopen(img.vol.fname,'w');
    if ( fid )
      TYPE=16;
      fwrite(fid,img.image,spm_5_type(TYPE));
      [s] = spm_5_hwrite(img.vol.fname,DIM,VOX,SCALE,TYPE, OFFSET,ORIGIN,DESCRIP);
      fclose ( fid );
    end;
  
  end;

