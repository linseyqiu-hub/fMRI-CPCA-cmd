function v = has_H_var( Hheader, module, varname );
global Zheader

  pth = '';
  v = 0;
  if ~isstruct( Hheader )
    return;
  end

  if strcmp( module, 'BH' ) || strcmp( module, 'GC' )
    p = 'GMH';
  else
    p = module;
  end;

  eval( [ 'pth = Hheader.model( Hheader.Hindex).path_to_segs.' p ';' ] );

  mvar = who_stats( pth, [ module '_vars.mat'], varname );
  if ~mvar.mat_exists
    mvar = who_stats( pth, [ module 'mat'], varname );
  end;

  v = mvar.mat_exists;

end


