function Coor = peak_coordinates(filename, thres)  
% C =PickCoordinates('G_Component_1_of_nd3_promax_oblique_i50000_p2.00_g1.00.img',0.3);

  if ( nargin < 2 ) Coor = {}; return; end;
%  if ( thres == 0 ) thres = 0.3 ; end;
%filename

  img = cpca_read_vol(filename);
%if isfield( img, 'error' )   
%  img.header.error
%end;

  x = size(img.image);
  if size(x,2 ) < 3
    PosD = reshape( img.image, img.vol.dim);
  else
    PosD = img.image;
  end;
  NegD = PosD;
  
  PosD((img.image(:) < 0 )) = 0;
  NegD((img.image(:) > 0 )) = 0;

  Coor = cell(1,2);
  Coor{1} = localmax(PosD,img.vol.mat,thres, 1);
  Coor{2} = localmax(NegD,img.vol.mat,thres, -1);

function List = localmax(D,M,thres, mul)

  D = abs(D);
  D(D(:)<thres)=0;
  Z = D(D(:)>0);
  [I J K] = ind2sub(size(D),find(D));
  XYZ = [I J K]';
  if isempty(XYZ)
    List = [];
    return
  end
  minz        = abs(min(min(Z)));
  zscores     = 1 + minz + Z;
  [N Z XYZ A] = cpca_maxima(zscores,XYZ);
  Z           = Z - minz - 1;
  XYZmm = M(1:3,:)*[XYZ; ones(1,size(XYZ,2))];

  Num    = 3;
  Dis    = 8;
  mms = prod(abs( sum(M(:,1:3) ) ) );
  
  List = [];
  while prod(size(find(isfinite(Z))))

    %-Find largest remaining local maximum
    %------------------------------------------------------------------
    [U,i]   = max(Z);			% largest maxima
    j       = find(A == A(i));		% maxima in cluster
    Ze = U*mul;
    Nv =N(i);
    Tv = Nv * mms;
    List = [List; Nv Tv XYZmm(:,i)' Ze XYZ(:,i)'];

    %-Print Num secondary maxima (> Dis mm apart)
    %------------------------------------------------------------------
    [l q] = sort(-Z(j));				% sort on Z value
    D     = i;
    for i = 1:length(q)
        d = j(q(i));
        if min(sqrt(sum((XYZmm(:,D)-XYZmm(:,d)*ones(1,size(D,2))).^2)))>Dis;
            if length(D) < Num
                Ze    = Z(d)*mul;                
                List = [List; Nv Tv XYZmm(:,d)' Ze XYZ(:,d)'];
            end
        end
    end
    Z(j) = NaN;		% Set local maxima to NaN
  end				% end region


