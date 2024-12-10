function SSQ = GMH_sum_of_squares( Hheader, module)
global Zheader 

  % --- produce report file on all SSQ 
  SSQ.sd = 0;                                          % --- total Z sum diagonal
  SSQ.Fsd = zeros( 1, max(1, Zheader.num_Z_arrays) );   % --- total Z sum diagonal by frequency
  SSQ.Subject = struct( ...
    'sd',  zeros(Zheader.num_runs, 1 ), ...                             % --- total Z sum diagonal for subject
    'Fsd', zeros( Zheader.num_runs, max(1, Zheader.num_Z_arrays) ) );   % --- total Z sum diagonal for subject by frequency
  
%   switch module
%       case 'GMH'
%         htyp = 'GMH';
%       case 'GnotH'
%         htyp = 'GC';
%       case 'HnotG'
%         htyp = 'BH';
%   end
  
  for SubjectNo = 1:Zheader.num_subjects
    A = load_subject_GMH_var( Hheader, SubjectNo, 'SSQ', module );
    
    SSQ.sd = SSQ.sd + A.sd;
    SSQ.Fsd = SSQ.Fsd + A.Fsd;

    SSQ.Subject.sd = SSQ.Subject.sd + A.Subject.sd;
    SSQ.Subject.Fsd = SSQ.Subject.Fsd + A.Subject.Fsd;
      
  end % --- each subject
       
 

