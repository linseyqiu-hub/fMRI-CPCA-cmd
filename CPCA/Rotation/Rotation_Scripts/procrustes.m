%------------------------------------------------------------------

function [B, T] = procrustes(A, TargetVR, type)
% Procrustes rotation of loadings matrix from factor analysis.

[d, m] = size(A);

if nargin < 2 || isempty(TargetVR)
    error('A TargetVR matrix must be specified for procrustes rotation.');
elseif any(size(TargetVR) ~= [d m])
    error('Incorrect size for procrustes rotation TargetVR matrix.');
end
if nargin < 3 || isempty(type)
    type = 'oblique';
else
    typeNames = {'oblique','orthogonal'};
    i = strmatch(lower(type), typeNames);
    if length(i) > 1
        error(sprintf('Ambiguous ''TypeProcr'' parameter value:  %s.', type));
    elseif isempty(i)
        error(sprintf('Unknown ''TypeProcr'' parameter value:  %s.', type));
    end
    type = typeNames{i};
end

% Orthogonal rotation to TargetVR
switch type
case 'orthogonal'
    [L, D, M] = svd(TargetVR' * A);
    T = M * L';
    
% Oblique rotation to TargetVR
case 'oblique'
    % LS, then normalize
    T = A \ TargetVR;
    T = T * diag(sqrt(diag((T'*T)\eye(m)))); % normalize inv(T)
end
B = A * T;
