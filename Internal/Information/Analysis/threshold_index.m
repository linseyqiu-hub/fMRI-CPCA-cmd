function idx = threshold_index( t )

  idx = 0;
  for ii = 1:num_global_thresholds()
    if t == global_threshold_value( ii)
      idx = ii;
      return;
    end
  end;

