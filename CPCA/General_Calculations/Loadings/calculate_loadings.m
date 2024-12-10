function [pos neg] = calculate_loadings( VR, thresh )

  if nargin < 2  thresh = 0;  end;

  pos = struct ( 'loadings', 0, 'min', 0, 'max', 0, 'mean', 0 );
  neg = pos;

  indpos=find(VR > thresh); 

  pos.loadings = size(indpos,1); 
  if ~isempty( indpos )
    pos.min = min(VR(indpos)); 
    pos.max = max(VR(indpos)); 
    pos.mean = mean(VR(indpos)); 
  end;

  indpos=find(VR < (thresh * -1 ) ); 

  neg.loadings = size(indpos,1); 
  if ~isempty( indpos )
    neg.min = max(VR(indpos)); 
    neg.max = min(VR(indpos)); 
    neg.mean = mean(VR(indpos)); 
  end;

