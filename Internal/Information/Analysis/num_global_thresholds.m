function n = num_global_thresholds()

  a = constant_define( 'PREFERENCES', 'threshold.active' );
  n = size(a,2);
