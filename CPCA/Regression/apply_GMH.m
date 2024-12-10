function SoS = apply_GMH( funcs, Gheader, pop )
global Zheader scan_information
% ----------------------------------------------
% ---  GMH is calculate by an expansion of G * M * H
% ---
% --- M rows are conditions/bins per subject, so expansion
% --- into individual runs is impossible, though
% --- resulting matrix may be preserved in that fashion
% ---
% --- This requires a test of available memory, and determining if
% --- full expansion will be possible.
% ---
% --- Additionally, Linux systems will most likely require
% --- automated cache clearing enabled before proceeding.
% ----------------------------------------------

if ( nargin < 3 )
    pop = [];
end
if ~strcmp( class(pop), 'cpca_progress' )
    pop = [];
end

SoS = 0;

fprintf( ' - Regressing  G''*Z*H ');
load( Zheader.Limits.path );
[h_id out_dir ] = H_path_spec( Hheader, 'GMH' );

Hheader.model( Hheader.Hindex).path_to_segs.GMH = out_dir;

Txt = 'GMH Module';
if ~isempty(pop)
    pop.setMessage( 'Preparing GMH calculations . . .' );
end

x = exist( out_dir, 'dir' );
if ( x ~= 7 )  % the directory does not exist - cannot proceed without HZ
    mkdir(out_dir);
end

% ----------------------------------------------
% ---  GMH vertical columnization is based on the square matrix
% ---  required by the number of voxels in the complete scan
% ---
% --- This is not the same number of vertical columns derived for the Z/G process
% ----------------------------------------------


Gheader.path_to_segs = os_path( Gheader.path_to_segs );
Gheader.GZheader.path_to_segs = os_path( Gheader.GZheader.path_to_segs );

% for ease of uniformity, scan_information.processing.GMH_model.options will be copied into Hheader
Hheader.model(Hheader.Hindex).options = scan_information.processing.GMH_model.options;
Hheader = reset_Hheader_for_new_algorithm(Hheader);
H = load_H_matrix( Hheader, 1 );
HH = H' * H;
hh = pinv(HH);

Hheader.HH = HH;
Hheader.hh = hh;

min_iters = Zheader.num_subjects + max(scan_information.frequencies, 1) * Hheader.model(Hheader.Hindex).partitions.count ;
Qg_iters = 0;
Qh_iters = 0;
ZH_iters = 0;
GMH_iters = 0;
BH_iters = 0;
GC_iters = 0;

%  if Hheader.options.overwrite || ( Hheader.options.vars.Qg == 1 && Hheader.options.exists.Qg == 0 )
if Hheader.model(Hheader.Hindex).options.overwrite || Hheader.model(Hheader.Hindex).options.vars.Qg
    Qg_iters = Zheader.num_subjects * Zheader.num_subjects;
end

if Hheader.model(Hheader.Hindex).options.overwrite || Hheader.model(Hheader.Hindex).options.vars.Qh == 1
    Qh_iters = ( Hheader.model(Hheader.Hindex).partitions.count * max(scan_information.frequencies, 1) ) * ...
        Hheader.model(Hheader.Hindex).partitions.count * max(scan_information.frequencies, 1);
end

if Hheader.model(Hheader.Hindex).options.overwrite || Hheader.model(Hheader.Hindex).options.vars.ZH == 1
    ZH_iters = Zheader.active_runs * max(1, scan_information.frequencies);
end

if Hheader.model(Hheader.Hindex).options.GMH.regress
    GMH_iters = Zheader.active_runs * max(1, scan_information.frequencies)  ;
end

if Hheader.model(Hheader.Hindex).options.GMH.write
    GMH_iters = GMH_iters + Zheader.active_runs ;
end

if Hheader.model(Hheader.Hindex).options.BH.regress
    BH_iters = Zheader.num_subjects ;
end

if Hheader.model(Hheader.Hindex).options.BH.write
    BH_iters = BH_iters + Zheader.active_runs ;
end

if Hheader.model(Hheader.Hindex).options.GC.regress
    % --- calculating HC
    GC_iters = Zheader.num_subjects * max(scan_information.frequencies, 1) * Hheader.model(Hheader.Hindex).partitions.count;
    % --- calculating C
    GC_iters = GC_iters + Zheader.num_subjects * max(scan_information.frequencies, 1) * Hheader.model(Hheader.Hindex).partitions.count * max(scan_information.frequencies, 1) * Hheader.model(Hheader.Hindex).partitions.count;
    % --- Creating bb
    GC_iters = GC_iters + Zheader.num_subjects ^ 2 - 1;
end


if Hheader.model(Hheader.Hindex).options.GC.write
    GC_iters = GC_iters + Zheader.num_subjects * max(scan_information.frequencies, 1) * ( Zheader.num_runs * 2 ) ;
end


if ~isempty(pop)
    pop.setMessage( 'Preparing GMH Variables' );
    pop.setIterations( min_iters + Qg_iters + Qh_iters + ZH_iters + GMH_iters + BH_iters + GC_iters, pop.PRIMARY );
end


prepare_GMH_vars( funcs, H, Hheader, out_dir,  pop );


if Hheader.model(Hheader.Hindex).options.overwrite || Hheader.model(Hheader.Hindex).options.vars.ZH
    create_ZH( funcs, H, Hheader, out_dir, pop );
end

HH_processed = 0;
if has_GMH_var( Hheader, 'GMH', 'HH_processed' )
    HH_processed = load_GMH_var( Hheader, 'GMH', 'HH_processed' );
end

if ~HH_processed
    GMH_file = [ out_dir 'GMH_vars.mat' ];
    initialize_non_existing_file( GMH_file );
    
    [u, d, v] = svd(Hheader.HH, 'econ');
    gmhh = u*sqrtm(pinv(d))*v';
    
    save( GMH_file, 'gmhh', 'H', 'HH', 'hh', '-append', '-v7.3') ;
    
    for participant = 1:Zheader.num_subjects
        GMHSfile = [out_dir filesep '/GMH_S' num2str(participant) '.mat'];
        initialize_non_existing_file( GMHSfile );
        
        load( [ Gheader.path_to_segs 'G_S' num2str(participant) '.mat'], 'GG');
        [u, d, v] = svd(GG, 'econ');
        gmhgg = u*sqrtm(pinv(d))*v';
        save( GMHSfile, 'GG', 'gmhgg', '-append', '-v7.3');
        if ( ~isempty( funcs.clear_cache ) )
            funcs.clear_cache( -1 );
        end
    end
    
    HH_processed = 1;
    save( GMH_file, 'HH_processed', '-append', '-v7.3');
end

% calculate GMH

