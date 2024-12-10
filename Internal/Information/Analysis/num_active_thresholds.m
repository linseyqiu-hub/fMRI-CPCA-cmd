function n = num_active_thresholds()

  n = sum(constant_define( 'PREFERENCES', 'threshold.active' ));
