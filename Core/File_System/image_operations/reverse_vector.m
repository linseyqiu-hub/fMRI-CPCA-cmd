function vec = reverse_vector( I ) 
% takes a 1 x n, or n x 1 vector and flips it
% this function will return the result in the same orientation as the passed vector
%
% if the passed vector is improperly sized, not nx1, 1xn, or n < 2 )
% an error message will be displayed and an empty vector returned

  vec = [];

  % --- parameter must be an n x 1 or 1 x n vector
  x = min(size(I));
  if ( x ~= 1 )				% --- vector improper size ( not n x 1 )
    fprintf( 'reverse_vector: Vector must be n x 1 or 1 x n in size.\n' );
    return;
  
  else
    x = max(size(I));
    if ( x < 2 )			% --- vector improper size (n < 2 )
      fprintf( 'reverse_vector: Vector must be n x 1 or 1 x n in size, where n > 1.\n' );
      return;
    else


      orient = find(size(I) > 1 );	% --- 1 = vertical, 2 = horizontal orientation of vector

      for ii = x:-1:1
        if ( orient == 1 ) vec = [vec; I(ii)]; else vec = [vec I(ii)]; end;
      end;

    end;

  end;


