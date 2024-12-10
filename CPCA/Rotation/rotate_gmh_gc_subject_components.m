function rotate_gmh_gc_subject_components( funcs, rotation_params, nd, log_fid, pop )
global Zheader scan_information 
  if ( nargin < 4 )  log_fid = 0;  end;
  if ( nargin < 5)  pop = [];  end;
  if ~strcmp( class(pop), 'cpca_progress' )
    pop = []; 
  end

  result = 0;
  
  Txt = 'GMH:GC Rotation';
  Sts = [ rotation_params.method ' Subject VR''s for ' num2str(nd) ' components' ];
  if ~isempty(pop)
    pop.setMessage( Sts );
  end;

  %----------------------------------------
  % Alternate VR - 1 image each for subject/component
  %----------------------------------------

  [ok outdir] = fs_create_path( 'subject', 'output', nd, 0, rotation_params );

%  outdir = fs_path( 'subject_vr', 'output', nd, 0, rotation_params );
  outdir = [pwd filesep outdir];

  component_directory = fs_path( 'rotated', 'output', nd, 0, rotation_params );
  component_directory = [pwd filesep component_directory];

  mat_file = fs_filename( 'mat', rotation_params.htype, rotation_params.method, rotation_params.defaults );

  load( Zheader.Model.path, 'Gheader' );
  load( Zheader.Limits.path, 'Hheader' );
  load( [ component_directory mat_file ], 'UR' );

  num_comps = size(UR,2);
  UR_From = 0;
  UR_To = 0;

  out_mat = fs_filename( 'alt_vr', rotation_params.htype, rotation_params.method, rotation_params.defaults );
