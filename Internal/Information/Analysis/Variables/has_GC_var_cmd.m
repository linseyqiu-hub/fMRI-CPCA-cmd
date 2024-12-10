function v = has_GC_var_cmd(Zheader, Gheader, varname, model )

  GZheader = '';
  v = 0;
  if nargin < 4 
    model = 'G'; 
  end
  
  if ~isfield( Gheader, [ model 'Zheader' ] )
    return;
  end
  
  eval( [ 'GZheader = Gheader.' model 'Zheader;' ] );
  if isempty( GZheader)
    return;
  end
 
  if isempty( GZheader.path_to_segs )
    return;
  end
  
  if ~strcmp( model, 'GAA')
    mvar = who_stats( GZheader.path_to_segs, 'GC_vars.mat', varname );
    if ~mvar.mat_exists
      mvar = who_stats( GZheader.path_to_segs, 'GC.mat', varname );

      if ~mvar.mat_exists
        mvar = who_stats( GZheader.path_to_segs, 'GCC_vars.mat', varname );

        if ~mvar.mat_exists
         mvar = who_stats( GZheader.path_to_segs, 'GCC.mat', varname );
        end
      end
    end
  else
      
    mvar = who_stats( GZheader.path_to_segs, 'BB_vars.mat', varname );
  end
  v = mvar.mat_exists;

end


