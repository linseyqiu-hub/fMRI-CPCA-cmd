function label_table = woodward_label_coord(table, peaks, wood_coords)

numex = numel(wood_coords);

% compare peaks to all the networks' coordinates
for i = 1:numex
    [~, p] = dsearchn(wood_coords{i}, peaks(:,1:3));
    p = arrayfun(@num2str, p, 'UniformOutput', false);
    table{:,i+5} = p;
end

label_table = table;

end
