function flag = nifti_single_file( h )
  flag = 0;

  if isfield( h, 'magic' )		% is this a nifti format?
    flag = ( length( h.magic ) > 2 & h.magic(2) == '+' );
  end;

