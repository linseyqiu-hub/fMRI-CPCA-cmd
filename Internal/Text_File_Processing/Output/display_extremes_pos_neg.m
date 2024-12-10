function display_extremes_pos_neg( epn, cvar, tsum, fid, decimals, log_fid )

  if ( nargin < 2 ), cvar = struct( 'pb', 0 ); tsum = 0; end;	% optional variances for text write 
  if ( nargin < 3 ), tsum = 0; end;	% optional file pointer for text write 
  if ( nargin < 4 ), fid = 0; end;	% optional file pointer for text write 
  if ( nargin < 5 ), decimals = 2; end; % optional number of decimal places to show ( default 2 )
  if ( nargin < 6 ), log_fid = 0; end; % optional open log file for putput

  flt_format = [' %.' num2str(decimals) 'f'];
  pct_format = [' %6.' num2str(decimals) 'f'];

  [nc, ~] = size(epn);

  if ( log_fid ), print_and_log( log_fid, '\nExtreme Positive negative loading:' ); end
  if ( fid ), fprintf( fid, '\nExtreme Positive negative loading:' ); end

  for k=1:nc

    if ( log_fid ), print_and_log( log_fid, '\n---------------------------------------------------------------------------\n' ); end;
    if ( fid ), fprintf( fid, '\n---------------------------------------------------------------------------\n' ); end;

    if ( log_fid ), print_and_log( log_fid, ['Component %d\t\tminimum: ' flt_format '\tmaximum: ' flt_format '\n'], k, epn(k).minv, epn(k).maxv ); end;
    if ( fid ), fprintf( fid, ['Component %d\t\tminimum: ' flt_format '\tmaximum: ' flt_format '\n'], k, epn(k).minv, epn(k).maxv ); end;

    if ( log_fid ),  print_and_log( log_fid, '\npercentage of loadings   ' ); end;
    if (     fid ),        fprintf(     fid, '\npercentage of loadings   ' ); end;
    for val = 1:num_global_thresholds()
      if is_active_threshold(val)
        if ( log_fid ), print_and_log( log_fid, '     %5d%%', global_threshold_value(val) );  end;
        if (     fid ),       fprintf(     fid, '     %5d%%', global_threshold_value(val) );  end;
      end;
    end;
    if ( log_fid ), print_and_log( log_fid, '\n');  end;  
    if (     fid ),       fprintf(     fid, '\n');  end;

    if ( log_fid ),  print_and_log( log_fid, 'abs threshold            ' ); end;
    if (     fid ),        fprintf(     fid, 'abs threshold            ' ); end;
    for val = 1:num_global_thresholds()
%      str = '             ';
      if is_active_threshold(val)
        str = sprintf( '     %6.2f', epn(k).percentiles(val).threshold);
        if ( log_fid ), print_and_log( log_fid, '%s', str );  end;
        if (     fid ),       fprintf(     fid, '%s', str );  end;
      end;
    end;
    if ( log_fid ), print_and_log( log_fid, '\n');  end;  
    if (     fid ),       fprintf(     fid, '\n');  end;


    if ( log_fid ),  print_and_log( log_fid, 'voxels above             ' ); end;
    if (     fid ),        fprintf(     fid, 'voxels above             ' ); end;
    for val = 1:num_global_thresholds()
%      str = '             ';
      if is_active_threshold(val)
        str = sprintf( '    %7d', epn(k).percentiles(val).voxels);
        if ( log_fid ), print_and_log( log_fid, '%s', str );  end;
        if (     fid ),       fprintf(     fid, '%s', str );  end;
      end;
    end;

    if ( log_fid ), print_and_log( log_fid, '\n');  end;  
    if (     fid ),       fprintf(     fid, '\n');  end;

    if ( log_fid ),  print_and_log( log_fid, 'positive voxels          ' ); end;
    if (     fid ),        fprintf(     fid, 'positive voxels          ' ); end;
    for val = 1:num_global_thresholds()
%      str = '             ';
      if is_active_threshold(val)
        str = sprintf( '    %7d', epn(k).percentiles(val).pos_voxels);
        if ( log_fid ), print_and_log( log_fid, '%s', str );  end;
        if (     fid ),       fprintf(     fid, '%s', str );  end;
      end;
    end;

    if ( log_fid ), print_and_log( log_fid, '\n');  end;  
    if (     fid ),       fprintf(     fid, '\n');  end;

    if ( log_fid ),  print_and_log( log_fid, 'negative voxels          ' ); end;
    if (     fid ),        fprintf(     fid, 'negative voxels          ' ); end;
    for val = 1:num_global_thresholds()
%      str = '             ';
      if is_active_threshold(val)
        str = sprintf( '    %7d', epn(k).percentiles(val).neg_voxels);
        if ( log_fid ), print_and_log( log_fid, '%s', str );  end;
        if (     fid ),       fprintf(     fid, '%s', str );  end;
      end;
    end;
    if ( log_fid ), print_and_log( log_fid, '\n');  end;  
    if (     fid ),       fprintf(     fid, '\n');  end;



    if isfield( cvar, 'component_variance' )

      if ( log_fid ), print_and_log( log_fid, ['\nSS explained by Component %d:  ' flt_format '\npredictable:\t\t\t' pct_format '%%\ntotal:\t\t\t\t' pct_format '%%\n'], ...
		k, ...
                tsum*(cvar.percent_explained_in_Z(k)/100), ...
                cvar.percent_explained_in_GC(k), ...
                cvar.percent_explained_in_Z(k) ); 
      end;
      if ( fid ), fprintf( fid, ['\nSS explained by Component %d:  ' flt_format '\npredictable:\t\t\t' pct_format '%%\ntotal:\t\t\t\t' pct_format '%%\n'], ...
		k, ...
                tsum*(cvar.percent_explained_in_Z(k)/100), ...
                cvar.percent_explained_in_GC(k), ...
                cvar.percent_explained_in_Z(k) ); 
      end;
    else
      if isfield( cvar, 'sum_variance' )	% older structure
        if ( log_fid ), print_and_log( log_fid, ['\nSS explained by Component %d:  ' flt_format '\npredictable:\t\t\t' pct_format '%%\ntotal:\t\t\t\t' pct_format '%%\n'], ...
		k, ...
                tsum*(cvar.percent_of_total(k)/100), ...
                cvar.percent_of_n_dimension(k), ...
                cvar.percent_of_total(k) ); 
        end;
        if ( fid ), fprintf( fid, ['\nSS explained by Component %d:  ' flt_format '\npredictable:\t\t\t' pct_format '%%\ntotal:\t\t\t\t' pct_format '%%\n'], ...
		k, ...
                tsum*(cvar.percent_of_total(k)/100), ...
                cvar.percent_of_n_dimension(k), ...
                cvar.percent_of_total(k) ); 
        end;

      end
    end;
  end;


