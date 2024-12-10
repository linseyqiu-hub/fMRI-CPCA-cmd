function mask_verification_cmd(Zheader, scan_information)
% doRank = 0 always
[DataStruct.Zheader, DataStruct.scan_information] = adjust_headers( Zheader, scan_information, Zheader.Z_Directory );
DataStruct.dir_char = '/';
DataStruct.summary_type = 1;		% 1 = all, 2 = errors, 3 = good
DataStruct.reparse = 0;			% flag file list requiring reparsing

DataStruct.isNII = strfind( lower(DataStruct.scan_information.mask.file), '.nii') > 0 | DataStruct.scan_information.mask.niiSingle ;
if DataStruct.isNII
    DataStruct.new_mask_name = 'new_mask.nii'; % file name to use when creating new mask
else
    DataStruct.new_mask_name = 'new_mask.img'; % file name to use when creating new mask
end

DataStruct.txt_mask_name.String = DataStruct.new_mask_name;
DataStruct.chk_NII_single.Value = DataStruct.scan_information.mask.niiSingle;

if ( ispc )	DataStruct.dir_char = '\'; 	end

DataStruct.lst_subjects.String = DataStruct.scan_information.SubjectID;
DataStruct.lst_subjects.Value = 1;

x = exist( './mask_verification.mat', 'file' );
if ( x == 2 )
    load mask_verification;

    update_scan_results(subject_verification );
    show_total(total_verification );

    voxel_errors = total_verification.bad > 0 | total_verification.columns_with_zeros > 0 | total_verification.columns_with_inf > 0 ;
    % disp(voxel_errors)
    % if ( voxel_errors )
    %   set( DataStruct.btn_new_mask, 'Visible', 'on' );
    %   set( DataStruct.txt_mask_name, 'Visible', 'on' );
    %   if DataStruct.isNII
    %     set( DataStruct.chk_NII_single, 'Visible', 'on' );
    %   end;
    % end;
    %
    % if ( ~isempty( DataStruct.scan_information.FileList ) )  Enabled = 'on'; else; Enabled = 'off'; end

end

DataStruct.chk_verify_all_subjects.Value = 1;
idx = 1:size(DataStruct.scan_information.SubjectID, 2);
DataStruct.lst_subjects.Value = idx;

% if ismac()
%   p = get( DataStruct.txt_current, 'Position' );
%   p(4) = p(4)*1.1;
%   set( DataStruct.txt_current, 'Position', p );
%
%   p = get( DataStruct.txt_total, 'Position' );
%   p(4) = p(4)*1.1;
%   set( DataStruct.txt_total, 'Position', p );
% end

doRank = 0; %DataStruct.chk_Rank.Value');

lst = DataStruct.lst_subjects.String;
subject_vector = DataStruct.lst_subjects.Value;
DataStruct.lst_results.String = [];

txt = [];
v = struct ( 'SubjectID', '', 'Freq', '', 'RunNo', 0, 'Scans', 0 , 'good', 0, 'bad', 0, 'count', 0, ...
    'scans_with_zeros', 0, 'scans_with_nanorinf', 0, ...
    'columns_with_zeros', 0, 'columns_with_nan', 0, 'columns_with_inf', 0, ...
    'files', struct( 'name', [] ) , 'columns_of_zeros', [], 'columns_of_inf', [], 'isSingular', -1, 'rcond', 0, 'rank', 0 );

subject_verification = [];
total_verification = v;

