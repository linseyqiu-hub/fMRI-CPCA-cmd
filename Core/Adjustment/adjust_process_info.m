function info = adjust_process_info()
global process_information

  info = legacy_define( 'process_info' );
  [info.is64bit info.hasCacheDrop info.sudoUser info.isRoot info.HDF5] = system_settings( info.cache_buffer );

  if isfield( process_information, 'sudo' )		info.sudo = process_information.sudo;			end;

  info.control_text = set_control_text();
