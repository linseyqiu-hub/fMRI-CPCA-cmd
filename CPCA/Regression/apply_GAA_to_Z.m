function SoS = apply_GAA_to_Z( funcs, Gheader, fid, pop )
% --- apply_GAA_to_Z( GHeader );
% ---
% --- Performs a regression of the null space of G*A on the normalized subject data
%
global Zheader scan_information;
SoS = 0;

FrequencyNo = 1;

  if ~scan_information.processing.model.process.apply_gaa
    return
  end;

  process_date = date;

  if ( nargin < 3 )  fid = 0;  end;
  if ( nargin < 4 )  pop = [];  end;
  if ~strcmp( class(pop), 'cpca_progress' )
    pop = []; 
  end
  
 
  model = 'GAA';
  load( Zheader.Contrast.path );

  pth_add = '';
  if Aheader.Aindex > 1
    pth_add = strrep( [ filesep Aheader.model( Aheader.Aindex).id ], ' ', '_' );
  end
  Aheader.model( Aheader.Aindex).path_to_GAA =  [pwd filesep 'GAAZsegs' pth_add filesep ];			% eg: GZ_segs, GAZ_segs
  
  vflag = ' -v7.3';

  x = exist( Aheader.model( Aheader.Aindex).path_to_GAA, 'dir' );
  if ( x ~= 7 )  % the directory does not exist
    eval ( [ 'mkdir ' Aheader.model( Aheader.Aindex).path_to_GAA ] );
  end;

  save Aheader Aheader

  out_B_file  =  [ Aheader.model( Aheader.Aindex).path_to_GAA 'B' ];
  out_BB_file = [ Aheader.model( Aheader.Aindex).path_to_GAA 'BB' ];
  out_BB_vars = [ Aheader.model( Aheader.Aindex).path_to_GAA 'BB_vars' ];
  out_AA_vars = [ Aheader.model( Aheader.Aindex).path_to_GAA 'GAA_vars' ];
  out_GAAZ    = [ Aheader.model( Aheader.Aindex).path_to_GAA 'GAAZ' ];
  initialize_mat_file( out_AA_vars );
  initialize_mat_file( out_BB_vars );
  initialize_mat_file( out_GAAZ );

