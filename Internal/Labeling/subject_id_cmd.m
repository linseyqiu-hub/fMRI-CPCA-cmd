function sid = subject_id_cmd( sno, scan_information)

  sid = '';
  if size(scan_information.SubjectID, 2 ) >= sno 
    sid = char(scan_information.SubjectID( sno ));
  end

