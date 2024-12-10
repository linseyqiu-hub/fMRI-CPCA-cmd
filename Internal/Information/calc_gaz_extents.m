function calc_gaz_extents()
% calculate the extents of GA and GAZ matrices
global Zheader ;

  legacy = legacy_define( 'LEGACY' );
  if isempty( Zheader.GAZ )
    Zheader.GAZ = zeros( legacy.g_index, 3 );       
  end
  
  % ------------------------
  % G' * Z
  % ------------------------
  Zheader.GAZ(legacy.gz_mat,1)= Zheader.GAZ(legacy.g_mat,2);
  Zheader.GAZ(legacy.gz_mat,2)= Zheader.total_columns;
  Zheader.GAZ(legacy.gz_mat,3) = ceil( (Zheader.GAZ(legacy.gz_mat,1) * Zheader.GAZ(legacy.gz_mat,2) * legacy.size_QWORD) /  legacy.size_MB);  



  % ------------------------
  % GA' * Z
  % ------------------------
  if ( Zheader.Contrast.mat_exists )
    Zheader.GAZ(legacy.ga_mat,1) = Zheader.GAZ(legacy.g_mat,1);  
    Zheader.GAZ(legacy.ga_mat,2) = Zheader.GAZ(legacy.a_mat,2);
    Zheader.GAZ(legacy.ga_mat,3) = ceil( (Zheader.GAZ(legacy.ga_mat,1) * Zheader.GAZ(legacy.ga_mat,2) * legacy.size_QWORD) / legacy.size_MB);  

    Zheader.GAZ(legacy.gaz_mat,1)= Zheader.GAZ(legacy.ga_mat,2);
    Zheader.GAZ(legacy.gaz_mat,2)= Zheader.total_columns;
    Zheader.GAZ(legacy.gaz_mat,3) = ceil( (Zheader.GAZ(legacy.gaz_mat,1) * Zheader.GAZ(legacy.gaz_mat,2) * legacy.size_QWORD) /  legacy.size_MB);  

  else
    Zheader.GAZ(legacy.ga_mat,:)=[0 0 0];
    Zheader.GAZ(legacy.gaz_mat,:)=[0 0 0];

  end; % A matrix exists


  if ( Zheader.Limits.mat_exists )

    % ------------------------
    % G' * Z * H
    % ------------------------
    Zheader.GAZ(legacy.gzh_mat,1)= Zheader.GAZ(legacy.g_mat,2);
    Zheader.GAZ(legacy.gzh_mat,2)= Zheader.GAZ(legacy.h_mat,2);
    Zheader.GAZ(legacy.gzh_mat,3) = ceil( (Zheader.GAZ(legacy.gzh_mat,1) * Zheader.GAZ(legacy.gzh_mat,2) * legacy.size_QWORD) /  legacy.size_MB);  

    % ------------------------
    % GA' * Z * H
    % ------------------------

    if ( Zheader.Contrast.mat_exists )

      Zheader.GAZ(legacy.gazh_mat,1)= Zheader.GAZ(legacy.a_mat,2);
      Zheader.GAZ(legacy.gazh_mat,2)= Zheader.GAZ(legacy.h_mat,2);
      Zheader.GAZ(legacy.gazh_mat,3) = ceil( (Zheader.GAZ(legacy.gazh_mat,1) * Zheader.GAZ(legacy.gazh_mat,2) * legacy.size_QWORD) /  legacy.size_MB);  

    else
      Zheader.GAZ(legacy.gazh_mat,:)=[0 0 0];

    end; % A Matrix exists

  else
    Zheader.GAZ(legacy.gzh_mat,:)=[0 0 0];
    Zheader.GAZ(legacy.gazh_mat,:)=[0 0 0];

  end;

