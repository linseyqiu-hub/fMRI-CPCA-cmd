clear

comp_filename=('CompImageGA3.img');
compimg=readImage(comp_filename); % 68880x1; same dimensions as mask.img

%lowercutoff=.0412 % cutoffs used for displaying image on mricron so that desired clusters are a reasonable size
%uppercutoff=.1052
%lowercutoff=.065
lowercutoff=.0412
uppercutoff=.1052

ind=find(compimg >= lowercutoff & compimg <= uppercutoff); % which rows of comp3pos (which voxels) have coordinates between those cutoffs

for i=1:size(ind)
comp_all_coords(i,:)=image2voxel(comp_filename,ind(i));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Lhipp_range=[
%-24 -19;  % min and max x coords for this cluster; determined from scrolling back & forth in mricron
%-28 -9;   % min and max y coords for this cluster
%-21 -3;   % min and max z coords for this cluster
%];

Lhipp_range=[-34 -17; -31 -5; -25 2];

% for frontal, try to get the x, y, & z ranges so that we get the same number
% of voxels as reported in the neuroimage paper. then we can just use that
% as our justification - just say we wanted to select the same number of
% voxels around the peak as before; 145 voxels

%Lfrontal_range=[-42 -27; -1 18; 14 56];
%Lfrontal_range=[-54 -28; 1 46; -8 56];
%Lfrontal_range=[-53 -29; -1 20; -8 56];
Lfrontal_range=[-50 -25; 1 20; 13 57];

% will have to just select voxels if the tailarach coordinates correspond
% to the ones for this cluster

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%cluster=Lhipp_range;
cluster=Lfrontal_range;

currentcluster_coords=[];
for j=1:size(comp_all_coords(:,1))
    if(comp_all_coords(j,1) >= cluster(1,1) & comp_all_coords(j,1) <= cluster(1,2) & comp_all_coords(j,2) >= cluster(2,1) & comp_all_coords(j,2) <= cluster(2,2) & comp_all_coords(j,3) >= cluster(3,1) & comp_all_coords(j,3) <= cluster(3,2))
    currentcluster_coords=[currentcluster_coords; comp_all_coords(j,:) ind(j,:)];
    end
end

size(currentcluster_coords) % 1st 3 columns are x,y,z tal coords. 4th column is indices (which row / which voxel on mask image)

%save Lhipp_talcoords&inds.mat currentcluster_coords; % 12 voxels
save Lfrontal_smaller_talcoords&inds.mat currentcluster_coords; % 146 voxels

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear

mask=readImage('mask.img');

%load Lhipp_talcoords&inds.mat;
load Lfrontal_smaller_talcoords&inds.mat;

msk=zeros(size(mask));
for k=1:size(mask)
    if(size(find(currentcluster_coords(:,4)==k)) > 0)
        msk(k)=1;
    end
end

%save Lhippmask.mat msk;
save Lfrontal_smaller_mask.mat msk


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% write masks to image files

clear

%load Lhippmask.mat;
load Lfrontal_smaller_mask.mat;

%Select the mask.img and mask.hdr
%cd /data/replicate_spm_w_cpca/one_sub/ext_   % select your work path
if strcmp(spm('ver'),'SPM')|strcmp(spm('ver'),'SPM5')
    maskfile=spm_select('List', pwd, '^mask.*\.img$');
    maskfile=spm_vol(maskfile);
    maskimg = spm_read_vols(maskfile);
else
    [maskfile, maskpath] = uigetfile('*.img', 'Select your mask.img');
    [hdrfile, hdrpath] = uigetfile('*.hdr', 'Select your mask.hdr');
    hdr=[hdrpath hdrfile];
    mask=[maskpath maskfile];
    m=['readImage_mit'  ('(mask)')];
    maskimg=eval(m);
end



    if strcmp(spm('ver'),'SPM')|strcmp(spm('ver'),'SPM5')
        FImg = maskfile;
        msk=reshape(msk,FImg.dim);
        imagename = ['msk' '.img'];
        FImg.fname =imagename;
        spm_create_vol(FImg);      
        spm_write_vol(FImg,msk);
    else
        [DIM VOX SCALE TYPE OFFSET ORIGIN DESCRIP] = spm_hread(hdr);
        imagename=['msk']
        filename=[imagename '.img'];
        fid = fopen(filename,'w');
        TYPE=16
        fwrite(fid,msk,spm_type(TYPE));
        [s] = spm_5_hwrite(filename,DIM,VOX,SCALE,TYPE, OFFSET,ORIGIN,DESCRIP);
    end
    
    
