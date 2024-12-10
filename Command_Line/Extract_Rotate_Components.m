function Extract_Rotate_Components(base_dir, numcomps, EorR, model, rot_method)
%% EorR: 'E' for extraction, 'R' for rotation
% supported roation methods: varimax, promax, hrfmax (need
% shapes.mat),orthomax, quartimax, equimax, hrf-procrustes and procrustes

if nargin < 5,  rot_method = [];  end

if strcmp( model, 'G' )==0
    disp( 'only G model is supported.' );
    return
end

if strcmp( EorR, 'E' )==0 && strcmp( EorR, 'R' )==0
    disp( 'EorR: only (E)xtraction or (R)otation is supported.' );
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
% if exist([base_dir filesep 'Gheader.mat'], 'file') ~= 2
%     disp('Gheader.mat does not exist!');
%     return
% end
% fullpath = [base_dir filesep 'Gheader.mat'];
% eval( [ 'load( ''' fullpath ''', ''Gheader'' ); '] );

if ~isempty(Zheader.Model.path)
    load( Zheader.Model.path, 'Gheader' );
else
    disp('Gheader.mat does not exist!');
    return
end

isROI = 0; % not  G ROI
if isROI
    model = 'ROI';
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


if strcmp( EorR, 'E' )
    % number of components
    scan_information.processing.model.process.components = numcomps;
    scan_information.processing.model.process.svd = ones(1, size( numcomps, 2 ) );
    scan_information.processing.model.process.extract_g = 1;
    % scan_information.processing.model.process.subject_specific = 1; % will do subject specific too
else
    % setup roation
    scan_information.processing.model.process.rotate_g = 1;
    scan_information.processing.model.rotation=1;
    % scan_information.processing.model.process.subject_specific_rotated = 1;
    %x = Rotation_Settings( 'Setting', sett, 'Title', 'G Rotation Settings', 'Model', 'G' );
    rotations = define_rotations();

    x = size(rotations,1);
    rot_setting=[];
    for j=1:length(rot_method)
        new_setting=[];
        for i = 1:x
            if ( strcmp( char(rot_method(j)), char(rotations(i).description) ) ) 
                new_setting = rotations(i); 
                new_setting.defaults.reltol = sqrt(eps);
                if isempty(rot_setting)
                    rot_setting = new_setting;
                else
                    rot_setting = [ rot_setting; new_setting];
                end
            end
        end
        
        %fn = fs_filename( 'mat', model, new_setting.method, new_setting.defaults ); % file name
        % %fprintf( 'checking special instructions . . .\n' );
        % if ( isfield( handles.new_setting.parameters, 'special' ) )
        %     %fprintf( 'special instructions exist . . .\n' );
        %     if ( size( handles.new_setting.parameters.special, 1 ) > 0 )
        %         %fprintf( 'special instructions counted . . .\n' );
        %         process_special_instructions( handles, handles.new_setting.parameters.special );
        %     end
        % end
        
        % save_headers_cmd(Zheader,scan_information);
    end
    if isempty(rot_setting)
        disp('unknown rotation method.');
        return;
    else
        scan_information.processing.model.rotation = rot_setting;
    end

    

        
end

%% -----------------------------------------------------------
% Extract and Rotate G unrotated components
% -----------------------------------------------------------
tic;
timers.Extract_G.start_time = clock;
% num_procs = size(scan_information.processing.model.process.components, 2);

% model = 'G';
% if isChecked( handles.chk_apply_ga ),         model = 'GA';      end;
% if isChecked( handles.chk_apply_gaa ),        model = 'GAA';     end;

Aheader = [];

for comp_idx = 1:size(scan_information.processing.model.process.components, 2)

    nd = scan_information.processing.model.process.components(comp_idx);
    if ( nd > 0 )

        %          ext = ['Extract ' num2str(nd) ' components'];

        if scan_information.processing.model.process.extract_g == 1 || scan_information.processing.model.process.subject_specific == 1

            if scan_information.processing.model.process.extract_g == 1 || ...
                    scan_information.processing.model.process.subject_specific == 1
                % extract_components_of_G();
                Zheader = extract_components_of_G_cmd(Zheader, scan_information, model, isROI, log_fid,nd);
            end

            scan_information.processing.model.process.extract_g = 0;

        end  % --- extract components

        if scan_information.processing.model.process.rotate_g == 1 || ...
                scan_information.processing.model.process.subject_specific_rotated == 1

            %rotate_components_of_G();
            Zheader = rotate_components_of_G_cmd(Zheader, scan_information, model, isROI, log_fid,nd);
        end % --- rotate components

    end  % --- valid number of components to extract


end  % --- each entered component value ---

timers.Extract_G.end_time = clock;
timers.Extract_G.duration = toc;
display_timer( timers.Extract_G, 'Extract G');

scan_information.processing.model.applied.extract_g = scan_information.processing.model.process.extract_g;
scan_information.processing.model.applied.rotate_g = scan_information.processing.model.process.rotate_g;
scan_information.processing.model.process.extract_g = 0;
scan_information.processing.model.process.rotate_g = 0;
scan_information.processing.model.process.subject_specific = 0;
scan_information.processing.model.process.subject_specific_rotated = 0;
save_headers_cmd(Zheader,scan_information);
disp('Done.')

end

%% --- extract_components_of_G ()
%  --- -----------------------------------
function Zheader = extract_components_of_G_cmd(Zheader, scan_information, model, isROI, log_fid, nd)

Aheader = [];

pth_add = '';

noParms = struct( 'model', 'G');

if isROI
    model = 'ROI';

    pth_add = load( 'G_ROI' );
    G_ROI = pth_add.G_ROI;
    noParms.hindex = strrep( [ filesep 'ROI' filesep G_ROI.mask( G_ROI.Rindex).id ], ' ', '_' );
    noParms.model = 'G';

    ftext = [ 'ROI: ' G_ROI.mask( G_ROI.Rindex).id ];

else
    if strcmp( model, 'GAA' )
        ftext = 'GnotA';
    else
        ftext = model;
    end

    if ~strcmp( model, 'G' )
        % --- for some odd reason a direct load of Zheader.Contrast.path
        % --- errors on trying to add Aheader to static space even though it
        % --- is defined, but indirect loading works fine - ??????
        pth_add = load( Zheader.Contrast.path );
        Aheader = pth_add.Aheader;
        if Aheader.Aindex > 1
            noParms.hindex = strrep( [ filesep Aheader.model( Aheader.Aindex).id ], ' ', '_' );
        end
    end
end


component_directory = fs_path( 'unrotated', 'output', nd, 0, noParms );
component_directory = [pwd filesep component_directory];
image_path = fs_path( 'unrotated', 'images', nd, 0, noParms );
image_path = [pwd filesep image_path];

msg = sprintf( 'Extract %s: %d components ', ftext, nd);

nvox = 0;
if isROI
    nvox = str2num(get( handles.txt_GROI_num_voxels, 'String' ));
end

nreg = [1 0 0];  % --- non registered default to whole brain only
if scan_information.mask.isRegistered
    nreg(1) = constant_define( 'PREFERENCES', 'general.whole_brain' );
    nreg(2) = constant_define( 'PREFERENCES', 'general.gray_matter' );
    nreg(3) = constant_define( 'PREFERENCES', 'general.white_matter' );
end

for ii = 1:3

    WG = ii - 1;
    if nreg(ii)

        print_title( msg, log_fid );

        if scan_information.processing.model.process.extract_g == 1
            [abort_process,Zheader] = extract_g_components_cmd(Zheader, scan_information, nd, log_fid, model, nvox, WG );
            clear extract_g_components_cmd

            g_images_unrotated_cmd(Zheader, scan_information, nd, log_fid, model, WG );
            clear g_images_unrotated_cmd

            if ~(scan_information.isMulFreq == 1) && strcmp( model, 'G' )

                rotation_params.method = 'unrotated';
                rotation_params.defaults = struct( 'empty', 1 );
                rotation_params.fs = 'unrotated';
                rotation_params.model = 'G';

                disp( 'Writing Cluster Information' );

                if constant_define( 'PREFERENCES', 'cluster.create_masks', 1 )
                    write_cluster_masks_cmd(scan_information, [], nd, '' );
                end
                if constant_define( 'PREFERENCES', 'cluster.calculate_mean' , 0 ) || ...
                        constant_define( 'PREFERENCES', 'cluster.calculate_median' , 0 )
                    write_cluster_beta_mean_median_cmd(Zheader, scan_information,  rotation_params, Gheader, nd, WG );
                end
            end

        end

        if scan_information.processing.model.process.subject_specific == 1 && ...
                strcmp( model, 'G' )   % --- no subject rotation for GA/GFnotA presently

            extract_g_subject_components_cmd( Zheader, scan_information ,  nd, log_fid, WG );
            clear extract_g_subject_components_cmd
        end
    end

    %    end

    %       if constant_define( 'PREFERENCES', 'general.calculate_altPR' )
    %         if ( isa( handles.progressBar, 'cpca_progress' ) )
    %           handles.progressBar.setMessage( 'Calculating Alternate PR . . .' );
    %         end
    % %        calculate_alternate_PR( nd, struct( 'model', 'G' ), 1 );

end


% if size(process_information.sudo.user, 2) > 0 && process_information.sudo.confirmed == 1
%     cmd = ['!chown -R ' process_information.sudo.user '.' process_information.sudo.group ' *' ];
%     eval( cmd );
% end


end  % --- nested function - G component Extraction

%% --- rotate_components_of_G ()
function Zheader = rotate_components_of_G_cmd(Zheader, scan_information, model, isROI, log_fid,nd)

Aheader = [];
pth_add = '';

if strcmp( model, 'GAA' )
    ftext = 'GnotA';
else
    ftext = model;
end

msg = sprintf( 'Rotate: %s %d components', ftext, nd );

rotation_params.Aindex = 0;
noParms = struct( 'model', 'G', 'Aindex', 0 );
if ~strcmp( model, 'G' )
    % --- for some odd reason a direct load of Zheader.Contrast.path
    % --- errors on trying to add Aheader to static space even though it
    % --- is defined, but indirect loading works fine - ??????
    pth_add = load( Zheader.Contrast.path );
    Aheader = pth_add.Aheader;
    rotation_params.Aindex = Aheader.Aindex;
    noParms.Aindex = Aheader.Aindex;
    if Aheader.Aindex > 1
        noParms.hindex = strrep( [ filesep Aheader.model( Aheader.Aindex).id ], ' ', '_' );
    end
end

component_directory = fs_path( 'unrotated', 'output', nd, 0, noParms );
component_directory = [pwd filesep component_directory];

% -----------------------------------------------------------
% is there a processed .mat file for the non rotated solution
% -----------------------------------------------------------
in_file = fs_filename( 'mat', model, 'unrotated', noParms );
in_file = [component_directory in_file];
if exist( in_file, 'file' )

    % ----------------------------------
    % --- multiple rotations ---
    % ----------------------------------
    for idx = 1:size(scan_information.processing.model.rotation, 1)

        % if isa( handles.progressBar, 'cpca_progress' )
        %     handles.progressBar.setProcess( [ scan_information.processing.model.rotation(idx).method ' Rotation ' num2str( nd ) ' components'] );
        % end

        this_rotation = scan_information.processing.model.rotation(idx);
        this_rotation.model = 'G';
        this_rotation.fs = 'rotated';
        this_rotation.htype = model;
        this_rotation.mode = '';
        if isfield( noParms, 'hindex' )
            this_rotation.hindex = noParms.hindex ;
        end
        this_rotation.Aindex = rotation_params.Aindex;


        str = [ '--- ' scan_information.processing.model.rotation(idx).method ];
        if ( scan_information.processing.model.rotation(idx).defaults.oblique )
            str = [ str ' oblique' ];  else str = [ str ' orthogonal' ];
        end
        str = [ str ' iter: ' num2str(scan_information.processing.model.rotation(idx).defaults.iterations) ];
        nm = sprintf( '%.2f', scan_information.processing.model.rotation(idx).defaults.power );
        str = [ str ' power: ' nm ];
        nm = sprintf( '%.2f', scan_information.processing.model.rotation(idx).defaults.gamma );
        str = [ str ' gamma: ' nm ' ---' ];

        fnm = fs_filename( 'mat', model, this_rotation.method, this_rotation.defaults );
        Sub = sprintf( '%s\n--- %s ---', str, fnm );
        print_title( Sub, log_fid );


        nreg = [1 0 0];  % --- non registered default to whole brain only
        if scan_information.mask.isRegistered
            nreg(1) = constant_define( 'PREFERENCES', 'general.whole_brain' );
            nreg(2) = constant_define( 'PREFERENCES', 'general.gray_matter' );
            nreg(3) = constant_define( 'PREFERENCES', 'general.white_matter' );
        end

        for ii = 1:3

            WG = ii - 1;
            if nreg(ii)
                print_title( msg, log_fid );
                disp( msg );

                if scan_information.processing.model.process.rotate_g == 1
                    [ab, Zheader] = rotate_components_cmd(Zheader, scan_information, this_rotation, nd, log_fid, model, WG );
                    clear rotate_components_cmd

                    if ab == 0
                        return;
                    end

                    g_images_rotated_cmd(Zheader, scan_information, this_rotation, nd, log_fid, model, WG );
                    clear g_images_rotated_cmd

                end


                % if size(process_information.sudo.user, 2) > 0 && process_information.sudo.confirmed == 1
                %     cmd = ['!chown -R ' process_information.sudo.user '.' process_information.sudo.group ' *' ];
                %     eval( cmd );
                % end

                if constant_define( 'PREFERENCES', 'general.calculate_altPR' )
                    disp( 'Calculating Alternate PR . . .');
                    calculate_alternate_PR_cmd(Zheader,scan_information, nd, this_rotation, 1 );
                end

                if ~(scan_information.isMulFreq == 1) && strcmp( model, 'G' )

                    if constant_define( 'PREFERENCES', 'cluster.create_masks' , 1 )
                        write_cluster_masks_cmd(scan_information, this_rotation, nd, this_rotation.htype );
                    end
                    if constant_define( 'PREFERENCES', 'cluster.calculate_mean' , 0 ) || ...
                            constant_define( 'PREFERENCES', 'cluster.calculate_median' , 0 )
                        write_cluster_beta_mean_median_cmd(Zheader, scan_information,  this_rotation, Gheader, nd);
                    end

                end

                % --- rotating for subject MUST be done AFTER rotated image creation
                if scan_information.processing.model.process.subject_specific_rotated == 1 && ...
                        strcmp( model, 'G' )   % --- no subject rotation for GA/GFnotA presently
                    if ( scan_information.processing.model.process.subject_specific_rotated || this_rotation.defaults.subject_stats )
                        rotate_subject_components_cmd(Zheader, scan_information, this_rotation, nd, log_fid,  WG);
                        clear rotate_subject_components_cmd
                    end
                end


            end
        end

    end  % --- each rotation index ---

end  % --- non rotated input file exists ---

end  % ---- nested function - rotate_G_components ()

