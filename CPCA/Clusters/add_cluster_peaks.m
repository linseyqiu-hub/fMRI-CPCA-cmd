function cluster_list = aduster_peaks( cluster_list, cluster_peaks )
  pk = struct( 'value', 0, 'mni', [], 'xyz', [] );

  if ~isempty(cluster_list)
    if ~isempty(cluster_peaks)
      [y idx] = sort( cluster_peaks, 1, 'descend' );

      for( ii = 1:size(idx,1) )

        cl_no = get_cluster_no( cluster_list, cluster_peaks(idx(ii),:) );
        if ( cl_no > 0 )
          pk.value = cluster_peaks(idx(ii),6);
          pk.mni = cluster_peaks(idx(ii),3:5);
          pk.xyz = cluster_peaks(idx(ii),7:9);
          cluster_list(cl_no).region = [cluster_list(cl_no).region; pk ];
        end
      end
    end;
  end;


