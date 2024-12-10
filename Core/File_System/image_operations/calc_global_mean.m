function Gm = calc_global_mean( img )
Gm = 0.0;

  M = [1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1];

  n = prod(img.vol.dim(1:2));
  dat = zeros(n, 1);		

  s1 = 0.0;
  m = 0;
  for ii = 1:img.vol.dim(3)		% --- for each plane          --- %

    M(14) = ii;
%    dat = img.image(:,:,ii) ;
%    slice( M, dat, img.vol.dim(1), img.vol.dim(2), img.vol, 0, 0);

    dat = zeros(n,1);
    for jj = 1:n
      dat(jj) = img.image( ( (ii-1) * n) + jj );
    end;

    for ( idx = 1:n )			% --- for each plane index    --- %
      if ( isfinite(dat(idx)))	
        s1 = s1 + dat(idx);		% --- total sum of all planes --- %
        m = m + 1;			% --- number of elements      --- %
      end;
    end;

  end;
  s1 = s1 / (8.0*m);			% --- discount voxels outside of object (mean/8 ) --- %

  Gm=0.0;
  m = 0;
  for ii = 1:img.vol.dim(3)		% --- for each plane          --- %

    M(14) = ii;
%    dat = img.image(:,:,ii) ;
%    dat = slice( img.image, img.vol.dim(1), img.vol.dim(2), M, dat );

    dat = zeros(n,1);
    for jj = 1:n
      dat(jj) = img.image( ( (ii-1) * n) + jj );
    end;


    for ( idx = 1:n )			% --- for each plane index    --- %
      if ( isfinite(dat(idx)) & dat(idx) > s1 )	
        Gm = Gm + dat(idx);		% --- total sum of all planes --- %
        m = m + 1;			% --- number of elements      --- %

      end;
    end;

  end;

  Gm = Gm ./ m;



