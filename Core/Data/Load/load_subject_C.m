function C = load_subject_C( Gheader, SubjectNo, ftag, model )
global Zheader

  if nargin < 3
    ftag = '';
  end;

  if nargin < 4
    model = 'G';
  end;
  
  C = [];
  Gpath = '';
 
  if ~strcmp( model, 'G' )
    load( Zheader.Contrast.path );
    eval( [ 'Gpath = Aheader.model( Aheader.Aindex).path_to_' model ';' ] );
  else
    eval( [ 'Gpath = Gheader.' model 'Zheader.path_to_segs;' ] );
  end
%  eval( [ 'Gpath = Gheader.' model 'Zheader.path_to_segs;' ] );
  
  GCName = [ Gpath 'GC_S' num2str(SubjectNo) ftag '.mat'];

  if ~isempty( ftag )
    n = matfile_vars( Gpath, ['GC_S' num2str(SubjectNo) ftag '.mat'], 'C_S*' );
    if isempty(n)
      GCName = [ Gpath 'GC_S' num2str(SubjectNo) '.mat'];
    end;
  end;

  eval ( [ 'load( GCName, ''C_S' num2str(SubjectNo) ftag ''');'] );
  eval ( [ 'C = C_S' num2str(SubjectNo) ftag ';' ] );

  clear C_S*;

end


