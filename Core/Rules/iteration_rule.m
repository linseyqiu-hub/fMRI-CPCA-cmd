function count = iteration_rule( Rclass, Rlabel, Rname, options )
% ---
% ---  process a file containing iteration calculation definitions
% ---
% ---  Parameters:
% ---      Rclass  : name of the rules class          ( file: Rclass.rul )
% ---      Rlabel  : name of the rules class section  ( [SECTION] )
% ---      Rname   : cell of rule names to parse.  empty cell parses all rules
% ---      options : optional structure containg external data element used
% ---                in formulas.  The field name must be contain in the
% ---                rule definition
% ---
% ---      eg:   iters = iteration_rule( 'Iterations', 'Subject Normalization', {'primary'}, ...
% ---                                     struct( 'covar', perform_covariant_regression > 0 ) );


global Zheader scan_information

  if nargin < 4
    % --- pass optional information in info such as SubjectNo, RunNo
    options = [];
  end;

  freqs = max(scan_information.frequencies, 1);
  
  pth = constant_define( 'RULES_PATH' );
  fn = [Rclass '.rul'];
  
  R = read_definition_data( [ pth fn], Rname, Rlabel );

  rules = fields( R.vars );
  for idx = 1:R.nvars
   
    A = '';
    eval ( [ 'A = R.vars.' char(rules(idx)) ';' ] )

    A = strrep( A, 'active_runs',   num2str( Zheader.active_runs ) );
    A = strrep( A, 'total_scans',   num2str( Zheader.total_scans ) );
    A = strrep( A, 'num_subjects',  num2str( Zheader.num_subjects ) );

    A = strrep( A, 'freqs',  num2str(freqs) );

    A = strrep( A, 'prime_runs',  num2str(  sum( [2:Zheader.num_subjects] )  ) );
    
    
    if ~isempty( options ) 

      if isfield( options, 'covar' ) 
        A = strrep( A, 'covar',  num2str( options.covar ) );
      end

      if ~isempty( strfind( A, 'subject_scans' ) )
        A = strrep( A, 'subject_scans',  num2str( sum( Zheader.timeseries.subject(options.Subj).run(:,1) )  ) );
      end;

      if ~isempty( strfind( A, 'subject_count' ) )
        A = strrep( A, 'subject_count',  num2str( Zheader.num_subjects - options.Subj ) );
      end;

      if ~isempty( strfind( A, 'secondary_count' ) )
        A = strrep( A, 'secondary_count',  num2str( Zheader.num_subjects - options.Subj + 1 ) );
      end;

      if ~isempty( strfind( A, 'subject_runs' ) )              
        A = strrep( A, 'subject_runs',  num2str( size(Zheader.timeseries.subject(options.Subj).run, 1 ) ));
      end;

      if ~isempty( strfind( A, 'subject_prime' ) )                % --- GC calculation 
%        A = strrep( A, 'subject_prime',  num2str( sum([1:Zheader.num_subjects - options.Subj ] )) );
        A = strrep( A, 'subject_prime',  num2str( sum( [options.Subj+1:Zheader.num_subjects ] - options.Subj )) );
      end;
      
    end

    eval ( [ 'B = ' A ';' ] );
%    A = sum( str2num(char(A )));

    eval ( [ 'count.' char(rules(idx)) ' = sum(B);' ] )
    
  end
  
