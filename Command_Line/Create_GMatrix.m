function Create_GMatrix(base_dir,GH, filename )
% create G matrix based on onsets file and Zinfo.mat
% requirement of GH structure
%   GH.condition_name: list of condtion name
%   GH.model_type: mode type
%   GH.bins: number of bin
%   GH.TR: timing rate
%   GH.inScans: timging vector units
%   GH.normalize_me: normaliztion of G matrix

% GH = structure_define('gheader');
% % --------------------------------
% % --- conditon list
% % --------------------------------
% GH.condition_name = {'2_letters',	'4_letters', '6_letters','8_letters'};
% 
% % --------------------------------
% % --- type of model
% % --------------------------------
GH.model_type = 0; %  0 for FIR, 1 for HRF (HRF no longer to support)
% 
% % --------------------------------
% % --- Number of timebins
% % --------------------------------
% GH.bins = 8; %timeBins
% 
% % --------------------------------
% % --- Timing Rate
% % --------------------------------
% GH.TR = 3; %timingRate
% 
% % --------------------------------
% % --- Timing in Seconds or Scans
% % --------------------------------
% GH.inScans = 1; % 1 for Scans, 0 for seconds?
% 
% %------------------------------------
% % --- Normalize G matrix
% %-----------------------------------
% GH.normalize_me = 1; % 1 for yes, 0 for no

% 
% base_dir = '/Users/wsu/example_data_Multiple_Groups_Subjects_Runs';
% filename = 'timing_onsets.txt';
cd(base_dir);

% check the exiting of Z matrix
if exist([base_dir filesep 'ZInfo.mat'], 'file') ~= 2
    disp('List or Zinfo file does not exist');
    return
