function [abort_proc,Zheader] = extract_ga_components_cmd(Zheader, scan_information, nd, log_fid, GAtyp )
% apply the G model to the normalized Z data
% creates the G_unrotated.mat data set for G extraction and imaging
%
% note: G and GA processing was separated to a allow for unique G as well as GA if desired


% --- Primary Iterations
% --- size( SubjectVector ) * 2;            - default [ 1:Zheader.num_subjects ]

if ( nargin < 4 )  log_fid = 0;  end
if ( nargin < 5 )  GAtyp = 'GA';  end

process_date = date;
abort_proc = 0;

load( Zheader.Model.path, 'Gheader');
load( Zheader.Contrast.path );

cc_var = 'CC';
cc_mat = 'GCC.mat';
%  eval( ['GZHeader = Gheader.' GAtyp 'Zheader;'] );
GAheader.GAZheader.path_to_segs = Aheader.model( Aheader.Aindex).path_to_GA;

pth_add = '';
if Aheader.Aindex > 1
    pth_add = strrep( [ filesep Aheader.model( Aheader.Aindex).id ], ' ', '_' );
end

% ---------------------------------------------------------
% with the volume of available extractions and rotations
% the root directory is getting quite crowded, so we will
% now put all extractions/rotations in a secondary directory
% named n_components (where n = the number of components extracted)
% ---------------------------------------------------------
noParms = struct( 'model', 'G', 'hindex', pth_add );

[has_dir component_directory] = fs_create_path( 'unrotated', 'output', nd, 0, noParms );
component_directory = [ pwd filesep component_directory ];

[has_dir plot_directory] = fs_create_path( 'unrotated', 'plots', nd, 0, noParms );
plot_directory = [ pwd filesep plot_directory ];

