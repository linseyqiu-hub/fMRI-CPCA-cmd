function abort_proc = extract_gmh_gc_components( funcs, nd, pop )
% extract nd components from the GC portion of Z = GMH + BH + GC + E
%
global Zheader scan_information process_information 

  if ( nargin < 3 )  pop = [];  end;
  if ~strcmp( class(pop), 'cpca_progress' )
    pop = []; 
  end

  abort_proc = 0;

  Txt = 'Extracting GMH:GnotH';
  Scnd = ['Extracting ' num2str(nd) ' components from GnotH'];

  if ~isempty(pop)
    pop.setMessage( ['Extracting ' num2str(nd) ' components'] );
    pop.setIterations(Zheader.num_subjects * max(scan_information.frequencies, 1) * Zheader.num_runs);
  end;


  load( Zheader.Limits.path );

  [H_ID H_Segments] = H_path_spec( Hheader, 'GMH' );
  Hheader.model(Hheader.Hindex).path_to_segs.GMH = H_Segments;
  noParms = struct( 'model', 'H', 'mode', 'GMH', 'htype', 'GnotH', 'hindex',  H_ID );

  [has_dir component_directory] = fs_create_path( 'unrotated', 'output', nd, 0, noParms );
  component_directory = [ pwd filesep component_directory ];

  Normalized_Z_Dir = Z_Directory();

  if ( has_dir )

    in_dir = [Zheader.Z_Directory filesep 'Hsegs' filesep 'GMH' filesep ];			% eg: GZ_segs, GAZ_segs

    load( Zheader.Model.path, 'Gheader');
    in_h = [ H_Segments 'GMH_vars.mat' ];
    load( in_h, 'H', 'HH', 'hh' );

    save_file = fs_filename( 'mat', 'GnotH', 'unrotated', noParms );
    save_file = [component_directory save_file];

    text_file = fs_filename( 'txt', 'GnotH', 'unrotated', noParms );
    text_file = ['output_' text_file];

    initialize_mat_file( save_file );

%    load( [H_Segments 'GC.mat'], 'gg', 'C_Eigenvalues', 'sumDiag' );

    copyfile( [ H_Segments 'GnotH.mat'], save_file, 'f' );

    if ( ~isempty( funcs.memory_stats ) ) funcs.memory_stats(); end;

    snr = sqrt(Zheader.total_scans); % --= 
    save( save_file, 'snr', '-append', '-v7.3' );

    if ~isempty(pop)
      pop.setComment( 'Performing SVD . . .' );
      pop.setPong( 1 );
    end;

%    [u1 d1 v1] = perform_svd([H_Segments 'GC'], 'AA', nd);
    x = who_stats(H_Segments, 'GnotH.mat', 'AA' );
    m = max( x.mat_x, x.mat_y );
    if m > 1  % --- use standard svd on scalars
      load( [H_Segments 'GnotH.mat'], 'gg', 'C_Eigenvalues', 'sumDiag' );
      [u1 d1 v1]=perform_svd([ H_Segments 'GnotH' ] , 'AA', nd); % --= 
    else
      load( [H_Segments 'GnotH.mat'], 'gg', 'C_Eigenvalues', 'sumDiag', 'AA' );
      [u1 d1 v1]=svd( AA); % --= 
    end

      
    if ~isempty(pop)
      pop.setPong( 0 );
      pop.setComment( '' );
    end;

