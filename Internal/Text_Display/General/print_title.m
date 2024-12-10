function print_title( title, fid );
% keeps section title displays standard in format 
  if ( nargin < 2 )  fid = 0;  end;

  ln = '-------------------------------------------------------------';
  print_and_log( fid, '\n%s\n%s\n%s\n', ln, title, ln );

