function write_cluster_beta_mean_median_cmd(Zheader, scan_information,  rotation_params, Gheader, nd, mask_registry )
% produce output of mean and median betas per cluster

% --- Primary Iterations
% --- nd * max(scan_information.frequencies, 1)

if nargin < 6,  mask_registry = 0;  end

ind = [];
if mask_registry > 0
    [~, ind] = mask_registrations( scan_information.mask, mask_registry );
end

if isempty( rotation_params )
    rotation_params.method = 'unrotated';
    rotation_params.defaults = struct( 'empty', 1 );
    rotation_params.fs = 'unrotated';
end

rotation_params.nd = nd;

if ~isfield( rotation_params, 'model' )
    rotation_params.model = 'G';
else
    if isempty(rotation_params.model)
        rotation_params.model = 'G';
    end
end

if ~isfield( rotation_params, 'GA' )
    rotation_params.GA = rotation_params.model;
end

if ~isfield( rotation_params, 'component_vector' )
    rotation_params.component_vector = 1:nd;
end

p = fs_path( rotation_params.fs, 'output', nd, 0, rotation_params );
v = fs_filename( 'mat', rotation_params.GA, rotation_params.method, rotation_params.defaults );

i = fs_path( rotation_params.fs, 'images', nd, 0, rotation_params );
m = fs_filename( 'loadings', rotation_params.GA, rotation_params.method, rotation_params.defaults );

