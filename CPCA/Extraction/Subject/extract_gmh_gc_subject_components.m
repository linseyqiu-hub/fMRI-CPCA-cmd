function abort_proc = extract_gmh_gc_subject_components( funcs, nd, log_fid, pop )
% apply the G model to the normalized Z data
% creates the G_unrotated.mat data set for G extraction and imaging
%
% note: G and GA processing was separated to a allow for unique G as well as GA if desired

global Zheader scan_information process_information 

  if ( nargin < 3 )  log_fid = 0;  end;
  if ( nargin < 4 )  pop = [];  end;
  if ~strcmp( class(pop), 'cpca_progress' )
    pop = []; 
  end

  abort_proc = 0;

  load( Zheader.Limits.path);

  [H_ID H_Segments] = H_path_spec( Hheader, 'GMH' );
  noParms = struct( 'model', 'H', 'mode', 'GMH', 'htype', 'GC', 'hindex',  H_ID );

  [has_dir component_directory] = fs_create_path( 'unrotated', 'output', nd, 0, noParms );
  component_directory = [ pwd filesep component_directory ];

  if ( has_dir )

    Txt = ['Extracting ' num2str(nd) ' components from GMH:GC'];
    if ~isempty(pop)
      pop.setMessages( Txt, 'Calculating Subject VRs', '' ); 
      pop.setIterations( Zheader.num_subjects * max(scan_information.frequencies, 1) * Zheader.total_columns );
    end;

    load( Zheader.Model.path, 'Gheader');

    save_file = fs_filename( 'mat', 'GC', 'unrotated', noParms );
    save_file = [component_directory save_file];

    %----------------------------------------
    % Alternate VR - 1 image each for subject/component
    %----------------------------------------

    noParms = struct( 'model', 'H', 'mode', 'GMH', 'method', 'unrotated', 'hindex',  H_ID );
    [ok outdir] = fs_create_path( 'subject', 'output', nd, 0, noParms );
    outdir = [pwd filesep outdir];

    eval ( [ 'load( ''' save_file ''', ''UR'', ''nr'')' ] );

    num_comps = size(UR,2);
    UR_From = 0;
    UR_To = 0;

    VR_ss_cov = [];
    VR_ssm_cov = [];
    VR_ss_coef = [];
    VR_ssm_coef = [];

    bar_max = Zheader.num_subjects * max(scan_information.frequencies, 1) * Zheader.num_runs * max(Zheader.partitions.count, 1);
    this_iter = 0;

    out_mat = fs_filename( 'alt_vr', 'GC', 'unrotated', [] );
    initialize_mat_file( [outdir out_mat] );
    
    H = load_H_matrix( Hheader, 1 );

    for SubjectNo = 1:Zheader.num_subjects

      sParms = struct( 'model', 'H', 'mode', 'GMH', 'method', 'unrotated');
      sParms.subject = SubjectNo;
      sid = subject_id( SubjectNo );
      if ~isempty(pop)
        pop.setParticipant( SubjectNo, Zheader.num_subjects, sid );
      end;

      if ( ~isempty( funcs.clear_cache ) )  funcs.clear_cache();  end; funcs.memory_stats();

      eval( ['alt_VR_S' num2str(SubjectNo) ' = [];'] );
      eval( ['alt_VR_coeff_S' num2str(SubjectNo) ' = [];'] );

      retrieve_subject_G( Gheader, SubjectNo );
      
      for FrequencyNo=1:max(scan_information.frequencies, 1)

        ftag = frequency_tag(FrequencyNo) ;
        fdsp = strrep( ftag, '_', ' ');

        if scan_information.frequencies > 1
          if ~isempty(pop)
            pop.setFrequency( FrequencyNo, scan_information.frequencies );
          end;
        end;

        retrieve_subject_GMH_GC( Hheader, SubjectNo, ftag);
% %        for column = 1:Hheader.model(Header.Hindex).partitions.count
% 
%           GC = [];
% 
%           for RunNo = 1:Zheader.num_runs
% 
%             if iscellstr( scan_information.SubjDir(SubjectNo, RunNo ) )
% 
%               if ~isempty(pop)
%                 pop.setRun( RunNo, Zheader.num_runs );
%               end;
% 
%               GCn = [];
%               for column = 1:Hheader.model(Hheader.Hindex).partitions.count
% 
%                 eval ( [ 'load( ''' H_Segments 'GC_S' num2str(SubjectNo) '.mat'', ''GC_R' num2str(RunNo) '_C' num2str(column) ftag ''' );'] );
%  
%                 eval( ['GCn = [GCn GC_R' num2str(RunNo) '_C' num2str(column) ftag '];'] );
%                 eval( ['clear GC_R' num2str(RunNo) '_C' num2str(column) ftag ';'] );
% 
%               end;  % --- each column
% 
%               GC = [GC; GCn];
%               clear GCn;
% 
%             end % --- subject contains run
% 
%           end % --- each run
% 
          if ~isempty(pop)
            pop.clearRun();
          end;
          
          if ( ~isempty( funcs.clear_cache ) )  funcs.clear_cache();  end; funcs.memory_stats();

          UR_From = Zheader.timeseries.subject(SubjectNo).run(1,2);
          UR_To = UR_From + size(GC,1) - 1;

          % nomalize subject UR
          URn = cpca_normalize( UR(UR_From:UR_To,:) );
          iter = 0;

          ss_cov = zeros( 1, num_comps );
          ss_coef = zeros( 1, num_comps );
          for ( vox = 1:size(GC,2) )

            if ~isempty(pop)
              pop.increment();
            end;

            vl = cov([URn GC(:,vox)] );
            eval( ['alt_VR_S' num2str(SubjectNo) ' = [alt_VR_S' num2str(SubjectNo) ' vl(size(vl,1),1:num_comps)''];' ] );
            ss_cov = ss_cov + vl(size(vl,1),1:num_comps).*vl(size(vl,1),1:num_comps);

            vl = corrcoef([URn GC(:,vox)] );
            eval( ['alt_VR_coeff_S' num2str(SubjectNo) ' = [alt_VR_coeff_S' num2str(SubjectNo) ' vl(size(vl,1),1:num_comps)''];' ] );
            ss_coef = ss_coef + vl(size(vl,1),1:num_comps).*vl(size(vl,1),1:num_comps);

          end;  % -- each voxel

%        end;  % --- each column
 
      end;  % --- each frequency 

      VR_ss_cov = [VR_ss_cov; ss_cov];
      VR_ssm_cov = [VR_ssm_cov; ss_cov./size(GC,2)];
      VR_ss_coef = [VR_ss_coef; ss_coef];
      VR_ssm_coef = [VR_ssm_coef; ss_coef./size(GC,2)];

      if ~isempty(pop)
        pop.clearFrequency();
        pop.setComment( 'Variance and thresholds' ); 
      end;
 

%       if sum(sum(H')) < size(V,1)
%         eval( [' ep_' num2str(SubjectNo) ' = calc_ext_Pos_Neg(alt_VR_S' num2str(SubjectNo) ''',1);' ] );
%       else
        eval( [' ep_' num2str(SubjectNo) ' = calc_ext_Pos_Neg(alt_VR_S' num2str(SubjectNo) ''');' ] );
%       end;
      
%      eval( [' ep_' num2str(SubjectNo) ' = calc_ext_Pos_Neg(alt_VR_S' num2str(SubjectNo) ''');' ] );
       cvariance_rotated_tot = 0;
       eval( ['cvariance_rotated_tot = component_variance( Gheader.GZheader.sum_diagonal, alt_VR_S' num2str(SubjectNo) ''' );' ] );


      if ( strcmp( class(pop), 'progress_display' ) )
        pop = pop.setComment( '' );
      end;

      eval ( [ 'save( ''' outdir out_mat ''', ''alt_VR_S' num2str(SubjectNo) ''', ''alt_VR_coeff_S' num2str(SubjectNo) ''', ''ep_' num2str(SubjectNo) ''', ''cvariance*'', ''-append'', ''-v7.3'');' ] );

      sParms.subject = SubjectNo;

      text_file = fs_filename( 'subject_txt', 'GC', 'unrotated', sParms );
      text_file = [outdir 'output_' text_file];

      fid = fopen( text_file, 'w' );
      text_file_header( nd, fid, 0, component_directory )

%      print_and_log( log_fid, '\n\nCorrelation coefficients of UR\n------------------------------------------\n' );
      if (fid) fprintf( fid, '\n\nCorrelation coefficients of UR\n------------------------------------------\n' ); end;

      cUR = corrcoef( UR ); % --= 
      for ii=1:size(cUR,1) 
        z=[]; 
        for jj = 1:size(cUR,2) 
          y = sprintf( '\t%.2f', cUR(ii,jj) ); 
          z = [z y];
        end; 
%        print_and_log( log_fid, '%s\n', z );
        if ( fid ) fprintf( fid, '%s\n', z ); end;

      end;

      ep = [];
      eval( ['ep = ep_' num2str(SubjectNo) ';'] ); 
      tsum = Zheader.tsum;
%      print_and_log( log_fid, '\nExtreme Positive negative loading for unrotated components:' );
      if ( fid ) fprintf( fid, '\nExtreme Positive negative loading for unrotated components:' ); end;
      display_extremes_pos_neg(ep, cvariance_rotated_tot, tsum, fid, 2, 0 );

      if ( fid ) fclose( fid ); fid = 0; end;

      if ( ~isempty( funcs.memory_stats ) ) funcs.memory_stats(); end;

    end;   % --- each subject

    if ~isempty(pop)
      pop.clearParticipant();
      pop.setComment('Summarizing' ); 
    end;

    eval ( [ 'save( ''' outdir out_mat ''', ''VR_s*'', ''-append'', ''-v7.3'');' ] );

    %----------------------------------------
    % summarize
    %----------------------------------------

    Normalized_Z_Dir = Z_Directory();

    noParms.text = 'subject_specific_ssloadings';
    vals_output = fs_filename( 'alt_vr_summary', 'GC', 'unrotated', noParms );
    values_output = [outdir vals_output];
    fid = fopen( values_output, 'w' );		% if the log file does not exist, then this will create an empty one, avoiding edit error

    text_file_header( nd, fid, 0, outdir, vals_output );

    fprintf( fid, '\nSum of Values Squared - cov( [UR GC] )\n------------------------------------------\n' );

    for SubjectNo = 1:Zheader.num_subjects

      fprintf( fid,  '%s', char(scan_information.SubjectID(SubjectNo)) ); 

      z=[]; 
      for comp = 1:num_comps
        y = sprintf( '\t%.4f', VR_ss_cov(SubjectNo,comp) ); 
        z = [z y];
      end; 
      fprintf( fid, '%s\n', z );

    end;    

    fprintf( fid, '\nMean of Values Squared - cov( [UR GC] )\n------------------------------------------\n' );

    for SubjectNo = 1:Zheader.num_subjects

      fprintf( fid,  '%s', char(scan_information.SubjectID(SubjectNo)) ); 

      z=[]; 
      for comp = 1:num_comps
        y = sprintf( '\t%.4f', VR_ssm_cov(SubjectNo,comp) ); 
        z = [z y];
      end; 
      fprintf( fid, '%s\n', z );

    end;    


    fprintf( fid, '\n\nVariance accounted for in subject GC\n------------------------------------------\n' );

    for SubjectNo = 1:Zheader.num_subjects

      eval( [ 'load( ''' Gheader.GZheader.path_to_segs filesep 'GC_S' num2str(SubjectNo) ''', ''subject_GCsd'');' ] );
      eval( [ 'load( ''' Normalized_Z_Dir 'Z' filesep 'Z' num2str(SubjectNo) '.mat'', ''tsum_subject'');'] );
        
      if exist( 'tsum_subject', 'var' ) & exist( 'subject_GCsd', 'var' )
        fprintf( fid,  '%s', char(scan_information.SubjectID(SubjectNo)) ); 
        fprintf( fid, '\t%.4f\n', (subject_GCsd / tsum_subject * 100) ); 
      end;

      clear tsum_subject subject_GCsd

    end;

    fprintf( fid, '\n');

    if ( fid ) fclose( fid ); fid = 0; end;

  end;  

