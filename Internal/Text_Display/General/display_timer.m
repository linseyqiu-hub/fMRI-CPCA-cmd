function display_timer( t, label, show_title, show_divider, fid )
% syntax ( display_timer( timer, label {,show_title, show_divider} );
%
% displays the result of timer structure
% start time, end time duration (in minutes/seconds )
%
% struct timers:
%  timing_stats = struct ( 'start_time', 0, 'end_time', 0, 'duration', 0 );
%  timers = struct ( 'Normalize', timing_stats, 'ApplyG', timing_stats, 'Extract', timing_stats );
%  
% to time an operation, create the timers with the appropriate name
%    tic
%    timers.Normalize.start_time = clock;
%      ... process ...
%    timers.Normalize.end_time = clock;
%    timers.Normalize.duration = toc;
%    display_timer ( timers.Normalize, 'Normalize', 1 );	% force the title labels on first item
%    display_timer ( timers.ApplyG, 'Apply G' );		% default is no title label text

 if ( nargin < 3 ) 	show_title = 0;			end;
 if ( nargin < 4 ) 	show_divider = show_title;	end;
 if ( nargin < 5 )  	fid = 0;  			end;

 if ( show_title )
   print_and_log( fid, '  Process        \tstart\t\tend\t\tDuration\n' );
 end;

 if ( show_divider )
   print_and_log( fid, '---------------------------------------------------------------------------\n');
 end;

 st = datestr(t.start_time);
 st = regexp(st, ' ', 'split' );

 en = datestr(t.end_time);
 en = regexp(en, ' ', 'split' );

 dur = floor(t.duration/60);
 mins = 'Minute';
 if dur > 1 mins = [mins 's']; end;

 sec = floor(mod(t.duration, 60));
 secs = 'Second';
 if sec > 1 secs = [secs 's']; end;

 print_and_log( fid, '%16s\t%s\t%s\t%d %s %d %s\n', label', char(st(2)), char(en(2)), dur, mins, sec, secs );


