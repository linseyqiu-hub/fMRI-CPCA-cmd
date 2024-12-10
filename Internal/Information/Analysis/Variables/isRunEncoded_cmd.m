function encoded = isRunEncoded_cmd(Zheader, scan_information, subjectNo,runNo, condition )

  x = []; 

  if iscellstr( scan_information.SubjDir(subjectNo, runNo ) )
      conds = Zheader.conditions.subject(subjectNo).Run(runNo).conditions(1,:);
      x = find(conds==condition);
  end

  encoded = ~isempty(x);

