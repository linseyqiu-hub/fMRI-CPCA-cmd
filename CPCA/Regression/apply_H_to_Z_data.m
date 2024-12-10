function SoS = apply_H_to_Z_data( funcs, Ztype, model, pop )
% Ztype is one of either Z, E or GZ

global Zheader scan_information process_information 

  if ( nargin < 3 )  pop = [];  end;
   if ~strcmp( class(pop), 'cpca_progress' )
    pop = []; 
  end
 
  % --- need to explicitly define the indexed structure when nesting 
  Hheader.model = struct( 'id', 0 );
  H_Segments = [];
  ZH = [];
  EH = [];
  
  SoS = 0;

  fprintf( '\n   - Regressing %s * H -', Ztype);

   Txt = ['Regressing ' Ztype ' * H . . .'];
   if ~isempty(pop)
     pop.setMessage( Txt );
   end;

  Mode = [Ztype 'H'];
  noParms = struct( 'model', 'H', 'mode', Mode );

  hfil = os_path( Zheader.Limits.path );
  load( hfil); 

  pthAdd = '';
  if Hheader.Hindex > 1   % --- the first level H is always on main directory
    if ~isempty( Hheader.model(Hheader.Hindex).id )
      pthAdd = [ Hheader.model(Hheader.Hindex).id filesep ];
      pthAdd = strrep( pthAdd, ' ', '_' );
    else
      pthAdd = ['H_' num2str(Hheader.Hindex, '%02d') filesep ];
    end;
  end;

  eval( [ 'Hheader.model(Hheader.Hindex).path_to_segs.' Mode ' = os_path( [pwd filesep ''Hsegs'' filesep Mode filesep pthAdd ] );' ] );
  save( Zheader.Limits.path, 'Hheader' );
  eval( [ 'H_Segments = Hheader.model(Hheader.Hindex).path_to_segs.' Mode ';'] );
  
%  out_dir = os_path( [H_Segments Mode ] );
  if strcmp( Mode, 'EH' )
    Residual_dir = ['Residual_' model];
    in_dir = [ Residual_dir filesep 'Z' filesep];
    ex = [ Residual_dir filesep];
  else
    Normalized_Z_Dir = Z_Directory();
    Normalized_Z_Dir = os_path( Normalized_Z_Dir );
    ex = [];
  end
  
  is_GZ = 0;
  in_file_fmt = 'Z';

  switch Ztype
    case 'Z'
      in_dir = [Normalized_Z_Dir 'Z' filesep];		% Zn
      in_file_fmt = 'Z';

  end

  x = exist(  H_Segments, 'dir' );
  if ( x ~= 7 )  % the directory does not exist
    mkdir(  H_Segments );
  end;

  out_file_name = Mode;
  out_file_vars = [Mode '_vars'];
  
