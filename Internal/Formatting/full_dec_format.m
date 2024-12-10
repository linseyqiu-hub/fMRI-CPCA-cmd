function fmt = full_dec_format( max_dec )

  ln = size(num2str(max_dec), 2);
  sZero = '';
  
  if ln > 1
    sZero = [ '0' num2str(ln) ];
  end;
  
  fmt = [ '%' sZero 'd' ];

end

