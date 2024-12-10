function niistruc = niistruct()

  niistruc = {
    'sizeof_hdr', 1,'int32';
    'data_type', 10,'uchar';
    'db_name', 18,'uchar';
    'extents', 1,'int32';
    'session_error', 1,'int16';
    'regular', 1,'uchar';
      'dim_info', 1,'uchar';
      'dim', 8,'int16';
      'intent_p1', 1,'int32';
      'intent_p2', 1,'int32';
      'intent_p3', 1,'int32';
      'intent_code', 1,'int16';
      'datatype', 1,'int16';
      'bitpix', 1,'int16';
      'slice_start', 1,'int16';
      'pixdim', 8,'float';
      'vox_offset', 1,'float';
      'scl_slope', 1,'float';
      'scl_inter', 1,'float';
      'slice_end', 1,'int16';
      'slice_code', 1,'uchar';
      'xyzt_units', 1,'uchar';
      'cal_max', 1,'float';
      'cal_min', 1,'float';
      'slice_duration', 1,'int32';
      'toffset', 1,'int32';
      'glmax', 1,'int32';		
      'glmin', 1,'int32';
      'description', 80,'uchar';
      'aux_file', 24,'uchar';
      'qform_code', 1,'int16';
      'sform_code', 1,'int16';
      'quatern_b', 1,'float';
      'quatern_c', 1,'float';
      'quatern_d', 1,'float';
      'qoffset_x', 1,'float';
      'qoffset_y', 1,'float';
      'qoffset_z', 1,'float';
      'srow_x', 4,'float';
      'srow_y', 4,'float';
      'srow_z', 4,'float';
      'intent_name', 16,'uchar';
      'magic', 4,'uchar';
};


