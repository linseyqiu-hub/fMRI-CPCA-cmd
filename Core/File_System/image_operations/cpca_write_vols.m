function errmsg = cpca_write_vols( img )

%global scan_information

  errmsg = '';
  filename = strrep( img.vol.fname, '.img', '.hdr' );
  cpca_create_vol(img.vol, img.header );

%  if nifti_single_file( img.header )
%    fmode = 'r+';
%  else
    fmode = 'w+';
%  end



  fid = fopen(img.vol.fname,fmode, 'native');
  if ( fid )

%    TYPE=16;
    fwrite(fid,img.image(:),cpca_dt( img.header.datatype ));

    fclose ( fid );
  else
    errmsg = ['unable to create file: ' filename ] ;
  end;


