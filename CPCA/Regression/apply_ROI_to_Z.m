function SoS = apply_ROI_to_Z( funcs, nv, model, fid, pop )
% --- apply_ROI_to_Z( GHeader );
% ---
% --- Performs a regression of specific regions of interest on the normalized subject data
% --- Each ROI is a collection of voxels from an existing anlayisis, where
% --- the columns of interest are formed into an HRF based G, and regressed
%
global Zheader scan_information 
SoS = 0;

  Gpath = '';
  Gheader = '';
  G_ROI = [];
  indexes = [];
  
  process_date = date;

  if ( nargin < 4 )  fid = 0;  end;
  if ( nargin < 5 )  pop = 0;  end;
  if ~strcmp( class(pop), 'cpca_progress' )
    pop = []; 
  end

  load G_ROI
  load( Zheader.Model.path, 'Gheader' );
   
  roi_id = strrep( G_ROI.mask( G_ROI.Rindex).id, ' ', '_' );
  out_dir = [ 'GZsegs' filesep 'ROI' filesep roi_id ];			% eg: GZ_segs, GAZ_segs
  out_zvars = [ out_dir filesep 'Z_vars.mat' ];			
  roi_dir = [ 'ROI' filesep roi_id filesep ];
  indexes = load( [ 'ROI' filesep 'data' filesep 'ROI_' num2str(G_ROI.Rindex, '%02d') '_' roi_id ] );
  vflag = ' -v7.3';

  x = 0;
  eval ( [ 'x = exist( ''' pwd filesep out_dir ''', ''dir'' );' ] );
  if ( x ~= 7 )  % the directory does not exist
    eval ( [ 'mkdir ' out_dir ] );
  end;

  start_subj = 1; % --= 
  SubjectVector = [ 1:Zheader.num_subjects ]; % --= 
 

  subject_display = 'Subject: %3d  Run: %2d';
  subject_clear = '\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b';

  %------------------------------------------------
  % multiply Gheader/Secondary against each segment of the Z matrix
  %------------------------------------------------

  iterations = size(SubjectVector,2) * Zheader.num_runs;

  %------------------------------------------------
  % Calculate and preserve the column (voxel) sum of squares 
  %------------------------------------------------
  SoS = 0;	% sum of squares of GZ  % --= 
  GCsum = 0;	% sum of columnar squares of GC  % --= 
  GCsd = 0;	% sum of the diagonals of GC % --= 
  Esd = 0;	% sum of the diagonals of E % --= 
  sd = 0; % --- interim work variable
  % --=
  gg = [];
  
  % --- revised Sum of squares holders for extended values
  SSQ.sd = 0;                                          % --- total Z sum diagonal
  SSQ.Fsd = zeros( 1, max(1, Zheader.num_Z_arrays) );   % --- total Z sum diagonal by frequency
  
  SSQ.Subject = struct ( ...
     'sd', zeros(Zheader.num_runs, 1 ), ...
     'Fsd', zeros( Zheader.num_runs, max(1, Zheader.num_Z_arrays) ) );
  
  out_C_file = [ out_dir filesep 'GC' ];
  out_CC_file = [ out_dir filesep 'GCC' ];
  out_CC_vars = [ out_dir filesep 'GC_vars' ];
  initialize_mat_file( out_CC_vars );
  
  Normalized_Z_Dir = Z_Directory();
  
  Z = [];	% --- predefine vars to be used in nested functions
  subject_GCsd = 0;  % sum diagonal of GC for subject
  Z_ROI_SD = 0;     % sum diagonal of Z with ROI voxels removed
  
  %% --- process each subject ( start may be from resume point )
  if ( start_subj <= size(SubjectVector,2) )     % allow for single subjects

    print_and_log( fid, ['\n   - Regressing ' roi_id ''''' * Z  -'] );
    if ( fid )
      fprintf( fid, '\n' );
    end;

    if ~isempty(pop)
      pop.setIterations( size(SubjectVector,2) * Zheader.num_runs, pop.SECONDARY);
    end;

    for idx=start_subj:size(SubjectVector,2)
      % --= for idx = start_subj:num_subjects 
      SubjectNo = SubjectVector( idx );  % --=
      sid = subject_id( SubjectNo );

      if ~isempty(pop)
        pop.setParticipant( idx, size(SubjectVector,2), sid );
      end;

      tsum_subject = 0;
      subject_GCsd = 0;     % --- initialize subject GC sum diagonal value
      SSQ.sd = SSQ.sd .* 0;
      SSQ.Fsd = SSQ.Fsd .* 0;
      SSQ.Subject.sd = SSQ.Subject.sd .* 0;
      SSQ.Subject.Fsd = SSQ.Subject.Fsd .* 0;
      
       
      % --= 
      % --= =================================================
      % --= Step 1: Calculate GZ for all subject runs
      % --= =================================================
      % --= 
      Rstart = 0; % --=
      Rend = 0; % --=
      % --=
      
      for FrequencyNo=1:max(scan_information.frequencies, 1)

        ftag = frequency_tag(FrequencyNo) ;
        fdsp = strrep( ftag, '_', ' ');
        
        out_GZ_file = [ out_dir filesep Gheader.prefix 'Z_S' num2str(SubjectNo) ftag ];
        out_GZ_vars = [ out_dir filesep Gheader.prefix 'Z_S' num2str(SubjectNo) '_vars' ];
        out_GC_file = [ out_dir filesep Gheader.prefix 'C_S' num2str(SubjectNo) ftag ];
        out_GC_vars = [ out_dir filesep Gheader.prefix 'C_S' num2str(SubjectNo) '_vars' ];
        out_E_file =  [ out_dir filesep Gheader.prefix 'E_S' num2str(SubjectNo) ];
       
        c_rows = nv;
        nvox   = size( indexes.Zindex, 1 );
        
        assignin( 'base', [ 'B_S' num2str(SubjectNo) ftag ], zeros( c_rows, nvox ) );
        assignin( 'base', [ 'C_S' num2str(SubjectNo) ftag ], zeros( c_rows, nvox ) );

        
        % --=       for each run
        for RunNo=1:Zheader.num_runs 
          calculate_GZ();
        end  % --= each subject run ---

%         pop.setMessage( 'calculating GC . . .' );
%         for RunNo = 1:Zheader.num_runs
%           calculate_GC_SD();
%         end; % --- each run

        evalin( 'base', [ 'save( ''' out_GC_file '.mat'', ''B_S' num2str(SubjectNo) ftag ''', ''C_S' num2str(SubjectNo) ftag ''', ''-append'', ''-v7.3''); '] );
        evalin( 'base', [ 'clear B_S' num2str(SubjectNo) ftag '; '] );
        evalin( 'base', [ 'clear C_S' num2str(SubjectNo) ftag '; '] );
      
      end; % --- each frequency range

      eval( [ 'save( ''' out_GC_vars '.mat'', ''subject_GCsd'', ''SSQ'', ''-append'', ''-v7.3''); '] );
 
      scan_information.processing.model.applied.resume_g.last_subject = SubjectNo;
      save_headers();
      
    end  % --= each subject ---
    % --= 

    save( out_zvars, 'Z_ROI_SD', '-v7.3');
    
    % --- reset last subject in case of Reprocess array usage
    scan_information.processing.model.applied.resume_g.last_subject = Zheader.num_subjects;
    
    evalin( 'base', 'clear' );
    
    if ~isempty(pop)
      pop.clearParticipant();
      pop.clearRun();
      pop.clearFrequency();
      pop.setComment(  '' );
    end;

  end;  % start subject < number of subjects *( bypasses when only need to recalculate B's )


  % --= ------------------------------------------------
  % --= now compute and save the CC matrices
  % --= ------------------------------------------------
  % --= 

  % --------------------------------------------------------
  % update header information
  % --------------------------------------------------------
  save_headers();

  % --- free any cached memeory left over befor processing - requires a force
  if ( ~isempty( funcs.clear_cache ) )  funcs.clear_cache( -1 ); end; funcs.memory_stats(); 

  
%  if ( ~scan_information.processing.model.applied.resume_g.CC * scan_information.processing.model.applied.resume_g.resume )
  if ( (~scan_information.processing.model.applied.resume_g.CC) * scan_information.processing.model.applied.resume_g.resume ) || ...
     (  ~scan_information.processing.model.applied.resume_g.resume) 
    % --- calclulate CC if not previously calculated on a resumption operation or
    % --- NOT a resumption 

    % --- to recreate the CC we need to perform the calculation on ALL subjects
    SubjectVector = [ 1:Zheader.num_subjects ]; % --- Reset in case previous stage was a reduced subject list

    print_and_log( fid, '\n   - Creating C*C\n');

    %------------------------------------------------
    % Estimate the time to create C*C' - this estimate blows on large arrays
    %------------------------------------------------
    % Estimate time
    n = 0; for ii=1:size(SubjectVector,2)-1 n=n+ii; end
    t=n/1500*10/60;
    bbest = sprintf( 'Estimated time (H:M): %02d:%02d\n', floor(t), floor((t-floor(t))*100) );

    bar_max = size(SubjectVector,2)-1;
    this_iter = 0;

    if ~isempty(pop)
      pop.setMessage( 'creating C * C'' Matrix . . .' );
      pop.setIterations( sum( [1:Zheader.num_subjects] ), pop.SECONDARY );
    end;

    thisIter = 0;

    
    if strcmp( model, 'G' )
%       CCw = sum(Gheader.subject_encoded) * Gheader.bins; % *scan_information.NumRuns
%     else
%       if strcmp( model, 'ROI' )
        CCw = c_rows * Zheader.num_subjects;
      else
        CCw = Zheader.Contrast.mat_y * Zheader.num_subjects;
%       end
    end          
    
%    CCw = sum(Gheader.subject_encoded) * Gheader.bins; % *scan_information.NumRuns
    CC = zeros( CCw, CCw );

    % ------------------------------------------
    %  primary column positions
    % ------------------------------------------
    pc_start = 0;
    pc_end = 0;

    % ------------------------------------------
    %  primary row positions
    % ------------------------------------------
    pr_start = 0;
    pr_end = 0;


    % ------------------------------------------
    %  secondary column positions
    % ------------------------------------------
    sc_start = 0;
    sc_end = 0;

    % ------------------------------------------
    %  secondary row positions
    % ------------------------------------------
    sr_start = 0;
    sr_end = 0;

    num_iters = 0;

    subject_minus = 1;
    if ( Zheader.num_subjects == 1 )   subject_minus = 0;  end  % our single subject test data dies on this 

    for sidx=1:size(SubjectVector,2)-subject_minus
        
      SubjectNo = SubjectVector( sidx );
      sid = subject_id( SubjectNo );
      if ~isempty(pop)
        pop.setParticipant( SubjectNo, Zheader.num_subjects, sid );
        pop.setComment( 'Loading Primary Segment . . .' );
      end;

      if ( ~isempty( funcs.memory_stats ) ) funcs.memory_stats(); end;

      %------------------------------------------------
      % pop up window progress update
      %------------------------------------------------

      PrimDepth = c_rows;
      PrimWidth = Zheader.total_columns - size( indexes.Gindex, 1 );
        
      Primary = zeros( PrimDepth, PrimWidth  * max( 1, Zheader.num_Z_arrays ) );
      
      ebc = 0;
      for FrequencyNo=1:max(scan_information.frequencies, 1)

        ftag = frequency_tag(FrequencyNo) ;
        sbc = ebc + 1;
        ebc = sbc + PrimWidth - 1;
        Primary( :,sbc:ebc) = load_subject_B( out_dir, SubjectNo, ftag, 'ROI' );

      end;

      if ~isempty(pop)
        pop.setComment( '' );
      end;
      if ( ~isempty( funcs.memory_stats ) ) funcs.memory_stats(); end;

      if ( Zheader.num_subjects > 1 )
      
        %------------------------------------------------
        % block diagonal
        %------------------------------------------------
        pr_start = pr_end + 1;
        eval( [ 'pr_end = min(pr_start + size(Primary,1) - 1, CCw ); ' ] );

        pr = [ num2str(pr_start) ':' num2str(pr_end) ];
        pc = [ num2str(pr_start) ':' num2str(pr_end) ];
        eval( [ 'CC( ' pr ',' pc ' ) = Primary * Primary'';' ] );

        % --- clear previous calculation buffers if necessary
        if ( ~isempty( funcs.clear_cache ) )  funcs.clear_cache(); end; funcs.memory_stats(); 

        %------------------------------------------------
        % initialize the secondary row positioning
        %------------------------------------------------
        sr_end = pr_end;
        thisone = 0;

        for sidx2=sidx+1:size(SubjectVector,2)
          
          SNo = SubjectVector( sidx2 );
          sid = subject_id( SNo );
          thisone = thisone + 1;
          theseones = size(SubjectVector,2) - (sidx+1) + 1;
          if ~isempty(pop)
            pop.setSecondaryParticipant( thisone, theseones, sid );
            pop.setComment( 'Loading Secondary Segment . . .' );
          end;

          if strcmp( model, 'ROI' )
            SecDepth = c_rows;
            
          else      
            if strcmp( model, 'G' )
              SecDepth = Gheader.subject_encoded(SubjectNo) * Gheader.bins;
            else
              SecDepth = Zheader.Contrast.mat_y;
            end          
          end

          ebc = 0;
          for SubFrequency=1:max(scan_information.frequencies, 1)

            subtag = frequency_tag(SubFrequency) ;
            sbc = ebc + 1;
            ebc = sbc + PrimWidth - 1;
            Secondary( :,sbc:ebc) = load_subject_B( out_dir, SNo, subtag, 'ROI' );

          end;  % --- each sub frequency

          if ~isempty(pop)
            pop.setComment( 'Calculating . . .' );
          end;
        
          sr_start = sr_end + 1;
          eval( [ 'sr_end = min(sr_start + size(Secondary,1) - 1, CCw ); ' ] );
          sr = [ num2str(sr_start) ':' num2str(sr_end) ];
          sc = [ num2str(sr_start) ':' num2str(sr_end) ];

          eval( [ 'CC( ' pr ',' sc ' ) = Primary * Secondary'';' ] );
          % --- clear previous calculation buffers if necessary
          if ( ~isempty( funcs.clear_cache ) )  funcs.clear_cache(); end; funcs.memory_stats(); 
        
          eval ( [ 'CC( ' sr ',' pc ' ) = Secondary * Primary'';' ] );


          if ( SNo == Zheader.num_subjects & SubjectNo == Zheader.num_subjects - 1 )    % place final block diagonal

            % --- clear previous calculation buffers if necessary
            if ( ~isempty( funcs.clear_cache ) )  funcs.clear_cache(); end; funcs.memory_stats(); 
            
            sc = [ num2str(sr_start) ':' num2str(sr_end) ];
            eval( [ 'CC( ' sr ',' sc ' ) = Secondary * Secondary'';' ] );
          end

          num_iters = num_iters + 1;

          if ~isempty(pop)
            pop.setComment( '' );
          end;
        
          clear Secondary;
          if ~isempty(pop)
             pop.increment();
          end;

          if ( ~isempty( funcs.clear_cache ) )  funcs.clear_cache(); end; funcs.memory_stats(); 

        end; % --- each secondary subject

        clear Primary;
      
      else
        CC = Primary * Primary';
        clear Primary;
      end  % --- more than 1 subject

      x = toc;
      s = format_toc( x, 'short' );

    end

    % --= 
    % --= ------------------------------------------------
    % --= % -- The CC array may be too large to perform a full
    % --= % -- svd on to retrieve all the eigenvalues in d
    % --= % -- where [u d v] = svd( CC );
    % --= ------------------------------------------------

    if ~isempty(pop)
      pop.clearParticipant();
      pop.clearRun();
      pop.clearFrequency();
      pop.setComment( 'Saving . . .' );
    end;

    save( [out_CC_file '.mat'], 'CC', '-v7.3');
    clear CC
    if ( ~isempty( funcs.clear_cache ) )  funcs.clear_cache(); end; funcs.memory_stats(); 

    scan_information.processing.model.applied.resume_g.CC = 1;
    
  end  % --- create full C * C' array
   

%  if ~scan_information.processing.model.applied.resume_g.Eigs
  if ( (~scan_information.processing.model.applied.resume_g.Eigs) * scan_information.processing.model.applied.resume_g.resume ) || ...
     (  ~scan_information.processing.model.applied.resume_g.resume) 

    print_and_log( fid, '\n   - Calculating C*C Eigenvalues\n');
    if isempty( out_CC_file )
      out_CC_file = [ out_dir filesep 'GCC' ];
    end
    
    
    n = matfile_vars( [out_dir filesep], 'GCC.mat', 'CC' );
  
    if ~isempty(n)
      m = array_sizes( [n.sz_x n.sz_y] );
      x = check_memory();
  
      if scan_information.isMulFreq || (x.user.free / 1000 < m.gigabytes * 2.1)  % --- allow a 10% threshold for now
  
         % --- not enough memory to perform internal eigs function
         % --- use the D from svd over 15 components
        clear CC
        if ( ~isempty( funcs.clear_cache ) )  funcs.clear_cache(); end; funcs.memory_stats(); 
        [u d v]=perform_svd( out_CC_file , 'CC', constant_define( 'EIG_COUNT' ) ); % --= 

        C_Eigenvalues = diag(d);
      else
      
        load( [out_CC_file '.mat'], 'CC' );
        C_Eigenvalues = sort(eig( CC ), 1, 'descend'); % --= 
        C_Eigenvalues = C_Eigenvalues(1:size(CC,2),:); % --= 
      end;
  
      save( out_CC_vars, 'C_Eigenvalues', '-v7.3', '-append');

      if ~isempty(pop)
        pop.setComment( '' );
       end;
  
      scan_information.processing.model.applied.resume_g.Eigs = 1;
      
    end  % --- CC variable exists

  end  % -- calculate CC Eigenvalues    
  % --------------------------------------------------------
  % update header information
  % --------------------------------------------------------
  save( Zheader.Model.path, 'Gheader','-append' );
  save_headers();
  
  SoS = Z_ROI_SD;
  % --= 

  %% --- calculate_GZ ()
  function calculate_GZ()
  % --- called within a for each run loop, will calculate the GZ, C and B variables


    if RunNo == 1
      initialize_mat_file( out_GZ_file );
%      initialize_mat_file( out_GZ_vars );
      initialize_mat_file( out_GC_file );
      initialize_mat_file( out_GC_vars );
%       initialize_mat_file( [ out_G filesep G_File ] );
    end;
        
    if isEncodedRun( SubjectNo, RunNo ) 

      if ~isempty(pop)
        pop.setRun( RunNo, Zheader.num_runs);
      end;

      if ( ~isempty( funcs.clear_cache ) )  
        funcs.clear_cache(pop); 
      end; 
      funcs.memory_stats(); 

      fprintf( subject_clear );
      fprintf( subject_display, SubjectNo, RunNo );

      if ( fid )
        fprintf( fid, '   - loading:     Subject: %s  Run: %2d\n', char(scan_information.SubjectID(SubjectNo)), RunNo );
      end;

      % --=---------------------------------------------
      % --= load in the normalized Z segment
      % --- model application is done on full subject width
      % --=---------------------------------------------

      r = Zheader.timeseries.subject(SubjectNo).run(RunNo,1);
           
      if ~isempty(pop)
        if scan_information.isMulFreq
          pop.setFrequency( FrequencyNo, scan_information.frequencies, fdsp );
        end;
        pop.setMessage( 'Calculating GZ' );
      end;

      pop.setMessage( 'Loading Subject Z . . .' );
%       G = load_subject_run_Z( SubjectNo, RunNo, ftag );
%       G = G(:,indexes.Gindex(1:nv));
%       GG = G' * G;
%       gg = sqrtm( pinv( GG ) );

%      G = load_subject_run(SubjectNo, RunNo );                          % --- create the ROI G from Z
      G = load_subject_GC_run(Gheader, SubjectNo, RunNo, ftag, model ); % --- create the ROI G from GC
      G = G(:, indexes.Gindex);
      [u d v] = svd( G );
      
      G = u(:,1:nv);
      GG = G' * G;
      gg = sqrtm( pinv( GG ) );
      assignin( 'base', 'gg', gg);
      
      Z = load_subject_run(SubjectNo, RunNo );                          % --- create the ROI G from Z
%      Z = load_subject_GC_run(Gheader, SubjectNo, RunNo, ftag, model );
      Z = Z(:, indexes.Zindex);
      Z_ROI_SD = Z_ROI_SD + sum(diag( Z * Z' ) );
      
      wdth = size(Z, 2 );% --= 

      if ( ~isempty( funcs.memory_stats ) ) 
        funcs.memory_stats(); 
      end;

          
 
      pop.setMessage( 'calculating and saving GZ . . .' );
      assignin( 'base',  [ 'GZ_R' num2str(RunNo) ftag ], G' * Z );
      evalin( 'base', [ 'save( ''' [out_GZ_file '.mat'] ''', ''' ['GZ_R' num2str(RunNo) ftag ] ''', ''-append'', ''-v7.3'');' ] );

      % --=
      %------------------------------------------------
      % --- ensure that the segment of GZ does not contain NaN
      %------------------------------------------------
      x = evalin( 'base', [ 'find( isnan(  GZ_R' num2str(RunNo) ftag ' ));' ] );
      if ( ~isempty(x) )
        sbj = '';
        if ( size( scan_information.SubjDir, 1 ) >= SubjectNo )
          sbj = [' (' char(scan_information.SubjDir(SubjectNo, RunNo)) ')' ];
        end

        str = [ 'Subject ' num2str(SubjectNo) ', Run ' num2str(RunNo)  sbj ' - Regressing G'' * Z has resulted in NaN''s in the values.  It would be advisable to check the timing vectors and data for this subject.' ];
        show_message( 'Possible timing vector error or corrupted data', str );
        SoS = 0;
        return;
      end;

      pop.setMessage( 'Accumulating B and C . . .' );
      % -- B = gg * GZ   [ gg = sqrtm(inv( G' * G) ) ]
      evalin( 'base', [ 'B_R' num2str(RunNo) ftag ' = gg * GZ_R' num2str(RunNo) ftag ';' ] );
      % -- C = gg * gg * GZ   [ gg = sqrtm(inv( G' * G) ) ]
      evalin( 'base', [ 'C_R' num2str(RunNo) ftag ' = gg * B_R' num2str(RunNo) ftag ';' ] );
      evalin( 'base', [ 'save( ''' out_GC_file '.mat'', ''B_R' num2str(RunNo) ftag ''', ''C_R' num2str(RunNo) ftag ''', ''-append'', ''-v7.3''); '] );

      if RunNo == 1
        evalin( 'base', [ 'B_S' num2str(SubjectNo) ftag ' = B_R' num2str(RunNo) ftag ';' ] );
        evalin( 'base', [ 'C_S' num2str(SubjectNo) ftag ' = C_R' num2str(RunNo) ftag ';' ] );
      else
        evalin( 'base', [ 'B_S' num2str(SubjectNo) ftag ' = B_S' num2str(SubjectNo) ftag ' + B_R' num2str(RunNo) ftag ';' ] );
        evalin( 'base', [ 'C_S' num2str(SubjectNo) ftag ' = C_S' num2str(SubjectNo) ftag ' + C_R' num2str(RunNo) ftag ';' ] );
      end;

      
      clear Z 
      
      assignin( 'base', 'G', G );
      evalin( 'base', [ 'GC_R' num2str(RunNo) ftag ' = G * C_S' num2str(SubjectNo) ftag ';' ] );

      sd = evalin( 'base',  ['sum(diag( GC_R' num2str(RunNo) ftag ' * GC_R' num2str(RunNo) ftag ''') );'] );
      GCsd = GCsd + sd;
      subject_GCsd = subject_GCsd + sd;

      SSQ.sd = SSQ.sd + sd;
      SSQ.Fsd( FrequencyNo ) = SSQ.Fsd( FrequencyNo ) + sd;
      SSQ.Subject.sd(RunNo) = SSQ.Subject.sd(RunNo) + sd;
      SSQ.Subject.Fsd(RunNo, FrequencyNo ) = SSQ.Subject.Fsd(RunNo, FrequencyNo ) + sd;
      
      evalin( 'base', ['clear GC_R' num2str(RunNo) ftag ] );
      evalin( 'base', 'clear GZ_R* B_R* C_R*;' ); % --=

      if ( ~isempty( funcs.clear_cache ) )  
        funcs.clear_cache(pop); 
      end; 
      funcs.memory_stats();

    end  % --=  subject contains run ---

    if ~isempty(pop)
      pop.increment();
    end

  end

  %% --- calculate GC_SD ()
  function calculate_GC_SD()

    if isEncodedRun( SubjectNo, RunNo ) 

      assignin( 'base', 'G', G );
      evalin( 'base', [ 'GC_R' num2str(RunNo) ftag ' = G * C_S' num2str(SubjectNo) ftag ';' ] );

      sd = evalin( 'base',  ['sum(diag( GC_R' num2str(RunNo) ftag ' * GC_R' num2str(RunNo) ftag ''') );'] );
      GCsd = GCsd + sd;
      subject_GCsd = subject_GCsd + sd;

      SSQ.sd = SSQ.sd + sd;
      SSQ.Fsd( FrequencyNo ) = SSQ.Fsd( FrequencyNo ) + sd;
      SSQ.Subject.sd(RunNo) = SSQ.Subject.sd(RunNo) + sd;
      SSQ.Subject.Fsd(RunNo, FrequencyNo ) = SSQ.Subject.Fsd(RunNo, FrequencyNo ) + sd;
      
      evalin( 'base', ['clear GC_R' num2str(RunNo) ftag ] );

    end; % ---  subject contains run

    if ~isempty(pop)
      pop.increment();
    end;

  end

  %% --- Accumulate_GC_SSQ ()
  %  --- -----------------------------------
  function ts = accumulate_GC_SSQ()
  % --- return total sum of squares
    ts = 0;
    A = [];
    
    for SubjectNo=1:Zheader.num_subjects
      GCvars = [ out_dir filesep 'GC_S' num2str(SubjectNo) '_vars.mat'];
      A = load( GCvars, 'SSQ');
      ts = ts + A.SSQ.sd;
    end;
    
  end  % --- end nested function --- accumulate_Z_SSQ
    

end % --- main function 

