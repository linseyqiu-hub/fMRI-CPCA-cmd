function update_java_path()
% --- called during startup to set the internal CPCA GUI java apps on the 
% --- dynamic javaclasspath

  jloader = com.mathworks.jmi.ClassLoaderManager.getClassLoaderManager;
  install_apps = '';                             % -- initialize return value to empty
  
  jpath = constant_define( 'JAVA_PATH' ) ;
  japps = constant_define( 'INSTALLED_JAR' ) ;
  
  for thisApp = 1:size( japps, 2 )
    appjar = dir( [jpath  char(japps(thisApp) ) ] );
    if ~isempty( appjar )
      install_apps = [ install_apps; { [ jpath char(japps(thisApp) ) ] } ];
    end;
  end;
    
  if ~isempty(install_apps)
    jloader.setEnabled(1); 
    com.mathworks.jmi.OpaqueJavaInterface.enableClassReloading(1);
    jloader.setClassPath(install_apps);
  end;

