function c = color2text( clr )
% convert a color matrix ( eg: [0.702 0.702 0.702] ) into a textual representation

  c = '';
  [x y] = size( clr );
  if ( y == 3 )
    c = [ '[ ' num2str(clr(1)) ' ' ];
    c = [ c num2str(clr(2)) ' ' ];
    c = [ c num2str(clr(3)) ' ]' ];
  end;

