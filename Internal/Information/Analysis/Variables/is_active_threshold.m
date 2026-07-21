function b = is_active_threshold( t )
  b = 0;
  active = constant_define( 'PREFERENCES', 'threshold.active', [1 1 1] );
  if t>0 & t<=size(active,2)
    b = active(t);
  end;

