function p = cpca_path();
% --- 
% --- return path to current installed CPCA GUI

  p = '';
  
  ph = which(  'cpca' );
  ph = strrep( ph, 'cpca.m', '' );
  
  if ~isempty(ph );
    p = ph;
  end
  
end


