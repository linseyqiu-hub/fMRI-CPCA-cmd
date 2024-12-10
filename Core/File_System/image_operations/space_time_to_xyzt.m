function xyzt = space_time_to_xyzt( spc, tim )
  xyzt = bitor( bitand( spc, 7 ), bitand( tim, 56 ) );

