function [MNI IJK] = MNI_coords( img )

  MNI = [];
  IJK = [];
  
  x = size(img.image);
  if size(x,2 ) < 3
    D = reshape( img.image, img.vol.dim);
  else
    D = img.image;
  end;

  ind = [1:prod(img.vol.dim)];

  [I J K] = ind2sub(size(D), ind);
  IJK = [I; J; K];
  if isempty(IJK)
    return
  end

  MNI = img.vol.mat(1:3,:)*[IJK; ones(1,size(IJK,2))];

