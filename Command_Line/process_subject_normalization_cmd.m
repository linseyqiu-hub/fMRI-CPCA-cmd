function process_subject_normalization_cmd(base_dir,varargin)
%% --- process_subject_normalization
% ---
% --- Normalize Z data matrix
% ---
% --- input:
% ---     base_dir: specify work folder,
% --      linearRegress: 1- On, 0 - Off
% --      quadraticRegress: 1- On, 0 - Off
% --      movementRegress: 1- On, 0 - Off, looking for rp{...}.txt file
% --      userCovariants: filename for user define covariants
% --      meanCenter: 1- On, 0 - Off
% --      standardize: 1- On, 0 - Off
%---- example
%----- process_subject_normalization_cmd('./example_data_Multiple_Groups_Subjects_Runs',...
% ---                       'linearRegress',1,...
% ---                       'quadraticRegress',1,..
% ---                       'meanCenter',1,...
% ---                       'standardize',1)


defaultLinearRegress = 1;
defaultQuadraticRegress = 1;
defaultMovementRegress = 0;
defaultMeanCenter = 1;
defaultStandardize = 1;


p = inputParser;
addRequired(p,'baseDir',@(x)validateattributes(x,{'char'},{'nonempty'}));
addParameter(p,'linearRegress',defaultLinearRegress, @(x)validateattributes(x,{'numeric'},{'nonempty','integer'}))
addParameter(p,'quadraticRegress',defaultQuadraticRegress, @(x)validateattributes(x,{'numeric'},{'nonempty','integer'}))
addParameter(p,'movementRegress',defaultMovementRegress, @(x)validateattributes(x,{'numeric'},{'nonempty','integer'}))
addParameter(p,'userCovariants',[],@(x)validateattributes(x,{'char'},{'nonempty'}));
addParameter(p,'meanCenter',defaultMeanCenter, @(x)validateattributes(x,{'numeric'},{'nonempty','integer'}))
addParameter(p,'standardize',defaultStandardize, @(x)validateattributes(x,{'numeric'},{'nonempty','integer'}))


parse(p,base_dir,varargin{:});

% ----check inputs--------------------------
base_dir = p.Results.baseDir;
cd(base_dir)

if exist([base_dir filesep 'ZInfo.mat'], 'file') ~= 2
    disp('Zinfo file does not exist.');
    return
end

%  --- -----------------------------------
load( 'ZInfo.mat', 'Zheader', 'scan_information' );

if(p.Results.linearRegress || p.Results.quadraticRegress || p.Results.movementRegress || ~isempty(p.Results.userCovariants) )
    scan_information.processing.subjects.process.apply_regression = 1;
else
    scan_information.processing.subjects.process.apply_regression = 0;
end
if(p.Results.linearRegress)
    scan_information.processing.subjects.process.linear_regress = 1;
else
    scan_information.processing.subjects.process.linear_regress = 0;
end
if(p.Results.quadraticRegress)
    scan_information.processing.subjects.process.quadratic_regress = 1;
else
    scan_information.processing.subjects.process.quadratic_regress = 0;
end
if(p.Results.movementRegress)
    scan_information.processing.subjects.process.movement_regress = 1;
else
    scan_information.processing.subjects.process.movement_regress = 0;
end
if(p.Results.meanCenter)
    scan_information.processing.subjects.process.mean_center = 1;
else
    scan_information.processing.subjects.process.mean_center = 0;
end
if(p.Results.standardize)
    scan_information.processing.subjects.process.standardize = 1;
else
    scan_information.processing.subjects.process.standardize = 0;
end
%scan_information.processing.subjects.process.create_ZZ = 0;
%scan_information.processing.subjects.process.extract_clusters = 0;
if(~isempty(p.Results.userCovariants))
    scan_information.processing.subjects.process.user_covariants=1;
    scan_information.processing.subjects.process.user_covariants_file=p.Results.userCovariants;
else
    scan_information.processing.subjects.process.user_covariants=0;
    scan_information.processing.subjects.process.user_covariants_file='';
end

log_results = 1;		% set to 0 if you want to run tests without a ton of files in the directory
tic

mkdir log;
dt = date;
cl = clock;
ampm = 'AM';

if cl(4) > 12
    ampm = 'PM';
    cl(4) = cl(4) - 12;
end