%    Af =  ( gg * u1(:,1:nd) / sqrt( Zheader.total_scans ) );

    save( save_file, 'u1', 'd1', 'v1', '-append', '-v7.3' );
    u3 = u1; v3 = v1; d3 = sqrtm(d1); % fix the variable names for rotation
    save( save_file, 'u3', 'd3', 'v3', '-append', '-v7.3' );
    % --- component loadings
    er = 0;

    w = Zheader.total_columns * max( 1, scan_information.frequencies );

    for participant = 1:Zheader.num_subjects

      sid = subject_id( participant );
      if ~isempty(pop)
        pop.setParticipant( participant, Zheader.num_subjects, sid );
      end;

      d = ( Gheader.subject_encoded(participant) * Gheader.bins) ;

      sr = er + 1;
      er = sr + d - 1;

      GZ = zeros(d,w);

      ec = 0;
      for FrequencyNo=1:max(scan_information.frequencies, 1)

        sc = ec + 1;
        ec = sc + sum( Hheader.model(Hheader.Hindex).partitions.columns) - 1;
        matrix_extents = [ '(:,' num2str(sc) ':' num2str(ec) ')'];

        ftag = frequency_tag(FrequencyNo) ;
        fdsp = strrep( ftag, '_', ' ');

        for runno = 1:Zheader.num_runs

          if isEncodedRun( participant, runno ) 
            if ~isempty(pop)
              pop.setRun( runno, Zheader.num_runs );
              pop.increment();
            end;

            eval( [ 'load( ''' Gheader.GZheader.path_to_segs 'GZ_S' num2str(participant) ftag '.mat'', ''GZ_R' num2str(runno) ftag ''');' ] );
            if runno == 1
                eval( [ 'GZ' matrix_extents ' = GZ_R' num2str(runno) ftag '; ' ] );
            else 
              eval( [ 'GZ' matrix_extents ' = GZ' matrix_extents ' + GZ_R' num2str(runno) ftag '; ' ] );
            end;

             eval( [ 'clear GZ_R' num2str(runno) ftag ' ;' ] );
             funcs.memory_stats(); 

          end; % --- run is encoded
        end; % --- each run

      end;  % --- each frequency

      if ( ~isempty( funcs.clear_cache ) )  funcs.clear_cache(pop); end; funcs.memory_stats(); 

      An = ( GZ' - H * inv( H' * H) * (GZ * H)') ; % --- * gg * u1(:,1:nd) / sqrt( size(Z,1) );

      retrieve_subject_G( Gheader, participant );

      load( [ Gheader.path_to_segs 'G_S' num2str(participant) '.mat'], 'GG' );
      [ug dg vg] = svd( GG );
      gg = vg * inv(sqrt(dg)) * ug';
      clear GG ug dg vg

      Pn = sqrt( Zheader.total_scans ) * gg * u1(sr:er,1:nd );
      if participant == 1
        V = An * ( gg * u1(sr:er,1:nd) / sqrt( Zheader.total_scans ) );
        P = Pn;
        U = G * Pn;
      else
        V = V + An * ( gg * u1(sr:er,1:nd) / sqrt( Zheader.total_scans ) );
        P = [P; Pn ];
        U = [U; G * Pn ];
      end;

    end;  % --- each participant

    if ~isempty(pop)
      pop.clearParticipant();
      pop.clearRun();
    end;

    if ( ~isempty( funcs.clear_cache ) )  funcs.clear_cache(pop); end; funcs.memory_stats(); 

    % --- component scores
    % -- we always use the variable name VR for images
    VR = V;
    PR = P;
    UR = U;
    Ph = [];
    PRh = [];

    save( save_file, 'V', 'P*', 'U','VR', 'UR', '-append', '-v7.3' );


    tsum = Zheader.tsum; % --= 
    psum = sum(C_Eigenvalues); % --= 
    ppsum=100*(psum/tsum)  ; % --= 

    dsum = sum(sum(d1(1:nd,:))); % --= 
    pdsum=100*(dsum/psum); % --= 
    ppdsum=100*(dsum/tsum); % --= 

%    ep = calc_ext_Pos_Neg(V);
    if sum(sum(H')) < size(V,1)
      ep = calc_ext_Pos_Neg(V, 1); % --= 
    else
      ep = calc_ext_Pos_Neg(V); % --= 
    end;

    save( save_file, 'tsum', 'dsum', 'psum', 'ppsum', 'pdsum', 'ppdsum', 'ep', '-append', '-v7.3' );

    nr = Zheader.total_scans;
    nc = Zheader.total_columns;

    if ~isempty(pop)
      pop.setComment( 'Calculating Component Variance' );
    end;

    cvariance_unrotated_tot = component_variance( Hheader.model(Hheader.Hindex).sum_diagonal.GC, V );
    cvariance_rotated_tot = cvariance_unrotated_tot;

    save( save_file, 'nr', 'nc', 'cvar*', '-append', '-v7.3' );

    fid = fopen( [component_directory text_file], 'w' );
    text_file_header( nd, fid, 0, component_directory, text_file );
    H_matrix_header(Hheader, fid);
    pca_summary( Hheader.model(Hheader.Hindex).sum_diagonal.GC, 'GnotH', cvariance_rotated_tot, fid, Zheader.tsum );
    if (fid) fprintf( fid, '\n\nCorrelation coefficients of UR\n------------------------------------------\n' ); end;

    cUR = corrcoef( UR ); % --= 
    for ii=1:size(cUR,1) 
      z=[]; 
      for jj = 1:size(cUR,2) 
        y = sprintf( '\t%.2f', cUR(ii,jj) ); 
        z = [z y];
      end; 
%      print_and_log( fid, '%s\n', z );
      if ( fid ) fprintf( fid, '%s\n', z ); end;

    end;

%    print_and_log( fid, '\nExtreme Positive negative loading for unrotated components:' );
    if ( fid ) fprintf( fid, '\nExtreme Positive negative loading for unrotated components:' ); end;
    display_extremes_pos_neg(ep, cvariance_rotated_tot, tsum, fid, 2, 0 );
    pca_summary( Hheader.model(Hheader.Hindex).sum_diagonal.GC, 'GnotH', cvariance_rotated_tot, 1, Zheader.tsum );


    if ( fid ) fclose( fid ); fid = 0; end;
	
    if ~isempty(pop)
      pop.setComment( 'Calculating Positive Betas' );
    end;
    betas_c_pos = calc_gmh_gc_betas( save_file, Gheader, Hheader, 1, pop );

    if ~isempty(pop)
      pop.setComment( 'Calculating Negative Betas' );
    end;
    betas_c_neg = calc_gmh_gc_betas( save_file, Gheader, Hheader, 0, pop );
 
    save( save_file, 'betas_*', '-append', '-v7.3');
	
    %----------------------------------------
    % output UR set to intial 0 per component
    %----------------------------------------
    noParms.var = 'HRF';
    noParms.component = 999;
    HRF_file = fs_filename( 'txt', 'GnotH', 'unrotated', noParms );
    output_HRF( component_directory, HRF_file, PR, Gheader);
%    plot_HRF( plot_directory, PR, Gheader, noParms );


  end;  % output directory exists



