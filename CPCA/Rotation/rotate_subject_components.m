function rotate_subject_components( funcs, rotation_params, nd, log_fid, pop, mask_registry )
global Zheader scan_information 

  this_rotation = rotation_params;

  if ( nargin < 4 ),  log_fid = 0;  end;
  if ( nargin < 5 ),  pop = [];  end;
  if ( nargin < 6 ),  mask_registry = 0;  end;
  if ~isa( pop, 'cpca_progress' ),     pop = [];    end

  ind = [];
  nvox = Zheader.total_columns;
  if mask_registry > 0;
    [~, ind] = mask_registrations( scan_information.mask, mask_registry );
    if ~isempty( ind ),       nvox = numel( ind );     end
  end

  if ~isfield( rotation_params, 'model' )
    rotation_params.model = 'G';
  else
    if isempty(rotation_params.model)
      rotation_params.model = 'G';
      rotation_params.method = 'unrotated';
    end;
  end;


  if ( rotation_params.model == 'G' )
    eval( ['load( ''' Zheader.Model.path ''', ''Gheader'' )' ] );
    rotation_params.prefix = 'G';
  else
    Gheader = [];
    rotation_params.prefix = 'H';
  end;

  Txt = 'Calculating Subject VRs';
  if ~isempty(pop)
    pop.setMessage( Txt );
    pop.setIterations( ...
          (Zheader.num_subjects * max(scan_information.frequencies, 1) ) ...
        + ( Zheader.num_subjects * nd * max(scan_information.frequencies, 1) ) ...
        , pop.PRIMARY );
  end;

  GC = [];

  %----------------------------------------
  % Alternate VR - 1 image each for subject/component
  %----------------------------------------

  [~, outdir] = fs_create_path( 'subject', 'output', nd, 0, rotation_params );

%  outdir = fs_path( 'subject', 'output', nd, 0, rotation_params );
  outdir = [pwd filesep outdir];

  component_directory = fs_path( 'rotated', 'output', nd, 0, rotation_params );
  component_directory = [pwd filesep component_directory];

  mat_file = fs_filename( 'mat', rotation_params.prefix, rotation_params.method, rotation_params.defaults );

  load( [component_directory mat_file], 'UR');
  load( Zheader.Model.path, 'Gheader');

  num_comps = size(UR,2);
  UR_From = 0;
  UR_To = 0;

  VR_ss_cov = [];
  VR_var_cov = [];
  VR_ss_coef = [];
  VR_var_coef = [];

  out_mat = fs_filename( 'alt_vr', rotation_params.model, rotation_params.method, rotation_params.defaults );
  initialize_mat_file( [outdir out_mat] );  
  save( [outdir out_mat], 'num_comps', '-append','-v7.3');

  for SubjectNo = 1:Zheader.num_subjects
    sid = subject_id( SubjectNo );
%    sid = strrep( sid, '_', ' ');

    if ~isempty(pop)
      pop.setParticipant( SubjectNo, Zheader.num_subjects, sid );
      pop.setIterations( max(scan_information.frequencies, 1) * max(Zheader.partitions.count, 1) * nvox, pop.SECONDARY );
    end;

    if ( ~isempty( funcs.clear_cache ) )  
      funcs.clear_cache();  
    end; 
    funcs.memory_stats();
    
    eval( ['alt_VR_S' num2str(SubjectNo) ' = [];'] );
    eval( ['alt_VR_coeff_S' num2str(SubjectNo) ' = [];'] );

    for FrequencyNo=1:max(scan_information.frequencies, 1)

      ftag = frequency_tag(FrequencyNo) ;
      fdsp = strrep( ftag, '_', ' ');

      if ~isempty(pop)
        pop.setComment( '' );
        if scan_information.isMulFreq
          pop.setFrequency( FrequencyNo, scan_information.frequencies, fdsp );
        end;
      end;

      retrieve_subject_GC( Gheader, SubjectNo, ftag );
      if ~isempty( ind )
         GC = GC( :, ind );
      end
        
      UR_From = Zheader.timeseries.subject(SubjectNo).run(1,2);
      UR_To = UR_From + size(GC,1) - 1;

      % nomalize subject UR
      URn = cpca_normalize( UR(UR_From:UR_To,:) );
%      iter = 0;

      if ~isempty(pop)
        pop.setComment( 'Calculating correlation coefficients' );
      end;

      ss_cov = zeros( 1, num_comps );
      ss_coef = zeros( 1, num_comps );
      for vox = 1:size(GC,2)
        if ~isempty(pop)
          pop.increment( pop.SECONDARY);
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

    sd = Gheader.GZheader.sum_diagonal;
    tag = 'GC';
    tsum = Zheader.tsum;
    if ~isempty( ind )
      switch mask_registry
        case 1
          sd = Gheader.GZheader.rsum(1) + sum(Gheader.GZheader.rsum(4:5));
%          case 2
%            sd = Gheader.GZheader.rsum(2);
      end
    end  
    cvariance_rotated_tot = 0;
    eval( [' ep_' num2str(SubjectNo) ' = calc_ext_Pos_Neg(alt_VR_S' num2str(SubjectNo) ''');' ] );
    eval( ['cvariance_rotated_tot = component_variance( Gheader.GZheader.sum_diagonal, alt_VR_S' num2str(SubjectNo) ''' );' ] );
    eval ( [ 'save( ''' outdir out_mat ''', ''alt_VR_S' num2str(SubjectNo) ''', ''alt_VR_coeff_S' num2str(SubjectNo) ''', ''ep_' num2str(SubjectNo) ''', ''cvariance*'', ''-append'',''-v7.3'');' ] );

    these_parms = rotation_params.defaults;
    these_parms.subject = SubjectNo;
    txt_file = fs_filename( 'subject_txt', 'G', rotation_params.method, these_parms);
    text_file = ['output_' txt_file];

    ep = [];
    eval( ['ep = ep_' num2str(SubjectNo) ';'] ); 

    fid = fopen( [outdir text_file], 'w' );
%    text_file_header( nd, fid, 0, component_directory, txt_file )
    text_file_header( nd, fid, 0, component_directory, text_file, 0, nvox );
    pca_summary( sd, tag, cvariance_rotated_tot, fid, tsum );
%    pca_summary( Gheader.GZheader.sum_diagonal, 'GC', cvariance_rotated_tot, fid );
    print_UR_coefficents( fid, corrcoef( UR ) );
    display_extremes_pos_neg(ep, cvariance_rotated_tot, tsum, fid, 2, 0 );
    if ( fid ), fclose( fid );  end;

    g_images_rotated_alt_vr( this_rotation, SubjectNo, nd, log_fid, pop, mask_registry  );

  end;   % --- each subject

  eval ( [ 'save( ''' outdir out_mat ''', ''VR_s*'', ''-append'',''-v7.3'');' ] );

  %----------------------------------------
  % summarize
  %----------------------------------------

%  Normalized_Z_Dir = Z_Directory();

  theseParms = rotation_params.defaults;
  theseParms.text = 'subject_specific_ssloadings';
  values_out = fs_filename( 'alt_vr_summary', 'G', rotation_params.method, theseParms );
  values_output = [outdir values_out];
  fid = fopen( values_output, 'w' );		% if the log file does not exist, then this will create an empty one, avoiding edit error

%  text_file_header( nd, fid, 0, outdir, values_out );
  text_file_header( nd, fid, 0, outdir, values_out, 0, nvox );
  print_subject_cov( fid, VR_ss_cov, VR_var_cov, Gheader );
  print_subject_cov( fid, VR_ss_coef, VR_var_coef, Gheader, 'corrcoef' );

  if ( fid ),     fclose( fid );   end;

  if ( ~isempty( funcs.memory_stats ) ),     funcs.memory_stats();   end;



