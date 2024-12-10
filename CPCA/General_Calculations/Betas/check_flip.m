function check_flip(comp, Gheader, ep, fn,  Zheader)

evalc( ['load( ''' fn ''')'] );
d = d3^2;
vr_cmp = VR(:,comp);
ncomps = size(VR,2);
x_plot = floor(sqrt(ncomps));
y_plot = ceil(ncomps/x_plot);
rank_1_matrix = UR(:, comp)*d(comp, comp)* vr_cmp';
top_5_pos = find(vr_cmp >= ep(comp).percentiles(2).threshold);
top_5_neg = find(vr_cmp < -ep(comp).percentiles(2).threshold);
top_5 = sort([top_5_pos; top_5_neg]);
mean_comp_pos = mean(rank_1_matrix(:, top_5_pos), 2);
mean_comp_neg = mean(rank_1_matrix(:, top_5_neg), 2);
mean_comp = mean(rank_1_matrix(:, top_5), 2);
all_g = [];
for sn = 1:Zheader.num_subjects
	%retrieve_subject_G(Gheader, sn);
	load( [ Gheader.path_to_segs Gheader.prefix '_S' num2str(sn) '.mat'],  'Graw');
	G = Graw;
	all_g = blkdiag(all_g, G);
end
all_g = [ones(size(all_g,1),1) all_g];
result_pos = pinv(all_g'*all_g)*all_g'*mean_comp_pos;
result_pos = result_pos(2:end,:);
result_neg = pinv(all_g'*all_g)*all_g'*mean_comp_neg;
result_neg = result_neg(2:end,:);
result = pinv(all_g'*all_g)*all_g'*mean_comp;
result = result(2:end,:);
all_conds = mean(reshape(PR(:,comp),size(result,1)/Zheader.num_subjects, Zheader.num_subjects), 2);
subplot(y_plot, x_plot, comp);
if(mean(result_pos)<0 || isnan(mean(result_pos)) && (mean(result_neg)>0 || isnan(mean(result_neg)))) 
	plot(-reshape(all_conds, Gheader.bins, Gheader.conditions))
	disp(['flip component: ' num2str(comp)])
else 
	plot(reshape(all_conds, Gheader.bins, Gheader.conditions))
	disp(['dont flip component: ' num2str(comp)])
end
title(['Component: ' num2str(comp)]);
