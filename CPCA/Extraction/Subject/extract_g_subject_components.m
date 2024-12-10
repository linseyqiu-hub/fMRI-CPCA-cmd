function abort_proc = extract_g_subject_components( funcs, nd, log_fid, pop, mask_registry )
% apply the G model to the normalized Z data
% creates the G_unrotated.mat data set for G extraction and imaging
%
% note: G and GA processing was separated to a allow for unique G as well as GA if desired

global Zheader scan_information  

  if ( nargin < 3 ),  log_fid = 0;  end;
  if ( nargin < 4 ),  pop = [];  end;
  if ( nargin < 5 ),  mask_registry = 0;  end;
  if ~isa( pop, 'cpca_progress' ),    pop = [];   end

  ind = [];
  if mask_registry > 0;
    [~, ind] = mask_registrations( scan_information.mask, mask_registry );
  end
  
  UR = [];
  GC = [];
  
  load( Zheader.Model.path, 'Gheader');
  
  nvox = Zheader.total_columns;
  tsum = Zheader.tsum;
  sumDiag = Gheader.GZheader.sum_diagonal;
  
  if ~isempty( ind )
    nvox = numel( ind );
    switch mask_registry
      case 1
        tsum = Zheader.rsum(1) + Zheader.rsum(4) + Zheader.rsum(5);
        sumDiag = Gheader.GZheader.rsum(1) + sum(Gheader.GZheader.rsum(4:5));
      case 2
        tsum = Zheader.rsum(2);
        sumDiag = Gheader.GZheader.rsum(2);
    end
  end;
  
  abort_proc = 0;

  noParms = struct( 'model', 'G' );

  [has_dir, component_directory] = fs_create_path( 'unrotated', 'output', nd, 0, noParms );
  component_directory = [ pwd filesep component_directory ];

  if ( has_dir )

    Txt = 'Calculating Subject VRs';

    if ~isempty(pop)
       pop.setMessage( Txt );
        pop.setIterations( ...
             (Zheader.num_subjects * max(scan_information.frequencies, 1) ) ...
           + ( Zheader.num_subjects * nd * max(scan_information.frequencies, 1) ) ...
           , pop.PRIMARY );
%           + ( (Zheader.num_subjects * max(scan_information.frequencies, 1) ) * nd * num_active_thresholds() ) ...
       
    end;

    UR_file = fs_filename( 'mat', 'G', 'unrotated', noParms );
    UR_file = [component_directory UR_file];

    %----------------------------------------
    % Alternate VR - 1 image each for subject/component
    %----------------------------------------

  noParms = struct( 'model', 'G', 'method', 'unrotated', 'reg', mask_registry, 'regTag', constant_define( 'REGISTRATION_TAG', mask_registry ) );
%    noParms = struct( 'model', 'G', 'method', 'unrotated');
    [~, outdir] = fs_create_path( 'subject', 'output', nd, 0, noParms );
    outdir = [pwd filesep outdir];

    load( UR_file, 'UR', 'nr');

    num_comps = size(UR,2);

    VR_ss_cov = [];
    VR_var_cov = [];
    VR_ss_coef = [];
    VR_var_coef = [];

%    out_mat = fs_filename( 'alt_vr', 'G', 'unrotated', [] );
    out_mat = fs_filename( 'alt_vr', 'G', 'unrotated', noParms );
    initialize_mat_file( [outdir out_mat] );

    for SubjectNo = 1:Zheader.num_subjects
      sid = subject_id( SubjectNo );

      [~, subj_dir] = fs_create_path( 'subject', 'subject', nd, SubjectNo, noParms );
      initialize_mat_file( [subj_dir out_mat] );
      
      if ~isempty(pop)
        pop.setParticipant( SubjectNo, Zheader.num_subjects, sid );
        pop.setIterations( max(scan_information.frequencies, 1) * max(Zheader.partitions.count, 1) * nvox, pop.SECONDARY );
      end;

