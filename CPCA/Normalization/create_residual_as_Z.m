function create_residual_as_Z( model, pop, Gheader )
global Zheader scan_information process_information

  if nargin < 1
    model = 'G';
  end;
  if ( nargin < 2 )  pop = [];  end;
  if ~strcmp( class(pop), 'cpca_progress' )
    pop = []; 
  end
  if ( nargin < 3 ) load( Zheader.Model.path, 'Gheader'); end;
      
  if ~exist( 'Gheader', 'var' )
    return
  end

  Residual_dir = ['Residual_' model];
  
  if  ~exist( Residual_dir, 'dir' )
    eval( [' mkdir ' Residual_dir ] );
  end;

  if  ~exist( [ Residual_dir filesep 'Z'], 'dir' )
    eval( [ 'mkdir ' Residual_dir filesep 'Z' ] );
  end;
  

  if ~isempty(pop)
    pop.setWindowTitle( 'Residual to Z' );
    pop.setMessages( 'Creating Residual Matrix ', '', '' );
    iters = iteration_rule( 'Iterations', 'Residual Creation', {'primary'} );
    pop.setIterations( iters.primary, pop.PRIMARY );
    pop.show();
  end
  
  if scan_information.mask.isRegistered % -- && constant_define( 'PREFERENCES', 'general.gray_white_split' )
    reg_data = mask_registrations( scan_information.mask );  
  end
  
  for subjectNo = 1:Zheader.num_subjects

    if ~isempty(pop)
      pop.setParticipant( subjectNo, Zheader.num_subjects, subject_id( subjectNo ));
      iters = iteration_rule( 'Iterations', 'Residual Creation', {'secondary'}, ...
                 struct( 'Subj', subjectNo ) );
      pop.setIterations( iters.secondary, pop.SECONDARY );
    end
      
    SSQ.sd = 0;                                          % --- total Z sum diagonal
    SSQ.Rsd = zeros( 1, 5 );                              % --- total Z sum diagonal by Registered area
    SSQ.Fsd = zeros( 1, max(1, Zheader.num_Z_arrays) );   % --- total Z sum diagonal by frequency
    SSQ.Subject = [];
  
    A.sd = zeros(Zheader.num_runs, 1 );                             % --- total Z sum diagonal for subject
    A.Fsd = zeros( Zheader.num_runs, max(1, Zheader.num_Z_arrays) ); % --- total Z sum diagonal for subject by frequency

    Zvars = [ Residual_dir filesep 'Z' filesep 'Z' num2str(subjectNo) '_vars.mat'];
    initialize_mat_file( Zvars );

    sbj = subject_id( subjectNo );
    pop.setParticipant( subjectNo, Zheader.num_subjects, sbj );

    
    for FrequencyNo = 1:max(scan_information.frequencies, 1)
      ftag = frequency_tag(FrequencyNo) ;
      fdir = strrep( ftag, '_', '' );

      if scan_information.isMulFreq
        pop.setFrequency( FrequencyNo, scan_information.frequencies, fdir );
      end

      Zname = [ Residual_dir filesep 'Z' filesep 'Z' num2str(subjectNo) ftag '.mat'];
      initialize_mat_file( Zname );

      for RunNo = 1:size( Zheader.timeseries.subject(subjectNo).run, 1 )

        if isEncodedRun(subjectNo,RunNo )
          if ~isempty(pop)
            pop.setRun( RunNo, size( Zheader.timeseries.subject(subjectNo).run, 1 ) );
          end

          
          GC = load_subject_GC_run( Gheader, subjectNo, RunNo, ftag, model );
          Z = load_subject_run_Z( subjectNo, RunNo, ftag );
          E = Z - GC;
