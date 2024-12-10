function box_text( chrs, text, b1, b2, c, title )

  if nargin < 6  title = [];  end
  if nargin < 5  c = 50;      end
  if nargin < 4  b2 = 3;      end
  if nargin < 3  b1 = 3;      end
  
  % --- chrs should be trlb
  if length( chrs) == 1 chrs = repmat( chrs, 1, 4 );  end
  if length( chrs) == 2 chrs = [ chrs chrs(2:-1:1) ]; end
  if length( chrs) == 3 chrs = [ chrs chrs(1) ];      end
  
  disp( separator_line( b1 + b2 + c, chrs(1) ) );
  
  if ~isempty( title )
    disp( [ separator_line( b1, chrs(2) ) center_text( title, c) separator_line( b2, chrs(3) ) ] );
    disp( separator_line( b1 + b2 + c, chrs(1) ) );
  end
  
  if iscell( text )
    for ii = 1:size( text,1)
      disp( [ separator_line( b1, chrs(2) ) center_text(char(text(ii)), c) separator_line( b2, chrs(3) ) ] );
    end
  else
    disp( [ separator_line( b1, chrs(2) ) center_text( text, c) separator_line( b2, chrs(3) ) ] );
  end
  
  disp( separator_line( b1 + b2 + c, chrs(4) ) );
