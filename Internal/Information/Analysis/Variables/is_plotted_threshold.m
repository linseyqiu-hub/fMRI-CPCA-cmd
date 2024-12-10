function b = is_plotted_threshold( t, mm3 )

  b = 0;

  if mm3 < constant_define( 'PREFERENCES', 'cluster.minimum_mm3' )
    return;
  end;

  b = is_active_threshold(t);

  if (b)
    if constant_define( 'PREFERENCES', 'threshold.default_only' )
       return;
    end
    b = b && t == constant_define( 'PREFERENCES', 'threshold.default' );
  end;

