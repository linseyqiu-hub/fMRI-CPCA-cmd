function [h mvl] = cpca_nifti_vol( filename )
% - not for use on nifti file yet.

  objNIFTI = struct ( ...		% --= 
    'dat', [], ...			% --= shaped file array   ---
    'mat', [], ...			% --= transform matrix    ---
    'mat_intent', '', ...		% --= 
    'mat0', [], ...			% --= transform matrix    ---
    'mat0_intent', '', ...		% --= 
    'descrip', '', ...			% --= text description    ---
    'aux_file', 'none' );		% --= 
  					% --* 1 of the transform  --- 
  					% --* matrices is the     --- 
  					% --* original, and 1 is  --- 
  					% --* a conversion        --- 
  mvl = struct ( ...			% --= 
    'fname', '', ...			% --= image filenmame     ---
    'mat', [], ...			% --= transform matrix    ---
    'dim', [], ...			% --= image dimensions    ---
    'dt', [], ...			% --= image data type     ---
    'pinfo', [], ...			% --= plane information   ---
    'n', [], ...			% --= volume id           ---
    'descrip', '', ...			% --= text description    ---
    'private', objNIFTI );		% --= NIFTI data          --- 

% --= 

  P     = deblank(filename);
  H	= P;
  q     = length(H);
  if q>=4 & H(q - 3) == '.'; H = H(1:(q - 4)); end
  H     = [H '.hdr'];

  image = [];

  [fid endian] = cpca_open_image( H );		% returns 0 if .hdr file does not exist

  if ( fid > 0 )
    h = cpca_read_header( fid );		% read in the associated .hdr file
  else

    [fid endian] = cpca_open_image( P );	% open the .img or .nii file

    if ( fid > 0 )
      h = cpca_read_header( fid );		% --= read in the header information

      if ( ~ nifti_single_file( h ) )	% not flagged as a nifti combined file?
        h.error = [ 'no header file associated with image file ' P ];
        return;
      end;

    else
      h.error = [ 'unable to open file ' P ];
      return;
    end

  end;

  % --= 
  be = strcmp( endian, 'ieee-be' ); % --= 
  % --= 
  mvl.fname = filename;	% --= 
  mvl.dim = double(h.dim(2:4));% --= 
  mvl.dt = double( [4 be] ) ;			% --= our default data type is double
  mvl.pinfo = double(h.dim(5:7)'); % --= 
%  mvl.pinfo = [ 1 0 0 ];			% from raw data - no slope
%  h.scl_slope = 1;
  mvl.descrip = h.description; % --= 
  % --= 
  mvl.private.descrip = h.description; % --= 
% --= 

%---------------------
%  mvl.mat    = [h.srow_x ; h.srow_y ; h.srow_z  ; 0 0 0 1];
%  origin = (double(h.dim(2:4))+1)/2;
  % --= -----------------------------------------------
  % --= create a transform matrix
  % --= -----------------------------------------------
%  vox    = double(h.pixdim(2:4));
  vox    = [ h.srow_x(1) h.srow_y(2) h.srow_z(3)]; % --= 
  if sum(vox) == 0  vox = [1 1 1];  end; % --= 
  % --= 
  origin = [ h.qoffset_x, h.qoffset_y, h.qoffset_z]; % --= 
  if ( sum( origin) == 0 )   origin = [ h.srow_x(4) h.srow_y(4) h.srow_z(4)]; end; % --= 
  % --= 
  off    = -vox + origin;  % --= % -- .*h.dim(2:4);
  mvl.mat    = [vox(1) 0 0 off(1) ; 0 vox(2) 0 off(2) ; 0 0 vox(3) off(3) ; 0 0 0 1]; % --= 
  % --= 
  % --= %-- assuming flipped when vox(1) non negative ---
  if ( vox(1) >= 0 ) mvl.mat = diag([-1 1 1 1]) * mvl.mat;  end; % --= 
% --------------------------
  % --= 
  mvl.private.dat = file_array( mvl.fname, mvl.dim, mvl.dt, double(h.vox_offset), h.scl_slope, h.scl_inter); % --= 
  % --= 
  h = encode_qform0(mvl.mat,h); % --= 
  % --= 
  dm = [mvl.private.dat.dim 1 1 1 1 ]; % --= 
  n = nifti_version( h ); % --= 
  n = [n 1]; % --= 
  % --= 
  off = (n(1)-1+dm(4)*(n(2)-1))*ceil(spm_5_type(mvl.dt(1),'bits')*dm(1)*dm(2)/8)*dm(3) + mvl.private.dat.offset; % --= 
  mvl.pinfo = [mvl.private.dat.scl_slope mvl.private.dat.scl_inter off]'; % --= 
  mvl.n = n; % --= 
  % --= 
  mvl.private.mat = mvl.mat; % --= 
  mvl.private.mat_intent = 'Aligned'; % --= 
  % --= 


