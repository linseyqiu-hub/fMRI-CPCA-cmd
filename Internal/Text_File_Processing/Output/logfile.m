function LFil = open_log()
% determines if a cpca log exists - creates on user account if not

  lFil = 0;

  if ( ~ispc )

    x = evalc( '!set | grep LOGNAME | grep -v BASH' );
    x = regexp( x, '=', 'split' );
    x = char(x(2));
    x = x(1,1:length(x)-1);

    logname = ['/home/' x '/.cpca/cpca.log' ];
    LFil = fopen( logname, 'w+' );		% open for append

  end


