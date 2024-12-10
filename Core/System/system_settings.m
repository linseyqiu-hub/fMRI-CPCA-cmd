function [is64bit hasCache sudoUser isRoot HDF5] = system_settings( cache_buffer )
% check matlab installation 
%
% check if matlab is running 64 bit libraries, 
% and if current logged in user has 'sudo' capability

  sudoUser = '';
  is64bit = 1 * abs( isscalar( strfind( eval('computer'), '64') ) );
  
  if isunix
    hasCache =  1 * abs( isscalar( findstr(evalc( strcat('!ls', cache_buffer) ),'No such') ) == 0  );
    env = get_linux_environ();
    sudoUser = env.sudouser;
    isRoot = env.isRoot;
    
  else
    hasCache = 0;
    isRoot = 0;
    sudoUser = '';
  end;

  HDF5 = '';

  if is64bit == 1
    HDF5 = ' -V7.3'; 
  end;


