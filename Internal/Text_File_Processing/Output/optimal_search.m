% finds the distances to the nearest point in component for every point in
% exemplar, such that no point is used more than once
function [chosen,optimal] = optimal_search(component, exemplar)

    optimal = zeros(size(exemplar,1),1);
    mat = zeros(size(component,1),size(exemplar,1));

    % fill in the matrix with distances from each coords to every other coord
    for inner_i = 1:size(component,1)
        for inner_j = 1:size(exemplar,1)
            euc_dist = euclid(component(inner_i,:),exemplar(inner_j,:));
            mat(inner_i,inner_j) = euc_dist;
        end
    end

    [~,indexes] = sort(mat);
    top_row = indexes(1,:)';

    chopped = top_row;
    max_num = min(size(mat,1),size(mat,2));

    if max_num == size(top_row,1)
        while ~(size(unique(top_row),1) == max_num)
            top_row = recycletop(top_row, mat);
        end
    else
        while ~(size(chopped,1) == max_num)
            top_row = recycletop(top_row, mat);
            chopped = top_row(top_row > 0);
        end
    end


    for col = 1:size(top_row,1)
        if ~(top_row(col) == 0)
           optimal(col) = mat(top_row(col),col);
        else
           optimal(col) = 1000;
        end
    end

    chosen = ~(optimal == 1000);
    optimal = optimal(chosen);
end
