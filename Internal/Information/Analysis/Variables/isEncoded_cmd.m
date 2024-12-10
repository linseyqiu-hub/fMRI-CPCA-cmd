function encoded = isEncoded_cmd(Zheader, scan_information, subject, condition )

  x = []; 
  for ii = 1:Zheader.num_runs
    if iscellstr( scan_information.SubjDir(subject, ii ) )    
      conds = Zheader.conditions.subject(subject).Run(ii).conditions(1,:);
      x = [x conds]; 
    end
  end
  x = unique(x);

  encoded = any(x == condition );

