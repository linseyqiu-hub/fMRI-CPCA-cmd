function run_id = determine_runID_cmd( subjectno, runno, scan_information )

  s_id = char( scan_information.SubjectID( subjectno) ) ;
  run_id = '';
  
  if isempty( scan_information.SubjDir )	% --- loaded from precreated Z - no scan dirs to be found
    run_id = ['run' num2str(runno)];
  else
    if ~isempty( cell2mat( scan_information.SubjDir( subjectno, runno ) ) )
      run_id = char(scan_information.SubjDir( subjectno, runno ) );
    else
      return;
    end
  end

  % --------------------------------------------------------
  % --- we need to strip out any group folders, subject folders or subject id's from run id's
  % ---  eg path:   group/snn/runx  or snn/snn_runx  etc ...
  % --------------------------------------------------------

  if ( size(scan_information.GroupList,1) > 0 )
    for ii = 1:size(scan_information.GroupList,1)
      run_id = strrep( run_id, [char(scan_information.GroupList(ii).name) char(filesep)], '' );
    end
  end

  % --------------------------------------------------------
  % strip out snn/ if multiple runs from s_id folder
  % --------------------------------------------------------
  run_id = strrep( run_id, [s_id char(filesep)], '' );

  % --------------------------------------------------------
  % strip out snn_ from run folder name
  % --------------------------------------------------------
  run_id = strrep( run_id, [s_id '_'], '' );

  % --------------------------------------------------------
  % strip out snn scans in s_id folder
  % --------------------------------------------------------
  run_id = strrep( run_id, s_id, '' );

