function [done bar] = proc_done_bar( count, max, settings, prevdone )
% syntax: [done bar] = proc_done_bar( count, max, settings, prevdone )
%
% count is the current iteration count of your percentile loop
% max is the maximum number of literations
% settings is the display definition structure ( see prep_done_bar )
% prevdone is the done value returned by a prvious call to proc_done_bar
%
% returns the value of the current percentage done, and the updated visual display 
%
% To avoid annoying flicker of display, if the percentage display remains unchanged, then
% the return display is of 0 length. Display will contain the characters needed
% to erase the former display.
%

  bar = '';
  done = floor((1/(max/count))*settings.length);

  if  done > prevdone 
    remain=settings.length-done;
    s1='';
    s2='';
    if ( done > 0 )
      for jj=1:done
        s1(jj) = settings.indicator;
      end;
    end;
    if ( remain > 0 )
      for jj=1:remain
        s2(jj) = settings.space;
      end;
    end;
    for jj=1:settings.length+1
      fprintf( '\b' );
    end;

    bar = [s1 s2 settings.border.right];  
  end;



