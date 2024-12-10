function v = has_GMH_var( Hheader, module, varname );
global Zheader

  v = 0;
  if ~isstruct( Hheader )
    return;
  end

  pth = Hheader.model( Hheader.Hindex).path_to_segs.GMH;

  mvar = who_stats( pth, [ module '_vars.mat'], varname );
  if ~mvar.mat_exists
    mvar = who_stats( pth, [ module '.mat'], varname );
  end
  
  v = mvar.mat_exists;

end


