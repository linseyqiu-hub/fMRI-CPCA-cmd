function print_UR_coefficents( fid, cUR )

  if (fid) fprintf( fid, '\n\nCorrelation coefficients of UR\n------------------------------------------\n' ); end;

  for ii=1:size(cUR,1) 
    z=[]; 
    for jj = 1:size(cUR,2) 
      n = sprintf( '%.2f', cUR(ii,jj) ); 
      y = sprintf( '  %5s', n );
      z = [z y];
    end; 
    if ( fid ) fprintf( fid, '%s\n', z ); end;
  end;

