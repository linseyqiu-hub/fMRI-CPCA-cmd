function threshold_print_mni(log_fid,component_no,fid,displays,thresholds,clusters, thr)

    if log_fid, print_and_log( 0, '\nMNI coordinates for cluster peaks at %d%% threshold for component %d\n', ...
          global_threshold_value(thr), component_no ); end;
    if (fid),  fprintf(fid, '\nMNI coordinates for cluster peaks at %d%% threshold for component %d\n', ...
          global_threshold_value(thr), component_no ); end;

    tf_display = char(displays(thr));
    thresh = char(thresholds(thr));
    show_clusters( 'positive', clusters.threshold(thr).pos, log_fid, fid, tf_display, component_no, thresh );
    show_clusters( 'negative', clusters.threshold(thr).neg, log_fid, fid, tf_display, component_no, thresh );

end
