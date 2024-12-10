function H_matrix_header( Hheader, fid )

  if ( fid )  
    fprintf( fid, '\n------------------------------------------\n' );
    fprintf( fid, '  H Model: \t %d of %d \t(%s)\n', Hheader.Hindex, size(Hheader.model, 1 ), ...
                                                Hheader.model(Hheader.Hindex).id ); 
    fprintf( fid, '         : \t [%s %s]\t(%s)\n', num2str(Hheader.model(Hheader.Hindex).size(1)), ...
                                              num2str(Hheader.model(Hheader.Hindex).size(2)), ...
                                              Hheader.model(Hheader.Hindex).file );
  end;

