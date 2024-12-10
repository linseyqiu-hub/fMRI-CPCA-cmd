function [folder filename] = split_path( path, dirchar )
% --- return the folder name and file name given full path filename

  folder = '';
  if nargin < 2
    dirchar = filesep;
  end;
  
  xx = regexp(path, dirchar, 'split' );
  for ( ii = 1:size(xx,2)-1 )
    folder = [folder char(xx(ii)) dirchar];
  end
  filename = char( xx( size(xx,2)) );

