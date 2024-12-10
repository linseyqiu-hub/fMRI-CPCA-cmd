function txt = next_variable( fid )

  text_found = 0;
  txt = '';

  while ~feof( fid ) | text_found == 1

    xx = strtrim( char(fgets( fid ) ) );  % or equivalent
    xx = strtrim(strrep( xx, '	', ' '));
  
    if ( length(xx) > 0 ) 			% arbitrary, but allow blank lines with spaces
      if ( xx(1) ~= '%' )			% bypass comments in file

%        z = regexp( xx, '.*[', 'match' );   	 %  all text to array start char : 's01_run1_condition = ['
%        if ~isempty(z)
%          xx = char(strrep( xx, z, '' ));
%        end
%
%        z = regexp( xx, '].*', 'match' );    	%  all text from array end char : '] ;'
%        if ~isempty(z)
%          xx = char(strrep( xx, z, '' ));
%        end

        if ( length(strtrim(xx)) > 0 ) 	% arbitrary, but allow blank lines with spaces
          txt = xx;
          text_found = 1;
          return;
        end;

      end  % --- comment ---
    end  % --- line text good ---

  end;
	
