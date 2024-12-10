function haslog = has_log()
% determines if a cpca log exists - creates on user account if not

  if ( ~ispc )

    x = evalc( '!set | grep LOGNAME | grep -v BASH' );
    x = regexp( x, '=', 'split' );
    x = char(x(2));
    x = x(1,1:length(x)-1);

    pfn = ['/home/' x '/.cpca' ];
    x = exist( pfn, 'dir' );
    if ( x ~= 7 )
      eval( [ '!mkdir ' pfn ] );
      eval( [ '!touch ' pfn '/cpca.log' ] );
    end;

  end

  x = exist( pfn, 'dir' );
  haslog = x == 7 ;

