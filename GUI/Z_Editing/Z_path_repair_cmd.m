function Z_path_repair_cmd(base_dir)


cd(base_dir)

if exist([base_dir filesep 'ZInfo.mat'], 'file') ~= 2
    disp('Zinfo.mat file does not exist.');
    return
end

fullpath = [base_dir filesep 'ZInfo.mat'];
eval( [ 'load( ''' fullpath ''', ''Zheader'' ,''scan_information''); '] );

current_path=[pwd filesep];

slash = filesep;
[Zpath, Zfile] = split_path( fullpath, slash );

% --- check the lowest allowable revision numbers

this_revision = revision_value( Zheader.cpca_version );
lowest_revision = revision_value( constant_define( 'LOWEST_REVISION' ) );

vsn = cpca_revision_number( Zheader.cpca_version );
reapply_revision = revision_value( constant_define( 'REAPPLY_REVISION' ) );

if this_revision < lowest_revision | this_revision <= reapply_revision
    if this_revision < lowest_revision
        str = ['This data set was created with a version of CPCA that is no longer supportable. [' vsn ']' ];
        title = 'Unsupported Legacy Version';
    else
        str = ['This data set was created with a version of CPCA that requires you to reapply the G Model and extract/rotate the components. [' vsn ']   You need not re-normalize or recreate the Z data.'];
        title = 'G Re-application Required';
    end

    %show_message( title, str );
    disp(title)
    disp(str)
    return;
end
Hheader=[];
Gheader=[];
disp('Updateing Z Data Matrix ...');
hdr_version = Zheader.header_version;

% adjust the header data to the current model if required
% --------------------------------------------------------
[Zheader, scan_information] = adjust_headers( Zheader, scan_information, Zpath );
% process_information = adjust_process_info();
if Zheader.Model.hdr_exists && isempty( Zheader.conditions.sp )
    load( Zheader.Model.path, 'Gheader');
    Zheader.conditions.sp = condition_start_columns_cmd(Zheader,Gheader.conditions, Gheader.bins );
end

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

save_Zinfo( Zheader, scan_information )

% verify data is actually at absolute path indicated in header
% if data was backed up to another location we need to adjust it.
% --------------------------------------------------------

% this indicates subject normalization process was run (even if not completed )
% --------------------------------------------------------
if scan_information.processing.subjects.process.last_subject > 0

    d = dir( [ Z_Directory() 'Z' filesep 'Z1*.mat'] );

    if ( size(d,1) == 0 )  % --- okay, the absolute location is farked
        % --- absolute paths to adjust
        % --- Zheader.Z_Directory: '/home/woodward/Desktop/tgt_v1_test/cpca/'
        % --- header.Model.path: '/home/woodward/Desktop/tgt_v1_test/cpca/G.mat'
        % --- Gheader.path_to_segs: '/home/woodward/Desktop/tgt_v1_test/cpca/Gsegs/'
        % --- Gheader.applied_to: '/home/woodward/Desktop/tgt_v1_test/cpca/'
        % --- Gheader.GZheader.path_to_segs: '/home/woodward/Desktop/tgt_v1_test/cpca/GZsegs/'
        disp("Reparing Z path...");

        [Zheader, scan_information] = adjust_headers( Zheader, scan_information, Zheader.Z_Directory );

        if ispc
            dir_char = '\';
            this_from = '/';
            this_to = '\';
        else
            dir_char = '/';
            this_to = '/';
            this_from = '\';
        end

        Zheader.Z_File.directory = strrep( Zheader.Z_File.directory, this_from, this_to);
        Zheader.Z_Directory      = strrep( Zheader.Z_Directory, this_from, this_to);
        Zheader.Z_Original       = strrep( Zheader.Z_Original, this_from, this_to);
        Zheader.Model.path       = strrep( Zheader.Model.path, this_from, this_to);
        Zheader.P.path           = strrep( Zheader.P.path, this_from, this_to);
        Zheader.D.path           = strrep( Zheader.D.path, this_from, this_to);
        Zheader.Contrast.path    = strrep( Zheader.Contrast.path, this_from, this_to);
        Zheader.Limits.path      = strrep( Zheader.Limits.path, this_from, this_to);


        zpath = current_path;
        badpath = Zheader.Z_Directory;
        Zheader.Z_Directory = zpath;

        % Gheader = structure_define( 'GHEADER' );
        % Gheader.GZheader = structure_define( 'GZHEADER' );
        % Hheader = structure_define( 'HHEADER' );

        mpath = strrep( scan_information.mask.file, badpath, zpath );
        scan_information.mask.file = mpath;

        gpath = strrep( Zheader.Model.path, badpath, zpath );

        xx = exist( gpath, 'file' );
        if ( xx == 2 )
            [Gpath, Gfile] = split_path( gpath, dir_char );
            xx = who_stats( Gpath, Gfile, 'Gheader' );
            if ( xx.mat_exists )
                eval( [ 'load( ''' gpath ''', ''Gheader'');' ] );
                Zheader.Model.path = gpath;
                Gheader.applied_to = zpath;
                if isfield(Gheader,'path_to_segs')
                    Gheader.path_to_segs = [Gpath 'Gsegs' filesep];
                    gspath = strrep( Gheader.path_to_segs, badpath, zpath );
                    Gheader.path_to_segs = gspath;
                end
                if isfield(Gheader.GZheader,'path_to_segs')
                    Gheader.GZheader.path_to_segs = [Gpath 'GZsegs' filesep];
                    gzpath = strrep( Gheader.GZheader.path_to_segs, badpath, zpath );
                    Gheader.GZheader.path_to_segs = gzpath;
                end
            end
        end


        if ~isempty( Zheader.Limits.path )

            hpath = strrep( Zheader.Limits.path, badpath, zpath );
            Zheader.Limits.path = hpath;
            xx = exist( hpath, 'file' );
            if ( xx == 2 )
                [Hpath, Hfile] = split_path( hpath, dir_char );
                xx = who_stats( Hpath, Hfile, 'Hheader' );
                if ( xx.mat_exists )
                    eval( [ 'load( ''' hpath ''', ''Hheader'');' ] );
                    % handles.Hheader = Hheader;
                    for ii = 1:size( Hheader.model, 1 )
                        Hheader.model(ii).path = strrep( Hheader.model(ii).path, badpath, zpath );
                    end

                    hspath = strrep( Hheader.model(1).path_to_segs, badpath, zpath );
                    xx = exist( hspath, 'dir' );
                    if ( xx == 7 )
                        Hheader.path_to_segs = hspath;
                    end

                end
            end
        end
    end

end




save ZInfo Zheader scan_information -append

if ~isempty(Gheader )
        eval( [ 'save( ''' Zheader.Model.path ''', ''Gheader'', ''-append'');' ] );
end

if ~isempty( Hheader )
        eval( [ 'save( ''' Zheader.Limits.path ''', ''Hheader'', ''-append'');' ] );
end





% if there is a defined G, is it processed with a header?
% --------------------------------------------------------
if ( Zheader.Model.file_exists )
    [Gpath, Gfile] = split_path( Zheader.Model.path, filesep );

    xx = who_stats( Gpath, Gfile, 'Gheader' );
    if ( ~xx.mat_exists )
        Gheader = Full_G_Parameters();
        if ( ~isempty( Gheader ) )
            eval ( ['save( ''' Zheader.Model.path ''', ''Gheader'', ''-append'')' ] );
            scan_information.processing.model.parameters.condition_name = Gheader.condition_name;
            scan_information.processing.model.parameters.model_type = Gheader.model_type;
            scan_information.processing.model.parameters.conditions = Gheader.conditions;
            scan_information.processing.model.parameters.bins = Gheader.bins;
            scan_information.processing.model.parameters.TR = Gheader.TR ;
            scan_information.processing.model.parameters.inScans = Gheader.inScans;
            save_Zinfo( Zheader, scan_information )
        end
    else
        % there is a defined G, but is it a current design?
        % --------------------------------------------------------
        load( Zheader.Model.path, 'Gheader');
        Gheader = adjust_gheader_cmd( Gheader, Zheader.num_subjects);
        if ( ~isfield( Gheader, 'prefix' ) )

            disp('Your present G model appears to have been created in an older format of the CPCA GUI.  Please reselect or recreate it to ensure the proper application of this G to your data.' );
        end

    end
end

% if the G has been applied, is it processed with new file structure? ( v 3.3.0 - Mar 01, 2010 )
% --------------------------------------------------------
if ( str2num(hdr_version) < 2.0 )  % we need to process any GZSegs/GZ_S{n} files

    gzpth = get_GZsegs_path();
    x = exist( gzpth, 'dir' );
    if ( x == 7 )  % the directory exists - loacte the last subject file
        last_file = [ 'GZ_S' num2str(Zheader.num_subjects) '.mat' ];
        x = who_stats( gzpth, last_file, 'Bn' );
        if ( x.mat_exists )   % we have an older file that needs to be processed
            disp('warning!')
            disp( 'The existing GZ data set was processed under an older CPCA version, please recreate the G matrix.' );
            return;
            % myAnswer = questdlg(str,'WARNING!','Yes');
            % if strcmp(myAnswer, 'Yes')
            %     update_GZSegs();   % not existing at all!!!!!!!!
            % else
            %     Zheader.header_version = hdr_version;
            %     save_Zinfo( Zheader, scan_information )
            % end

        end
    end

end

% update the subject ID's if necessary
% --------------------------------------------------------
if ( isempty(scan_information.SubjectID ) && isempty(Zheader.Z_File.name) )
    for S = 1:Zheader.num_subjects
        if ( size(scan_information.SubjDir,1) >= S && ~isempty(scan_information.SubjDir) )
            x = regexp( char(scan_information.SubjDir(S,1)), filesep, 'split' );
            scan_information.SubjectID = [scan_information.SubjectID {char(x(1))} ];
        else
            scan_information.SubjectID = [scan_information.SubjectID {'     '} ];
        end
    end
    save_Zinfo( Zheader, scan_information )
end