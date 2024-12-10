function B = load_subject_B( Gheader, SubjectNo, ftag, model );
global  Zheader

  if nargin < 3
    ftag = '';
  end;

  if nargin < 4
    model = 'G';
  end;
  
  B = [];
  Gpath = '';
  
  if strcmp( model, 'ROI')
    if isfield( Gheader, 'ROIZheader' )
      if isfield( Gheader.ROIZheader, 'path_to_segs' )
        Gpath = Gheader.ROIZheader.path_to_segs;
      else
        Gpath = [Gheader filesep];
      end
    else
      Gpath = [Gheader filesep];
    end
  else
      
    if ~strcmp( model, 'G' )
      load( Zheader.Contrast.path );
      eval( [ 'Gpath = Aheader.model( Aheader.Aindex).path_to_' model ';' ] );
    else
      eval( [ 'Gpath = Gheader.' model 'Zheader.path_to_segs;' ] );
    end
  end;
  
  GCName = [ Gpath 'GC_S' num2str(SubjectNo) ftag '.mat'];

  if ~isempty( ftag )
    n = matfile_vars( Gpath, ['GC_S' num2str(SubjectNo) ftag '.mat'], 'B_S*' );
    if isempty(n)
      GCName = [ Gpath 'GC_S' num2str(SubjectNo) '.mat'];
    end;
  end;

  eval ( [ 'load( GCName, ''B_S' num2str(SubjectNo) ftag ''');'] );
  eval ( [ 'B = B_S' num2str(SubjectNo) ftag ';' ] );

  clear B_S*;

end