% ---Accum SSQ to /Residual/Z/Zn_vars

          clear GC Z
          start_col = 1;
          for column = 1:size( Zheader.partitions.columns,2)
            end_col = start_col + Zheader.partitions.columns(column) - 1;
            eval ( ['Z_R' num2str(RunNo) '_C' num2str(column) ftag ' = E(:,start_col:end_col);' ] );
            eval ( [ 'save( ''' Zname ''', ''Z_R' num2str(RunNo) '_C' num2str(column) ftag ''', ''-append'', ''-v7.3'' )' ] );
            start_col = end_col+1;
            eval ( ['clear Z_R' num2str(RunNo) '_C' num2str(column) ftag ] );
          end;

          sd = sum(diag( E * E' ));

          A.sd(RunNo) = A.sd(RunNo) + sd;
          A.Fsd(RunNo, FrequencyNo ) = A.Fsd(RunNo, FrequencyNo ) + sd;

          SSQ.sd = SSQ.sd + sd;
          SSQ.Fsd( FrequencyNo ) = SSQ.Fsd( FrequencyNo ) + sd;

          if scan_information.mask.isRegistered % -- && constant_define( 'PREFERENCES', 'general.gray_white_split' )
            for ii = 1:5
              if reg_data.count(ii) > 0
                SSQ.Rsd(ii) = SSQ.Rsd(ii) + ...
                    sum(diag( E(reg_data.ind(ii).zref) * E(reg_data.ind(ii).zref)' ) ); % --- sum(sd(reg_data.ind(ii).zref) );
              end
            end
          end

          if ~isempty(pop)
            pop.increment();
          end
        
        end  % --- run is encoded
      end  % --- each run

    end  % --- each frequency

    SSQ.Subject = [SSQ.Subject; A];
    save( Zvars, 'SSQ', '-v7.3', '-append' );
    
  end  % --- each subject
  
  % --- preserve study information 
  si_save = scan_information;
  z_save = Zheader;

  % --- adjust study information to new Residual Z
  Zheader.conditions = struct( ...	  % [2.8] subjects must have the same conditions ( runs may use different )
    'Names', [], ...			  % all condition names ( each subject must encode all conditions )
    'subject', [], ...   		  % subject(n).Runs []  each encoded condition per subject run
    'encoded', [], ...   		  % logical flag for all defined conditions encoded per subject
    'allEncoded', 0, ...   		  % total number of encoded conditions 
    'nonEncoded', 0, ...   		  % total number of non encoded conditions 
    'sp', []);			          % start row of each condition by subject ( add bin number )

  Zheader.Z_File = struct ( ...
  'name', '', ...			% name of Z file
  'directory', '', ...			% directory Z file located in
  'variable', '', ...			% struct containing variable info
  'mean_centered', 0, ...		% flag set if data is mean centered
  'normalized', 0 );			% flag set if data is normalized

  Zheader.Z_Directory = [ pwd filesep Residual_dir filesep ];
  Zheader.Z_Original = '';


  st = struct ( ...
  'file_exists', 0, ...
  'path', '', ...
  'mat_exists', 0, ...
  'hdr_exists', 0, ...
  'mat', '', ...
  'mat_x', 0, ...
  'mat_y', 0 );

  Zheader.Model = st;
  Zheader.Contrast = st;
  Zheader.Limits = st;
  Zheader.P = st;
  Zheader.D = st;

  mat_file = [Residual_dir filesep 'ZInfo.mat'];
  mat_list = ' Zheader scan_information';
  if exist( 'SD', 'var' )
    mat_list = [mat_list ' SD' ];
  end;
  if exist( 'tsum_removed', 'var' )
    mat_list = [mat_list ' tsum_removed' ];
  end;
  
  eval( [ 'save ' mat_file mat_list ' -v7.3' ] );

  Zheader.tsum = accumulate_Z_SSQ(Residual_dir);
  save( mat_file, 'Zheader', '-append', '-v7.3');

  Z_SD_Report( [Residual_dir filesep ] );
        
  
%  Gheader = new_gheader();
%  mat_file = ['Residual' filesep '/ZInfo.mat'];
  
  Zheader = z_save;
  scan_information = si_save;
  
  pop.hide();

  if size(process_information.sudo.user, 2) > 0 && process_information.sudo.confirmed == 1
    cmd = ['!chown -R ' process_information.sudo.user '.' process_information.sudo.group ' *' ];
    eval( cmd );
  end
  
end

  %% --- Accumulate_Z_SSQ ()
  %  --- -----------------------------------
  function ts = accumulate_Z_SSQ(Residual_dir)
  global Zheader
  
    ts = 0;
    A = [];
    SSQ = struct( 'sd', 0, ...                                          % --- total Z sum diagonal
                  'Rsd', zeros( 1, 5 ), ...     
                  'Fsd', zeros( 1, max(1, Zheader.num_Z_arrays) ), ...   % --- total Z sum diagonal by frequency
                  'Subject', struct( ...
                    'sd', zeros(Zheader.num_runs, 1 ), ...                             
                    'Fsd', zeros( Zheader.num_runs, max(1, Zheader.num_Z_arrays) ) ) );   

    for SubjectNo=1:Zheader.num_subjects
      A = load_subject_Z_var( SubjectNo, 'SSQ');
      
      if ~isempty(A)
        SSQ.sd =  SSQ.sd + A.sd;
        SSQ.Fsd =  SSQ.Fsd + A.Fsd;
        SSQ.Rsd =  SSQ.Rsd + A.Rsd;

        SSQ.Subject.sd =  SSQ.Subject.sd + A.Subject.sd;
        SSQ.Subject.Fsd =  SSQ.Subject.Fsd + A.Subject.Fsd;

      end % -- variable loaded

    end % each subject

    Zvars =  [Residual_dir filesep 'Z' filesep 'Z_vars'];
    initialize_non_existing_file( Zvars );
    save( Zvars, 'SSQ', '-v7.3', '-append' );
  
    ts = SSQ.sd;
    
  end  


