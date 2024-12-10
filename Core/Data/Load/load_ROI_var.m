function v = load_ROI_var( mode, varname );

  v = [];
  if nargin < 2 
    return; 
  end
  
  if exist( 'G_ROI.mat', 'file' )
      
    load G_ROI
    if exist( 'G_ROI', 'var' )

      roi_id = strrep( G_ROI.mask( G_ROI.Rindex).id, ' ', '_' );
      out_dir = [ 'GZsegs' filesep 'ROI' filesep roi_id filesep];			% eg: Gsegs, GZsegs

      mvar = who_stats( [out_dir filesep], 'GC_vars.mat', varname );
      if mvar.mat_exists
        load( [out_dir filesep 'GC_vars.mat'], varname ) ;
        eval ( [ 'v = ' varname ';' ] );
      end;
      
   end
   
  end
  
end


