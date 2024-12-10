function n = global_threshold_value(t)

  active = constant_define( 'PREFERENCES', 'threshold.active');
  values = constant_define( 'PREFERENCES', 'threshold.values');
  n = 0;
  if t>0 & t<=size(active,2)
    n = values(t);
  end;

