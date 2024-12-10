function result = rotate_h_components( funcs, rotation_params, nd, log_fid, pop )
% rotate extracted components from applied G*Z data
%
%  A return value of 0 flags operational error and aborts further processing in GUI

global Zheader scan_information 
% --- Primary Iterations
% --- 4

  if ( nargin < 4 )  log_fid = 0;  end;
  if ( nargin < 5 )  pop = 0;  end;
  if ~strcmp( class(pop), 'cpca_progress' )
    pop = []; 
  end

  result = 0;
  if ~isfield( rotation_params, 'model' )   return;  end;

  load( Zheader.Limits.path );

  [H_ID H_Segments] = H_path_spec( Hheader, 'GMH' );
  rotation_params.hindex = H_ID;
  
  component_directory = fs_path( 'unrotated', 'output', nd, 0, rotation_params   );
  in_file = fs_filename( 'mat', rotation_params.htype, 'unrotated', struct( 'model', 'H')  );
  load( [component_directory in_file], 'V', 'U', 'P*', 'ep', 'cvariance*', 'betas_c*', 'betas_c_neg', 'component_loadings', 'psum', 'ppsum', 'dsum', 'pdsum', 'ppdsum' );

  Normalized_Z_Dir = Z_Directory();
  in_h = [ H_Segments rotation_params.htype '.mat' ];

  component_orientation_data = [];

  if ( ~isempty( funcs.memory_stats ) ) funcs.memory_stats(); end;

  for ii = 1:size(ep,1)
    % beta averages
    thr = min( size(ep(1).percentiles, 1), constant_define( 'PREFERENCES', 'threshold.default' ) );
    avg_pos = mean(mean(betas_c_pos(ii).threshold(thr).betas(3:end,:)));
    avg_neg = mean(mean(betas_c_neg(ii).threshold(thr).betas(3:end,:)));
    % now require load average
    avgl_pos = component_loadings(ii).pos.mean;
    avgl_neg = component_loadings(ii).neg.mean;
    component_orientation_data = [component_orientation_data; ep(ii).percentiles( thr).pos_voxels avg_pos avgl_pos ep(ii).percentiles( thr ).neg_voxels avg_neg avgl_neg ];
  end;

  clear ep;		% do not hold onto variables from unrotated data

  compute_comps = 0;

  has_dir = fs_create_path( 'rotated', 'images', nd, 0, rotation_params );

  H = load_H_matrix( Hheader, 1 );

  component_directory = fs_path( 'rotated', 'output', nd, 0, rotation_params );
  component_directory = [pwd filesep component_directory];

  Gheader = [];
  if ( rotation_params.model == 'G' )
    load( Zheader.Model.path, 'Gheader' );
    rotation_params.prefix = 'G';
  else
    if strcmp( rotation_params.htype, 'GMH' )
      load( Zheader.Model.path, 'Gheader' );
    end;
    rotation_params.prefix = 'H';
  end;

  nr = Zheader.total_scans;
  nc = Zheader.total_columns;

  sumDiag = 0;
  % --- determine proper tsum/GC sum diag values for model
  eval( ['sumDiag = Hheader.model(Hheader.Hindex).sum_diagonal.' rotation_params.htype ';' ] );  
  if rotation_params.mode(1) == 'E'
    tsums = Zheader.tsum_E;
  else
    tsums = Zheader.tsum;
  end;

  mat_file = fs_filename( 'mat', rotation_params.htype, rotation_params.method, rotation_params.defaults );
  initialize_mat_file( [component_directory mat_file] );

  if nd > 0

    if ~isempty(pop)
      pop.setPong( 1 );
    end;

    [T PR VR UR] = compute_facs( P, U, V, nd, tsums, nr, nc, Gheader, rotation_params, pop );
    if ( isempty( T ) )       
      if ~isempty(pop)
        pop.setPong( 0 );
      end;
      return;      
    end;		% comp_facs will return all empty if unable to rotate
   
