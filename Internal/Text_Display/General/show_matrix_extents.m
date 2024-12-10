function show_matrix_extents(fid)
global Zheader ;

  if nargin < 1   fid = 0; end;
  legacy = legacy_define( 'LEGACY' );
  
  % --------------------------------------------------------
  % display the process settings
  % --------------------------------------------------------

  print_and_log( fid, 'Subjects: %3d  [ %6d x %6d ]  Runs: %2d \n', ...
                  Zheader.num_subjects, Zheader.total_scans, Zheader.total_columns, Zheader.num_runs );

  if Zheader.Model.mat_x > 0
    print_and_log( fid, '       G:      [ %6d x %6d ]  %s\n', ...
                  Zheader.Model.mat_x, Zheader.Model.mat_y, Zheader.Model.path );
  end;

  if Zheader.Contrast.mat_x > 0
    print_and_log( fid, '       A:      [ %6d x %6d ]  %s\n', ...
                      Zheader.Contrast.mat_x, Zheader.Contrast.mat_y, Zheader.Contrast.path );
  end;

  if Zheader.Limits.mat_x > 0
    print_and_log( fid, '       H:      [ %6d x %6d ]  %s\n', ...
                      Zheader.Limits.mat_x, Zheader.Limits.mat_y, Zheader.Limits.path );
  end;

  if Zheader.GAZ(legacy.ga_mat,1) > 0
    print_and_log( fid, '      GA:      [ %6d x %6d ]  \n', ...
                      Zheader.GAZ(legacy.ga_mat,1), Zheader.GAZ(legacy.ga_mat,2) );
  end;

  if Zheader.GAZ(legacy.g_mat,1) > 0
    print_and_log( fid, '      GZ:      [ %6d x %6d ]  \n', ...
                      Zheader.GAZ(legacy.gz_mat,1), Zheader.GAZ(legacy.gz_mat,2) );
  end;

  if Zheader.GAZ(legacy.gaz_mat,1) > 0
    print_and_log( fid, '     GAZ:      [ %6d x %6d ]  \n', ...
                      Zheader.GAZ(legacy.gaz_mat,1), Zheader.GAZ(legacy.gaz_mat,2) );
  end;

  if Zheader.GAZ(legacy.gaa_mat,1) > 0
    print_and_log( fid, '     GAA:      [ %6d x %6d ]  \n', ...
                      Zheader.GAZ(legacy.gaa_mat,1), Zheader.GAZ(legacy.gaa_mat,2) );
  end;

  if Zheader.GAZ(legacy.gaaz_mat,1) > 0
    print_and_log( fid, '    GAAZ:      [ %6d x %6d ]  \n', ...
                      Zheader.GAZ(legacy.gaaz_mat,1), Zheader.GAZ(legacy.gaaz_mat,2) );
  end;

  if Zheader.GAZ(legacy.gzh_mat,1) > 0
    print_and_log( fid, '     GZH:      [ %6d x %6d ]  \n', ...
                      Zheader.GAZ(legacy.gzh_mat,1), Zheader.GAZ(legacy.gzh_mat,2) );
  end;

  if Zheader.GAZ(legacy.gazh_mat,1) > 0
    print_and_log( fid, '    GAZH:      [ %6d x %6d ]  \n', ...
                      Zheader.GAZ(legacy.gazh_mat,1), Zheader.GAZ(legacy.gazh_mat,2) );
  end;



