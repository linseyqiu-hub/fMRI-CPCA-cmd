function [txt label_found] = find_entry( fid, label )
% --- find entry labeled onsets.{*}thisEntry
% --- used on generated onstes files only

  label_found = 0;
  txt = '';

  fseek( fid, 0, 'bof' );
  
  while ~feof( fid ) | label_found == 1

    xx = strtrim( char(fgets( fid ) ) );  % or equivalent
    xx = strtrim(strrep( xx, '	', ' '));
  
    if ( length(xx) > 0 ) 			% arbitrary, but allow blank lines with spaces
      if ( xx(1) ~= '%' )			% bypass comments in file

        c = regexp( xx, '=', 'split' );         % --- generated condition onsets are labelled as
        condname = strtrim( char(c(1)) );       % --- onsets.condition_name = [ 1 2 3 4 ...];
        x = strfind( condname, label );
        label_found = ~isempty(x) && prod(size(x)) == 1;
        
        if label_found
          x = strfind( xx, '[' );
          y = strfind( xx, ']' );

          z = regexp( xx, '.*[', 'match' );   	 %  all text to array start char : 's01_run1_condition = ['
          if ~isempty(z)
            xx = char(strrep( xx, z, '' ));
          end

          z = regexp( xx, '].*', 'match' );    	%  all text from array end char : '] ;'
          if ~isempty(z)
            xx = char(strrep( xx, z, '' ));
          end

          txt = xx;
          return;
        end;

      end  % --- comment ---
    end  % --- line text good ---

  end;
