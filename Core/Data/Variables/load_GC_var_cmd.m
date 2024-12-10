function v = load_GC_var_cmd( Gheader, Zheader, varname, model, Aidx )


  v = [];
  if nargin < 4
    model = 'G';
  end

  if nargin < 5
    Aidx = 0;
  end
  if ~isnumeric(Aidx)
    Aidx = 0;
  end
  
 Gpath = '';
  if strcmp( model, 'ROI' )
    if isfield( Gheader, 'ROIZheader' )
      if isfield( Gheader.ROIZheader, 'path_to_segs' )
        Gpath = Gheader.ROIZheader.path_to_segs;
      else
        Gpath = [Gheader filesep];
      end
    else
      Gpath = [Gheader filesep];
    end
    
  else
      
    if ~isstruct( Gheader )
      return;
    end

    if ~isfield( Gheader, 'GZheader' )
      return;
    end
      
    if ~strcmp( model, 'G' )
      load( Zheader.Contrast.path );
      if ~Aidx
        Aidx = Aheader.Aindex;
      end
    
      eval( [ 'Gpath = Aheader.model( Aidx ).path_to_' model ';' ] );
    else
      Gpath = Gheader.GZheader.path_to_segs;
    end
  
  end
  
  if ~strcmp( model, 'GAA')
    GCName = 'GC_vars.mat';
    mvar = who_stats( Gpath, GCName, varname );
    if ~mvar.mat_exists
      GCName = 'GC.mat';
      mvar = who_stats( Gpath, GCName, varname );

      if ~mvar.mat_exists
        GCName = 'GCC_vars.mat';
        mvar = who_stats( Gpath, GCName, varname );
        if ~mvar.mat_exists
          GCName = 'GCC.mat';
          mvar = who_stats( Gpath, GCName, varname );
        end
      end
    end
  
  else
    GCName = 'BB_vars.mat';
    mvar = who_stats( Gpath, GCName, varname );
  end
  if exist( [Gpath GCName], 'file' )  % -- older file system
    load( [Gpath GCName], varname );
  end
  
  if exist( varname, 'var' )
    eval ( [ 'v = ' varname ';' ] );
  end

end


