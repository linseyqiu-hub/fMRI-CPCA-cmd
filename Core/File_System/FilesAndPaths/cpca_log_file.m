function [log_path log_file] = cpca_log_file()

  log_root = '';
  log_path = '';
  log_file = '';
  if ( ~ispc )

    x = evalc( '!set | grep ''^LOGNAME''' );		% test environment setting LOGNAME=
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
    log_root = 'C:\';					% PC applications will default to C:\
    x = '';
  end;
  
  if ( ~isempty( x ) ) 					% LOGNAME found?
    x = exist( log_root, 'dir' );			% does user home directory exist?
    if ( x ~= 7 )
      return;
    end;

  end;

  x = date();
  x = strrep( x, '-', '_' );

  log_path = [log_root filesep '.cpca'];

  ld = exist( log_path, 'dir' );			% does user log directory exist?
  if ( ld ~= 7 )					% If not, can we create it?
    nld = evalc( ['!mkdir ' log_path ] );
    creation_failed = ~isempty( regexp( nld, 'Permission denied', 'match' ) );
    if ( creation_failed ) 
      log_path = '';
      return;
    end;

  end;

  log_file = [filesep 'cpca' x(3:end) '.log' ];

  log = [ log_path log_file ];				% test log file existence and access
  ld = exist( log, 'file' );				% does user log file exist? 
							% (it had to have been created so permissions okay)
  if ( ld ~= 7 )					% If not, can we create it?
    nld = evalc( ['!touch ' log ] );
    creation_failed = ~isempty( regexp( nld, 'Permission denied', 'match' ) );
    if ( creation_failed ) 
      log_path = '';
      log_file = '';
      return;
    end;

  end;

