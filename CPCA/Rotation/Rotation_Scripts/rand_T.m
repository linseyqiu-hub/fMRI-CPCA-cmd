function T = rand_T( U )

  % per liang wang Dec 11, 2009

  T = rand(size(U,2));
  UR     = U*T(:,1);
  j     = 1;

  for i = 2:size(U,2)
    D = U*T(:,i);
    D = D - UR*(inv(UR'*UR)*UR'*D);
    T(:,i)=inv(U'*U)*U'*D;
    if norm(D,1) > exp(-32)
      UR          = [UR D];
      j(end + 1) = i;
    end
  end

  T = T./(ones(size(T,1),1)*sqrt(sum(T.^2)));


