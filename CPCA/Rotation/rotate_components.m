function result = rotate_components( funcs, rotation_params, nd, log_fid, pop, GAtyp, mask_registry )
% rotate components from applied G*Z data
%
%  A return value of 0 flags operational error and aborts further processing in GUI

global Zheader scan_information

  if nargin < 4,  log_fid = 0;  end;
  if nargin < 5,  pop = [];  end;
  if nargin < 6,      GAtyp = 'G';  end
  if nargin < 7,  mask_registry = 0;  end;
  if ~isa(pop, 'cpca_progress' ),     pop = [];    end

  result = 0;
%  mask_registry = reg * constant_define( 'PREFERENCES', 'general.gray_white_split' );
  
  if ~isfield( rotation_params, 'model' ), 
    rotation_params.model = 'G';
  else
    if isempty(rotation_params.model)
      rotation_params.model = 'G';
    end;
  end;

  if ~isfield( rotation_params, 'Aindex' )
    rotation_params.Aindex = 0;
  end;
  
  rotation_params.defaults.reg = mask_registry;
  rotation_params.defaults.regTag = constant_define( 'REGISTRATION_TAG', mask_registry );
  
  noParms = struct( 'model', 'G', 'reg', mask_registry, 'regTag', constant_define( 'REGISTRATION_TAG', mask_registry ) );
%  noParms = struct( 'model', 'G' );
  if isfield( rotation_params, 'hindex' )
    noParms.hindex = rotation_params.hindex ;   
  end
  
  if strcmp( rotation_params.model, 'H' )
    component_directory = fs_path( 'unrotated', 'output', nd, 0, rotation_params  );
    component_directory = [pwd filesep component_directory];
    in_file = fs_filename( 'mat', rotation_params.htype, 'unrotated', rotation_params );
  else
    component_directory = fs_path( 'unrotated', 'output', nd, 0,  noParms );
    component_directory = [pwd filesep component_directory];
    in_file = fs_filename( 'mat', GAtyp, 'unrotated', noParms );
  end;
  betas_c_pos = [];
  betas_c_neg = [];
  Gheader = [];
  ep = [];
  
  load( [component_directory in_file],'d3', 'V', 'U', 'P*', 'ep', 'cvariance*', ...
      'betas_c*', 'component_loadings', 'psum', 'ppsum', 'dsum', 'pdsum', 'ppdsum' );
  
  ind = [];
  if mask_registry > 0
    [~, ind] = mask_registrations( scan_information.mask, mask_registry );

    % --- adjust procrustes target VR to pint to proper file when Grey or
    % --- White matter rotation
    if ~isempty( rotation_params.defaults.hrf_file ) && strcmpi( rotation_params.method, 'procrustes' ) 
      if rotation_params.defaults.reg > 0
        rot_type = 'orthogonal';
        if rotation_params.defaults.oblique
          rot_type = 'oblique';
        end
          
        rotation_params.defaults.hrf_file = ...
           strrep( char(rotation_params.defaults.hrf_file), rot_type, ...
           [ rot_type strrep(constant_define( 'REGISTRATION_TYPE', rotation_params.defaults.reg ), ' ', '_') ] );
      end
    end

  end

  component_orientation_data = [];

  if ( ~isempty( funcs.memory_stats ) ), funcs.memory_stats(); end;

  if ~strcmp( GAtyp, 'GAA' )   % --- no betas for GAA (yet)
    for ii = 1:size(ep,1)
      % beta averages
      thr = min( size(ep(1).percentiles, 1), constant_define( 'PREFERENCES', 'threshold.default', 3 ) );
      avg_pos = mean(mean(betas_c_pos(ii).threshold(thr).betas(3:end,:)));
      avg_neg = mean(mean(betas_c_neg(ii).threshold(thr).betas(3:end,:)));
      % now require load average
      avgl_pos = component_loadings(ii).pos.mean;
      avgl_neg = component_loadings(ii).neg.mean;
      component_orientation_data = [component_orientation_data; ep(ii).percentiles( thr).pos_voxels avg_pos avgl_pos ep(ii).percentiles( thr ).neg_voxels avg_neg avgl_neg ];
    end;
  end
  
  clear ep;		% do not hold onto variables from unrotated data
  
