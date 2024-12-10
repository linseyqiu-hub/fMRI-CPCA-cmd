function betas = calc_b_betas_cmd( fn, Bn, pos )

  if ( nargin < 3 ) pos = 0; end	% --- send pos = 1 to calculate positive values ---

  % --= 
  % --= load mat_fil VR ep
  evalc( ['load( ''' fn ''', ''UR'', ''URep'' )'] );
  evalc( ['load( ''' Bn ''', ''B'' )'] );

  nconds = size(URep,1); % --= 
  nbins = 1; % --= 
  ncomps = size(UR,2); % --= 
  % --= 
  bin_start = 1;	% --= % cut off the first 2 bins in beta calcs 
			% to restore full bin length, set this var to 1 

  % --= % -----------------------------------
  % --= % betas - pos/neg voxels for component flip checking
  % --= % -----------------------------------
  betas = []; % --= 
  thrbetas = struct( 'betas', [] ); 
  compbetas = struct( 'threshold', [] ); 

  for comp = 1:ncomps % --= 

    compbetas.threshold = []; 
    % --= 

    for thr = 1:size( URep(comp).percentiles, 1 )

      thrbetas.betas = []; 

      threshold = URep(comp).percentiles(thr).threshold; % --= % top 5% of component weights
      voxels = URep(comp).percentiles(thr).voxels; % --= 

      if voxels > 0 
        % --= 
        % --= ------------------------------------------------
        % --= load the single component
        % --= ------------------------------------------------
        vr_cmp = UR(:,comp); % --= 
        % --= 
        if ( pos == 1 ) % --= 
          x = find( vr_cmp > threshold ); % --= 
        else % --= 
          x = find( vr_cmp < ( threshold * -1 ) ); % --= 
        end % --= 
        % --= 

        comp_voxels = size(x,1); % --= 

%        C_comp = B(:,x);
         C_comp = B(x,comp);

        if ( size(x,1) > 1 ) % --= % ensure that there are loadings 
%          thrbetas.betas = [thrbetas.betas; C_comp ];
          thrbetas.betas = [thrbetas.betas mean(C_comp) ];
        else  % --= % --- there are no loadings ---
%          thrbetas.betas = zeros( nbins, nconds ); % --= 
          thrbetas.betas = [thrbetas.betas 0]; % --= 
        end % --= 	
        
      end
      
      compbetas.threshold = [compbetas.threshold; thrbetas ];
      
    end

    betas = [betas; compbetas ];% --= 

  end	% --= % --- each component ---
% --= 

