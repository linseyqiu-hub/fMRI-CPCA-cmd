function show_VR_loadings( component_loadings, cvariance, component_no, fid, log_fid )

  % --- summary of variance ---
  avg_pos_vox = '';
  if component_loadings.pos.mean > 0 
    avg_pos_vox = sprintf( '%.2f', component_loadings.pos.mean );
  end;

  avg_neg_vox = '';
  if component_loadings.neg.mean < 0 
    avg_neg_vox = sprintf( '%.2f', component_loadings.neg.mean );  
  end;

  PosLoadings = num2str(component_loadings.pos.loadings );
  MaxPosLoadings = sprintf( '%.2f', component_loadings.pos.max );

  NegLoadings = num2str(component_loadings.neg.loadings );
  MaxNegLoadings = sprintf( '%.2f', component_loadings.neg.max );

  variance = sprintf( '%.2f', cvariance.component_variance(component_no) );
  VarND = sprintf( '%.2f', cvariance.percent_explained_in_GC(component_no) );
  VarTotal = sprintf( '%.2f', cvariance.percent_explained_in_Z(component_no) );

  if log_fid 
    print_and_log( 0, '           Avg   Loadings        Max \n%s %5s %10s %10s\n%s %5s %10s %10s\nvariance: %7s %7s%% %7s%%\n', ...
                  '    +vox:', avg_pos_vox, PosLoadings, MaxPosLoadings, ...
                  '    -vox:', avg_neg_vox, NegLoadings, MaxNegLoadings, ...
                  variance, VarND, VarTotal ); 
  end;

  if fid 
    fprintf( fid, '           Avg   Loadings        Max \n%s %5s %10s %10s\n%s %5s %10s %10s\nvariance: %7s %7s%% %7s%%\n', ...
                  '    +vox:', avg_pos_vox, PosLoadings, MaxPosLoadings, ...
                  '    -vox:', avg_neg_vox, NegLoadings, MaxNegLoadings, ...
                  variance, VarND, VarTotal ); 
  end;


  % --- summary of loadings ---
  fprintf( '\nPositive:   total ');
  for val = 1:num_global_thresholds()
    if is_active_threshold(val)
      fprintf( '     %6d%%', global_threshold_value(val) );
    end;
  end;

  fprintf( '\nLoadings: %7d', component_loadings.pos.loadings);
  for val = 1:num_global_thresholds()
%    str = '             ';
    if is_active_threshold(val)
      str = sprintf( '     %7d', component_loadings.pos.threshold(val).loadings);
%    end;
      fprintf( '%s', str );
    end;
  end;

  fprintf( '\nMinimum : %7.2f', component_loadings.pos.min );
  for val = 1:num_global_thresholds()
%    str = '             ';
    if is_active_threshold(val)
      str = sprintf( '     %7.2f', component_loadings.pos.threshold(val).min);
%    end;
      fprintf( '%s', str );
    end;
  end;

  fprintf( '\nMaximum : %7.2f', component_loadings.pos.max );
  for val = 1:num_global_thresholds()
%    str = '             ';
    if is_active_threshold(val)
      str = sprintf( '     %7.2f', component_loadings.pos.threshold(val).max);
%    end;
      fprintf( '%s', str );
    end;
  end;

  fprintf( '\nMean    : %7.2f', component_loadings.pos.mean );
  for val = 1:num_global_thresholds()
%    str = '             ';
    if is_active_threshold(val)
      str = sprintf( '     %7.2f', component_loadings.pos.threshold(val).mean);
%    end;
      fprintf( '%s', str );
    end;
  end;

  fprintf( '\n');

  fprintf( '\nNegative:   total ');
  for val = 1:num_global_thresholds()
    if is_active_threshold(val)
      fprintf( '     %6d%%', global_threshold_value(val) );
    end;
  end;

  fprintf( '\nLoadings: %7d', component_loadings.neg.loadings);
  for val = 1:num_global_thresholds()
%    str = '             ';
    if is_active_threshold(val)
      str = sprintf( '     %7d', component_loadings.neg.threshold(val).loadings);
%    end;
      fprintf( '%s', str );
    end;
  end;

  fprintf( '\nMinimum : %7.2f', component_loadings.neg.min );
  for val = 1:num_global_thresholds()
%    str = '             ';
    if is_active_threshold(val)
      str = sprintf( '     %7.2f', component_loadings.neg.threshold(val).min);  
%    end;
      fprintf( '%s', str );
    end;
  end;

  fprintf( '\nMaximum : %7.2f', component_loadings.neg.max );
  for val = 1:num_global_thresholds()
%    str = '             ';
    if is_active_threshold(val)
      str = sprintf( '     %7.2f', component_loadings.neg.threshold(val).max);
%    end;
      fprintf( '%s', str );
    end;
  end;

  fprintf( '\nMean    : %7.2f', component_loadings.neg.mean );
  for val = 1:num_global_thresholds()
%    str = '             ';
    if is_active_threshold(val)
      str = sprintf( '     %7.2f', component_loadings.neg.threshold(val).mean);
%    end;
      fprintf( '%s', str );
    end;
  end;

  fprintf( '\n');


