function cmp = mvs_component_number( filename )
% ---------------------------
% determine information from selected filename
% all filenames have the same general format
%  MDL_nd#Components_methos_style_i#iterations_p#power
%  hrfmax ++  _{useraddedtext}
%  all others ++  _g#gamma_{useraddedtext}
% eg: G_nd2_hrfmax_orthogonal_i10000_p2.00_shapes1
% ---------------------------

  if ( filename(1:1) == '(' |  filename(1:1) == '[' )
    cmp = str2num(char(regexp( filename(1,1:4), '[0-9]', 'match' )));
  else
    x = regexp( filename, '_', 'split' );
    cmp = str2double( strrep( x(2), 'nd', '' ) );
  end;

