function n = num_global_thresholds()
  a = constant_define( 'PREFERENCES', 'threshold.active', [1 1 1] );
  n = size(a,2);