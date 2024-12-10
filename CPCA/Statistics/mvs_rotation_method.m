function method = mvs_rotation_method ( filename )
% ---------------------------
% determine information from selected filename
% all filenames have the same general format
%  MDL_nd#Components_methos_style_i#iterations_p#power
%  hrfmax ++  _{useraddedtext}
%  all others ++  _g#gamma_{useraddedtext}
% eg: G_nd2_hrfmax_orthogonal_i10000_p2.00_shapes1
% ---------------------------

  x = regexp( filename, '_', 'split' );
  method = strrep( char( x(2)), '.mat', '' );


