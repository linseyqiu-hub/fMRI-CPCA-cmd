function [PR NEW_T COR_ORTH] = hrf_procrustes(p_unrot, shapes, rotation_specs, one_shape_per_component, GAtyp, pop)
global Zheader scan_information

PR = [];
NEW_T = [];
COR_ORTH = [];

  if ( nargin < 4 ),  one_shape_per_component = 0;   end
  if ( nargin < 5 ),  GAtyp = '';  end;
  if ( nargin < 6 ),  pop = [];  end;
  if ~isa( pop, 'cpca_progress'),     pop = [];   end


% shapes is a #timebins x #shapes matrix and contains all hrf shapes to try
load( Zheader.Model.path, 'Gheader');

if ~exist( 'Gheader', 'var' )
  disp ( 'WTF!!' );
  return
end

nConditions = Gheader.conditions;
nBins = Gheader.bins;

if ~isempty( GAtyp )
  if strcmp( GAtyp, 'GA' )
    nConditions = Gheader.contrasts;
    nBins = Gheader.contrast_bins;
  end
end

% Get parameters I
num_components = size(p_unrot,2);

%% Build target_shapes
% target_shapes allow different shapes in different conditions

if ~isempty( pop )
 pop.setMessage( 'Building Target Shapes' );
end

if nConditions == 1 || one_shape_per_component

    % append shapes #subject*#conditions*#timebins 
    target_shapes = repmat(shapes, Zheader.num_subjects*nConditions, 1);
    
    % check which subjects encode which conditions
    isEncodedVector = zeros(Zheader.num_subjects*nConditions*nBins, 1);
    for subj_i=1:Zheader.num_subjects
        for cond_i=1:nConditions
            rows = (((subj_i-1)*nConditions*nBins+(cond_i-1)*nBins+1):((subj_i-1)*nConditions*nBins+cond_i*nBins));
            isEncodedVector(rows,1) = repmat(isEncoded(subj_i, cond_i), nBins, 1);
        end
    end
    
    % take out some rows if subjects do not encode all conditions 
    target_shapes = target_shapes(logical(isEncodedVector),:);    
    
else
    
    % Add possible null-shape
    shapes = horzcat(shapes, zeros(nBins, 1));
    num_shapes = size(shapes, 2);

    % Compute possible shape - condition - component combinations
    C = compute_combos(num_shapes, nConditions, pop);

    % First columns of target_shapes are same shapes for all conditions
%    target_shapes_all_conditions = zeros(Gheader.conditions*Gheader.bins*Zheader.num_subjects, size(C,1));
target_shapes = zeros(Zheader.conditions.allEncoded*nBins, size(C,1));

% --- repmat runs into memory errors
%    target_shapes_all_conditions(:,1:num_shapes) = repmat(shapes, Zheader.num_subjects*Gheader.conditions, 1);
    sr = 0;
    for ii = 1:Zheader.num_subjects  % *Gheader.conditions

      for cond = 1:nConditions
        if isEncoded( ii, cond )
          target_shapes(sr+1:sr+size(shapes,1),1:num_shapes) = shapes;
          sr = sr + size(shapes,1 );
        end;
      end;
    end

    % Allow different shapes in different conditions
    for ii=1:size(C,1)
% %        cur_shape = zeros(Gheader.conditions*Gheader.bins, 1);
%         cur_shape = [];
%         for cond_i=1:Gheader.conditions
%             shape_to_insert = shapes(:,C(ii, cond_i));
%             rows = (((cond_i-1)*Gheader.bins+1):(cond_i*Gheader.bins));
%             cur_shape(rows, :) = shape_to_insert;
%         end
% %        target_shapes_all_conditions(:,(num_shapes-1)+i) = repmat(cur_shape, Zheader.num_subjects, 1);
        sr = 0;
        for jj = 1:Zheader.num_subjects   
          for cond_i=1:nConditions
            if isEncoded( jj, cond_i )
              target_shapes(sr+1:sr+size(shapes,1),(num_shapes-1)+ii) = shapes(:,C(ii, cond_i));
              sr = sr + size(shapes, 1 );
            end
          end
        end
    end
       
end


% Start values for finding best fit
PR = p_unrot;
NEW_T = eye(num_components);
COR_ORTH = 0;

num_target_shapes = size(target_shapes, 2);
combos = nchoosek(1:num_target_shapes, num_components);

  if ~isempty( pop )
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
        [L, ~, M] = svd(p_model' * p_unrot);
        t_procr = M * L';
        p_procr = p_unrot * t_procr;
        
        % Goodness of Fit -- Orthogonal Rotation
        y = abs(corrcoef([p_procr p_model]));
        y = y((num_components+1):end, 1:num_components);
        p_procr_volume_cor = prod(max(y, [], 1));
        
        if p_procr_volume_cor > COR_ORTH
            PR = p_procr;
            NEW_T = t_procr;
            COR_ORTH = p_procr_volume_cor;
%            output.best_combo_procr = combos(i,:);
        end
        
    end
    
    if ~isempty( pop )
    pop.increment( pop.SECONDARY );
    end

end

if ~isempty( pop )
pop.setComment( '' );
end

