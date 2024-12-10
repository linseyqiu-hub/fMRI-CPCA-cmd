function s = format_value( V, fmt)
% --- returns the V and formatted by fmt or blank string

  s = '';
  
  if isinf( V) 
    s = 'Inf';
    return;
  end

  if isnan( V) 
    s = 'NaN';
    return;
  end
  
  if V > 0
     s = sprintf( fmt, V);   
  end;

end