%  prep_AA();
  GAA = zeros( Zheader.Contrast.mat_y * Zheader.num_subjects, Zheader.Model.mat_y );
  A = [];
  A = load( Aheader.model( Aheader.Aindex).path, Aheader.model( Aheader.Aindex).var );
  eval( [ 'A = A.' Aheader.model( Aheader.Aindex).var ';' ] );
      
  er = 0;
  ec = 0;
  for ii = 1:Zheader.num_subjects
    [Gs gg] = load_run_G( Gheader, ii, 0 );  % ---load original G
    GA = Gs * A;
      
    sr = er + 1;
    er = sr + size(A,2) - 1;
      
    sc = ec + 1;
    ec = sc + size(Gs,2) - 1;
    GAA( sr:er,sc:ec) = GA' * Gs;
  end;

  AA = null( GAA );
  save( out_AA_vars, 'AA', '-v7.3', '-append' );
  
  subject_display = 'Subject: %3d  Run: %2d';
  subject_clear = '\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b';

  %------------------------------------------------
  % multiply Gheader/Secondary against each segment of the Z matrix
  %------------------------------------------------

  iterations = Zheader.num_subjects * Zheader.num_runs;

  %------------------------------------------------
  % Calculate and preserve the column (voxel) sum of squares 
  %------------------------------------------------
  SoS = 0;	% sum of squares of GZ  % --- 
  GCsum = 0;	% sum of columnar squares of GC  % --- 
  GCsd = 0;	% sum of the diagonals of GC % --- 

  % ---revised Sum of squares holders for extended values
  SSQ.sd = 0;                                          % ---total Z sum diagonal
  SSQ.Fsd = zeros( 1, max(1, Zheader.num_Z_arrays) );   % ---total Z sum diagonal by frequency
  SSQ.Rsd = zeros( 1, 5 );                              % --- total Z sum diagonal by Registered area
  
  SSQ.Subject = struct ( ...
     'sd', zeros(Zheader.num_runs, 1 ), ...
     'Fsd', zeros( Zheader.num_runs, max(1, Zheader.num_Z_arrays) ) );
  

  Normalized_Z_Dir = Z_Directory();
  
  subject_GCsd = 0;  % sum diagonal of GC for subject

  fullAA = load( out_AA_vars, 'AA' );

  GG = zeros( size(fullAA.AA,2) );
  
  print_and_log( fid, ['\n   - Regressing ' model ''''' * Z  -'] );
  if ( fid )
    fprintf( fid, '\n' );
  end;

  if ~isempty(pop)
    pop.setIterations( Zheader.num_subjects * Zheader.num_runs, pop.SECONDARY);
  end;

  Rstart = 0; % ---
  Rend = 0; % ---
    
  for SubjectNo = 1:Zheader.num_subjects

    sid = subject_id( SubjectNo );

    if ~isempty(pop)
      pop.setParticipant( SubjectNo, Zheader.num_subjects, sid );
    end;

    tsum_subject = 0;
    subject_GCsd = 0;     % ---initialize subject GC sum diagonal value
    SSQ.sd = SSQ.sd .* 0;
    SSQ.Fsd = SSQ.Fsd .* 0;
    SSQ.Subject.sd = SSQ.Subject.sd .* 0;
    SSQ.Subject.Fsd = SSQ.Subject.Fsd .* 0;
      
    % --- =================================================
    % --- Step 1: Calculate GAA/GAAZ for all subjects
    % --- =================================================
     
    % ---bypass frequency processing for now
    ftag = '';
      
       
    out_GZ_file = [ Aheader.model( Aheader.Aindex).path_to_GAA 'GAAZ_S' num2str(SubjectNo) ftag ];
    out_GZ_vars = [ Aheader.model( Aheader.Aindex).path_to_GAA 'GAAZ_S' num2str(SubjectNo) '_vars' ];
    out_GC_file = [ Aheader.model( Aheader.Aindex).path_to_GAA 'GAAB_S' num2str(SubjectNo) ftag ];
    out_GC_vars = [ Aheader.model( Aheader.Aindex).path_to_GAA 'GAAB_S' num2str(SubjectNo) '_vars' ];
    out_E_file =  [ Aheader.model( Aheader.Aindex).path_to_GAA 'GAAE_S' num2str(SubjectNo) ];
    out_AA_file = [ Aheader.model( Aheader.Aindex).path_to_GAA 'GAA_S' num2str(SubjectNo) ftag ];
       
    c_rows = sum(Zheader.conditions.encoded(SubjectNo).condition ) * Gheader.bins;
        
    initialize_mat_file( out_GC_file );
    initialize_mat_file( out_GC_vars );
    initialize_mat_file( out_GZ_file );
    initialize_mat_file( out_GZ_vars );
    initialize_mat_file( out_AA_file );

    if ( ~isempty( funcs.clear_cache ) )  
      funcs.clear_cache(pop); 
    end; 
    funcs.memory_stats(); 

    fprintf( subject_clear );
           
    if ~isempty(pop)
      pop.setMessage( 'Loading Subject Z . . .' );
    end;
    Z = load_subject_Z(SubjectNo, ftag );

    if ~isempty(pop)
      pop.setMessage( 'Loading Subject G . . .' );
    end;
    G = load_run_G(Gheader, SubjectNo, 0);   % ---original G for full subject

    if ( ~isempty( funcs.memory_stats ) ) 
      funcs.memory_stats(); 
    end;

    out_AA = [ Aheader.model( Aheader.Aindex).path_to_GAA Gheader.prefix 'AA_S' num2str(SubjectNo) ];
    load( out_AA, 'GAA' );
            
            
    Rstart = Rend  + 1;
    Rend = Rstart + (Gheader.bins*Gheader.conditions) - 1;
            
    % ---Calculate and preserve individual GAA values based on full null space
    % ---accumulate into final GG value
    GAA = G * fullAA.AA(Rstart:Rend,:);
    save( out_AA_file, 'GAA', '-append', '-v7.3');

    GG = GG + GAA' * GAA;
    
    % ---Calculate and preserve individual GAAZ values based on full null space
    % ---accumulate into final GZ value
    GAAZ = GAA' * Z;
    if SubjectNo == 1
      A_GAAZ = GAAZ;
    else
      A_GAAZ = A_GAAZ + GAAZ;
    end;
    
    save( out_GZ_file, 'GAAZ', '-append', '-v7.3');

    clear AA GAAZ
 
    if ( ~isempty( funcs.clear_cache ) )  
      funcs.clear_cache(pop); 
    end; 
    funcs.memory_stats();
    
    if ~isempty(pop)
      pop.increment();
    end

  end  % --- each subject ---
 
  gg = sqrtm( pinv( GG ) );
  save( out_AA_vars, 'GG', 'gg', '-append', '-v7.3' );
    
  GAAZ = A_GAAZ;
  save( out_GAAZ, 'GAAZ', '-v7.3', '-append' );
    
  clear A_GAAZ
    
  % --- Calculate and preserve individual B and C values based on full null space
  % --- Accumulate and preserve GC sum diagonals
  % --- single run only at this point
    
  for SubjectNo = 1:Zheader.num_subjects

    sid = subject_id( SubjectNo );

    if ~isempty(pop)
      pop.setParticipant( SubjectNo, Zheader.num_subjects, sid );
    end;

    tsum_subject = 0;
    subject_GCsd = 0;     % ---initialize subject GC sum diagonal value
    SSQ.sd = SSQ.sd .* 0;
    SSQ.Fsd = SSQ.Fsd .* 0;
	SSQ.Rsd = SSQ.Rsd .* 0;
    SSQ.Subject.sd = SSQ.Subject.sd .* 0;
    SSQ.Subject.Fsd = SSQ.Subject.Fsd .* 0;
    
      
    out_GZ_file = [ Aheader.model( Aheader.Aindex).path_to_GAA 'GAAZ_S' num2str(SubjectNo) ftag ];
    out_GC_file = [ Aheader.model( Aheader.Aindex).path_to_GAA 'GAAB_S' num2str(SubjectNo) ftag ];
    out_GC_vars = [ Aheader.model( Aheader.Aindex).path_to_GAA 'GAAB_S' num2str(SubjectNo) ftag '_vars' ];
    out_AA_file = [ Aheader.model( Aheader.Aindex).path_to_GAA 'GAA_S' num2str(SubjectNo) ftag ];

    for RunNo=1:Zheader.num_runs 
        
      if isEncodedRun( SubjectNo, RunNo ) 
              
        if ~isempty(pop)
          pop.setMessage( 'calculating and saving GnotAZ . . .' );
          pop.setRun( RunNo, Zheader.num_runs);
        end;

        load( out_GZ_file, 'GAAZ');
        load( out_AA_file, 'GAA');
            

        B = gg * GAAZ;
        C = gg * B;

        save( out_GC_file, 'B', 'C', '-append', '-v7.3' );
          
        sd = sum(diag( (GAA * C) * (GAA * C)' ) );
        GCsd = GCsd + sd;
        subject_GCsd = subject_GCsd + sd;

        SSQ.sd = SSQ.sd + sd;
        SSQ.Fsd( FrequencyNo ) = SSQ.Fsd( FrequencyNo ) + sd;
        SSQ.Subject.sd(RunNo) = SSQ.Subject.sd(RunNo) + sd;
        SSQ.Subject.Fsd(RunNo, FrequencyNo ) = SSQ.Subject.Fsd(RunNo, FrequencyNo ) + sd;
            

        if ( ~isempty( funcs.clear_cache ) )  
          funcs.clear_cache(pop); 
        end; 
        funcs.memory_stats();

      end  % ---  subject contains run ---

      if ~isempty(pop)
        pop.increment();
      end
       
    end  % --- each subject run ---

    eval( [ 'save( ''' out_GC_vars '.mat'', ''subject_GCsd'', ''SSQ'', ''-append'', ''-v7.3''); '] );
 
    scan_information.processing.model.applied.resume_g.last_subject = SubjectNo;
    save_headers();
      
  end  % --- each subject ---

  % ---reset last subject in case of Reprocess array usage
  scan_information.processing.model.applied.resume_g.last_subject = Zheader.num_subjects;
    
  evalin( 'base', 'clear' );

  load( out_GAAZ, 'GAAZ' );
    
  B = gg * GAAZ;
  BB = B * B';
  [u4 d4 v4] = svd(BB);
  d4 = sqrt(d4);

  C_Eigenvalues = sort(eig( BB ), 1, 'descend'); % --= 
  C_Eigenvalues = C_Eigenvalues(1:size(BB,2),:); % --= 
   
  save( out_BB_vars, 'B', 'BB', 'C_Eigenvalues', '-v7.3', '-append' );
    
  if ~isempty(pop)
    pop.clearParticipant();
    pop.clearRun();
    pop.clearFrequency();
    pop.setComment(  '' );
  end;

  ts = 0;
  for SubjectNo=1:Zheader.num_subjects
    GCvars = [  Aheader.model(Aheader.Aindex).path_to_GAA 'GAAB_S' num2str(SubjectNo) '_vars.mat'];
    A = load( GCvars, 'SSQ');
    ts = ts + A.SSQ.sd;
  end;
  Aheader.model(Aheader.Aindex).sd(2) = ts;
    
  save( Zheader.Contrast.path, 'Aheader' );

  eval ( ['save( ''' Zheader.Model.path ''', ''Gheader'', ''-append'')' ] );

  save_headers();

  if ( ~isempty( funcs.clear_cache ) )  funcs.clear_cache( -1 ); end; funcs.memory_stats(); 
  
  save( Zheader.Model.path, 'Gheader', '-append' );
  
  SoS = 1;


    

