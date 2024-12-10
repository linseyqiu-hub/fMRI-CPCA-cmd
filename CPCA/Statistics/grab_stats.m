function grab_stats( zsum, nd )
% get variables from processed Z for comparisons during release checks

  if ( nargin < 2 )
    fprintf( '%s\n', 'syntax: grab_stats( Zheader.tsum, # components.');
    return
  end;

  d = dir( [ 'G_nd' num2str(nd) '*.mat' ] );
  if ( size(d,1) > 0 )
    for ii = 1:size(d,1)
%      filename = [ 'G_nd' num2str(nd) '_unrotated' ];
      show_stats( d(ii).name, zsum );
    end
  end


function show_stats( filename, zsum ) 

  x = regexp( filename, '_', 'split' );
  cmp = str2double( strrep( x(2), 'nd', '' ) );
 
  vars = ' F cvariance* ep tsum dsum psum ppsum pdsum ppdsum snr GZSoS Beigs d3';
  eval ( [ 'load ' filename vars ] );

  chk_psum = sum(Beigs);

  fprintf( '\nfile: %s\n\n', filename );
  fprintf( 'Variable\t\tvalue\t\tverify\n' );
  fprintf( '------------------------- Basic Stats -------------------------------\n' );
  fprintf( 'Total Sum of Squares:\t%12.3f\t%12.3f\n', tsum, zsum );
  fprintf( 'Explained by G:  \t%12.3f\t%12.3f\n', psum, chk_psum );
  fprintf( '   Percentages:  \t %11.4f %%\t %11.4f %%\n', ppsum, 100*psum/tsum );
  fprintf( 'Explained by nd:  \t%12.3f\t%12.3f\n', dsum, sum(sum(d3.^2)) );
  fprintf( '   Percentages:  \t %11.4f %%\t %11.4f %%\n', pdsum, 100*dsum/psum );
  fprintf( ' %% of total SS:  \t %11.4f %%\t %11.4f %%\n', ppdsum, 100*dsum/tsum );

  fprintf( '\n------------------- Variances (unrotated) -------------------------\n' );

  fprintf( 'Component          \t' );
  for ii = 1:size(cvariance_unrotated_tot.explainedvar,2)
    fprintf( '%12d\t', ii );
  end

  fprintf( '\ntotal variance    \t%12.3f\t', cvariance_unrotated_tot.totalvar );

  fprintf( '\n   nd variance    \t' );
  for ii = 1:size(cvariance_unrotated_tot.explainedvar,2)
    fprintf( '%12.3f\t', cvariance_unrotated_tot.explainedvar(ii) );
  end

  fprintf( '\n    %% variance    \t' );
  for ii = 1:size(cvariance_unrotated_tot.explainedvar,2)
    fprintf( ' %11.4f %%\t', cvariance_unrotated_tot.nd_percent(ii) );
  end

  fprintf( '\n    %%   total    \t' );
  for ii = 1:size(cvariance_unrotated_tot.explainedvar,2)
    fprintf( ' %11.4f %%\t', cvariance_unrotated_tot.tot_percent(ii) );
  end


  fprintf( '\n------------------- Variances (rotated) -------------------------\n' );

  fprintf( 'Component          \t' );
  for ii = 1:size(cvariance_rotated_tot.explainedvar,2)
    fprintf( '%12d\t', ii );
  end

  fprintf( '\ntotal variance    \t%12.3f\t', cvariance_rotated_tot.totalvar );

  fprintf( '\n   nd variance    \t' );
  for ii = 1:size(cvariance_rotated_tot.explainedvar,2)
    fprintf( '%12.3f\t', cvariance_rotated_tot.explainedvar(ii) );
  end

  fprintf( '\n    %% variance    \t' );
  for ii = 1:size(cvariance_rotated_tot.explainedvar,2)
    fprintf( ' %11.4f %%\t', cvariance_rotated_tot.nd_percent(ii) );
  end

  fprintf( '\n    %%   total    \t' );
  for ii = 1:size(cvariance_rotated_tot.explainedvar,2)
    fprintf( ' %11.4f %%\t', cvariance_rotated_tot.tot_percent(ii) );
  end


 

  fprintf( '\n' );
  fprintf( '\n------------------------ extremes -----------------------------\n' );

  fprintf( '          \t %18.0f %% \t                 %18.0f %% \t                 %18.0f %%', 1,5,10 );

  for ii = 1:size(ep,1)

    fprintf( '\n Component %d \t', ii );

    for jj = 1:3
      str = sprintf( '%8.3f %6d(+%6d/-%6d)', ep(ii).percentiles(jj).threshold, ...
            ep(ii).percentiles(jj).voxels, ...
            ep(ii).percentiles(jj).pos_voxels, ...
            ep(ii).percentiles(jj).neg_voxels );
      fprintf( '%s\t', str );
    end

  end

  fprintf( '\n' );





