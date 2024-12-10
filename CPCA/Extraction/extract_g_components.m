function abort_proc = extract_g_components( funcs, nd, log_fid, pop, GAtyp, nv, mask_registry )
% apply the G model to the normalized Z data
% creates the G_unrotated.mat data set for G extraction and imaging
%
% note: G and GA processing was separated to a allow for unique G as well as GA if desired

global Zheader scan_information ;

% --- Primary Iterations
% --- size( SubjectVector ) * 2;            - default [ 1:Zheader.num_subjects ]

  if ( nargin < 3 ),  log_fid = 0;  end;
  if ( nargin < 4 ),  pop = [];  end;
  if ( nargin < 5 ),  GAtyp = 'G';  end;
  if ( nargin < 6 ),  nv = 0;  end;
  if ( nargin < 7 ),  mask_registry = 0;  end;
  if ~isa( pop, 'cpca_progress' ),     pop = [];    end

  ind = [];
  if mask_registry > 0;
    [~, ind] = mask_registrations( scan_information.mask, mask_registry );
  end

  abort_proc = 0;

  isROI = strcmp( GAtyp, 'ROI' );
  nFreqs = max( scan_information.frequencies, 1);
  
  if strcmp( GAtyp, 'GA')
    abort_proc = extract_ga_components( funcs, nd, log_fid, pop, GAtyp );
    return;
  end;
  
  if strcmp( GAtyp, 'GAA')
    abort_proc = extract_gaa_components( funcs, nd, log_fid, pop, GAtyp );
    return;
  end;


  % ---------------------------------------------------------
  % with the volume of available extractions and rotations
  % the root directory is getting quite crowded, so we will
  % now put all extractions/rotations in a secondary directory
  % named n_components (where n = the number of components extracted)
  % ---------------------------------------------------------
  noParms = struct( 'model', 'G', 'reg', mask_registry, 'regTag', constant_define( 'REGISTRATION_TAG', mask_registry ) );
%  noParms = struct( 'model', 'G' );
  if isROI
    load G_ROI
    noParms.hindex = strrep( [ filesep 'ROI' filesep G_ROI.mask( G_ROI.Rindex).id ], ' ', '_' );
    noParms.model = 'G';
    noParms.ROIGZ = [ noParms.model filesep strrep( G_ROI.mask( G_ROI.Rindex).id, ' ', '_' ) filesep 'GZsegs'];

    indexes = load( [ 'ROI' filesep 'data' filesep 'ROI_' num2str(G_ROI.Rindex, '%02d') '_' strrep( G_ROI.mask( G_ROI.Rindex).id, ' ', '_' ) ] );
    
  end;

  cc_var = ['CC' constant_define( 'REGISTRATION_TAG', mask_registry ) ];