hr = sprintf( '%02d', cl(4) );
mn = sprintf( '%02d', cl(5) );

log_fn = ['log/cpca_processing_' dt '_' hr ':' mn '_' ampm '.txt' ];
log_fn = strrep( log_fn, ':', '_' );

if log_results
    log_fid = fopen( log_fn, 'w' );
    if log_fid == -1
        log_fid = 0;
    end   % -- some remote systems may fail on log opening
else
    log_fid = 0;
    print_title( 'Output logging is off.' );
end

timers.Normalize.start_time = clock;

estimated_time = Zheader.total_scans * scan_information.image_read_average;
estimated_time = estimated_time + (Zheader.total_scans / scan_information.normalize_average);
estimated_time = estimated_time + (Zheader.total_scans / scan_information.save_average);
str = format_toc( estimated_time, 'Estimated Completion Time: ' );
print_and_log( log_fid, '%s\n', str );




% if ( Zheader.cluster_data )
%   Txt = 'Extracting Clusters from Voxel Data';
%   Sts = 'Extracting Clusters';
% else
disp('Creating Z matrix from scan images') ;
% end

start_subj = 1;
if ( scan_information.processing.subjects.process.resume )
    start_subj = start_subj + scan_information.processing.subjects.process.last_subject;
else
    if ( Zheader.cluster_data == 0 )
        Zheader.tsum = 0;
        Zheader.tsum_with_trends = 0;
        Zheader.tsum_trends = 0;
        Zheader.tsum_linear_trends = 0;
        Zheader.tsum_quadratic_trends = 0;
        Zheader.tsum_hm_trends = 0;
        Zheader.tsum_user_trends = 0;
        Zheader.tsum_E = 0;
    end
    Zheader.tsum_clusters = 0;

end

if ( start_subj <= Zheader.num_subjects )     % allow for single subjects

    perform_covariant_regression = ( scan_information.processing.subjects.process.movement_regress + ...
        scan_information.processing.subjects.process.linear_regress + ...
        scan_information.processing.subjects.process.quadratic_regress ) * ...
        scan_information.processing.subjects.process.apply_regression;



    disp( 'Normalizing Subject Data' );


    for SubjectNo=start_subj:scan_information.NumSubjects

        SSQ.sd = 0;                                           % --- total Z sum diagonal
        SSQ.Rsd = zeros( 1, 5 );                              % --- total Z sum diagonal by Registered area
        SSQ.Fsd = zeros( 1, max(1, Zheader.num_Z_arrays) );   % --- total Z sum diagonal by frequency
        SSQ.Subject = struct( ...
            'sd', zeros(Zheader.num_runs, 1 ), ...
            'Fsd', zeros( Zheader.num_runs, max(1, Zheader.num_Z_arrays) ) );

        for FrequencyNo = 1:Zheader.num_Z_arrays

            % if ( Zheader.cluster_data )
            %   ab = extract_clusters( SubjectNo, log_fid, 1 );
            %   clear extract_clusters
            % else

            [SS, Zheader, scan_information] = normalize_subject_cmd(SubjectNo, FrequencyNo, log_fid, Zheader, scan_information );
            % clear normalize_subject


            if ~isempty( SS )
                ab = 0;
                SSQ.sd = SSQ.sd + SS.sd;
                SSQ.Rsd = SSQ.Rsd + SS.Rsd;
                SSQ.Fsd(FrequencyNo) = SSQ.Fsd(FrequencyNo) + SS.sd;
                SSQ.Subject.sd = SSQ.Subject.sd + SS.Subject.sd;
                SSQ.Subject.Fsd = SSQ.Subject.Fsd + SS.Subject.Fsd;
            else
                ab = 1;
            end
            % end


            Zheader.partitions.partitioned = 1;


        end  % --- each frequency

        Zvars = ['Z' filesep 'Z' num2str(SubjectNo) '_vars.mat'];
        save( Zvars, 'SSQ',  '-append' );

    end % --- each subject

    Z_SD_Report_cmd(Zheader,scan_information);
    SSQ = accumulate_Z_SSQ();
    Zheader.tsum = SSQ.sd;
    Zheader.rsum = SSQ.Rsd;
    Zheader.rfac = calc_regression_stats_cmd(Zheader, scan_information);
    Zheader.tsum_linear_trends = Zheader.tsum * ( Zheader.rfac(1) /100 );
    Zheader.tsum_quadratic_trends = Zheader.tsum * ( Zheader.rfac(2) /100 );
    Zheader.tsum_hm_trends = Zheader.tsum * ( Zheader.rfac(3) /100 );
    Zheader.tsum_user_trends = Zheader.tsum * ( Zheader.rfac(4) /100 );
    if( isnan(Zheader.tsum))
        disp('WARNING: Z matrix has corrupted values, check masks for proper output');
    end
    if ~isempty( Zheader.Z_Original )
        Zheader.Z_Original = '';
    end

    % --- preserve an unambiguous copy of the mask
    here = scan_information.mask.file;
    isNII = strfind( lower(here), '.nii') > 0 ;
    if isNII
        there = [pwd filesep 'mask_used.nii'];
        if ~strcmp( here, there )
            copyfile( here, there, 'f' );
        end
    else
        there = [pwd filesep 'mask_used.img'];
        if ~strcmp( here, there )
            copyfile( here, there, 'f' );
            here = strrep( here, '.img', '.hdr' );
            there = [pwd filesep 'mask_used.hdr'];
            copyfile( here, there, 'f' );
        end
    end

