function [H HH hh] = load_H_matrix( Hheader, sno )

  H = [];

  if isempty( Hheader.model(Hheader.Hindex).path ) | isempty( Hheader.model(Hheader.Hindex).file ) |  isempty( Hheader.model(Hheader.Hindex).var )  
    return; 
  end;  


  if Hheader.model(Hheader.Hindex).path
    fn =[ Hheader.model(Hheader.Hindex).path Hheader.model(Hheader.Hindex).file ];

  else 

    if Hheader.model(Hheader.Hindex).use_VR

      fn = [ Hheader.model(Hheader.Hindex).path 'Subject_Specific' filesep 'Subject_'  num2str( sno, '%03d' ) filesep Hheader.model(Hheader.Hindex).file ];

    else
      fn = [ Hheader.model(Hheader.Hindex).path 'H_S'  num2str( sno ) '.mat' ];
    end;

  end;

  fe = exist( fn, 'file' );
  if fe ~= 2  return;  end;   				

  load( fn, Hheader.model(Hheader.Hindex).var );

  fe = exist( Hheader.model(Hheader.Hindex).var, 'var' );
  if fe ~= 1  return;  end;   				
  
  if ~strcmp( Hheader.model(Hheader.Hindex).var, 'H' )
    eval( ['H = ' Hheader.model(Hheader.Hindex).var ';'] );
  end;
  
  % --- reorient the H matrix to nvox * ncontrast shape
  if size(H,2) > size(H, 1 )
    H = H';
  end;
  
  HH = H' * H;         
  [u d v] = svd( HH );
  hh = v * inv(sqrt(d)) * u';