%   compute_comps = 0;

  fs_create_path( 'rotated', 'images', nd, 0, rotation_params );

  component_directory = fs_path( 'rotated', 'output', nd, 0, rotation_params );
  %component_directory = [pwd filesep component_directory];
 
  tsum = Zheader.tsum;
  if ( rotation_params.model == 'G' )
    tag = 'GC';
    load( Zheader.Model.path, 'Gheader' );
    rotation_params.prefix = 'G';
    
    sumDiag = 0;
    if ~strcmp( GAtyp, 'G' )
      load( Zheader.Contrast.path );
      sumDiag = Aheader.model( Aheader.Aindex).sd(1+strcmp(GAtyp, 'GAA' ));
      
    else   
      eval( [ 'sumDiag = Gheader.' GAtyp 'Zheader.sum_diagonal;' ] );
      if ~isempty( ind )
        switch mask_registry
            case 1
              sumDiag = Gheader.GZheader.rsum(1) + sum(Gheader.GZheader.rsum(4:5));
              tsum = Zheader.rsum(1) + Zheader.rsum(4) + Zheader.rsum(5);
            case 2
              sumDiag = Gheader.GZheader.rsum(2);
              tsum = Zheader.rsum(2);
        end
      end
    end
    rotation_params.htype = GAtyp;

  else
    Gheader = [];
    if strcmp( rotation_params.htype, 'GnotH' )
      load( Zheader.Model.path, 'Gheader' );
    end;
    rotation_params.prefix = 'H';
    load( Zheader.Limits.path );
    
    if isfield( Hheader.model(Hheader.Hindex).sum_diagonal, rotation_params.htype )
      eval( ['sumDiag = Hheader.model(Hheader.Hindex).sum_diagonal.' rotation_params.htype ';' ] );  
    end;
    switch rotation_params.htype
        case 'GMH'
          sumDiag = Hheader.model(Hheader.Hindex).sum_diagonal.GMH;
        case 'GnotH'
          sumDiag = Hheader.model(Hheader.Hindex).sum_diagonal.GC;
        case 'HnotG'
          sumDiag = Hheader.model(Hheader.Hindex).sum_diagonal.BH;
    end
  end;

  nr = Zheader.total_scans;
  nc = Zheader.total_columns;

  nvox = Zheader.total_columns;
%   if isROI
%     nvox = nvox - size( indexes.Gindex, 1 );
%   else
    if ~isempty( ind )
      nvox = numel( ind );
    end
%   end;
  
  [~, plot_directory] = fs_create_path( 'rotated', 'plots', nd, 0, rotation_params );
  plot_directory = [ pwd filesep plot_directory ];

  mat_file = fs_filename( 'mat', rotation_params.htype, rotation_params.method, rotation_params.defaults );
  initialize_mat_file( [component_directory mat_file] );

  if nd > 0
    Zheader.NumComponents_GA = nd;

%  %   Txt = sprintf( 'Rotating %d components from GZ (%s)',nd, rotation_params.method );
%     Txt = sprintf( '%s Rotation %d components', upper( rotation_params.method ), nd );

    if ~isempty(pop)
      pop.setPong( 1 );
    end;
    [T, PR, VR, UR] = compute_facs( P, U, V, nd, tsum, nr, nc, Gheader, rotation_params, pop, GAtyp );
    if ( isempty( T ) )       
      if ~isempty(pop)
        pop.setPong( 0 );
      end;
      return;      
    end;		% comp_facs will return all empty if unable to rotate

    if ( ~isempty( funcs.memory_stats ) ), funcs.memory_stats(); end;
    if ~isempty(pop)
      pop.setComment( 'Calculating statistics . . .' );
    end;
    [PR, VR, UR, cvariance_rotated_tot] = calc_rotation_stats( PR, UR, VR, T, nd, rotation_params, pop );        

    if ~isempty(pop)
      pop.increment( pop.PRIMARY );
    end;

    theseParms = rotation_params.defaults;
    theseParms.var = 'T';
    T_file = fs_filename( 'mat', rotation_params.htype, rotation_params.method, theseParms );

    save( [component_directory T_file], 'T', '-v7.3' );
    save( [component_directory mat_file], 'd3', 'P*', 'U*', 'V*', 'T', 'cvariance*', 'rotation_params', ...
        'component_orientation_data', 'psum', 'ppsum', 'dsum', 'pdsum', 'ppdsum', 'mask_registry', ...
        '-append', '-v7.3' );

    ftext = rotation_params.htype;
    if strcmp( GAtyp, 'GAA' ) 
      ftext = 'GnotA';
    end
    txt_file = fs_filename( 'txt', ftext, rotation_params.method, rotation_params.defaults );
    text_file = [ 'output_' txt_file ];
%    text_file = [ component_directory 'output_' txt_file ];
    fid = fopen( [component_directory text_file], 'w' );

    text_file_header( nd, fid, log_fid, component_directory, text_file, rotation_params.Aindex, nvox )
    if strcmp( rotation_params.model, 'H' )
      H_matrix_header(Hheader, fid);
    end;
    
    if ~isempty( rotation_params.htype )
      ftext =  rotation_params.htype;
    else
      if strcmp( GAtyp, 'G' ) 
        ftext = [tag constant_define( 'REGISTRATION_SUMMARY_TAG', mask_registry )];
      end;
    end
    
    pca_summary( sumDiag, ftext, cvariance_rotated_tot, fid, tsum );
    if ( fid ), fclose( fid );  end;

    pca_summary( sumDiag, ftext, cvariance_rotated_tot, 1, tsum );
    
    % ------------------------------------------------
    % --- force G application to be only on all subjects
    % ------------------------------------------------
