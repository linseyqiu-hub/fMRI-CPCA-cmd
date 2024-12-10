function rev = cpca_revision_number( r )

  rev = '';

  if nargin == 0  r = constant_define( 'REVISION' ); end;

  if isstruct( r )
    if ( length( constant_define( 'REVISION_RELEASE' ) ) > 0 )
      if ( length( constant_define( 'REVISION_RELEASE' ) ) > 1 )
        rev = sprintf( 'cpca %.1f.%d(%02d)%s', r.major, r.minor, r.edit, r.release );
      else
        rev = sprintf( 'cpca %.1f.%d(%02d)%c', r.major, r.minor, r.edit, r.release );
      end;
    else
      rev = sprintf( 'cpca %.1f.%d(%02d)', r.major, r.minor, r.edit );
    end;

  else

    if ischar( r )
      if length( r ) == 6 
        rev = sprintf( 'cpca %.1f.%d(%02d)', hex2dec(r(1:2))/10, hex2dec(r(3:4)), hex2dec(r(5:6)) );
      end;

    end;

  end;



