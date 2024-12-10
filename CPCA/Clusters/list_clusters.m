function Coor = list_clusters(filename, thres)  
% lst = list_clusters('G_Component_1_of_nd3_promax_oblique_i50000_p2.00_g1.00.img',0.3);

  Coor = {};
  
  if ( nargin < 2 ) return; end;

  img = cpca_read_vol(filename);
  if isfield( img.header, 'error' )
    disp( [ 'list_clusters (6): ' img.header.error ] );
    return;
  end;

  x = size(img.image);
  if size(x,2 ) < 3
    PosD = reshape( img.image, img.vol.dim);
  else
    PosD = img.image;
  end;
  NegD = PosD;
  
  PosD((img.image(:) < 0 )) = 0;
  NegD((img.image(:) > 0 )) = 0;
 
  Coor.pos = clusters_from(PosD,img.vol.mat,thres );
  Coor.neg = clusters_from(NegD,img.vol.mat,thres );


function cl_list = clusters_from(D,M,thres)

  cl_list = [];		% sorted return structure
  clist = [];		% initially defined structure before sorting

  Da = abs(D);
  Da(Da(:)<thres)=0;
  Z = Da(Da(:)>0);
  [I J K] = ind2sub(size(Da),find(Da));
  XYZ = [I J K]';
  if isempty(XYZ)
    return
  end
  minz        = abs(min(min(Z)));
  zscores     = 1 + minz + Z;

  % ---  [cci N Z2 XYZmx A] = spm_max(zscores,XYZ);
  % --- we only need a small portion of the spm_max routine ---
  % Ensure that L contains exactly integers
  L = round(XYZ);

  %
  % Turn location list to binary 3D volume.
  %
  dim = [max(L(1,:)) max(L(2,:)) max(L(3,:))];
  vol = zeros(dim(1),dim(2),dim(3));
  index = sub2ind(dim,L(1,:)',L(2,:)',L(3,:)');
  vol(index) = 1;

  %
  % Label each cluster in 3D volume with it's 
  % own little label using an 18 connectivity  [L N Z B A] = spm_max(zscores,XYZ);
  % criterion (without crashing ;-)).
  %
  % cci = connected components image volume.

  [cci,num] = bwlabel(vol,18);
  % --- the cci values are all we are interested in for total clusters ---

  num_clusters = max(max(max(cci)));
  % the first entry in N is a total, actual cluster table info starts at 2

  XYZmm = M(1:3,:)*[XYZ; ones(1,size(XYZ,2))];
  vox2mm = prod( abs(diag(M(1:3,1:3))) );		% --- voxel dimensions for mm^3 ---

  pk = struct( 'value', 0, 'mni', [], 'xyz', [] );
  sp = struct( 'cluster_no', 0, 'voxels', 0, 'mm3', 0, 'peak', pk, 'load', [], 'mni', [], 'xyz', [], 'region', [] );
% --- cluster_no	arbitrary index value
% --- voxels		number of voxels associated with this cluster
% --- mm3		cubin mm of cluster area
% --- peak		the mni coordinates and loading value of the highest cluster peak 
% --- load		complete list of loading values for each cluster voxel
% --- mni		complete list of mni coordinates for each cluster voxel
% --- xyz		complete list of Z index values for each cluster voxel
% --- region		list of peaks for clusters

  for cluster_no = 1:num_clusters

    spn = sp;

    x = find(cci==cluster_no);

    spn.cluster_no = cluster_no;  
    spn.voxels = size(x,1);
    spn.mm3 = spn.voxels * vox2mm;

    for ii = 1:size(x,1)
  
      ix = find( index==x(ii) );
      idx = sub2ind(size(D), XYZ(1,ix), XYZ(2,ix), XYZ(3,ix) );

      spn.mni = [spn.mni; XYZmm(:,ix)'];
      spn.xyz = [spn.xyz; XYZ(:,ix)'];
      spn.load = [spn.load; D(idx)];

      if ( Da(idx) > abs(spn.peak.value) )
        spn.peak.value = D(idx);
        spn.peak.mni = XYZmm(:,ix)';
        spn.peak.xyz = XYZ(:,ix)';
      end;

    end;

    clist = [clist; spn];

  end;

  % now order the clusters, largest to smallest

  sz = []; 
  for ii = 1:size(clist,1)  
    sz = [sz; clist(ii).voxels]; 
  end;

  [x idx] = sort(sz, 'descend');
  for ( ii = 1:size(idx,1) )
    cl_list = [cl_list; clist(idx(ii))];
    cl_list(ii).cluster_no = ii;
  end;




