function clusterno = get_cluster_no( cluster_struct, element )
% cluster_struct = clusters.neg
% element = component.neg(1,:)

  vox = element(1);
  mni = element(3:5);

  clusterno = 0;
  for ii = 1:size(cluster_struct,1)

    if ( cluster_struct(ii).voxels == vox )

      for ( jj = 1:size(cluster_struct(ii).mni,1) )
        if ( all( cluster_struct(ii).mni(jj,:) == mni ) )
          clusterno = ii;
          return;
        end
      end
    end;

  end;


