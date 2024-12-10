function prepare_GMH_vars( funcs, H, Hheader, out_dir, pop )
global Zheader scan_information

if ( nargin < 2 )  pop = [];  end;
if ~strcmp( class(pop), 'cpca_progress' )
    pop = [];
end

Txt = 'GMH Module';

process_date = date;

% ----------------------------------------------
% --- GG gg Preparation   --- Gsegs/G_Sn  GG gg
% ----------------------------------------------
GGgg_processed = 0;
load( Zheader.Model.path,'Gheader' );

GMHfile = [out_dir 'GMH_vars.mat'];
initialize_non_existing_file(GMHfile);

if has_GMH_var( Hheader, 'GMH', 'GGgg_processed' )
    GGgg_processed = load_GMH_var( Hheader, 'GMH', 'GGgg_processed' );
end;

if ~GGgg_processed
    GGn = [];
    if ~isempty(pop)
        pop.setComment( 'GG/gg' );
        pop.setIterations(Zheader.num_subjects, pop.SECONDARY );
    end;
    
    for  SubjectNo = 1:Zheader.num_subjects
        sid = subject_id( SubjectNo );
        
        if ~isempty(pop)
            pop.setParticipant( SubjectNo, Zheader.num_subjects, sid );
            pop.increment();
        end;
        
        GMHSfile = [out_dir 'GMH_S' num2str(SubjectNo) '.mat'];
        if ~exist( GMHSfile, 'file' )
            initialize_mat_file( GMHSfile );
        end;
        
        Gfile = [Gheader.path_to_segs 'G_S' num2str(SubjectNo) '.mat'];
        load( Gfile, 'Gnorm' );
        GG = Gnorm' * Gnorm;
        if isempty(GGn) GGn = GG; else GGn = GGn + GG; end;
        
        save( GMHSfile, 'GG', '-append', '-v7.3' );
        
        funcs.memory_stats();
        
        if ~isempty(pop)
            pop.increment( pop.PRIMARY);
        end;
        
    end;
    
    if ~isempty(pop)
        pop.clearParticipant();
    end;
    
    GG = GGn;
    gg = sqrtm(pinv(GG));	% --=
    
    %    GMHfile = [out_dir 'GMH_vars.mat'];
    %    if ~exist( GMHfile, 'file' )
    %      initialize_mat_file( GMHfile );
    %    end;
    GGgg_processed = 1;
    
    save( GMHfile, 'GG', 'gg', 'GGgg_processed', '-append', '-v7.3' );
    
    funcs.memory_stats();
    
end;

% ----------------------------------------------
% --- preserve H in segments by frequency   Hsegs/GMH/H  H_C{n} {_freq}
% ----------------------------------------------

H_processed = 0;
if has_GMH_var( Hheader, 'GMH', 'H_processed' )
    H_processed = load_GMH_var( Hheader, 'GMH', 'H_processed' );
end;

if ~H_processed
    if ~isempty(pop)
        pop.setMessage( 'Preparing Segments of H' );
        pop.setComment( '' );
        pop.setIterations( max(scan_information.frequencies, 1) * Hheader.model(Hheader.Hindex).partitions.count, pop.SECONDARY );
    end;
    
    Hfile = [ out_dir 'H'];
    initialize_mat_file( Hfile );
    
    bar_max = max(scan_information.frequencies, 1) * Hheader.model(Hheader.Hindex).partitions.count;
    this_iter = 0;
    
    er = 0;
    for FrequencyNo=1:max(scan_information.frequencies, 1)
        ftag = frequency_tag(FrequencyNo) ;
        
        for columnno = 1:Hheader.model(Hheader.Hindex).partitions.count
            
            if ~isempty(pop)
                pop.increment( pop.SECONDARY);
            end;
            
            Hvar = [ 'H_C' num2str(columnno) ftag ];
            sr = er + 1;
            er = sr + Hheader.model(Hheader.Hindex).partitions.columns(columnno) - 1;
            eval( [ Hvar ' = H(sr:er,:);' ] );
            
            save( Hfile, Hvar, '-append', '-v7.3');
            eval( [ 'clear ' Hvar ] );
            
            if ( ~isempty( funcs.clear_cache ) )  funcs.clear_cache(pop); end; funcs.memory_stats();
            
            if ~isempty(pop)
                pop.increment( pop.PRIMARY);
            end;
            
        end;
        
    end;  % --- each frequency range
    
    H_processed = 1;
    save( GMHfile, 'H_processed', '-append', '-v7.3' );
    
end;


