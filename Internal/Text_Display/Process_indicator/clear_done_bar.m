function  bar = clear_done_bar( settings )
% removes a displayed progress bar

  for jj=1:settings.length+2
    fprintf( '\b' );
  end;

