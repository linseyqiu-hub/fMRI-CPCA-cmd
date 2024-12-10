function [thresholds, files, displays] = threshold_txts(ftext, mniParms, component_directory, type)

  thresholds = [];
  files = [];
  displays = [];

  for thr = 1:num_global_thresholds()
   thresh = [num2str(global_threshold_value(thr)) '%'];
   if is_active_threshold(thr)

    txt_file = fs_filename( 'txt', ftext, [type '_' thresh], mniParms );
    text_file = [component_directory txt_file];
    fid = fopen( text_file, 'w' );
    tf_display = [ component_directory txt_file] ;

    files = [files; fid];
    displays = [displays; {tf_display}];
   else
    files = [files; 0];
    displays = [displays; {'none'}];
   end
    thresholds = [thresholds; {thresh}];
  end

end
