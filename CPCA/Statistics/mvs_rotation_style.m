function rstyle = mvs_rotation_style ( filename )
% ---------------------------
% determine information from selected filename
% all filenames have the same general format
%  MDL_nd#Components_methos_style_i#iterations_p#power
%  hrfmax ++  _{useraddedtext}
%  all others ++  _g#gamma_{useraddedtext}
% eg: G_nd2_hrfmax_orthogonal_i10000_p2.00_shapes1
% ---------------------------

  rstyle = '';
  x = regexp( filename, '_', 'split' );
  if ( size( x,2) > 2 )
    rstyle = char( x(3) );
  end;

