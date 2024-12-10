% writes out a SPM formatted img and hdr file 
% with all positive values from the specified image set to 1
% will also return the mask image

function msk=make_mask(mask_me)

msk=readImage(mask_me);
msk(find(msk>0))=1;

[filename extension]=strtok(mask_me, '.');
mskfile = [filename '_msk' extension];

[DIM VOX SCALE TYPE OFFSET ORIGIN DESCRIP] = spm_5_hread(mask_me);
fid=fopen(mskfile, 'w');
fwrite(fid,msk,spm_type(TYPE));

%write the same SPM header but with the scale set to 1
SCALE=1;
spm_5_hwrite(mskfile,DIM,VOX,SCALE,TYPE,OFFSET,ORIGIN,DESCRIP);
