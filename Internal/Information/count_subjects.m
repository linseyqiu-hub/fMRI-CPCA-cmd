function n = count_subjects( txtfile )
% count number of valid subjects in a files.txt file
% Linux only

  n = 0;
  
  if isunix
    txtfile = strrep( txtfile, ' ', '?' );  % --- trap spaces in filename and/or path
    n = str2double( evalc( [ '!cat ' txtfile ' | grep scandir | grep -v "%" | grep -c .' ] ) ) ;
  else
    fid = fopen( txtfile, 'r' )
    if fid
      while ~feof( fid )
        ln = fgetl( fid );
        if size( ln,2) > 8 
          if strcmp( 'scandir:', ln(1:8) )
            n = n + 1;
          end;
        end;
      end
      fclose( fid );
    end
  end
end