%     nr = Zheader.total_scans;
%     nremoved = Zheader.tsum_trends;
%     GroupIndex = 0;
%     SubjectVector = [ 1:Zheader.num_subjects ];

    ep = calc_ext_Pos_Neg(VR);
    save( [component_directory mat_file], 'ep', '-append', '-v7.3' );

    if strcmp( rotation_params.prefix, 'H' )
      H = load_H_matrix( Hheader, 1 );
      URcf = corrcoef( [VR H] );
      URcv = cov( [VR H] );

      save( [component_directory mat_file], 'URcf', 'URcv', '-append', '-v7.3' );
    end;
    
    if ( ~isempty( funcs.memory_stats ) ), funcs.memory_stats(); end;

    %----------------------------------------
    % summarize
    %----------------------------------------
    fid = fopen( [component_directory text_file], 'a+' );
    print_UR_coefficents( fid, corrcoef( UR ) );
    print_matrix_values( fid, T, ['T matrix (' rotation_params.method ' ' num2str(rotation_params.defaults.iterations) ' iterations ): ' ]);
    display_extremes_pos_neg(ep, cvariance_rotated_tot, tsum, fid, 2, log_fid );
    if ( fid ), fclose( fid );  end;

    result = nd;

    %----------------------------------------
    % positive/negative betas of C for each component
    %----------------------------------------]
 
    if ~isempty(pop)
      pop.setComment( 'Recomputing for beta check. . .' );
      pop.increment( pop.PRIMARY );
    end;

    fnm = [component_directory mat_file];

    if isempty( Gheader )
      load( Zheader.Model.path,'Gheader' );
    end;

    if ~strcmp( rotation_params.prefix, 'H' )
      if ~strcmp( GAtyp, 'GAA' )
        if ( ~isempty( funcs.clear_cache ) )  
          funcs.clear_cache(-1);    % -- force cache clearance priot to beta calc
        end; 
        funcs.memory_stats(); 

        betas_c_pos = calc_c_betas( fnm, Gheader, 1, 0, rotation_params.htype, mask_registry );

        if ( ~isempty( funcs.clear_cache ) )  
          funcs.clear_cache(-1);    % -- force cache clearance priot to beta calc
        end; 
        funcs.memory_stats(); 
        betas_c_neg = calc_c_betas( fnm, Gheader, 0, 0, rotation_params.htype, mask_registry );
      end
    else
      if ~isempty(pop)
        pop.setComment( 'Positive Betas . . .' );
      end;
      betas_c_pos = calc_gmh_gc_betas( fnm, Gheader, Hheader, 1, pop );
            
      if ~isempty(pop)
        pop.setComment( 'Negative Betas . . .' );
      end;
      betas_c_neg = calc_gmh_gc_betas( fnm, Gheader, Hheader, 0, pop );
        
    end;
  
    if ~strcmp( GAtyp, 'GAA' )
      if ~isempty(pop)
        pop.setComment( 'Saving . . .' );
      end;
      save( [component_directory mat_file], 'betas_*', '-append', '-v7.3' );
      if ~isempty(pop)
        pop.setComment( '' );
        pop.increment( pop.PRIMARY );
      end;
    end
    
    %----------------------------------------
    % output UR set to intial 0 per component
    %----------------------------------------
    if ~strcmp( GAtyp, 'GAA' )
      if ~isempty(pop)
        pop.setComment( 'Producing output . . .' );
      end;

      if ~strcmp( rotation_params.htype, 'GA' )
        theseParms = rotation_params;
        theseParms.defaults.var = 'HRF';
        theseParms.defaults.component = 999;
        out_file = fs_filename( 'txt', rotation_params.htype, rotation_params.method, theseParms.defaults );
        output_HRF( component_directory, out_file, PR, Gheader, nvox);
        plot_HRF( plot_directory, PR, Gheader, theseParms );
      end
    
      fid = fopen( [component_directory text_file], 'a' );
      if (fid)

        print_subject_variances( fid, mask_registry )      
        fprintf( fid, '\n');
        fclose( fid );
      end;
    end

  end

  
  if ( ~isempty( funcs.memory_stats ) ), funcs.memory_stats(); end;

  if ~isempty(pop)
    pop.setPong( 0 );
    pop.setComment( '' );
    pop.increment( pop.PRIMARY );
  end;

