function scan_verification_cmd(Zheader, scan_information) 

  [handles.Zheader, handles.scan_information] = adjust_headers( Zheader, scan_information, Zheader.Z_Directory );
  handles.dir_char = '/';
  handles.summary_type = 1;		% 1 = all, 2 = errors, 3 = good
  handles.reparse = 0;			% flag file list requiring reparsing

  if ( ispc )	
      handles.dir_char = '\'; 	
  end

  set( handles.lst_subjects, 'String', handles.scan_information.SubjectID', 'Value', 1 );

  set( handles.chk_verify_all_subjects, 'Value', 1 );
  idx = 1:size(handles.scan_information.SubjectID, 2);
  set( handles.lst_subjects, 'Value', idx );



lst = get(handles.lst_subjects,'String');
  subject_vector = get(handles.lst_subjects,'Value');
  set( handles.lst_results, 'String', [] );

  txt = [];
  v = struct ( 'SubjectID', '', 'Freq', '', 'RunNo', 0, 'good', 0, 'bad', 0, 'wrong_dim', 0, 'count', 0, 'dim', [], 'pixdim', [], 'files', struct( 'name', [] ) );

  subject_verification = [];
  total_verification = v;
  initial_dim = [];
  initial_pixdim = [];

  for FrequencyNo = 1:handles.Zheader.num_Z_arrays
  for Subject = 1:size(subject_vector, 2 )
    SubjectNo = subject_vector(Subject);
    SubjectID = char(lst(SubjectNo));

    set( handles.lst_subjects, 'Value', SubjectNo );

    for RunNo = 1:handles.Zheader.num_runs

      if iscellstr( handles.scan_information.SubjDir( Subject, RunNo ) )

        verification = v;
        verification.SubjectID = SubjectID;
        verification.RunNo = RunNo;

        verification.Freq = '';

        if handles.scan_information.frequencies > 0 
          if ( length(char(handles.scan_information.freq_names(FrequencyNo))) > 0 )  
            if ( ~strcmp( char(handles.scan_information.freq_names(FrequencyNo)), '<na>') )  
              verification.Freq = char(handles.scan_information.freq_names(FrequencyNo)); 
            end
          end
        end

        time_series = handles.Zheader.timeseries.subject(SubjectNo).run(RunNo,1);

        %------------------------------------------------
        % full path of subject scan files for directory reading 
        %------------------------------------------------
        subject_dir = subject_scan_directory_cmd( SubjectNo, RunNo, FrequencyNo, scan_information);
        dirspec = [ subject_dir filesep handles.scan_information.ListSpec ];

        % --------------------------------------------------------
        % read directory and process individual files
        % --------------------------------------------------------
        D=dir(dirspec);
        n_files=size(D,1);

        for scan_no = 1:n_files

          %------------------------------------------------
          % full path of subject individual scan file
          %------------------------------------------------
          filespec = [ subject_dir filesep D(scan_no).name ];

          pathspec= [ subject_dir filesep ];
           
          %------------------------------------------------
          % load in scan image and place in holding matrix
          %------------------------------------------------
          img = cpca_read_vol( filespec );
          verification.count = verification.count + 1;
          total_verification.count = total_verification.count + 1;

          if isfield( img.header, 'error' )
            verification.bad = verification.bad + 1;
            total_verification.bad = total_verification.bad + 1;

% --- place in secondary display
            fn = strrep( img.header.error, pathspec, '' );
            name = strrep( fn, 'file corrupted ', '' );
            verification.files.name = [verification.files.name; {name} ];
          else

            if isempty( initial_dim )   
                initial_dim = img.vol.dim;  
            end
            if isempty( initial_pixdim )   
                initial_pixdim = img.header.pixdim(2:4);  
            end

            verification.dim = img.vol.dim;
            verification.pixdim = img.header.pixdim(2:4);

            if all(verification.dim == initial_dim) & all(verification.pixdim == initial_pixdim)
              verification.good = verification.good + 1;
              total_verification.good = total_verification.good + 1;
            else
              verification.bad = verification.bad + 1;
              total_verification.bad = total_verification.bad + 1;

              verification.wrong_dim = verification.wrong_dim + 1;
              total_verification.wrong_dim = total_verification.wrong_dim + 1;
            end

          end

          summary = sprintf( '%s %s run%d  (%6d:%6d) %6d/%6d', SubjectID, verification.Freq, RunNo, verification.bad, verification.wrong_dim, verification.good, verification.count );
          set( handles.txt_current, 'String', summary );
          drawnow();

        end  % --- each scan image ---

        subject_verification = [subject_verification; verification ];
        update_scan_results( handles, subject_verification );
        set( handles.lst_results, 'Value', size(subject_verification,1) );

        show_total( handles, total_verification );

      end  % --- Subject contains run ---
    end  % --- each run ---

  end  % --- each selected subject ---
  end  % --- each frequency range

%  set( handles.lst_subjects, 'Value', 1 );
  show_total( handles, total_verification );

  set( handles.txt_current, 'String', '' );
  set( handles.lst_results, 'Value', 1 );

  save scan_verification subject_verification total_verification;
