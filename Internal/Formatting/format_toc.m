function tm_str = format_toc( tm, msg )
% formats the toc time into a human readable display
%
% format_toc( (n=toc), message );
% Formats the amount of time from the prior instance of tic
% Will use message as the format description
% eg: 
% format_toc( toc, 'Elapsed Time: ' );
% will display 
%
% Elapsed time:  42 Minutes
% or
% Elapsed time:  1 Hour 42 Minutes
% 
% use the msg 'short' to display time in a short format
% eg 01:25:32  or 25:32

  h=floor(tm/3600);
  if h > 1 hs = 's'; else hs = ''; end;
  m=floor( max(0,tm-(h*3600)) /60 );
  if m > 1 ms = 's'; else ms = ''; end;
  s=floor( max(0,tm-((h*3600)+(m*60)) ) );
  if s > 1 ss = 's'; else ss = ''; end;

  if strcmp( msg, 'short' ) == 1 | strcmp( msg, 'long' ) == 1

    if h > 0 | strcmp( msg, 'long' ) == 1
      tm_str = sprintf( '%02d:%02d:%02d', h, m, s );
    else
      tm_str = sprintf( '%02d:%02d', m, s );
    end;
 
  else
    if h > 0 
      tm_str = sprintf( '%s%02d Hour%c %02d Minute%c %02d Second%c', msg, h, hs, m, ms, s, ss );
    else
      tm_str = sprintf( '%s%02d Minute%c %02d Second%c', msg, m, ms, s, ss );
    end;

  end;

