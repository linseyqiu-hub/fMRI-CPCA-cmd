function [encoded sr er] = PR_condition_position( subject, condition, Gheader )
global Zheader

  sr = 0;
  er = 0;

  encoded = isEncoded( subject, condition );
  if ~encoded
    return;
  end;

  offset = 0;

  if isstruct( Gheader )    % --- passed bin size, not structure
    subject_start_row = ( sum(Gheader.subject_encoded(1:subject-1) )*Gheader.bins ) + 1;
    nbins = Gheader.bins;
    
    if condition > 1
      offset = sum( Zheader.conditions.encoded(subject).condition(1:condition-1) ) * nbins;
    end;
    
  else
    subject_start_row = Zheader.conditions.sp(subject, condition) + 1;
    nbins = Gheader;
  end;

  sr = subject_start_row + offset;
  er = sr + nbins - 1;


