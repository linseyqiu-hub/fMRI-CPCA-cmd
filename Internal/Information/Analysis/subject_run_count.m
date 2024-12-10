function c = subject_run_count( SubjectNo )
global Zheader

  c = 1;    % the default run count is always 1 run
  
  if isfield( Zheader.timeseries, 'subject' )
    if ~(SubjectNo > size( Zheader.timeseries.subject, 1 ))
      c = size(Zheader.timeseries.subject(SubjectNo).run, 1);
    end;
  end;

end

