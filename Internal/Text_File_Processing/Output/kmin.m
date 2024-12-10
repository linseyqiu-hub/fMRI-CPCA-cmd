% define kmin cause mink doesn't exist in this matlab version;
% finds the indexes of the k minimum values
function indexes = kmin(array, k)
    indexes = [];
    sorted = sort(array);
    for loop = 1:k
        my_index = find(array == sorted(loop));
        if size(my_index,1) == 1
            indexes = [indexes, my_index];
        else
            for i=1:size(my_index)
                if ~ismember(my_index(i),indexes)
                    indexes = [indexes, my_index(i)];
                    break;
                end
            end
        end
    end
end
