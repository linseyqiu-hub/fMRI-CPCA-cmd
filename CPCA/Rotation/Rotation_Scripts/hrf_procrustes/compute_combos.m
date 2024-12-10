function [C] = compute_combos(num_shapes,num_conditions, pop )

    % computes all combinations to arrange all target shape columns as components
  if ( nargin < 3 )  pop = [];  end;
  if ~strcmp( class(pop), 'cpca_progress' )
    pop = []; 
  end

  if ~isempty(pop)
    pop.setComment( 'Determining Permutations' );
  end
    % get all combinations, without order
    C_base = nchoosek(1:num_shapes,num_conditions);

    % get all combinations to order the columns in C_base
    col_combos = perms(1:num_conditions);
    
  if ~isempty(pop)
    pop.setComment( ['Determining Permutations ( ' num2str(size(col_combos,1)) ' )' ] );
    pop.setIterations( size(col_combos,1), pop.SECONDARY );
    pop.setPercent( 0, pop.SECONDARY );
  end
    
    % prelocate output C
    C = zeros(size(col_combos,1)*size(C_base,1),num_conditions);
    % for each combination to order the columns in C_base
    for cond=1:size(col_combos,1)
        % select the rows
        rows = (1+cond*size(C_base,1)-size(C_base,1)):cond*size(C_base,1);
        % append the combination below the C we got so far
        C(rows,:) = C_base(:,col_combos(cond,:));
        if ~isempty(pop)
          pop.increment( pop.SECONDARY );
        end
    end
    
  if ~isempty(pop)
    pop.setComment( '' );
  end

end

