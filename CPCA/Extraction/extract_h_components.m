function abort_proc = extract_h_components( nd, model, pop )
% extract nd components from HZ data
% creates the H_nd{x}_unrotated.mat data set for HZ extraction and imaging
%
global Zheader scan_information process_information 

  abort_proc = 1;
  if ( nargin < 2 )  return;  end;
  if ( nargin < 3 )  pop = [];  end;
   if ~strcmp( class(pop), 'cpca_progress' )
    pop = []; 
  end

  abort_proc = 0;

  load( Zheader.Limits.path);

  [H_ID H_Segments] = H_path_spec( Hheader, model );
  eval( [ 'Hheader.model(Hheader.Hindex).path_to_segs.' model ' = H_Segments;'] );

  noParms = struct( 'model', 'H', 'mode', model, 'hindex',  H_ID );
  [has_dir component_directory] = fs_create_path( 'unrotated', 'output', nd, 0, noParms );
 
  if ( has_dir )

    Txt  = ['Extracting ' num2str(nd) ' components from ' model];
    if ~isempty(pop)
      pop.setProcess(Txt);
    end;

    in_h = [ H_Segments model '.mat' ];
    x = exist( in_h, 'file' );

    if ( x == 2 )		% BB file has been created
      load( in_h, 'BB' );
      
      save_file = fs_filename( 'mat', model, 'unrotated', noParms );
      save_file = [component_directory save_file]
      initialize_mat_file( save_file );

      % --= ---------------------------------------------------------
      % --= component extraction
      % --= ---------------------------------------------------------

      if ~isempty(pop)
        pop.setMessage(  'Performing Singular Value Decomposition . . .' );
        pop.setPong(  1 );
      end;

      % --= [u3 d3 v3] = svd( BB );
      [u3 d3 v3] = svd(BB);

      if ~isempty(pop)
        pop.setPong( 0 );
      end;
      
%      d3 = sqrt(d3); % --= 
      save( save_file, 'u3', 'd3', 'v3', 'nd', '-append', '-v7.3' );

      if ~isempty(pop)
        pop.setMessage( 'Calculating Loadings' ); 
      end;

      % --= 
      % ------------------------------------------------
      % --- force H application to be only on all subjects
      % ------------------------------------------------
      if model == 'ZH'
        tsum = Zheader.tsum; % --= 
      else
        tsum = Zheader.tsum_E; % --= 
      end;
      
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
      %------------------------------------------------ 
      [H HH hh] = load_H_matrix( Hheader, 1 );

      U = [];
      V = [];
      P = [];
      Ph = hh * v3(:,1:nd) * sqrt(d3(1:nd,1:nd)) / snr;
%      V = H * Ph;
      
      if ~isempty(pop)
        pop.setIterations( Zheader.num_subjects, pop.SECONDARY);
      end;

      for SubjectNo=1:Zheader.num_subjects

        sid = subject_id( SubjectNo );
        if ~isempty(pop)
          pop.setParticipant( SubjectNo, Zheader.num_subjects, sid );      
          pop.increment(pop.SECONDARY);
        end;

        [H HH hh] = load_H_matrix( Hheader, SubjectNo );
        in_ZH = [ H_Segments model '_S' num2str(SubjectNo) ];

         eval( [ 'V' num2str(SubjectNo) ' = H * Ph;' ] );
         if isempty(V)
           eval( [ 'V = V' num2str(SubjectNo) ';' ] );
         else
           eval( [ 'V = reshape( mean( [V(:) V' num2str(SubjectNo) '(:) ], 2 ), size(V,1), size(V,2) );' ] );
         end;

         save( save_file, ['V' num2str(SubjectNo)], '-append', '-v7.3');
         eval( [ 'clear V' num2str(SubjectNo) ' ;' ] );

       
        for RunNo=1:Zheader.num_runs
          if isEncodedRun( SubjectNo, RunNo ) 

            retrieve_subject_ZH_run( Hheader, SubjectNo, RunNo );
            Un = snr * ZH * hh * v3(:,1:nd) * inv(sqrt(d3(1:nd,1:nd)));
            U = [U; Un];

            if ~isempty(pop)
              pop.increment(pop.PRIMARY);
            end;

          end;
        end;

      end;

      clear ZH
      
      if ~isempty(pop)
        pop.clearParticipant();
      end;

      % -- allows us to use the same variable names in the following calculations as in the original code
      nr = Zheader.total_scans;
      nc = Zheader.total_columns;

      save( save_file, 'U', 'P*', 'V', 'nr', 'nc', '-append', '-v7.3');

      ep = calc_ext_Pos_Neg(V); % --= 

      VR = V;	% --= set the same vars used by rotated stats to the non rotated solutions

      nullset = zeros( 1, nd );

      if ~isempty(pop)
        pop.setMessage( 'Calculating Variance' ); 
      end;
      
      sumDiag = 0;

      eval( ['sumDiag = Hheader.model(Hheader.Hindex).sum_diagonal.' model ';'] );
      cvariance_unrotated_tot = component_variance( sumDiag, VR, tsum );
      cvariance_rotated_tot = cvariance_unrotated_tot;

      save( save_file, 'VR', 'ep', '-append', '-v7.3');
%      clear V VR AR A

      if ~isempty(pop)
        pop.setMessage( 'Producing Output' ); 
      end;

      UR = U; % --= 
      URep = calc_ext_Pos_Neg(UR);
      save( save_file, 'U', 'UR', 'URep', 'cvariance*', '-append', '-v7.3');
      
      text_file = fs_filename( 'txt', model, 'unrotated', noParms );
      text_file = [component_directory 'output_' text_file];

      fid = fopen( text_file, 'w' );
      if ( fid )
        text_file_header( nd, fid, 0, component_directory );
        H_matrix_header(Hheader, fid);
        pca_summary( sumDiag, model, cvariance_unrotated_tot, fid, tsum );
        print_UR_coefficents( fid, corrcoef( UR ) );
        display_extremes_pos_neg(ep, cvariance_rotated_tot, tsum, fid, 4 );
        fclose( fid ); 
        fid = 0; 
      end;

      % --= 


      PR = P; % --= 
      PRh = Ph; % --= 

      save( save_file, 'PR*', '-append', '-v7.3');

      %----------------------------------------
      % positive/negative betas of C for each component
      %----------------------------------------
      if ~isempty(pop)
        str = sprintf( 'Calculating Beta C. . .' );
        pop.setMessage( 'Calculating Beta C. . .'  );  
      end;

      evalc( ['load( ''' [ H_Segments model '.mat' ] ''', ''B'' );'] );
      betas = corrcoef( [UR B] );
      betas = betas(end-(size(UR,2)-1):end,1:size(UR,2));

      if ~isempty(pop)
        pop.setMessage( ''  );  
      end;
      
      save( save_file, 'betas', '-append', '-v7.3');

      %----------------------------------------
      % output PR set to intial 0 per component
      %----------------------------------------
%       noParms.var = 'HRF';
%       noParms.component = 999;
%       out_file = fs_filename( 'txt', model, 'unrotated', noParms );
%       output_HRF( component_directory, out_file, PR, []);

    end;  % --- BBG file exists ---

  end;	% -- output directory exists

% --= 


