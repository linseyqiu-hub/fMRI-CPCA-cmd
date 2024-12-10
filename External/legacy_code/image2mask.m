function image2mask(Image, Th, Outfile)
%Image: file name as input image [*.img] in current workpath 
%Th: the selected threshold [Th inf] or [-inf Th]
%Outfile: file name as output image
%
% This code requires to call 'SPM5' codes, please make sure 'SPM5' in
% MATLAB paths.

if isempty(Image)
    imagefile = spm_select('List', pwd, '^.*\.img$');
else
    imagefile = spm_select('List', pwd, Image);
end
if nargin < 3, error('please input parameters again!'); end
v=spm_vol(imagefile);
Data = spm_read_vols(v);
Mask = logical(zeros(size(Data)));
Mask(find(Data <= Th(2) & Data >=Th(1))) = 1;
o = v;
o.fname = Outfile;
o.dt(1) = 16;
spm_write_vol(o,Mask);
