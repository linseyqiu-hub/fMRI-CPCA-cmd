function stddev = stddev( mtx )
% calculate std on larger width arrays ( 100k+ )
% uses std formula
%  ---                     ---            
% /   1                _      \   1
% |  -----  sum  ( x - x )    |  ---
% \  n - 1                    /   2
%  ---                     ---
%

sos = zeros(1,size(mtx,2));				% final results
mn = mean(mtx);

for ii = 1:size(mtx,1) 					% primary row
  for jj = 1:size(mtx,2)
    sos(1,jj) = sos(1,jj) + ( (mtx(ii,jj)-mn(1,jj) ) * (mtx(ii,jj)-mn(1,jj) ) );	% square x-mean
  end;
end;

stddev = sqrt( sos/max(1,(size(mtx,1)-1)) );

