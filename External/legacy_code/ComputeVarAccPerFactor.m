%% function to view pos and neg loadings on a component.
%% Called by cpcaScree.m 


function [pdsum]=ComputeVarAccPerFactor(u3,d3,v3,nd,tsum,nr,nc,u1,d1,v1,GA,GAZ,Randind);
format compact

%% recompute the loadings etc %%

gg=u1*sqrt(inv(d1))*v1';
B=gg*GAZ;

psum=trace(d3'*d3);
ppsum=100*psum/tsum;
fprintf(' \n')
fprintf(' The SS that can be explained by GA %10.3f \n', psum);
fprintf(' The percent SS out of the total SS %10.3f \n', ppsum);
dsum=trace(d3(1:nd,1:nd)'*d3(1:nd,1:nd));
pdsum=100*dsum/psum;
ppdsum=100*dsum/tsum;
fprintf(' \n')
fprintf(' The SS that can be explained by the nd-dimensional solution %10.3f \n', dsum);
fprintf(' The percent SS out of what can be explained by GA %10.3f \n', pdsum);
fprintf(' The percent SS out of the total SS %10.3f \n', ppdsum);



