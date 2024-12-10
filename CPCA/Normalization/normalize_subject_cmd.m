function [SSQ, Zheader, scan_information]= normalize_subject_cmd( SubjectNo, FrequencyNo, fid, Zheader, scan_information )
% --- read in raw scan images for a specified subject and apply the desired
% --- level of normalization ( linear regression, mean centering and/or standardization
%

% -----------------------------------------------------------------------
% --- Normalization Process code base and explanation
% ---   - process repeated for each individual run per subject
%
% ---  load all scans per subject run into single matrix  ---  Z{run#}
% ---  remove linear trends ( original code from Dr. Liang Wang located at that point in this file )
%
% ---  use mean/std on raw subject data to center around 0 and 1 per subject
% ---    --- in this instance, std is n-1 subject scans, not the total of all subject scans - 1
%
% ---  divide each normalized subject data set into columnar segments to allow creation of
% ---  matrix to perform operations on full width or full length of data set.
% ---  each segment name forma is Z_Rn_C#  ( where n = Run Number;   # = segment Number
% ---    --- eg Z_R1_C2 is the second segment of Run 1 
%
% --- assuming 3 subjects divided into 2 segments
% --- S1 = [Z_R1_C1 Z_R1_C2];		each segment loaded from the individual subject data set concatenated horizontally
% --- C1 = [Z_R1_C1; Z_R1_C1; Z_R1_C1]; 	each segment loaded from Zn.mat concatenated vetrically --  where n = subject number
% -----------------------------------------------------------------------


%   Zheader = [];
%   scan_information = [];
%   load( 'ZInfo.mat', 'Zheader', 'scan_information' );

  ab = 0;		% --- error in data flag telling cpca to abort process
  SD = [];
  tsum_subject = 0;
  Z = [];
  SS_E = [];

  SSQ.sd = 0;                                          % --- total Z sum diagonal
  SSQ.Fsd = zeros( 1, max(1, Zheader.num_Z_arrays) );   % --- total Z sum diagonal by frequency
  SSQ.Rsd = zeros( 1, 5 );                              % --- total Z sum diagonal by Registered area
  SSQ.Subject = [];
  
  if scan_information.mask.isRegistered % -- && constant_define( 'PREFERENCES', 'general.gray_white_split' )
    reg_data = mask_registrations( scan_information.mask );  
  end
  
  A.sd = zeros(Zheader.num_runs, 1 );                             % --- total Z sum diagonal for subject
  A.Fsd = zeros( Zheader.num_runs, max(1, Zheader.num_Z_arrays) ); % --- total Z sum diagonal for subject by frequency
  A.Rsd = zeros( Zheader.num_runs, 5 );                              % --- total Z sum diagonal by Registered area
  
  xx = 0;
  if ( nargin < 3 )  FrequencyNo = 1;  end
  if ( nargin < 4 )  fid = 0;  end

  sid = '';

  if ( ~isfield( Zheader, 'partitions' ) ) Zheader.partitions = 0; end
  if ( ~isfield( Zheader.partitions, 'count' ) )
    Zheader.partitions = calc_column_partitions( Zheader.total_scans, Zheader.total_columns, constant_define( 'PARTITION_MAXC') );
  end

  [ ftag, fdsp ] = frequency_tag_cmd(FrequencyNo,scan_information) ;

  print_and_log( fid, ' - Subject %s %2d of %d Run: %2d %s', char(scan_information.SubjectID( SubjectNo )),  SubjectNo, Zheader.num_subjects, 1, fdsp );
  if ( fid )
    fprintf( fid, '\n' );
  end
  
  done_bar = structure_define( 'PROG_BAR' );
  bar = prep_done_bar( done_bar );                                 
  fprintf( '%s', bar );

  tic;
  sid = subject_id_cmd( SubjectNo,scan_information );
 
  x = exist( [pwd filesep 'Z'], 'dir');
  if x~=7
    eval( [ 'mkdir ''' pwd filesep 'Z'''] )
  end
 
  % ---------------------------------------------------
  % --- recreate the ts_vector if required
  % ---------------------------------------------------

  perform_covariant_regression = ( scan_information.processing.subjects.process.movement_regress + ...
        scan_information.processing.subjects.process.linear_regress + ...
        scan_information.processing.subjects.process.quadratic_regress ) * ... 
        scan_information.processing.subjects.process.apply_regression;
 

  if ( scan_information.processing.subjects.process.linear_regress == 1 )
    if ( isempty( Zheader.ts_vector ) )


      Zheader.ts_vector = [];
      for s = 1:Zheader.num_subjects
        for r = 1:Zheader.num_runs
          Zheader.ts_vector = vertcat(Zheader.ts_vector, Zheader.timeseries.subject(s).run(r,1) );
        end
      end

    end

  end

  tsum_removed = 0;			% --- tsum regressed out for each subject

  Zname = ['Z' filesep 'Z' num2str(SubjectNo) ftag '.mat'];
  initialize_mat_file( Zname );

  Zvars= ['Z' filesep 'Z' num2str(SubjectNo) '_vars.mat'];
  if ( FrequencyNo == 1 )
    initialize_mat_file( Zvars );
  end
  
  for RunNo = 1:Zheader.num_runs

    rSSE  = [0 0 0 0 0 0 0 0];	% sum of squares of Error * subject ssZ per regression factor

    if isEncodedRun_cmd(SubjectNo, RunNo ,scan_information) 

      time_series = Zheader.timeseries.subject(SubjectNo).run(RunNo,1);
      voxels = Zheader.total_columns;
      bar_max = time_series;  % ---  * 2;


      % --- we're going to time the operation and estimate image scan duration
      % --- first step will be to get a time for each row scan and calculate a formula to
      % --- estmate the increasing time delay as the arry increases in X dimensions

      subject_dir = subject_scan_directory_cmd( SubjectNo, RunNo, FrequencyNo, scan_information);
      filespec = [subject_dir filesep char(scan_information.ListSpec)];

      % -----------------------------------------------------------
      % --- read directory and process individual files
      % -----------------------------------------------------------
      D=dir(filespec);
      n_files=size(D);

      % -----------------------------------------------------------
      % --- load and concatenate subject scans per run

      Z = zeros( time_series, Zheader.total_columns );

      for scan_no = 1:time_series

        [xx, bar] = proc_done_bar( scan_no, bar_max, done_bar, xx );
        if ~isempty(bar)
          fprintf('%s', bar );
        end

        %------------------------------------------------
        % --- full path of subject individual scan file
        %------------------------------------------------
        filespec = [subject_dir filesep, D(scan_no).name ];

        %------------------------------------------------
        % --- load in scan image and place in holding matrix
        %------------------------------------------------

        % --= 
        % --=     for each image
        % --=       Z = [Z; scanned_image( mask_index )];
        % --=     end
   
        img = cpca_read_vol( filespec );
        Z(scan_no,:) = img.image( scan_information.mask.ind(:) )';
        
        
      end  % --- process each scan

      % if ( ~isempty( funcs.memory_stats ) ) funcs.memory_stats(); end

      %------------------------------------------------
      % --- pre-normalize subject data
      %------------------------------------------------

      %------------------------------------------------
      % ---     regression variables
      %------------------------------------------------

      G = [];

      linear = [1:time_series];
      linear = linear - ones(1,time_series) * mean(linear);

      quadratic = linear.^2;
      quadratic = quadratic - ones(1,time_series) * mean(quadratic);

      if ( perform_covariant_regression > 0 )  % -- apply any form of regression

        X = [];
        C = ones(1,time_series)';
        Intercept = 0;

        % --= 
        % --=     %------------------------------------------------
        % --=     % --- pre-standardize subject data
        % --=     %------------------------------------------------
 
        column_mean = mean( Z );
        SD = samp_dev( Z );

        for ii = 1:time_series

          Z(ii,:) = ( Z(ii,:) -column_mean(1,:));
          Z(ii,:) = ( Z(ii,:) ./ SD(1,:));

        end

        tsum_with_trends = get_sum_diagonal( 'Z' );
        Zheader.tsum_with_trends = Zheader.tsum_with_trends + tsum_with_trends;

        user_covariants = [];
        if ( scan_information.processing.subjects.process.user_covariants )
          if ( size( scan_information.processing.subjects.process.user_covariants_file, 2 ) > 1 )
            user_covariants = load( scan_information.processing.subjects.process.user_covariants_file, '-ASCII' );
          end

        end

        %------------------------------------------------
        % --- Head Movement Regression files check
        %------------------------------------------------
        G = [];
        if ( scan_information.processing.subjects.process.movement_regress == 1 )

          fil = dir( [subject_dir filesep 'rp_*.txt']  );
          if ( size( fil, 1) == 0 )
            fprintf( 'Unable to locate a movement regression text file for subject %s run %d', char(scan_information.SubjectID(SubjectNo)), RunNo ) ;
            SSQ = [];
            return
          end
          fil = [subject_dir filesep fil(1).name ] ;

          G = load( fil );
          bar_max = bar_max + Zheader.total_columns;

        end  		% ----- load head movement regression data ---

        %------------------------------------------------
        % --- remove trends and preserve percentage
        %------------------------------------------------

        ssZ = get_sum_diagonal( 'Z' );
        
        if ( scan_information.processing.subjects.process.linear_regress == 1 )

          X = linear';
          beta1 = pinv(X'*X)* X' * Z;

          Trends = X * beta1;
          Zn = Z - Trends;

          rSSE(1) = get_sum_diagonal( 'Zn' );
          rSSE(5) = ssZ;  

        end

        %------------------------------------------------
        % --- remove Quadratic trends and preserve percentage
        %------------------------------------------------

        if ( scan_information.processing.subjects.process.quadratic_regress == 1 )

          X = [X,quadratic'];
          beta1 = pinv(X'*X)* X' * Z;

          Trends = X * beta1;
          Zn = Z - Trends;

          rSSE(2) = get_sum_diagonal( 'Zn' );
          rSSE(6) = ssZ;  

        end

        %------------------------------------------------
        % --- remove Head Movement trends and preserve percentage
        %------------------------------------------------

        if ( ~isempty( G) )

          X = [X,G];
          beta1 = pinv(X'*X)* X' * Z;

          Trends = X * beta1;
          Zn = Z - Trends;

          rSSE(3) = get_sum_diagonal( 'Zn' );
          rSSE(7) = ssZ;  

        end

        %------------------------------------------------
        % --- remove User Defined trends and preserve percentage
        %------------------------------------------------

        if ( ~isempty( user_covariants ) )
          sr = Zheader.timeseries.subject(SubjectNo).run(RunNo,2);
          er = sr + Zheader.timeseries.subject(SubjectNo).run(RunNo,1) - 1;
          X = [X,user_covariants(sr:er,:)];
          beta1 = pinv(X'*X)* X' * Z;

          Trends = X * beta1;
          Zn = Z - Trends;

          rSSE(4) = get_sum_diagonal( 'Zn' );
          rSSE(8) = ssZ;  

        end

        %------------------------------------------------
        % --- regress from Z
        % --- intercept will either be a scalar 0 or a matrix the size of Z
        %------------------------------------------------
        Zn = Trends;  %  - Intercept;
        Zheader.tsum_trends = Zheader.tsum_trends + get_sum_diagonal( 'Zn' );
        Z = Z - Trends;

      end  % --- apply pre Standardization regression

      %------------------------------------------------
      % --- perform requested normalization
      %------------------------------------------------


%       if scan_information.processing.subjects.process.mean_center || scan_information.processing.subjects.process.standardize
          
        if  Zheader.timeseries.subject(SubjectNo).run(RunNo,1) > 1
          column_mean = mean( Z );
          SD = samp_dev( Z );
        else
          column_mean = zeros( 1, Zheader.total_columns );
          SD = ones( 1, Zheader.total_columns );
        end

        sd = zeros(1, time_series );
        for ii=1:time_series

          if scan_information.processing.subjects.process.mean_center
            Z(ii,:) = Z(ii,:) - column_mean;
          end
          
          if scan_information.processing.subjects.process.standardize
            Z(ii,:) = Z(ii,:) ./ SD(1,:);
          end
        
          sd(ii) = ( Z(ii,:) * Z(ii,:)' );
          Zheader.tsum = Zheader.tsum + sd(ii);
          tsum_subject = tsum_subject + sd(ii);

        end
%       end;

      Zheader.Z_Directory = [pwd '/'];

%      sd = sum(diag( Z * Z' ));

      A.sd(RunNo) = A.sd(RunNo) + sum(sd);
      A.Fsd(RunNo, FrequencyNo ) = A.Fsd(RunNo, FrequencyNo ) + sum(sd);
      SSQ.sd = SSQ.sd + sum(sd);
      SSQ.Fsd( FrequencyNo ) = SSQ.Fsd( FrequencyNo ) + sum(sd);

      if scan_information.mask.isRegistered % -- && constant_define( 'PREFERENCES', 'general.gray_white_split' )
        sd = zeros( size( scan_information.mask.ind ) );
        for ii=1:numel(sd)
          sd(ii) = sum(diag( Z(:,ii) * Z(:,ii)' ));
        end
%        sd = diag( Z( reg_data.ind(ii).zref) * Z(reg_data.ind(ii).zref)' );
        for ii = 1:5
          if reg_data.count(ii) > 0
            SSQ.Rsd(ii) = SSQ.Rsd(ii) + sum(sd(reg_data.ind(ii).zref) );
          end
        end
      end
      

      save( Zname, 'SD', 'tsum_removed', 'tsum_subject',  '-append' );
      save_columns_of_Z_cmd( Z,scan_information, SubjectNo, RunNo, FrequencyNo ,Zheader );
      Z = [];
      % if ( ~isempty( funcs.clear_cache ) )  funcs.clear_cache( pop); end; funcs.memory_stats(); 

      SS_E = [SS_E; rSSE];

    end  % ---  Subject contains Run

  end  % --- each Subject Run

  SSQ.Subject = [SSQ.Subject; A];

  scan_information.processing.subjects.process.last_subject = SubjectNo;

  save( 'ZInfo.mat', 'SD', 'tsum_removed',  '-append' );
  save_Zinfo( Zheader, scan_information );
  
  save( Zvars, 'SD', 'tsum_removed', 'tsum_subject', 'SS_E',  '-append' );

  total_time = toc;
  str = format_toc( total_time, 'short');
  fprintf(' [%s]\n', str );


  
  function ss = get_sum_diagonal( which_one )
    ss = 0;
    m = 0;
    eval( [ 'm = size( ' which_one ', 1);' ] );
      for w = 1:m
        eval( [ 'ss = ss + ' which_one '(w,:) * ' which_one '(w,:)'';' ] );
      end
  end

end
