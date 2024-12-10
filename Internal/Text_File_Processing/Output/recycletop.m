% finds the next closest distance, called when the current closest is
% already in use
function new_top = recycletop(top, mat)
    new_top = top;

    [~,indexes] = sort(mat);
    top_row_vals = zeros(size(top,1),1);
    
    if size(mat,1) == 1
        for i=1:size(top,1)
            if ~(top(i) == 1)
                new_top(i) = 0;
            end
        end
        return;
    else
        for i=1:size(top,1)
            if ~(top(i) == 0)
                top_row_vals(i) = mat(top(i),i);
            else
                top_row_vals(i) = 1000;
            end
        end
    end

    % find the first duplicate!
    first = 1;
    for col = 1:size(top,1)
        if first == 1
            number = top(col);
            if ~(number == 0)
                match = find(top == number); % indexes of duplicates to this number
                if ~(size(match,1) == 1)
                    compare = top_row_vals(match);
                    [~, idx] = min(compare);
                    for loop = 1:size(compare,1)
                        if ~(loop == idx)
                           row = find(indexes(:,match(loop)) == number);
                           if row < size(indexes,1)
                               new_top(match(loop)) = indexes(row+1,match(loop));
                           else
                               new_top(match(loop)) = 0;
                           end
                        end
                    end
                    first = 0;
                end
            end
        else
            return;
        end
    end
end
