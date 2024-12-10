function values = parse_filelist_input( input_line )

  values = [];
  x = struct( 'var', '', 'value', '' );

  line = strrep( input_line, '  ', ' ' );
  e = regexp(strtrim(line), ' ', 'split' );

  for ii = 1:size(e,2)
    thisone = regexp(char(e(ii)), ':', 'split' );
    x.var = strtrim( char( thisone(1) ) );
    x.value = strtrim( char( thisone(2) ) );

    if ( size(thisone,2) > 2 )
      for jj = 3:size(thisone,2)
        x.value = [ x.value ':' strtrim( char( thisone(jj) ) ) ];
      end;
    end;

    values = [values; x];
  end;


