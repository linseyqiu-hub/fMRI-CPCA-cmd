function Good_T = hrfmax( P, U, shapes, iterations, load_state, pop )

  Good_T = [];
  
  if ( nargin < 3 )	
    error( 'hrfmax: need at least 3 parameters.' );
  end;

  if ( nargin < 4 )	
    iterations = 500000;		
  end;

  if ( nargin < 5 )	
    load_state = 0;		
  end;

  if ( nargin < 6 )	
    pop = 0;  	
  end;
  if ~strcmp( class(pop), 'cpca_progress' )
    pop = []; 
  end

  Txt = sprintf( 'HRFMAX Rotation %d components',size(P,2) );

  if ~isempty(pop)
    pop.setForHRFMAX();
    pop.activateSaveState();
    pop.setMessage( [ 'iterations ' num2str( iterations ) ] );
    pop.setComment( 'Calculating T Matrix' );
    pop.setIterations( iterations, pop.SECONDARY );
  end;
  
  
  if load_state
    load hrfmax_state

  else
      
    tm = struct( 'per_iter', 0.0072, 'estimated', 0, 'display', '', 'start_time', 0, 'duration', 0 );
    state = struct( 'loop_start', 1, ...
                  'timers', tm, ...
                  'Good_T', [], ...
                  'totcorr', 0, ...
                  'info', [0;0;0], ...
                  'U', U, ...
                  'P', P, ...
                  'iterations', iterations, ...
                  'iteration_gap', 1000, ...
                  'num_shapes', 0, ...
                  'num_bins', 0, ...
                  'num_components', 0, ...
                  'num_all_conditions', 0, ...
                  'all_shapes', 0, ...
                  'this_pct', 1, ...
                  'all_component_max_correlations', [] ...
    );

    if ( state.iterations < 20001 )
      state.iteration_gap = 100;
    end


    [state.num_shapes state.num_bins] = size(shapes);
    state.num_components = size(P,2);
    state.num_all_conditions = floor( size(state.P,1)/state.num_bins );		% actually the number of conditions * (subects * runs)

    if ( state.num_all_conditions * state.num_bins  ~= size(P,1) )
      error( 'P_unrotated and shapes do not correspond to each other' );
    end;

    state.all_shapes = zeros( size(shapes,1), size(shapes, 2) * state.num_all_conditions );
    ec = 0;
    for ii = 1:state.num_all_conditions
      sc = ec + 1;
      ec = sc + size(shapes,2) - 1;
      state.all_shapes(:, sc:ec) = shapes;
    end;

    fprintf( ' - T Calculation: %7d/%7d\n', 1, state.iterations );

    state.timers.estimated = state.timers.per_iter * state.iterations;	%initial estimate of 1 hour for a 500,000 iteration
    state.timers.display = format_toc( state.timers.estimated, 'Est. Dur. ');
    state.timers.start_time = clock;

    state.all_component_max_correlations = zeros(1, state.num_components );
 
  end;

  if ~isempty(pop)
%    pop.setMessage( Txt,  [ 'iterations ' num2str( iterations ) ], 'Calculating T Matrix' );
    pop.setMessage( [ 'iterations ' num2str( iterations ) ] );
    pop.setComment( 'Calculating T Matrix' );
    pop.setIterations( iterations, pop.SECONDARY );
    pop.setPercent( state.this_pct, pop.SECONDARY );
    pop.setStateInfo( state.info(1), state.info(2), state.info(3) );
  end;

  Good_T = calc_href_T_matrix( state, pop );
%  Good_T = state.Good_T;
  
  if ~isempty(pop)
    pop.deactivateSaveState();
    pop.unsetHRFMAX();
  end;

  


% -----------------------------------
% main calculation process - allows for state change
% -----------------------------------
function this_T = calc_href_T_matrix( state, pop )

  for loop = state.loop_start:state.iterations

    if ( floor(loop/state.iteration_gap)-(loop/state.iteration_gap) == 0 )
      fprintf( '\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b%7d/%7d', loop, state.iterations );
      
      state.info = pop.getStateInfo();
      save hrfmax_state state
     
    end;

    if ~isempty(pop)
      x = pop.getSaveState();
      if x
        state.info = pop.getStateInfo();
        save hrfmax_state state
        state.Good_T = [];
        pop.unsetHRFMAX();
        return;
      end;

      pop.incrementHrfmax();
      state.this_pct = state.this_pct + 1;
    end;


    % -----------------------------------
    % start with a random rotation matrix
    % -----------------------------------
    T = rand_T( state.U );
    
    % -----------------------------------
    % calculate our Rotated P using current random generated T
    % -----------------------------------
    RotatedP = state.P * inv(T');
    
    state.all_component_max_correlations = state.all_component_max_correlations .* 0;
    for this_component = 1:state.num_components 
      x = abs(corrcoef([RotatedP(:,this_component) state.all_shapes' ]));
      state.all_component_max_correlations( this_component ) = max( x(2:end, 1 ) );
    end;
 
    volume = prod(state.all_component_max_correlations );
     
    % -----------------------------------
    % determine if higher correlation on new T
    % -----------------------------------
    if volume > state.totcorr
      state.totcorr = volume;
      state.Good_T = T;
      this_T = T;
      
      if ~isempty(pop)
        pop.flagTChange( pop.SECONDARY );
      end
      save hrfmax_T T
        
    end

% if ~ mod( loop, 1000 )    
%   disp( state.Good_T );
%   disp( '' );
% end

    state.loop_start = loop;
  end

  delete hrfmax_state.mat
