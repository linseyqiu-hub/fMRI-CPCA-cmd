function v = load_subject_BH_var( Hheader, SubjectNo, varname, module, ex_var );
global Zheader

  v = [];
  pth = '';
  if ~isstruct( Hheader )
    return;
  end

  if strcmp( module, 'BH' ) || strcmp( module, 'GC' ) 
    p = 'GMH';
    if strcmp( module, 'BH' )
      module = 'HnotG';
    end
  else
    p = module;
  end;

  % --- non module name files will be passed as optional variable
  % --- module path will retain original module definition in pth
  if nargin == 5
    module = ex_var;
  end;
  
  eval( [ 'pth = Hheader.model( Hheader.Hindex).path_to_segs.' p ';' ] );

  fn = [ module '_S' num2str(SubjectNo) '_vars.mat'];
  mvar = who_stats( pth, fn, varname );

  if ~mvar.mat_exists
    fn = [ module '_vars.mat'];
    mvar = who_stats( pth, fn, varname );
  end
  
  if ~mvar.mat_exists
    fn = [ module '_S' num2str(SubjectNo) '.mat'];
    mvar = who_stats( pth, fn, varname );
  end;

  if ~mvar.mat_exists
    fn = [ module '.mat'];
    mvar = who_stats( pth, fn, varname );
  end;
  
  
  if mvar.mat_exists
    load( [pth fn], varname );
    if exist( varname, 'var' )
      eval ( [ 'v = ' varname ';' ] );
    end;

  end


