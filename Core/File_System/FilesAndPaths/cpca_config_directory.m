function log_path = cpca_config_directory()
% ---
% --- return path to CPCA GUI user configuration directory
% ---   Linux :  ~/.cpca
% ---   Mac   :  /Users/{user}/.cpca
% ---   PC    :  C:\CnosLab


  log_root = '';
  log_path = '';

  dn = '.cpca';						% directory name on MAC and Linus is .cpca

  if ( ~ispc )

    x = evalc( '!set | grep ''^SUDO_USER''' );
    if isempty( x)
      x = evalc( '!set | grep ''^LOGNAME''' );		% test environment setting LOGNAME=
    end;
    if isempty( x)
      x = evalc( '!env | grep ''^LOGNAME''' );		% tcsh for fressufrfer requires env rather than set
    end
    
    if ( ~isempty( x ) ) 				% LOGNAME found?
      if ( ismac ) log_root = '/Users/'; else log_root = '/home/'; end;	

      x = regexp( x, '=', 'split' );
      if ( size(x,2) == 2)      			% env setting discovered
        x = char(x(2));					% retrieve the environment setting value
        x = x(1,1:length(x)-1);				% strip off CRLF
        log_root = [ log_root x ];			% create final destination path name
      end;

    end;

    if ( isempty( log_root ) ) 				
      return;
    end;
  
  else
    log_root = 'C:';			% PC applications will default to C:\
    dn = 'CNoSLab';					% directory name on PC is CNosLab
    x = ' ';
  end;
  
  if ( ~isempty( x ) ) 					% LOGNAME found?
    x = exist( log_root, 'dir' );			% does user home directory exist?
    if ( x ~= 7 )
      return;
    end;

  end;

  x = date();
  x = strrep( x, '-', '_' );

  log_path = [log_root filesep dn];

  ld = exist( log_path, 'dir' );			% does user log directory exist?
  if ( ld ~= 7 )                            % If not, can we create it?
    if ~ispc
      nld = evalc( ['!mkdir ' log_path ] );
      creation_failed = ~isempty( regexp( nld, 'Permission denied', 'match' ) );
      if ( creation_failed ) 
        log_path = '';
        return;
      end;
    else
      mkdir( log_path );
      ld = exist( log_path, 'dir' );			% does user log directory exist?
      if ( ld ~= 7 )                            % If not, can we create it?
        log_path = '';
        return;
      end;
    end
  end;

