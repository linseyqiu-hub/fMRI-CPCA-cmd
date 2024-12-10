function [UR VR PR cvariance_rotated_tot] = realign_rotated_components( U, V, P, cvariance_rotated_tot, pop );

  if ( nargin < 5 )  pop = [];  end;
  if ~strcmp( class(pop), 'cpca_progress' )
    pop = []; 
  end

    VR = [];
    UR = [];
    PR = [];

    % --------------------------------
    % --- make sure components in VR are in same order as percent of variance (descending) 
    % --------------------------------
    varpct = [];
    orig_idx = [];

    for ii = 1:size(V,2)
      varpct = [varpct cvariance_rotated_tot.percent_explained_in_GC(ii)]; 
      orig_idx = [orig_idx ii];
    end;

    [a idx] = sort( varpct, 2, 'descend' );

    Txt = sprintf( 'Rotating %d components from GZ',size(V,2)  );
    if ( sum( idx == orig_idx ) ~= size(V,2) )   % reorder components
      if ~isempty(pop)
        pop.setMessage( Txt );
      end;

      cvar = cvariance_rotated_tot;
      cvariance_rotated_tot.component_variance = [];
      cvariance_rotated_tot.percent_explained_in_Z = [];
      cvariance_rotated_tot.percent_explained_in_GC = [];
      for ii = 1:size(idx,2)
        VR = [VR V(:,idx(ii))];
        UR = [UR U(:,idx(ii))];
        PR = [PR P(:,idx(ii))];

        cvariance_rotated_tot.component_variance = [ cvariance_rotated_tot.component_variance cvar.component_variance(idx(ii)) ];
        cvariance_rotated_tot.percent_explained_in_Z = [ cvariance_rotated_tot.percent_explained_in_Z cvar.percent_explained_in_Z(idx(ii)) ];
        cvariance_rotated_tot.percent_explained_in_GC = [ cvariance_rotated_tot.percent_explained_in_GC cvar.percent_explained_in_GC(idx(ii)) ];
      end;
      clear cvar;
    else
      VR = V;
      UR = U;
      PR = P;
    end;

