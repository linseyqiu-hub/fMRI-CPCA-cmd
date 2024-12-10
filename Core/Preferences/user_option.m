function sett = user_option( variable )
% --- internal call from constant_define( 'PREFERENCES', {setting} ) 

  sett = [];

  if iscell( variable )
    variable = char( variable );
  end;
  
  if ~isstr( variable)
    return;
  end
  
  optmat = [ constant_define( 'CONFIG_PATH' ) constant_define( 'CONFIG_FILE' ) ];
  if ~exist( optmat, 'file' )
    return;
  end;

  fld = '';
  n = regexp( variable, '\.', 'split' );
  
  load( optmat, 'user_options' );
  if exist( 'user_options', 'var' )

    for ii = 1:size(n,2)
      x = 0;
      eval( ['x = isfield( user_options' fld ', ''' char(n(ii)) ''' );' ] ); 
      if ~x return;  end
      
      fld = [fld '.' char(n(ii)) ];
      
    end
    eval( [ 'sett = user_options.' variable ';' ] );

  end

