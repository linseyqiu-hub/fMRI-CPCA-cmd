function mtyp = cpca_xyzt_type( xyzt )

  mtyp = '?/?';

  mt = [{'?'} {'?'}];
  mtypes = cpca_xyzt_types();
  bmsk = [ 7 56 ];

  for ii = 1:size(bmsk, 2 )
    msk = bmsk(ii);
    xy = bitand( xyzt, msk );

    for ( jj = 2:size(mtypes,1) )
      if ( mtypes(jj).code == xy )
        mt(ii) = {mtypes(jj).type};
        break;
      end;
    end;
  end;

  mtyp = [ char(mt(1)) '/' char(mt(2)) ];


