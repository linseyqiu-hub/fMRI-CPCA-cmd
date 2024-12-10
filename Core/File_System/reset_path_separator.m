function pth = reset_path_separator( pth )
% --- converts any path separation characters ( /or \ ) to proper system
% --- path separator

  pth = strrep( pth, '/', filesep );
  pth = strrep( pth, '\', filesep );

end

