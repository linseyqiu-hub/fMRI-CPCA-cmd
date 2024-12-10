function S = component_variance_cmd(Zheader, sumDiag, VR, ss_Z )
% sumDiag is the 'variance' explained by GC. The sumDiag is calculated by sum(diag(GC*GC'))
% GC is a estimate of the dependent variable Z : Z = GC + E. Here if you
%    are using CPCA code, you can obtain GC by the equation: GC = G*gg*B.

% VR is a rotated component loading. 
%
% Liang Wang 
% wanglbit@gmail.com

  if nargin < 4  ss_Z = Zheader.tsum;  end
  
  S = struct ( 'stats', struct( 'ss_Z', 0, 'ss_GC', 0, 'variance_Z', 0, 'variance_GC', 0, 'GC_variance_explained_in_Z', 0, 'nr', 0 ), 'component_variance', 0, 'variance_explained_in_GC',0, 'percent_explained_in_GC', 0, 'variance_explained_in_Z',0, 'percent_explained_in_Z', 0);

  % --- the number of scans,   ssq of Z,  ssq of GC ( or GMH, GnotH ext...)
  S.stats.nr = Zheader.total_scans;
  S.stats.ss_Z = ss_Z;
  S.stats.ss_GC = sumDiag;

  % --- variance of Z,  variance of GC,  percent of all components in GC accounted for in Z
  S.stats.variance_Z = S.stats.ss_Z / S.stats.nr;
  S.stats.variance_GC = S.stats.ss_GC / S.stats.nr;
  S.stats.GC_variance_explained_in_Z  = S.stats.ss_GC / S.stats.ss_Z;

  % --- the total variance represented in the number of components
  S.component_variance = sum( VR .^ 2 );

  % -- the component variance accounted for in GC
  S.variance_explained_in_GC = ( sum(S.component_variance) ./ S.stats.variance_GC ) * 100;
  S.percent_explained_in_GC = ( S.component_variance ./ S.stats.variance_GC ) * 100;

  % -- the component variance accounted for in Z
  S.variance_explained_in_Z = ( sum(S.component_variance) ./ S.stats.variance_Z ) * 100;
  S.percent_explained_in_Z  =  ( S.component_variance ./ S.stats.variance_Z ) * 100;


