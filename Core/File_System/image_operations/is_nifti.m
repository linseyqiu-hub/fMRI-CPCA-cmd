function v = is_nifti( magic )

  v = 0;

   if ( ( length(magic) > 2 & magic(1) == 'n' ) & ...
     ( magic(2) == 'i' | magic(2) == '+' ) & ...
     ( magic(3) >= '1' & magic(3) <= '9' ) ...
      )
    v = magic(3)-'0'; 
  end;

