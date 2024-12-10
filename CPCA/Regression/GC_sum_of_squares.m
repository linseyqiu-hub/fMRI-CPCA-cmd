function SSQ = GC_sum_of_squares( Gheader, model)
global Zheader scan_information 

  if nargin < 2
    model = 'G';
  end;

  % --- produce report file on all SSQ 
  SSQ.sd = 0;                                          % --- total Z sum diagonal
  SSQ.Fsd = zeros( 1, max(1, Zheader.num_Z_arrays) );   % --- total Z sum diagonal by frequency
  SSQ.Rsd = zeros( 1, 5 );                              % --- total Z sum diagonal by Registered area
  SSQ.Subject = struct( ...
    'sd',  zeros(Zheader.num_runs, 1 ), ...                             % --- total Z sum diagonal for subject
    'Fsd', zeros( Zheader.num_runs, max(1, Zheader.num_Z_arrays) ) );   % --- total Z sum diagonal for subject by frequency
    
  for SubjectNo = 1:Zheader.num_subjects
    A = load_subject_GC_var( Gheader, SubjectNo, 'SSQ', model );
    
    SSQ.sd = SSQ.sd + A.sd;
    SSQ.Fsd = SSQ.Fsd + A.Fsd;
    SSQ.Rsd = SSQ.Rsd + A.Rsd;

    SSQ.Subject.sd = SSQ.Subject.sd + A.Subject.sd;
    SSQ.Subject.Fsd = SSQ.Subject.Fsd + A.Subject.Fsd;
      
  end % --- each subject
       
 

