function [scan_information, Zheader] = sum_subject_scans_cmd(scan_information,Zheader)
% summarize subject scan extents when new mask or input text file slected

  if Zheader.older_Z == 1
    return;
  end

  if ( isfield( Zheader, 'Z_File' )  )
    if ( ~isempty( Zheader.Z_File.name )  )  return; end
  end
  
  memory = check_memory();
  
  Zheader.total_scans = 0;
  Zheader.active_runs = 0;
  Zheader.num_subjects = scan_information.NumSubjects;
  Zheader.num_runs = scan_information.NumRuns;

  Zheader.num_Z_arrays = scan_information.frequencies;
  Zheader.Z_array_names = scan_information.freq_names;

%  Zheader.subject_scans = zeros( scan_information.NumSubjects, 2 );
  scan_information.processing.subjects.run_count = 0;

  ts_offset = 1;
  Zheader.timeseries.subject = [];

  if isfield( scan_information, 'GroupList' ) 
    if ( size( scan_information.GroupList,1) > 0 )
      for ( ii = 1:size( scan_information.GroupList,1) )
        scan_information.GroupList(ii).subjectdepth = 0;
      end
    end
  end

  Zheader.num_Z_arrays = scan_information.frequencies;
  Zheader.Z_array_names = scan_information.freq_names;

  scan_issue = 0;


  disp( 'Determining Data Extents' );

  empty_list = [];
  
  for FrequencyNo = 1:Zheader.num_Z_arrays
      
      
    for SubjectNo=1:Zheader.num_subjects

      sid = subject_id_cmd( SubjectNo, scan_information); 
        
      run = [];

      for RunNo = 1:Zheader.num_runs

        if isEncodedRun_cmd( SubjectNo, RunNo, scan_information)    

          scan_information.processing.subjects.run_count = scan_information.processing.subjects.run_count + 1;

          [r, c, scan_information] = get_subject_scan_count_cmd( SubjectNo, RunNo, FrequencyNo, scan_information );
          if ( c < 0 )		% voxel count -1 if wildcard error
            sdir = subject_scan_directory_cmd( SubjectNo, RunNo, FrequencyNo, scan_information);
            sid = subject_id_cmd( SubjectNo , scan_information);
            str = ['No scans found: ' sid ' ' sdir ];

            scan_issue = 1;
            
          end

          if r == 0   % --- no data
            empty_list = [empty_list; [SubjectNo FrequencyNo RunNo ] ];
          end
          
          if FrequencyNo == 1
            run = vertcat( run, [r max(1, ts_offset)]);     
            ts_offset = ts_offset + r;

            if c == 0 
              c=Zheader.total_columns; 
            end	% c will be 0 if processed from a loaded ZInfo file

            Zheader.total_columns = c;
            Zheader.total_scans = Zheader.total_scans + r;
            Zheader.active_runs = Zheader.active_runs + 1;
          end

          Zheader.max_scans = max( Zheader.max_scans, r );

          if SubjectNo == 1 
            Zheader.min_scans = r;
            Zheader.min_columns = c;
          else
            Zheader.min_scans = min( Zheader.min_scans, r );
            Zheader.min_columns = min( Zheader.min_columns, c );
          end

          if isfield( scan_information, 'GroupList' ) 
            if ( size( scan_information.GroupList,1) > 0 )
              for ( ii = 1:size( scan_information.GroupList,1) )
                x = find( str2num(scan_information.GroupList(ii).subjectlist ) == SubjectNo );
                if ~isempty(x)
                  scan_information.GroupList(ii).subjectdepth = scan_information.GroupList(ii).subjectdepth + r;
                end
              end
            end
          end


          % ------------------------------------------------
          % --- check for rp_...txt file and determine depth
          % --- one file per each subject run
          % ------------------------------------------------
  
          subject_dir = subject_scan_directory_cmd( SubjectNo, RunNo, FrequencyNo, scan_information);

          fil = '';
          fn = [subject_dir filesep ];
          f = dir( [subject_dir filesep 'rp_*.txt']  );

          if ( size( f, 1) == 1 )
            fil = [subject_dir filesep f(1).name];

            hm_data = load( fil );
            x = size( hm_data );
            if scan_information.processing.subjects.rp_width == 0 
              scan_information.processing.subjects.rp_width = x(2);
            end

            if x(2) == scan_information.processing.subjects.rp_width & x(1) == r
              %scan_information.processing.subjects.rp_count = scan_information.processing.subjects.rp_count + 1;
            end

          end

        end  % subject contains this run

      end  % each Run

      if FrequencyNo == 1

        subject = struct( 'run', [] );
        subject.run  = run;

        Zheader.timeseries.subject = vertcat(Zheader.timeseries.subject, subject);
      end    
      
    end  % each Subject

  end  % each Frequency Range

  % --------------------------------------------------------
  % create a vector of subject scan info for Liang's Linear regression algorithm
  % --------------------------------------------------------
  Zheader.ts_vector = [];
  for s = 1:Zheader.num_subjects
    for r = 1:size( Zheader.timeseries.subject(s).run,1 )
      Zheader.ts_vector = vertcat(Zheader.ts_vector, Zheader.timeseries.subject(s).run(r,1) );
    end
  end


  % --------------------------------------------------------
  % estimate memory requirements
  % --------------------------------------------------------
  % szQ = constant_define( 'SIZE_QWORD' );
%   memory.matrix.per_column = Zheader.total_scans * szQ; 
%   memory.matrix.per_row = Zheader.total_columns * szQ; 
%   memory.matrix.total = ceil( (Zheader.total_columns * Zheader.total_scans * szQ)/ constant_define( 'SIZE_MB' ));  
  % mem_max = memory.user.free;
  % if ( Zheader.memory_limit > 0 )
  %   mem_max = Zheader.memory_limit*1000;
  % end
      
  
  if ~isempty( empty_list )
    fid = fopen( 'subject_scan_data_errors.txt', 'w' );
    
    str = [];
    fprintf( 1, '%s\n', '% --- The following subjects contain no data' );
    if fid
      fprintf( fid, '%s\n', 'The following subjects contain no data' );
    end
    
    for ii = 1:size(empty_list, 1 )

      sdir = subject_scan_directory_cmd( empty_list(ii, 1), empty_list(ii, 3), empty_list(ii, 2), scan_information);
      
      Subject = subject_id_cmd( empty_list(ii, 1), scan_information);
      ftag = frequency_tag_cmd( empty_list(ii, 2), scan_information );
      ftag = strrep( ftag, '-', '' );
      str = [ 'Subject ' num2str(empty_list(ii, 1)) ' (' subject_id_cmd( empty_list(ii, 1),scan_information ) ') ' ftag '  run: ' num2str(empty_list(ii, 3)) ];
      fprintf( 1, '%% --- %s [%s]\n', str, sdir );
      if fid
        fprintf( fid, '%s [%s]\n', str, sdir );
      end
    end

    if fid
      fclose( fid );
      fprintf( 1, '\n%s\n', '% --- file: subject_scan_data_errors.txt' );
    end
  end



end
