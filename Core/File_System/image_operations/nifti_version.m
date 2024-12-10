function v = nifti_version( h )

  v = 0;

  if isfield( h, 'magic' )		% is this a nifti format?
    if ( ( length(h.magic) > 2 & h.magic(1) == 'n' ) & ...
       ( h.magic(2) == 'i' | h.magic(2) == '+' ) & ...
       ( h.magic(3) >= '1' & h.magic(3) <= '9' ) ...
        )
      v = h.magic(3)-'0'; 
    end;
  end;

