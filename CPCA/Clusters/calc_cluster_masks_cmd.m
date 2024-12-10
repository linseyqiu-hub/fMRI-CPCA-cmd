function clusters = calc_cluster_masks_cmd(scan_information, clusters )
 
    clusterStruct = struct( 'include', 0, 'exclude', 0, 'Mindex', [], 'Zindex', [] );
    dm = scan_information.mask.header.dim(2:4);
    WG = isRegistered(scan_information.mask) * constant_define( 'PREFERENCES', 'general.gray_white_split' );
    mask_index = scan_information.mask.ind;
    if WG
      [~, mask_index] = mask_registrations( scan_information.mask, 1 );
    end

    for cno = 1:size(clusters.pos, 1 ) 
      thiscluster = clusterStruct;
      thiscluster.size = clusters.pos(cno).voxels;

      for ii=1:size(clusters.pos(cno).xyz, 1)
        I = clusters.pos(cno).xyz(ii,1);
        J = clusters.pos(cno).xyz(ii,2); 
        K = clusters.pos(cno).xyz(ii,3); 

        idx = ( (K-1) * prod(dm(1:2) ) ) + ( (J-1) * dm(1) ) + I;
        zidx = find( mask_index == idx);

        thiscluster.Mindex = [thiscluster.Mindex; idx];
        thiscluster.Zindex = [thiscluster.Zindex; zidx];
      end

      clusters.pos(cno).Masks = thiscluster;
    end

    for cno = 1:size(clusters.neg, 1 ) 
      thiscluster = clusterStruct;
      thiscluster.size = clusters.neg(cno).voxels;

      for ii=1:size(clusters.neg(cno).xyz, 1)
        I = clusters.neg(cno).xyz(ii,1);
        J = clusters.neg(cno).xyz(ii,2); 
        K = clusters.neg(cno).xyz(ii,3); 

        idx = ( (K-1) * prod(dm(1:2) ) ) + ( (J-1) * dm(1) ) + I;
        zidx = find( mask_index == idx);

        thiscluster.Mindex = [thiscluster.Mindex; idx];
        thiscluster.Zindex = [thiscluster.Zindex; zidx];
        
      end
%       thiscluster.gray_matter = size(thiscluster.GZindex, 1);
      clusters.neg(cno).Masks = thiscluster;
    end

