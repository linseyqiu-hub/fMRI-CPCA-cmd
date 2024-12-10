function abort_proc = extract_gmh_components( funcs, nd, pop )
% extract nd components from ZH data
% creates the H_nd{x}_unrotated.mat data set for ZH extraction and imaging
%
global Zheader scan_information process_information 

  if ( nargin < 3 )  pop = [];  end;
  if ~strcmp( class(pop), 'cpca_progress' )
    pop = []; 
  end

  abort_proc = 0;

  load( Zheader.Limits.path );

  [H_ID H_Segments] = H_path_spec( Hheader, 'GMH' );
  Hheader.model(Hheader.Hindex).path_to_segs.GMH = H_Segments;

  noParms = struct( 'model', 'H', 'mode', 'GMH', 'hindex',  H_ID );
  [has_dir component_directory] = fs_create_path( 'unrotated', 'output', nd, 0, noParms );
  component_directory = [ pwd filesep component_directory ];

  if ( has_dir )

    if has_GMH_var( Hheader, 'GMH', 'BB' )		% BB file has been created

      in_h = [ H_Segments 'GMH_vars.mat' ];
        
      if ~isempty(pop)
        pop.setPong( 1 ); 
      end;

      load( in_h, 'B', 'BB', 'gmhh', 'H', 'HH', 'hh' );
    
      save_file = fs_filename( 'mat', 'GMH', 'unrotated', noParms );
      save_file = [component_directory save_file];
      initialize_mat_file( save_file );  
      
      % --= ---------------------------------------------------------
      % --= component extraction
      % --= ---------------------------------------------------------

      if ( ~isempty( funcs.clear_cache ) )  funcs.clear_cache(); funcs.memory_stats(); end;

      if ~isempty(pop)
        pop.setComment(  'Preforming SVD . . .' ); 
      end;

      % --= [u3 d3 v3] = svd( C );
      [u3 d3 v3]=svd(BB);
      if ( ~isempty( funcs.memory_stats ) ) funcs.memory_stats(); end;

      d3=sqrt(d3); % --= 
      save( save_file, 'u3', 'd3', 'v3', 'nd', '-v7.3', '-append' );

      if ~isempty(pop)
        pop.setComment(  '' ); 
        pop.increment( pop.PRIMARY ); 
      end;

      % --= 
      % ------------------------------------------------
      % --- force H application to be only on all subjects
      % ------------------------------------------------
      tsum = Zheader.tsum; % --= 
      GroupIndex = 0;
      SubjectVector = [ 1:Zheader.num_subjects ]; % --= 
      % --= 
      psum = trace(d3' * d3); % --= 
      ppsum=100*psum; % --= 
      % --=  

      dsum = trace(d3(1:nd,1:nd)' * d3(1:nd,1:nd) ); % --= 
      pdsum=100*(dsum/psum); % --= 
      ppdsum=100*(dsum/tsum); % --= 

      snr = sqrt(Zheader.total_scans); % --= 

      save( save_file, 'tsum','psum','ppsum','dsum','pdsum','ppdsum','snr','-append','-v7.3');

      %------------------------------------------------
      % creation of U P and V
      % full gg needs to be compiled from each subject gg
      %------------------------------------------------ 

      if ~isempty(pop)
        pop.setComment(  'Calculating Statistics' ); 
        pop.increment( pop.PRIMARY ); 
      end;

      load( Zheader.Model.path, 'Gheader');

      gw = sum( Gheader.subject_encoded ) * Gheader.bins;
%      ggf = zeros( gw  );
      er = 0;
      P = [];
      
      for SubjectNo = 1:Zheader.num_subjects

        gmhgg = load_subject_GMH_var( Hheader, SubjectNo, 'gmhgg', 'GMH'  );
        
        sr = er + 1;
        er = sr + (Gheader.subject_encoded(SubjectNo) * Gheader.bins) - 1;

        Ps = B(sr:er,:) * v3(:,1:nd) * inv( d3(1:nd,1:nd));  % --=
        P = [P; snr * gmhgg * Ps];

        if ( ~isempty( funcs.clear_cache ) )  funcs.clear_cache(); funcs.memory_stats(); end;
      end;

      clear Ps;

      U = [];
      er = 0;
      for SubjectNo = 1:Zheader.num_subjects
          
        retrieve_subject_G( Gheader, SubjectNo );
        sr = er + 1;
        er = sr + (Gheader.subject_encoded(SubjectNo) * Gheader.bins) - 1;
        U = [U; G * P(sr:er,:)]; 

        if ( ~isempty( funcs.clear_cache ) )  funcs.clear_cache(); funcs.memory_stats(); end;
      end;

      Ph = gmhh * v3(:,1:nd) * d3(1:nd,1:nd) / snr; % --= 
      V = H * Ph;

      % -- allows us to use the same variable names in the following calculations as in the original code
      nr = Zheader.total_scans;
      nc = Zheader.total_columns;
      ndGA = nd;

      save( save_file, 'U', 'P*', 'V', 'nr', 'nc', 'ndGA', '-append', '-v7.3');

      if sum(sum(H')) < size(V,1)
        ep = calc_ext_Pos_Neg(V, 1); % --= 
      else
        ep = calc_ext_Pos_Neg(V); % --= 
      end;
      % --= 
      VR = V;	% --= set the same vars used by rotated stats to the non rotated solutions
      UR = U;
      PR = P;
      PRh = Ph;
      
      nullset = zeros( 1, nd );

      cvariance_unrotated_tot = component_variance( Hheader.model(Hheader.Hindex).sum_diagonal.GMH, V );
      cvariance_rotated_tot = cvariance_unrotated_tot;

      URcf = corrcoef( [VR H] );
      URcv = cov( [VR H] );

      save( save_file, 'VR', 'UR*', 'PR*', 'cvariance*', 'ep', '-append', '-v7.3');
      clear V VR

      if ( ~isempty( funcs.memory_stats ) ) funcs.memory_stats(); end;

      if ~isempty(pop)
        pop.setComment(  'Producing Output' ); 
        pop.increment( pop.PRIMARY ); 
      end;

      text_file = fs_filename( 'txt', 'GMH', 'unrotated', noParms );
      text_file = [component_directory 'output_' text_file];

      fid = fopen( text_file, 'w' );

      text_file_header( nd, fid, 0, component_directory );
      H_matrix_header(Hheader, fid);
      pca_summary( Hheader.model(Hheader.Hindex).sum_diagonal.GMH, 'GMH', cvariance_unrotated_tot, fid );

      cUR = corrcoef( UR ); % --= 
      fprintf( '\n\nCorrelation coefficients of UR\n------------------------------------------\n' );
      if (fid) fprintf( fid, '\n\nCorrelation coefficients of UR\n------------------------------------------\n' ); end;

      for ii=1:size(cUR,1) 
        z=[]; 
        for jj = 1:size(cUR,2) 
          y = sprintf( '\t%.2f', cUR(ii,jj) ); 
          z = [z y];
        end; 
        fprintf( '%s\n', z );
        if ( fid ) fprintf( fid, '%s\n', z ); end;

      end;

      fprintf( '\nExtreme Positive negative loading for unrotated components:' );
      if ( fid ) fprintf( fid, '\nExtreme Positive negative loading for unrotated components:' ); end;
      display_extremes_pos_neg(ep, cvariance_rotated_tot, tsum, fid, 4 );

      if ( fid ) fclose( fid ); fid = 0; end;

      pca_summary( Hheader.model(Hheader.Hindex).sum_diagonal.GMH, 'GMH', cvariance_unrotated_tot, 1 );

      %----------------------------------------
      % positive/negative betas of C for each component
      %----------------------------------------

      if ~isempty(pop)
        pop.setComment( 'Calculating Positive Betas' ); 
        pop.increment( pop.PRIMARY ); 
      end;
      betas_c_pos = calc_gmh_gm_betas( save_file, Hheader, 1, pop);

      if ~isempty(pop)
        pop.setComment( 'Calculating Negative Betas' ); 
        pop.increment( pop.PRIMARY ); 
      end;
      betas_c_neg = calc_gmh_gm_betas( save_file, Hheader, 0, pop );

      eval ( [ 'save( ''' save_file ''', ''betas_*'', ''-append'', ''-v7.3'')' ] );

      %----------------------------------------
      % output UR set to intial 0 per component
      %----------------------------------------

      noParms.var = 'HRF';
      noParms.component = 999;
      PR_file = fs_filename( 'txt', 'GMH', 'unrotated', noParms );
      output_HRF( component_directory, PR_file, PR, Gheader);

    end;  % --- BBG file exists ---

  end;  % output directory exists

  if ~isempty(pop)
    pop.setComment(  '' ); 
    pop.setPong(0);
    pop.increment( pop.PRIMARY ); 
  end;


