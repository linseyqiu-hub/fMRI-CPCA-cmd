function [B, T] = promax(A, power, gamma, normalize, reltol, maxit, al, style, pop)
% [B, T] = promax(A, power, gamma, normalize, reltol, maxit)
%
% Promax oblique rotation of loadings matrix from factor analysis.
%
% A is your loading matrix to be rotated.
% power is the Exponent for creating promax target matrix
%                      [ scalar >= 1 | {4} ]
%
% gamma is the coefficient for orthomax rotation must be between 0 and 1
%
%if nargin < 3 | isempty(normalize), normalize = 'on'; end
%if nargin < 4 | isempty(reltol), reltol = sqrt(eps); end
%if nargin < 5 | isempty(maxit), maxit = 250; end
%
% Brotated=A*T

B = [];
T = [];

[d, m] = size(A);

if nargin < 2 | isempty(power)
    power = 4;
elseif power < 1
    error('The power for promax rotation must be 1 or greater.');
end
if nargin < 3, gamma = []; end
if nargin < 4, normalize = []; end
if nargin < 5, reltol = []; end
if nargin < 6, maxit = []; end
if nargin < 7, al = 'orthomax'; end
if nargin < 8, style = 'oblique'; end
if nargin < 9, pop = 0; end;
  if ~strcmp( class(pop), 'cpca_progress' )
    pop = []; 
  end

  if ~isempty(pop)
    str = sprintf( 'Performing %s rotation', al );
    pop.setStatus( str );
    pop.show();
  end;

if ( strcmp( al, 'promax' ) ) 

  % Create target matrix from orthomax (defaults to varimax) solution
  [B0, T0] = orthomax(A, gamma, normalize, reltol, maxit);
  if ( isempty(T0) )  return; end;		% orthomax error exit point

  Target = sign(B0) .* abs(B0).^power; % keep it real, respect sign

  % Oblique rotation to target
  [B, T] = proc_todd(A, Target, style);

end;


%------------------------------------------------------------------
