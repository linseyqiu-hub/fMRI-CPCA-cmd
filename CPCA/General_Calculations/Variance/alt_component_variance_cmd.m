function [S structure_matrix] = alt_component_variance_cmd(Zheader, sumDiag_GC, VR, T )
% alt_component_variance is used in conjunction with component variance on oblique rotations
% returning the variances and alternative UR/VR ( structure matrices) for oblique solutions

 
  S = struct ( 'stats', struct( 'total_ss_Z', 0, 'total_ss_GC', 0, 'ss_Z', 0, 'ss_GC', 0, 'nr', 0 ), 'sum_variance', 0, 'variance_of_n_dimension',0, 'percent_of_n_dimension', 0, 'variance_of_total',0, 'percent_of_total', 0);

  structure_matrix = VR * inv(T) * inv(T');

  S.stats.nr = Zheader.total_scans;
  S.stats.total_ss_Z = Zheader.tsum;
  S.stats.total_ss_GC = sumDiag_GC;

  S.stats.ss_Z = S.stats.total_ss_Z / S.stats.nr;
  S.stats.ss_GC = S.stats.total_ss_GC / S.stats.nr;

  % --- the explained variance is the sum of the transformed loadings (structure matrix )
  S.sum_variance = sum( structure_matrix .^ 2 );

  % -- the n-dimensional variance is the variance accounted for in GC
  S.variance_of_n_dimension = ( sum(S.sum_variance) ./ S.stats.ss_GC ) * 100;
  S.percent_of_n_dimension = ( S.sum_variance ./ S.stats.ss_GC ) * 100;

  % -- the total variance is the variance accounted for in Z
  S.variance_of_total = ( sum(S.sum_variance) ./ S.stats.ss_Z ) * 100;
  S.percent_of_total  =  ( S.sum_variance ./ S.stats.ss_Z ) * 100;