%  cc_var = 'CC';
  cc_mat = 'GCC.mat';
  
  [has_dir, component_directory] = fs_create_path( 'unrotated', 'output', nd, 0, noParms );
  component_directory = [ pwd filesep component_directory ];

  if ~isROI
    [has_dir, plot_directory] = fs_create_path( 'unrotated', 'plots', nd, 0, noParms );
    plot_directory = [ pwd filesep plot_directory ];
  end
  
  if ( has_dir )

    load( Zheader.Model.path, 'Gheader');

    if isROI
      Gheader.ROIZheader.path_to_segs = [ 'GZsegs' filesep 'ROI' filesep strrep( G_ROI.mask( G_ROI.Rindex).id, ' ', '_' ) filesep ];
    end;
    
    if ( has_GC_var( Gheader, cc_var, GAtyp ) )		% BB file has been created
      save_file = fs_filename( 'mat', GAtyp, 'unrotated', noParms );
      save_file = [component_directory save_file];

      if ( ~isempty( funcs.clear_cache ) ),  funcs.clear_cache(); end; funcs.memory_stats(); 

      % ---------------------------------------------------------
      % component extraction
      % ---------------------------------------------------------

      x = find( scan_information.processing.model.process.components == nd );
      if x && x <= size( scan_information.processing.model.process.svd, 2 )
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

        cc_file = '';
        eval( [ 'cc_file = Gheader.' GAtyp 'Zheader.path_to_segs;' ] );
        x = matfile_vars( cc_file, cc_mat, cc_var );

        m = max( x.sz_x, x.sz_y );
        if m > 1  % --- use standard svd on scalars
          [ u3, d3, v3 ]=perform_svd([ cc_file cc_mat ] , cc_var, nd);
        else
          CC = load_GC_var( Gheader, cc_var, GAtyp );
          [ u3, d3, v3 ] = svd( CC );
          clear CC*;
        end
          
        d3=sqrt(d3); 
        save( save_file, 'u3', 'd3', 'v3', 'nd', '-append', '-v7.3' );
       
        if ~isempty(pop)
          pop.setPong( 0 );
        end;
      
        funcs.memory_stats(); 

        if isnan( sum(sum( u3 )) ) || isnan( sum(sum( d3)) ) || isnan( sum(sum(v3)) ) 
          show_message( 'NaN in SVD results', 'Applying svd to C * C'' has resulted in NaN.' );
          return;
        end

      end  % -- bypass svd stage
      
      if ~isempty(pop)
        pop.setMessage(  'Calculating Loadings' );
      end;

      eigvar = ['C' constant_define( 'REGISTRATION_TAG', mask_registry ) '_Eigenvalues'];
      C_Eigenvalues = load_GC_var( Gheader, eigvar, GAtyp );

      switch mask_registry
          case 0
            tsum = Zheader.tsum;
          case 1   % -- Gray, Brainstem and Cerebellum
            tsum = Zheader.rsum(1) + Zheader.rsum(4) + Zheader.rsum(5);
          case 2
            tsum = Zheader.rsum(2);
      end
      
      if isROI
        tsum = G_ROI.mask( G_ROI.Rindex).tsum_ZTrim;
      end
      
      SubjectVector = 1:Zheader.num_subjects;
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
      save( save_file, 'tsum','psum','ppsum','dsum','pdsum','ppdsum','snr','-append','-v7.3');

      %------------------------------------------------
      % creation of U P and V
      %------------------------------------------------

      U = [];
      P = [];  
      V = [];
      Ph = [];
      PRh = [];         % --- no PR for H, but we still require the empty variable
      Pn = [];
      
      if ~isempty(pop)
        pop.setIterations( size(SubjectVector,2), pop.SECONDARY);
      end;

      nvox = Zheader.total_columns;
      if isROI
        nvox = nvox - size( indexes.Gindex, 1 );
      else
        if ~isempty( ind )
           nvox = numel( ind );
        end
      end;
      
      V = zeros( nvox * nFreqs, nd );

      for idx=1:size(SubjectVector,2)
      
        SubjectNo = SubjectVector( idx );
        sid = subject_id( SubjectNo );

        B = [];
        for FrequencyNo=1:nFreqs
          ftag = frequency_tag(FrequencyNo) ;
          Bn = load_subject_B( Gheader, SubjectNo, ftag, GAtyp );
          if ~isempty( ind )
            Bn = Bn(:,ind);
          end
          B = [B Bn];
        end;
        clear Bn;
        
        if ~isempty(pop)
          pop.setParticipant( SubjectNo, Zheader.num_subjects, sid );      
        end;
 

        if ( ~isempty( funcs.clear_cache ) )  
          funcs.clear_cache();  
        end; 
        funcs.memory_stats();

        %------------------------------------------------
        % load in the normalized subject Model segment
        %------------------------------------------------
        if isROI
          G = [];
          for RunNo = 1:Zheader.num_runs
            G = [G; load_subject_GC_run(Gheader, SubjectNo, RunNo, ftag, 'G' )]; 
          end
          G = G(:, indexes.Gindex);
          [u d v] = svd( G );
      
          if nv > 0
            G = u(:,1:nv);
          end
          
        else
          retrieve_subject_G( Gheader, SubjectNo );
        end;
        gg = sqrtm(pinv( G'*G ) );

          
        if SubjectNo == 1 || strcmp( GAtyp, 'GA' )
          sp = 1;
        else
          if strcmp( GAtyp, 'GA' ) || isROI
            sp = sp + size(gg,1);
          else
            sp = ( sum(Gheader.subject_encoded(1:SubjectNo-1) )*Gheader.bins ) + 1;
          end
          
        end;

        ep = sp + size(gg,1)-1;
  
        % --= P = snr * gg * u3(:,1:nd);
        eval ( [ 'Pn = snr * gg * u3(' num2str(sp) ':' num2str(ep) ',1:nd); ' ] );
        P = [ P; Pn ];

        % --= U = G * P;
        U = [U; G * Pn ];
  
        % --= V = C * u3(:,1:nd) /snr ;
        Vn =  B' * u3(sp:ep,1:nd) / snr ;
        V = V + Vn;
        eval( [ 'V' num2str(SubjectNo) ' = Vn;' ] );
        save( save_file, ['V' num2str(SubjectNo) ], '-append', '-v7.3');
        eval( [ 'clear V' num2str(SubjectNo) ' ;' ] );

        if ~isempty(pop)
          pop.increment();
        end;

      end;

      clear Pn B;

      if ( ~isempty( funcs.memory_stats ) ) 
        funcs.memory_stats(); 
      end;

      % allows us to use the same variable names in the following calculations as in the original code
      nr = Zheader.total_scans;
      nc = Zheader.total_columns;
      if ~isempty( ind )
        nc = numel( ind ); 
      end

      save( save_file, 'U', 'P*', 'V', 'nr', 'nc', 'nd', 'mask_registry', '-append', '-v7.3');
      clear U P

      for FrequencyNo = 1:max(scan_information.frequencies,1)
        start_col = (FrequencyNo - 1) * nvox + 1;
        end_col = start_col + nvox - 1;
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

      sd = Gheader.GZheader.sum_diagonal;
      tag = 'GC';
      if isROI
        sd =  G_ROI.mask( G_ROI.Rindex ).sum_diagonal;
        tag = 'GCr';
      else
        if ~isempty( ind )
          tsum = Zheader.tsum; 
          switch mask_registry
              case 1
                sd = Gheader.GZheader.rsum(1) + sum(Gheader.GZheader.rsum(4:5));
                tsum = Zheader.rsum(1) + sum(Zheader.rsum(4:5));
              case 2
                sd = Gheader.GZheader.rsum(2);
                tsum = Zheader.rsum(2);
          end
        end  
      end;
      
      cvariance_unrotated_tot = component_variance( sd, V );
      cvariance_rotated_tot = cvariance_unrotated_tot;

      save( save_file, 'VR', 'ep*', 'cvariance*' ,'-append', '-v7.3');
      clear V VR

      load( save_file, 'U');
      UR = U;
      save( save_file, 'UR', '-append', '-v7.3');

      text_file = fs_filename( 'txt', GAtyp, 'unrotated', noParms );
      text_file = [ 'output_' text_file ];

      fid = fopen( [component_directory text_file], 'w' );
      fprintf('\n\n' );
      text_file_header( nd, fid, log_fid, component_directory, text_file, 0, nvox );
     pca_summary( sd, [tag constant_define( 'REGISTRATION_SUMMARY_TAG', mask_registry )], ...
         cvariance_unrotated_tot, fid, tsum );
%      pca_summary( sd, tag, cvariance_unrotated_tot, fid, tsum );
      print_UR_coefficents( fid, corrcoef( UR ) );
      display_extremes_pos_neg(ep, cvariance_rotated_tot, tsum, fid, 2, log_fid );
      if ( fid ), fclose( fid );  end;

      pca_summary( sd, [tag constant_define( 'REGISTRATION_SUMMARY_TAG', mask_registry )], cvariance_unrotated_tot, 1, tsum );
%      pca_summary( sd, tag, cvariance_unrotated_tot, 1, tsum );
      
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

     
      if ~isempty(pop)
        pop.setMessage( 'Calculating Positive Betas. . .');
        pop.setPong( 1 );
      end;
      
      if ( ~isempty( funcs.clear_cache ) )  
        funcs.clear_cache(-1);    % -- force cache clearance priot to beta calc
      end; 
      funcs.memory_stats(); 
      betas_c_pos = calc_c_betas( save_file, Gheader, 1, 0 , GAtyp, mask_registry );

      if ~isempty(pop)
        pop.setMessage( 'Calculating Negative Betas. . .' );
      end;
      if ( ~isempty( funcs.clear_cache ) )  
        funcs.clear_cache(-1);    % -- force cache clearance priot to beta calc
      end; 
      funcs.memory_stats(); 
      betas_c_neg = calc_c_betas( save_file, Gheader, 0, 0, GAtyp, mask_registry );

      if ~isempty(pop)
        pop.setPong( 0 );
        pop.setMessage( 'Producing statistics output. . .' );
      end;
      
      save( save_file, 'betas_*', '-append', '-v7.3');

      if ~strcmp( GAtyp, 'GA' ) && ~isROI
        %----------------------------------------
        % output UR set to intial 0 per component
        %----------------------------------------
        noParms.var = 'HRF';
        noParms.component = 999;
        out_file = fs_filename( 'txt', GAtyp, 'unrotated', noParms );
        load( save_file, 'PR');
        output_HRF( component_directory, out_file, PR, Gheader, 0, nvox);
        plot_HRF( plot_directory, PR, Gheader, noParms );
      end
      
      % --- some older systems display a tendency to not open the file in append mode fast enough
      % --- and the subject variance is not written.   
      if ~isROI
        fid = fopen( [component_directory text_file], 'a' );
        if ~fid>0
          pause(2);	
        end;
        % --- If the file is not open for append, wait 2 seconds and test again
        print_subject_variances( fid, mask_registry );  
      
        fprintf( fid, '\n');
        fclose( fid );
      end
      
    end;  % --- BBG file exists ---

  end;	% -- output directory exists

  if ~isempty(pop)
    pop.clearParticipant();
    pop.clearRun();
    pop.clearFrequency();
  end;

