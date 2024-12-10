function f = who_count( path, fn, spec )
% find the statistics on a specified matrix variable in a specified file
%
% returns a small struct indicating
%   file_exists 0/1 depending on file actually present
%   spec_exists  0/1 depending on wether matrix variable ?*
%
% eg: g_sz = who_stats( './', 'G.mat', 'G');

  f = 0;

  % check file existance
  % --------------------------------------------------------

  % get a list of files in selected directory

  file = [path fn ];
  x=exist( file );
  if x == 2   % the file exists

    % now check matrix name existance
    % --------------------------------------------------------
    command = sprintf( 'whos -file ''%s'' %s',file, spec );
    vars = evalc( command );
    
    n = strfind( spec, '*' );  % -- check vars for non wildcarded begining of varspec
    if ~isempty( n )
      spec = spec(1:n(1)-1);
    end
        
    command = sprintf( 'value=strfind( vars, '' %s'' );', spec );
    y = evalc( command );
    f = size(value,2);

  end;



