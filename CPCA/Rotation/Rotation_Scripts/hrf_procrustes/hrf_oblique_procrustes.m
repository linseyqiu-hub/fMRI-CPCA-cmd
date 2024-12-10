function [PR NEW_T SS] = hrf_oblique_procrustes(p_unrot, shapes, rotation_specs, one_shape_per_component, pop)
global Zheader scan_information

PR = [];
NEW_T = [];
SS = [];

if nargin < 4
    one_shape_per_component = 0;
end
  if ( nargin < 5 )  pop = [];  end;
  if ~strcmp( class(pop), 'cpca_progress' )
    pop = []; 
  end

% shapes is a #timebins x #shapes matrix and contains all hrf shapes to try
load( Zheader.Model.path, 'Gheader');

if ~exist( 'Gheader', 'var' )
  disp ( 'WTF!!' );
  return
end

% Get parameters I
num_components = size(p_unrot,2);

%% Build target_shapes
% target_shapes allow different shapes in different conditions
 if ~isempty(pop)
   pop.setMessage( 'Building Target Shapes' );
 end

if Gheader.conditions == 1 || one_shape_per_component

    % append shapes #subject*#conditions*#timebins 
    target_shapes = repmat(shapes, Zheader.num_subjects*Gheader.conditions, 1);
    
    % check which subjects encode which conditions
    isEncodedVector = zeros(Zheader.num_subjects*Gheader.conditions*Gheader.bins, 1);
    for subj_i=1:Zheader.num_subjects
        for cond_i=1:Gheader.conditions
            rows = (((subj_i-1)*Gheader.conditions*Gheader.bins+(cond_i-1)*Gheader.bins+1):((subj_i-1)*Gheader.conditions*Gheader.bins+cond_i*Gheader.bins));
            isEncodedVector(rows,1) = repmat(isEncoded(subj_i, cond_i), Gheader.bins, 1);
        end
    end
    
    % take out some rows if subjects do not encode all conditions 
    target_shapes = target_shapes(logical(isEncodedVector),:);    
    
else
    
    % Add possible null-shape
    shapes = horzcat(shapes, zeros(Gheader.bins, 1));
    num_shapes = size(shapes, 2);

    % Compute possible shape - condition - component combinations
    C = compute_combos(num_shapes, Gheader.conditions, pop);

    % First columns of target_shapes are same shapes for all conditions
    target_shapes_all_conditions = zeros(Gheader.conditions*Gheader.bins*Zheader.num_subjects, size(C,1));
    target_shapes_all_conditions(:,1:num_shapes) = repmat(shapes, Zheader.num_subjects*Gheader.conditions, 1);
    
    % Allow different shapes in different conditions
    for i=1:size(C,1)
        cur_shape = zeros(Gheader.conditions*Gheader.bins, 1);
        for cond_i=1:Gheader.conditions
            shape_to_insert = shapes(:,C(i, cond_i));
            rows = (((cond_i-1)*Gheader.bins+1):(cond_i*Gheader.bins));
            cur_shape(rows, :) = shape_to_insert;
        end
        target_shapes_all_conditions(:,(num_shapes-1)+i) = repmat(cur_shape, Zheader.num_subjects, 1);
    end
    
    isEncodedVector = zeros(Zheader.num_subjects*Gheader.conditions*Gheader.bins, 1);
    for subj_i=1:Zheader.num_subjects
        for cond_i=1:Gheader.conditions
            rows = (((subj_i-1)*Gheader.conditions*Gheader.bins+(cond_i-1)*Gheader.bins+1):((subj_i-1)*Gheader.conditions*Gheader.bins+cond_i*Gheader.bins));
            isEncodedVector(rows,1) = repmat(isEncoded(subj_i, cond_i), Gheader.bins, 1);
        end
    end
    
    target_shapes = target_shapes_all_conditions(logical(isEncodedVector),:);
    
end

% Start values for finding best fit
PR = p_unrot;
NEW_T = eye(num_components);
SS = Inf;

num_target_shapes = size(target_shapes, 2);
combos = nchoosek(1:num_target_shapes, num_components);
  if ~isempty(pop)
    pop.setMessage( 'Performing Rotation' );
    pop.setComment( ['Iterations: ' num2str(size(combos,1)) ] );
    pop.setIterations( size(combos,1), pop.SECONDARY );
    pop.setPercent( 0, pop.SECONDARY );
  end

for i = 1:size(combos,1)
    
    % Try one possible Target Matrix
    p_model = target_shapes(:,combos(i,:));
    
    if (rank(p_model) == num_components)
        
        % Orthogonal Procrustes Rotation
        t_obl = p_unrot \ p_model;
        t_obl = t_obl * diag(sqrt(diag((t_obl'*t_obl)\eye(size(p_model,2)))));
        p_obl = p_unrot * t_obl;
        
        % Ensure that rotated p contains only real numbers
        if isreal(p_obl)
            
            %% Goodness of Fit -- Oblique Rotation
            
            sum_squares_obl = sum(sum((p_model-p_obl).^2));
            
            if sum_squares_obl < SS
                PR = p_obl;
                NEW_T = t_obl;
                SS = sum_squares_obl;
            end
            
        end
        
    end
    if ~isempty(pop)
      pop.increment( pop.SECONDARY );
   end
end

if ~isempty(pop)
  pop.setComment( '' );
end

