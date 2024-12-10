format compact

%these 2 lines removed by Eva 15/02/08
%load GA_values.mat;
%load Znorm.mat;

size(GA)
size(Z)
diary on
[Fmx d2 dd]= pcaptspecial1_Todd(GA, Z);
save temp_perm2.mat d2 dd
clear
load temp_perm2.mat 
load temp_perm.mat 
