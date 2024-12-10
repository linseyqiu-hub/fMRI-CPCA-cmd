function fn = rotated_output_filename( settings, Model, Components )

%  if ( nargin < 3 ) Components = '#'; end;
  if ( nargin < 2 ) Model = 'G'; end;

%  if ( isnumeric(Components) )
%    fn = [ Model '_nd' num2str(Components) '_' settings.method ];
%  else
%    fn = [ Model '_' Components '_' settings.method ];
%  end;

  fn = [ Model '_' settings.method ];

  if ( settings.defaults.oblique )
    fn = [ fn '_oblique' ];
  else
    fn = [ fn '_orthogonal' ];
  end;

  fn = [ fn '_i' num2str(settings.defaults.iterations) ];

    str = sprintf( '%.2f', settings.defaults.power );
    fn = [ fn '_p' str ];

  if ( ~strcmp( settings.method, 'hrfmax' ) )
    str = sprintf( '%.2f', settings.defaults.gamma );
    fn = [ fn '_g' str ];
  end;

  if ( ~isempty(settings.defaults.text) ) 	% user defined appended text
    fn = [ fn '_'  settings.defaults.text ];
  end;


