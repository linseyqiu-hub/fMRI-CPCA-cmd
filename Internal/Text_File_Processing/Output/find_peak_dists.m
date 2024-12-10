% function to find the distances between component and network. trunc is
% the number of points to remove when calculating a truncated mean, and the
% fun and wood_weights inputs determind the type of mean that is taken.
function find_peak_dists(f,wood_coords,peaks,wood_labels,trunc,fun, direction, wood_weights)
        numex = numel(wood_coords);
        min_score = inf;
        all_scores = zeros(numex,1);
        
        if nargin < 8
            for c = 1:numel(wood_coords)
                if direction == 'ctoe'
                    [~, d] = fun(wood_coords{c}, peaks(:,1:3));
                elseif direction == 'etoc'
                    [~, d] = fun(peaks(:,1:3), wood_coords{c});
                end

                if ~(size(d,1) > trunc)
                    return;
                end
                
                asc = sort(d);
        
                dist = mean(asc(1:end-trunc));
                if dist < min_score
                    min_score = dist;
                end
                all_scores(c) = dist;
            end
        else
            for c = 1:numel(wood_coords)
                if direction == 'ctoe'
                    [in, d] = fun(wood_coords{c}, peaks(:,1:3));
                elseif direction == 'etoc'
                    [in, d] = fun(peaks(:,1:3), wood_coords{c});
                end

                if sum(in) == size(peaks,1)
                    use_weights = wood_weights{c};
                    use_weights = use_weights(in);
                    dist = d'*use_weights;
                else
                    dist = d'*wood_weights{c};
                end
                
                if dist < min_score
                    min_score = dist;
                end
                all_scores(c) = dist;
            end
        end
        
        ind = kmin(all_scores-min_score,numex);
        
        for i = 1:numex
            label = wood_labels{ind(i)};
            fprintf(f, ['\n' num2str(i) '. ' label ' (' num2str(ind(i)) ')\t' num2str(all_scores(ind(i))) ' (' num2str(all_scores(ind(i))-min_score) ')']);
        end
    end