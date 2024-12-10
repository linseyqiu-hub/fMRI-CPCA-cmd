function Y=tw_load1d(fname)
%loads an spm-compatible image into a one-dimensional array

V=spm_vol(fname);
Y=spm_read_vols(V);
Y=reshape(Y,prod(V.dim(1:3)),1);