%      sParms = struct( 'model', 'G', 'method', 'unrotated');
      sParms = noParms;
      sParms.subject = SubjectNo;

      if ~isempty( funcs.clear_cache ),  funcs.clear_cache();  end; funcs.memory_stats();

      eval( ['alt_VR_S' num2str(SubjectNo) ' = [];'] );
      eval( ['alt_VR_coeff_S' num2str(SubjectNo) ' = [];'] );

      for FrequencyNo=1:max(scan_information.frequencies, 1)

        ftag = frequency_tag(FrequencyNo) ;
        fdsp = strrep( ftag, '_', ' ');

        if ~isempty(pop)
          pop.setComment( '' );
          if isMultiFrequency()
            pop.setFrequency( FrequencyNo, scan_information.frequencies, fdsp );
          end;
        end;

        retrieve_subject_GC( Gheader, SubjectNo, ftag );
        if ~isempty( ind )
          GC = GC(:,ind);
        end

        if ~isempty( funcs.clear_cache ) 
          funcs.clear_cache(); 
        end; 
        funcs.memory_stats();

        UR_From = Zheader.timeseries.subject(SubjectNo).run(1,2);
        UR_To = UR_From + size(GC,1) - 1;

        % nomalize subject UR
        URn = cpca_normalize( UR(UR_From:UR_To,:) );

        if ~isempty(pop)
          pop.setComment( 'Calculating correlation coefficients' );
        end;

        ss_cov = zeros( 1, num_comps );
        ss_coef = zeros( 1, num_comps );
        for  vox = 1:size(GC,2)
          if ~isempty(pop)
            pop.increment( pop.SECONDARY );
          end;
          vl = cov([URn GC(:,vox)] );
          eval( ['alt_VR_S' num2str(SubjectNo) ' = [alt_VR_S' num2str(SubjectNo) ' vl(size(vl,1),1:num_comps)''];' ] );
          ss_cov = ss_cov + vl(size(vl,1),1:num_comps).*vl(size(vl,1),1:num_comps);

          vl = corrcoef([URn GC(:,vox)] );
          eval( ['alt_VR_coeff_S' num2str(SubjectNo) ' = [alt_VR_coeff_S' num2str(SubjectNo) ' vl(size(vl,1),1:num_comps)''];' ] );
          ss_coef = ss_coef + vl(size(vl,1),1:num_comps).*vl(size(vl,1),1:num_comps);

        end;  % -- each voxel

        if ~isempty(pop)
          pop.increment( pop.PRIMARY );
        end;
        
      end;  % --- each frequency 

      VR_ss_cov   = [VR_ss_cov;   ss_cov];
      VR_var_cov  = [VR_var_cov;  ss_cov./size(GC,2)];
      VR_ss_coef  = [VR_ss_coef;  ss_coef];
      VR_var_coef = [VR_var_coef; ss_coef./size(GC,2)];
 
      if ~isempty(pop)
        pop.clearRun();
        pop.clearFrequency();
        pop.setComment( 'Variance and thresholds' );
      end;

      VR = [];
      eval( [' VR = alt_VR_S' num2str(SubjectNo) ';' ] );
      ep = calc_ext_Pos_Neg(VR');
      eval( [' ep_' num2str(SubjectNo) ' = ep;' ] );
      cvariance_rotated_tot = component_variance( sumDiag, VR' );

      save( [outdir out_mat], ['alt_VR_S' num2str(SubjectNo) ], ['alt_VR_coeff_S' num2str(SubjectNo) ], ['ep_' num2str(SubjectNo) ], 'cvariance*', '-append', '-v7.3');
      save( [subj_dir out_mat], 'ep', 'VR', 'cvariance*', '-append', '-v7.3');

      sParms.subject = SubjectNo;

      text_file = [outdir 'output_' fs_filename( 'subject_txt', 'G', 'unrotated', sParms ) ];
%      text_file = [outdir 'output_' text_file];

      fid = fopen( text_file, 'w' );
      text_file_header( nd, fid, 0, component_directory, text_file, 0, nvox );
      pca_summary( sumDiag, ['GC' constant_define( 'REGISTRATION_SUMMARY_TAG', mask_registry )], cvariance_rotated_tot, fid, tsum );
      print_UR_coefficents( fid, corrcoef( UR ) );
      display_extremes_pos_neg(ep, cvariance_rotated_tot, tsum, fid, 2, 0 );
      if ( fid ), fclose( fid ); end;

      if ~isempty( funcs.memory_stats ), funcs.memory_stats(); end;

      g_images_unrotated_alt_vr( nd, SubjectNo, log_fid, pop, mask_registry );

    end;   % --- each subject

    eval ( [ 'save( ''' outdir out_mat ''', ''VR_*'', ''-append'', ''-v7.3'');' ] );

    %----------------------------------------
    % summarize
    %----------------------------------------

    noParms.text = 'subject_specific_ssloadings';
    vals_output = [outdir fs_filename( 'alt_vr_summary', 'G', 'unrotated', noParms )];
    fid = fopen( vals_output, 'w' );		% if the log file does not exist, then this will create an empty one, avoiding edit error

    text_file_header( nd, fid, 0, outdir, vals_output, 0, nvox );
    print_subject_cov( fid, VR_ss_cov, VR_var_cov, Gheader );
    print_subject_cov( fid, VR_ss_coef, VR_var_coef, Gheader, 'corrcoef' );

    if ( fid ), fclose( fid ); end;

  end;  

