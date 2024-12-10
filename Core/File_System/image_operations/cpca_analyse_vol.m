function [h mvl] = cpca_analyse_vol( filename )
% - not for use on nifti file yet.
% --= Analyse images converted to NIFTI 1 format
% --= 
  objNIFTI = struct ( ...		% --= 
    'dat', [], ...			% --= shaped file array   ---
    'mat', [], ...			% --= transform matrix    ---
    'mat_intent', '', ...		% --= 
    'mat0', [], ...			% --= transform matrix    ---
    'mat0_intent', '', ... 		% --= 
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
    'n', [1,1], ...			% --= volume id           ---
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
    h = cpca_read_header( fid );		% --= read in the associated .hdr file
  else

    [fid endian] = cpca_open_image( P );	% open the .img or .nii file

    if ( fid > 0 )
      h = cpca_read_header( fid );		% read in the header information

      if ( ~ nifti_single_file( hdr ) )	% not flagged as a nifti combined file?
        h.error = [ 'no header file associated with image file ' P ];
        return;
      end;

    else
      h.error = [ 'unable to open file ' P ];
      return;
    end

  end;
  % --= 
  be = strcmp( endian, 'ieee-be' );% --= 
  % --= 
  if ( ~nifti_version (h) ) % --= 
    hdr = new_nifti_header(); % --= 
    hdr.dim        = h.dim; % --= 
%    hdr.datatype   = 4;	% -- 	% we force datatype to double (16 bit)
%    hdr.bitpix     = 16; 
    hdr.datatype   = h.datatype; % --= 
    hdr.bitpix     = h.bitpix; % --= 
    hdr.pixdim     = h.pixdim; % --= 
    hdr.vox_offset = h.vox_offset; % --= 
    hdr.scl_slope  = h.funused1; % --= 
    hdr.scl_inter  = h.funused2; % --= 
    hdr.description= h.descrip; % --= 
    hdr.aux_file   = h.aux_file; % --= 
    hdr.glmax      = h.glmax; % --= 
    hdr.glmin      = h.glmin; % --= 
    hdr.cal_max    = h.cal_max; % --= 
    hdr.cal_min    = h.cal_min; % --= 
    switch hdr.datatype, % --= 
      case 130, hdr.datatype = 256; % --= %   int8
      case 132, hdr.datatype = 512; % --= % uint16
      case 136, hdr.datatype = 768; % --= % uint32
    end;% --= 
    % --= 
    hdr.scl_slope = 1; % --= 
    hdr.scl_inter = 0; % --= 
    % --= 
    if isfinite(h.funused1) & h.funused1 % --= 
      hdr.scl_slope = h.funused1; % --= 
      if isfinite(h.funused2) % --= 
        hdr.scl_inter = h.funused2;  % --= 
      else % --= 
        hdr.scl_inter = 0; % --= 
      end; % --= 
    else % --= 
      if h.glmax - h.glmin & h.cal_max - h.cal_min % --= 
        hdr.scl_slope = ( h.cal_max - h.cal_min )  / ( h.glmax - h.glmin ); % --= 
        hdr.scl_inter = h.cal_min - hdr.scl_slope * h.glmin; % --= 
      end; % --= 
    end; % --= 
    % --= 
    hdr.qform_code = 2;		% --= % --- mat intent code - Aligned --
%    hdr.sform_code = 2;	% --= % --- mat intent code - Aligned --
    hdr.sform_code = 0;		% --= % --- force 'scanner-anatomical' transform matrix rotation
    % --= 
    origin = (double(h.origin(1:3))); % --= 
    % --= 
    h = hdr; % --= 
    % --= 
  else % --= 
    origin = (double(h.dim(2:4))+1)/2; % --= 
  end; % --= 
  % --= 
  % --= -----------------------------------------------
  % --= create a transform matrix
  % --= -----------------------------------------------
  vox    = double(h.pixdim(2:4)); % --= 
  if sum(vox) == 0  vox = [1 1 1];  end; % --= 
  % --= 
  off    = -vox.*origin; % --= 
  mvl.mat    = [vox(1) 0 0 off(1) ; 0 vox(2) 0 off(2) ; 0 0 vox(3) off(3) ; 0 0 0 1]; % --= 
  % --= 
  % --- assuming flipped when vox(1) non negative ---
  if ( vox(1) >= 0 ) mvl.mat = diag([-1 1 1 1]) * mvl.mat;  end; % --= 
  % --= 
  mvl.fname = filename;	 % --= 
  mvl.dim = double(h.dim(2:4)); % --= 
  mvl.dt = double( [4 be] );% --=   % our default data type is double
  mvl.pinfo = double(h.dim(5:7)'); % --= 
  mvl.descrip = h.description; % --= 
  % --= 
  mvl.private.descrip = h.description; % --= 
  mvl.private.dat = file_array( mvl.fname, mvl.dim, mvl.dt, 0, h.scl_slope, h.scl_inter); % --= 
  % --= 
  h            = encode_qform0(mvl.mat,h); % --= 
  mvl.mat        = mvl.mat * [eye(4,3) [1 1 1 1]']; % --= 
  h.srow_x     = mvl.mat(1,:); % --= 
  h.srow_y     = mvl.mat(2,:); % --= 
  h.srow_z     = mvl.mat(3,:); % --= 
%  h.srow_x     = mvl.private.mat(1,:);
%  h.srow_y     = mvl.private.mat(2,:);
%  h.srow_z     = mvl.private.mat(3,:);
  % --= 
  dm = [mvl.private.dat.dim 1 1 1 1 ]; % --= 
  n = [1 1]; % --= 
  off = (n(1)-1+dm(4)*(n(2)-1))*ceil(spm_5_type(mvl.dt(1),'bits')*dm(1)*dm(2)/8)*dm(3) + mvl.private.dat.offset; % --= 
  mvl.pinfo = [mvl.private.dat.scl_slope mvl.private.dat.scl_inter off]'; % --= 
  mvl.n = n; % --= 
  % --= 
  % --= % --- we have set the qform and sform codes to Aligned - set the internal private mats ---
  mvl.private.mat = mvl.mat; % --= 
  mvl.private.mat_intent = 'Aligned'; % --= 
%  mvl.private.mat0 = mvl.mat;
%  mvl.private.mat0_intent = 'Aligned';


