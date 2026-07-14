function scan_verification_cmd(scan_information, Zheader, output_dir)
% SCAN_VERIFICATION_CMD  Command-line scan integrity check (no GUI).
%
%   scan_verification_cmd(scan_information, Zheader, output_dir)
%
%   Walks every subject x run x frequency folder resolved from
%   scan_information, reads each matching scan file, and checks:
%     - read/corruption errors (img.header.error)
%     - dimension/pixdim consistency against the first file read
%
%   Always runs unconditionally (ungated) - reports results but does
%   not halt or block the pipeline.
%
%   Writes to output_dir:
%     scan_verification.mat  - subject_verification, total_verification
%     scan_verification.txt  - human-readable summary (auto-generated,
%                              no separate "save errors" step required)

  [Zheader, scan_information] = adjust_headers( Zheader, scan_information, Zheader.Z_Directory );

  v = struct( 'SubjectID', '', 'Freq', '', 'RunNo', 0, ...
              'good', 0, 'bad', 0, 'wrong_dim', 0, 'count', 0, ...
              'dim', [], 'pixdim', [], 'files', struct( 'name', [] ) );

  subject_verification = [];
  total_verification = v;
  initial_dim = [];
  initial_pixdim = [];

  num_subjects = size(scan_information.SubjectID, 2);

  fprintf('Verifying scans...\n');

  for FrequencyNo = 1:Zheader.num_Z_arrays
    for SubjectNo = 1:num_subjects

      SubjectID = char(scan_information.SubjectID(SubjectNo));

      for RunNo = 1:Zheader.num_runs

        if ~iscellstr( scan_information.SubjDir( SubjectNo, RunNo ) )
          continue;
        end

        verification = v;
        verification.SubjectID = SubjectID;
        verification.RunNo = RunNo;
        verification.Freq = '';

        if scan_information.frequencies > 0
          fname = char(scan_information.freq_names(FrequencyNo));
          if ~isempty(fname) && ~strcmp(fname, '<na>')
            verification.Freq = fname;
          end
        end

        %--------------------------------------------------
        % resolve folder + gather matching scan files
        %--------------------------------------------------
        subject_dir = subject_scan_directory_cmd( SubjectNo, RunNo, FrequencyNo, scan_information );
        dirspec = [ subject_dir filesep scan_information.ListSpec ];

        D = dir(dirspec);
        n_files = size(D,1);

        for scan_no = 1:n_files

          filespec = [ subject_dir filesep D(scan_no).name ];
          pathspec = [ subject_dir filesep ];

          img = cpca_read_vol( filespec );
          verification.count = verification.count + 1;
          total_verification.count = total_verification.count + 1;

          if isfield( img.header, 'error' )
            verification.bad = verification.bad + 1;
            total_verification.bad = total_verification.bad + 1;

            fn = strrep( img.header.error, pathspec, '' );
            name = strrep( fn, 'file corrupted ', '' );
            verification.files.name = [verification.files.name; {name}];

          else

            if isempty(initial_dim)
              initial_dim = img.vol.dim;
            end
            if isempty(initial_pixdim)
              initial_pixdim = img.header.pixdim(2:4);
            end

            verification.dim = img.vol.dim;
            verification.pixdim = img.header.pixdim(2:4);

            if all(verification.dim == initial_dim) && all(verification.pixdim == initial_pixdim)
              verification.good = verification.good + 1;
              total_verification.good = total_verification.good + 1;
            else
              verification.bad = verification.bad + 1;
              total_verification.bad = total_verification.bad + 1;
              verification.wrong_dim = verification.wrong_dim + 1;
              total_verification.wrong_dim = total_verification.wrong_dim + 1;

              % dimension mismatch is also a flagged file
              verification.files.name = [verification.files.name; {D(scan_no).name}];
            end

          end

        end  % --- each scan file ---

        subject_verification = [subject_verification; verification];

        fprintf('  %s %s run%d  (bad:%d wrong_dim:%d) %d/%d\n', ...
          SubjectID, verification.Freq, RunNo, ...
          verification.bad, verification.wrong_dim, ...
          verification.good, verification.count);

      end  % --- each run ---
    end  % --- each subject ---
  end  % --- each frequency ---

  fprintf('Done. %d scans checked, %d good, %d bad (%d wrong dim).\n', ...
    total_verification.count, total_verification.good, ...
    total_verification.bad, total_verification.wrong_dim);

  %--------------------------------------------------
  % persist .mat (always, ungated)
  %--------------------------------------------------
  save( fullfile(output_dir, 'scan_verification.mat'), ...
        'subject_verification', 'total_verification' );

  %--------------------------------------------------
  % persist .txt (always, automatic - no manual "save errors" step)
  %--------------------------------------------------
  text_file = fullfile(output_dir, 'scan_verification.txt');
  fid = fopen(text_file, 'w');
  if fid
    fprintf(fid, 'Scan Verification Summary\n');
    fprintf(fid, '%d scans  %d good  %d read err  %d dim err\n\n', ...
      total_verification.count, total_verification.good, ...
      total_verification.bad, total_verification.wrong_dim);

    for ii = 1:size(subject_verification,1)

      fprintf(fid, '%s %s run%d  (%d:%d) %d/%d\n', ...
        subject_verification(ii).SubjectID, ...
        subject_verification(ii).Freq, ...
        subject_verification(ii).RunNo, ...
        subject_verification(ii).bad, ...
        subject_verification(ii).wrong_dim, ...
        subject_verification(ii).good, ...
        subject_verification(ii).count);

      if subject_verification(ii).bad > 0
        fprintf(fid, '  flagged files:\n');
        for jj = 1:size(subject_verification(ii).files.name, 1)
          fprintf(fid, '    %s\n', char(subject_verification(ii).files.name(jj)));
        end
      end

    end

    fclose(fid);
  end

end