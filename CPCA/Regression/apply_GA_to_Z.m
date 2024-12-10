function SoS = apply_GA_to_Z( funcs, Gheader, fid, pop )
% --- apply_GA_to_Z( GHeader );
% ---
% --- Performs a regression of G*A on the normalized subject data
%
global Zheader scan_information 
SoS = 0;


  Gpath = '';
  Aheader = [];
 
  process_date = date;

  if ( nargin < 3 )  fid = 0;  end;
  if ( nargin < 4 )  pop = [];  end;
  
  if ~strcmp( class(pop), 'cpca_progress' )
    pop = []; 
  end
  

  model = 'GA';
  load( Zheader.Contrast.path );
  
  pth_add = '';
  if Aheader.Aindex > 1
    pth_add = strrep( [ filesep Aheader.model( Aheader.Aindex).id ], ' ', '_' );
  end
 
  Aheader.model( Aheader.Aindex).path_to_GA =  [pwd filesep 'GAZsegs' pth_add filesep ];			% eg: GZ_segs, GAZ_segs
  vflag = ' -v7.3';

  x = exist( Aheader.model( Aheader.Aindex).path_to_GA, 'dir' );
  if ( x ~= 7 )  % the directory does not exist
    eval ( [ 'mkdir ' Aheader.model( Aheader.Aindex).path_to_GA ] );
  end;

  save Aheader Aheader
  
  start_subj = 1; % --= 
  SubjectVector = [ 1:Zheader.num_subjects ]; % --= 
 
  if ( scan_information.processing.model.applied.resume_g.resume ) 
    if ~isempty(scan_information.processing.model.applied.resume_g.Reprocess)
      SubjectVector = scan_information.processing.model.applied.resume_g.Reprocess; % --= 
    else
      start_subj = 1; 
    end  
  end; % --= -- allow resumption from last successful applied subject

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
  SSQ.Rsd = zeros( 1, 5 );                              % --- total Z sum diagonal by Registered area
  SSQ.Fsd = zeros( 1, max(1, Zheader.num_Z_arrays) );   % --- total Z sum diagonal by frequency
  
  SSQ.Subject = struct ( ...
     'sd', zeros(Zheader.num_runs, 1 ), ...
     'Fsd', zeros( Zheader.num_runs, max(1, Zheader.num_Z_arrays) ) );
  
  out_C_file =  [ Aheader.model( Aheader.Aindex).path_to_GA Gheader.prefix 'C' ];
  out_CC_file = [ Aheader.model( Aheader.Aindex).path_to_GA  Gheader.prefix 'CC' ];
  out_CC_vars = [ Aheader.model( Aheader.Aindex).path_to_GA  Gheader.prefix 'C_vars' ];
  initialize_mat_file( out_CC_vars );
  initialize_mat_file( out_C_file );
  initialize_mat_file( out_CC_file );
 
  Normalized_Z_Dir = Z_Directory();
  
  Z = [];	% --- predefine vars to be used in nested functions
  
  subject_GCsd = 0;  % sum diagonal of GC for subject
  c_rows = Aheader.model( Aheader.Aindex).contrasts * Aheader.model( Aheader.Aindex).bins;
  start_subject = 1;
  SubjectVector = [1:Zheader.num_subjects];
  
  %% --- process each subject ( start may be from resume point )
  if ( start_subj <= size(SubjectVector,2) )     % allow for single subjects

    print_and_log( fid, ['\n   - Regressing ' model ''''' * Z  -'] );
    if ( fid )
      fprintf( fid, '\n' );
    end;

    if ~isempty(pop)
      pop.setIterations( size(SubjectVector,2) * Zheader.num_runs, pop.SECONDARY);
    end;

    assignin( 'base', 'B', zeros( c_rows, Zheader.total_columns ) );
    assignin( 'base', 'C', zeros( c_rows, Zheader.total_columns ) );
    
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
      SSQ.Rsd = SSQ.Rsd .* 0;
      SSQ.Fsd = SSQ.Fsd .* 0;
      SSQ.Subject.sd = SSQ.Subject.sd .* 0;
      SSQ.Subject.Fsd = SSQ.Subject.Fsd .* 0;
      
      % --= =================================================
      % --= Step 1: Calculate GZ for all subject runs
      % --= =================================================
      % --= 
      Rstart = 0; % --=
      Rend = 0; % --=
      % --=
      C = [];
      
      for FrequencyNo=1:max(scan_information.frequencies, 1)

        ftag = frequency_tag(FrequencyNo) ;
        fdsp = strrep( ftag, '_', ' ');
        
        out_GZ_file = [ Aheader.model( Aheader.Aindex).path_to_GA 'GZ_S' num2str(SubjectNo) ftag ];
        out_GZ_vars = [ Aheader.model( Aheader.Aindex).path_to_GA 'GZ_S' num2str(SubjectNo) '_vars' ];
        out_GC_file = [ Aheader.model( Aheader.Aindex).path_to_GA 'GC_S' num2str(SubjectNo) ftag ];
        out_GC_vars = [ Aheader.model( Aheader.Aindex).path_to_GA 'GC_S' num2str(SubjectNo) '_vars' ];
        out_E_file =  [ Aheader.model( Aheader.Aindex).path_to_GA 'GE_S' num2str(SubjectNo) ];
       
        for RunNo=1:Zheader.num_runs 
          if isEncodedRun( SubjectNo, RunNo ) 
            [G gg] = load_run_G( Gheader, SubjectNo, RunNo, 'GA');
            calculate_GZ();
          end
        end  % --= each subject run ---

       
        evalin( 'base', [ 'save( ''' [out_GZ_file '.mat'] ''', ''' ['GZ_S' num2str(SubjectNo) ftag ] ''', ''-append'', ''-v7.3'');' ] );
        evalin( 'base', [ 'B_S' num2str(SubjectNo) ftag ' = gg * GZ_S' num2str(SubjectNo) ftag ';' ] );
        evalin( 'base', [ 'C_S' num2str(SubjectNo) ftag ' = gg * B_S' num2str(SubjectNo) ftag '; '] );
        evalin( 'base', [ 'save( ''' out_GC_file '.mat'', ''B_S' num2str(SubjectNo) ftag ''', ''C_S' num2str(SubjectNo) ftag ''', ''-append'', ''-v7.3''); '] );

        
        evalin( 'base', [ 'clear B_S' num2str(SubjectNo) ftag '; '] );
        C = evalin( 'base', ['C_S' num2str(SubjectNo) ftag ] );
        evalin( 'base', [ 'clear C_S' num2str(SubjectNo) ftag ' GZ_S' num2str(SubjectNo) ftag '; '] );

        for RunNo=1:Zheader.num_runs 
          if isEncodedRun( SubjectNo, RunNo ) 
            G = load_run_G( Gheader, SubjectNo, RunNo, 'GA');
          
            sd = sum(diag( (G * C) * (G * C)' ) );
            GCsd = GCsd + sd;
            subject_GCsd = subject_GCsd + sd;

            SSQ.sd = SSQ.sd + sd;
            SSQ.Fsd( FrequencyNo ) = SSQ.Fsd( FrequencyNo ) + sd;
            SSQ.Subject.sd(RunNo) = SSQ.Subject.sd(RunNo) + sd;
            SSQ.Subject.Fsd(RunNo, FrequencyNo ) = SSQ.Subject.Fsd(RunNo, FrequencyNo ) + sd;
          end
        end  % --= each subject run ---
        
     
      end; % --- each frequency range

      eval( [ 'save( ''' out_GC_vars '.mat'', ''subject_GCsd'', ''SSQ'', ''-append'', ''-v7.3''); '] );
 
      scan_information.processing.model.applied.resume_g.last_subject = SubjectNo;
      save_headers();
      
    end  % --= each subject ---

 
    
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

  
  if ~isempty(pop)
    pop.setMessage( 'creating C * C'' Matrix . . .' );
    pop.setIterations( sum( [1:Zheader.num_subjects] ), pop.SECONDARY );
  end;

  % ---- compute C * C' array
  CC = zeros( c_rows * Zheader.num_subjects, c_rows * Zheader.num_subjects );
  
  % ------------------------------------------
  %  primary & secondary row/column positions
  % ------------------------------------------
  pr_start = 0;
  pr_end = 0;
  sr_start = 0;
  pc_start = 0;
  pc_end = 0;
  sr_end = 0;
  sc_start = 0;
  sc_end = 0;

  for psubj= 1:Zheader.num_subjects

    sid = subject_id( psubj );

    if ~isempty(pop)
      pop.setParticipant( psubj, size(SubjectVector,2), sid );
    end;
    
    Primary = load_subject_B( Gheader, psubj, '', model );
    
    pr_start = pr_end + 1;
    pr_end = min(pr_start + size(Primary,1) - 1, c_rows * Zheader.num_subjects );
  
    pr = [ num2str(pr_start) ':' num2str(pr_end) ];
    pc = [ num2str(pr_start) ':' num2str(pr_end) ];
    eval( [ 'CC( ' pr ',' pc ' ) = Primary * Primary'';' ] );
 
    if ( Zheader.num_subjects > 1 )

      if psubj < Zheader.num_subjects
          
        sr_end = pr_end;
        thisone = 0;
          
        for ssubj = psubj+1:Zheader.num_subjects

          ssid = subject_id( ssubj );
          Secondary = load_subject_B( Gheader, ssubj, '', model );
        
          sr_start = sr_end + 1;
          sr_end = min(sr_start + size(Secondary,1) - 1, c_rows * Zheader.num_subjects );
          sr = [ num2str(sr_start) ':' num2str(sr_end) ];
          sc = [ num2str(sr_start) ':' num2str(sr_end) ];

          eval( [ 'CC( ' pr ',' sc ' ) = Primary * Secondary'';' ] );
          % --- clear previous calculation buffers if necessary
          if ( ~isempty( funcs.clear_cache ) )  funcs.clear_cache(); end; funcs.memory_stats(); 
        
          eval ( [ 'CC( ' sr ',' pc ' ) = Secondary * Primary'';' ] );
          
          if ( ssubj == Zheader.num_subjects & psubj == Zheader.num_subjects - 1 )    % place final block diagonal

            % --- clear previous calculation buffers if necessary
            if ( ~isempty( funcs.clear_cache ) )  funcs.clear_cache(); end; funcs.memory_stats(); 
            
            sc = [ num2str(sr_start) ':' num2str(sr_end) ];
            eval( [ 'CC( ' sr ',' sc ' ) = Secondary * Secondary'';' ] );
          end
          
          clear Secondary;

        end  % --- Secondary Subject B
        
      end  % --- Primary not last subject
  
    else  % --- single subject only
      CC = Primary * Primary';
    end;
    
    clear Primary;
    
  end  % --- Primary Subject B 

  save( [out_CC_file '.mat'], 'CC', '-append', '-v7.3');
  clear CC
  if ( ~isempty( funcs.clear_cache ) )  funcs.clear_cache(); end; funcs.memory_stats(); 
  

  eval( [ 'Aheader.model(Aheader.Aindex).sd(1) = accumulate_GC_SSQ();' ] );
  save( Zheader.Contrast.path, 'Aheader' );


  % --------------------------------------------------------
  % update header information
  % --------------------------------------------------------
  save_headers();

  % --- free any cached memeory left over befor processing - requires a force
  if ( ~isempty( funcs.clear_cache ) )  funcs.clear_cache( -1 ); end; funcs.memory_stats(); 

  
  if ( (~scan_information.processing.model.applied.resume_g.Eigs) * scan_information.processing.model.applied.resume_g.resume ) || ...
     (  ~scan_information.processing.model.applied.resume_g.resume) 

    print_and_log( fid, '\n   - Calculating C*C Eigenvalues\n');
  
    n = matfile_vars( Aheader.model( Aheader.Aindex).path_to_GA, 'GCC.mat', 'CC' );
  
    if ~isempty(n)
      m = array_sizes( [n.sz_x n.sz_y] );
      x = check_memory();
  
      if scan_information.isMulFreq || (x.user.free / 1000 < m.gigabytes * 2.1)  % --- allow a 10% threshold for now
  
         % --- not enough memory to perform internal eigs function
         % --- use the D from svd over 15 components
        clear CC
        if ( ~isempty( funcs.clear_cache ) )  funcs.clear_cache(); end; funcs.memory_stats(); 
        [u d v]=perform_svd([ Aheader.model( Aheader.Aindex).path_to_GA 'GCC' ] , 'CC', constant_define( 'EIG_COUNT')  ); % --= 

        C_Eigenvalues = sqrt(diag(d));
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
  save( Zheader.Model.path, 'Gheader' ,'-append');
  save_headers();
  
  SoS = 1;
  % --= 

  %% --- calculate_GZ ()
  function calculate_GZ()
  % --- called within a for each run loop, will calculate the GZ, C and B variables

    if RunNo == 1
      initialize_mat_file( out_GZ_file );
%      initialize_mat_file( out_GZ_vars );
      initialize_mat_file( out_GC_file );
      initialize_mat_file( out_GC_vars );
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
      Z = load_subject_run(SubjectNo, RunNo, ftag );

      wdth = size(Z, 2 );% --= 

      if ( ~isempty( funcs.memory_stats ) ) 
        funcs.memory_stats(); 
      end;

      % --=----------------------------------------------
      % --= load in the normalized Model segment
      % --=----------------------------------------------
      % --= 
      % --= load Gsegs/G_S{n} Gnorm;
      % --= 
      pop.setMessage( ['Loading Subject ' model ' . . .'] );
      assignin( 'base', 'gg', gg);
          
      % --=----------------------------------------------
      % --= Apply G matrix 
      % --- segments of GZ saved in GZ_S{n}
      % --- segments of C saved in GC_S{n}
      % --- segments of GC saved in GC_S{n}
      % --=----------------------------------------------
      % --=
      %------------------------------------------------
      % GZ = G' * Z;
      % for subjects with multiple runs, GZ is accumulated
      % resulting in a final GZ of ( Gwidth x Voxels ) dimensions
      % for the entire subject data set
      %
      % --=  % -- B = gg * GZ   [ gg = sqrtm(inv( G' * G) ) ]
      % ensure that the subject segment of C does not contain NaN
      % --=  subject C segements saved as Cs
      %------------------------------------------------

      pop.setMessage( 'calculating and saving GZ . . .' );
%      eval( [ 'GZ_R' num2str(RunNo) ftag ' = G'' * Z;'] );
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

        str = [ 'Subject ' num2str(SubjectNo) ', Run ' num2str(RunNo)  sbj ' - Regressing ' model ''' * Z has resulted in NaN''s in the values.  It would be advisable to check the timing vectors and data for this subject.' ];
        show_message( 'Possible timing vector error or corrupted data', str );
        SoS = 0;
        return;
      end;

%       % -- B = gg * GZ   [ gg = sqrtm(inv( G' * G) ) ]
       evalin( 'base', [ 'B_R' num2str(RunNo) ftag ' = gg * GZ_R' num2str(RunNo) ftag ';' ] );
       evalin( 'base', [ 'save( ''' out_GC_file '.mat'', ''B_R' num2str(RunNo) ftag ''', ''-append'', ''-v7.3''); '] );
      
      if RunNo == 1
        evalin( 'base', ['GZ_S' num2str(SubjectNo) ftag ' = GZ_R' num2str(RunNo) ftag ';'] ); 
      else
        evalin( 'base', ['GZ_S' num2str(SubjectNo) ftag ' = GZ_S' num2str(SubjectNo) ftag ' + GZ_R' num2str(RunNo) ftag ';'] ); 
      end
      
      clear Z 
      evalin( 'base', 'clear GZ_R*;' ); % --=

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
      assignin( 'base', 'G', load_run_G( Gheader, SubjectNo, RunNo, strcmp( model, 'GA') ) );
      evalin( 'base', [ 'GC_R' num2str(RunNo) ftag ' = G * C;' ] );

      evalin( 'base', [ 'save( ''' out_GC_file '.mat'', ''GC_R' num2str(RunNo) ftag ''', ''-append'', ''-v7.3''); '] );
      
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
      GCvars = [  Aheader.model(Aheader.Aindex).path_to_GA 'GC_S' num2str(SubjectNo) '_vars.mat'];
      A = load( GCvars, 'SSQ');
      ts = ts + A.SSQ.sd;
    end;
    
  end  % --- end nested function --- accumulate_Z_SSQ
    

end % --- main function 

