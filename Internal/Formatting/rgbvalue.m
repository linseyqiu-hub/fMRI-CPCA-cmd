function color_vec = rgbvalue( rgb )
% ---  allows quick conversion of rgb values to a matlab color vector
% ---  usage color = rgb2matlab( [ red green blue ] )

  color_vec = [];

  if length( rgb ) > 1
    color_vec = zeros( 1, 3 );
    for ii = 1:length(rgb)
      color_vec(ii) = rgb(ii) / 255;
    end;
  else
    color_vec = rgb / 255;
  end
  

end

