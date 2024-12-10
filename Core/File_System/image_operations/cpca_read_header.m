function X = cpca_read_header( fid )
% -----------------------------------------------
% borrowed from SPM spm_hread()
% will return a structure containing image header volume information
% -----------------------------------------------

  if ( fid > 0 )
    X.sizeof_hdr = fread(fid,1,'int32');

    fseek(fid,344,'bof');
    z.magic = mysetstr(fread(fid,4,'uchar'))';
    nii_version = nifti_version( z );
    fseek(fid,4,'bof');

    X.data_type  	= mysetstr( fread(fid,10,'uchar' ) )';	
    X.db_name    	= mysetstr( fread(fid,18,'uchar' ) )';
    X.extents    	= fread(fid,1,'int32');
    X.session_error 	= fread(fid,1,'int16');
    X.regular    	= mysetstr( fread(fid,1,'uchar') )';
 
    if ( nii_version ~= 0 )

      X.dim_info	= mysetstr( fread(fid,1,'uchar') )';
      X.dim    		= fread(fid,8,'int16')';
      X.intent_p1    	= fread(fid,1,'int32');
      X.intent_p2    	= fread(fid,1,'int32');
      X.intent_p3    	= fread(fid,1,'int32');
      X.intent_code	= fread(fid,1,'int16');
      X.datatype	= fread(fid,1,'int16');
      X.bitpix		= fread(fid,1,'int16');
      X.slice_start	= fread(fid,1,'int16');
      X.pixdim		= fread(fid,8,'float')';
      X.vox_offset	= fread(fid,1,'float');
      X.scl_slope	= fread(fid,1,'float');
      X.scl_inter	= fread(fid,1,'float');
      X.slice_end	= fread(fid,1,'int16');
      X.slice_code	= fread(fid,1,'uchar');
      X.xyzt_units	= fread(fid,1,'uchar');
  
      X.cal_max		= fread(fid,1,'float');
      X.cal_min		= fread(fid,1,'float');
      X.slice_duration	= fread(fid,1,'int32');
      X.toffset		= fread(fid,1,'int32');
      X.glmax		= fread(fid,1,'int32');		% glmax/min are unused in nifti
      X.glmin		= fread(fid,1,'int32');

      % -----------------------------------------------
      % read (struct) data_history  0x0094 - 0x015c
      % -----------------------------------------------
      fseek(fid,148,'bof');

      X.description	= mysetstr(fread(fid,80,'uchar'))';
      X.aux_file	= mysetstr(fread(fid,24,'uchar'))';

      X.qform_code	= fread(fid,1,'int16');
      X.sform_code	= fread(fid,1,'int16');

      X.quatern_b	= fread(fid,1,'float');
      X.quatern_c	= fread(fid,1,'float');
      X.quatern_d	= fread(fid,1,'float');
      X.qoffset_x	= fread(fid,1,'float');
      X.qoffset_y	= fread(fid,1,'float');
      X.qoffset_z	= fread(fid,1,'float');

      X.srow_x		= fread(fid,4,'float')';
      X.srow_y		= fread(fid,4,'float')';
      X.srow_z		= fread(fid,4,'float')';
      X.intent_name	= mysetstr(fread(fid,16,'uchar'))';

      X.magic		= mysetstr(fread(fid,4,'uchar'))';

    else

      % -----------------------------------------------
      % read in ANALYSE 7.5 format
      % -----------------------------------------------

      X.hkey_un0	= mysetstr( fread(fid,1,'uchar') )';	% aka hkey_un0
      X.dim    		= fread(fid,8,'int16')';
      X.vox_units    	= mysetstr(fread(fid,4,'uchar'))';
      X.cal_units    	= mysetstr(fread(fid,8,'uchar'))';
      X.unused1		= fread(fid,1,'int16');
      X.datatype	= fread(fid,1,'int16');
      X.bitpix		= fread(fid,1,'int16');
      X.dim_un0		= fread(fid,1,'int16');
      X.pixdim		= fread(fid,8,'float')';
      X.vox_offset	= fread(fid,1,'float');
      X.funused1	= fread(fid,1,'float');
      X.funused2	= fread(fid,1,'float');
      X.funused3	= fread(fid,1,'float');
      X.cal_max		= fread(fid,1,'float');
      X.cal_min		= fread(fid,1,'float');
      X.compressed	= fread(fid,1,'int32');
      X.verified	= fread(fid,1,'int32');
      X.glmax		= fread(fid,1,'int32');
      X.glmin		= fread(fid,1,'int32');
  
      X.descrip		= mysetstr(fread(fid,80,'uchar'))';
      X.aux_file	= mysetstr(fread(fid,24,'uchar'))';
      X.orient		= fread(fid,1,'uchar');
      X.origin		= fread(fid,5,'int16')';
      X.generated	= mysetstr(fread(fid,10,'uchar'))';
      X.scannum		= mysetstr(fread(fid,10,'uchar'))';
      X.patient_id	= mysetstr(fread(fid,10,'uchar'))';
      X.exp_date	= mysetstr(fread(fid,10,'uchar'))';
      X.exp_time	= mysetstr(fread(fid,10,'uchar'))';
      X.hist_un0	= mysetstr(fread(fid,3,'uchar'))';
      X.views		= fread(fid,1,'int32');
      X.vols_added	= fread(fid,1,'int32');
      X.start_field	= fread(fid,1,'int32');
      X.field_skip	= fread(fid,1,'int32');
      X.omax		= fread(fid,1,'int32');
      X.omin		= fread(fid,1,'int32');
      X.smax		= fread(fid,1,'int32');
      X.smin		= fread(fid,1,'int32');
  
    end;

    % -----------------------------------------------
    % close the input file
    % -----------------------------------------------
    fclose( fid );
 
  end;



function out = mysetstr(in)
  tmp = find(in == 0);
  if min(tmp) == 1 out = ''; return; end;
  tmp = min([min(tmp) length(in)]);
  out = setstr(in(1:tmp));
return;