if Hheader.model(Hheader.Hindex).options.overwrite || Hheader.model(Hheader.Hindex).options.vars.Qg
    % ----------------------------------------------
    % --- Qg Preparation   --- Gsegs/G_Sn  Qg_S{n} (n = secondary subject no )
    % ----------------------------------------------
    if ~isempty(pop)
        pop.setMessage( 'Preparing Qg matrix' );
        pop.setComment( '' );
        pop.setIterations( Zheader.num_subjects * Zheader.num_subjects, pop.SECONDARY );
    end;
    
    start_subj = 1; % --=
    if ( scan_information.processing.GMH_model.applied.resume )
        start_subj = start_subj + scan_information.processing.GMH_model.applied.var_prep.Qg;
    end; % --= -- allow resumption from last successful applied subject
    
    if start_subj < Zheader.num_subjects | Zheader.num_subjects == 1
        
        for SubjectNo = 1:Zheader.num_subjects
            
            Qfile = [ 'Qg_S' num2str(SubjectNo) ];
            if ~exist([out_dir Qfile '.mat'], 'file')
                initialize_mat_file( [ out_dir Qfile] );
                
                sid = subject_id( SubjectNo );
                if ~isempty(pop)
                    pop.setParticipant( SubjectNo, Zheader.num_subjects, sid );
                end;
                
                Zx =  sum(Zheader.timeseries.subject(SubjectNo).run(:,1) );
                
                for ii = 1:Zheader.num_subjects
                    
                    sid = subject_id( ii );
                    if ~isempty(pop)
                        pop.setSecondaryParticipant( ii, Zheader.num_subjects, sid );
                        pop.increment();
                    end;
                    
                    Gfile = [Gheader.path_to_segs 'G_S' num2str(SubjectNo) '.mat'];
                    load( Gfile, 'Gnorm', 'GG' );
                    [ u d v] = svd( GG );
                    gg = u * sqrtm(pinv(d)) * v';
                    invGG = gg * gg;
                    Qvar = [ 'Qg_S' num2str(ii) ];
                    eval( [ Qvar ' = Gnorm * invGG * Gnorm'';' ] );
                    eval([ Qvar '= eye(' num2str(Zx) ') -' Qvar ';' ])
                    
                    save( [ out_dir Qfile], Qvar, '-append', '-v7.3' );
                    clear Qg*
                    
                    if ( ~isempty( funcs.clear_cache ) )  funcs.clear_cache(pop); end; funcs.memory_stats();
                    
                end;
                
                scan_information.processing.GMH_model.applied.var_prep.Qg = SubjectNo;
                save_headers();
                
                if ~isempty(pop)
                    pop.increment( pop.PRIMARY);
                end;
            end
        end; % --- each subject
        
    end; % --- resumption
    
end;  % -- prepare Qg matrices

if ~isempty(pop)
    pop.clearParticipant();
    pop.clearRun();
end;


