function [U D V] = perform_svd(matFile, matVar, klimit, clear_cache )
% -- calculating svd by the power method to obtain singular components for huge data,
% -- rather than the QR algorith usually used (Thanks Yoshio for pointing to
% -- this way). The calculation mainly relies on multiple iteration steps to find asymptotical stable solutions. 
% -- The usage of this function is considered as the same to svd (eg. [U D V] =
% -- svd (A) ). Please refer to the paper below for the more detailed
% -- information.
% --
% -- Input
% -- A       raw data
% -- klimit  the maximum numbe of singular planes to compute. You can specify
% --          the number of extracted components
% -- Output
% -- U component scores
% -- D singular values
% -- V component loadings
% --
% -- Liang Wang  2010/02/04
% -- wanglbit@gmail.com
% --
% -- Reference:
% -- Simple algorithms for the partial singular value decomposition
% -- J.C. Nash and S. Shlien
% -- The Computer Journal, Vol. 30. No. 3, 1987
% --
% -- September 2012 - John Paiement 
% -- revision 1.0: emulation of ByRef using variable from file
% --               independent mat file per iteration, inline subroutines expanded
% --               to maintain lowest threshold of memory consumption possible
% -- revision 1.1: revised to use main matrix as global variable rather than waste
% --               time/resources saving/loading.  If you can load it you
% --               can process it.
% --
% -- syntax      : [U D V] = perform_svd(matFile, matVar, klimit )
% --
% -- parameters  : matFile: string - name of file containg matrix ( w/o extension )
% --               matVar : string - name variable within matFile
% --               klimit : double - number of components to process
% -- eg          : [U D V] = perform_svd('GZsegs/GCC', 'CC', 3 )
% --
% -- optimizing  : this function is designed to utilize the CPCA cache
% --               clearing operations on Linux platforms.  MATLAB should
% --               be run as sudo user, and the [*] Auto cache clear
% --               function enabled.  It will run without this, but will
% --               run out of memory on CC arrays over a few GB in size
% --               without it.

  if nargin < 4
    clear_cache = [];
  end
  eval( [ 'global clear_cache ' matVar  ] );
  
  matFile = strrep( matFile, '.mat', '' );  % --- strip off .mat extension if given
  
  load( [matFile '.mat'], matVar );
  if ( ~isempty( clear_cache ) )  
    clear_cache(); 
  end;

  m = 0; n = 0;
  eval ( [ '[m n] = size( ' matVar ' );' ] );
  tol = sqrt(eps); % a tolerance for deciding that a singular value is zero
  delta = 10*eps; % a convergence criterion
  climit = 300; % the maximum number of iterations per singular plane

  % initializing working vectors and matrices
  D = zeros(klimit,klimit); % singluar values  	
  U = zeros(m,klimit); % component scores  	
  V = zeros(n,klimit); % component loadings	
  k = 1;
   
  % step 1 initalizes r, s & p, then calls step 2   
  r = randn(n,1);					
  s = sqrt(r'*r);					
  p = r./s;		

  [U D V k] = svd_on_component(m,n,p,climit,klimit,tol,k,delta,U,D,V, matVar);

  clear svd_on_component
  if ( ~isempty( clear_cache ) )  
    clear_cache(); 
  end;

