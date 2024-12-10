function yesno = user_options_set()

  yesno = 0;

  optmat = [ constant_define( 'CONFIG_PATH' ) constant_define( 'CONFIG_FILE' ) ];
  yesno = exist( optmat, 'file' ) > 0;


%  optmat = [ constant_define( 'CONFIG_PATH' ) constant_define( 'CONFIG_FILE' ) ];
%  if ~exist( optmat, 'file' )
%    return;
%  end;
%
%  load( optmat, 'user_options' );
% eval( [ 'user_options.' variable ' = ' data '; ] );
%  save( optmat, 'user_options' );
  
