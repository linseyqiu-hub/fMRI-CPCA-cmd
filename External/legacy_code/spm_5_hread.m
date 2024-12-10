function [DIM,VOX,SCALE,TYPE,OFFSET,ORIGIN,DESCRIP, otherendian, DCOFF ] = spm_5_hread(P)

% reads a header
% FORMAT [DIM VOX SCALE TYPE OFFSET ORIGIN DESCRIP] = spm_5_hread(P);
%
% P       - filename 	     (e.g spm or spm.img)
% DIM     - image size       [i j k [l]] (voxels)
% VOX     - voxel size       [x y z [t]] (mm [secs])
% SCALE   - scale factor
% TYPE    - datatype (integer - see spm_5_type)
% OFFSET  - offset (bytes)
% ORIGIN  - origin [i j k]
% DESCRIP - description string
% otherendian - does hdr/img use native byte-order (0) or is data byte swapped (1)
%             -allows big-endian machines (Sun) to read little endian (Intel) data and vice versa
% DCOFF -Zero intercept for calibrating data, see SPM2's spm_vol_ana.m
%___________________________________________________________________________
%
% spm_5_hread reads variables into working memory from a SPM/ANALYZE
% compatible header file.  If the header does not exist global defaults
% are used.  The 'originator' field of the ANALYZE format has been
% changed to ORIGIN in the SPM version of the header.  funused1 of the
% ANALYZE format is used for SCALE
%
% see also dbh.h (ANALYZE) spm_5_hwrite.m and spm_5_type.m
%
%__________________________________________________________________________
% @(#)spm_5_hread.m	2.7 99/10/29
%Modified 22July2004 to include DC offset (zero-intercept for image calibration), see SPM2's spm_vol_ana.m

% ensure correct suffix {.hdr}
%---------------------------------------------------------------------------
P     = deblank(P);
q     = length(P);
if q>=4 & P(q - 3) == '.'; P = P(1:(q - 4)); end
P     = [P '.hdr'];


% open header file
%---------------------------------------------------------------------------
fid   = fopen(P,'r','native');

if (fid > 0)

  % read (struct) header_key
  %---------------------------------------------------------------------------
  fseek(fid,0,'bof');

  % first dword of file is structure length - test for endian type
  otherendian = 0;
  sizeof_hdr 	= fread(fid,1,'int32');
  % -- Magic Number - fix this : perhaps sizeof_hdr > 2k
  if sizeof_hdr==1543569408, % Appears to be other-endian

      % Re-open other-endian
      fclose(fid);
      if spm_platform('bigend'),
        fid = fopen(P,'r','ieee-le');
      else,
        fid = fopen(P,'r','ieee-be');
      end;

      fseek(fid,0,'bof');
      sizeof_hdr = fread(fid,1,'int32');
      otherendian = 1;
    end;


  data_type  	= mysetstr(fread(fid,10,'uchar'))';
  db_name    	= mysetstr(fread(fid,18,'uchar'))';
  extents    	= fread(fid,1,'int32');
  session_error   = fread(fid,1,'int16');
  regular    	= mysetstr(fread(fid,1,'uchar'))';
  hkey_un0    	= mysetstr(fread(fid,1,'uchar'))';



  % read (struct) image_dimension
  %---------------------------------------------------------------------------
  fseek(fid,40,'bof');

  dim    	= fread(fid,8,'int16');
  vox_units    	= mysetstr(fread(fid,4,'uchar'))';
  cal_units    	= mysetstr(fread(fid,8,'uchar'))';
  unused1	= fread(fid,1,'int16');
  datatype	= fread(fid,1,'int16');
  bitpix	= fread(fid,1,'int16');
  dim_un0	= fread(fid,1,'int16');
  pixdim	= fread(fid,8,'float');
  vox_offset	= fread(fid,1,'float');
  funused1	= fread(fid,1,'float');
  funused2	= fread(fid,1,'float');
  funused3	= fread(fid,1,'float');
  cal_max	= fread(fid,1,'float');
  cal_min	= fread(fid,1,'float');
  compressed	= fread(fid,1,'int32');
  verified	= fread(fid,1,'int32');
  glmax		= fread(fid,1,'int32');
  glmin		= fread(fid,1,'int32');


  % read (struct) data_history
  %---------------------------------------------------------------------------
  fseek(fid,148,'bof');

  descrip	= mysetstr(fread(fid,80,'uchar'))';
  aux_file	= mysetstr(fread(fid,24,'uchar'))';
  orient	= fread(fid,1,'uchar');
  origin	= fread(fid,5,'int16');
  generated	= mysetstr(fread(fid,10,'uchar'))';
  scannum	= mysetstr(fread(fid,10,'uchar'))';
  patient_id	= mysetstr(fread(fid,10,'uchar'))';
  exp_date	= mysetstr(fread(fid,10,'uchar'))';
  exp_time	= mysetstr(fread(fid,10,'uchar'))';
  hist_un0	= mysetstr(fread(fid,3,'uchar'))';
  views		= fread(fid,1,'int32');
  vols_added	= fread(fid,1,'int32');
  start_field	= fread(fid,1,'int32');
  field_skip	= fread(fid,1,'int32');
  omax		= fread(fid,1,'int32');
  omin		= fread(fid,1,'int32');
  smax		= fread(fid,1,'int32');
  smin		= fread(fid,1,'int32');

  fclose(fid);


  if isempty(smin)
    error(['There is a problem with the header file ' P '.']);
  end

  % convert to SPM global variables
  %---------------------------------------------------------------------------
  DIM  	  	= dim(2:4)';
  VOX       	= pixdim(2:4)';
  %SCALE     	= funused1;
  %SCALE    	= ~SCALE + SCALE;
  %DCOFF = 0;


  if isfinite(funused1) & funused1,

    SCALE = funused1;
    if isfinite(funused2),
      DCOFF = funused2; %DCoffset
    else,
      DCOFF = 0;
    end;

  else,

    if glmax-glmin & cal_max-cal_min,
      SCALE = (cal_max-cal_min)/(glmax-glmin);
      DCOFF = cal_min - SCALE *glmin;

      %if hdr.dime.funused1,
        %warning(['Taking scalefactor etc from glmax/glmin & cal_max/cal_min of "' fname '".']);
      %end;

    else,
      SCALE= 1;
      DCOFF = 0;
      warning(['Assuming a scalefactor of 1 for "' P '".']);
    end;

  end;


  TYPE = datatype;
  if otherendian == 1 & datatype ~= 2,
    TYPE = TYPE*256;
  end;

  OFFSET	= vox_offset;
  ORIGIN    	= origin(1:3)';
  DESCRIP   	= descrip(1:max(find(descrip)));

else
  global DIM VOX SCALE TYPE OFFSET ORIGIN
  DESCRIP = ['defaults'];
end

return;
%_______________________________________________________________________

function out = mysetstr(in)
  tmp = find(in == 0);
  tmp = min([min(tmp) length(in)]);
  out = setstr(in(1:tmp));
return;

