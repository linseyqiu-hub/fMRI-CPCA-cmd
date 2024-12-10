% Script for adding woodward labels to a component

function woodward_label(file, peaks, wood_coords, wood_weights, wood_labels)

fprintf(file, '\n\nAveraged distances from the component to each exemplar');
fprintf(file, '\n\nUnweighted\tDistance');
find_peak_dists(file,wood_coords,peaks(:,1:3),wood_labels,0,@dsearchn, 'ctoe');
% fprintf(file, '\n\nWeighted\tDistance');
% find_peak_dists(file,wood_coords,peaks(:,1:3),wood_labels,0,@dsearchn, 'ctoe', wood_weights);
fprintf(file, '\n\nUnweighted, Truncated Once\tDistance');
find_peak_dists(file,wood_coords,peaks(:,1:3),wood_labels,1,@dsearchn, 'ctoe');
fprintf(file, '\n\nUnweighted, Truncated Twice\tDistance');
find_peak_dists(file,wood_coords,peaks(:,1:3),wood_labels,2,@dsearchn, 'ctoe');
fprintf(file, '\n\nUnweighted, Truncated Thrice\tDistance');
find_peak_dists(file,wood_coords,peaks(:,1:3),wood_labels,3,@dsearchn, 'ctoe');


% fprintf(file, '\n\nOptimized\tDistance');
% find_peak_dists(file,wood_coords,peaks(:,1:3),wood_labels,0,@optimal_search, 'ctoe');
% fprintf(file, '\n\nOptimized, Weighted\tDistance');
% find_peak_dists(file,wood_coords,peaks(:,1:3),wood_labels,0,@optimal_search,  'ctoe', wood_weights);
% fprintf(file, '\n\nOptimized, Unweighted, Truncated Once\tDistance');
% find_peak_dists(file,wood_coords,peaks(:,1:3),wood_labels,1,@optimal_search, 'ctoe');
% fprintf(file, '\n\nOptimized, Unweighted, Truncated Twice\tDistance');
% find_peak_dists(file,wood_coords,peaks(:,1:3),wood_labels,2,@optimal_search, 'ctoe');
% fprintf(file, '\n\nOptimized, Unweighted, Truncated Thrice\tDistance');
% find_peak_dists(file,wood_coords,peaks(:,1:3),wood_labels,3,@optimal_search, 'ctoe');

end
