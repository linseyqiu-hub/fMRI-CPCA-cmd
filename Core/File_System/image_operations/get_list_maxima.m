function pindex = get_list_maxima( v, lp )
global vol lst lindex

  vol = v;
  lst = lp;
  pindex = [];

  ndim = sum(size(vol)>0);	% number of dimensions
  vdim = size(vol);
  if (ndim == 2) 
    vdim = [vdim 1];
    ndim = 3; 
  end;

  [lm ln] = size(lst );

  lindex = zeros( 1000,1);

  n_lindex = get_maxima( vdim, ln, 18 );

  for ii = 1:n_lindex
    pindex = [pindex lindex(ii)];
  end;



function ldx_n = get_maxima( vdim, nlist, cc )
global vol lst lindex

  ldx_sz = 1000;
  ldx_n = 0;

  jj = 1;

%  ix = ((int) (list[j]+0.1)); iy = ((int) (list[j+1]+0.1)); iz = ((int) (list[j+2]+0.1));

  for ( ii = 1:nlist )
    x = get_index( lst(jj), lst(jj+1), lst(jj+2), vdim );
    if ( x > 0)
      if ( is_maxima( vdim ,lst(jj), lst(jj+1), lst(jj+2), cc))

        if (ldx_n >= ldx_sz)  ldx_sz = ldx_sz  + 1000; lindex = resize_matrix( lindex, ldx_sz ); end
        ldx_n = ldx_n + 1;
        lindex(ldx_n) = ii;
      end;
    end;

    jj = jj + 3;

  end;




function rtn =  is_maxima( dim, x, y, z, cc )
global vol

  rtn = 0;

  jj = get_index(x,y,z,dim ); if ( jj < 0) return; end;
  cv = vol(jj);

  if (cc >= 6)
    ii = get_index( x+1, y, z,dim ); if ( ii > 0 & vol(ii) > cv) return; end;
    ii = get_index( x-1, y, z,dim ); if ( ii > 0 & vol(ii) > cv) return; end;
    ii = get_index( x, y+1, z,dim ); if ( ii > 0 & vol(ii) > cv) return; end;
    ii = get_index( x, y-1, z,dim ); if ( ii > 0 & vol(ii) > cv) return; end;
    ii = get_index( x, y, z+1,dim ); if ( ii > 0 & vol(ii) > cv) return; end;
    ii = get_index( x, y, z-1,dim ); if ( ii > 0 & vol(ii) > cv) return; end;

  end;

  if (cc >= 18)
    ii = get_index( x+1, y+1, z,dim ); if ( ii > 0 & vol(ii) > cv) return; end;
    ii = get_index( x+1, y-1, z,dim ); if ( ii > 0 & vol(ii) > cv) return; end;
    ii = get_index( x+1, y, z+1,dim ); if ( ii > 0 & vol(ii) > cv) return; end;
    ii = get_index( x+1, y, z-1,dim ); if ( ii > 0 & vol(ii) > cv) return; end;

    ii = get_index( x-1, y+1, z,dim ); if ( ii > 0 & vol(ii) > cv) return; end;
    ii = get_index( x-1, y-1, z,dim ); if ( ii > 0 & vol(ii) > cv) return; end;
    ii = get_index( x-1, y, z+1,dim ); if ( ii > 0 & vol(ii) > cv) return; end;
    ii = get_index( x-1, y, z-1,dim ); if ( ii > 0 & vol(ii) > cv) return; end;

    ii = get_index( x, y+1, z+1,dim ); if ( ii > 0 & vol(ii) > cv) return; end;
    ii = get_index( x, y+1, z-1,dim ); if ( ii > 0 & vol(ii) > cv) return; end;
    ii = get_index( x, y-1, z+1,dim ); if ( ii > 0 & vol(ii) > cv) return; end;
    ii = get_index( x, y-1, z-1,dim ); if ( ii > 0 & vol(ii) > cv) return; end;

  end;


  if (cc == 26)
    ii = get_index( x+1, y+1, z+1,dim ); if ( ii > 0 & vol(ii) > cv) return; end;
    ii = get_index( x+1, y+1, z-1,dim ); if ( ii > 0 & vol(ii) > cv) return; end;
    ii = get_index( x+1, y-1, z+1,dim ); if ( ii > 0 & vol(ii) > cv) return; end;
    ii = get_index( x+1, y-1, z-1,dim ); if ( ii > 0 & vol(ii) > cv) return; end;

    ii = get_index( x-1, y+1, z+1,dim ); if ( ii > 0 & vol(ii) > cv) return; end;
    ii = get_index( x-1, y+1, z-1,dim ); if ( ii > 0 & vol(ii) > cv) return; end;
    ii = get_index( x-1, y-1, z+1,dim ); if ( ii > 0 & vol(ii) > cv) return; end;
    ii = get_index( x-1, y-1, z-1,dim ); if ( ii > 0 & vol(ii) > cv) return; end;
  end;
     
  rtn = 1;


function idx = get_index(x, y, z, dim)
  idx = 0;
  if (x < 1 | x > dim(1) | y < 1 | y > dim(2) | z < 1 | z > dim(3)) 
    idx = -1;
  else 
    idx = ( (z-1) * ( dim(1) * dim(2) ) ) + ( ( y - 1) * dim(1) ) + x;
  end;



function mtx = resize_matrix( omtx, nsz )

  mtx = zeros( nsz ,1);
  sz = prod(size(omtx));
  mtx(1:sz) = omtx;




