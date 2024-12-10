function ln = separator_line( len, chr )

  if nargin < 2
    chr = 0;
  else
    chr = chr - 32;
  end;
  
  ln = char(blanks( len ) + chr );

end

% ---  useful characters               
% ---  separator_line( 20, '-' )       separator_line( 20, '=' )     separator_line( 20, '#' )
% ---  --------------------            ====================          ####################
% ---  
% ---  separator_line( 20, '^' )       separator_line( 20, 'v' )     separator_line( 20, '*' )
% ---  ^^^^^^^^^^^^^^^^^^^^            vvvvvvvvvvvvvvvvvvvv          ********************
% ---  
% ---  separator_line( 20, '~' )       separator_line( 20, '/' )     separator_line( 20, '\' )
% ---  ~~~~~~~~~~~~~~~~~~~~            ////////////////////          \\\\\\\\\\\\\\\\\\\\
