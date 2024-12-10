function run_count = calc_run_count( num_freq, num_subj, num_run )
global scan_information

  run_count = 0;

  for FrequencyNo = 1:num_freq
    for SubjectNo=1:num_subj
      for RunNo = 1:num_run 
        if iscellstr( scan_information.SubjDir( SubjectNo, RunNo ) )
          run_count = run_count + 1;
        end;
      end;
    end;
  end;

