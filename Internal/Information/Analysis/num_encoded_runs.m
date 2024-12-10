function n = num_encoded_runs( SubjectNo )
% -- returns the number of runs encoded for given subject
global Zheader scan_information

  n = 0;
  for RunNo = 1:Zheader.num_runs
    n = n + double( iscellstr( scan_information.SubjDir(SubjectNo, RunNo ) ) );
  end;

end

