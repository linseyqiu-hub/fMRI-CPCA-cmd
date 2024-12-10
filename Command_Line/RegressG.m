function RegressG(base_dir, model)

% base_dir = '/Users/wsu/example_data_Multiple_Groups_Subjects_Runs';
if strcmp( model, 'G' )==0
    disp( 'only G model is supported.' );
    return
end

% check the exiting of Z matrix
if exist([base_dir filesep 'ZInfo.mat'], 'file') ~= 2
    disp('ZInfo.mat does not exist!');
    return
end
fullpath = [base_dir filesep 'ZInfo.mat'];
eval( [ 'load( ''' fullpath ''', ''Zheader'' ,''scan_information''); '] );

% check the exiting of G matrix
if ~isempty(Zheader.Model.path)
    load( Zheader.Model.path,'Gheader' );
else
    disp('Gheader.mat does not exist!');
    return
end

log_results=1;
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


% model = 'G';
isROI = 0; % not  G ROI
if isROI
    model = 'ROI';
end
% if isChecked( handles.chk_apply_ga )
%   model = 'GA';
% end;
% if isChecked( handles.chk_apply_gaa )
%   model = 'GAA';
% end;


Gpath = '';
iters = 0;

tic;
timers.ApplyG.start_time = clock;


if strcmp( model, 'GAA' )
    disp( 'Regressing GnotA * Z . . .' );
else
    fprintf('Regressing %s  * Z . . .\n', model );
end
large = constant_define( 'PREFERENCES', 'general.large_variable_creation' );

% iters = iteration_rule( 'Iterations', 'G Regression', {'primary'} );
% handles.progressBar.setIterations( iters.primary, handles.progressBar.PRIMARY );


if isROI
    nvox = str2num(get( handles.txt_GROI_num_voxels, 'String' ));
    SoS =  apply_ROI_to_Z( handles.funcs, nvox, model, log_fid, handles.progressBar );
    clear apply_ROI_to_Z

    G_ROI.mask( G_ROI.Rindex).tsum_ZTrim = SoS;

else
    SoS =  apply_partitioned_to_Z_cmd( Gheader,Zheader, scan_information, log_fid, large);
    clear apply_partitioned_to_Z_cmd
end


if ( SoS == 0 )
    return;
end

% if size(process_information.sudo.user, 2) > 0 && process_information.sudo.confirmed == 1
%     cmd = ['!chown -R ' process_information.sudo.user '.' process_information.sudo.group ' *' ];
%     eval( cmd );
% end

timers.ApplyG.end_time = clock;
timers.ApplyG.duration = toc;
display_timer( timers.ApplyG, 'Apply G');


% Gheader GZheader altered and saved, but not global - reload for logging
load( Zheader.Model.path, 'Gheader' );

if isROI
    save G_ROI G_ROI

    roi_id = strrep( G_ROI.mask( G_ROI.Rindex).id, ' ', '_' );
    Gpath = [ 'GZsegs' filesep 'ROI' filesep roi_id filesep ];			% eg: GZ_segs, GAZ_segs

    txt = G_ROI.mask( G_ROI.Rindex).id;

else
    if ~strcmp( model, 'G' )
        load( Zheader.Contrast.path );
        eval( [ 'Gpath = Aheader.model( Aheader.Aindex).path_to_' model ';' ] );
        txt = 'GAC';
    else
        eval( [ 'Gpath = Gheader.' model 'Zheader.path_to_segs;' ] );
        txt = 'GC';
    end
end

if ~strcmp( model, 'GAA' )
    varf = [ Gpath 'GC_vars.mat' ];
else
    varf = [ Gpath 'BB_vars.mat' ];
    txt = 'GnotAC';
end

if ~exist( varf, 'file' )
    fprintf( 'Missing GC information \n Unable to locate file containg GC information  file: %s', varf );
    %        initialize_mat_file( varf );
    return;
end

if isROI
    SSQ = GC_sum_of_squares( Gpath, 'ROI' );
    G_ROI.mask( G_ROI.Rindex).sum_diagonal = SSQ.sd;
    save G_ROI G_ROI

    GC_SD_Report_cmd( Gpath, Zheader,scan_information, 'ROI' );

else
    SSQ = GC_sum_of_squares_cmd( Gheader,Zheader, model );

    if ~strcmp( model, 'G' )
        idx = 1 + strcmp( model, 'GAA' );
        Aheader.model( Aheader.Aindex).sd(idx) = SSQ.sd;
    else
        Gheader.GZheader.rsum = SSQ.Rsd;
        save( Zheader.Model.path, 'Gheader', '-append' );
    end

    GC_SD_Report_cmd( Gheader, Zheader,scan_information, model, txt );

    if ( Gheader.model_type == constant_define( 'FIR_MODEL') & ~strcmp( model, 'GA' ) & ~strcmp( model, 'GAA' ) )
        mean_beta_images_cmd(Gheader, Zheader,scan_information);
    end

end


dt = date;

%      Zheader.rsum = SSQ.Rsd;
Zheader.cpca_version = constant_define( 'REVISION' );   % ---  update created revision number to bypass UR/FR alterations later
scan_information.processing.model.process.apply_g = 0;
scan_information.processing.model.applied.apply_g = 1;
scan_information.processing.model.applied.resume_g.resume = 0;
save_headers_cmd(Zheader,scan_information);

fclose(log_fid);

%% plot of the singular values
disp('plotting singular values')
if ( ~isempty( Zheader.Model.path ) && Zheader.Model.hdr_exists == 1 )
    load( Zheader.Model.path, 'Gheader' );
    [gzpth g] = split_path( Gheader.GZheader.path_to_segs, filesep );
else
    gzpth = ['./GZsegs' filesep ] ;
end

% model = 'G';
% if isChecked( handles.chk_apply_ga ),       model = 'GA';    end;
% if isChecked( handles.chk_apply_gaa),       model = 'GAA';   end;

WG = isRegistered(scan_information.mask) * constant_define( 'PREFERENCES', 'general.gray_white_split' );
eigvar = ['C' constant_define( 'REGISTRATION_TAG', WG ) '_Eigenvalues'];

C_Eigenvalues = load_GC_var_cmd( Gheader, Zheader, eigvar, model );
%   end;

if ~isempty( C_Eigenvalues )

    ext = min(40, size(C_Eigenvalues,1) );
    Ce = C_Eigenvalues(1:ext,:)./(Zheader.total_scans - 1);
    h = figure('Visible','off');
    plot( Ce, '-O', 'MarkerSize', 5 );

    set( h, 'NumberTitle' , 'off' );
    set( h, 'Name' , ['Scree Plot ' model constant_define( 'REGISTRATION_FULL', WG ) ] );
    saveas(h, 'Singular Values.png');
    disp('please check file Singular Values.png.')
    close(h)
end

disp('Done.')


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
            A = load_subject_Z_var_cmd( SubjectNo, 'SSQ');

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
        save( Zvars, 'SSQ', '-v7.3', '-append' );

        ts = SSQ;

    end  % --- end nested function --- accumulate_Z_SSQ

end
