function converted = convert_ZInfo( fullpath )
% --- convert a legacy ZInfo mat file to current studyInfo segmentation
% --- data file

  % flag successful conversion
  % --------------------------------------------------------
  converted = 0;
  
  Zpath = split_path( fullpath, filesep );
  
  % create default studyInfo data tables
  % --------------------------------------------------------
  studyInfo = study_parameters();
  Zheader = [];
  scan_information = [];
  
  % load in the legacy ZInfo data
  % --------------------------------------------------------
  load( fullpath );
  if ~isempty( Zheader )

    % adjust the header data to the most current legacy model if required
    % --------------------------------------------------------
    [Zheader, scan_information] = adjust_headers( Zheader, scan_information, Zpath );
  
    % check that the adjustment did not corrupt the partitioning status
    % --------------------------------------------------------
    if ( Zheader.partitions.partitioned == 0 )

      x = who_count( [Zpath filesep 'Z' filesep], 'Z1.mat', 'Z_R1_*' );
      if ( x > 0 ) 

        Zheader.partitions.partitioned = 1;
        Zheader.partitions.count = x;
        xx = who_stats( [Zpath filesep 'Z' filesep], 'Z1.mat', 'Z_R1_C1' );
        Zheader.partitions.width = xx.mat_y;

        eval ( [ 'xx = who_stats( ''' [Zpath filesep 'Z' filesep] ''', ''Z1.mat'', ''Z_R1_C' num2str(x) ''');' ] );
        Zheader.partitions.last = xx.mat_y;

        Zheader.partitions.columns = [];
        for ii = 1:(x-1)
          Zheader.partitions.columns = [Zheader.partitions.columns Zheader.partitions.width];
        end
        Zheader.partitions.columns = [Zheader.partitions.columns Zheader.partitions.last];

        Zheader.partitions.mem = array_sizes( [Zheader.total_scans Zheader.partitions.width ] );

      end
    end
  
                                                                           % --- full path to study location
    studyInfo.General.location              = reset_path_separator ( Zheader.Z_Directory ); 
    studyInfo.General.num_subjects          = Zheader.num_subjects;        % --- number of study participants
    studyInfo.General.num_runs              = Zheader.num_runs;            % --- maximum number of scan sessions
    studyInfo.General.min_runs              = scan_information.MinRuns;    % --- minimum number of scan sessions 
    studyInfo.General.active_runs           = Zheader.active_runs;         % --- total of all scan sessions
    studyInfo.General.num_Z_arrays          = Zheader.num_Z_arrays;        % --- each frequency range is tagged as a separate Z Array
    studyInfo.General.total_scans           = Zheader.total_scans;         % --- total number of scan in study
    studyInfo.General.total_columns         = Zheader.total_columns;       % --- number of selected voxels
    studyInfo.General.max_scans             = Zheader.max_scans;           % --- maximum number of scans in a subject
    studyInfo.General.min_scans             = Zheader.min_scans;           % --- minimum number of scans in a subject
    studyInfo.General.multi_frequeny        = scan_information.isMulFreq;  % --- flag indicating study contains frequency range data
    studyInfo.General.frequencies           = max( 1, scan_information.frequencies );  % --- number of frequency ranges
    studyInfo.General.frequency_labels      = scan_information.freq_names; % --- labels to use to tag frequency range data ( ie: Z_25Hz )
    studyInfo.General.timeseries.subject    = Zheader.timeseries.subject;  % --- number of scans and full study start position per subject/run  
    studyInfo.General.timeseries.vector     = Zheader.ts_vector;           % --- unused - legacy values preserved for linear/quad regression
    studyInfo.General.partitions            = Zheader.partitions;          % --- see structure_define90 for description

    studyInfo.Source.base_dir               = reset_path_separator ( scan_information.BaseDir );    % --- base directory of source scan data
    studyInfo.Source.list_spec              = scan_information.ListSpec;   % --- wildcard file specifier for scan image selectiom
    studyInfo.Source.subj_dir               = reset_path_separator ( scan_information.SubjDir );    % --- cell matrix of each sunbej run directory location
    studyInfo.Source.frequency_dirs         = reset_path_separator ( scan_information.freq_dirs );  % --- frequency directory names
    studyInfo.Source.subject_dirs           = reset_path_separator ( scan_information.SubjectDirs );% --- subject directory names
    studyInfo.Source.run_dirs               = reset_path_separator ( scan_information.run_dirs );   % --- tilde delimited run directories for each subject
    studyInfo.Source.scandir_format         = reset_path_separator ( scan_information.scandir_format ); % --- format specifier to locate scans
    studyInfo.Source.file_list              = reset_path_separator ( scan_information.FileList );   % --- full path to text file used to parse information
    studyInfo.Source.subject_id             = scan_information.SubjectID;  % --- subject5 identifier of each subject ( defaults to subject directory name )
    studyInfo.Source.duplicate_id           = scan_information.duplicate_IDs; % --- flag indicating duplicate subject id's in data
    studyInfo.Source.rp_count               = scan_information.processing.subjects.rp_count;        % --- number of SPM rigid body parameter files discovered in subject run directories
    studyInfo.Source.tt_count               = scan_information.processing.subjects.tt_count;        % --- nunber of cpca trial timings files discovered in subject run directories
 
    studyInfo.Stats.tsums.rfac              = Zheader.rfac;                % --- vector of regression data during normalization
    studyInfo.Stats.tsums.with_trends       = Zheader.tsum_with_trends;    % --- sum of squares of Z data prior to regressio
    studyInfo.Stats.tsums.linear_trends     = Zheader.tsum_linear_trends;  % --- sum of squares of linear trends removed from Z data
    studyInfo.Stats.tsums.quadratic_trends  = Zheader.tsum_quadratic_trends; % --- sum of squares of quadratic trends removed from Z data
    studyInfo.Stats.tsums.user_trends       = Zheader.tsum_user_trends;    % --- sum of squares of user define regression trends removed from Z data
    studyInfo.Stats.tsums.hm_trends         = Zheader.tsum_hm_trends;      % --- sum of squares of head movement trends removed from Z data  ( SPM rp files )
    studyInfo.Stats.tsums.trends            = Zheader.tsum_trends;         % --- sum of squares of all trends removed from Z data
    studyInfo.Stats.tsums.tsum              = Zheader.tsum;                % --- sum of squares of final regressed/normalized Z data matrix
  
    studyInfo.Groups.num_groups             = size( scan_information.GroupList, 1 );  % --- number of defined participant groupings
    studyInfo.Groups.group_list             = scan_information.GroupList;
  
    if ~isempty( scan_information.mask )    % --- image data structure ( ref structure_define )
      studyInfo.Mask                        = scan_information.mask;
      studyInfo.Mask.file                   = reset_path_separator ( studyInfo.Mask.file );
      studyInfo.Mask.vol.fname              = reset_path_separator ( studyInfo.Mask.vol.fname );
    end
  
    if ~isempty( Zheader.Model )            % --- ref structure_define 'gheader'
      studyInfo.Models.G                    = Zheader.Model;
      studyInfo.Models.G.path               = reset_path_separator ( studyInfo.Models.G.path );
    end
  
    if ~isempty( Zheader.Contrast )         % --- ref structure_define 'aheader'
      studyInfo.Models.A                    = Zheader.Contrast;
      studyInfo.Models.A.path               = reset_path_separator ( studyInfo.Models.A.path );
    end
  
    if ~isempty( Zheader.Contrast )         % --- ref structure_define 'hheader'
      studyInfo.Models.H                    = Zheader.Limits;
      studyInfo.Models.H.path               = reset_path_separator ( studyInfo.Models.H.path );
    end
  
 
    if ~isempty( Zheader.conditions )
       if isfield( Zheader.conditions, 'Names'),      studyInfo.Conditions.name  = Zheader.conditions.Names;            end
       if isfield( Zheader.conditions, 'subject'),    studyInfo.Conditions.subject  = Zheader.conditions.subject;       end
       if isfield( Zheader.conditions, 'encoded'),    studyInfo.Conditions.encoded  = Zheader.conditions.encoded;       end
       if isfield( Zheader.conditions, 'allEncoded'), studyInfo.Conditions.allEncoded  = Zheader.conditions.allEncoded; end
       if isfield( Zheader.conditions, 'nonEncoded'), studyInfo.Conditions.nonEncoded  = Zheader.conditions.nonEncoded; end
       if isfield( Zheader.conditions, 'sp'),         studyInfo.Conditions.sp  = Zheader.conditions.sp;                 end
    end
  
    studyInfo.Timing.mean_centered         = Zheader.MeanCentered;
    studyInfo.Timing.normalized            = Zheader.Normalized;

  
%    save_study_parameters( studyInfo );
  
    converted = 1;

  end
  
