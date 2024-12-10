function rtn = image_data_info( h )

rtn = struct ( 'dim', [], 'pdim', [], 'dtyp', '', 'measure', '', 'affine', 0, 'matrix', [] );

rtn.dim = h.dim(2:4);
rtn.pdim = h.pixdim(2:4);
x = cpca_data_type( h.datatype);
rtn.dtyp = [ lower(x.nifti) ' (' num2str(x.bits) ')' ];

rtn.measure = cpca_xyzt_type( h.xyzt_units );

rtn.affine = h.sform_code > 0;
if rtn.affine
  rtn.matrix = [ h.srow_x; h.srow_y; h.srow_z];
end;

