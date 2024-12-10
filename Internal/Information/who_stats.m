function f = who_stats( path, fn, mtx )
% find the statistics on a specified matrix variable in a specified file
%
% returns a small struct indicating
%   file_exists 0/1 depending on file actually present
%   mat_exists  0/1 depending on wether matrix variable exists or not
%   mat_x       n   matrix x  dimension 
%   mat_y       n   matrix y  dimension 
%
% eg: g_sz = who_stats( './', 'G.mat', 'G');

  f = struct ( ...
    'file_exists', 0, ...
    'path', '', ...
    'mat_exists', 0, ...
    'mat', '', ...
    'mat_x', 0, ...
    'mat_y', 0 );

  % check file existance
  % --------------------------------------------------------

  % get a list of files in selected directory

  file = [path fn ];
  x=exist( file );
  if x == 2   % the file exists

    f.file_exists = 1;
    f.path = file;

    % now check matrix name existance
    % --------------------------------------------------------
    command = sprintf( 'whos -file ''%s''',file );
    vars = evalc( command );

    sz=size(vars,2);
    command = sprintf( 'value=findstr( vars, '' %s '' );', mtx );
    y = evalc( command );
    if  value > 0 
      f.mat_exists = 1;
      f.mat = mtx;
      f.mat_x = sscanf(vars(value:sz), '%*s%d%d');
      f.mat_y = sscanf(vars(value:sz), '%*s%*d%*c%d');
    end;

  end;



