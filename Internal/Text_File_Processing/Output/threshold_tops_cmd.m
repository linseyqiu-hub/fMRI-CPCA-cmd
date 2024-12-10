function threshold_tops_cmd(Zheader,scan_information, displays, nd, component_directory, Aidx, nvox, sd, ftext, mask_registry, ...
    cvariance_rotated_tot, tsum, ep, component_no, log_fid, loadings, files)

  for thr = 1:num_global_thresholds()
      if is_active_threshold(thr)
          fid = files(thr);
          [~,fname] = fileparts(char(displays(thr)));

          if component_no == 1
            text_file_header_cmd(Zheader,scan_information, nd, fid, 0, component_directory, fname, Aidx, nvox, thr );
             pca_summary_cmd(Zheader,scan_information, sd, [ftext constant_define( 'REGISTRATION_SUMMARY_TAG', mask_registry)], ...
                 cvariance_rotated_tot, fid, tsum );
          end
          
          print_formatted_ep( ep, component_no, fid, log_fid );
          show_VR_loadings( loadings, cvariance_rotated_tot, component_no, fid, log_fid );
      end
  end
end