if ( has_dir )

    vflag = ' -v7.3';


    if (  has_GC_var_cmd(Zheader, GAheader, cc_var, GAtyp ) )		% BB file has been created
        save_file = fs_filename( 'mat', GAtyp, 'unrotated', noParms );
        save_file = [component_directory save_file];

        % if ( ~isempty( funcs.clear_cache ) )  funcs.clear_cache(); end; funcs.memory_stats();

        % ---------------------------------------------------------
        % component extraction
        % ---------------------------------------------------------

        x = find( scan_information.processing.model.process.components == nd );
        if x & x <= size( scan_information.processing.model.process.svd, 2 )
            do_svd = scan_information.processing.model.process.svd(x);
        else
            do_svd = 1;  % -- default position
        end

        if do_svd

            initialize_mat_file( save_file );

            disp(  'Performing Singular Value Decomposition . . .' );

            cc_file = Aheader.model( Aheader.Aindex).path_to_GA;
            x = matfile_vars( cc_file, cc_mat, cc_var );
            m = max( x.sz_x, x.sz_y );
            if m > 1  % --- use standard svd on scalars
                C_Eigenvalues = load_GC_var_cmd( Gheader, Zheader, 'C_Eigenvalues', GAtyp );
                [u3 d3 v3]=perform_svd([ cc_file cc_mat ] , cc_var, nd); % --=
            else
                C_Eigenvalues = load_GC_var_cmd( Gheader, Zheader, 'C_Eigenvalues', GAtyp );
                CC = load_GC_var_cmd( Gheader, Zheader, cc_var, GAtyp );
                %          load( [ cc_file '/GCC.mat'], 'C_Eigenvalues', 'CC' );
                [u3 d3 v3]=svd( CC); % --=
                clear CC;
            end

            % funcs.memory_stats();


            % --= ---------------------------------------------------------
            % --=  u3 and v3 are now sized to the G depth x # of components
            % --=  d3 will be a single column vector of the component eigenvalues
            % --=  ---------------------------------------------------------
            % --=

            % ---------------------------------------------------------
            % verify no NaN
            if ( isnan( sum(sum(u3)) ) | isnan( sum(sum(d3)) ) | isnan( sum(sum(v3)) ) )
                abort_proc = 1;
                str = 'Applying svd to C * C'' has resulted in a Nan.';
                fprintf( 'Data Calculation Error: %s\n', str );
                return;
            end

            d3=sqrt(d3); % --=
            save( save_file, 'u3', 'd3', 'v3', 'nd', '-append', '-v7.3' );

        else

            load( save_file, 'u3', 'd3', 'v3' );

        end  % -- bypass svd stage

        disp(  'Calculating Loadings' );


        C_Eigenvalues = load_GC_var_cmd(Gheader, Zheader, 'C_Eigenvalues', GAtyp );

        % ------------------------------------------------
        % --- force G application to be only on all subjects
        % ------------------------------------------------
        tsum = Zheader.tsum; % --=
        GroupIndex = 0;
        SubjectVector =  1:Zheader.num_subjects ;
        % --=

        psum = sum(C_Eigenvalues); % --=
        ppsum=100*(psum/tsum)  ; % --=
        % --=

        Zheader.summaries.GZ.SS.Explained = psum;
        Zheader.summaries.GZ.SS.pct = ppsum;
        % --=

        % --- size of d3 from svd_power is square matrix ( nd x nd )
        dsum = sum(sum(d3.^2)); % --=
        pdsum=100*(dsum/psum); % --=
        ppdsum=100*(dsum/tsum); % --=
        % --=

        Zheader.summaries.GZ.ND.Explained = dsum;
        Zheader.summaries.GZ.ND.pct = pdsum;
        Zheader.summaries.GZ.ND.pct_tsum = ppdsum;

        snr = sqrt(Zheader.total_scans);   % --=
        % --=
        save( save_file, 'tsum','psum','ppsum','dsum','pdsum','ppdsum','snr','GroupIndex','-append','-v7.3');

        %------------------------------------------------
        % creation of U P and V
        %------------------------------------------------

        U = [];
        P = [];
        V = [];
        Ph = [];
        PRh = [];         % --- no PR for H, but we still require the empty variable
        PR = [];
        Pn = [];

        % if ~isempty(pop)
        %   pop.setIterations( size(SubjectVector,2), pop.SECONDARY);
        % end;

        V = zeros( Zheader.total_columns * max( scan_information.frequencies, 1), nd );

        ep = 0;

        for SubjectNo=1:Zheader.num_subjects

            sid = subject_id_cmd( SubjectNo,scan_information );

            retrieve_subject_G_cmd( Gheader, Zheader, SubjectNo, 0, 'GA' );
            gg = sqrtm(pinv( G'*G ) );

            sp = ep + 1;
            ep = sp + size(gg,1)-1;

            eval ( [ 'Pn = snr * gg * u3(' num2str(sp) ':' num2str(ep) ',1:nd); ' ] );
            P = [ P; Pn ];

            U = [U; G * Pn ];

            B = [];
            for FrequencyNo=1:max(scan_information.frequencies, 1)
                ftag = frequency_tag_cmd(FrequencyNo,scan_information) ;
                B = [B load_subject_B_cmd( Gheader, SubjectNo,Zheader, ftag, GAtyp ) ];
            end

            Vn =  B' * u3(sp:ep,1:nd) / snr ;
            V = V + Vn;

            eval( [ 'V' num2str(SubjectNo) ' = Vn;' ] );
            save( save_file, ['V' num2str(SubjectNo) ], '-append', '-v7.3');
            eval( [ 'clear V' num2str(SubjectNo) ' ;' ] );

        end  % -- each subject

        clear B;

        % if ( ~isempty( funcs.memory_stats ) )
        %   funcs.memory_stats();
        % end;

        % allows us to use the same variable names in the following calculations as in the original code
        nr = Zheader.total_scans;
        nc = Zheader.total_columns;

        save( save_file, 'U', 'P*', 'V', 'nr', 'nc', 'nd', '-append', '-v7.3');
        clear U P

        for FrequencyNo = 1:max(scan_information.frequencies,1)
            start_col = (FrequencyNo - 1) * Zheader.total_columns + 1;
            end_col = start_col + Zheader.total_columns - 1;
            ftag = frequency_tag_cmd(FrequencyNo,scan_information);

            thisVR = V(start_col:end_col,:);
            eval( ['ep' ftag ' = calc_ext_Pos_Neg(thisVR);' ] );

        end

        % if ( ~isempty( funcs.clear_cache ) )
        %   funcs.clear_cache();
        % end;
        % funcs.memory_stats();

        % --- ep will already be calculated if not frequencied Meg data
        if scan_information.frequencies > 1 ep = calc_ext_Pos_Neg(V);  end

        VR = V;	% set the same vars used by rotated stats to the non rotated solutions

        nullset = zeros( 1, nd );

        cvariance_unrotated_tot = component_variance_cmd(Zheader, Aheader.model( Aheader.Aindex).sd(1), V );
        cvariance_rotated_tot = cvariance_unrotated_tot;

        save( save_file, 'VR', 'ep*', 'cvariance*' ,'-append', '-v7.3');
        clear V VR

        load( save_file, 'U');
        UR = U;
        save( save_file, 'UR', '-append', '-v7.3');

        text_file = fs_filename( 'txt', GAtyp, 'unrotated', noParms );
        text_file = [ 'output_' text_file ];

        fid = fopen( [component_directory text_file], 'w' );
        fprintf('\n\n' );
        text_file_header_cmd(Zheader, scan_information, nd, fid, log_fid, component_directory, text_file, Aheader.Aindex );
        pca_summary_cmd(Zheader,scan_information, Aheader.model( Aheader.Aindex).sd(1), 'GA', cvariance_unrotated_tot, fid );
        print_UR_coefficents( fid, corrcoef( UR ) );
        display_extremes_pos_neg(ep, cvariance_rotated_tot, Zheader.tsum, fid, 2, log_fid );
        if ( fid ) fclose( fid ); fid = 0; end

        pca_summary_cmd(Zheader,scan_information, Aheader.model( Aheader.Aindex).sd(1), 'GA', cvariance_unrotated_tot, 1 );

        clear U UR

        load( save_file, 'P');
        PR = P;
        save( save_file, 'PR*', '-append', '-v7.3');
        %
        % if ( ~isempty( funcs.memory_stats ) ) funcs.memory_stats(); end;

        %----------------------------------------
        % positive/negative betas of C for each component
        %----------------------------------------

        % --- clear up larger variables before calulating betas
        clear G P* thisVR Vn gg u3 d3 v3 C_Eigen*


        disp( 'Calculating Positive Betas. . .');

        %
        % if ( ~isempty( funcs.clear_cache ) )
        %   funcs.clear_cache(-1);    % -- force cache clearance priot to beta calc
        % end;
        % funcs.memory_stats();
        betas_c_pos = calc_c_betas_cmd(Zheader, scan_information,  save_file, Gheader, 1, 0 , GAtyp );

        disp( 'Calculating Negative Betas. . .' );
        %
        % if ( ~isempty( funcs.clear_cache ) )
        %   funcs.clear_cache(-1);    % -- force cache clearance priot to beta calc
        % end;
        % funcs.memory_stats();
        betas_c_neg = calc_c_betas_cmd(Zheader, scan_information,  save_file, Gheader, 0, 0, GAtyp );

        disp( 'Producing statistics output. . .' );

        save( save_file, 'betas_*', '-append', '-v7.3');


        % --- some older systems display a tendency to not open the file in append mode fast enough
        % --- and the subject variance is not written.
        fid = fopen( [component_directory text_file], 'a' );
        if ~fid>0
            pause(2);
        end
        % --- If the file is not open for append, wait 2 seconds and test again

        if (fid)

            Normalized_Z_Dir = Z_Directory_cmd(Zheader);

            fprintf( fid, '\n\nVariance accounted for in subject GA\n------------------------------------------\n' );

            for SubjectNo = 1:Zheader.num_subjects

                sid = subject_id_cmd( SubjectNo,scan_information );
                GCsd = load_subject_GC_var_cmd( Gheader, Zheader,  SubjectNo, 'subject_GCsd', GAtyp );
                tsum = load_subject_Z_var_cmd(Zheader, SubjectNo, 'tsum_subject' );

                if ~isempty( tsum ) && ~isempty( GCsd )
                    fprintf( fid,  '%s', char(scan_information.SubjectID(SubjectNo)) );
                    fprintf( fid, ['\t' constant_define( 'PREFERENCES', 'precision.log', '%.2f' ) '%%\n'] , (GCsd / tsum * 100) );
                end


            end

            fprintf( fid, '\n');
            fclose( fid );
        end

    end  % --- BBG file exists ---

end	% -- output directory exists

