function Flip_Component(base_dir, comp_to_flip)
%% flip the sign of loading for choosen component
% comp_to_flip, which component to be flipped
% will flip all rotated and unrotated components.


if ~isnumeric(comp_to_flip) || comp_to_flip < 1
   comp_to_flip =[];
end

if isempty(comp_to_flip)
    disp('wrong component!')
    return
end
% check the exiting of Z matrix
if exist([base_dir filesep 'ZInfo.mat'], 'file') ~= 2
    disp('ZInfo.mat does not exist!');
    return
end
fullpath = [base_dir filesep 'ZInfo.mat'];
eval( [ 'load( ''' fullpath ''', ''Zheader'' ,''scan_information''); '] );

cd(base_dir);

criteria.prefix = 'G'; 		% computed_n file name prefix
criteria.module = '';		% used for GMH prefix for modules GMH, GC or BH
criteria.Hmodel = '';		% used to determine which ( ZH, EH or GMH )
criteria.mask_registry = 0; % Mask registry setting for this analysis set
criteria.aPR = [];          % PR - alternate
criteria.VR = 0;            % plot VR components
criteria.GI = 0;            % group index value
criteria.Hheader = [];		% load in the Hheader if required


if isempty( criteria.Hmodel )
    criteria.model_display = criteria.prefix;
    if isempty( criteria.module )
        criteria.module = criteria.prefix;
    end
else
    if isempty( criteria.module )
        criteria.model_display = criteria.Hmodel;
        criteria.module = criteria.Hmodel;
    else
        criteria.model_display = criteria.module;
    end
end

CompTypeList = '';

% ---------------------------
% add the files from valid subdirectories (n_components)
% ---------------------------
rs = define_rotations();
valid_dirs = {'unrotated'};
for ii = 1:size(rs)
    valid_dirs = [valid_dirs {rs(ii).method}];
end
[comp_list num_comps] = directory_list( [base_dir filesep criteria.prefix filesep] );
if num_comps > 0

    for compcount = 1:size(comp_list, 1 )
        comp_dir = [pwd filesep criteria.prefix filesep char( comp_list(compcount) ) filesep];
        if ~isempty( criteria.Hmodel )
            comp_dir = [comp_dir criteria.Hmodel filesep];
        end

        [sub_list sub_count] = directory_list( comp_dir );
        if sub_count > 0

            for cdir = 1:sub_count

                if any( strcmp( char(sub_list(cdir)), valid_dirs))

                    nc = num2str( validate_numeric_entry ( char( comp_list(compcount) ) ) );

                    if ~isempty( criteria.Hmodel )
                        H_ID = H_path_spec( criteria.Hheader, criteria.Hmodel );
                        if ~strcmp( char(sub_list(cdir)), 'unrotated' )
                            noParms = struct( 'model', 'H', 'mode', criteria.Hmodel, 'hindex',  H_ID, 'method', char(sub_list(cdir))  );
                            p =  fs_path( 'rotated', 'output', nc, 0, noParms );
                        else
                            noParms = struct( 'model', 'H', 'mode', criteria.Hmodel, 'hindex',  H_ID );
                            p =  fs_path( 'unrotated', 'output', nc, 0, noParms );
                        end
                        q = [p char(42) '.mat'];
                        %q = [p char(sub_list(cdir)) filesep criteria.module char(42) '.mat' ];
                    else
                        p = [comp_dir char(sub_list(cdir)) filesep ];
                        q = [p char(42) '.mat' ];
                    end

                    addlst = get_matfile_entries( p, nc, criteria );
                    CompTypeList = [CompTypeList addlst];

                    [A_list A_count] = directory_list( p );
                    if A_count > 0
                        for A_ii = 1:A_count
                            clear addlst
                            addlst = get_matfile_entries( [comp_dir char(sub_list(cdir)) filesep char(A_list(A_ii)) filesep], nc, criteria, 1 );
                            if ~isempty(addlst)
                                for A_jj = 1:size(addlst,2)
                                    if ~strcmp( char(A_list(A_ii)), 'ROI' )
                                        CompTypeList = [CompTypeList [char(addlst(A_jj)) ' [' char(A_list(A_ii)) ']' ]];
                                    else
                                        CompTypeList = [ CompTypeList char(addlst(A_jj)) ];
                                    end

                                end
                            end
                        end
                    end


                end % -- valid data directory

            end % -- check if valid
        end  % --- extraction directory found

    end  % check each component count directory

end  % -- no extracted component directories found for model type

criteria.lst_computedFiles = CompTypeList;

for idx = 1:size(CompTypeList,2)
    [cdir, fn] = filename_from_list( idx, criteria );
    % rstyle = mvs_rotation_style( fn );
    %
    %
    % load( [pwd filesep cdir fn], 'VR', 'ep', 'alternatePR', 'GroupIndex', 'mask_registry', 'process_date' );
    % criteria.Weights = load([pwd filesep cdir fn], 'PR*');
    %
    % criteria.mask_registry = 0;
    % if exist( 'mask_registry', 'var' )
    %   criteria.mask_registry = mask_registry;
    % end
    % if exist( 'alternatePR', 'var' )
    %   criteria.aPR = alternatePR;
    % end
    %
    % criteria.GI = 0;
    % criteria.select_grps = 0;
    %
    % group_selection_window = 0;
    x = regexp( cdir, '_', 'split' );
    x1 = regexp( char(x(1)), '[0-9]', 'match' );
    strx = [];
    for ii = 1:size(x1,2)
        strx = [strx char(x1(ii) )];
    end
    numcomps = str2num(strx);

    if comp_to_flip > numcomps
        fprintf('The total number of components is %s\n', num2str(nucomps));
        disp('Please double check the component is going to flip!')
        return;
    end

    % for ii = 1:numcomps
    %     p = sprintf( '%d', ii );
    %     lst = horzcat( lst, {p});
    % end

    str = char(CompTypeList{idx}); 	% returns selected item from lst_Component
    fprintf('working on %s\n', str);
    method = mvs_rotation_method( fn );
    rstyle = mvs_rotation_style( fn );

    GAtyp = 'G';
    Aidx = 0;
    str = regexp( fn, '_', 'split' );
    isGA = strcmp( char(str(1)), 'GA' ) | strcmp( char(str(1)), 'GAA' );
    if isGA
        GAtyp = 'GA';
        load( Zheader.Contrast.path );
        Aidx = Aheader_index( Aheader, criteria, idx );
    else
        GAtyp = char(str(1) );
    end

    disp( 'Flipping Data' );

    % if ( comp_to_flip == 0 )
    %     MainText = [ 'Flip all components ( UR VR PR ) in ' fn ];
    % else
    MainText = [ 'Flip component ' num2str(comp_to_flip) ' ( UR VR PR ) in ' fn ];
    % end

    disp( MainText );
    disp( 'Loading Data' );

    % --- snr, T & rotation_params do not exist in unrotated solution
    load( [pwd filesep cdir fn], 'UR', 'VR', 'PR*', 'snr', 'tsum', 'betas_c*', 'rotation_params', 'T', 'cvar*', 'alternatePR', 'mask_registry' );
    if ~exist( 'mask_registry', 'var' ),  mask_registry = 0;  end

    ind = [];
    if mask_registry > 0
        [~, ind] = mask_registrations( scan_information.mask, mask_registry );
    end
    nvox = Zheader.total_columns;
    if ~isempty( ind )
        nvox = numel( ind );
    end

    if exist('rotation_params', 'var' )
        rotation_params = rotation_params;
    else
        rotation_params = [];
    end
    rotation_params.model = criteria.prefix;

    if ~isfield( rotation_params, 'defaults' )
        rotation_params.defaults = [];
    end

    if ~isfield( rotation_params, 'method' )
        rotation_params.method = method;
    end

    Mode = criteria.prefix;

    if criteria.prefix == 'H'
        rotation_params.mode = criteria.Hmodel;
        rotation_params.htype = criteria.module;

        rotation_params.hindex = H_path_spec( criteria.Hheader, criteria.module );

        Mode = criteria.Hmodel;
        if size( criteria.module,2) > 0
            Mode = criteria.module;
        end
    end

    meth = 'rotated';
    if strcmp( rotation_params.method, 'unrotated' )
        meth = rotation_params.method;
    end

    if isGA & Aidx > 1
        rotation_params.hindex = Aheader.model( Aidx ).id;
    end
    rotation_params.Aindex = Aidx;

    %   if mask_registry > 0 && constant_define( 'PREFERENCES', 'general.gray_white_split' )
    rotation_params.defaults.reg =  mask_registry;
    rotation_params.defaults.regTag = constant_define( 'REGISTRATION_TAG', mask_registry);
    %   end

    image_directory = fs_path( meth, 'images', numcomps, 0, rotation_params );
    mni_file = fs_filename( 'loadings', GAtyp, rotation_params.method, rotation_params.defaults );
    load( [pwd filesep image_directory mni_file], 'MNI' );

    plot_directory = fs_path( meth, 'plots', numcomps, 0, rotation_params );
    plot_directory = [ pwd filesep plot_directory ];

    component_directory = fs_path( meth, 'output', numcomps, 0, rotation_params );

    % disp( 'Flipping Components' );

    % --- make a flip log entry for these flipped components
    % --- and preserve original content
    [logok logdir] = fs_create_path(meth, 'fliplog', numcomps, 0, rotation_params );

    if logok
        logfile = [ logdir 'fliplog.log' ];

        TS = datestr(now, 'HH_MM_PM' );
        append_flip_log( logfile, MainText );

        logbu = [ logdir  datestr(now, 'mmm_dd_yyyy' ) filesep TS filesep ];

        if ~exist( logbu, 'dir' )
            mkdir( logbu );
            mkdir( [ logbu 'Images' ] );
        end

        eval( [ 'copyfile( ''' component_directory char(42) '.txt'', ''' logbu ''' );' ] );
        eval( [ 'copyfile( ''' component_directory 'Images' filesep char(42) ''', ''' logbu 'Images'' );' ] );
    	copyfile([component_directory fn], logbu);
    	movefile([logbu fn], [logbu 'original_G_unrotated.mat']);
    end

    % --- ---------------------
    % --- flip VR, UR and PR
    % --- ---------------------
    if ( comp_to_flip == 0 )
        UR  = UR  .* -1;
        VR  = VR  .* -1;
        PR  = PR  .* -1;
        PRh = PRh .* -1;

        % --- ---------------------
        % --- flip alternate PR
        % --- ---------------------
        if exist( 'alternatePR', 'var' )

            for cmp = 1:size(VR,2)
                n = alternatePR.component(cmp).pos;
                p = alternatePR.component(cmp).neg;

                n.PR = n.PR * -1;
                n.avg = n.avg * -1;
                p.PR = p.PR * -1;
                p.avg = p.avg * -1;
                alternatePR.component(cmp).pos = p;
                alternatePR.component(cmp).neg = n;

                alternatePR.component(cmp).all.PR = alternatePR.component(cmp).all.PR * -1;
                alternatePR.component(cmp).all.avg = alternatePR.component(cmp).all.avg * -1;
            end

        end


    else
        % --- ---------------------
        % --- flip Component VR, UR and PR
        % --- ---------------------
        UR(:,comp_to_flip) = UR(:,comp_to_flip) .* -1;
        VR(:,comp_to_flip) = VR(:,comp_to_flip) .* -1;
        if ~isempty( PR )
            PR(:,comp_to_flip) = PR(:,comp_to_flip) .* -1;
        end
        if ~isempty( PRh )
            PRh(:,comp_to_flip) = PRh(:,comp_to_flip) .* -1;
        end

        % --- ---------------------
        % --- flip Component alternate PR
        % --- ---------------------
        if exist( 'alternatePR', 'var' )
            n = alternatePR.component(comp_to_flip).pos;
            p = alternatePR.component(comp_to_flip).neg;

            n.PR = n.PR * -1;
            n.avg = n.avg * -1;
            p.PR = p.PR * -1;
            p.avg = p.avg * -1;
            alternatePR.component(comp_to_flip).pos = p;
            alternatePR.component(comp_to_flip).neg = n;

            alternatePR.component(comp_to_flip).all.PR = alternatePR.component(comp_to_flip).all.PR * -1;
            alternatePR.component(comp_to_flip).all.avg = alternatePR.component(comp_to_flip).all.avg * -1;

        end


        % --- ---------------------
        % --- flip Component cluster MNI data
        % --- ---------------------

        if ~(scan_information.isMulFreq == 1)
            if isfield( MNI, 'component' )
                if ~isempty( MNI.component )		% --- no cluster info for BH components
                    for cno = 1:size( comp_to_flip, 2 )

                        for thr = 1:size(MNI.component(comp_to_flip(cno)).threshold, 1 )

                            p = flip_MNI_values( MNI.component(comp_to_flip(cno)).threshold(thr).neg );
                            n = flip_MNI_values( MNI.component(comp_to_flip(cno)).threshold(thr).pos );

                            MNI.component(comp_to_flip(cno)).threshold(thr).pos = p;
                            MNI.component(comp_to_flip(cno)).threshold(thr).neg = n;

                        end % --- each threshold of component
                    end % --- each component to flip

                    save( [image_directory mni_file], 'MNI', '-append', '-v7.3'  );

                end  % --- MNI contains cluster information
            end  % --- MNI contains component field
        end  % --- no MNI data on beamformed MEG images

        % --- ---------------------
        % --- loadings for component recalculated during image creation
        % --- ---------------------

    end

    if rotation_params.model == 'H'
        H = load_H_matrix( criteria.Hheader );
        ep = calc_ext_Pos_Neg(VR); % --=
    else
        ep = calc_ext_Pos_Neg(VR);
    end

    % -- reset the altered data

    if exist( 'alternatePR', 'var' )
        criteria.aPR = alternatePR;
    end

    if exist( 'alternatePR', 'var' )
        save( [cdir fn], 'UR*', 'VR', 'PR*', 'alternatePR', 'ep', '-append', '-v7.3' );
    else
        save( [cdir fn], 'UR*', 'VR', 'PR*', 'ep', '-append', '-v7.3' );
    end

    % --- ---------------------
    % --- recalculate Component pos/neg betas
    % --- ---------------------
    tag = 'GC';
    tsum = Zheader.tsum;

    if ( strcmp( criteria.prefix(1), 'H' ) )

        sumDiag = 0;
        eval( ['sumDiag = criteria.Hheader.model(criteria.Hheader.Hindex).sum_diagonal.' rotation_params.htype ';' ] );

        if ~strcmp( criteria.Hmodel, 'GMH' )

            in_dir = [Zheader.Z_Directory 'Hsegs' filesep ];			% eg: GZ_segs, GAZ_segs
            in_h = [ in_dir criteria.Hmodel '.mat' ];

            disp( 'Calculating Positive Betas' );
            betas_c_pos = calc_b_betas_cmd( [cdir fn], in_h, 1 );

            disp( 'Calculating Negative Betas' );
            betas_c_neg = calc_b_betas_cmd( [cdir fn], in_h );
        else

            disp( 'Calculating Positive Betas' );
            betas_c_pos = calc_gmh_gm_betas_cmd( [cdir fn], criteria.Hheader, 1);

            disp( 'Calculating Negative Betas' );
            betas_c_neg = calc_gmh_gm_betas_cmd( [cdir fn], criteria.Hheader, 0);

        end

    else
        load( Zheader.Model.path, 'Gheader' );

        if isGA
            sumDiag = Aheader.model(Aidx).sd(1 + strcmp( GAtyp, 'GAA' ) );
        else
            sumDiag = Gheader.GZheader.sum_diagonal;
            switch mask_registry
                case 1
                    sumDiag = Gheader.GZheader.rsum(1) + sum(Gheader.GZheader.rsum(4:5));
                    tsum = Zheader.rsum(1) + sum(Zheader.rsum(4:5));
                    %          tag = 'GC Gm';
                case 2
                    sumDiag = Gheader.GZheader.rsum(2);
                    tsum = Zheader.rsum(2);
                    %          tag = 'GC Wm';
            end

        end

        disp( 'Calculating Positive Betas' );
        betas_c_pos = calc_c_betas_cmd(Zheader, scan_information, [cdir fn], Gheader, 1, 0, GAtyp, mask_registry );

        disp( 'Calculating Negative Betas' );
        betas_c_neg = calc_c_betas_cmd(Zheader, scan_information, [cdir fn], Gheader, 0, 0, GAtyp, mask_registry );

    end

    ftext = '';

    if exist( 'rotation_params', 'var' )
        if isfield( rotation_params, 'defaults' )
            theseParms = rotation_params;
        end
    end

    % --- ---------------------
    % -- refresh original output file
    % --- ---------------------
    disp( 'Updating Output Files . . .' );

    %   if mask_registry > 0
    %     theseParms.defaults.reg =  mask_registry;
    %     theseParms.defaults.regTag = constant_define( 'REGISTRATION_TAG', mask_registry);
    %   end

    ftext = GAtyp;
    if strcmp( GAtyp, 'GA' ),    ftext = 'AnotG';  end
    if strcmp( GAtyp, 'GAA' ),   ftext = 'GnotA';  end

    text_file = fs_filename( 'txt', ftext, method, theseParms.defaults );
    text_file = [ 'output_' text_file ];

    ftext = [ GAtyp 'C'];
    if strcmp( GAtyp, 'GA' )
        ftext = GAtyp;
    end
    if strcmp( GAtyp, 'GAA' )
        ftext = 'GnotA';
    end
    %   ftext = [ftext constant_define( 'REGISTRATION_SUMMARY_TAG', mask_registry) ];

    fid = fopen( [cdir text_file], 'w' );
    text_file_header_cmd(Zheader, scan_information, numcomps, fid, 0, cdir, text_file, rotation_params.Aindex, nvox ) ;
    if criteria.prefix == 'H'
        H_matrix_header(criteria.Hheader, fid);
    end
    pca_summary_cmd(Zheader,scan_information, sumDiag, [ftext constant_define( 'REGISTRATION_SUMMARY_TAG', mask_registry)], cvariance_rotated_tot, fid, tsum );
    pca_summary_cmd(Zheader,scan_information, sumDiag, [ftext constant_define( 'REGISTRATION_SUMMARY_TAG', mask_registry)], cvariance_rotated_tot, 1, tsum );
    %  pca_summary( sumDiag, ftext, cvariance_rotated_tot, 1 );


    print_UR_coefficents( fid, corrcoef( UR ) );
    if exist( 'T', 'var' )
        print_matrix_values( fid, T, 'T matrix:' );
    end
    display_extremes_pos_neg(ep, cvariance_rotated_tot, tsum, fid, 2, 0 );

    if ~isGA
        print_subject_variances_cmd(Zheader,scan_information, fid, mask_registry )
    end

    if ( fid ) fclose( fid ); fid = 0; end


    % --- ---------------------
    % --- refresh PR(HRF) output file
    % --- refresh alternate PR(HRF) output file
    % --- ---------------------

    thoseParms = theseParms;

    theseParms.defaults.var = 'HRF';
    theseParms.defaults.component = 999;
    text_file = fs_filename( 'txt', Mode, method, theseParms.defaults );

    if ~isempty(PR) & ~isGA
        output_HRF_cmd(Zheader, scan_information,  cdir, text_file, PR, Gheader, 0, nvox);
        if exist( plot_directory, 'dir' )
            plot_HRF_cmd(Zheader, scan_information,  plot_directory, PR, Gheader, thoseParms );
        end
    end

    if ~isempty(PRh)

        eval( ['sumDiag = criteria.Hheader.model(criteria.Hheader.Hindex).sum_diagonal.' rotation_params.htype ';' ] );
        if rotation_params.mode(1) == 'E'
            tsums = Zheader.tsum_E;
        else
            tsums = Zheader.tsum;
        end
        ftag = '';

        mniParms.text = ftag;
        mniParms.var = 'Predictor_Weights';
        for component_no = 1:size(PRh,2)
            mniParms.component = component_no;
            mni_file = fs_filename( 'txt', rotation_params.htype, 'unrotated', mniParms );

            fid = fopen( [cdir mni_file], 'w' );
            text_file_header_cmd(Zheader, scan_information, numcomps, fid, 0, cdir, mni_file, rotation_params.Aindex, nvox );
            if criteria.prefix == 'H'
                H_matrix_header(criteria.Hheader, fid);
            end
            pca_summary_cmd(Zheader,scan_information, sumDiag, rotation_params.htype, cvariance_rotated_tot, fid );
            print_formatted_ep( ep, component_no, fid, 0 );
            show_PR_weights( PRh(:,component_no), VR(:,component_no), criteria.Hheader, 1, fid );

            if ( fid)  fclose(fid); end
        end
    end

    % --- ---------------------
    if exist( 'Alternate_PR', 'var' )
        % --- ---------------------
        aPR = [];
        for comp = 1:size(alternatePR.component, 1 )
            aPR = [aPR alternatePR.component(comp).all.PR(:) ];
        end

        theseParms.defaults.text = 'Alternate_PR';
        thoseParms.defaults.text = 'Alternate_PR';
        text_file = fs_filename( 'txt', Mode, method, theseParms.defaults );
        output_HRF_cmd(Zheader, scan_information, cdir, text_file, aPR, Gheader);
        plot_HRF_cmd(Zheader, scan_information, plot_directory, aPR, Gheader, thoseParms );
    end

    % --- ---------------------
    % -- recreate component images
    % --- ---------------------
    disp( 'Recreating Images' );
    if ~isfield( rotation_params, 'htype' )
        rotation_params.htype = [];
    end

    if ( strcmp( criteria.prefix(1), 'H' ) )
        if ( strcmp( criteria.Hmodel, 'GMH' ) )
            recreate_gmh_images_cmd(Zheader, scan_information,rotation_params, Mode, numcomps, comp_to_flip);
        else
            recreate_h_images_cmd(Zheader, scan_information,  rotation_params, criteria.Hmodel, numcomps, 0 );
        end

    else
        recreate_g_images_cmd(Zheader, scan_information, rotation_params, numcomps, comp_to_flip, GAtyp, mask_registry );
    end
    load([pwd filesep cdir fn], 'component_loadings');
    %eval( ['load( ''' cdir fn ''', ''component_loadings'' )'] );

    if ~(scan_information.isMulFreq == 1) && ~isGA	% --- bypass cluster data on meg data for now
        rotation_params.fs = meth;
        if ~isfield( rotation_params, 'htype' )
            rotation_params.htype = 'G';
        end
        rotation_params.component_vector = comp_to_flip;
        if ~strcmp( criteria.Hmodel, 'GMH' ) & ~strcmp( criteria.Hmodel, 'BH' )

            if isempty( rotation_params.htype )
                rotation_params.htype = Mode;  % --- changes to flip GMH vars may cause loss of G prefix
            end

            %      write_cluster_beta_mean_median( rotation_params, Gheader, size(VR,2) );
            %      write_cluster_masks( rotation_params, size(VR,2), rotation_params.htype );
            if constant_define( 'PREFERENCES', 'cluster.create_masks' , 1 )
                write_cluster_masks_cmd(scan_information, rotation_params, size(VR,2), rotation_params.htype);
            end
            if constant_define( 'PREFERENCES', 'cluster.calculate_mean' , 0 ) | ...
                    constant_define( 'PREFERENCES', 'cluster.calculate_median' , 0 )
                write_cluster_beta_mean_median_cmd(Zheader, scan_information,  rotation_params, Gheader, size(VR,2) );
            end
        end
    end

    if exist( 'alternatePR', 'var' )
        criteria.aPR = alternatePR;
    end
    clear UR VR PR* snr tsum betas_c* rotation_params T cvar* alternatePR mask_registry;
end

disp('Done!');

end
% --- end function


function [ cmpdir, fn] = filename_from_list( idx, criteria )

list_content = criteria.lst_computedFiles ;
str = char(list_content{idx});
isGA = 0;
isROI = 0;

str2 = regexp(str, ' ', 'split' );
method = char(str2(2));
if strcmp( method, 'GMH' ) || strcmp( method, 'GnotH' ) || strcmp( method, 'HnotG' )
    method = char(str2(3));
end

if strcmp( method, 'GA' ) || strcmp( method, 'GAA' )
    method = char(str2(3));
    isGA = 1;
end
%   if strcmp( method, 'GAA' )
%     method = char(str2(3));
%     isGA = 1;
%   end
if strcmp( method, 'ROI' )
    method = char(str2(3));
    isROI = 1;
end

x = regexp( str(1,1:4), '[0-9]', 'match' );
strx = [];
for ii = 1:size(x,2)
    strx = [strx char(x(ii) )];
end
nc = str2num(strx);

if ~isempty( criteria.Hmodel )
    htyp = criteria.module;
    switch criteria.module
        case 'GC'
            htyp = 'GnotH';
        case 'BH'
            htyp = 'HnotG';
    end

    H_ID  = H_path_spec( criteria.Hheader, 'GMH') ;
    prm = struct( 'model', criteria.prefix, 'mode', criteria.Hmodel, 'hindex', H_ID );
else
    prm = struct( 'model', criteria.prefix );

    if isROI
        roi_id = strrep(  strrep( char(str2(4)), '(', '' ),  ')', '' );
        prm.hindex = [ 'ROI' filesep roi_id ];
        prm.model = 'G';
        %       noParms.ROIGZ = [ noParms.model filesep strrep( G_ROI.mask( G_ROI.Rindex).id, ' ', '_' ) filesep 'GZsegs'];
    end

end

if ( any(strcmp( str2, 'unrotated' ) ) )
    cmpdir = fs_path( 'unrotated', 'output', nc, 0, prm  );
else
    prm.method = method;
    cmpdir = fs_path( 'rotated', 'output', nc, 0, prm );
end

x = strfind( str, '[' );
if x
    y = strfind( str, ']' );
    if y
        pth_add = str(x+1:y-1);
        str = strtrim(strrep( str, ['[' pth_add ']'], '' ));
        cmpdir = [cmpdir pth_add filesep ];
    end
end

%   wipe = [ '[' num2str(nc) ']' ];
%   if length( criteria.Hmodel ) == 0
%     fn = strrep( str, wipe, criteria.prefix(1));
%   else
%     fn = strrep( str, wipe, criteria.Hmodel);
%   end

wipe = [ '(' num2str(nc) ')' ];

if length( criteria.Hmodel ) == 0
    if isGA
        fn = strrep( str, [wipe ' '], '');
    else
        if ~isROI
            fn = strrep( str, wipe, criteria.prefix(1));
        else
            fn = strrep( str, wipe, '');
            if ~isempty( strfind( fn, ' (' ))
                fn = strtrim( fn(1:strfind( fn, ' (' )) );
            end
        end

    end
else
    if length( criteria.module ) == 0
        fn = strrep( str, wipe, criteria.Hmodel);
    else
        fn = strrep( str, [wipe ' '], '' );
    end
end

fn = strrep( fn, ' ', '_' );
fn = [ fn '.mat' ];
end
% --- end function

function Aidx = Aheader_index( Aheader, criteria, idx )

  Aidx = 0;
  list_content =  criteria.lst_computedFiles ;
  str = char(list_content(idx));
  [cdir fn] = filename_from_list( idx, criteria );
  
  prm = struct( 'model', criteria.prefix );
  method = mvs_rotation_method( fn );
  rot = 'unrotated';
      
  if ~strcmp( method, 'unrotated' )
    rot = 'rotated';
    prm.method = method;
  end

  x = str2num(char(regexp( str(1:5), '[0-9]', 'match' )));
  if size(x,1) == 1
    nc = x;
  else
    nc = x(1) + (x(2) * 10);
    if size(x,1) == 3
      nc = nc + (x(3) * 100);  % - doubtful, but let's not assume
    end
    
  end
  
  rdir = fs_path( rot, 'output', nc, 0, prm );
  pth = strrep( cdir, rdir, '' );

  Aidx = 1;
  if ~isempty( pth )
    for ii = 1:size( Aheader.model, 1 )
      if strcmp( Aheader.model(ii).id,  pth(1:length(pth)-1 ) )
        Aidx = ii;
        break
      end
    end
  end
end

function lst = get_matfile_entries( folder, nc, criteria, dosubs )

if nargin < 4
    dosubs = 0;
end

lst = [];
dirlist = {folder};

if dosubs
    [dlist dircount] = directory_list( folder );

    dirlist = {folder};
    if ~isempty( dlist )
        for ii = 1:size( dlist, 1 )
            dirlist = [dirlist; {[folder char(dlist(ii) )]} ];
        end
    end
end


for ii = 1:size( dirlist, 1 )

    folder = strrep( [char( dirlist(ii) ) filesep ], [filesep filesep], filesep );

    matlist = dir([folder char(42) '.mat' ]);

    if ( size(matlist, 1) > 0 )

        for jj = 1:size(matlist,1)

            if isempty( strfind( matlist(jj).name, '_T_' ))
                hrft = who_stats( folder, matlist(jj).name, 'cpca_version' );

                if hrft.mat_exists    % ---- valid cpca output mat

                    validP = who_stats( folder, matlist(jj).name, 'PR' );
                    if validP.mat_exists    % ---- valid cpca extraction/rotation output mat

                        str = matlist(jj).name;

                        if ~isempty( criteria.Hmodel )
                            wipe = [ criteria.Hmodel '_'];
                            rep = [ '(' num2str(nc) ') ' criteria.Hmodel ' ' ];
                            str = strrep( str, wipe, rep );

                            repas = criteria.module;
                            if strcmp(criteria.module,'GC' )
                                repas = 'GnotH';
                            else
                                if strcmp(criteria.module,'BH' )
                                    repas = 'HnotG';
                                end
                            end
                            wipe = [ criteria.module '_'];
                            rep = [ '(' num2str(nc) ') ' repas ' ' ];
                            str = strrep( str, wipe, rep );
                        end

                        wipe = [ criteria.model_display '_'];
                        rep = [ '(' num2str(nc) ') ' ];
                        str = strrep( str, wipe, rep );

                        wipe = 'GA_';
                        rep = [ '(' num2str(nc) ') GA ' ];
                        str = strrep( str, wipe, rep );

                        wipe = 'GAA_';
                        rep = [ '(' num2str(nc) ') GAA ' ];
                        str = strrep( str, wipe, rep );

                        str = strrep( str, '_', ' ' );
                        str = strrep( str, '.mat', '' );

                        rep = [ '(' num2str(nc) ') ' ];
                        if isempty( strfind( str, rep ) )
                            str = [rep str ];
                        end

                        if ~isempty( strfind( str, 'ROI' ) )
                            roi_id = strrep( folder, char( dirlist(1) ), '' );
                            roi_id = strrep( roi_id, filesep, '' );

                            str = [ str, ' (', roi_id ')' ];
                        end


                        lst = horzcat( lst, {str});
                    end

                end
            end	% --- not the hrfmax T variable
        end
    end

end

end
% --- end function
