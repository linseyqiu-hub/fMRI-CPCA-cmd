function ab = extract_clusters_cmd(scan_information, Zheader, process_information, SubjectNo, fid, pop )
% --- read in raw scan images for a specified subject and apply the desired
% --- level of normalization ( linear regression, mean centering and/or standardization
%

% -----------------------------------------------------------------------
% --- Normalization Process code base and explanation
% ---   - process repeated for each individual run per subject
%
% ---  load all scans per subject run into single matrix  ---  Z{run#}
% ---  remove linear trends ( original code from Dr. Liang Wang located at that point in this file )
%
% ---  use mean/std on raw subject data to center around 0 and 1 per subject
% ---    --- in this instance, std is n-1 subject scans, not the total of all subject scans - 1
%
% ---  divide each normalized subject data set into columnar segments to allow creation of
% ---  matrix to perform operations on full width or full length of data set.
% ---  each segment name forma is Z_Rn_C#  ( where n = Run Number;   # = segment Number
% ---    --- eg Z_R1_C2 is the second segment of Run 1 
%
% --- assuming 3 subjects divided into 2 segments
% --- S1 = [Z_R1_C1 Z_R1_C2];		each segment loaded from the individual subject data set concatenated horizontally
% --- C1 = [Z_R1_C1; Z_R1_C1; Z_R1_C1]; 	each segment loaded from Zn.mat concatenated vetrically --  where n = subject number
% -----------------------------------------------------------------------

  eval ( [ 'load( ''' Zheader.Z_Directory 'ZInfo.mat'', ''Zmask'');'] );

  ab = 0;		% --- error in data flag telling cpca to abort process
  SD = [];

  xx = 0;
  if ( nargin < 5 )  fid = 0;  end;
  if ( nargin < 6 )  pop = [];  end;
  if ~strcmp( class(pop), 'cpca_progress' )
    pop = []; 
  end

  sid = '';

%  if ( ~isfield( Zheader, 'partitions' ) ) Zheader.original_partitions = 0; end;
%  if ( ~isfield( Zheader.original_partitions, 'count' ) )
%    Zheader.partitions = calc_column_partitions( Zheader.total_scans, Zheader.total_columns, Zheader.partition_max );
%  end;

  if ( isfield( scan_information, 'SubjectID' ) )
    sn = size(scan_information.SubjectID,2);
    if ( sn <= Zheader.num_subjects )
      sid = char(scan_information.SubjectID( SubjectNo ));
    end
  end

%  fprintf( ' - Subject %s %2d of %d Run: %2d ', sid, SubjectNo, Zheader.num_subjects, 1 );
  print_and_log( fid, ' - Subject %s %2d of %d Run: %2d ', sid, SubjectNo, Zheader.num_subjects, 1 );
  if ( fid )
    fprintf( fid, '\n' );
  end;
  
  bar = prep_done_bar( process_information.done_bar );                                 
  fprintf( '%s', bar );

  tic;

  if ~isempty(pop)
    pop.setParticipant( SubjectNo, Zheader.num_subjects, sid );
    pop.setIterations( Zheader.num_runs );
  end;


  tsum_subject = 0;			% --- tsum for each subject
  tsum_removed = 0;			% --- tsum regressed out for each subject

  for RunNo = 1:Zheader.num_runs;

    if isEncodedRun_cmd( SubjectNo, RunNo,scan_information ) 
      if ~isempty(pop)
        pop.setRun( RunNo, Zheader.num_runs );
      end;

      time_series = Zheader.timeseries.subject(SubjectNo).run(RunNo,1);
      voxels = Zheader.total_columns;
      bar_max = time_series;  % ---  * 2;

      clear_done_bar( process_information.done_bar );
      fprintf( '\b\b\b%2d ', RunNo );

      bar = prep_done_bar( process_information.done_bar );                                 
      fprintf( '%s', bar );

      mats = 'Zheader process_information scan_information';

      %------------------------------------------------
      % load in the normalized Z segment
      %  model application is done on full subject width
      %------------------------------------------------

      r = Zheader.timeseries.subject(SubjectNo).run(RunNo,1);
      Z = zeros(r, Zheader.total_columns );
       
      start_col = 1;
      end_col = 1;

      for column = 1:size( Zheader.original_partitions.columns,2)

        eval ( [ 'load( ''' Zheader.Z_Original 'Z' num2str(SubjectNo) '.mat'', ''Z_R' num2str(RunNo) '_C' num2str(column) ''');'] );
        eval( ['end_col = start_col + size( Z_R' num2str(RunNo) '_C' num2str(column) ', 2 ) - 1;' ] );
        eval ( [ 'Zn(1:' num2str(r) ',' num2str(start_col) ':' num2str(end_col) ') = Z_R' num2str(RunNo) '_C' num2str(column) ';' ] );
        start_col = end_col + 1;
      end;

      eval ( [ 'Z_R' num2str(RunNo) '_C1 = [];' ] );

      for ii = 1:size(Zn,1)
        Z = Zn(ii,:);
        eval ( [ 'Z_R' num2str(RunNo) '_C1 = [Z_R' num2str(RunNo) '_C1; Z(find(Zmask))];' ] );
      end
    

      %------------------------------------------------
      % --- calculate sums of squares of normalized data
      % --- calculate only on Z creation to avoid zeroing out tsum if ZZ created later
      %------------------------------------------------
      if ( scan_information.processing.subjects.process.create_Z == 1 | Zheader.cluster_data )
        for jj=1:voxels
          command=sprintf('tsum_v = ( Z_R%d_C1(:,%d)''*Z_R%d_C1(:,%d) );', RunNo, jj, RunNo, jj );
          eval(command);
          Zheader.tsum_clusters = Zheader.tsum_clusters + tsum_v;
        end
      end



      if ~isempty(pop)
        pop.increment();
      end;
 

      % --- save all the extraneous data
      if ( RunNo > 1 )
        eval ( [ 'save( ''Z' filesep 'Z' num2str(SubjectNo) '.mat'', ''Z_R' num2str(RunNo) '_C1'', ''-v7.3'', ''-append'' );' ] );
      else
        eval ( [ 'save( ''Z' filesep 'Z' num2str(SubjectNo) '.mat'', ''Z_R' num2str(RunNo) '_C1'', ''-v7.3'' );' ] );
      end;


  end;  % --- run is encoded
  end;  % --- each Subject Run


  scan_information.processing.subjects.process.last_subject = SubjectNo;
  save_headers();

  total_time = toc;
  str = format_toc( total_time, 'short');
  fprintf(' [%s]\n', str );


