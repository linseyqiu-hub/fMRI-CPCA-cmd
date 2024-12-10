function [spc tim] = xyzt_to_space_time( xyzt )
  
  spc = bitand( xyzt, 7 );
  tim = bitand( xyzt, 56 );

