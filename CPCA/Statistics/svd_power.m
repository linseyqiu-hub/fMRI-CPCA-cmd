function [U D V]=svd_power(A,klimit,pop)
%% calculating svd by the power method to obtain singular components for huge data,
%% rather than the QR algorith usually used (Thanks Yoshio for pointing to
%% this way). The calculation mainly relies on multiple iteration steps to find asymptotical stable solutions. 
%% The usage of this function is considered as the same to svd (eg. [U D V] =
%% svd (A) ). Please refer to the paper below for the more detailed
%% information.
%
%Input
% A       raw data
% klimit  the maximum numbe of singular planes to compute. You can specify
%          the number of extracted components
%Output
% U component scores
% D singular values
% V component loadings
%
% Liang Wang  2010/02/04
% wanglbit@gmail.com
%
% Reference:
% Simple algorithms for the partial singular value decomposition
% J.C. Nash and S. Shlien
% The Computer Journal, Vol. 30. No. 3, 1987
%

  if ( nargin < 3 )  pop = 0;  end;

  [m n] = size(A);				
  tol = sqrt(eps); % a tolerance for deciding that a singular value is zero
  delta = 10*eps; % a convergence criterion

% --- the only alteration from the original code from Liang on May 02, 1010 is the
% --- reduction of the climit from 10,000 to 300
  climit = 300; % the maximum number of iterations per singular plane

  % initializing working vectors and matrices
  D = zeros(klimit,klimit); % singluar values  	
  U = zeros(m,klimit); % component scores  	
  V = zeros(n,klimit); % component loadings	
  k = 1;
  [U,D,V] = step1(A,m,n,climit,klimit,tol,k,delta,U,V,D);

%  fprintf('All done...');

function [U,D,V] = step1(A,m,n,climit,klimit,tol,k,delta,U,V,D)
% step 1
r = randn(n,1);					
s = sqrt(r'*r);					
p = r./s;
[U,D,V] = step2(A,m,n,p,climit,klimit,tol,k,delta,U,V,D);
return

function [U,D,V] = step2(A,m,n,p,climit,klimit,tol,k,delta,U,V,D)
% step 2

w = 0;
while k <= klimit

    counter = 0; % iteration counter for kth plane
    while counter < climit
        counter = counter + 1;

        q = A*p;
        s = sqrt(q'*q);
        q = q./s;
        r = A'*q;
        s = sqrt(r'*r);
        r = r./s;
        d = 0;
        for i = 1:n
            d = max(d,abs(p(i)-r(i)));
        end
%         d = max(d,max(abs(p-r)));
        if d <= delta % convergence test
            break;
        else
            w = p - r;
        end
        p = r;
        if s/(D(k)+tol) < tol % test for rank-deficit matrix
            fprintf('Rank-deficit matrix, stop computing...')
            return
        end
    end
    [U D V] = step8(k,s,q,r,D,U,V);    
    A = step10(A,m,n,s,q,r);
    if sqrt(w'*w) < eps
        [U,D,V] = step1(A,n,climit,klimit,k,delta,U,V,D);
    else
        k = k + 1;
        [U,D,V] = step2(A,m,n,p,climit,klimit,tol,k,delta,U,V,D);
    end
end

function [U D V] = step8(k,s,q,r,D,U,V)
% store results
D(k,k) = s;
U(:,k) = q;
V(:,k) = r;

function A = step10(A,m,n,s,q,r)
% deflate matrix
%   A = A-s*q*r';

for i = 1:m
    for j = 1:n
        A(i,j) = A(i,j)-s*q(i)*r(j);
    end
end