end

if ( log_fid)
    fclose( log_fid);
end


dt = date;
str = sprintf( 'Subjects: %d  Runs: %d ',  Zheader.num_subjects, Zheader.num_runs );
nrm = sprintf( 'Normalize raw subject data from %s ',  scan_information.BaseDir );
nrm2 = sprintf( 'Normalized Z matrices stored at %s ',  Zheader.Z_Directory );
write_log( dt, nrm, nrm2, str );

% if scan_information.processing.subjects.process.create_ZZ == 1
%
%   Zheader.ZZ = ZZ_segmentation( Zheader.total_scans, Zheader.total_columns );
%   create_ZZ( 1 );
%
% end

scan_information.processing.subjects.apply = 0;  		% flag no longer needing to scan the subjects
scan_information.processing.subjects.normalized = date;
scan_information.processing.subjects.process.apply_regression = 0;
scan_information.processing.subjects.process.linear_regress = 0;
scan_information.processing.subjects.process.quadratic_regress = 0;
scan_information.processing.subjects.process.movement_regress = 0;
scan_information.processing.subjects.process.mean_center = 0;
scan_information.processing.subjects.process.standardize = 0;
scan_information.processing.subjects.process.create_ZZ = 0;
scan_information.processing.subjects.process.extract_clusters = 0;
scan_information.processing.subjects.process.create_Z = 0;

save_Zinfo( Zheader, scan_information );

timers.Normalize.end_time = clock;
timers.Normalize.duration = etime(timers.Normalize.end_time, timers.Normalize.start_time );
%% --- Accumulate_Z_SSQ ()
%  --- -----------------------------------
    function ts = accumulate_Z_SSQ()

        ts = 0;
        A = [];
        SSQ = struct( 'sd', 0, ...                                          % --- total Z sum diagonal
            'Rsd', zeros( 1, 5 ), ...                             % --- total Z sum diagonal by registration
            'Fsd', zeros( 1, max(1, Zheader.num_Z_arrays) ), ...   % --- total Z sum diagonal by frequency
            'Subject', struct( ...
            'sd', zeros(Zheader.num_runs, 1 ), ...
            'Fsd', zeros( Zheader.num_runs, max(1, Zheader.num_Z_arrays) ) ) );

        for SubjectNo=1:Zheader.num_subjects
            A = load_subject_Z_var_cmd(Zheader, SubjectNo, 'SSQ');

            if ~isempty(A)
                SSQ.sd =  SSQ.sd + A.sd;
                SSQ.Fsd =  SSQ.Fsd + A.Fsd;
                SSQ.Rsd =  SSQ.Rsd + A.Rsd;

                SSQ.Subject.sd =  SSQ.Subject.sd + A.Subject.sd;
                SSQ.Subject.Fsd =  SSQ.Subject.Fsd + A.Subject.Fsd;

            end % -- variable loaded

        end % each subject

        Zvars =  ['Z' filesep 'Z_vars'];
        initialize_non_existing_file( Zvars );
        save( Zvars, 'SSQ',  '-append' );

        ts = SSQ;

    end  % --- end nested function --- accumulate_Z_SSQ

end  % --- end function --- subject normalization