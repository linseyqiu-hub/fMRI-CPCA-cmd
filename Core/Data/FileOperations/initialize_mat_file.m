function initialize_mat_file( fn )
% --- initialize a mat file and set creation flags
% --- 
% --- variables:
% ---    process_date : date of creation
% ---    cpca_version : version of CPCA GUI used
% ---     v_{version} : version number of CPCA GUI used
% --- 
% --- WARNING: this function will overwrite any existing file
% --- 

  process_date = date;
  cpca_version = constant_define( 'REVISION' ) ;

  eval( ['v_' constant_define( 'VERSION_NUMBER' ) ' = 1;' ] );

  x = strfind( fn, '.mat' );
  if isempty(x)
    fn = [fn '.mat'];
  end;
  
  eval( ['save( ''' fn ''', ''process_date'', ''cpca_version'', ''v_*'', ''-v7.3'');' ] );

