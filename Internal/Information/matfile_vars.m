function f = matfile_vars( path, fn, variable )
% return a list of variables and their sizes from a specified matlab .mat file
% syntax: f = matfile_vars( path, fn )
% eg: f = matfile_vars( 'Desktop/temp/', 'G_values.mat' );

  if nargin < 3  variable = '';  end;

  f = [];

  file = [path fn ];

  x=exist( file );
  if x == 2   % the file exists

    command = sprintf( 'whos -file ''%s'' ',file );
    c = evalc( [command variable] );
    c1 = regexp( c, '\n', 'split' );
    [cx cy] = size(c1);

    if ( cy > 2 )

      count = 0;


      mat_var = struct ( ...
        'name', '',  ...
        'sz_x', 0, ...
        'sz_y', 0 );

  
      for xx=2:cy 
        if ~isempty(char(c1(xx))) 
          count = count + 1;
          m_var = strtrim(char(c1(xx)));

          s=findstr( ' ', strtrim(m_var) );
          mat_var.name = sscanf( m_var(1:s(1)), '%s' );

          xx=size(m_var );
          m_var=strtrim(m_var(s(1):xx(2) ));
          s=findstr( ' ', strtrim(m_var) );
          mat_var.sz_x = sscanf( m_var, '%d' );
          mat_var.sz_y = sscanf( m_var, '%*d%*c%d' );

          f = vertcat( [f; mat_var ]);    
        end;  % var stats

      end;  % iterate through vars

    end;  % mat file has vars in it

  end;  % mat file exists

