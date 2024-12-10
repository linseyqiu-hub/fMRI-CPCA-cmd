function v = load_subject_GC_var_cmd( Gheader, Zheader, SubjectNo, varname, model )

  if nargin < 5
    model = 'G';
  end
  
  Gpath = '';
  if strcmp( model, 'ROI' )
    Gpath = Gheader;
  else
    if ~strcmp( model, 'G' )
      load( Zheader.Contrast.path );
      eval( [ 'Gpath = Aheader.model( Aheader.Aindex).path_to_' model ';' ] );
    else
      eval( [ 'Gpath = Gheader.' model 'Zheader.path_to_segs;' ] );
    end
  end
  
  v = [];
  GCName = [ Gpath 'GC_S' num2str(SubjectNo) '_vars.mat'];

  if ~exist( GCName, 'file' )  % -- older file system
    GCName = [ Gpath 'GC_S' num2str(SubjectNo) '.mat'];
  end

  if ~exist( GCName, 'file' )  % -- GAA process
    GCName = [ Gpath 'GAAB_S' num2str(SubjectNo) '_vars.mat'];
  end
  
  load( GCName, varname );
  if exist( varname, 'var' )
    eval ( [ 'v = ' varname ';' ] );
  end

end


