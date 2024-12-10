function [PR VR UR cvariance_rotated_tot] = calc_rotation_stats_cmd(Zheader, scan_information,  P, U, V, T, nd, rotation_params)
% --- Primary Iterations
% --- N/A setPong(1)

  UR = U;
  VR = V;
  PR = P;
  cvariance_rotated_tot = [];


  if ~isfield( rotation_params, 'prefix' )
    rotation_params.prefix = 'G';
  else
    if isempty(rotation_params.model)
      rotation_params.model = 'G';
    end
  end

  if ~isfield( rotation_params, 'htype' )
    rotation_params.htype = rotation_params.mode;
  else
    if isempty( rotation_params.htype )
      rotation_params.htype = rotation_params.mode;
    end
  end
  
  noParms = struct( 'model', rotation_params.model, 'mode', rotation_params.mode );
  theseParms = rotation_params.defaults;

  component_directory = fs_path( 'unrotated', 'output', nd, 0, rotation_params );
  component_directory = [pwd filesep component_directory];
  infile = fs_filename( 'mat', rotation_params.htype, 'unrotated', [] );
  infile = [component_directory infile ];

  eval( ['load( ''' infile ''', ''tsum'', ''nr'', ''nc'', ''snr'', ''cvar*'' )'] );
  eval( ['load( ''' Zheader.Model.path ''', ''Gheader'' )' ] );

  component_directory = fs_path( 'rotated', 'output', nd, 0, rotation_params );
  component_directory = [pwd filesep component_directory];

  fn = fs_filename( 'mat', rotation_params.htype, rotation_params.method, theseParms );
  fn = [component_directory fn ];

  ofD = fs_filename( 'txt', rotation_params.htype, rotation_params.method, theseParms );
  ofD = [component_directory ofD ];

  theseParms.var = 'PR';
  oft = fs_filename( 'txt', rotation_params.htype, rotation_params.method, theseParms );
  oft = [component_directory oft ];
  ofn = strrep( oft, '.txt', '.mat' );

  Txt = sprintf( 'Rotating %d components from GZ',nd );

  disp( 'Calculating Variances . . .' );

  nr = Zheader.total_scans;
  if isfield( scan_information, 'GroupList' ) & isfield( scan_information.processing.model.process, 'group_index' )
    if scan_information.processing.model.process.group_index > 0 
      if ( size( scan_information.GroupList,1) >= scan_information.processing.model.process.group_index )
        nr = scan_information.GroupList(scan_information.processing.model.process.group_index).subjectdepth;
      end
    end
  end

  sumDiag = 0;
  if rotation_params.model == 'G'
    if strcmp( rotation_params.htype, 'GA' ) | strcmp( rotation_params.htype, 'GAA' )
      load( Zheader.Contrast.path );
      sumDiag = Aheader.model( Aheader.Aindex).sd(1+strcmp(rotation_params.htype, 'GAA' ));
    else   
      eval( [ 'sumDiag = Gheader.' rotation_params.htype 'Zheader.sum_diagonal;'] );
    end

  else
    load( Zheader.Limits.path);
    if isfield( Hheader.model(Hheader.Hindex).sum_diagonal, rotation_params.htype )
      eval( ['sumDiag = Hheader.model(Hheader.Hindex).sum_diagonal.' rotation_params.htype ';' ] );  
    end
    switch rotation_params.htype
        case 'GMH'
          sumDiag = Hheader.model(Hheader.Hindex).sum_diagonal.GMH;
        case 'GnotH'
          sumDiag = Hheader.model(Hheader.Hindex).sum_diagonal.GC;
        case 'HnotG'
          sumDiag = Hheader.model(Hheader.Hindex).sum_diagonal.BH;
    end
    
%     if strcmp( rotation_params.mode, 'GMH' )
%       eval( [ 'sumDiag = Hheader.model(Hheader.Hindex).sum_diagonal.' rotation_params.htype ';' ] );  
%     else
%       eval( [ 'sumDiag = Hheader.model(Hheader.Hindex).sum_diagonal.' rotation_params.mode ';' ] );
%     end;
  end

  disp( 'Realigning Components . . .' );

  x = strfind( rotation_params.defaults.text, 'ALT' ) ;
  if ( rotation_params.defaults.oblique & ~isempty(x) )
    [cvariance_rotated_tot VR] = alt_component_variance_cmd(Zheader, sumDiag, V, T );
    [aur_variance PR] = alt_component_variance_cmd(Zheader, sumDiag, P, T );
    [ur vr pr cvariance_rotated_tot] = realign_rotated_components( UR, VR, P, cvariance_rotated_tot );

  else
    cvariance_rotated_tot = component_variance_cmd(Zheader, sumDiag, V, tsum );
    [ur vr pr cvariance_rotated_tot] = realign_rotated_components( U, V, P, cvariance_rotated_tot );
  end

  if ( ~isempty(vr) )
    VR = vr;
    UR = ur;
    PR = pr;
  end


   

