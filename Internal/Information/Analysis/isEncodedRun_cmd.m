function yn = isEncodedRun_cmd( Subject, RunNo,scan_information )

  if nargin < 2
    RunNo = 1;
  end
  
  yn = iscellstr( scan_information.SubjDir( Subject, RunNo ) );
