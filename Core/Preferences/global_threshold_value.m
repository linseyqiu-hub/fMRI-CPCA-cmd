function n = global_threshold_value(t)
  active = constant_define( 'PREFERENCES', 'threshold.active', [1 1 1] );
  values = constant_define( 'PREFERENCES', 'threshold.values', [1 5 10] );
  n = 0;
  if t>0 & t<=size(active,2)
    n = values(t);
  end;

