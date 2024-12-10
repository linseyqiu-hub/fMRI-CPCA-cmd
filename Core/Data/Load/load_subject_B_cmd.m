function B = load_subject_B_cmd( Gheader, SubjectNo,Zheader, ftag, model )


  if nargin < 4
    ftag = '';
  end

  if nargin < 5
    model = 'G';
  end
  
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
  end
  
  GCName = [ Gpath 'GC_S' num2str(SubjectNo) ftag '.mat'];

  if ~isempty( ftag )
    n = matfile_vars( Gpath, ['GC_S' num2str(SubjectNo) ftag '.mat'], 'B_S*' );
    if isempty(n)
      GCName = [ Gpath 'GC_S' num2str(SubjectNo) '.mat'];
    end
  end

  eval ( [ 'load( GCName, ''B_S' num2str(SubjectNo) ftag ''');'] );
  eval ( [ 'B = B_S' num2str(SubjectNo) ftag ';' ] );

  clear B_S*;

end


