function SoS = apply_partitioned_to_Z_cmd( Gheader, Zheader, scan_information, fid, variable_creation)
% --- apply_patritioned_to_Z( GHeader );
% ---
% --- Performs a regression of G on the normalized subject data
%
SoS = 0;

  if scan_information.processing.model.process.apply_ga
    SoS = apply_GA_to_Z_cmd( Gheader,Zheader, scan_information, fid );
    return
  end

  if scan_information.processing.model.process.apply_gaa
    SoS = apply_GAA_to_Z_cmd(Gheader,Zheader, scan_information, fid );
    return
  end

  Gpath = '';

  if nargin < 4,  fid = 0;  end


  model = 'G';
  out_dir = [ model 'Zsegs'];			% eg: GZ_segs, GAZ_segs

  x = 0;
  eval ( [ 'x = exist( ''' pwd filesep out_dir ''', ''dir'' );' ] );
  if ( x ~= 7 )  % the directory does not exist
    eval ( [ 'mkdir ' out_dir ] );
  end


  start_subj = 1; % --=
  SubjectVector = 1:Zheader.num_subjects; % --=


  % ------------------------------------------------
  % --- force G application to be only on all subjects
  % ------------------------------------------------

  GZheader.path_to_segs = [ pwd filesep out_dir filesep  ];
  GZheader.prefix = [ model 'Z' ];
  GZheader.columns = Zheader.partitions.count;
  GZheader.runs = Zheader.num_runs;
  GZheader.subjects = size(SubjectVector,2);
  eval( [ 'Gheader.' model 'Zheader = GZheader;' ] );

  eval( [ 'Gpath = Gheader.' model 'Zheader.path_to_segs;' ] );

  subject_display = '\nSubject: %3d  Run: %2d';
  subject_clear = '\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b';


  %------------------------------------------------
  % Calculate and preserve the column (voxel) sum of squares
  %------------------------------------------------
  SoS = 0;	% sum of squares of GZ
  GCsd = 0;	% sum of the diagonals of GC
  sd = 0; % --- interim work variable

  gg = [];

  % --- revised Sum of squares holders for extended values
  SSQ.sd = 0;                                          % --- total Z sum diagonal
  SSQ.Rsd = zeros( 1, 5 );                              % --- total Z sum diagonal by Registered area
  SSQ.Fsd = zeros( 1, max(1, Zheader.num_Z_arrays) );   % --- total Z sum diagonal by frequency

  SSQ.Subject = struct ( ...
     'sd', zeros(Zheader.num_runs, 1 ), ...
     'Fsd', zeros( Zheader.num_runs, max(1, Zheader.num_Z_arrays) ) );

  out_CC_vars = [ out_dir filesep Gheader.prefix 'C_vars' ];
  initialize_mat_file( out_CC_vars );

  Normalized_Z_Dir = Z_Directory_cmd(Zheader);

  Z = [];	% --- predefine vars to be used in nested functions
  subject_GCsd = 0;  % sum diagonal of GC for subject

  if scan_information.mask.isRegistered % ---&& constant_define( 'PREFERENCES', 'general.gray_white_split' );
    reg_data = mask_registrations( scan_information.mask );
  end


  %% --- process each subject ( start may be from resume point )
  if ( start_subj <= size(SubjectVector,2) )     % allow for single subjects

    print_and_log( fid, ['\n   - Regressing ' model ''''' * Z  -'] );
    if ( fid )
      fprintf( fid, '\n' );
    end

    for idx=start_subj:size(SubjectVector,2)
      % --= for idx = start_subj:num_subjects
      SubjectNo = SubjectVector( idx );  % --=
      sid = subject_id_cmd( SubjectNo, scan_information );

      % if ~isempty(pop)
      %   pop.setParticipant( idx, size(SubjectVector,2), sid );
      %   iters = iteration_rule( 'Iterations', 'G Regression', {} , ...
      %           struct( 'Subj', SubjectNo ) );
      %   pop.setIterations( iters.secondary_GZ + iters.secondary_GC, pop.SECONDARY);
      % end;

      subject_GCsd = 0;     % --- initialize subject GC sum diagonal value
      SSQ.sd = SSQ.sd .* 0;
      SSQ.Rsd = SSQ.Rsd .* 0;
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

        ftag = frequency_tag_cmd(FrequencyNo,scan_information) ;
        fdsp = strrep( ftag, '_', ' ');

        out_GZ_file = [ out_dir filesep Gheader.prefix 'Z_S' num2str(SubjectNo) ftag ];
        out_GC_file = [ out_dir filesep Gheader.prefix 'C_S' num2str(SubjectNo) ftag ];
        out_GC_vars = [ out_dir filesep Gheader.prefix 'C_S' num2str(SubjectNo) '_vars' ];

        if strcmp( model, 'GA' )
          c_rows = Gheader.contrasts * Gheader.contrast_bins;
        else
          if Gheader.model_type == constant_define( 'FIR_MODEL')
            c_rows = sum(Zheader.conditions.encoded(SubjectNo).condition ) * Gheader.bins;
          else
            c_rows = Gheader.conditions;
          end
        end

        for RunNo=1:Zheader.num_runs
          calculate_GZ();
        end  % --= each subject run ---

        evalin( 'base', [ 'save( ''' out_GC_file '.mat'', ''B_S' num2str(SubjectNo) ftag ''', ''C_S' num2str(SubjectNo) ftag ''', ''-append'', ''-v7.3''); '] );

        disp( 'calculating GC . . .' );

        for RunNo = 1:Zheader.num_runs
          calculate_GC_SD();
        end % --- each run

        evalin( 'base', [ 'clear B_S' num2str(SubjectNo) ftag '; '] );
        evalin( 'base', [ 'clear C_S' num2str(SubjectNo) ftag '; '] );

      end % --- each frequency range

      eval( [ 'save( ''' out_GC_vars '.mat'', ''subject_GCsd'', ''SSQ'', ''-append'', ''-v7.3''); '] );

      scan_information.processing.model.applied.resume_g.last_subject = SubjectNo;
      save_headers_cmd(Zheader, scan_information);

    end  % --= each subject ---
    % --=

    % --- reset last subject in case of Reprocess array usage
    scan_information.processing.model.applied.resume_g.last_subject = Zheader.num_subjects;

    % evalin( 'base', 'clear' );


  end  % start subject < number of subjects *( bypasses when only need to recalculate B's )

  if variable_creation(1,2)
      [Zheader, scan_information] = create_residual_as_Z_cmd(Zheader, scan_information, model, Gheader );
  end

  eval( [ 'Gheader.' model 'Zheader.sum_diagonal = accumulate_GC_SSQ();' ] );
  Gheader.applied_to = Normalized_Z_Dir;
  Gheader.date_applied = date;

  eval ( ['save( ''' Zheader.Model.path ''', ''Gheader'', ''-append'')' ] );

  compile_CC_array_cmd( Zheader, scan_information, model,0 )      
  calculate_Eigenvalues_cmd( Gpath, 'CC', 0, scan_information.isMulFreq);% --- create whole brain CC matrix

  if scan_information.mask.isRegistered % ---  && constant_define( 'PREFERENCES', 'general.gray_white_split' );
    compile_CC_array_cmd(Zheader, scan_information, model, 1 );           % --- create  gray matter CC matrix
    calculate_Eigenvalues_cmd( Gpath, 'CCG', 1, scan_information.isMulFreq);            % --- and calculate the eigenvector
    compile_CC_array_cmd(Zheader, scan_information, model, 2 );           % --- create white matter CC matrix
    calculate_Eigenvalues_cmd( Gpath, 'CCW', 2,scan_information.isMulFreq);            % --- and calculate the eigenvector
  end

  % --------------------------------------------------------
  % update header information
  % --------------------------------------------------------
  save( Zheader.Model.path, 'Gheader', '-append' );
  save_headers_cmd(Zheader, scan_information);

  SoS = 1;
  % --=

  %% --- calculate_GZ ()
  function calculate_GZ()
  % --- called within a for each run loop, will calculate the GZ, C and B variables

    if RunNo == 1
      initialize_mat_file( out_GZ_file );
      initialize_mat_file( out_GC_file );
      initialize_mat_file( out_GC_vars );
    end

    if isEncodedRun_cmd( SubjectNo, RunNo,scan_information )

      % if ~isempty(pop)
      %   pop.setRun( RunNo, Zheader.num_runs);
      % end;
      % 
      % if ( ~isempty( funcs.clear_cache ) )
      %   funcs.clear_cache(pop);
      % end;
      % funcs.memory_stats();

      %fprintf( subject_clear ); fprintf('\n');
      fprintf( subject_display, SubjectNo, RunNo );fprintf('\n');

      if ( fid )
        fprintf( fid, '   - loading:     Subject: %s  Run: %2d\n', char(scan_information.SubjectID(SubjectNo)), RunNo );
      end

      % --=---------------------------------------------
      % --= load in the normalized Z segment
      % --- model application is done on full subject width
      % --=---------------------------------------------

      r = Zheader.timeseries.subject(SubjectNo).run(RunNo,1);


        % if scan_information.isMulFreq
        %   pop.setFrequency( FrequencyNo, scan_information.frequencies, fdsp );
        % end;
        disp( 'Calculating GZ' );


      disp('Loading Subject Z . . .' );
      Z = load_subject_run_cmd(SubjectNo, RunNo,Zheader, ftag );

      wdth = size(Z, 2 );% --=

      % if ( ~isempty( funcs.memory_stats ) )
      %   funcs.memory_stats();
      % end

      % --=----------------------------------------------
      % --= load in the normalized Model segment
      % --=----------------------------------------------
      % --=
      % --= load Gsegs/G_S{n} Gnorm;
      % --=
      fprintf( 'Loading Subject %s . . .\n', model );
      [G gg] = load_run_G_cmd( Zheader, Gheader, SubjectNo, RunNo );
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

      disp( 'calculating and saving GZ . . .' );

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
        fprintf( 'Possible timing vector error or corrupted data: %s \n', str );
        SoS = 0;
        return;
      end

      disp( 'Accumulating B and C . . .' );
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
      end

      clear Z
      evalin( 'base', 'clear GZ_R* B_R* C_R*;' ); % --=

      % if ( ~isempty( funcs.clear_cache ) )
      %   funcs.clear_cache(pop);
      % end;
      % funcs.memory_stats();

    end  % --=  subject contains run ---

  end

  %% --- calculate GC_SD ()
  function calculate_GC_SD()

    if isEncodedRun_cmd( SubjectNo, RunNo,scan_information )
      assignin( 'base', 'G', load_run_G_cmd(Zheader, Gheader, SubjectNo, RunNo ) );
      evalin( 'base', [ 'GC_R' num2str(RunNo) ftag ' = G * C_S' num2str(SubjectNo) ftag ';' ] );

      sd = zeros( size( scan_information.mask.ind ) );
      for ii=1:numel(sd)
        sd(ii) = evalin( 'base',  ['sum(diag( GC_R' num2str(RunNo) ftag '(:,' num2str(ii) ') * GC_R' num2str(RunNo) ftag '(:,' num2str(ii) ')'') );'] );
      end

%      sd = evalin( 'base',  ['sum(diag( GC_R' num2str(RunNo) ftag ' * GC_R' num2str(RunNo) ftag ''') );'] );
      GCsd = GCsd + sum(sd);
      subject_GCsd = subject_GCsd + sd;

      SSQ.sd = SSQ.sd + sum(sd);
      SSQ.Fsd( FrequencyNo ) = SSQ.Fsd( FrequencyNo ) + sum(sd);
      SSQ.Subject.sd(RunNo) = SSQ.Subject.sd(RunNo) + sum(sd);
      SSQ.Subject.Fsd(RunNo, FrequencyNo ) = SSQ.Subject.Fsd(RunNo, FrequencyNo ) + sum(sd);

      if scan_information.mask.isRegistered % 000 && constant_define( 'PREFERENCES', 'general.gray_white_split' );
        for ii = 1:5
          if reg_data.count(ii) > 0
            SSQ.Rsd(ii) = SSQ.Rsd(ii) + sum(sd(reg_data.ind(ii).zref) );
          end
        end
      end

      evalin( 'base', ['clear GC_R' num2str(RunNo) ftag ] );

    end % ---  subject contains run

  end

  %% --- Accumulate_GC_SSQ ()
  %  --- -----------------------------------
  function ts = accumulate_GC_SSQ()
  % --- return total sum of squares
    ts = 0;
    A = [];

    for SubjectNo=1:Zheader.num_subjects
      GCvars = [ model 'Zsegs' filesep 'GC_S' num2str(SubjectNo) '_vars.mat'];
      A = load([pwd filesep GCvars], 'SSQ');
      ts = ts + A.SSQ.sd;
    end

  end  % --- end nested function --- accumulate_Z_SSQ


end % --- main function