evalc( ['load( ''' i m ''', ''MNI'' )'] );

nconds = Gheader.conditions;
nbins = Gheader.bins;
cne = ones( nbins,1) .* constant_define( 'NON_ENCODED_COND_FLAG' ) ;

%   comp_betas = struct( 'component', [] );

if ( rotation_params.model == 'G' )
    evalc( ['load( ''' p v ''', ''VR'', ''AR'', ''ep*'' )'] );
else
    evalc( ['load( ''' p v ''', ''AR'', ''ep'' )'] );
    VR = AR;
end

nvox = Zheader.total_columns;
if ~isempty( ind )
    nvox = size( ind, 1 );
    %    VR = VR(:,ind);
end

%   iters = nd * num_active_thresholds() * 2;

for FrequencyNo = 1:scan_information.frequencies
    start_col = (FrequencyNo - 1) * nvox + 1;
    end_col = start_col + nvox - 1;
    ftag = frequency_tag_cmd(FrequencyNo,scan_information) ;

    % if ~isempty(pop)
    %   pop.setIterations( size(rotation_params.component_vector,2) * num_active_thresholds(), pop.SECONDARY );
    % end;

    thisVR = VR(start_col:end_col,:);

    for cmp = 1:size(rotation_params.component_vector,2)

        comp = rotation_params.component_vector(cmp);
        rotation_params.defaults.component = comp;

        Sts = ['Component ' num2str(cmp) ];

        %       component = struct( 'avg', [], 'med', [] );

        %       abs_cluster_no = 0;

        for thresh_index = 1:num_global_thresholds()

            if is_active_threshold(thresh_index)


                % pop.setMessage( [Sts ' @' num2str(global_threshold_value( thresh_index)) '%'] );


                if isfield( MNI, 'component' )
                    thisMNI = MNI.component(comp).threshold( thresh_index );
                    rotation_params.threshold = global_threshold_value( thresh_index);
                else
                    thisMNI = MNI((((FrequencyNo-1)*nd)+comp));
                end

                rotation_params.thresh_index = thresh_index;

                % ------------------------------------------------
                % function may be called by a component flip
                % ensure all files in component directory are removed to avoid confusion
                % ------------------------------------------------
                cp = fs_path( rotation_params.fs, 'cluster_mean', nd, 0, rotation_params );
                if exist( cp, 'dir' )
                    eval( ['delete ' cp '*;'] );
                end

                cp = fs_path( rotation_params.fs, 'cluster_median', nd, 0, rotation_params );
                if exist( cp, 'dir' )
                    eval( ['delete ' cp '*;'] );
                end

                cp = fs_path( rotation_params.fs, 'cluster_plots', rotation_params.nd, 0, rotation_params );
                if exist( cp, 'dir' )
                    eval( ['delete ' cp '*;'] );
                end

                threshold = [];
                eval( ['threshold = ep' ftag '(comp).percentiles( thresh_index ).threshold;' ] );	% top 5% of component weights
                eval( ['voxels = ep' ftag '(comp).percentiles( thresh_index ).voxels;' ] );


                disp( ' Positive Clusters . . .' );


                abs_cluster_no = 0;
                if size(thisMNI.pos, 1 ) > 0

                    rotation_params.defaults.posneg = 'Positive';

                    for clno = 1:size(thisMNI.pos, 1 )

                        if ( thisMNI.pos(clno).mm3 >= constant_define( 'PREFERENCES', 'cluster.minimum_mm3' ) )

                            abs_cluster_no = abs_cluster_no + 1;
                            rotation_params.defaults.cluster = sprintf('%03d', abs_cluster_no);

                            % ------------------------------------------------
                            % load the single cluster component
                            % ------------------------------------------------
                            vr_cmp = thisVR(:,comp);
                            index = thisMNI.pos(clno).Masks.Zindex;
                            %               if ~isempty(ind)
                            %                 index = thisMNI.pos(clno).Masks.GZindex;
                            %               end
                            % ------------------------------------------------
                            % are there positive clusters
                            % ------------------------------------------------
                            vr_cmp = vr_cmp(index);
                            x = find( vr_cmp >= threshold );

                            %               vr_comp = vr_cmp(x);

                            if ( size(x,1) > 1 )		% ensure that there are loadings

                                avg_conditions = [];
                                med_conditions = [];

                                for s=1:Zheader.num_subjects

                                    C = load_subject_C_cmd( Gheader, Zheader, s );
                                    C_comp = C(:,x);

                                    subject_avg_conditions = [];
                                    subject_med_conditions = [];
                                    er = 0;
                                    for cond = 1:nconds

                                        if isEncoded_cmd(Zheader, scan_information, s, cond )

                                            sr = er + 1;
                                            er = sr + nbins - 1;
                                            C_avg = mean(C_comp(sr:er,:), 2);
                                            C_med = median(C_comp(sr:er,:), 2);

                                            subject_avg_conditions = [subject_avg_conditions C_avg];
                                            subject_med_conditions = [subject_med_conditions C_med];

                                        else   % --- condition non encoded pad out the array
                                            subject_avg_conditions = [subject_avg_conditions cne ];
                                            subject_med_conditions = [subject_med_conditions cne ];
                                        end

                                    end  % --- each condition

                                    avg_conditions = [avg_conditions; subject_avg_conditions ];
                                    med_conditions = [med_conditions; subject_med_conditions ];

                                end  % --- each subject


                                disp( 'Positive Clusters . . . Writing . . .' );

                                write_this_info_cmd(Zheader,scan_information,rotation_params, avg_conditions, med_conditions, thisMNI.pos(clno), FrequencyNo );

                            end  % --- VR has loadings above % threshold

                        end % --- positive cluster over 500 cubic mm

                    end % --- each positive cluster

                end % --- positive clusters exist


                disp( ' Negative Clusters . . .' );

                abs_cluster_no = 0;
                if size(thisMNI.neg, 1 ) > 0

                    rotation_params.defaults.posneg = 'Negative';

                    for clno = 1:size(thisMNI.neg, 1 )

                        if ( thisMNI.neg(clno).mm3 >= constant_define( 'PREFERENCES', 'cluster.minimum_mm3' ) )

                            abs_cluster_no = abs_cluster_no + 1;
                            rotation_params.defaults.cluster = sprintf('%03d', abs_cluster_no);

                            % ------------------------------------------------
                            % load the single cluster component
                            % ------------------------------------------------
                            vr_cmp = thisVR(:,comp);
                            index = thisMNI.neg(clno).Masks.Zindex;
                            %               if ~isempty(ind)
                            %                 index = thisMNI.neg(clno).Masks.GZindex;
                            %               end

                            % ------------------------------------------------
                            % are there negative clusters
                            % ------------------------------------------------
                            vr_cmp = vr_cmp(index);
                            x = find( vr_cmp <= ( threshold * -1 ) );

                            %               vr_comp = vr_cmp(x);

                            if ( size(x,1) > 1 )		% ensure that there are loadings

                                avg_conditions = [];
                                med_conditions = [];

                                for s=1:Zheader.num_subjects

                                    C = load_subject_C_cmd( Gheader, Zheader, s );
                                    C_comp = C(:,x);

                                    subject_avg_conditions = [];
                                    subject_med_conditions = [];
                                    er = 0;

                                    for cond = 1:nconds
                                        if isEncoded_cmd(Zheader, scan_information, s, cond )

                                            sr = er + 1;
                                            er = sr + nbins - 1;
                                            C_avg = mean(C_comp(sr:er,:), 2);
                                            C_med = median(C_comp(sr:er,:), 2);

                                            subject_avg_conditions = [subject_avg_conditions C_avg];
                                            subject_med_conditions = [subject_med_conditions C_med];

                                        else   % --- condition non encoded pad out the array
                                            subject_avg_conditions = [subject_avg_conditions cne ];
                                            subject_med_conditions = [subject_med_conditions cne ];
                                        end

                                    end  % --- each condition

                                    avg_conditions = [avg_conditions; subject_avg_conditions ];
                                    med_conditions = [med_conditions; subject_med_conditions ];

                                end  % --- each subject


                                disp( 'Negative Clusters . . . Writing . . .' );

                                write_this_info_cmd(Zheader,scan_information,rotation_params, avg_conditions, med_conditions, thisMNI.neg(clno), FrequencyNo );

                            end  % --- VR has loadings above % threshold

                        end % --- negative cluster over 500 cubic mm

                    end % --- each negative cluster

                end % --- negative clusters exist


            end  % --- threshold is active
        end  % --- each threshold


    end  % --- each component
end  % --- each frequency range


function write_this_info_cmd(Zheader,scan_information, rotation_params, avg_conditions, med_conditions, mni, FrequencyNo)

%  if ( length(char(scan_information.freq_names(FrequencyNo))) > 0 )  ftag = [char(scan_information.freq_names(FrequencyNo)) '_']; else ftag = ''; end;
ftag = frequency_tag_cmd( FrequencyNo,scan_information );
nbins = calculate_nbins_cmd(Zheader);

[~, p] = fs_create_path( rotation_params.fs, 'cluster_mean', rotation_params.nd, 0, rotation_params );
[~, q] = fs_create_path( rotation_params.fs, 'cluster_median', rotation_params.nd, 0, rotation_params );

of = sprintf( '%s_%s_MNI_%d_x_%d_x%d_MM3_%d%s_mean.txt', rotation_params.defaults.posneg, rotation_params.defaults.cluster, mni.peak.mni(1), mni.peak.mni(2), mni.peak.mni(3), mni.mm3, ftag );
mean_output = [p of];

of = sprintf( '%s_%s_MNI_%d_x_%d_x%d_MM3_%d%s_median.txt', rotation_params.defaults.posneg, rotation_params.defaults.cluster, mni.peak.mni(1), mni.peak.mni(2), mni.peak.mni(3), mni.mm3, ftag );
median_output = [q of];

mean_fid = fopen( mean_output, 'w' );
median_fid = fopen( median_output, 'w' );

fprintf(  mean_fid, 'created: %s - cpca %s\n', date, constant_define( 'REVISION_NUMBER' ) );
fprintf(  mean_fid, 'original location: %s\n', p );
fprintf(  mean_fid, '------------------------------------------\n' );

fprintf(  median_fid, 'created: %s - %s\n', date, date, constant_define( 'REVISION_NUMBER' ) );
fprintf(  median_fid, 'original location: %s\n', p );
fprintf(  median_fid, '------------------------------------------\n' );

hdr = sprintf( 'Voxels\t  MM^3\tPeak MNI   Value' );
str = sprintf( '%5d\t%6d\t[%d %d %d] %.04f', mni.voxels, mni.mm3, mni.peak.mni(1), mni.peak.mni(2), mni.peak.mni(3), mni.peak.value );
fprintf(  mean_fid, '%s\n%s\n', hdr, str );
fprintf(median_fid, '%s\n%s\n', hdr, str );

fprintf(  mean_fid, '\n' );
fprintf(  median_fid, '\n' );

for SubjectNo = 1:Zheader.num_subjects

    st = (( SubjectNo - 1 ) * nbins ) + 1;
    en = st + nbins - 1;

    SubjectMean = avg_conditions( st:en,: );
    SubjectMean = SubjectMean(:);

    SubjectMedian = med_conditions( st:en,: );
    SubjectMedian = SubjectMedian(:);

    fprintf(    mean_fid, 'S%d', SubjectNo );
    fprintf(  median_fid, 'S%d', SubjectNo );

    if ( size( scan_information.SubjectID, 2 ) >= SubjectNo )
        fprintf(    mean_fid, '\t%s', char(scan_information.SubjectID(SubjectNo)) );
        fprintf(  median_fid, '\t%s', char(scan_information.SubjectID(SubjectNo)) );
    end

    for ii = 1:size( SubjectMean, 1 )

        if SubjectMean(ii) == constant_define( 'NON_ENCODED_COND_FLAG' )
            fprintf(    mean_fid, '\t --- ');
        else
            fprintf(    mean_fid, ['\t' constant_define( 'PREFERENCES', 'precision.log', '%.2f' ) ], SubjectMean(ii) );
        end

        if SubjectMedian(ii) == constant_define( 'NON_ENCODED_COND_FLAG' )
            fprintf(  median_fid, '\t --- ');
        else
            fprintf(  median_fid, ['\t' constant_define( 'PREFERENCES', 'precision.log', '%.2f' )], SubjectMedian(ii) );
        end

    end

    fprintf(    mean_fid, '\n' );
    fprintf(  median_fid, '\n' );
end

fclose(   mean_fid );
fclose( median_fid );