end
fullpath = [base_dir filesep 'ZInfo.mat'];
eval( [ 'load( ''' fullpath ''', ''Zheader'' ,''scan_information''); '] );

Zheader.conditions.Names = GH.condition_name;
GH.conditions = size(GH.condition_name, 2 ); %Number of conditions
GH.subject_encoded = zeros( 1, Zheader.num_subjects ) * GH.conditions;

[txt, onsetsfile, Zheader] = import_onsets_list_cmd(base_dir, filename, GH.model_type, Zheader,scan_information);
if ( ~isempty( txt ) )
    fprintf('File %s was created.\n', txt);
else
    disp('Failed to read onsets file! ');
    return;
end
save_Zinfo( Zheader, scan_information );

disp( 'Creating G . . .' );

onsvec = [];

GH.Import_File = onsetsfile; %GH.imported_from;
GH.source = onsetsfile; %GH.imported_from;

% --------------------------------
% --- path to segmented output
% --------------------------------
GH.path_to_segs = [ pwd filesep 'Gsegs' filesep];

duration = GH.bins * GH.TR;
fprintf('Duration of model: %d seconds. \n', duration);

disp( 'Condition Encoding . . .');

GH.subject_encoded = [];
if ( size(Zheader.conditions.encoded,1) > 0 )  % [1,1,1,1] [1,1,1,1],....
    for ii = 1:size(Zheader.conditions.encoded,1)
        GH.subject_encoded = [GH.subject_encoded sum( Zheader.conditions.encoded(ii).condition ) ];
    end
end


TR = 1;
if( ~GH.inScans )
    TR = GH.TR;
end


flags = eye( GH.bins, GH.bins );	% --- our inset is a (n,n) diagonal

x = isfolder( 'Gsegs' );
if ( x ~= 1 )  % --- the directory does not exist
    mkdir Gsegs;
end

gsWidth = GH.bins * GH.conditions;

timingTable = table('Size', [0, 4], 'VariableTypes',...
    {'string', 'string', 'string', 'string'},  ...
    'VariableNames', {'Subject', 'Run', 'Condtion', 'timing'});

tableindex=1;


fid = fopen ( constant_define( 'G_IMPORT_NAME'), 'r' );  % --=

all_onsets = [];

if ( fid )

    disp('Processing Event Onsets . . .');

    num_overrun = 0;
    max_overrun = 0;
    invalid_start_point = 0;

    grank = fopen( ['Gsegs' filesep 'G_Ranking.txt'], 'w' );
    fprintf( grank, 'Expected subject G rank: %d\n\n', gsWidth );

    subRank = [];
    % --=
    % --= for each subject
    for  SubjectNo = 1:Zheader.num_subjects

        sid = subject_id_cmd( SubjectNo,scan_information );
        fprintf('---subject: %s---\n', sid);

        gsw = sum( Zheader.conditions.encoded(SubjectNo).condition );

        %      GH.subject_encoded = [GH.subject_encoded gsw];
        gsWidth = gsw * GH.bins;

        Gnorm = [];
        initialize_mat_file( ['Gsegs' filesep 'G_S' num2str(SubjectNo) '.mat'] );
        eval( [ 'save( ''Gsegs' filesep 'G_S' num2str(SubjectNo) '.mat'', ''Gnorm'', ''-append'' )'] );

        Rstart = 0;  % --=

        % set( handles.lst_subjects, 'Value', SubjectNo ) ;


        % ------------------------------------------------------
        % --- produce the full subject G for all subject runs
        % --=   Graw = zeros( numscans_thisrun, gsWidth);
        % ------------------------------------------------------
        GG = zeros( gsWidth );
        Graw = [];

        % --=
        % --=   for each run
        %      for RunNo = 1:size( Zheader.timeseries.subject(SubjectNo).run , 1 )
        for RunNo = 1:Zheader.num_runs

            var = ['Gr' num2str(RunNo) ];
            evalin( 'base', [ var ' = [];'] );

            fprintf('RunNo %d/%d\n', RunNo, Zheader.num_runs  );

            if iscellstr(scan_information.SubjDir(SubjectNo, RunNo ) )
                % --=     Rstart = ( numscans_thisrun ) * ( RunNo - 1 );
                % --=
                if ( GH.model_type == constant_define( 'FIR_MODEL') )
                    eval( ['Gr' num2str(RunNo) ' = zeros( Zheader.timeseries.subject(SubjectNo).run(RunNo,1),' num2str(gsWidth) ');'] );
                    %          end;
                else
                    eval( ['Gr' num2str(RunNo) ' = [];'] );
                end

                % set( handles.lst_runs, 'Value', RunNo ) ;

                cond = 0;

                for condno = 1:GH.conditions

                    if ( Zheader.conditions.encoded(SubjectNo).condition(condno) )

                        cond = cond + 1;

                        if any( Zheader.conditions.subject(SubjectNo).Run(RunNo).conditions == condno )

                            fprintf('condition %s : %s\n', num2str(condno), char(Zheader.conditions.Names(condno)));

                            % --=  % read the next timing onsets line from input file
                            % --=
                            timings = next_entry( fid ); % --=
                            timingTable(tableindex,:) = {sid, ...%Subject
                                    determine_runID_cmd( SubjectNo, RunNo, scan_information ),... %Run
                                    char(Zheader.conditions.Names(condno)), ... %Condtion
                                    num2str(timings)}; %timings

                            tableindex = tableindex + 1;

                            if ( length(timings) > 0 ) % --=
                                onsets = [];
                                eval( [ 'onsets = [' timings '];' ] ); % --=
                                for ii = 1:size(onsets, 2 )
                                    onsvec = [onsvec onsets(ii) - floor(onsets(ii) )];
                                end

                                % no NOT!! divide HRF model by TR - that is done in algorithm called later
                                if( ~GH.inScans & GH.model_type == constant_define( 'FIR_MODEL') )
                                    onsets = onsets / TR;
                                    scan_hrf_offset = GH.displacement;   % seek HRF shape at n.n seconds after event
                                else
                                    scan_hrf_offset = GH.displacement/GH.TR;   % seek HRF shape at n.n seconds after event
                                end

                                if ( GH.model_type == constant_define( 'FIR_MODEL') )

                                    scan0 = sort(floor(onsets)); 		% --=   absolute scan 0 of event
                                    onsets = scan0 + 1; 				% --=   always start at scan after event - TODO  add adjust from scan0 by 1 and 2

                                    [x y] = size(onsets);		% --=

                                    cstart = ( (cond - 1) * GH.bins ) + 1;
                                    cend = cstart + GH.bins - 1;
                                    flagdepth = GH.bins;

                                    for ii = 1:y  % --=

                                        gMax = min( max(onsets(ii),1)+GH.bins-1, Zheader.total_scans );
                                        fMax = min( GH.bins, gMax-onsets(ii)+1);
                                        Gdepth = 0;
                                        eval( ['Gdepth = size( Gr' num2str(RunNo) ', 1 );' ] );

                                        if ( gMax > Gdepth)  	% --= scan depth issue - perhaps should be seconds
                                            num_overrun = num_overrun + 1;	% --=
                                            % --=           flagdepth = nbins - (gMax - size(Graw,1) );
                                            flagdepth = GH.bins - (gMax - Gdepth );
                                            gMax = Gdepth;		% --=
                                            % --=           max_overrun = max( flagdepth * TR, max_overrun );
                                            max_overrun = max( flagdepth*GH.TR, max_overrun );
                                        end  % --=

                                        % --=
                                        if ( max(onsets(ii),1) <= Gdepth )		% --=
                                            command = sprintf( 'Gr%d(%d:%d,%d:%d) = Gr%d(%d:%d,%d:%d) + flags(1:%d,:);\n', ... 	% --=
                                                RunNo, max(onsets(ii),1), gMax, cstart, cend, ...	% --=
                                                RunNo, max(onsets(ii),1), gMax, cstart, cend, flagdepth );	% --=
                                            eval( command );% --=
                                        else  % --=
                                            invalid_start_point = invalid_start_point + 1;  % --=
                                        end  % --=

                                    end  % --= each onset value ---

                                else  % -- model is HRF

                                    timings = next_entry( fid ); % --=
                                    t_dur = [];
                                    eval( [ 't_dur = [' timings '];' ] ); % --=

                                    if size(t_dur,2) == 1	% allow a single duration entry to be used as default
                                        t_durations = ones( size( onsets ) ) * t_dur;
                                    else
                                        t_durations = t_dur;
                                    end

                                    t_onsets = calculate_hrf_shape( [onsets' t_durations'], Zheader.timeseries.subject(SubjectNo).run(RunNo,1), TR );
                                    eval( [ 'Gr' num2str(RunNo) ' = [Gr' num2str(RunNo) ' t_onsets];' ] );

                                end  % --- model specific switch ---

                            end  % --- timing entry found ---

                        else
                            % - condition encoded in subject, but not this run - pad (
                            % watch split conditions
                            if ( GH.model_type == constant_define( 'HRF_MODEL' ) )
                                eval( [ 'Gr' num2str(RunNo) ' = [Gr' num2str(RunNo) ' zeros( size( Gr' num2str(RunNo) ' , 1), 1 ) ];' ] );
                            end
                        end % --- this condition encoded within the subject run

                    end % --- this condition encoded within the subject

                end  % --= each condition ---
                
                eval ( [ 'G_R' num2str(RunNo) ' = Gr' num2str(RunNo) ';' ] );	% --=
                eval ( [ 'G_R' num2str(RunNo) '(find(G_R' num2str(RunNo) ')) = 1;' ] );	% --=


                if GH.normalize_me

                    disp('Normalizing . . .');

                    mn = 0;
                    eval ( [ 'mn = mean(Gr' num2str(RunNo) ');' ] );	% --=
                    % --=
                    xx = 0;
                    eval ( [ 'xx = size(G_R' num2str(RunNo) ',2);' ] );
                    for jj = 1:xx	% --=
                        eval ( [ 'G_R' num2str(RunNo) '(:,jj) = G_R' num2str(RunNo) '(:,jj)-mn(1,jj);' ] );	% --=
                    end	% --=
                    % --=
                    st = 0;
                    eval ( [ 'st = samp_dev( G_R' num2str(RunNo) ' );' ] );	% --=
                    for jj = 1:xx	% --=
                        if ( st(1,jj) ~= 0 )  % -- avoid Nan in response to divide by 0 errors
                            eval ( [ 'G_R' num2str(RunNo) '(:,jj) = G_R' num2str(RunNo) '(:,jj) ./ st(1,jj);' ] );	% --=
                        end
                    end	% --=

                    % for non encoded conditions
                    mn = 0;
                    x = 0;
                    eval( [' mn = min( min( G_R' num2str(RunNo) ' ) );' ] );
                    eval( [' x = find( G_R' num2str(RunNo) ' == 0 );' ] );
                    if size( x, 1 ) > 0
                        eval( [' G_R' num2str(RunNo) '(x(:)) = mn;' ] );
                    end


                end

                disp('Finalizing . . .');

                eval ( [ 'Gnorm = [Gnorm; G_R' num2str(RunNo) ' ];' ] );
                eval ( [ 'Graw = [Graw; Gr' num2str(RunNo) ' ];' ] );

                eval( [ 'GG_R' num2str(RunNo) ' = G_R' num2str(RunNo) ''' * G_R' num2str(RunNo) ';' ] );
                eval( [ 'GG = GG + GG_R' num2str(RunNo) ';' ] );

                disp( 'Saving . . .');
                eval( [ 'save( ''Gsegs' filesep 'G_S' num2str(SubjectNo) '.mat'', ''G_R*'', ''Gr*'', ''Gn*'', ''-append'' )'] );
                clear G_* GG_*
                eval( ['clear Gr' num2str(RunNo) ] );

            end  % --= subject contains run ---
        end  % --= each run ---


        disp( 'Checking Rank . . .');
        this_rank = rank( Gnorm );
        this_rcond = rcond(Gnorm'*Gnorm);
        if ( ~this_rcond > (eps*1.1) )
            GH.illformed = 1;
            GH.subjects = [GH.subjects SubjectNo];

            sr = sprintf( 'Subject %3d: id: %s  rank: %d ', SubjectNo, subject_id( SubjectNo), this_rank );
            subRank = [subRank; {sr}];

        end

        disp( 'Calculating Projection . . .');

        try
            gg = sqrtm(pinv(GG));
            str = format_value(  sum( sum( gg ) ), '%.2f' );
        catch e
            x = e;
            str = 'ERR';
        end
        eval( [ 'save( ''Gsegs' filesep 'G_S' num2str(SubjectNo) '.mat'', ''GG'', ''gg'', ''Graw'', ''-append'' )'] );

        fprintf( grank, 'Subject %3d: rank: %d   rcond:%s    gg: %s\n', SubjectNo, this_rank, num2str(this_rcond), str );

        %toc
    end  % --= each subject ---
    % --=

    GH.mean_tr = mean( onsvec );

end  % --- onsets input file opened ---

if ( fid )  fclose( fid ); end
if ( grank )  fclose( grank ); end




if GH.illformed
    disp('We discovered a potential deficiency in one ore more of your subjects G matrices.');
end

Gheader = GH;
%save Gheader Gheader
save('Gheader.mat', "Gheader", "timingTable");

dt = date;
crt = 'created partitioned G matrix' ;
src = [ ' From: ' char(Gheader.source) ];
loc = [ 'Store: ' Gheader.path_to_segs ];
dim = [ 'Stats: Conditions: ' num2str(Gheader.conditions) '   Bins: ' num2str(Gheader.bins) ];
write_log( dt, crt, src, loc, dim );

if ( (invalid_start_point + num_overrun) > 0 )
    disp( 'Warning!  Onset Depth Exceeded\n');
    fprintf( '%d onsets encoded beyond the depth of the run : %d onsets started encoding beyond the depth of the run.  Perhaps the onsets are in seconds rather than scans.\n', num_overrun, invalid_start_point );
end

  g_okay = 0;

  if ( ~isempty( GH )  )

    % --------------------------------------------
    % --- G creation may have required redefinition of Runs and Conditions
    % --- contained in Zheader - reload to be safe
    % --------------------------------------------

    conds= Zheader.conditions;
    % Gheader = GH;
    Zheader.conditions.sp = condition_start_columns_cmd(Zheader,  Gheader.conditions, Gheader.bins );

    Gheader.subjects = conds.subject;
    Gheader.subject_encoded = [];
    if ( size(conds.encoded,1) > 0 )
      for ii = 1:size(conds.encoded,1)
        Gheader.subject_encoded = [Gheader.subject_encoded sum( conds.encoded(ii).condition ) ];
      end
    end

    p = [pwd() filesep];
    eval( [ 'save( ''' p 'Gheader.mat'', ''Gheader'', ''-append'');' ] );
	 
    Zheader.Model = who_stats( p, 'Gheader.mat', 'Gheader' );
    Zheader.Model.hdr_exists = Zheader.Model.mat_exists;

    if Zheader.Model.hdr_exists == 1
      Zheader.Model.mat_x = Zheader.total_scans;
      Zheader.Model.mat_y = sum( Gheader.subject_encoded) * Gheader.bins;

    end

    g_okay = ( Zheader.Model.mat_exists || Zheader.Model.hdr_exists ) && (Zheader.Model.mat_x == Zheader.total_scans) && Gheader.conditions > 0;

    scan_information.processing.model.parameters.model_type = Gheader.model_type;
    scan_information.processing.model.parameters.conditions = Gheader.conditions;
    scan_information.processing.model.parameters.bins = Gheader.bins;
    scan_information.processing.model.parameters.TR = Gheader.TR;
    scan_information.processing.model.parameters.inScans = Gheader.inScans;
    scan_information.processing.model.parameters.condition_name = Gheader.condition_name;

    scan_information.processing.model.parameters.plotting  = struct( 'global', '', 'extended', '', 'use_extended', 0 );
    scan_information.processing.model.parameters.plotting.global = struct( 'line', '', 'marker', '', 'label', '' );
    scan_information.processing.model.parameters.plotting.global.line = struct( 'style', 2, 'size', 1 );
    scan_information.processing.model.parameters.plotting.global.marker = struct( 'style', 1, 'size', 1, 'color', [], 'edge', 0, 'edgecolor', [] );
    scan_information.processing.model.parameters.plotting.global.label = struct( 'y_axis', 'Mean Predictor Weights', 'x_axis', 'Time', 'title', '', 'legend', 1 );
    scan_information.processing.model.parameters.plotting.extended = struct ( 'conditions', Gheader.conditions, 'plotting', '' );

    scan_information.processing.model.process.components = 2;
    scan_information.processing.H_model.process.components = 2;
    scan_information.processing.PD_model.process.components = 2;

   
    Zheader=calc_gaz_extents_cmd(Zheader);  

    scan_information.processing.model.apply = g_okay;
    scan_information.processing.model.process.extract_g = 0;  %scan_information.processing.model.process.apply_g;
    scan_information.processing.model.process.rotate_g = 0;  %scan_information.processing.model.process.apply_g;
    scan_information.processing.model.applied.apply_g = 0;
    scan_information.processing.model.applied.extract_g = 0;
    scan_information.processing.model.applied.rotate_g = 0;

    a_okay = 0;
    if ( Zheader.Contrast.mat_exists )  % change of G requires A application
      a_okay =  g_okay && Zheader.Contrast.mat_exists && ((Zheader.Contrast.mat_x * Zheader.num_subjects) == Zheader.Model.mat_y );
    end

    scan_information.processing.model.process.apply_ga = 0;  %a_okay;
    scan_information.processing.model.process.extract_ga = 0;  %a_okay;
    scan_information.processing.model.process.apply_gaa = 0;  %a_okay;
    scan_information.processing.model.applied.apply_ga = 0;
    scan_information.processing.model.applied.extract_ga = 0;
    scan_information.processing.model.applied.apply_gaa = 0;

    save_headers_cmd(Zheader, scan_information)

  end

end