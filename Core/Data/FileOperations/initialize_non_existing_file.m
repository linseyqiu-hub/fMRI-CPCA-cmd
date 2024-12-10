function initialize_non_existing_file( fn )
% --- initialize a mat file and set creation flags if required
% --- 
% --- variables:
% ---    process_date : date of creation
% ---    cpca_version : version of CPCA GUI used
% ---     v_{version} : version number of CPCA GUI used
% --- 
% --- this function will not overwrite any existing file
% --- 

  process_date = date;
  cpca_version = constant_define( 'REVISION' ) ;

  x = strfind( fn, '.mat' );
  if isempty(x)
    fn = [fn '.mat'];
  end;
  
  if ~exist( fn, 'file' )
    eval( ['v_' constant_define( 'VERSION_NUMBER' ) ' = 1;' ] );

    eval( ['save( ''' fn ''', ''process_date'', ''cpca_version'', ''v_*'', ''-v7.3'');' ] );

  end
  