function V = vectored_mean( Var )
% --- returns the mean of vectors if result is a vector
% --- returns passed vector if result is a single value

  sz = size( Var );
  if any( sz == 1 )  V = Var;  return;  end;

  V = mean(Var);