%  out_dir = [out_dir filesep];

  subject_display = 'Subject: %3d  Run: %2d';
  subject_clear = '\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b';

  % ----------------------------------------------
  % --- revised BH' algorithm from Kwang-Hee Jung, July 17, 2012
  % --- ZH = Z * H;
  % --- aa = ZH' * ZH;
  % --- 
  % --- HH = H' * H;         
  % --- [u d v] = svd( HH );
  % --- 
  % --- hh = v * inv(sqrt(d)) * u';
  % --- BB = hh * aa * hh;
  % --- 
  % --- [u1 d1 v1] = svd( BB );
  % --- 
  % --- V = H * hh * v1(:,1:nd) * sqrt(d(1:nd,1:nd)) /sqrtn;
  % --- 
  % --- U = sqrtn * ZH * hh *v1(:,1:nd) * inv(sqrt(d1(1:nd,1:nd)));
  % --- 
  % ----------------------------------------------

  nc = Zheader.total_columns;
  sqrtn = sqrt( Zheader.total_scans );
  
  initialize_mat_file( [ H_Segments out_file_name] );
  initialize_mat_file( [ H_Segments out_file_vars] );

  SSQ.sd = 0;                                          % --- total Z sum diagonal
  SSQ.Fsd = zeros( 1, max(1, Zheader.num_Z_arrays) );   % --- total Z sum diagonal by frequency
  
  SSQ.Subject = struct ( ...
     'sd', zeros(Zheader.num_runs, 1 ), ...
     'Fsd', zeros( Zheader.num_runs, max(1, Zheader.num_Z_arrays) ) );

  % we can calculate HE and C at the same time

  [H HH hh] = load_H_matrix( Hheader, 1 );      % required for sizing calculations
  hhi = inv(HH);
  
  Che = [];
  Chz = [];
  ZHvar = [ Ztype 'H' ];
  eval( [ ZHvar ' = [];' ] );
  BHsd = 0;	% sum of the diagonals of BH % --= 
  subject_BHsd = 0;
  AA = zeros( size(H,2) );
  BB = zeros( size(H,2) );
  B = zeros( Zheader.total_scans, size(H,2) );
  B_er = 0;
  BH = [];
  Bf = [];
  
  
  hs = 0;	% start row of H matrix  
  he = 0;	% end rown of matrix

  bar_max = Zheader.num_subjects * max(scan_information.frequencies, 1) * Zheader.num_runs;
  this_iter = 0;

  if ~isempty(pop)
    pop.setIterations( bar_max, pop.SECONDARY);
    pop.setComment( [' Preparing ' Mode ' . . .'] );
  end;

  for SubjectNo=1:Zheader.num_subjects

    SSQ.sd = SSQ.sd .* 0;
    SSQ.Fsd = SSQ.Fsd .* 0;
    SSQ.Subject.sd = SSQ.Subject.sd .* 0;
    SSQ.Subject.Fsd = SSQ.Subject.Fsd .* 0;
    
    funcs.memory_stats(); 
    sid = subject_id( SubjectNo );

    tsum_subject = 0;
    subject_BHsd = 0;
    
    in_Z_file = [ in_dir in_file_fmt num2str(SubjectNo) ];
    out_H_file = [  H_Segments out_file_name '_S' num2str(SubjectNo) ];

    initialize_mat_file( out_H_file );
    out_BH_vars = [ out_H_file '_vars' ];
    initialize_mat_file( out_BH_vars );

    if SubjectNo == 1						% --- load and calculate H for all subjects
      [H HH hh] = load_H_matrix( Hheader, SubjectNo );
      assignin( 'base', 'hhi', inv( HH ) );
      assignin( 'base', 'hh', hh );
      assignin( 'base', 'H', H );
    end;

    for RunNo=1:Zheader.num_runs
 
      B_sr = B_er + 1;
      B_er = B_sr + Zheader.timeseries.subject(SubjectNo).run(RunNo,1) - 1;
  
      if isEncodedRun( SubjectNo, RunNo ) 

        Z = [];
        Hstart = 0;
        Hend = 0;
        
      
        for FrequencyNo=1:max(scan_information.frequencies, 1)

          if ( ~isempty( funcs.clear_cache ) )  funcs.clear_cache( pop ); end; funcs.memory_stats(); 

          ftag = frequency_tag(FrequencyNo) ;
          fdsp = strrep( ftag, '_', ' ');
          
          % --- start and end rows of H for frequency
          Hstart = Hend + 1;
          Hend = Hstart + Zheader.total_columns - 1;
          evalin( 'base', ['Hstart =' num2str(Hstart) ';'] );
          evalin( 'base', ['Hend =' num2str(Hend) ';'] );

          HH = H(Hstart:Hend,:)' * H(Hstart:Hend,:);         
          [u d v] = svd( HH );
          hh = v * inv(sqrt(d)) * u';
          hhi = inv(HH);
          assignin( 'base', 'hhi', inv( HH ) );
          assignin( 'base', 'hh', hh );
          assignin( 'base', 'H', H );

          if ~isempty(pop)
            pop.setParticipant( SubjectNo, Zheader.num_subjects, sid );      
            pop.setRun( RunNo, Zheader.num_runs);
            if scan_information.isMulFreq
              pop.setFrequency( FrequencyNo, scan_information.frequencies, fdsp );
            end;
            pop.increment(pop.SECONDARY);
          end;

          %------------------------------------------------
          % load in the normalized Z/E segment
          %------------------------------------------------

          r = Zheader.timeseries.subject(SubjectNo).run(RunNo,1);
       
          Z = load_subject_run_Z( SubjectNo, RunNo, ftag, ex );

          if ( ~isempty( funcs.memory_stats ) ) funcs.memory_stats(); end;

          assignin( 'base', [ ZHvar '_R' num2str(RunNo) ftag ], Z * H(Hstart:Hend,:) );
          evalin( 'base', [ 'B_R' num2str(RunNo) ftag ' = ' ZHvar '_R' num2str(RunNo) ftag ' * hhi * hhi;' ] );
          clear Z 
        
          B(B_sr:B_er,: ) = B(B_sr:B_er,: )  + evalin( 'base', [ 'B_R' num2str(RunNo) ftag ';' ] );

          if  FrequencyNo == 1
            if ~isempty( ftag )
              evalin( 'base', [ZHvar '_R' num2str(RunNo) ' = ' ZHvar '_R' num2str(RunNo) ftag ';'] );
            end;
            aa = evalin( 'base', [ZHvar '_R' num2str(RunNo) ftag ''' * ' ZHvar '_R' num2str(RunNo) ftag ';'] );
          else        
            aa = aa + evalin( 'base', [ZHvar '_R' num2str(RunNo) ftag ''' * ' ZHvar '_R' num2str(RunNo) ftag ';'] );
            evalin( 'base', [ZHvar '_R' num2str(RunNo) ' = ' ZHvar '_R' num2str(RunNo) ' + ' ZHvar '_R' num2str(RunNo) ftag ';'] );
          end;
          
          evalin ( 'base', [ 'save( ''' out_H_file ''', ''' ZHvar '_R' num2str(RunNo) ftag ''', ''B_R*'', ''-append'', ''-v7.3'' );'] );
          
          BH = evalin ( 'base', [ ZHvar '_R' num2str(RunNo) ftag ' * hh * hh * H(Hstart:Hend,:)'';'] );
          sd = sum(diag( BH * BH' ));
          BHsd = BHsd + sd;
          subject_BHsd = subject_BHsd + sd;
          
          SSQ.sd = SSQ.sd + sd;
          SSQ.Fsd( FrequencyNo ) = SSQ.Fsd( FrequencyNo ) + sd;
          SSQ.Subject.sd(RunNo) = SSQ.Subject.sd(RunNo) + sd;
          SSQ.Subject.Fsd(RunNo, FrequencyNo ) = SSQ.Subject.Fsd(RunNo, FrequencyNo ) + sd;

        end;	% --- each frequency range
          
        if ~isempty( ftag )
          evalin ( 'base', [ 'save( ''' out_H_file ''', ''' ZHvar '_R' num2str(RunNo) ''', ''-append'', ''-v7.3'' );'] );
        end;

        save( out_H_file, 'aa', '-append', '-v7.3' );
      
        AA = AA + aa;
        BB = BB + hh*aa*hh;

        evalin( 'base', [ 'clear ' ZHvar '_R* B_R* ;' ] ); 
        if ~isempty(pop)
          pop.increment( pop.PRIMARY);
        end;

      end;	% --- run is encoded
    end;	% --- each run

%    save( out_H_file, 'B', '-append', '-v7.3' );
    save( out_BH_vars, 'subject_BHsd', 'SSQ', '-append', '-v7.3' );
    
  end;	% --- each subject

  if ~isempty(pop)
    pop.setComment( [''] );
  end;
  
  [u1 d1 v1]=svd(BB);

  C_Eigenvalues = sort(eig( BB ), 1, 'descend');
  C_Eigenvalues = C_Eigenvalues(1:size(BB,2),:);

  save( [H_Segments out_file_name], 'AA', 'BB', 'B', 'C_Eigenvalues', '-append', '-v7.3');
  save( [H_Segments out_file_vars], 'C_Eigenvalues', '-append', '-v7.3');

  Esd = 0;

  ts = accumulate_BH_SSQ()

  if ~isempty(pop)
    pop.clearParticipant();
    pop.clearRun();
    pop.clearFrequency();
    pop.setIterations( bar_max );
    pop.setComment( '' );
  end;

  Zheader.tsum_HE = Esd;
  save_headers();

  eval( ['Hheader.model(Hheader.Hindex).sum_diagonal.' Mode ' = BHsd;' ] );
  save( hfil, 'Hheader' );
  scan_information.processing.H_model.path_to_segs =  H_Segments ;
  SoS = 1;



 %% --- Accumulate_BH_SSQ ()
  %  --- -----------------------------------
  function ts = accumulate_BH_SSQ()
  % --- return total sum of squares
  % --- produce report file on all SSQ 
    ts = 0;
    A = [];
    
    for SubjectNo=1:Zheader.num_subjects
      BHvars = [ H_Segments char(Mode(1)) 'H_S' num2str(SubjectNo) '_vars.mat'];
      A = load( BHvars, 'SSQ');
      ts = ts + A.SSQ.sd;
    end

  end  % --- end nested function --- accumulate_Z_SSQ
 
end

