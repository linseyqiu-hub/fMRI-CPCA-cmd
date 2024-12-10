function GC = load_subject_GC_run_cmd( Gheader,Zheader, SubjectNo, RunNo, ftag, model )

  if nargin < 5
    ftag = '';
  end

  if nargin < 6
    model = 'G';
  end
  
  GC = [];
  Gpath = '';

  if ~strcmp( model, 'G' )
    load( Zheader.Contrast.path );
    eval( [ 'Gpath = Aheader.model( Aheader.Aindex).path_to_' model ';' ] );
  else
    eval( [ 'Gpath = Gheader.' model 'Zheader.path_to_segs;' ] );
  end
  GCName = [ Gpath 'GC_S' num2str(SubjectNo) ftag '.mat'];


  load( GCName, ['GC_R' num2str(RunNo) ftag ] );
  if exist( ['GC_R' num2str(RunNo) ftag ], 'var' )
    eval ( [ 'GC = GC_R' num2str(RunNo) ftag ';' ] );
    clear GC_R*;

  else
    % --- GC variable may not have been preserved, load in G and C and calc if possible
    retrieve_subject_G_cmd( Gheader, Zheader, SubjectNo, RunNo );
    C = load_subject_C_cmd( Gheader, Zheader, SubjectNo, ftag, model );

    if ~isempty( G ) && ~isempty( C)
      if strcmp( model, 'G' )
        GC = G * C;
      else
        load( Aheader.model(Aheader.Aindex).path, Aheader.model(Aheader.Aindex).var );
        eval( [ ' GC = (G * ' Aheader.model(Aheader.Aindex).var ' ) * C; '] );
      end
    end
  end

end


