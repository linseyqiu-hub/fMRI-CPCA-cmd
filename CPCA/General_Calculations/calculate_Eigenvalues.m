function calculate_Eigenvalues( Gpath, CC_var, reg)
global scan_information

  eig_var = 'C_Eigenvalues';
  out_CC_vars = [ Gpath 'GC_vars.mat' ];
  
  switch reg
      case 1,           % Gray Matter includes Brain Stem and Cerebellum
        eig_var = 'CG_Eigenvalues';
      case 2,           % White Matter only
        eig_var = 'CW_Eigenvalues';
  end

  n = matfile_vars( Gpath, 'GCC.mat', CC_var );
  
  if ~isempty(n)
    m = array_sizes( [n.sz_x n.sz_y] );
    x = check_memory();
  
    if scan_information.isMulFreq || (x.user.free / 1000 < m.gigabytes * 2.1)  % --- allow a 10% threshold for now
  
      % --- not enough memory to perform internal eigs function
      % --- use the D from svd over 15 components
      %if ( ~isempty( funcs.clear_cache ) )  funcs.clear_cache(); end; funcs.memory_stats(); 
      [u d v]=perform_svd( [Gpath 'GCC'], CC_var, constant_define( 'EIG_COUNT') ); % --= 

      eval( [ eig_var ' = sqrt(diag(d));' ] );
    else
      
      load( [ Gpath 'GCC.mat'], CC_var );
      eval( [ eig_var ' = sort(eig( ' CC_var ' ), 1, ''descend'');' ] );
      eval( [ eig_var ' = ' eig_var '(1:size(' CC_var ',2),:);' ] );
      
    end;
  
    initialize_non_existing_file( out_CC_vars );
    save( out_CC_vars, eig_var, '-v7.3', '-append');

%     if ~isempty(pop)
%       pop.setComment( '' );
%      end;
  
  end  % --- CC variable exists

  