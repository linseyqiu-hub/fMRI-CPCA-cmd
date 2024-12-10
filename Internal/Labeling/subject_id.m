function sid = subject_id( sno )
global scan_information

  sid = '';
  if size(scan_information.SubjectID, 2 ) >= sno 
    sid = char(scan_information.SubjectID( sno ));
  end;

