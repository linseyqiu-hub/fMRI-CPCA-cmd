function  bar = prep_done_bar( settings )
% creates a simple text progress bar of the format [----     ]
% The bar is not displayed, but returns as a string
%
% settings passed as  struct( 
%    length', 15, 			% length of internal bar
%    space', ' ', 			% character to use as unprocessed percentage
%    indicator', '=',	 		% character to use as processed percentage
%    border', struct( 
%      left', '[', 			% character to use at left border
%      right', ']') 	  		% character to use at right border
% 

  for jj=1:settings.length
    s(jj) = settings.space;
  end;
  bar = [settings.border.left s settings.border.right];

