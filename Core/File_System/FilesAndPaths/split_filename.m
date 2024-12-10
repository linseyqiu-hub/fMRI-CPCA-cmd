function [name ext] = split_filename( filename )
% --- return the file name and extension for a given full file name

  name = '';
  ext = '';

  xx = find(filename == '.' );
  % --- split the name and extension on the last '.' character
  if size(xx,2) > 0 
    name = filename( 1:xx(size(xx,2))-1 );
    ext  = filename( xx(size(xx,2))+1:end );
  end

