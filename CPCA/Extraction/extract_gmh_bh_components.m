function abort_proc = extract_gmh_bh_components( funcs, nd, pop )
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

  noParms = struct( 'model', 'H', 'mode', 'GMH', 'htype', 'HnotG', 'hindex',  H_ID );
  [has_dir component_directory] = fs_create_path( 'unrotated', 'output', nd, 0, noParms );
  component_directory = [ pwd filesep component_directory ];

  if ( has_dir )

    % ---------------------------------------------------------
    % we can only extract if the H application produces a ZH.mat file
    % ---------------------------------------------------------
    in_h = [ H_Segments 'HnotG_vars.mat' ];
    x = exist( in_h, 'file' );

    if ( x == 2 )		% BB file has been created

      if ~isempty(pop)
        pop.setPong( 1 ); 
      end;

      load( in_h, 'BB' );
      [H HH hh] = load_H_matrix( Hheader, 1 );  
%      [ u d v ] = svd( Hheader.HH );
%      hh = u * sqrt(inv(d)) * v';
      
      save_file = fs_filename( 'mat', 'HnotG', 'unrotated', noParms );
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

      U = [];
      P = [];

      for SubjectNo = 1:Zheader.num_subjects

        retrieve_subject_G( Gheader, SubjectNo );
        GG = G'*G;
        [ u d v ] = svd( GG );
        gg = u * sqrtm(pinv(d)) * v';
        invGG = gg * gg;

        ZH = [];
        for RunNo = 1:Zheader.num_runs

          if isEncodedRun( SubjectNo, RunNo ) 
            ZHR = load_subject_BH_var( Hheader, SubjectNo, ['ZH_R' num2str(RunNo) ], 'GMH', 'ZH' );
%          load( [H_Segments 'ZH_S' num2str(SubjectNo) '.mat'], ['ZH_R' num2str(RunNo) ]);
            ZH = [ZH; ZHR ];
            clear ZHR
            if ( ~isempty( funcs.clear_cache ) )  funcs.clear_cache(); funcs.memory_stats(); end;
          end;
        end;

        U = [U; snr * ( ZH - ( G * invGG * G' * ZH ) ) * hh * v3(:,1:nd) * inv( d3(1:nd,1:nd) )];
        
      end;

      Ph = hh * v3(:,1:nd) * d3(1:nd,1:nd) / snr;
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
      URep = calc_ext_Pos_Neg(UR);
      
      nullset = zeros( 1, nd );

      cvariance_unrotated_tot = component_variance( Hheader.model(Hheader.Hindex).sum_diagonal.BH, V );
      cvariance_rotated_tot = cvariance_unrotated_tot;

      save( save_file, 'VR', 'UR*', 'PR*', 'cvariance*', 'ep', '-append', '-v7.3');
      clear V VR 

      if ( ~isempty( funcs.memory_stats ) ) funcs.memory_stats(); end;

      if ~isempty(pop)
        pop.setComment(  'Producing Output' ); 
        pop.increment( pop.PRIMARY ); 
      end;

      text_file = fs_filename( 'txt', 'HnotG', 'unrotated', noParms );
      text_file = [component_directory 'output_' text_file];

      fid = fopen( text_file, 'w' );

      text_file_header( nd, fid, 0, component_directory );
      H_matrix_header(Hheader, fid);
      pca_summary( Hheader.model(Hheader.Hindex).sum_diagonal.BH, 'HnotG', cvariance_unrotated_tot, fid );

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

      display_extremes_pos_neg(ep, cvariance_rotated_tot, tsum, fid, 4 );

      if ( fid ) fclose( fid ); fid = 0; end;

      %----------------------------------------
      % positive/negative betas of C for each component
      %----------------------------------------

      if ~isempty(pop)
        pop.setComment( 'Calculating Positive Betas' ); 
        pop.increment( pop.PRIMARY ); 
      end;
      betas_c_pos = calc_b_betas( save_file, [ H_Segments 'HnotG.mat' ], 1);

      if ~isempty(pop)
        pop.setComment( 'Calculating Negative Betas' ); 
        pop.increment( pop.PRIMARY ); 
      end;
      betas_c_neg = calc_b_betas( save_file, [ H_Segments 'HnotG.mat' ], 0);

      eval ( [ 'save( ''' save_file ''', ''betas_*'', ''-append'', ''-v7.3'')' ] );

    end;  % --- BBG file exists ---

  end;  % output directory exists