%     if strcmp(rotation_params.method, 'procrustes' ) & strcmp(rotation_params.htype, 'GMH' )
%       PRh = Ph * T';
%     else
      PRh = Ph * inv(T');
%     end;
    
    % --- GMH::GMH Precrustes = PRh = Ph * T;
    
    if ( ~isempty( funcs.memory_stats ) ) funcs.memory_stats(); end;
    if ~isempty(pop)
      pop.setComment( 'Calculating statistics . . .' );
    end;
    [PR VR UR cvariance_rotated_tot] = calc_rotation_stats( PR, UR, VR, T, nd, rotation_params, pop );        
    [ur vr PRh cvariance_rotated_tot] = realign_rotated_components( U, V, PRh, cvariance_rotated_tot );

    if ~isempty(pop)
      pop.increment( pop.PRIMARY );
    end;

    PRep = calc_ext_Pos_Neg(PRh);

    theseParms = rotation_params.defaults;
    theseParms.var = 'T';
    T_file = fs_filename( 'mat', rotation_params.htype, rotation_params.method, theseParms );

    eval( [ 'save( ''' component_directory T_file ''', ''T'' )'] );
    save( [component_directory T_file], 'T', '-v7.3' );
    save( [component_directory mat_file], 'P*', 'U*', 'V*', 'T', 'cvariance*', 'rotation_params', 'component_orientation_data', 'psum', 'ppsum', 'dsum', 'pdsum', 'ppdsum', '-append', '-v7.3' );

    txt_file = fs_filename( 'txt', rotation_params.htype, rotation_params.method, rotation_params.defaults );
    text_file = [ 'output_' txt_file ];
%    text_file = [ component_directory 'output_' txt_file ];
    fid = fopen( [component_directory text_file], 'w' );
    text_file_header( nd, fid, log_fid, component_directory, text_file )
    H_matrix_header(Hheader, fid);
    pca_summary( sumDiag, rotation_params.htype, cvariance_rotated_tot, fid, tsums );
    if ( fid ) fclose( fid ); fid = 0; end;

    % ------------------------------------------------
    % --- force G application to be only on all subjects
    % ------------------------------------------------
    nr = Zheader.total_scans;
    nremoved = Zheader.tsum_trends;
    GroupIndex = 0;
    SubjectVector = [ 1:Zheader.num_subjects ];

%    ep = calc_ext_Pos_Neg(VR);
    if sum(sum(H')) < size(V,1)
      ep = calc_ext_Pos_Neg(V, 1); % --= 
    else
      ep = calc_ext_Pos_Neg(V); % --= 
    end;

    URcf = corrcoef( [VR H] );
    URcv = cov( [VR H] );

    save( [component_directory mat_file], 'ep', 'URcf', 'URcv', '-append' );

    if ( ~isempty( funcs.memory_stats ) ) funcs.memory_stats(); end;

    %----------------------------------------
    % summarize
    %----------------------------------------
    fid = fopen( [component_directory text_file], 'a+' );
    print_UR_coefficents( fid, corrcoef( UR ) );
    print_matrix_values( fid, T, 'T matrix:' );
    display_extremes_pos_neg(ep, cvariance_rotated_tot, Zheader.tsum, fid, 2, log_fid );
    if ( fid ) fclose( fid ); fid = 0; end;

    result = nd;

    %----------------------------------------
    % positive/negative betas of C for each component
    %----------------------------------------]
 
    if ~isempty(pop)
      pop.setComment( 'Recomputing for beta check. . .' );
      pop.increment( pop.PRIMARY );
    end;

%    fn = fs_filename( 'mat', 'G', rotation_params.method, rotation_params.defaults );
    fnm = [component_directory mat_file];
    if isempty( Gheader )
      load( Zheader.Model.path, 'Gheader');
    end;

    if strcmp( rotation_params.mode, 'GMH' )
        
      switch rotation_params.htype
          
        case 'GC'
          if ~isempty(pop)
            pop.setComment( 'Positive Betas . . .' );
          end;
          betas_c_pos = calc_gmh_gc_betas( fnm, Gheader, Hheader, 1, pop );
            
          if ~isempty(pop)
            pop.setComment( 'Negative Betas . . .' );
          end;
          betas_c_neg = calc_gmh_gc_betas( fnm, Gheader, Hheader, 0, pop );
            
        case 'BH'
          evalc( ['load( ''' in_h ''', ''B'' );'] );
          betas = corrcoef( [UR B] );
          betas = betas(end-(size(UR,2)-1):end,1:size(UR,2));
              
        case 'GMH'
          if ~isempty(pop)
            pop.setComment( 'Positive Betas . . .' );
          end;
          betas_c_pos = calc_gmh_gm_betas( fnm, Hheader, 1, pop );
          
          if ~isempty(pop)
            pop.setComment( 'Negative Betas . . .' );
          end;
          betas_c_neg = calc_gmh_gm_betas( fnm, Hheader, 0, pop );
            
      end;
      
    else
      evalc( ['load( ''' in_h ''', ''B'' );'] );
      betas = corrcoef( [UR B] );
      betas = betas(end-(size(UR,2)-1):end,1:size(UR,2));
        
    end;

    if ~isempty(pop)
      pop.setComment( 'Saving . . .' );
    end;
    save( [component_directory mat_file], 'betas_*', '-append', '-v7.3' );
    if ~isempty(pop)
      pop.setComment( '' );
      pop.increment( pop.PRIMARY );
    end;

    %----------------------------------------
    % output UR set to intial 0 per component
    %----------------------------------------

    if ( isfield ( pop, 'pb' ) )
      if ~isempty(pop)
        pop.setComment( 'Producing output . . .' );
      end;
    end;

    if strcmp( rotation_params.mode, 'GMH')  % -- only produce HRF for GMH::GMH or GMH::GC
      if ~strcmp( rotation_params.htype, 'BH')     
        theseParms = rotation_params.defaults;
        theseParms.var = 'HRF';
        theseParms.component = 999;
        out_file = fs_filename( 'txt', rotation_params.htype, rotation_params.method, theseParms );

        if ~isempty(PR)
          output_HRF( component_directory, out_file, PR, Gheader);
        end;

        if ~isempty(PRh)
          ftag = '';
          mniParms.text = ftag;
          mniParms.var = 'H_Predictor_Weights';
          for component_no = 1:size(PRh,2)
            mniParms.component = component_no;
            mni_file = fs_filename( 'txt', rotation_params.htype, '', mniParms );

            fid = fopen( [component_directory mni_file], 'w' );
            text_file_header( nd, fid, 0, component_directory, mni_file );
            H_matrix_header(Hheader, fid);
            pca_summary( sumDiag, rotation_params.htype, cvariance_rotated_tot, fid );
            print_formatted_ep( ep, component_no, fid, 0 );
            show_PR_weights( PRh(:,component_no), VR(:,component_no), Hheader, 1, fid );

            if ( fid)  fclose(fid); end;
          end;
        end;

      end;
    end;
  end

  if ( ~isempty( funcs.memory_stats ) ) funcs.memory_stats(); end;

  if ~isempty(pop)
    pop.setPong( 0 );
    pop.setComment( '' );
    pop.increment( pop.PRIMARY );
  end;

  if ( rotation_params.defaults.subject_stats == 1 )

    if isfield( rotation_params, 'mode' )
      if rotation_params.mode == 'GMH'  return; end;    % --- subject specific for GMH handled differently
    end;

    %----------------------------------------
    % Alternate VR - 1 image each for subject/component
    %----------------------------------------

    if ( strcmp( class(pop), 'progress_diaplay' ) )
      str = sprintf( 'Calculating Subject VR''s', nd );
      pop = pop.setMessage( str );
      pop = pop.setPercent( 1, 1 );
      pop = pop.clearSubject();
      pop = pop.clearRun();
      pop.activate();
      pop.refresh();
    end;

    [ok outdir] = fs_create_path( 'subject', 'output', nd, 0, rotation_params );

    outdir = fs_path( 'subject', 'output', nd, 0, rotation_params );
    outdir = [pwd filesep outdir];


    %eval ( [ 'load( ''' component_directory mat_file ''', ''PR'')' ] );
    eval ( ['load( ''' Zheader.Model.path ''', ''Gheader'')' ] );

    num_comps = size(PR,2);
    PR_From = 0;
    PR_To = 0;

    out_mat = fs_filename( 'alt_vr', rotation_params.model, rotation_params.method, rotation_params.defaults );
    eval ( [ 'save( ''' outdir out_mat ''', ''num_comps'')' ] );

    VR_ss_cov = [];
    VR_ssm_cov = [];
    VR_ss_coef = [];
    VR_ssm_coef = [];

    for subjectNo = 1:Zheader.num_subjects

      eval( ['alt_VR_S' num2str(subjectNo) ' = [];'] );
      eval( ['alt_VR_coeff_S' num2str(subjectNo) ' = [];'] );

      if ( ~isempty( funcs.clear_cache ) )  funcs.clear_cache();  end;
      if ( ~isempty( funcs.memory_stats ) ) funcs.memory_stats(); end;

%       if ( strcmp( class(pop), 'progress_display' ) )
%         pop = pop.setPercent( 1,1 );
%         pop.activate();
%         pop.refresh();
%       end;

      bar_max = max(scan_information.frequencies, 1);
      this_iter = 0;

      PR_From = PR_To + 1;

      for FrequencyNo=1:max(scan_information.frequencies, 1)

        GC = [];

        ftag = frequency_tag(FrequencyNo) ;
        sid = [ char(scan_information.SubjectID( subjectNo )) ftag];
        sid = strrep( sid, '_', ' ');

        this_iter = this_iter + 1;
%         if ( strcmp( class(pop ), 'progress_display' ) )
%           pop.setSubject( subjectNo, Zheader.num_subjects, sid );
%           pct = max((this_iter/bar_max)*100, 1);
%           pop = pop.setPercent( pct );
%           pop = pop.setStatus( 'Calculating . . .' );
%           pop.refresh();  
%         end;

        for RunNo = 1:Zheader.num_runs
          eval( ['load ''' Gheader.GZheader.path_to_segs 'GC_S' num2str(subjectNo) '.mat'' GC_R' num2str(RunNo) ftag ] );
          eval( ['GC = [GC; GC_R' num2str(RunNo) ftag '];'] );
          eval( ['clear GC_R' num2str(RunNo) ftag ';'] );
        end;

        if ( ~isempty( funcs.memory_stats ) ) funcs.memory_stats(); end;

        PR_To = PR_From + size(GC,1) - 1;

        % nomalize subject PR
        PRn = cpca_normalize( PR(PR_From:PR_To,:) );
        iter = 0;


        ss_cov = zeros( 1, num_comps );
        ss_coef = zeros( 1, num_comps );
        for ( vox = 1:size(GC,2) )
          iter = iter + 1; 
          if ( strcmp( class(pop), 'progress_display' ) )
            pop = pop.setPercent( (vox/(size(GC,2))*100) );
            pop.refresh();
          end;
          vl = cov([PRn GC(:,vox)] );
          eval( ['alt_VR_S' num2str(subjectNo) ' = [alt_VR_S' num2str(subjectNo) ' vl(size(vl,1),1:num_comps)''];' ] );
          ss_cov = ss_cov + vl(size(vl,1),1:num_comps).*vl(size(vl,1),1:num_comps);

          vl = corrcoef([PRn GC(:,vox)] );
          eval( ['alt_VR_coeff_S' num2str(subjectNo) ' = [alt_VR_coeff_S' num2str(subjectNo) ' vl(size(vl,1),1:num_comps)''];' ] );
          ss_coef = ss_coef + vl(size(vl,1),1:num_comps).*vl(size(vl,1),1:num_comps);

        end;
 
        VR_ss_cov = [VR_ss_cov; ss_cov];
        VR_ssm_cov = [VR_ssm_cov; ss_cov./size(GC,2)];
        VR_ss_coef = [VR_ss_coef; ss_coef];
        VR_ssm_coef = [VR_ssm_coef; ss_coef./size(GC,2)];
 
        if ( ~isempty( funcs.memory_stats ) ) funcs.memory_stats(); end;

      end; % --- each frequency

      if ( strcmp( class(pop), 'progress_display' ) )
        pop = pop.setComment( 'Variance and thresholds' );
      end;

      cvariance_rotated_tot = 0;
      eval( [' ep_' num2str(subjectNo) ' = calc_ext_Pos_Neg(alt_VR_S' num2str(subjectNo) ''');' ] );
      eval( ['cvariance_rotated_tot = component_variance( Gheader.GZheader.sum_diagonal, alt_VR_S' num2str(subjectNo) ''', [], nr, pop );' ] );

      if ( strcmp( class(pop), 'progress_display' ) )
        pop = pop.setComment( 'Saving . . .' );
      end;

      eval ( [ 'save( ''' outdir out_mat ''', ''alt_VR_S' num2str(subjectNo) ''', ''alt_VR_coeff_S' num2str(subjectNo) ''', ''ep_' num2str(subjectNo) ''', ''cvariance*'', ''-append'');' ] );

    end;   % --- each subject

    eval ( [ 'save( ''' outdir out_mat ''', ''VR_s*'', ''-append'');' ] );

    %----------------------------------------
    % summarize
    %----------------------------------------

    theseParms = rotation_params.defaults;
    theseParms.text = 'subject_specific_ssloadings';
    values_output = fs_filename( 'alt_vr_summary', 'G', rotation_params.method, theseParms )
    values_output = [outdir values_output]
    fid = fopen( values_output, 'w' );		% if the log file does not exist, then this will create an empty one, avoiding edit error

    text_file_header( nd, fid, 0, outdir );

    fprintf( fid, '\nSum of Values Squared - cov( [PR GC] )\n------------------------------------------\n' );

    for SubjectNo = 1:Zheader.num_subjects

      fprintf( fid,  '%s', char(scan_information.SubjectID(SubjectNo)) ); 

      z=[]; 
      for comp = 1:num_comps
        y = sprintf( '\t%.4f', VR_ss_cov(SubjectNo,comp) ); 
        z = [z y];
      end; 
      fprintf( fid, '%s\n', z );

    end;    

    fprintf( fid, '\nMean of Values Squared - cov( [PR GC] )\n------------------------------------------\n' );

    for SubjectNo = 1:Zheader.num_subjects

      fprintf( fid,  '%s', char(scan_information.SubjectID(SubjectNo)) ); 

      z=[]; 
      for comp = 1:num_comps
        y = sprintf( '\t%.4f', VR_ssm_cov(SubjectNo,comp) ); 
        z = [z y];
      end; 
      fprintf( fid, '%s\n', z );

    end;    

    fprintf( fid, '\nSum of Values Squared - corrcoef( [PR GC] )\n------------------------------------------\n' );

    for SubjectNo = 1:Zheader.num_subjects

      fprintf( fid,  '%s', char(scan_information.SubjectID(SubjectNo)) ); 

      z=[]; 
      for comp = 1:num_comps
        y = sprintf( '\t%.4f', VR_ss_coef(SubjectNo,comp) ); 
        z = [z y];
      end; 
      fprintf( fid, '%s\n', z );

    end;    

    fprintf( fid, '\nMean of Values Squared - corrcoef( [PR GC] )\n------------------------------------------\n' );

    for SubjectNo = 1:Zheader.num_subjects

      fprintf( fid,  '%s', char(scan_information.SubjectID(SubjectNo)) ); 

      z=[]; 
      for comp = 1:num_comps
        y = sprintf( '\t%.4f', VR_ssm_coef(SubjectNo,comp) ); 
        z = [z y];
      end; 
      fprintf( fid, '%s\n', z );

    end;    

    if ( fid ) fclose( fid ); fid = 0; end;

    if ( ~isempty( funcs.memory_stats ) ) funcs.memory_stats(); end;

  end;  % -- subject components

