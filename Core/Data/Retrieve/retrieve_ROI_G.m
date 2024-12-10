function retrieve_ROI_G( SubjectNo, RunNo )

  if nargin < 2
    RunNo = 0;
  end;

  load G_ROI
  Gpath = [ 'ROI' filesep strrep( G_ROI.mask( G_ROI.Rindex).id, ' ', '_' ) filesep 'Gsegs' filesep]; 
  assignin( 'caller', 'G', [] );

  if RunNo == 0
    n =  who_count( Gpath, ['G_S' num2str(SubjectNo) '.mat'], 'G_R*' );
    Gnorm = [];
    
    for ii = 1:n  
      load( [ Gpath 'G_S' num2str(SubjectNo) '.mat'],  ['G_R' num2str(ii)] );
      eval( [ 'Gnorm = [Gnorm; G_R' num2str(ii) '];' ] );
    end
    
  else
    gvar = ['G_R' num2str(RunNo)];
    load( [ Gpath 'G_S' num2str(SubjectNo) '.mat'],  gvar );
    if exist( gvar, 'var' );
      eval( ['Gnorm = ' gvar ';' ] );
    end;
  end;

  
  if exist( 'Gnorm', 'var' );
      
    assignin( 'caller', 'G', Gnorm );
  end;

end 
