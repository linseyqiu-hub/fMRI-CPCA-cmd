function s = format_percentages( V, P, fmt)
% --- returns the 2 values P and P/V*100 formatted by fmt
% --- example format_percentages( 100, 20, '%.2f (%.1f%%)'  
% ---    returns '20.00 (20.0%)'
%   Detailed explanation goes here

  if V > 0
    if P > 0
       s = sprintf( fmt, P, P/V*100 );   
    else    
       s = sprintf( fmt, P, 0 );   
    end;
  else
    s = sprintf( fmt, P, 0 );   
  end;

end

