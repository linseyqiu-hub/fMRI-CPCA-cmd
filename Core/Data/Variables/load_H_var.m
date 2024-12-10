function v = load_H_var( Hheader, Htyp, module, varname );

  v = [];
  if ~isstruct( Hheader )
    return;
  end
  pth = '';
  eval( [ 'pth = Hheader.model( Hheader.Hindex).path_to_segs.' Htyp ';' ] );
  fn = [ module '_vars.mat'];

  mvar = who_stats( pth, fn, varname );
  if ~mvar.mat_exists
    fn = [ module '.mat'];
    mvar = who_stats( pth, fn, varname );
  end;
  
  if mvar.mat_exists
    load( [ pth fn ], varname' );
  end;

  if exist( varname, 'var' )
    eval( [ 'v = ' varname ';'] );
  end;
  
end


