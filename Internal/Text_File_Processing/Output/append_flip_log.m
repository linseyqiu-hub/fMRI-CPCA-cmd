function append_flip_log( logfile, txt )

  if nargin < 2  return;  end;

  if ~exist( logfile, 'file' )
    fid = fopen( logfile, 'w');
    if fid
      fprintf( fid, '%% --- flipped components log\n' );
      fprintf( fid, '%% --- ------------------------------------------------------------\n' );
    end;
    
  else    
    fid = fopen( logfile, 'a');
  end;
  
  if fid
    thisVer = [' - ' constant_define( 'REVISION_NUMBER') ': '];
    pdat = date;
    x = fix(clock);
    y = sprintf( ' %02d:%02d', x(4), x(5) );
    fprintf( fid, [ '\n' pdat y thisVer txt '\n' ] ); 

    fclose( fid );
  end;



