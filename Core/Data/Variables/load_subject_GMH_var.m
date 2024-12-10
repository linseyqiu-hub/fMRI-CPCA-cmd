function v = load_subject_GMH_var( Hheader, SubjectNo, varname, module );

  v = 0;
  if ~isstruct( Hheader )
    return;
  end

  pth = Hheader.model( Hheader.Hindex).path_to_segs.GMH;
  fn = [ module '_S' num2str(SubjectNo) '_vars.mat'];

  mvar = who_stats( pth, fn, varname );
  
  if ~mvar.mat_exists
    fn = [ module '_S' num2str(SubjectNo) '.mat'];
    mvar = who_stats( pth, fn, varname );
  end;

  if mvar.mat_exists
    load( [pth fn], varname );
  end;
  
  if exist( varname, 'var' )
    eval( [ 'v = ' varname ';'] );
  end;
  
end


