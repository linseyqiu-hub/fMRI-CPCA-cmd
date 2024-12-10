function R = parse_rule( Rule, isProc )
% ---
% ---  process a file containing logical rule definitions
% ---  this script is called by defined_rule, the main control script for
% ---  rules processing
% ---
% ---  Parameters:
% ---      Rule    : structure containing the rules read in from a .rul file
% ---      isProc  : optional flag indicating to turn all rules off
% ---

global Zheader scan_information
 
  env = structure_define( 'env_struct' );
  if ~ispc
    env = get_linux_environ();
  end
  hlog = 0;
  [path, name] = cpca_log_file();
  if ~isempty( path)
    hlog =  exist( [path name], 'file') > 0;
  end

  analysis = struct ( ...
    'G', struct( ...
       'defined',   0, ...
       'regressed', 0, ...
       'extracted', 0, ...
       'FIR',       0 ...
       ), ...
    'A', struct( ...
       'defined',   0, ...
       'regressed', 0, ...
       'extracted', 0 ...
       ), ...
    'H', struct( ...
       'defined',   0, ...
       'Exists', 0, ...
       'ZH', struct( ...
         'regressed', 0, ...
         'extracted', 0 ), ...
       'EH', struct( ...
         'regressed', 0, ...
         'extracted', 0 ), ...
       'GMH', struct( ...
         'regressed', 0, ...
         'extracted', 0, ...
         'HnotGregressed', 0, ...
         'HnotGextracted', 0, ...
         'GnotHregressed', 0, ...
         'GnotHextracted', 0) ...
       ) ...
    );
    
  residual_G = ~isempty( matfile_vars( 'Residual_G/Z/', ['Z' num2str(Zheader.num_subjects) '_vars.mat'], 'SSQ' ) );
  residual_GA = ~isempty( matfile_vars( 'Residual_GA/Z/', ['Z' num2str(Zheader.num_subjects) '_vars.mat'], 'SSQ' ) );
  residual_GAA = ~isempty( matfile_vars( 'Residual_GAA/Z/', ['Z' num2str(Zheader.num_subjects) '_vars.mat'], 'SSQ' ) );

  analysis.G.defined = prod( [ Zheader.Model.mat_exists  Zheader.Model.mat_x == Zheader.total_scans   Zheader.Model.hdr_exists ] );
  if analysis.G.defined
    load( Zheader.Model.path, 'Gheader' );
    
    analysis.G.regressed = has_GC_var( Gheader, 'C_Eigenvalues') ;
    analysis.G.extracted = has_regressed_analysis( 'G' );
    analysis.G.FIR       = Gheader.model_type == constant_define( 'FIR_MODEL' );
  end;

  if ~isempty( Zheader.Contrast.path )
    load ( Zheader.Contrast.path )
    if exist( 'Aheader', 'var' )
      analysis.A.defined = prod( [  Aheader.model(Aheader.Aindex).mat_x * Zheader.num_subjects == Zheader.Model.mat_y  Zheader.Contrast.mat_exists ] );
    end
  end
  
  analysis.H.defined = prod( [ Zheader.Limits.mat_exists  Zheader.Limits.mat_x == (Zheader.total_columns * max(scan_information.frequencies, 1))  Zheader.Limits.hdr_exists ] );
  if analysis.H.defined
    load ( Zheader.Limits.path )
    analysis.H.ZH.regressed = has_H_var( Hheader, 'ZH', 'C_Eigenvalues') ;
    analysis.H.Exists =  ~isempty( matfile_vars( 'Residual/Z/', ['Z' num2str(Zheader.num_subjects) '_vars.mat'], 'SSQ' ) );
    analysis.H.EH.regressed = has_H_var( Hheader, 'EH', 'C_Eigenvalues') ;
    analysis.H.GMH.regressed = has_GMH_var( Hheader, 'GMH', 'C_Eigenvalues') ;
    analysis.H.GMH.HnotGregressed = has_GMH_var( Hheader, 'HnotG', 'C_Eigenvalues') ;
    analysis.H.GMH.GnotHregressed = has_GMH_var( Hheader, 'GnotH', 'C_Eigenvalues') ;
  end
    
  rules = fields( Rule.vars );
  
  for idx = 1:Rule.nvars
    
    A = '';
    eval ( [ 'A = Rule.vars.' char(rules(idx)) ';' ] )

    A = strrep( A, 'true',     num2str(1) );
    A = strrep( A, 'false',    num2str(0 ));
    A = strrep( A, 'off',      num2str(0 ));
    A = strrep( A, 'isLinux',  num2str( ~isempty(env.username ) ) );
    A = strrep( A, 'isSudo',   num2str( env.isSudo ) );
    A = strrep( A, 'isLoaded', num2str( Zheader.total_scans > 0 ) );
    A = strrep( A, 'hasLog',   num2str(hlog) );
    A = strrep( A, 'allEncoded', num2str(Zheader.conditions.nonEncoded == 0) );
    A = strrep( A, 'notFreq',  num2str(scan_information.isMulFreq == 0));
    A = strrep( A, 'hasMask',  num2str( ~isempty(scan_information.mask)  & isfield( scan_information.mask, 'ind' ) & numel(scan_information.mask.ind ) > 0 ));
    A = strrep( A, 'notRegistered',  num2str( ~(isfield( scan_information.mask, 'isRegistered' ) && ...
                                       scan_information.mask.isRegistered == 1 ) ));
    
    A = strrep( A, 'hasGEigs', num2str(analysis.G.regressed) );
    A = strrep( A, 'hasGVR',   num2str(analysis.G.extracted) );
    A = strrep( A, 'Gdefined', num2str( analysis.G.defined ) );
    A = strrep( A, 'isFIR',    num2str(analysis.G.FIR) );

    A = strrep( A, 'hasA',     num2str( analysis.A.defined ) );

    A = strrep( A, 'hasH',     num2str( analysis.H.defined ) );
    A = strrep( A, 'hasResidual',   num2str( residual_G | residual_GA | residual_GAA) );
    A = strrep( A, 'hasZH',    num2str( analysis.H.ZH.regressed  ) );
    A = strrep( A, 'hasEH',    num2str( analysis.H.EH.regressed  ) );
    A = strrep( A, 'hasGMHGC', num2str( analysis.H.GMH.GnotHregressed  ) );
    A = strrep( A, 'hasGMHBH', num2str( analysis.H.GMH.HnotGregressed  ) );
    A = strrep( A, 'hasGMH',   num2str( analysis.H.GMH.regressed  ) );

    A = strrep( A, 'notProcessing', num2str(~isProc) );

    if ~isempty( strfind( A, 'hasROIEigs' ) )
      A = strrep( A, 'hasROIEigs',  num2str( has_ROI_var( 'GZ', 'Est_Eigenvalues')) );        
    end

    if ~isempty( strfind( A, 'hasGCROI' ) )

      x = [];
      if exist( 'G_ROI.mat', 'file' )
        load G_ROI
        ROIGZ = [ 'ROI' filesep strrep( G_ROI.mask( G_ROI.Rindex).id, ' ', '_' ) filesep 'GZsegs' filesep];
        x = matfile_vars( ROIGZ, [ 'GC_S' num2str( Zheader.num_subjects ) '.mat'], [ 'C_S' num2str( Zheader.num_subjects )] );
      end
      A = strrep( A, 'hasGCROI',  num2str( ~isempty(x) ) );        
      
    end
    
% hasGEigs  hasGCvar( 1, 0, 'C_eignevalues' ) 
% hasGVR
 
    A = prod( str2num(char(A )));
    eval ( [ 'Rule.vars.' char(rules(idx)) ' = A;' ] )
    
  end

  R = Rule;
  
  
