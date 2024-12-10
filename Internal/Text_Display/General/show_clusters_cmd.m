function show_clusters_cmd( posneg, cl_info, log_fid, fid, tf_display, component_no, thresh )
% posneg is text 'positive' or 'negative' for display
% cl_info is the cluster.pos|neg list
% log_fid is the fid of the open text logging file
% fid is the fid of the open cluster list full text output file
% tf_display is the name of the full list file

  if ( nargin < 7 )        thresh = constant_define( 'PREFERENCES', 'threshold.default' ); end

  print_header();
									% all MNI values printed to disk
  peak_max_display = 3;		% maximum number of peak for cluster printed to screen
  this_peak_displayed = 0;

  if isempty(cl_info)
    print_and_log( log_fid, ['No ' posneg ' loadings above threshold \n']);
    if ( fid ), fprintf( fid,['No ' posneg ' loadings above threshold \n']); end

  else
      formatter = output_definition( 'CLUSTER_FORMAT' );
      region_format = output_definition ('CLUSTER_REGION');%format for non-peak clusters

      out_folder = [fileparts(tf_display) filesep];

      peaks = [];
      count = 1;

      for ii = 1:size(cl_info,1)
          if ( this_peak_displayed < peak_max_display )
              this_peak_displayed = this_peak_displayed + 1;

              fprintf( 1, formatter,  ...
                  cl_info(ii).voxels, cl_info(ii).mm3, ...
                  cl_info(ii).peak.mni(1), cl_info(ii).peak.mni(2), cl_info(ii).peak.mni(3), ...
                  cl_info(ii).peak.value );

              if ( fid )
                  fprintf( fid, formatter, ...
                      cl_info(ii).voxels, cl_info(ii).mm3, ...
                      cl_info(ii).peak.mni(1), cl_info(ii).peak.mni(2), cl_info(ii).peak.mni(3), ...
                      cl_info(ii).peak.value);
              end  % -- print cluster list to file ---

              currpeak = cl_info(ii).peak;
              peaks(count,:) = [currpeak.mni(1),currpeak.mni(2),currpeak.mni(3),currpeak.value];
              count = count + 1;

              if ( size(cl_info(ii).region, 1) > 1 )
                  for jj = 1:size(cl_info(ii).region, 1)
                      if ( fid )
                          if ( ~all(cl_info(ii).peak.mni == cl_info(ii).region(jj).mni ) )
                              fprintf( fid, region_format, ...
                                  cl_info(ii).region(jj).mni(1), cl_info(ii).region(jj).mni(2), cl_info(ii).region(jj).mni(3), ...
                                  cl_info(ii).region(jj).value );
                          end  % -- cluster region not peak value ---
                      end  % -- print cluster list to file ---

                      if ( ~all(cl_info(ii).peak.mni == cl_info(ii).region(jj).mni ) )
                          currpeak = cl_info(ii).region(jj);
                          peaks(count,:) = [currpeak.mni(1),currpeak.mni(2),currpeak.mni(3),currpeak.value];
                          count = count + 1;
                      end
                  end
              end
          end
      end

    parts = [num2str(component_no) '_' posneg '_' thresh];
    mni_to_labels(peaks, out_folder, parts, 1); % sort order is default (1) when running through cpca

    print_and_log( log_fid, ' -- Complete MNI list contained in %s\n\n', strrep(tf_display,pwd,''));
  end

  function print_header()

    str = ['\nLocal maximum for ' posneg ' part...\n' ];
    print_and_log( log_fid, str );
    fprintf( 1,  output_definition( 'CLUSTER_HEADER' ) );

    if fid
      fprintf( fid, str );
      fprintf( fid,  output_definition( 'CLUSTER_HEADER' ) );
    end

  end

end
