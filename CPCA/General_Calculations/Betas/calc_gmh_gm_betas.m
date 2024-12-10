function betas = calc_gmh_gm_betas( fn, Hheader, pos, pop )
global Zheader scan_information 

  if ( nargin < 3 ) pos = 0; end;	% --- send pos = 1 to calculate positive values ---
  if ( nargin < 4 )  pop = [];  end;
  if ~strcmp( class(pop), 'cpca_progress' )
    pop = []; 
  end

  % --- 
  % --- load mat_fil VR ep
  load( fn, 'UR', 'ep' );

  ncomps = size(UR,2); % --- 
  if isempty( Hheader.HH )
    H = load_H_matrix( Hheader, 1 );
    HH = H' * H;
    hh = pinv(HH);
  
    Hheader.HH = HH;
    Hheader.hh = hh;
  end;
  
  ncontrast = size( Hheader.HH,1);

  [H_ID H_Segments] = H_path_spec( Hheader, 'GMH' );
  retrieve_GM( Hheader );
  

  % --- % -----------------------------------
  % --- % betas - pos/neg voxels for component flip checking
  % --- % -----------------------------------
  betas = [];
  thrbetas = struct( 'betas', [] ); 
  compbetas = struct( 'threshold', [] ); 

  if ~isempty(pop)
    pop.setIterations( ncomps * size( ep(1).percentiles, 1 ) * ncontrast );
  end;

  for comp = 1:ncomps % --- 

    compbetas.threshold = []; 
    % --- 

    for thr = 1:size( ep(comp).percentiles, 1 )

      thrbetas.betas = []; 

      threshold = ep(comp).percentiles( thr ).threshold; % --- % top 5% of component weights
      voxels = ep(comp).percentiles( thr).voxels; % --- 

      if threshold ~= 0 & voxels ~= 0
          
        if ( pos == 1 ) % --- 
          inds = find( UR(:,comp) > threshold);
        else % --- 
          inds = find( UR(:,comp) < -1 * threshold);
        end; % --- 

        for contr = 1:ncontrast

          if ~isempty(pop)
            pop.increment();
          end;

          if size(inds, 1) > 0 
            cavg = mean( GM(inds,contr ) );
          else
            cavg = 0;
          end;      
          thrbetas.betas = [thrbetas.betas cavg];
        end
% --- 
      else
        thrbetas.betas = zeros(1, ncontrast );
      end;
      
     compbetas.threshold = [compbetas.threshold; thrbetas ];

    end;

    betas = [betas; compbetas ];

  end;	% --- % --- each component ---
% --- 

