function encoded = isEncoded( subject, condition )
  global Zheader scan_information

  x = []; 
  for ii = 1:Zheader.num_runs
    if iscellstr( scan_information.SubjDir(subject, ii ) )    
      conds = Zheader.conditions.subject(subject).Run(ii).conditions(1,:);
      x = [x conds]; 
    end;
  end;
  x = unique(x);

  encoded = any(x == condition );

