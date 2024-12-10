function abort_proc = extract_gaa_components( funcs, nd, log_fid, pop, GAtyp )
global Zheader scan_information process_information 

% --- Primary Iterations
% --- size( SubjectVector ) * 2;            - default [ 1:Zheader.num_subjects ]

  if ( nargin < 3 )  log_fid = 0;  end;
  if ( nargin < 4 )  pop = 0;  end;
  if ( nargin < 5 )  GAtyp = 'GAA';  end;
  if ~strcmp( class(pop), 'cpca_progress' )
    pop = []; 
  end

  process_date = date;
  abort_proc = 0;

  load( Zheader.Model.path, 'Gheader');
  load( Zheader.Contrast.path );

  cc_var = 'BB';
  cc_mat = 'BB_vars.mat';
%  eval( ['GZHeader = Gheader.' GAtyp 'Zheader;'] );
  GAheader.GAAZheader.path_to_segs = Aheader.model( Aheader.Aindex).path_to_GAA;
  
  pth_add = '';
  if Aheader.Aindex > 1
    pth_add = strrep( [ filesep Aheader.model( Aheader.Aindex).id ], ' ', '_' );
  end

  noParms = struct( 'model', 'G', 'hindex', pth_add );

  [has_dir component_directory] = fs_create_path( 'unrotated', 'output', nd, 0, noParms );
  component_directory = [ pwd filesep component_directory ];

  [has_dir plot_directory] = fs_create_path( 'unrotated', 'plots', nd, 0, noParms );
  plot_directory = [ pwd filesep plot_directory ];

  if ( has_dir )

    vflag = ' -v7.3';


    if (  has_GC_var( GAheader, cc_var, GAtyp ) )		% BB file has been created
      save_file = fs_filename( 'mat', GAtyp, 'unrotated', noParms );
      save_file = [component_directory save_file];

      if ( ~isempty( funcs.clear_cache ) )  funcs.clear_cache(); end; funcs.memory_stats(); 

      % ---------------------------------------------------------
      % component extraction
      % ---------------------------------------------------------

      x = find( scan_information.processing.model.process.components == nd );
      if x & x <= size( scan_information.processing.model.process.svd, 2 )
        do_svd = scan_information.processing.model.process.svd(x);
      else
        do_svd = 1;  % -- default position
      end;
      
      if do_svd

        initialize_mat_file( save_file );
          
        if ~isempty(pop)
          pop.setMessage(  'Performing Singular Value Decomposition . . .' );
          pop.setPong(  1 );
        end;

        cc_file = Aheader.model( Aheader.Aindex).path_to_GAA;
        x = matfile_vars( cc_file, cc_mat, cc_var );
        m = max( x.sz_x, x.sz_y );
        if m > 1  % --- use standard svd on scalars
          C_Eigenvalues = load_GC_var( GAheader, 'C_Eigenvalues', GAtyp );
          [u3 d3 v3]=perform_svd([ cc_file cc_mat ] , cc_var, nd); % --= 
        else
          C_Eigenvalues = load_GC_var( GAheader, 'C_Eigenvalues', GAtyp );
          CC = load_GC_var( Gheader, cc_var, GAtyp );
          [u3 d3 v3]=svd( CC); % --= 
          clear CC;
        end
      
        if ~isempty(pop)
          pop.setPong( 0 );
        end;
      
        funcs.memory_stats(); 

        
        % ---------------------------------------------------------
        % verify no NaN 
        if ( isnan( sum(sum(u3)) ) | isnan( sum(sum(d3)) ) | isnan( sum(sum(v3)) ) )
          abort_proc = 1;
          str = 'Applying svd to C * C'' has resulted in a Nan.';
          show_message( 'Data Calculation Error', str );
          return;
        end

        d3=sqrt(d3); % --= 
        save( save_file, 'u3', 'd3', 'v3', 'nd', '-append', '-v7.3' );

      else
          
        load( save_file, 'u3', 'd3', 'v3' );
          
      end  % -- bypass svd stage
      
      if ~isempty(pop)
        pop.setMessage(  'Calculating Loadings' );
      end;

      C_Eigenvalues = load_GC_var( GAheader, 'C_Eigenvalues', GAtyp );

      % ------------------------------------------------
      % --- force G application to be only on all subjects
      % ------------------------------------------------
      tsum = Zheader.tsum; % --= 
      GroupIndex = 0;
      SubjectVector = [ 1:Zheader.num_subjects ];
      % --= 

      psum = sum(C_Eigenvalues); % --= 
      ppsum=100*(psum/tsum)  ; % --= 
      % --= 

      Zheader.summaries.GZ.SS.Explained = psum; 
      Zheader.summaries.GZ.SS.pct = ppsum;
      % --= 

      % --- size of d3 from svd_power is square matrix ( nd x nd )
      dsum = sum(sum(d3.^2)); % --= 
      pdsum=100*(dsum/psum); % --= 
      ppdsum=100*(dsum/tsum); % --= 
      % --= 

      Zheader.summaries.GZ.ND.Explained = dsum;
      Zheader.summaries.GZ.ND.pct = pdsum;
      Zheader.summaries.GZ.ND.pct_tsum = ppdsum;

      snr = sqrt(Zheader.total_scans);   % --= 
      % --= 
      save( save_file, 'tsum','psum','ppsum','dsum','pdsum','ppdsum','snr','GroupIndex','-append','-v7.3');

      %------------------------------------------------
      % creation of U P and V
      %------------------------------------------------

      U = [];
      P = [];  
      V = [];
      Ph = [];
      PRh = [];         % --- no PR for H, but we still require the empty variable
      PR = [];
      
      if ~isempty(pop)
        pop.setIterations( size(SubjectVector,2), pop.SECONDARY);
      end;

      in_dir = [ GAtyp 'Zsegs'];			% eg: GZ_segs, GAZ_segs
      
      load( [ in_dir filesep 'GAA_vars' ], 'GG' );
      [u d v] = svd( GG );
      gg = u * sqrtm(pinv(d)) * v';

      B = load_GC_var( Gheader, 'B', GAtyp );
      
      P = snr * gg * u3(:,1:nd);
      V = B' * u3(:,1:nd )/ snr;


      for idx=1:size(SubjectVector,2)
      
        SubjectNo = SubjectVector( idx );
        sid = subject_id( SubjectNo );
        in_GAA = [ in_dir filesep Gheader.prefix 'AA_S' num2str(SubjectNo) ];

        load( in_GAA, 'GAA' );
        U = [U; GAA * P];
        
        if ~isempty(pop)
          pop.setParticipant( SubjectNo, Zheader.num_subjects, sid );      
        end;
 
        if ( ~isempty( funcs.clear_cache ) )  
          funcs.clear_cache();  
        end; 
        funcs.memory_stats();

      end;
      
      if ( ~isempty( funcs.memory_stats ) ) 
        funcs.memory_stats(); 
      end;

      % allows us to use the same variable names in the following calculations as in the original code
      nr = Zheader.total_scans;
      nc = Zheader.total_columns;

      save( save_file, 'U', 'P*', 'V', 'nr', 'nc', 'nd', '-append', '-v7.3');
      clear U P

      for FrequencyNo = 1:max(scan_information.frequencies,1)
        start_col = (FrequencyNo - 1) * Zheader.total_columns + 1;
        end_col = start_col + Zheader.total_columns - 1;
        ftag = frequency_tag(FrequencyNo);

        thisVR = V(start_col:end_col,:);
        eval( ['ep' ftag ' = calc_ext_Pos_Neg(thisVR);' ] );

      end;

      if ~isempty(pop)
        pop.clearParticipant();
      end;

      if ( ~isempty( funcs.clear_cache ) )  
        funcs.clear_cache(); 
      end; 
      funcs.memory_stats(); 

      % --- ep will already be calculated if not frequencied Meg data
      if scan_information.frequencies > 1 ep = calc_ext_Pos_Neg(V);  end;

      VR = V;	% set the same vars used by rotated stats to the non rotated solutions

      nullset = zeros( 1, nd );

      cvariance_unrotated_tot = component_variance( Aheader.model( Aheader.Aindex).sd(2), V );
      cvariance_rotated_tot = cvariance_unrotated_tot;

      save( save_file, 'VR', 'ep*', 'cvariance*' ,'-append', '-v7.3');
      clear V VR

      load( save_file, 'U');
      UR = U;
      save( save_file, 'UR', '-append', '-v7.3');

      text_file = fs_filename( 'txt', 'GnotA', 'unrotated', noParms );
      text_file = [ 'output_' text_file ];

      fid = fopen( [component_directory text_file], 'w' );
      fprintf('\n\n' );
      text_file_header( nd, fid, log_fid, component_directory, text_file, Aheader.Aindex );
      pca_summary( Aheader.model( Aheader.Aindex).sd(2), 'GnotA', cvariance_unrotated_tot, fid );
      print_UR_coefficents( fid, corrcoef( UR ) );
      display_extremes_pos_neg(ep, cvariance_rotated_tot, Zheader.tsum, fid, 2, log_fid );
      if ( fid ) fclose( fid ); fid = 0; end;

      pca_summary( Aheader.model( Aheader.Aindex).sd(2), 'GnotA', cvariance_unrotated_tot, 1 );
      
      clear U UR

      load( save_file, 'P');
      PR = P;
      save( save_file, 'PR*', '-append', '-v7.3');

      if ( ~isempty( funcs.memory_stats ) ) funcs.memory_stats(); end;

      %----------------------------------------
      % positive/negative betas of C for each component
      %----------------------------------------
      
      % --- clear up larger variables before calulating betas
      clear G P* thisVR Vn gg u3 d3 v3 C_Eigen*

      if ( ~isempty( funcs.clear_cache ) )  
        funcs.clear_cache(-1);    % -- force cache clearance priot to beta calc
      end; 
    end;  % --- BBG file exists ---

  end;	% -- output directory exists

  if ~isempty(pop)
    pop.clearParticipant();
    pop.clearRun();
    pop.clearFrequency();
  end;

