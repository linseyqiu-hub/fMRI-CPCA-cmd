function exemplar_to_component(f, coords, wood_labels, wood_coords)

max_coords = 0;
for i = 1:size(wood_labels,2)
    s = size(wood_coords{i},1);
    if s > max_coords
        max_coords = s;
    end
end

table = build_dist_table(wood_coords,coords,max_coords,wood_labels,@dsearchn);
otable = build_dist_table(wood_coords,coords,max_coords,wood_labels,@optimal_search);

fprintf(f, '\n\nDistances from each exemplar to the component\n\n');
table_print(f,table,max_coords);

fprintf(f, '\n\nAveraged distances from each exemplar to the component');

fprintf(f, '\n\nUnweighted\tDistance');
find_peak_dists(f,wood_coords,coords,wood_labels,0,@dsearchn, 'etoc');
fprintf(f, '\n\nUnweighted, Truncated Once\tDistance');
find_peak_dists(f,wood_coords,coords,wood_labels,1,@dsearchn, 'etoc');
fprintf(f, '\n\nUnweighted, Truncated Twice\tDistance');
find_peak_dists(f,wood_coords,coords,wood_labels,2,@dsearchn, 'etoc');
fprintf(f, '\n\nUnweighted, Truncated Thrice\tDistance');
find_peak_dists(f,wood_coords,coords,wood_labels,3,@dsearchn, 'etoc');

fprintf(f, '\n\nOptimized distances (equal in both directions)\n\n');
table_print(f,otable,max_coords);

fprintf(f, '\n\nAveraged optimized distances between exemplar and component\t(equivalent in both directions)');

fprintf(f, '\n\nOptimized\tDistance');
find_peak_dists(f,wood_coords,coords,wood_labels,0,@optimal_search, 'etoc');
fprintf(f, '\n\nOptimized, Unweighted, Truncated Once\tDistance');
find_peak_dists(f,wood_coords,coords,wood_labels,1,@optimal_search, 'etoc');
fprintf(f, '\n\nOptimized, Unweighted, Truncated Twice\tDistance');
find_peak_dists(f,wood_coords,coords,wood_labels,2,@optimal_search, 'etoc');
fprintf(f, '\n\nOptimized, Unweighted, Truncated Thrice\tDistance');
find_peak_dists(f,wood_coords,coords,wood_labels,3,@optimal_search, 'etoc');

end