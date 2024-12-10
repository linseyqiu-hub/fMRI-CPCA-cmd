function rs  = define_rotations()

  rs = [];
  define_hrfmax = 1;
  
  % ------------------------------------------
  % always place the default rotation method as the 1st definition
  % ------------------------------------------

  % ------------------------------------------
  % define parameters and default settings for varimax rotation (orthomax: gamma:1)
  % ------------------------------------------
  st = structure_define( 'ROTATIONS' );

  st.method = 'varimax';
  st.description = 'varimax';
  st.parameters.power = 0;
  st.parameters.iterations = 1;
  st.parameters.oblique = 0;
  st.parameters.gamma = 1;
  st.parameters.orthogonal_output = 0;
  st.parameters.apply_to_ur = 1;
  st.parameters.alternate_ur = 0;
  st.parameters.normalize = 1;
  st.parameters.HRF = 0;

  st.defaults.power = 1;
  st.defaults.iterations = 500;
  st.defaults.oblique = 0;
  st.defaults.gamma = 1;
  st.defaults.orthogonal_output = 0;
  st.defaults.apply_to_ur = 0;
  st.defaults.alternate_ur = 0;
  st.defaults.subject_stats = 0;
  st.defaults.normalize = 1;
  st.defaults.calc_variance = 1;
  st.defaults.reltol = sqrt(eps);
  st.defaults.text = '';
  st.defaults.hrf_file = '';
  st.defaults.hrf_mat = '';

  rs = [rs; st];
  rotate_varimax = size( rs,1);

  % ------------------------------------------
  % define parameters and default settings for promax (procrustes) rotation
  % ------------------------------------------
  st = structure_define( 'ROTATIONS' );

  st.method = 'promax';
  st.description = 'promax';
  st.parameters.power = 1;
  st.parameters.iterations = 1;
  st.parameters.oblique = 0;
  st.parameters.gamma = 1;
  st.parameters.orthogonal_output = 0;
  st.parameters.apply_to_ur = 1;
  st.parameters.alternate_ur = 1;
  st.parameters.normalize = 1;
  st.parameters.HRF = 0;

  st.defaults.power = 2;
  st.defaults.iterations = 500;
  st.defaults.oblique = 1;
  st.defaults.gamma = 1;
  st.defaults.orthogonal_output = 0;
  st.defaults.apply_to_ur = 0;
  st.defaults.alternate_ur = 1;
  st.defaults.subject_stats = 0;
  st.defaults.normalize = 1;
  st.defaults.calc_variance = 1;
  st.defaults.reltol = sqrt(eps);
  st.defaults.text = '';
  st.defaults.hrf_file = '';
  st.defaults.hrf_mat = '';

  rs = [rs; st];
  rotate_promax = size( rs,1);

 if ( define_hrfmax )
    % ------------------------------------------
    % define parameters and default settings for HRF max rotation
    % ------------------------------------------
    st = structure_define( 'ROTATIONS' );

    st.method = 'hrfmax';
    st.description = 'hrfmax';
    st.parameters.power = 1;
    st.parameters.iterations = 1;
    st.parameters.oblique = 0;
    st.parameters.gamma = 0;
    st.parameters.orthogonal_output = 0;
    st.parameters.apply_to_ur = 0;
    st.parameters.alternate_ur = 1;
    st.parameters.normalize = 0;
    st.parameters.use_T = 1;
    st.parameters.HRF = 1;

    st.defaults.power = 2;
    st.defaults.iterations = 500000;
    st.defaults.oblique = 0;
    st.defaults.gamma = 0;
    st.defaults.orthogonal_output = 0;
    st.defaults.apply_to_ur = 0;
    st.defaults.alternate_ur = 1;
    st.defaults.subject_stats = 0;
    st.defaults.normalize = 0;
    st.defaults.calc_variance = 1;
    st.defaults.reltol = sqrt(eps);
    st.defaults.text = '';
    st.defaults.T_mat = [];
    st.defaults.T_orient = [];
    st.defaults.hrf_file = '';
    st.defaults.hrf_mat = '';

    rs = [rs; st];
    rotate_hrfmax = size( rs,1);

 end;

  % ------------------------------------------
  % define parameters and default settings for orthomax rotation
  % note: gamma settings define Varimax, Quartimax or Eqimax
  % ------------------------------------------
  st = structure_define( 'ROTATIONS' );

  st.method = 'orthomax';
  st.description = 'orthomax';
  st.parameters.power = 0;
  st.parameters.iterations = 1;
  st.parameters.oblique = 0;
  st.parameters.gamma = 1;
  st.parameters.orthogonal_output = 0;
  st.parameters.apply_to_ur = 1;
  st.parameters.alternate_ur = 0;
  st.parameters.normalize = 1;
  st.parameters.HRF = 0;

  st.defaults.power = 1;
  st.defaults.iterations = 500;
  st.defaults.oblique = 0;
  st.defaults.gamma = 0.5;
  st.defaults.orthogonal_output = 0;
  st.defaults.apply_to_ur = 0;
  st.defaults.alternate_ur = 0;
  st.defaults.subject_stats = 0;
  st.defaults.normalize = 1;
  st.defaults.calc_variance = 1;
  st.defaults.reltol = sqrt(eps);
  st.defaults.text = '';
  st.defaults.hrf_file = '';
  st.defaults.hrf_mat = '';

  rs = [rs; st];
  rotate_orthomax = size( rs,1);




  % ------------------------------------------
  % define parameters and default settings for quartimax rotation (orthomax: gamma:0)
  % ------------------------------------------
  st = structure_define( 'ROTATIONS' );

  st.method = 'quartimax';
  st.description = 'quartimax';
  st.parameters.power = 0;
  st.parameters.iterations = 1;
  st.parameters.oblique = 0;
  st.parameters.gamma = 1;
  st.parameters.orthogonal_output = 0;
  st.parameters.apply_to_ur = 0;
  st.parameters.alternate_ur = 0;
  st.parameters.normalize = 1;
  st.parameters.HRF = 0;

  st.defaults.power = 1;
  st.defaults.iterations = 500;
  st.defaults.oblique = 0;
  st.defaults.gamma = 0;
  st.defaults.orthogonal_output = 0;
  st.defaults.apply_to_ur = 0;
  st.defaults.alternate_ur = 0;
  st.defaults.subject_stats = 0;
  st.defaults.normalize = 1;
  st.defaults.calc_variance = 1;
  st.defaults.reltol = sqrt(eps);
  st.defaults.text = '';
  st.defaults.hrf_file = '';
  st.defaults.hrf_mat = '';

  rs = [rs; st];
  rotate_quartimax = size( rs,1);

  % ------------------------------------------
  % define parameters and default settings for equimax rotation (orthomax: gamma:0.5)
  % the value of 0.5 is questionable, so we will leave this disabled for now
  % ------------------------------------------
  st = structure_define( 'ROTATIONS' );

  st.method = 'equimax';
  st.description = 'equimax';
  st.parameters.power = 0;
  st.parameters.iterations = 1;
  st.parameters.oblique = 1;
  st.parameters.gamma = 0;
  st.parameters.orthogonal_output = 0;
  st.parameters.apply_to_ur = 0;
  st.parameters.normalize = 1;
  st.parameters.HRF = 0;

  st.defaults.power = 1;
  st.defaults.iterations = 500;
  st.defaults.oblique = 0;
  st.defaults.gamma = 0.5;
  st.defaults.orthogonal_output = 0;
  st.defaults.apply_to_ur = 0;
  st.defaults.subject_stats = 0;
  st.defaults.normalize = 1;
  st.defaults.calc_variance = 1;
  st.defaults.reltol = sqrt(eps);
  st.defaults.text = '';
  st.defaults.hrf_file = '';
  st.defaults.hrf_mat = '';

  rs = [rs; st];
  rotate_equimax = size( rs,1);


  % ------------------------------------------
  % define parameters and default settings for HRF procrustes rotation
  % ------------------------------------------
  st = structure_define( 'ROTATIONS' );

  st.method = 'hrf-procrustes';
  st.description = 'HRF procrustes';
  st.parameters.power = 0;
  st.parameters.iterations = 1;
  st.parameters.oblique = 0;
  st.parameters.gamma = 1;
  st.parameters.orthogonal_output = 0;
  st.parameters.apply_to_ur = 0;
  st.parameters.alternate_ur = 0;
  st.parameters.normalize = 0;
  st.parameters.HRF = 1;

  st.defaults.power = 0;
  st.defaults.iterations = 500;
  st.defaults.oblique = 0;
  st.defaults.gamma = 0;
  st.defaults.orthogonal_output = 0;
  st.defaults.apply_to_ur = 0;
  st.defaults.alternate_ur = 0;
  st.defaults.subject_stats = 0;
  st.defaults.normalize = 0;
  st.defaults.calc_variance = 1;
  st.defaults.reltol = sqrt(eps);
  st.defaults.text = '';
  st.defaults.hrf_file = '';
  st.defaults.hrf_mat = '';

  rs = [rs; st];
  rotate_hprocrustes = size( rs,1);


  % ------------------------------------------
  % re-implementation of original procrustes rotation  (Feb 04, 2014)
  % ------------------------------------------
  st = structure_define( 'ROTATIONS' );

  st.method = 'procrustes';
  st.description = 'procrustes';
  st.parameters.power = 0;
  st.parameters.iterations = 1;
  st.parameters.oblique = 0;
  st.parameters.gamma = 1;
  st.parameters.orthogonal_output = 0;
  st.parameters.apply_to_ur = 0;
  st.parameters.alternate_ur = 0;
  st.parameters.normalize = 0;
  st.parameters.HRF = 0;

  st.defaults.power = 0;
  st.defaults.iterations = 500;
  st.defaults.oblique = 0;
  st.defaults.gamma = 0;
  st.defaults.orthogonal_output = 0;
  st.defaults.apply_to_ur = 0;
  st.defaults.alternate_ur = 0;
  st.defaults.subject_stats = 0;
  st.defaults.normalize = 0;
  st.defaults.calc_variance = 1;
  st.defaults.reltol = sqrt(eps);
  st.defaults.text = '';
  st.defaults.hrf_file = '';
  st.defaults.hrf_mat = '';

  rs = [rs; st];
  rotate_procrustes = size( rs,1);
  
  % ------------------------------------------
  % Special Instructions for rotation methods - emergent parameters 
  % initial condition for development of this structure
  % promax - 
  %   selection of oblique enables power
  %   selection of orthogonal disables power
  %
  % type	indicate the type of condition/result action  
  % control	indicate the name of the control in question
  % parameter	indicates the name of the control parameter to get/set
  % set_to	indicates the value to set that parameter to
  %
  % the type field will also indicate what extra parameters to use
  % eg: control_equal  ( regexp split on '_', then eval ( get( si.(1), si.parameter) == si(2) )
  %
  %  special_instructions = struct( ...
  %    'condition', struct ( 'type', 'control_equal', 'control', 'chk_oblique', 'parameter', 'Value', 'equal_to', 1 ), ...
  %    'result', struct ( 'type', 'control_set', 'control', 'ctl_power', 'parameter', 'Enable', 'set_to', 'on' ) ...
  %  );
  %  special_instructions = [special_instructions; struct( ...
  %    'condition', struct ( 'type', 'control_equal', 'control', 'chk_orthogonal', 'parameter', 'Value', 'equal_to', 1 ), ...
  %    'result', struct ( 'type', 'control_set', 'control', 'ctl_power', 'parameter', 'Enable', 'set_to', 'off' ) ...
  %  ) ];



  if ( define_hrfmax )

    rs(rotate_hrfmax).parameters.special = struct( ...
      'condition', struct ( 'type', 'control_equal', 'control', 'chk_oblique', 'parameter', 'Value', 'equal_to', 1 ), ...
      'result',    struct( [ ...
          struct( 'type', 'control_state', 'control', 'ctl_power', 'parameter', 'Enable', 'set_to', 'on' ), ...
          struct( 'type', 'control_state', 'control', 'txt_power', 'parameter', 'Enable', 'set_to', 'on' ), ...
          struct( 'type', 'control_state', 'control', 'chk_alt_UR', 'parameter', 'Enable', 'set_to', 'on' ), ...
          struct( 'type', 'control_set', 'control', 'chk_alt_UR', 'parameter', 'Value', 'set_to', 1 ) ...
        ] ) ...
    );


    rs(rotate_hrfmax).parameters.special = [rs(rotate_hrfmax).parameters.special; struct( ...
      'condition', struct ( 'type', 'control_equal', 'control', 'chk_oblique', 'parameter', 'Value', 'equal_to', 0 ), ...
      'result',    struct( [ ...
          struct( 'type', 'control_state', 'control', 'ctl_power', 'parameter', 'Enable', 'set_to', 'off' ), ...
          struct( 'type', 'control_state', 'control', 'txt_power', 'parameter', 'Enable', 'set_to', 'off' ), ...
          struct( 'type', 'control_state', 'control', 'chk_alt_UR', 'parameter', 'Enable', 'set_to', 'off' ), ...
          struct( 'type', 'control_set', 'control', 'chk_alt_UR', 'parameter', 'Value', 'set_to', 0 ) ...
        ] ) ...
    ) ];


    rs(rotate_hrfmax).parameters.special = [rs(rotate_hrfmax).parameters.special; struct( ...
      'condition', struct ( 'type', 'control_equal', 'control', 'chk_Use_T', 'parameter', 'Value', 'equal_to', 1 ), ...
      'result',    struct( [ ...
          struct( 'type', 'control_state', 'control', 'chk_load_state_file', 'parameter', 'Visible', 'set_to', 'off' ), ...
          struct( 'type', 'control_set', 'control', 'chk_load_state_file', 'parameter', 'Value', 'set_to', 0 ), ...
        ] ) ...
    ) ];


  end;

  rs(rotate_promax).parameters.special = struct( ...
    'condition', struct ( 'type', 'control_equal', 'control', 'chk_oblique', 'parameter', 'Value', 'equal_to', 1 ), ...
    'result',    struct( [ ...
        struct( 'type', 'control_state', 'control', 'ctl_power', 'parameter', 'Enable', 'set_to', 'on' ) ...
	struct( 'type', 'control_state', 'control', 'txt_power', 'parameter', 'Enable', 'set_to', 'on' ) ...
        struct( 'type', 'control_state', 'control', 'chk_alt_UR', 'parameter', 'Enable', 'set_to', 'on' ) ...
        struct( 'type', 'control_set', 'control', 'chk_alt_UR', 'parameter', 'Value', 'set_to', 1 ), ...
	struct( 'type', 'control_state', 'control', 'chk_select_target_vr', 'parameter', 'Visible', 'set_to', 'off' ) ...
      ] ) ...
  );


  rs(rotate_promax).parameters.special = [rs(rotate_promax).parameters.special; struct( ...
    'condition', struct ( 'type', 'control_equal', 'control', 'chk_orthogonal', 'parameter', 'Value', 'equal_to', 1 ), ...
    'result',    struct( [ ...
        struct( 'type', 'control_state', 'control', 'ctl_power', 'parameter', 'Enable', 'set_to', 'on' ) ...
	struct( 'type', 'control_state', 'control', 'txt_power', 'parameter', 'Enable', 'set_to', 'on' ) ...
	struct( 'type', 'control_set', 'control', 'ctl_power', 'parameter', 'Value', 'set_to', 2 ), ...
	struct( 'type', 'control_state', 'control', 'chk_select_target_vr', 'parameter', 'Visible', 'set_to', 'off' ) ...
      ] ) ...
  ) ];


  rs(rotate_promax).parameters.special = [rs(rotate_promax).parameters.special; struct( ...
    'condition', struct( [ ...
        struct( 'type', 'control_state', 'control', 'chk_Use_T', 'parameter', 'Visible', 'set_to', 'off' ), ...
        struct( 'type', 'control_state', 'control', 'chk_load_state_file', 'parameter', 'Visible', 'set_to', 'off' ), ...
        struct( 'type', 'control_state', 'control', 'chk_load_state_file', 'parameter', 'Visible', 'set_to', 'off' ), ...
      ] ), ...
      'result', struct ( 'type', 'no_go' ) ...
   ) ];



  if exist( 'rotate_orthomax', 'var' )
    rs(rotate_orthomax).parameters.special = [rs(rotate_orthomax).parameters.special; struct( ...
    'condition', struct( [ ...
        struct( 'type', 'control_state', 'control', 'chk_Use_T', 'parameter', 'Visible', 'set_to', 'off' ), ...
        struct( 'type', 'control_state', 'control', 'chk_load_state_file', 'parameter', 'Visible', 'set_to', 'off' ), ...
	struct( 'type', 'control_state', 'control', 'chk_select_target_vr', 'parameter', 'Visible', 'set_to', 'off' ) ...
      ] ), ...
      'result', struct ( 'type', 'no_go' ) ...
    ) ];
  end;



  if exist( 'rotate_varimax', 'var' )
    rs(rotate_varimax).parameters.special = [rs(rotate_varimax).parameters.special; struct( ...
    'condition', struct( [ ...
        struct( 'type', 'control_state', 'control', 'chk_Use_T', 'parameter', 'Visible', 'set_to', 'off' ), ...
        struct( 'type', 'control_state', 'control', 'chk_load_state_file', 'parameter', 'Visible', 'set_to', 'off' ), ...
	struct( 'type', 'control_state', 'control', 'chk_select_target_vr', 'parameter', 'Visible', 'set_to', 'off' ) ...
      ] ), ...
      'result', struct ( 'type', 'no_go' ) ...
    ) ];
  end;

  if exist( 'rotate_equimax', 'var' )
    rs(rotate_equimax).parameters.special = [rs(rotate_equimax).parameters.special; struct( ...
    'condition', struct( [ ...
        struct( 'type', 'control_state', 'control', 'chk_Use_T', 'parameter', 'Visible', 'set_to', 'off' ), ...
        struct( 'type', 'control_state', 'control', 'chk_load_state_file', 'parameter', 'Visible', 'set_to', 'off' ), ...
	    struct( 'type', 'control_state', 'control', 'chk_select_target_vr', 'parameter', 'Visible', 'set_to', 'off' ) ...
        ] ), ...
      'result', struct ( 'type', 'no_go' ) ...
   ) ];
  end;


  
  %struct( 'type', 'control_set',   'control', 'chk_oblique',          'parameter', 'Value',   'set_to', 0 ), ...
  %struct( 'type', 'control_set',   'control', 'chk_alt_UR',           'parameter', 'Value',   'set_to', 0 ), ...

  if exist( 'rotate_hprocrustes', 'var' )
    rs(rotate_hprocrustes).parameters.special = struct( ...
      'condition',    struct( [ ...
        struct( 'type', 'control_state', 'control', 'chk_Use_T',            'parameter', 'Visible', 'set_to', 'off' ), ...
        struct( 'type', 'control_state', 'control', 'chk_apply_to_UR',      'parameter', 'Visible', 'set_to', 'on' ), ...
        struct( 'type', 'control_state', 'control', 'ctl_power',            'parameter', 'Enable',  'set_to', 'off' ), ...
	struct( 'type', 'control_state', 'control', 'txt_power',            'parameter', 'Enable',  'set_to', 'off' ), ...
        struct( 'type', 'control_state', 'control', 'lbl_iterations',       'parameter', 'Enable',  'set_to', 'off' ), ...
        struct( 'type', 'control_state', 'control', 'txt_iterations',       'parameter', 'Enable',  'set_to', 'off' ), ...
        struct( 'type', 'control_state', 'control', 'ctl_gamma',            'parameter', 'Enable',  'set_to', 'off' ), ...
        struct( 'type', 'control_state', 'control', 'chk_alt_UR',           'parameter', 'Enable',  'set_to', 'off' ), ...
        struct( 'type', 'control_state', 'control', 'chk_load_state_file',  'parameter', 'Visible', 'set_to', 'off' ), ...
	struct( 'type', 'control_state', 'control', 'chk_select_target_vr', 'parameter', 'Visible', 'set_to', 'off' ) ...
	struct( 'type', 'control_state', 'control', 'chk_apply_to_UR',      'parameter', 'String',  'set_to', ' Single Shape per Comp'), ...
	struct( 'type', 'control_state', 'control', 'chk_select_target_vr', 'parameter', 'String',  'set_to', 'Select Target VR' ) ...
      ] ) ...
    );

  end;

  
  % ------------------------------------------
  % re-implementation of original procrustes rotation  (Feb 04, 2014)
  % ------------------------------------------
  if exist( 'rotate_procrustes', 'var' )
    rs(rotate_procrustes).parameters.special = struct( ...
      'condition',    struct( [ ...
        struct( 'type', 'control_state', 'control', 'chk_Use_T', 'parameter', 'Visible', 'set_to', 'off' ), ...
        struct( 'type', 'control_state', 'control', 'ctl_power', 'parameter', 'Enable', 'set_to', 'off' ), ...
	struct( 'type', 'control_state', 'control', 'txt_power', 'parameter', 'Enable', 'set_to', 'off' ), ...
        struct( 'type', 'control_state', 'control', 'lbl_iterations', 'parameter', 'Enable', 'set_to', 'off' ), ...
        struct( 'type', 'control_state', 'control', 'txt_iterations', 'parameter', 'Enable', 'set_to', 'off' ), ...
        struct( 'type', 'control_state', 'control', 'ctl_gamma', 'parameter', 'Enable', 'set_to', 'off' ), ...
        struct( 'type', 'control_state', 'control', 'chk_alt_UR', 'parameter', 'Enable', 'set_to', 'off' ), ...
        struct( 'type', 'control_set', 'control', 'chk_alt_UR', 'parameter', 'Value', 'set_to', 0 ), ...
        struct( 'type', 'control_state', 'control', 'chk_load_state_file', 'parameter', 'Visible', 'set_to', 'off' ), ...
	struct( 'type', 'control_state', 'control', 'chk_select_target_vr', 'parameter', 'Visible', 'set_to', 'on' ) ...
	struct( 'type', 'control_state', 'control', 'chk_select_target_vr', 'parameter', 'String', 'set_to', 'Select Target VR' ) ...
      ] ) ...
    );

  end;
  