if Hheader.model(Hheader.Hindex).options.GMH.regress || Hheader.model(Hheader.Hindex).options.GMH.write
    
    if ~isempty(pop)
        pop.setProcess( 'GMH::GMH Processing');
    end
    
    if Hheader.model(Hheader.Hindex).options.GMH.regress
        regress_GMH( funcs, Gheader, H, Hheader, out_dir, pop );
    end
    
    SSQ = GMH_sum_of_squares( Hheader, 'GMH' );
    Hheader.model(Hheader.Hindex).sum_diagonal.GMH = SSQ.sd;
    save( Zheader.Limits.path, 'Hheader' );
    
    save( [out_dir 'GMH_vars.mat'], 'SSQ', '-v7.3', '-append' );
    
    GMH_SD_Report( Hheader, 'GMH' );
    
end

if Hheader.model(Hheader.Hindex).options.BH.regress || Hheader.model(Hheader.Hindex).options.BH.write
    
    if ~isempty(pop)
        pop.setProcess( 'GMH::BH [HnotG] Processing');
    end
    
    if Hheader.model(Hheader.Hindex).options.BH.regress
        regress_BH( funcs, Gheader, H, Hheader, out_dir, pop );
    end
    
    BHsd = create_BH( funcs, Gheader, H, Hheader, out_dir, pop );
    SSQ = GMH_sum_of_squares( Hheader, 'HnotG' );
    Hheader.model(Hheader.Hindex).sum_diagonal.BH = SSQ.sd;
    save( Zheader.Limits.path, 'Hheader' );
    
    GMH_SD_Report( Hheader, 'HnotG' );
    
end

if Hheader.model(Hheader.Hindex).options.GC.write || Hheader.model(Hheader.Hindex).options.GC.regress
    
    if ~isempty(pop)
        pop.setProcess( 'GMH::GC [GnotH] Processing');
    end
    Hheader.model(Hheader.Hindex).partitions.count =1;
    if Hheader.model(Hheader.Hindex).options.GC.regress
        regress_GC( funcs, Gheader, H, Hheader, out_dir, pop );
    end
    
    GCsd = create_GC( funcs, Gheader, H, Hheader, out_dir, pop );
    
    SSQ = GMH_sum_of_squares( Hheader, 'GnotH' );
    Hheader.model(Hheader.Hindex).sum_diagonal.GC = SSQ.sd;
    save( Zheader.Limits.path, 'Hheader' );
    
    initialize_non_existing_file( [out_dir 'GnotH_vars.mat'] );
    save( [out_dir 'GnotH_vars.mat'], 'SSQ', '-v7.3', '-append' );
    GMH_SD_Report( Hheader, 'GnotH' );
    
end
if  Hheader.model(Hheader.Hindex).options.E.apply
    
    create_E( funcs, Gheader, Hheader, H, out_dir, pop );
    
end
SoS = 1;




function create_ZH( funcs, H, Hheader, out_dir, pop )
global Zheader scan_information

Txt = 'GMH Module';
if ~isempty(pop)
    pop.setMessage( 'Creating ZH . . .' );
    pop.setIterations( Zheader.active_runs * max(1, scan_information.frequencies), pop.SECONDARY );
end

Normalized_Z_Dir = Z_Directory();
Normalized_Z_Dir = os_path( Normalized_Z_Dir );

out_file_name = 'ZH';

out_dir = strrep( [out_dir filesep], [filesep filesep], filesep );
in_dir = [Normalized_Z_Dir 'Z' filesep];

for participant=1:Zheader.num_subjects
    
    sid = subject_id( participant );
    if ~isempty(pop)
        pop.setParticipant( participant, Zheader.num_subjects, sid );
    end
    
    out_H_file = [ out_dir out_file_name '_S' num2str(participant) ];
    
    initialize_mat_file( out_H_file );
    
    for RunNo=1:Zheader.num_runs
        
        if isEncodedRun( participant, RunNo )
            if ~isempty(pop)
                pop.setRun( RunNo, Zheader.num_runs );
            end
            
            %------------------------------------------------
            % load in the normalized Z/E segment
            %------------------------------------------------
            
            r = Zheader.timeseries.subject(participant).run(RunNo,1);
            eval( [ 'ZH_R' num2str(RunNo) ' = zeros(r, size(H,2) );' ] );
            
            end_col = 0;
            
            for FrequencyNo=1:max(scan_information.frequencies, 1)
                
                ftag = frequency_tag(FrequencyNo) ;
                start_col = end_col + 1;
                end_col = start_col + Zheader.total_columns - 1;
                
                if ~isempty(pop)
                    pop.increment( pop.SECONDARY);
                end
                
                Z = load_subject_run_Z( participant, RunNo, ftag );
                eval( [ 'ZH_R' num2str(RunNo) ftag ' = Z * H(start_col:end_col,:);' ] );
                eval( [ 'ZH_R' num2str(RunNo) ' = ZH_R' num2str(RunNo) ' + ZH_R' num2str(RunNo) ftag ';' ] );
                save( out_H_file, ['ZH_R' num2str(RunNo) ftag], '-append', '-v7.3');
                %eval( [ 'clear ZH_R' num2str(RunNo) ftag ';' ] );
                
                if ( ~isempty( funcs.clear_cache ) )
                    funcs.clear_cache(-1);
                end
                funcs.memory_stats();
                
                if ~isempty(pop)
                    pop.increment( pop.PRIMARY);
                end
                
            end  % --- each frequency range
            
            if ( ~isempty( funcs.clear_cache ) )
                funcs.clear_cache(-1);
            end
            funcs.memory_stats();
            
            save( out_H_file, ['ZH_R' num2str(RunNo)], '-append', '-v7.3');
            
            clear  ZH_R*;
            
            if ( ~isempty( funcs.memory_stats ) )
                funcs.memory_stats();
            end
            
        end % --- run is encoded
    end % --- each run
    
end  % --- each participant

if ~isempty(pop)
    pop.clearParticipant();
    pop.clearRun();
end



function regress_GMH( funcs, Gheader, H, Hheader, out_dir, pop)
global Zheader scan_information

SSQ.sd = 0;
SSQ.Fsd = zeros( 1, max(1, Zheader.num_Z_arrays) );
SSQ.Subject = struct( ...
    'sd', zeros(Zheader.num_runs, 1 ), ...
    'Fsd', zeros( Zheader.num_runs, max(1, Zheader.num_Z_arrays) ) );

HH = H' * H;
[ u d v] = svd( HH );
hh = u * sqrt(inv(d)) * v';
invHH = hh * hh;

Txt = 'GMH Module';
if ~isempty(pop)
    pop.setMessage( 'Regressing for GMH . . .' );
    pop.setIterations( Zheader.num_subjects * Zheader.num_runs * max(1, scan_information.frequencies), pop.SECONDARY );
