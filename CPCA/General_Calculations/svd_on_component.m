function [U, D, V, k] = svd_on_component(m,n,p,climit,klimit,tol,k,delta,U,D,V, matVar )
eval( [ 'global clear_cache ' matVar  ] );

while k <= klimit
  if ( ~isempty( clear_cache ) )  
    clear_cache(); 
  end;
  w = 0;

  counter = 0; % iteration counter for kth plane
  while counter < climit
    counter = counter + 1;

    q = [];
    r = [];
    
    eval( [ 'q = ' matVar ' *p;' ] );
    s = sqrt(q'*q);
    q = q./s;
    eval( [ 'r = ' matVar '''*q;' ] );
    s = sqrt(r'*r);
    r = r./s;
    d = 0;
    for i = 1:n
      d = max(d,abs(p(i)-r(i)));
    end
%    d = max(d,max(abs(p-r)));
    if d <= delta % convergence test
      break;
    else
      w = p - r;
    end
    p = r;
    if D(k) ~= 0 && s/(D(k)+tol) < tol    % test for rank-deficit matrix
      fprintf('Rank-deficit matrix, stop computing...')
      return
    end

  end
%  step8(k,s,q,r);    
  D(k,k) = s;
  U(:,k) = q;
  V(:,k) = r;

%    A = step10(A,m,n,s,q,r);
  for i = 1:m
    eval( [ matVar '(i,:) = ' matVar '(i,:)-s*q(i)*r'';' ] );
  end
    
  if sqrt(w'*w) < eps

%    step1(mf, matVar,m,n,climit,klimit,tol,k,delta);
    r = randn(n,1);					
    s = sqrt(r'*r);					
    p = r./s;					

    [U,D,V,k] = svd_on_component(m,n,p,climit,klimit,tol,k,delta,U,D,V, matVar);
    if ( ~isempty( clear_cache ) )  
      clear_cache(); 
    end;

  else
    k = k + 1;
%    step2(mf, matVar,m,n,p,climit,klimit,tol,k,delta);
  end

end

  if ( ~isempty( clear_cache ) )  
    clear_cache(); 
  end;