%  eval ( [ 'save( ''' outdir out_mat ''', ''num_comps'')' ] );
  initialize_mat_file( [outdir out_mat] );  
  save( [ outdir out_mat ], 'num_comps', '-append','-v7.3' );

  in_dir = [Zheader.Z_Directory 'Hsegs' filesep 'GMH' filesep ];			% eg: GZ_segs, GAZ_segs

  VR_ss_cov = [];
  VR_ssm_cov = [];
  VR_ss_coef = [];
  VR_ssm_coef = [];

  if ~isempty(pop)
    pop.setIterations( Zheader.num_subjects * max(scan_information.frequencies, 1) * Zheader.total_columns );
  end;

  for SubjectNo = 1:Zheader.num_subjects
    sid = subject_id( SubjectNo );
    if ~isempty(pop)
      pop.setParticipant( SubjectNo, Zheader.num_subjects, sid );
      pop.setComment( 'Calculating . . .' );
    end;

    eval( ['alt_VR_S' num2str(SubjectNo) ' = [];'] );
    eval( ['alt_VR_coeff_S' num2str(SubjectNo) ' = [];'] );

    if ( ~isempty( funcs.clear_cache ) )  funcs.clear_cache();  end; funcs.memory_stats();

    for FrequencyNo=1:max(scan_information.frequencies, 1)

      ftag = frequency_tag(FrequencyNo) ;
      fdsp = strrep( ftag, '_', ' ');
      if scan_information.isMulFreq
        if ~isempty(pop)
          pop.setFrequency( FrequencyNo, scan_information.frequencies, fdsp );
        end;
      end;

      GC = [];

      for RunNo = 1:Zheader.num_runs

        if iscellstr( scan_information.SubjDir(SubjectNo, RunNo ) )

          if ~isempty(pop)
            pop.setRun( RunNo, Zheader.num_runs);
          end;

          GCn = [];
          for column = 1:Hheader.partitions.count

            eval ( [ 'load( ''' in_dir 'GC_S' num2str(SubjectNo) '.mat'', ''GC_R' num2str(RunNo) '_C' num2str(column) ftag ''' );'] );
 
            eval( ['GCn = [GCn GC_R' num2str(RunNo) '_C' num2str(column) ftag '];'] );
            eval( ['clear GC_R' num2str(RunNo) '_C' num2str(column) ftag ';'] );

          end;  % --- each column

          GC = [GC; GCn];
          clear GCn;

        end % --- subject contains run
      end % --- each run

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

    end;  % --- each frequency 

    VR_ss_cov = [VR_ss_cov; ss_cov];
    VR_ssm_cov = [VR_ssm_cov; ss_cov./size(GC,2)];
    VR_ss_coef = [VR_ss_coef; ss_coef];
    VR_ssm_coef = [VR_ssm_coef; ss_coef./size(GC,2)];


    if ~isempty(pop)
      pop.setComment('Variance and thresholds' );
    end;

    nr = Zheader.total_scans;
    if sum(sum(H')) < size(V,1)
      eval( [' ep_' num2str(SubjectNo) ' = calc_ext_Pos_Neg(alt_VR_S' num2str(SubjectNo) ''',1);' ] );
    else
      eval( [' ep_' num2str(SubjectNo) ' = calc_ext_Pos_Neg(alt_VR_S' num2str(SubjectNo) ''');' ] );
    end;
%    eval( [' ep_' num2str(SubjectNo) ' = calc_ext_Pos_Neg(alt_VR_S' num2str(SubjectNo) ''');' ] );
    cvariance_rotated_tot = 0;
    eval( ['cvariance_rotated_tot = component_variance( Gheader.GZheader.sum_diagonal, alt_VR_S' num2str(SubjectNo) ');' ] );

    if ~isempty(pop)
      pop.setComment('Saving . . .' );
    end;


    eval ( [ 'save( ''' outdir out_mat ''', ''alt_VR_S' num2str(SubjectNo) ''', ''alt_VR_coeff_S' num2str(SubjectNo) ''', ''ep_' num2str(SubjectNo) ''', ''cvariance*'', ''-append'',''-v7.3'');' ] );


    rotation_params.parameters.subject = SubjectNo;
    txt_file = fs_filename( 'subject_txt', 'GC', rotation_params.method, rotation_params.parameters);
    text_file = [outdir 'output_' txt_file];

    fid = fopen( text_file, 'w' );
    text_file_header( nd, fid, 0, component_directory, txt_file )

%    print_and_log( log_fid, '\n\nCorrelation coefficients of UR\n------------------------------------------\n' );
    if (fid) fprintf( fid, '\n\nCorrelation coefficients of UR\n------------------------------------------\n' ); end;

    cUR = corrcoef( UR ); % --= 
    for ii=1:size(cUR,1) 
      z=[]; 
      for jj = 1:size(cUR,2) 
        y = sprintf( '\t%.2f', cUR(ii,jj) ); 
        z = [z y];
      end; 
%      print_and_log( log_fid, '%s\n', z );
      if ( fid ) fprintf( fid, '%s\n', z ); end;

    end;

    ep = [];
    eval( ['ep = ep_' num2str(SubjectNo) ';'] ); 
    tsum = Zheader.tsum;
%    print_and_log( log_fid, '\nExtreme Positive negative loading for unrotated components:' );
    if ( fid ) fprintf( fid, '\nExtreme Positive negative loading for unrotated components:' ); end;
    display_extremes_pos_neg(ep, cvariance_rotated_tot, tsum, fid, 2, 0 );

    if ( fid ) fclose( fid ); fid = 0; end;

  end;   % --- each subject

  eval ( [ 'save( ''' outdir out_mat ''', ''VR_s*'', ''-append'',''-v7.3'');' ] );

  %----------------------------------------
  % summarize
  %----------------------------------------

  if ~isempty(pop)
    pop.setComment('Summarizing . . .' );
  end;

  Normalized_Z_Dir = Z_Directory();

  theseParms = rotation_params.defaults;
  theseParms.text = 'subject_specific_ssloadings';
  values_out = fs_filename( 'alt_vr_summary', 'G', rotation_params.method, theseParms )
  values_output = [outdir values_out]
  fid = fopen( values_output, 'w' );		% if the log file does not exist, then this will create an empty one, avoiding edit error

  text_file_header( nd, fid, 0, outdir, values_out );

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

  if ( ~isempty( funcs.memory_stats ) ) funcs.memory_stats(); end;


