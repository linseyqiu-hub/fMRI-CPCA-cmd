function write_log( dt, t1, t2, t3, t4, t5, t6, t7 )
% determines if a cpca log exists - creates on user account if not

  rev = sprintf( '%d.%d(%d)', constant_define( 'REVISION_MAJOR'), constant_define( 'REVISION_MINOR'), constant_define( 'REVISION_EDIT') );

  [path name] = cpca_log_file();
  if ( isempty( path) )  return;  end;		% if permissions errors or environment unaccessible, abort logging

  logname = [path name];
  LFil = fopen( logname, 'a+' );		% open for append

  ln  = '% -------------+----------------------------------------------------------------------';
  fprintf( LFil, '\n%s\n', ln );

  str = sprintf( '%% %12s : %s', dt, t1 );
  fprintf( LFil, '%s\n', str );


  if ( nargin > 2 )    if (~isempty(t2)) 	place_in_log( LFil, t2, rev );   end;	end;
  if ( nargin > 3 )    if (~isempty(t3)) 	place_in_log( LFil, t3 );   end;	end;
  if ( nargin > 4 )    if (~isempty(t4)) 	place_in_log( LFil, t4 );   end;	end;
  if ( nargin > 5 )    if (~isempty(t5)) 	place_in_log( LFil, t5 );   end;	end;
  if ( nargin > 6 )    if (~isempty(t6)) 	place_in_log( LFil, t6 );   end;	end;
  if ( nargin > 7 )    if (~isempty(t7)) 	place_in_log( LFil, t7 );   end;	end;


function place_in_log( LOG, txt, rev )

  if ( nargin < 3 ) rev = ''; end;
  if ( iscell( txt ) )
    for ii = 1:size(txt,1)		% place each row of cell as new log line entry
      fprintf( LOG, '%% %8s     :  - %s\n', rev, char(txt(ii,1)) );
    end;
  else
    fprintf (  LOG, '%% %8s     :  - %s\n', rev, txt );
  end;