% if Hheader.model(Hheader.Hindex).options.overwrite || Hheader.model(Hheader.Hindex).options.vars.Qh == 1
%     % ----------------------------------------------
%     % --- Qh Preparation   --- Gsegs/Qh
%     % ----------------------------------------------
%     if ~isempty(pop)
%         pop.setMessage( 'Preparing Qh matrix' );
%         pop.setComment( '' );
%     end;
%     
%     start_column = 1; % --=
%     if ( scan_information.processing.GMH_model.applied.resume )
%         start_column = start_column + scan_information.processing.GMH_model.applied.var_prep.Qh;
%     end; % --= -- allow resumption from last successful applied subject
%     
%     if start_column < Hheader.model(Hheader.Hindex).partitions.count
%         
%         if start_column == 1	% -- DO NOT CLEAR ON RESUME
%             if ~isempty(pop)
%                 pop.setComment( 'Initializing subject files . . .' );
%             end;
%             
%             for FrequencyNo=1:max(scan_information.frequencies, 1)
%                 ftag = frequency_tag(FrequencyNo) ;
%                 for primaryColumn = 1:Hheader.model(Hheader.Hindex).partitions.count
%                     out_Qh_file = [ out_dir filesep 'Qh_S' num2str(primaryColumn ) ftag ] ;
%                     initialize_mat_file( out_Qh_file);
%                 end;
%             end;
%         end;
%         
%         Ipn = eye(Hheader.model(Hheader.Hindex).partitions.width);
%         Ip0 = zeros(Hheader.model(Hheader.Hindex).partitions.width);
%         
%         bar_max = max(scan_information.frequencies, 1) * Hheader.model(Hheader.Hindex).partitions.count;
%         this_iter = 0;
%         Hfile = [ out_dir filesep 'H.mat'];
%         
%         if ~isempty(pop)
%             pop.setComment( '' );
%             pop.setIterations(( Hheader.model(Hheader.Hindex).partitions.count * max(scan_information.frequencies, 1) ) * Hheader.model(Hheader.Hindex).partitions.count * max(scan_information.frequencies, 1) ) ;
%         end;
%         
%         for primaryColumn = start_column:Hheader.model(Hheader.Hindex).partitions.count
%             
%             for FrequencyNo=1:max(scan_information.frequencies, 1)
%                 ftag = frequency_tag(FrequencyNo) ;
%                 
%                 %        for primaryColumn = 1:Hheader.model(Hheader.Hindex).partitions.count
%                 
%                 out_Qh_file = [out_dir filesep 'Qh_S' num2str(primaryColumn ) ftag] ;
%                 
%                 load( Hfile, [ 'H_C' num2str(primaryColumn) ftag ] );
%                 
%                 HCp = zeros( Hheader.model(Hheader.Hindex).partitions.width, size(H, 2) );
%                 
%                 eval( [ 'HCp(1:size(H_C' num2str(primaryColumn) ftag ',1),:) = H_C' num2str(primaryColumn) ftag ' ;'] );
%                 clear H_C*
%                 
%                 prime_var = [num2str(primaryColumn) ftag ];
%                 
%                 for SecondaryFreq = 1:max(scan_information.frequencies, 1)
%                     ftag2 = frequency_tag(SecondaryFreq) ;
%                     
%                     for secondaryColumn = 1:Hheader.model(Hheader.Hindex).partitions.count
%                         
%                         if ~isempty(pop)
%                             pop.setComment(  ['Primary: ' num2str(primaryColumn) '  Secondary: ' num2str(secondaryColumn) ' . . .'] );
%                             pop.increment();
%                         end;
%                         
%                         load( Hfile, [ 'H_C' num2str(secondaryColumn) ftag2 ] );
%                         
%                         HCs = zeros( Hheader.model(Hheader.Hindex).partitions.width, size(H, 2) );
%                         eval( [ 'HCs(1:size(H_C' num2str(secondaryColumn) ftag2 ',1),:) = H_C' num2str(secondaryColumn) ftag2 ' ;'] );
%                         clear H_C*
%                         
%                         secondary_var = [num2str(secondaryColumn) ftag2 ];
%                         if ( strcmp( prime_var, secondary_var ) )
%                             eval( [ 'Qh_S' num2str(secondaryColumn) ftag2 ' = Ipn - HCp * Hheader.hh * HCs'';'] );
%                         else
%                             eval( [ 'Qh_S' num2str(secondaryColumn) ftag2 ' = Ip0 - HCp * Hheader.hh * HCs'';'] );
%                         end;
%                         
%                         depth = ['1:' num2str( min( Hheader.model(Hheader.Hindex).partitions.width, Hheader.model(Hheader.Hindex).partitions.columns( primaryColumn) ) )];
%                         width = ['1:' num2str( min( Hheader.model(Hheader.Hindex).partitions.width, Hheader.model(Hheader.Hindex).partitions.columns( secondaryColumn) ) )];
%                         
%                         eval( [ 'Qh_S' num2str(secondaryColumn) ftag2 ' = Qh_S' num2str( secondaryColumn) ftag2 '( ' depth ',' width ');'] );
%                         
%                         save( [out_Qh_file '.mat'], ['Qh_S' num2str(secondaryColumn) ftag2 ], '-append', '-v7.3' );
%                         
%                         clear Qh_S*
%                         
%                         if ( ~isempty( funcs.clear_cache ) )  funcs.clear_cache(pop); end; funcs.memory_stats();
%                         %              funcs.memory_stats();
%                         
%                         if ~isempty(pop)
%                             pop.increment( pop.PRIMARY);
%                         end;
%                         
%                     end;  % -- secondary columns
%                     
%                     %            if ( ~isempty( funcs.clear_cache ) )  funcs.clear_cache(pop); end; funcs.memory_stats();
%                     
%                 end;  % -- secondary frequencies
%                 
%                 %      end;  % --- primary column ( swapped with frequency )
%                 
%             end;  % --- primary Frequency Range
%             
%             scan_information.processing.GMH_model.applied.var_prep.Qh = primaryColumn;
%             save_headers();
%             
%         end;  % --- primary column ( swapped with frequency )
%         
%     end;  % --- resumption
%     
% end; % --- end prepare Qh matrices



