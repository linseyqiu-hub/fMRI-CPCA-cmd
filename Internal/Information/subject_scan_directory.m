function sdir = subject_scan_directory( SubjectNo, RunNo, FrequencyNo )
global scan_information 

  if ( nargin < 3 )  FrequencyNo = 1; end;

  %------------------------------------------------
  % --- full path of subject scan files for directory reading 
  %------------------------------------------------
  rdir = '';
  if numel( scan_information.run_dirs ) > 0 
    x = regexp( scan_information.run_dirs(SubjectNo), '~', 'match' );
    if ~isempty(x)
      e = regexp( char( scan_information.run_dirs(SubjectNo) ), '~', 'split' );
      rdir = char(e(RunNo));
    else
      if ( length( char( scan_information.run_dirs(SubjectNo) ) ) > 0 )
        rdir = char( scan_information.run_dirs(SubjectNo) );
      end;
    end;
  end;

  grpdir = '';
  if size(scan_information.GroupList, 1 ) > 0 
    for ii = 1:size(scan_information.GroupList, 1 ) 
      if any( str2num(scan_information.GroupList(ii).subjectlist) == SubjectNo )  grpdir = scan_information.GroupList(ii).name; end;
    end;
  end;

  sdir = [ char(scan_information.BaseDir) filesep scan_information.scandir_format ];
  sdir = strrep( sdir, '{subject_dir}', char(scan_information.SubjectDirs(SubjectNo)) );
  sdir = strrep( sdir, '{frequency_dir}', char(scan_information.freq_dirs(FrequencyNo)) );
  sdir = strrep( sdir, '{group_dir}', grpdir );
  sdir = strrep( sdir, '{run_dir}', rdir );



