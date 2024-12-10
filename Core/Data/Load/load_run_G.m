function  [G gg] = load_run_G( Gheader, SubjectNo, RunNo, mulA )
  global Zheader scan_information
  
  if nargin < 4
    mulA = [];
  else
    if mulA == 0   % --- older code used a strcmp( model, typ ) reference
      mulA = [];
    end;
  end
  

  G = [];
  gg = [];

  if RunNo == 0
    % ---  use RunNo = 0 to load full subject G
    load( [ Gheader.path_to_segs Gheader.prefix '_S' num2str(SubjectNo) '.mat'], 'Gnorm', 'gg');
    eval( ['G = Gnorm;' ] );
  else
    load( [ Gheader.path_to_segs Gheader.prefix '_S' num2str(SubjectNo) '.mat'], ['G_R' num2str(RunNo)], 'gg');
    eval( ['G = G_R' num2str(RunNo) ';' ] );
  end;
  
  if ~isempty(mulA) & Zheader.Contrast.mat_exists 
      
    load( Zheader.Contrast.path );
    load( Aheader.model( Aheader.Aindex).path, Aheader.model( Aheader.Aindex).var );
    eval( [ 'G = G * ' Aheader.model( Aheader.Aindex).var ';' ] );

    load( [Aheader.model( Aheader.Aindex).path_to_G 'GA_S' num2str(SubjectNo) '.mat'], 'gg');
    
  end;

  
end 
