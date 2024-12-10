% finds the euclidean distance between two cartesian points
function euc_dist = euclid(a,b)
    euc_dist = sqrt(sum((a-b).^2));
end
