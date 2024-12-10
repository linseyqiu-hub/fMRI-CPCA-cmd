function clear_java_path()
% --- called during startup to clear the dynamic javaclasspath of any
% --- existing CPCA GUI java apps.  These are cleared to insure updates
% --- get loaded at startup.

  jpath = constant_define( 'JAVA_PATH' ) ;  
  japps = constant_define( 'INSTALLED_JAR' ) ;
  
  jcp = javaclasspath( '-dynamic' );
  if ~isempty( jcp )

    for thisApp = 1:size(japps, 2 )
      
      appjar = dir( [jpath  char(japps(thisApp) ) ] );
      if ~isempty(appjar)
        for thisJava = 1:size(jcp, 2 )
          x = strfind( jcp(thisJava), char(japps(thisApp) ) );
          if ~isempty(x)
            eval( ['javarmpath ''' jpath char(japps(thisApp) ) ''';' ] );
          end
        end
        
      end

    end

  end;
  

