function yn = isEncodedRun( Subject, RunNo )
  global scan_information

  if nargin < 2
    RunNo = 1;
  end
  
  yn = iscellstr( scan_information.SubjDir( Subject, RunNo ) );
