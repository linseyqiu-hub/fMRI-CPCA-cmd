function print_matrix_values( fid, mtx, txt )

  if (fid) fprintf( fid, '\n%s\n------------------------------------------\n', txt ); end;

  for ii=1:size(mtx,1) 
    z=[]; 
    for jj = 1:size(mtx,2) 
      n = sprintf( '%.3f', mtx(ii,jj) ); 
      y = sprintf( '  %6s', n );
      z = [z y];
    end; 
    if ( fid ) fprintf( fid, '%s\n', z ); end;

  end;

