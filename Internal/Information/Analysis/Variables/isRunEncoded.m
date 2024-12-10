function encoded = isRunEncoded(subjectNo,runNo, condition )
global Zheader scan_information
  x = []; 

  if iscellstr( scan_information.SubjDir(subjectNo, runNo ) )
      conds = Zheader.conditions.subject(subjectNo).Run(runNo).conditions(1,:);
      x = find(conds==condition);
  end

  encoded = ~isempty(x);

