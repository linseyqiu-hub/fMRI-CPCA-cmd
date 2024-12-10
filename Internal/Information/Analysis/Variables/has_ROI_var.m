function v = has_ROI_var( mode, varname );

  v = 0;
  if nargin < 2 
    return; 
  end
  
  if exist( 'G_ROI.mat', 'file' )
      
    load G_ROI
    if exist( 'G_ROI', 'var' )

      roi_id = strrep( G_ROI.mask( G_ROI.Rindex).id, ' ', '_' );
      out_dir = [ 'ROI' filesep roi_id filesep mode 'segs'];			% eg: Gsegs, GZsegs

      mvar = who_stats( [out_dir filesep], 'GC_vars.mat', varname );
      v = mvar.mat_exists;
   end
   
  end
  
end


