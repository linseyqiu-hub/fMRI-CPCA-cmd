function retrieve_subject_G( Gheader, SubjectNo, RunNo, mulA )
global Zheader 

  if nargin < 3
    RunNo = 0;
  end;

  if nargin < 4
    mulA = [];
  end
  
  assignin( 'caller', 'G', [] );

  Gnorm = '';
  if RunNo == 0
    load( [ Gheader.path_to_segs Gheader.prefix '_S' num2str(SubjectNo) '.mat'],  'Gnorm');
  else
    gvar = ['G_R' num2str(RunNo)];
    load( [ Gheader.path_to_segs Gheader.prefix '_S' num2str(SubjectNo) '.mat'],  gvar );
    if exist( gvar, 'var' );
      eval( ['Gnorm = ' gvar ';' ] );
    end;
  end;

  
  if exist( 'Gnorm', 'var' );
      
    if ~isempty(mulA) & Zheader.Contrast.mat_exists 
      load( Zheader.Contrast.path );
      load( Aheader.model( Aheader.Aindex).path, Aheader.model( Aheader.Aindex).var );
      eval( [ 'Gnorm = Gnorm * ' Aheader.model( Aheader.Aindex).var ';' ] );
    end;
      
    assignin( 'caller', 'G', Gnorm );
  end;

end 
