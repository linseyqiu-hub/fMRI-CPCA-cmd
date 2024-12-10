function [B, T] = orthomax(A, gamma, normalize, reltol, maxit)
% Orthogonal rotation of loadings matrix from factor analysis.

[d, m] = size(A);
B = [];

% Defaults to normalized varimax rotation
if nargin < 2 || isempty(gamma)
    gamma = 1;
elseif gamma < 0 || gamma > 1
    error('The coefficient for orthomax rotation must be between 0 and 1.');
end
if nargin < 3 || isempty(normalize), normalize = 'on'; end
if nargin < 4 || isempty(reltol), reltol = sqrt(eps); end
if nargin < 5 || isempty(maxit), maxit = 250; end

% Normalize the factor loadings
switch normalize
case 'on'
    h = sqrt(sum(A.^2, 2));
    Beta = A ./ repmat(h, 1, size(A,2));
case 'off'
    Beta = A;
otherwise
    error('The ''Normalize'' parameter value must be ''on'' or ''off''.');
end
T = eye(m);
BetaT = Beta;

D = 0;
for k = 1:maxit
    Dold = D;
    [L, D, M] = svd(Beta' * (d*BetaT.^3 - gamma*BetaT * diag(sum(BetaT.^2))));

    T = L * M';
    D = sum(diag(D)) ;		% cvgs to sum(d*sum(BetaT.^4) - gamma*sum(BetaT.^2).^2)
    BetaT = Beta * T;
    if (abs(D - Dold)/D < reltol)
        % Unnormalize the rotated loadings
        switch normalize
        case 'on'
            B = BetaT .* repmat(h, 1, size(A,2));
        case 'off'
            B = BetaT;
        end
        return;
    end
end

% orthomax should have returned it's solution without reaching this point
% if we reach here, indicate an error and abort processing gracefully

  T = [];  % flag to abort inside promax
  B = [];  % flag to abort inside promax
  str = 'orthomax has reached the maximum iterations without determining a solution.';
  show_message( 'Out of Bounds', str );
  return;

error('Iteration limit exceeded for factor rotation.');

