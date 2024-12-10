function rv = verify_user_mask( SubjectNo, RunNo, FrequencyNo, pop )
% read in raw scan images for a specified subject and confirm that the mask applies porperly to the subject data
%
global scan_information Zheader process_information 

  sc = struct( ...
    'count', 0, ...
    'min', 0, ...
    'max', 0, ...
    'nans', [], ...
    'error', '');

  xx = 0;
  if ( nargin < 4 )  pop = []  end;
  if ( nargin < 3 )  FrequencyNo = 1; end;
  if ( nargin < 2 )  RunNo = 1; end;
  if ~strcmp( class(pop), 'cpca_progress' )
    pop = []; 
  end

  sid = subject_id( SubjectNo );

  rv = sc;

  time_series = Zheader.timeseries.subject(SubjectNo).run(RunNo,1);
  bar_max = time_series;

  Txt = 'Applying mask to subject images . . .';
  if ~isempty(pop)
    pop.setParticipant( SubjectNo, Zheader.num_subjects, sid );
    pop.setIterations( time_series);
  end;

  %------------------------------------------------
  % full path of subject scan files for directory reading 
  %------------------------------------------------
  subject_dir = subject_scan_directory( SubjectNo, RunNo, FrequencyNo);
  dirspec = [ subject_dir filesep scan_information.ListSpec ];

  % --------------------------------------------------------
  % read directory and process individual files
  % --------------------------------------------------------
  D=dir(dirspec);
  n_files=size(D);

  % =========================================================
  % load and each subject scan per run

  % --= 
  % --= for each subject
  % --=   for each run

  if ~isempty(pop)
    pop.setMessage( Txt, '', '' );
  end;

  for scan_no = 1:time_series

    if ~isempty(pop)
      pop.increment();
    end;

    %------------------------------------------------
    % full path of subject individual scan file
    %------------------------------------------------
    filespec = [ subject_dir filesep D(scan_no).name ];
           
    %------------------------------------------------
    % load in scan image and place in holding matrix
    % --=     for each scan image
    % --=  
    %------------------------------------------------

    img = cpca_read_vol( filespec);	% --=
    if isfield( img.header, 'error' )	% --=
      rv.count = -1;	% --=
      rv.max = 0;	% --=
      rv.min = 0;	% --=
      rv.error = img.header.error;	% --=
      return;	% --=
    end;	% --=

    scan_image(1,:)=img.image(find(scan_information.mask.image)); % --=
    if ( scan_no == 1 )	% --=
      scan_sum = abs(scan_image);	% --=
    else	% --=
      scan_sum = scan_sum + abs(scan_image);	% --=
    end;	% --=

    xx = sum( sum( scan_image ) ); % --=
    if isnan(xx) | isinf(xx)
      rv.nans = [rv.nans scan_no];

      fid = fopen( 'scan_errors.txt', 'a' );  % --- append offending file to list
      if fid
        fprintf( fid, '%3d - %s\n', scan_no, filespec );
        fclose( fid );
      end;

%      rv.error = 'Subject scans contain NaN or Inf';	% --=
    end;

  % --=  
  end;  % --= process each scan

  xx = find(scan_sum == 0 ); % --=
  rv.count = size(xx,1)*size(xx,2); % --=
  rv.max = max(scan_sum); % --=
  rv.min = min(scan_sum); % --=

  fid = fopen( 'scan_summary.txt', 'a' );  % --- append offending file to list
  if fid
    fprintf( fid, 'Subject %3d (%5s) Run %d [%s]: %3d \n', SubjectNo, sid, RunNo, char(scan_information.freq_dirs(FrequencyNo)), rv.count );
    fclose( fid );
  end;

  % --- for Jen 

  
  % --=  
  % --=   end  % ---each run
  % --= end  % --- each subject
   

