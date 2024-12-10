function diags = sum_diagonal( mtx )

diags = [];				% final results

for ii = 1:size(mtx,2) 			% primary row
  Cn = [];				% individual row results
%  for jj = 1:size(mtx,2)		% columns of primary row
    Cn = [Cn mtx(:,ii)'*mtx(:,ii)];	% accumulate columnar squares in row
%  end;
  diags = [diags sum(Cn)];			% apply columnar total to final result
end;

if ~isempty( diags )
  diags = sum(diags);
end;

