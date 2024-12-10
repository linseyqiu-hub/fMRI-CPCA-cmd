function nm = validate_numeric_entry( str )

  nm = ''; 
  x = regexp( str, '[0-9\.]', 'match' );
  for ii = 1:size(x,2); 
    nm = [nm char(x(ii))]; 
  end;


