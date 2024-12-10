% to build a table of distances for the given networks, given a list of distances
function table = build_dist_table(wood_coords,coords,max_coords,wood_labels,fun)
    table = cell2table(cell(max_coords, size(wood_labels,2)*5));
    % build the table of stuff
    for n = 1:size(wood_labels,2)
        [in, dist] = fun(coords, wood_coords{n});
        table{1,(n-1)*5+1} = {wood_labels{1,n}};
        table{2,(n-1)*5+1} = {'coordinate'};
        table{2,(n-1)*5+2} = {'x'};
        table{2,(n-1)*5+3} = {'y'};
        table{2,(n-1)*5+4} = {'z'};
        table{2,(n-1)*5+5} = {'distance'};
        skips = 0;
        for m = 1:size(wood_coords{n},1)
            table{2+m,(n-1)*5+1} = {['(' num2str(wood_coords{n}(m,1)) ', ' num2str(wood_coords{n}(m,2)) ', ' num2str(wood_coords{n}(m,3)) ')']};
            table{2+m,(n-1)*5+2} = {wood_coords{n}(m, 1)};
            table{2+m,(n-1)*5+3} = {wood_coords{n}(m, 2)};
            table{2+m,(n-1)*5+4} = {wood_coords{n}(m, 3)};
            if (size(dist,1) == size(wood_coords{n},1)) 
                table{2+m,(n-1)*5+5} = {dist(m)};
            elseif (in(m) == 1)
                table{2+m,(n-1)*5+5} = {dist(m-skips)};
            else
                table{2+m,(n-1)*5+5} = {'No match'};
                skips = skips + 1;
            end
        end
    end 
end