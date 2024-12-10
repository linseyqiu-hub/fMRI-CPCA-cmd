function retrieve_subject_G_cmd( Gheader, Zheader, SubjectNo, RunNo, mulA )

  if nargin < 4
    RunNo = 0;
  end

  if nargin < 5
    mulA = [];
  end
  
  assignin( 'caller', 'G', [] );

  Gnorm = '';
  if RunNo == 0
    load( [ Gheader.path_to_segs Gheader.prefix '_S' num2str(SubjectNo) '.mat'],  'Gnorm');
  else
    gvar = ['G_R' num2str(RunNo)];
    load( [ Gheader.path_to_segs Gheader.prefix '_S' num2str(SubjectNo) '.mat'],  gvar );
    if exist( gvar, 'var' )
      eval( ['Gnorm = ' gvar ';' ] );
    end
  end

  
  if exist( 'Gnorm', 'var' )
      
    if ~isempty(mulA) & Zheader.Contrast.mat_exists 
      load( Zheader.Contrast.path );
      load( Aheader.model( Aheader.Aindex).path, Aheader.model( Aheader.Aindex).var );
      eval( [ 'Gnorm = Gnorm * ' Aheader.model( Aheader.Aindex).var ';' ] );
    end
      
    assignin( 'caller', 'G', Gnorm );
  end

end 