for Subject = 1:size(subject_vector, 2 )

    SubjectNo = subject_vector(Subject);
    SubjectID = char(lst(SubjectNo));
    DataStruct.lst_subjects.Value = SubjectNo;

    for FrequencyNo = 1:DataStruct.Zheader.num_Z_arrays

        ftag = frequency_tag_cmd(FrequencyNo,scan_information);
        ftag = strrep( ftag, '_', '' );

        for RunNo = 1:DataStruct.Zheader.num_runs

            if iscellstr( DataStruct.scan_information.SubjDir( Subject, RunNo ) )

                verification = v;
                verification.SubjectID = SubjectID;
                verification.RunNo = RunNo;
                verification.Freq = ftag;

                time_series = DataStruct.Zheader.timeseries.subject(SubjectNo).run(RunNo,1);

                %------------------------------------------------
                % full path of subject scan files for directory reading
                %------------------------------------------------
                subject_dir = subject_scan_directory_cmd( SubjectNo, RunNo, FrequencyNo, scan_information);
                dirspec = [ subject_dir filesep DataStruct.scan_information.ListSpec ];

                % --------------------------------------------------------
                % read directory and process individual files
                % --------------------------------------------------------
                D=dir(dirspec);
                n_files=size(D,1);
                verification.Scans = n_files;
                total_verification.Scans = total_verification.Scans + n_files;

                Z = zeros( n_files, Zheader.total_columns );

                for scan_no = 1:n_files

                    %------------------------------------------------
                    % full path of subject individual scan file
                    %------------------------------------------------
                    filespec = [ subject_dir filesep D(scan_no).name ];

                    pathspec= [ subject_dir filesep ];

                    %------------------------------------------------
                    % load in scan image and place in holding matrix
                    %------------------------------------------------
                    img = cpca_read_vol( filespec );

                    if isfield( img.header, 'error' )
                        verification.bad = verification.bad + 1;
                        total_verification.bad = total_verification.bad + 1;

                        % --- place in secondary display
                        fn = strrep( img.header.error, pathspec, '' );
                        name = strrep( fn, 'file corrupted ', '' );
                        verification.files.name = [verification.files.name; {name} ];

                    else
                        verification.good = verification.good + 1;
                        total_verification.good = total_verification.good + 1;

                        Z(scan_no,:) = img.image( scan_information.mask.ind(:) )';

                        x = find( Z(scan_no,:) == 0 );
                        if ~isempty( x )
                            verification.scans_with_zeros = verification.scans_with_zeros + 1;
                            total_verification.scans_with_zeros = total_verification.scans_with_zeros + 1;
                        end

                        x = sum( Z(scan_no,:) );
                        if isnan(x) | isinf(x)
                            verification.scans_with_nanorinf = verification.scans_with_nanorinf + 1;
                            total_verification.scans_with_nanorinf = total_verification.scans_with_nanorinf + 1;
                        end


                    end

                    summary = sprintf( '%s %s run%d  [scans:  %d/%d  zero:%d  inf/nan:%d] [ columns: zero:%d inf:%d nan:%d]', SubjectID, ftag, RunNo, ...
                        verification.good, time_series, ...
                        verification.scans_with_zeros,  verification.scans_with_nanorinf, ...
                        verification.columns_with_zeros, verification.columns_with_inf, verification.columns_with_nan );
                    disp(summary)
                    %set( DataStruct.txt_current, 'String', summary );


                    voxel_errors = verification.bad > 0 | verification.scans_with_zeros > 0 | verification.scans_with_nanorinf > 0 ;
                    % if ( voxel_errors )
                    %   set( DataStruct.btn_new_mask, 'Visible', 'on' );
                    %   set( DataStruct.txt_mask_name, 'Visible', 'on' );
                    %   if DataStruct.isNII
                    %     set( DataStruct.chk_NII_single, 'Visible', 'on' );
                    %   end
                    %   drawnow();
                    % end

                end  % --- each scan image ---

                if verification.bad == 0
                    sd = stddev(Z);
                    verification.rcond = rcond( Z * Z' );
                    verification.isSingular = ~verification.rcond > (eps * 1.1 );

                    if doRank
                        s = svd(Z, 'econ');
                        tol = max(size(Z)) * eps(max(s));
                        verification.rank = sum(s > tol);
                    end

                    verification.columns_of_zeros = find( sd == 0 );
                    if ~isempty(verification.columns_of_zeros)
                        verification.columns_with_zeros = size(verification.columns_of_zeros,2);
                        total_verification.columns_of_zeros = unique([verification.columns_of_zeros total_verification.columns_of_zeros]);
                        total_verification.columns_with_zeros = size(total_verification.columns_of_zeros,2);
                    end

                    verification.columns_of_inf = find( sd == inf );
                    if ~isempty(verification.columns_of_inf)
                        verification.columns_with_inf = size(verification.columns_of_inf,2);
                        verification.columns_of_inf = unique([verification.columns_of_inf total_verification.columns_of_inf]);
                        total_verification.columns_with_inf = size(total_verification.columns_of_inf,2);
                    end

                    x = isnan(sum(sd));
                    if (x)
                        verification.columns_with_nan = 1;
                        total_verification.columns_with_nan = 1;
                    end

                end
                subject_verification = [subject_verification; verification ];
                update_scan_results( subject_verification );
                DataStruct.lst_results.Value = size(subject_verification,1);

                show_total(total_verification );

            end  % --- Subject contains run ---

        end  % --- each run ---

    end  % --- each frequency range

end  % --- each selected subject ---

%  set( DataStruct.lst_subjects, 'Value', 1 );
show_total( total_verification );

DataStruct.txt_current.String = '' ;
DataStruct.lst_results.Value = 1 ;

save mask_verification subject_verification total_verification;

singular_values = [ {''} {''} {' [singular]'} ];

text_file = 'mask_verification.txt';
fid = fopen( text_file, 'w' );
if ( fid )

    for ii = 1:size(subject_verification, 1 )

        if ~isfield( subject_verification(ii), 'isSingular' ) % --- older version did no singularity check
            subject_verification(ii).isSingular = -1;
        end

        fmt = '%s %s run%d  [scans:  %d/%d  zero:%d  inf/nan:%d] [ columns: zero:%d inf:%d nan:%d]';
        if doRank
            fmt = [fmt ' rank: ' num2str(subject_verification(ii).rank) ];
        end
        fmt = [fmt ' rcond: %e %s'];

        fprintf( fid, [fmt '\n'], ...
            subject_verification(ii).SubjectID, ...
            subject_verification(ii).Freq, ...
            subject_verification(ii).RunNo, ...
            subject_verification(ii).good, ...
            subject_verification(ii).Scans, ...
            subject_verification(ii).scans_with_zeros, ...
            subject_verification(ii).scans_with_nanorinf, ...
            subject_verification(ii).columns_with_zeros, ...
            subject_verification(ii).columns_with_inf, ...
            subject_verification(ii).columns_with_nan, ...
            subject_verification(ii).rcond, ...
            char(singular_values( subject_verification(ii).isSingular + 2) ) ); % , ...

    end

    fprintf( fid, '\nTotal: [scans:  %d/%d  zero:%d  inf/nan:%d] [ columns: zero:%d inf:%d nan:%d] eps: %e\n', ...
        total_verification.good, total_verification.Scans, ...
        total_verification.scans_with_zeros,  total_verification.scans_with_nanorinf, ...
        total_verification.columns_with_zeros, total_verification.columns_with_inf, ...
        total_verification.columns_with_nan, eps   );

    fclose( fid );

end


    function show_total(total_verification )


        summary = sprintf( 'Total: [scans:  %d/%d  zero:%d  inf/nan:%d] [ columns: zero:%d inf:%d nan:%d]  eps: %e', ...
            total_verification.good, total_verification.Scans, ...
            total_verification.scans_with_zeros,  total_verification.scans_with_nanorinf, ...
            total_verification.columns_with_zeros, total_verification.columns_with_inf, total_verification.columns_with_nan, eps   );

        DataStruct.txt_total.String = summary;
    end


    function update_scan_results(subject_verification )

        singular_values = [ {''} {''} {'[singular]'} ];
        doRank =0; % get( DataStruct.chk_Rank, 'Value');

        txt = [];
        for iii = 1:size(subject_verification, 1 )

            if ~isfield( subject_verification(iii), 'isSingular' ) % --- older version did no singularity check
                subject_verification(iii).isSingular = -1;
            end

            fmt = '%s %s run%d  [scans:  %d/%d  zero:%d  inf/nan:%d] [ columns: zero:%d inf:%d nan:%d]';
            if doRank
                fmt = [fmt ' rank: ' num2str(subject_verification(iii).rank) ];
            end
            fmt = [fmt ' rcond: %e %s'];

            summary = sprintf( fmt, ...
                subject_verification(iii).SubjectID, ...
                subject_verification(iii).Freq, ...
                subject_verification(iii).RunNo, ...
                subject_verification(iii).good, ...
                subject_verification(iii).Scans, ...
                subject_verification(iii).scans_with_zeros, ...
                subject_verification(iii).scans_with_nanorinf, ...
                subject_verification(iii).columns_with_zeros, ...
                subject_verification(iii).columns_with_inf, ...
                subject_verification(iii).columns_with_nan, ...
                subject_verification(iii).rcond, ...
                char(singular_values( subject_verification(iii).isSingular + 2) ) ...
                );

            switch (DataStruct.summary_type)
                case 2
                    if ( subject_verification(iii).bad > 0 )
                        txt = [txt; {summary}];
                    end

                case 3
                    if ( subject_verification(iii).bad == 0 )
                        txt = [txt; {summary}];
                    end

                otherwise
                    txt = [txt; {summary}];
            end

        end
        DataStruct.lst_results.String = txt;
        DataStruct.lst_results.Value = 1;

    end

end