end

start_subj = 1; % --=
if ( scan_information.processing.GMH_model.applied.resume )
    start_subj = start_subj + scan_information.processing.GMH_model.applied.regression.GMH;
end % --= -- allow resumption from last successful applied subject

GMHfile = [ out_dir 'GMH_vars.mat'];

if start_subj <= Zheader.num_subjects
    
    M = [];
    %    B = [];
    GM = [];
    sumDiag = 0;
    
    %    GMHfile = [ out_dir 'GMH_vars.mat'];
    load( GMHfile, 'gmhh' );
    
    for participant = start_subj:Zheader.num_subjects
        
        SSQ.sd = SSQ.sd * 0;
        SSQ.Fsd = SSQ.Fsd .* 0;
        SSQ.Subject.sd = SSQ.Subject.sd .* 0;
        SSQ.Subject.Fsd = SSQ.Subject.Fsd .* 0;
        
        sid = subject_id( participant );
        if ~isempty(pop)
            pop.setParticipant( participant, Zheader.num_subjects, sid );
            pop.setRun( 1, Zheader.num_runs );
        end
        
        if ( ~isempty( funcs.clear_cache ) )
            funcs.clear_cache(-1);
        end
        funcs.memory_stats();
        
        
        GMHSfile = [out_dir 'GMH_S' num2str(participant) '.mat'];
        GMHSvars = [out_dir 'GMH_S' num2str(participant) '_vars.mat'];
        initialize_non_existing_file( GMHSvars );
        
        load( GMHSfile, 'GG', 'gmhgg');
        [u, d, v] = svd( GG );
        gg = u * sqrtm(pinv(d)) * v';
        invGG = gg * gg;
        
        GZ = zeros(Gheader.conditions*Gheader.bins, Zheader.total_columns * max(scan_information.frequencies, 1) );
        
        Mn = [];
        Bn = [];
        
        retrieve_subject_G( Gheader, participant );
        
        ec = 0;
        for FrequencyNo=1:max(scan_information.frequencies, 1)
            sc = ec + 1;
            ec = sc + Zheader.total_columns - 1;
            
            ftag = frequency_tag(FrequencyNo) ;
            
            for RunNo = 1:Zheader.num_runs
                
                if isEncodedRun( participant, RunNo )
                    if ~isempty(pop)
                        pop.setRun( RunNo, Zheader.num_runs );
                    end
                    
                    if ( ~isempty( funcs.clear_cache ) )
                        funcs.clear_cache(-1);
                    end
                    funcs.memory_stats();
                    
                    if ~isempty(pop)
                        pop.increment( pop.SECONDARY);
                    end
                    
                    load( [ Gheader.GZheader.path_to_segs 'GZ_S' num2str(participant) ftag '.mat'], ['GZ_R' num2str(RunNo) ftag]);
                    eval ( [ 'GZ(:,' num2str(sc) ':' num2str(ec) ') = GZ(:,' num2str(sc) ':' num2str(ec) ') + GZ_R' num2str(RunNo) ftag ';'] );
                    
                    eval ( [ 'clear GZ_R' num2str(RunNo) ftag ';'] );
                    
                    if ( ~isempty( funcs.clear_cache ) )
                        funcs.clear_cache(-1);
                    end
                    funcs.memory_stats();
                    
                    if ~isempty(pop)
                        pop.increment( pop.PRIMARY);
                    end
                    
                end  % --- run is encoded
                
            end % --- each subject run
        end  % --- each frequency
        
        M = invGG * GZ * H * invHH;
        C = gg * GZ * H * hh;
        GM = G * M;
        
        save( GMHSfile, 'M', 'GM', 'C', '-append', '-v7.3');
        
        clear G M GZ;
        
        if ( ~isempty( funcs.clear_cache ) )
            funcs.clear_cache(-1);
        end
        funcs.memory_stats();
        
        er = 0;
        mx = 0;
        max_rows = 1000;
        if size( GM,1 ) > 1000
            max_rows = 500;
        end
        
        for RunNo = 1:Zheader.num_runs
            
            if isEncodedRun( participant, RunNo )
                mx = mx + Zheader.timeseries.subject(participant).run( RunNo, 1 );
                
                while er < mx
                    sr = er + 1;
                    er = min( sr + max_rows - 1, mx );
                    
                    ec = 0;
                    for FrequencyNo=1:max(scan_information.frequencies, 1)
                        sc = ec + 1;
                        ec = sc + Zheader.total_columns - 1;
                        
                        GMH = GM(sr:er,:) * H(sc:ec,:)';
                        sd = sum(diag( GMH * GMH' ));
                        
                        SSQ.sd = SSQ.sd + sd;
                        SSQ.Fsd( FrequencyNo ) = SSQ.Fsd( FrequencyNo ) + sd;
                        SSQ.Subject.sd(RunNo) = SSQ.Subject.sd(RunNo) + sd;
                        SSQ.Subject.Fsd(RunNo, FrequencyNo ) = SSQ.Subject.Fsd(RunNo, FrequencyNo ) + sd;
                        
                        if ( ~isempty( funcs.clear_cache ) )
                            funcs.clear_cache(-1);
                        end
                        funcs.memory_stats();
                        
                    end
                end
            end
        end
        
        save( GMHSvars, 'SSQ', '-append', '-v7.3');
        clear M GM GMH;
        
        %      B = [B; C];
        if ( ~isempty( funcs.memory_stats ) )
            funcs.memory_stats();
        end
        
    end  % -- each subject
    
    BBw = sum(Gheader.subject_encoded) * Gheader.bins;
    B = zeros( BBw, size(hh,2) );
    
    er = 0;
    for participant = 1:Zheader.num_subjects
        retrieve_subject_GMH_C( Hheader, participant );
        
        sr = er + 1;
        er = sr + size(C,1) - 1;
        B(sr:er,:) = C;
        
        clear C;
    end
    
    BB = B' * B;
    save( GMHfile, 'B', 'BB', '-append', '-v7.3');
    %    save( GMHfile, 'M', 'B', 'BB', '-append', '-v7.3');
    
    C_Eigenvalues = sort(eig( BB ), 1, 'descend');
    C_Eigenvalues = C_Eigenvalues(1:size(BB,2),:);
    
    GMHfile = [ out_dir 'GMH_vars.mat'];
    %    initialize_mat_file( GMHfile );
    save( GMHfile, 'C_Eigenvalues', '-append', '-v7.3');
    
    fprintf( '[done]\n');
    
end  % resumption




function regress_BH( funcs, Gheader, H, Hheader, out_dir, pop )
global Zheader scan_information

fprintf( ' - regressing B / HnotG ');

% --- In = eye(m);				% --- Zd x Zd
% --- Ip = eye(n);				% --- Zw x Zw
% ---
% --- Q = In - G * pinv(G'*G) * G';		% --- Zd x Zd
% --- B = Q * ZH * pinv( HH );			% --- Zd x nd  ( Zh = [Z1*H; Z2*h; ... Zn * H] )
% --- HnotG = B * H';				% --- Zd x Zw

%  eval( ['load( ''' out_dir filesep 'GMH.mat'');'] );
this_pctg = 0;

HH = H' * H;
[u, d, v] = svd( HH );
hh = u * sqrt(inv(d)) * v';
invHH = hh * hh;

%  Zdir = Z_Directory();
in_Zdir = [ 'Hsegs' filesep 'GMH' filesep];

%   B = [];
AA = zeros( size( H, 2 ) );

initialize_mat_file( [out_dir 'HnotG'] );

if ~isempty(pop)
    pop.setMessage( 'Regressing GMH::HnotG . . .' );
    pop.setIterations( Zheader.active_runs * 2, pop.SECONDARY);
end

aa = zeros(  size( H, 2 ) );
for participant = 1:Zheader.num_subjects
    
    B_S = [];
    
    initialize_mat_file( [out_dir '/HnotG_S' num2str(participant)] );
    
    sid = subject_id( participant );
    
    retrieve_subject_G( Gheader, participant );
    GG = G'*G;
    [ u d v ] = svd( GG );
    gg = u * sqrt(inv(d)) * v';
    invGG = gg * gg;
    
    Qg = load_subject_BH_var( Hheader, participant, ['Qg_S' num2str(participant)], 'GMH', 'Qg' );
    ZH = [];
    
    for runno = 1:Zheader.num_runs
        
        if isEncodedRun( participant, runno )
            sr = ( (runno - 1) * Zheader.timeseries.subject(participant).run( runno, 1 ) ) + 1;
            er = sr + Zheader.timeseries.subject(participant).run( runno, 1 ) - 1;
            
            ZHS = [];
            for FrequencyNo=1:max(scan_information.frequencies, 1)
                ftag = frequency_tag( FrequencyNo );
                
                ZHF = load_subject_BH_var( Hheader, participant, ['ZH_R' num2str(runno) ftag ], 'GMH', 'ZH' );
                eval( [ 'B_R' num2str(runno) ftag ' = Qg(sr:er,sr:er) * ZHF * invHH;' ] );
                save( [ out_dir 'HnotG_S' num2str(participant) '.mat'], ['B_R' num2str(runno) ftag ], '-append', '-v7.3');
                
                if FrequencyNo == 1
                    ZHS = ZHF;
                    eval( [ 'B_R' num2str(runno) ' = B_R' num2str(runno) ftag ';' ] );
                else
                    ZHS = ZHS + ZHF;
                    eval( [ 'B_R' num2str(runno) ' = B_R' num2str(runno) ' + B_R' num2str(runno) ftag ';' ] );
                end
                
                %eval( ['clear B_R' num2str(runno) ftag ';' ] );
                
            end
            
            ZH = [ZH; ZHS];
            clear ZHF ZHS
            
            save( [ out_dir 'HnotG_S' num2str(participant) '.mat'], ['B_R' num2str(runno) ], '-append', '-v7.3');
            eval( [ 'B_S = [B_S; B_R' num2str(runno) '];' ] );
            
        end % --- run is sencoded
    end
    
    
    GZ = G' * ZH;
    
    aa = aa + ZH' * ZH - GZ' * invGG * GZ;
    AA = AA + aa;
    
    save( [ out_dir 'HnotG_S' num2str(participant) '.mat'], 'B_S', 'GZ', 'aa', '-append', '-v7.3');
    clear B_S;
    
    if ( ~isempty( funcs.clear_cache ) )  funcs.clear_cache(-1); end
    funcs.memory_stats();
    
    if ~isempty(pop)
        pop.increment( pop.PRIMARY );
    end
    
end

% --- we need a full B matrix to allow for beta calculation
B = [];
for participant = 1:Zheader.num_subjects
    B_S = load_subject_BH_var( Hheader, participant, 'B_S', 'BH' );
    B = [B; B_S];
end
save( [out_dir 'HnotG.mat'], 'B', '-append', '-v7.3');
clear B B_S

BB = hh * aa * hh;

C_Eigenvalues = sort(eig( BB ), 1, 'descend');
C_Eigenvalues = C_Eigenvalues(1:size(BB,2),:);

initialize_mat_file( [out_dir 'HnotG_vars.mat'] );
save( [out_dir 'HnotG_vars.mat'], 'BB', 'AA', 'C_Eigenvalues', '-append', '-v7.3');


function BHsd = create_BH( funcs, Gheader, H, Hheader, out_dir, pop )
global Zheader scan_information

fprintf( ' - creating B / HnotG output matrix');

% ----------------------------------------------
% --- BH Creation
% ----------------------------------------------

if ~isempty(pop)
    pop.setMessage( 'calculating GMH::HnotG variance . . .' );
    pop.setIterations( Zheader.active_runs * max(scan_information.frequencies, 1) );
end

SSQ.sd = 0;
SSQ.Fsd = zeros( 1, max(1, Zheader.num_Z_arrays) );
SSQ.Subject = struct( ...
    'sd', zeros(Zheader.num_runs, 1 ), ...
    'Fsd', zeros( Zheader.num_runs, max(1, Zheader.num_Z_arrays) ) );


BHsd = 0;
for participant = 1:Zheader.num_subjects
    
    SSQ.sd = SSQ.sd * 0;
    SSQ.Fsd = SSQ.Fsd .* 0;
    SSQ.Subject.sd = SSQ.Subject.sd .* 0;
    SSQ.Subject.Fsd = SSQ.Subject.Fsd .* 0;
    
    sid = subject_id( participant );
    if ~isempty(pop)
        pop.setParticipant(  participant, Zheader.num_subjects, sid );
    end
    
    for runno = 1:Zheader.num_runs
        
        if isEncodedRun( participant, runno )
            if ~isempty(pop)
                pop.setRun(  runno, Zheader.num_runs );
            end
            
            for FrequencyNo = 1:max(scan_information.frequencies, 1)
                ftag = frequency_tag(FrequencyNo) ;
                sc = (( FrequencyNo -1 ) * Zheader.total_columns) + 1;
                ec = sc + Zheader.total_columns - 1;
                eval( ['load( ''' out_dir filesep 'HnotG_S' num2str(participant) '.mat'', ''B_R' num2str(runno) ''')'; ] );
                
                sd = 0;
                eval( [ 'BH_R' num2str(runno) ftag ' = B_R' num2str(runno) ' * H(sc:ec,:)''; ' ] );
                eval( ['sd = sum(diag( BH_R' num2str(runno) ftag ' * BH_R' num2str(runno) ftag ''') );'] );
                BHsd = BHsd + sd;
                
                % --- TODO: NO FREQUENCY RANGE SPLIT YET
                SSQ.sd = SSQ.sd + sd;
                SSQ.Fsd( 1 ) = SSQ.Fsd( 1 ) + sd;
                SSQ.Subject.sd(runno) = SSQ.Subject.sd(runno) + sd;
                SSQ.Subject.Fsd(runno, FrequencyNo ) = SSQ.Subject.Fsd(runno, FrequencyNo ) + sd;
                
                
                if Hheader.model(Hheader.Hindex).options.BH.write
                    ec = 0;
                    
                    for columnno = 1:Hheader.model(Hheader.Hindex).partitions.count
                        sc = ec + 1;
                        ec = sc + Hheader.model(Hheader.Hindex).partitions.columns(columnno) - 1;
                        matrix_extents = [':,' num2str(sc) ':' num2str(ec) ];
                        
                        eval( [ 'BH_R' num2str(runno) '_C' num2str(columnno) ftag ' = BH_R' num2str(runno) ftag '( ' matrix_extents ');' ] );
                        eval( ['save( ''' out_dir filesep 'HnotG_S' num2str(participant) '.mat'', ''BH_R' num2str(runno) '_C' num2str(columnno) ftag ''', ''-append'', ''-v7.3'')'; ] );
                        eval( ['clear BH_R' num2str(runno) '_C' num2str(columnno) ftag ';' ] );
                        
                    end  % -- each horizontal column
                    
                    if ( ~isempty( funcs.clear_cache ) )  funcs.clear_cache(-1); end; funcs.memory_stats();
                    
                end  % --- each frequency
                
            end  % --- write BH variable
            
            if ~isempty(pop)
                pop.increment( pop.SECONDARY );
                pop.increment( pop.PRIMARY );
            end
            
        end  % --- run is encoded
    end  % --- each run
    
    eval( ['save( ''' out_dir filesep 'HnotG_S' num2str(participant) '.mat'', ''SSQ'', ''-append'', ''-v7.3'')'; ] );
    
end  % --- each participant

%  Hheader.model(Hheader.Hindex).sum_diagonal_GMH_BH = BHsd;
%  save Hheader Hheader;

fprintf( '[done]\n');


function regress_GC( funcs, Gheader, H, Hheader, out_dir, pop)
global Zheader scan_information

% =====
% --- In = eye(m);				% --- Zd x Zd
% --- Ip = eye(n);				% --- Zw x Zw
% ---
% --- Qhx = Ip - H * pinv( HH) * H';		% --- Zw x Zw
% --- Ca = pinv(GG) * GZ * Qhx;		% --- nbins*nconds*nsubs x Zw
% --- GnotH = G * Ca;				% --- Zd x Zw
% ---
% --- x = H * pinv( HH) * H';
% ---   x         23621x23621            4463613128  double
% ---
% --- x = pinv( HH) * H';
% ---   x         3x23621            566904  double
% ---
% --- x = H * pinv( HH);
% ---   x         23621x3             566904  double
% =====

fprintf( ' - creating C / GnotH ');
Txt = 'GMH Module';
if ~isempty(pop)
    pop.setMessage( 'calculating HC ');
    pop.setIterations(Zheader.num_subjects * max(scan_information.frequencies, 1) * Hheader.model(Hheader.Hindex).partitions.count, pop.SECONDARY)
end



% ----------------------------------------------
% --- HC{n} Preparation
% ----------------------------------------------

start_subj = 1; % --=
if ( scan_information.processing.GMH_model.applied.resume )
    start_subj = start_subj + scan_information.processing.GMH_model.applied.regression.GC.HC;
end % --= -- allow resumption from last successful applied subject

if start_subj <= Zheader.num_subjects
    
    bar_max = Zheader.num_subjects * Zheader.num_runs * max(scan_information.frequencies, 1);
    this_iter = 0;
    
    sumDiag = 0;
    
    er = 0;
    for participant = start_subj:Zheader.num_subjects
        
        sid = subject_id( participant );
        if ~isempty(pop)
            pop.setParticipant( participant, Zheader.num_subjects, sid );
        end
        
        out_file = [out_dir 'HC_S' num2str(participant) ] ;
        initialize_mat_file( out_file);
        
        sr = er + 1;
        er = sr + Gheader.bins * Gheader.conditions - 1; - 1;
        
        for FrequencyNo=1:max(scan_information.frequencies, 1)
            ftag = frequency_tag(FrequencyNo) ;
            fdsp = strrep( ftag, '_', ' ');
            
            retrieve_subject_G( Gheader, participant );
            eval( ['load( ''' Gheader.GZheader.path_to_segs 'GC_S' num2str(participant) ftag '.mat'', ''C_S' num2str(participant) ftag ''') ;' ] );
            eval( ['HC' ftag ' = C_S' num2str(participant) ';']);
            eval( ['save(''' out_file '.mat'', ''HC' ftag ''', ''-append'', ''-v7.3'');' ] );
            
            if ~isempty(pop)
                pop.increment( pop.PRIMARY);
            end
            
        end  % --- each frequency range
        save_headers();
        
    end % --- each participant
end % --- resumption

if ~isempty(pop)
    pop.clearParticipant();
end


% ----------------------------------------------
% --- C{n} Creation
% ----------------------------------------------


start_subj = 1; % --=
start_freq = 1;
if ( scan_information.processing.GMH_model.applied.resume )
    start_subj = start_subj + scan_information.processing.GMH_model.applied.regression.GC.C.last_subject;
    start_freq = min( start_freq + scan_information.processing.GMH_model.applied.regression.GC.C.last_freq, max(scan_information.frequencies, 1) );
end % --= -- allow resumption from last successful applied subject

if start_subj <= Zheader.num_subjects
    
    if ~isempty(pop)
        pop.setMessage( 'calculating C' );
        %      pop.setIterations(Zheader.num_subjects * max(scan_information.frequencies, 1) * Hheader.model(Hheader.Hindex).partitions.count * max(scan_information.frequencies, 1) * Hheader.model(Hheader.Hindex).partitions.count)
    end
    
    
    bar_max = Zheader.num_subjects * max(scan_information.frequencies, 1) * Hheader.model(Hheader.Hindex).partitions.count;
    this_iter = (start_subj-1) * max(scan_information.frequencies, 1) * Hheader.model(Hheader.Hindex).partitions.count;
    
    for participant = start_subj:Zheader.num_subjects
        
        sid = subject_id( participant );
        if ~isempty(pop)
            pop.setParticipant( participant, Zheader.num_subjects, sid );
            pop.setIterations(Hheader.model(Hheader.Hindex).partitions.count * max(scan_information.frequencies, 1) * Hheader.model(Hheader.Hindex).partitions.count)
        end
        
        out_file = [out_dir filesep 'GnotH_C_S' num2str(participant) ] ;
        if start_freq == 1
            initialize_mat_file( out_file);
        end
        
        for PrimaryFreq = start_freq:max(scan_information.frequencies, 1)
            ftagP = frequency_tag(PrimaryFreq) ;
            fdspP = strrep( ftagP, '_', ' ');
            
            for PrimaryCol = 1:Hheader.model(Hheader.Hindex).partitions.count
                
                this_iter = this_iter + 1;
                
                HCn = [];
                
                for FrequencyNo=1:max(scan_information.frequencies, 1)
                    eval( ['load(''' out_dir filesep 'HC_S' num2str(participant) '.mat'', ''HC' ftag ''');' ] );
                    
                    ftag = frequency_tag(FrequencyNo) ;
                    fdsp = strrep( ftag, '_', ' ');
                    eval( ['HCn = [HCn HC' ftag '];' ] );
                    eval( ['clear HC' ftag ';' ] );
                    
                    
                    if ( ~isempty( funcs.clear_cache ) )
                        funcs.clear_cache(-1);
                    end
                    funcs.memory_stats();
                    
                end
                
                % HCn = [ HC_S1_C1_10Hz HC_S1_C2_10Hz HC_S1_C3_10Hz HC_S1_C4_10Hz HC_S1_C5_10Hz HC_S1_C6_10Hz HC_S1_C1_20Hz HC_S1_C2_20Hz HC_S1_C3_20Hz HC_S1_C4_20Hz HC_S1_C5_20Hz HC_S1_C6_20Hz ];
                %  HCn       32x6000            1536000  double
                
                orth_H = (HCn*H*inv(H'*H))*H';
                
                eval( [ 'C_C' num2str(PrimaryCol) ftagP ' = HCn - (orth_H);' ] );
                eval( [ 'save( ''' out_file '.mat'', ''C_C' num2str(PrimaryCol) ftagP ''', ''-append'', ''-v7.3'');' ] );
                
                eval( [ 'clear C_C' num2str(PrimaryCol) ftagP ' HCn Qhn;' ] );
                
            end  % --- each horizontal column of primary frequency
            
            if ( ~isempty( funcs.clear_cache ) )
                funcs.clear_cache(-1);
            end
            funcs.memory_stats();
            
            scan_information.processing.GMH_model.applied.regression.GC.C.last_freq = PrimaryFreq;
            save_headers();
            
        end % --- each primary frequency
        
        if ( ~isempty( funcs.clear_cache ) )
            funcs.clear_cache(-1);
        end
        funcs.memory_stats();
        
        scan_information.processing.GMH_model.applied.regression.GC.C.last_subject = participant;
        save_headers();
        
    end  % -- each participant
    
end % --- resumption

if ~isempty(pop)
    pop.setMessage( 'Creating AA . . .' );
    pop.clearParticipant();
    pop.clearRun();
    pop.clearFrequency();
end

if ( ~isempty( funcs.memory_stats ) ) funcs.memory_stats(); end

out_file = [out_dir filesep 'GnotH' ] ;
initialize_mat_file( out_file);

%  save( [ out_file '.mat'], 'sumDiag', '-append', '-v7.3');

snr = sqrt(Zheader.total_scans); % --=
save( [ out_file '.mat'], 'snr', '-append', '-v7.3' );

if ( ~isempty( funcs.clear_cache ) )
    funcs.clear_cache(-1);
end
funcs.memory_stats();

% fprintf( '\n\n************************< Calculating AA >***************************\n\n');
%
% fprintf( '********************< Current Workspace consumption >********************\n');
% whos
%
%   m = array_sizes( [sum( Gheader.subject_encoded * Gheader.bins ) sum( Gheader.subject_encoded * Gheader.bins )] );
%   x = check_memory();
% fprintf( '********************<  AA Requirement >********************\n');
% fprintf( '  AA: %s\n',  strtrim( [ m.mem_display  m.sz_display] ) );
% fprintf( '  total: %.2f    used: %.2f    free: %.2f    cached:  %.2f\n', x.user.total/1000, x.user.used/1000, x.user.free/1000, x.user.cache/1000);


%  AA = gg * bb * gg;
ftag = '';
AA = zeros(  sum( Gheader.subject_encoded * Gheader.bins ) );
% x = check_memory();
% fprintf( '  total: %.2f    used: %.2f    free: %.2f    cached:  %.2f\n\n', x.user.total/1000, x.user.used/1000, x.user.free/1000, x.user.cache/1000);

invHH = inv( H' * H);       % --- revise per frequency when recoding

prim_end_row = 0;
prim_end_col = 0;
for primary_subj = 1:Zheader.num_subjects
    
    sid = subject_id( primary_subj );
    if ~isempty(pop)
        pop.setParticipant( primary_subj, Zheader.num_subjects, sid );
    end
    
    % x = check_memory();
    % fprintf( '\n********************<  loading participant GZ (%s)  >********************\n', sid );
    % fprintf( ' current total: %.2f    used: %.2f    free: %.2f    cached:  %.2f\n', x.user.total/1000, x.user.used/1000, x.user.free/1000, x.user.cache/1000);
    
    retrieve_full_subject_GZ( Gheader, primary_subj, 'Primary' );
    % m = array_sizes( size( Primary ) );
    % fprintf( '       Primary: %s\n',  strtrim( [ m.mem_display  m.sz_display] ) );
    
    load( [ Gheader.path_to_segs 'G_S' num2str(primary_subj) '.mat'], 'GG' );
    % m = array_sizes( size( GG ) );
    % fprintf( '            GG: %s\n',  strtrim( [ m.mem_display  m.sz_display] ) );
    [u, d, v] = svd( GG );
    ggP = v * inv(sqrt(d)) * u';
    clear GG u d v
    % x = check_memory();
    % fprintf( '    post total: %.2f    used: %.2f    free: %.2f    cached:  %.2f\n', x.user.total/1000, x.user.used/1000, x.user.free/1000, x.user.cache/1000);
    
    if ( ~isempty( funcs.clear_cache ) )
        funcs.clear_cache(-1);
    end
    funcs.memory_stats();
    
    prim_start_row = prim_end_row + 1;
    prim_end_row = prim_start_row + size(ggP, 1) - 1;
    
    prim_start_col = prim_end_col + 1;
    prim_end_col = prim_start_col + size(ggP, 1) - 1;
    
    % fprintf( '********************<  Calculating AA segments  >********************\n' );
    AA( prim_start_row:prim_end_row, prim_start_col:prim_end_col ) = ...
        ggP * ( (Primary * Primary') - (Primary * H * invHH * (Primary * H)' ) ) * ggP;
    
    % x = check_memory();
    % fprintf( '       Primary: %.2f    used: %.2f    free: %.2f    cached:  %.2f\n', x.user.total/1000, x.user.used/1000, x.user.free/1000, x.user.cache/1000);
    
    if ( ~isempty( funcs.clear_cache ) )
        funcs.clear_cache(-1);
    end
    funcs.memory_stats();
    % x = check_memory();
    % fprintf( ' cache cleared: %.2f    used: %.2f    free: %.2f    cached:  %.2f\n', x.user.total/1000, x.user.used/1000, x.user.free/1000, x.user.cache/1000);
    
    if primary_subj < Zheader.num_subjects
        
        sec_end_row = prim_end_row;
        sec_end_col = prim_end_col;
        
        for secondary_subj = primary_subj+1:Zheader.num_subjects
            
            % sid = subject_id( secondary_subj );
            % fprintf( '********************<  loading secondary GZ (%s)  >********************\n', sid );
            
            retrieve_full_subject_GZ( Gheader, secondary_subj, 'Secondary' );
            % m = array_sizes( size( Secondary ) );
            % fprintf( '     Secondary: %s\n',  strtrim( [ m.mem_display  m.sz_display] ) );
            load( [ Gheader.path_to_segs 'G_S' num2str(secondary_subj) '.mat'], 'GG' );
            % m = array_sizes( size( GG ) );
            % fprintf( '            GG: %s\n',  strtrim( [ m.mem_display  m.sz_display] ) );
            [u, d, v] = svd( GG );
            ggS = v * inv(sqrt(d)) * u';
            clear GG u d v
            % x = check_memory();
            % fprintf( '     Secondary: %.2f    used: %.2f    free: %.2f    cached:  %.2f\n', x.user.total/1000, x.user.used/1000, x.user.free/1000, x.user.cache/1000);
            if ( ~isempty( funcs.clear_cache ) )
                funcs.clear_cache(-1);
            end
            funcs.memory_stats();
            % x = check_memory();
            % fprintf( ' cache cleared: %.2f    used: %.2f    free: %.2f    cached:  %.2f\n', x.user.total/1000, x.user.used/1000, x.user.free/1000, x.user.cache/1000);
            
            sec_start_row = sec_end_row + 1;
            sec_end_row = sec_start_row + size(ggP, 1) - 1;
            
            sec_start_col = sec_end_col + 1;
            sec_end_col = sec_start_col + size(ggS, 1) - 1;
            
            % fprintf( '********************<  Calculating AA segments  >********************\n' );
            AA( prim_start_row:prim_end_row, sec_start_col:sec_end_col ) = ...
                ggP * ( (Primary * Secondary') - (Primary * H * invHH * (Secondary * H)' ) ) * ggP;
            
            AA( sec_start_row:sec_end_row, prim_start_col:prim_end_col ) = ...
                ggS * ( (Secondary * Primary') - (Secondary * H * invHH * (Primary * H)' ) ) * ggS;
            
            if ( ~isempty( funcs.clear_cache ) )
                funcs.clear_cache(-1);
            end
            funcs.memory_stats();
            % x = check_memory();
            % fprintf( ' cache cleared: %.2f    used: %.2f    free: %.2f    cached:  %.2f\n', x.user.total/1000, x.user.used/1000, x.user.free/1000, x.user.cache/1000);
            
        end
    end
end

save( [out_file '.mat'], 'AA', '-append', '-v7.3' );

if ~isempty(pop)
    pop.setMessage( 'Determining Eigenvalues . . .' );
    pop.clearParticipant();
    pop.clearRun();
    pop.setPong( 1 );
end

m = array_sizes( size(AA) );
x = check_memory();

%   if x.user.free / 1000 < m.gigabytes * 2.1   % --- allow a 10% threshold for now
% --- not enough memory to perform internal eigs function
% --- use the D from svd over 15 components
[~, d, ~]=svds(AA, 40); % --=

C_Eigenvalues = diag(d);
%   else
%
%     C_Eigenvalues = sort(eig( AA ), 1, 'descend'); % --=
%
%   end

save( [out_file '.mat'], 'C_Eigenvalues', '-append', '-v7.3' );

clear AA ;


if ~isempty(pop)
    pop.setPong( 0 );
    pop.clearParticipant();
    pop.clearRun();
end

function GCsd = create_GC( funcs, Gheader, H, Hheader, out_dir, pop)
global Zheader scan_information

GCsd = 0;
Txt = 'GMH Process';
if ~isempty(pop)
    pop.setMessage( 'creating GnotH. . .');
    pop.setIterations( Zheader.num_subjects * max(scan_information.frequencies, 1) * ( Zheader.num_runs * 2 ) );
end

SSQ.sd = 0;
SSQ.Fsd = zeros( 1, max(1, Zheader.num_Z_arrays) );
SSQ.Subject = struct( ...
    'sd', zeros(Zheader.num_runs, 1 ), ...
    'Fsd', zeros( Zheader.num_runs, max(1, Zheader.num_Z_arrays) ) );

for participant = 1:Zheader.num_subjects
    
    SSQ.sd = SSQ.sd * 0;
    SSQ.Fsd = SSQ.Fsd .* 0;
    SSQ.Subject.sd = SSQ.Subject.sd .* 0;
    SSQ.Subject.Fsd = SSQ.Subject.Fsd .* 0;
    
    out_file = [out_dir 'GnotH_S' num2str(participant) ] ;
    out_vars = [out_dir 'GnotH_S' num2str(participant) '_vars' ] ;
    initialize_mat_file( out_file);
    initialize_mat_file( out_vars);
    
    sid = subject_id( participant );
    if ~isempty(pop)
        pop.setParticipant( participant, Zheader.num_subjects, sid );
    end
    
    retrieve_subject_G( Gheader, participant );
    
    %ec = 0;
    for FrequencyNo=1:max(scan_information.frequencies, 1)
        ftag = frequency_tag(FrequencyNo) ;
        %sc = ec + 1;
        %ec = sc + Zheader.total_columns - 1;
        
        c_rows = sum(Zheader.conditions.encoded(participant).condition ) * Gheader.bins;
        eval( [ 'C_S' num2str(participant) ftag ' = zeros( c_rows, Zheader.total_columns );' ] );
        
        C = [];
        for columnno = 1:Hheader.model(Hheader.Hindex).partitions.count
            eval ( [ 'load( ''' out_dir 'GnotH_C_S' num2str(participant) '.mat'', ''C_C' num2str(columnno) ftag ''');'] );
            eval ( [ 'C = [C C_C' num2str(columnno) ftag '];'] );
            eval ( [ 'clear C_C' num2str(columnno) ftag ';'] );
        end
        
        er = 0;
        mx = 0;
        max_rows = 1000;
        if size( G,1 ) > 100
            max_rows = 50;
        end
        
        for RunNo = 1:Zheader.num_runs
            
            if isEncodedRun( participant, RunNo )
                mx = mx + Zheader.timeseries.subject(participant).run( RunNo, 1 );
                
                while er < mx
                    sr = er + 1;
                    er = min( sr + max_rows - 1, mx );
                    
                    GC = G(sr:er,:) * C;
                    sd = sum(diag( GC * GC' ));
                    
                    SSQ.sd = SSQ.sd + sd;
                    SSQ.Fsd( FrequencyNo ) = SSQ.Fsd( FrequencyNo ) + sd;
                    SSQ.Subject.sd(RunNo) = SSQ.Subject.sd(RunNo) + sd;
                    SSQ.Subject.Fsd(RunNo, FrequencyNo ) = SSQ.Subject.Fsd(RunNo, FrequencyNo ) + sd;
                    
                    if ( ~isempty( funcs.clear_cache ) )
                        funcs.clear_cache(pop);
                    end
                    funcs.memory_stats();
                    
                end
            end  % --- run is encoded
        end
        
    end  % --- each frequency
    
    save( [out_vars '.mat'], 'SSQ', '-append', '-v7.3');
    
end  % --- each participant

fprintf( '[done]\n');
if ~isempty(pop)
    pop.clearParticipant();
    pop.clearRun();
end



function create_E( funcs, Gheader, Hheader, H, out_dir, pop )
global Zheader scan_information
% --- Z = GMH + BH + GC + E
% --- E = Z - (GMH + BH + GC)
% ---
% --- As the partition width between Z and GMH may not be the same
% --- each full run calculation will be performed per frequency
% ---

Normalized_Z_Dir = Z_Directory();
Normalized_Z_Dir = os_path( Normalized_Z_Dir );

Txt = 'GMH Process';
if ~isempty(pop)
    pop.setMessage( 'creating E. . .');
    pop.setIterations( Zheader.num_subjects * max(scan_information.frequencies, 1) * Zheader.num_runs  );
end

for participant = 1:Zheader.num_subjects
    
    sid = subject_id( participant );
    if ~isempty(pop)
        pop.setParticipant( participant, Zheader.num_subjects, sid );
    end
    
    initialize_mat_file( [out_dir filesep 'E_S' num2str(participant)] );
    
    for runno = 1:Zheader.num_runs
        
        if isEncodedRun( participant, runno )
            if ~isempty(pop)
                pop.setRun( runno, Zheader.num_runs );
            end
            
            for FrequencyNo=1:max(scan_information.frequencies, 1)
                ftag = frequency_tag(FrequencyNo) ;
                
                Z = zeros( Zheader.timeseries.subject(participant).run(runno, 1 ), Zheader.total_columns );
                
                ec = 0;
                for columnno = 1:Zheader.partitions.count
                    sc = ec + 1;
                    ec = sc + Zheader.partitions.columns(columnno) - 1;
                    
                    eval ( [ 'load( ''' Normalized_Z_Dir 'Z' filesep 'Z' num2str(participant) '.mat'', ''Z_R' num2str(runno) '_C' num2str(columnno) ftag ''');'] );
                    
                    eval( [ 'Z(:,' num2str(sc) ':' num2str(ec) ') =  Z_R' num2str(runno) '_C' num2str(columnno) ftag ';' ] ) ;
                    eval( [ 'clear Z_R' num2str(runno) '_C' num2str(columnno) ftag ';' ] ) ;
                end
                
                if ~isempty(pop)
                    pop.increment();
                end
                
                ec = 0;
                for columnno = 1:Hheader.model(Hheader.Hindex).partitions.count
                    sc = ec + 1;
                    ec = sc + Hheader.model(Hheader.Hindex).partitions.columns(columnno) - 1;
                    matrix_extents = [':,' num2str(sc) ':' num2str(ec) ];
                    
                    eval( ['load( ''' out_dir filesep 'HnotG_S' num2str(participant) '.mat'', ''BH_R' num2str(runno) '_C' num2str(columnno) ftag ''')'; ] );
                    eval( ['load( ''' out_dir filesep 'GMH_S' num2str(participant) '.mat'', ''GM' ftag ''')'; ] );
                    eval( ['load( ''' out_dir filesep 'GnotH_C_S' num2str(participant) '.mat'', ' ' ''C_C' num2str(columnno) ftag ''')'; ] );
                    load( [ Gheader.path_to_segs 'G_S' num2str(participant) '.mat'], ['G_R' num2str(runno)]);
                    GMH = GM*H';
                    eval(['GC = ' 'G_R' num2str(runno) '*C_C' num2str(columnno) ';']);
                    eval( [ 'E_R' num2str(runno) '_C' num2str(columnno) ftag ' = Z(' matrix_extents ') - GMH' ftag ' - BH_R' num2str(runno) '_C' num2str(columnno) ftag ' - GC' ftag ';' ] );
                    eval( ['save( ''' out_dir filesep 'E_S' num2str(participant) '.mat'', ''E_R' num2str(runno) '_C' num2str(columnno) ftag ''', ''-append'', ''-v7.3'')'; ] );
                    
                    eval( ['clear E_R' num2str(runno) '_C' num2str(columnno) ftag ' BH_R' num2str(runno) '_C' num2str(columnno) ftag ' GMH_R' num2str(runno) '_C' num2str(columnno) ftag ' - GC_R' num2str(runno) '_C' num2str(columnno) ftag ';' ] );
                    
                end
                
                %        clear Z GMH_R*;
                if ( ~isempty( funcs.clear_cache ) )
                    funcs.clear_cache(pop);
                end
                funcs.memory_stats();
                
            end
            
        end  % -- run is encoded
    end
    
end


if ~isempty(pop)
    pop.clearParticipant();
    pop.clearRun();
end

fprintf( '[done]\n');
function Hheader = reset_Hheader_for_new_algorithm(Hheader)
Hheader.model(Hheader.Hindex).partitions.count = 1;
Hheader.model(Hheader.Hindex).partitions.width = Hheader.model(Hheader.Hindex).size(1);
Hheader.model(Hheader.Hindex).partitions.columns = Hheader.model(Hheader.Hindex).size(1);
Hheader.model(Hheader.Hindex).partitions.last = Hheader.model(Hheader.Hindex).size(1);



