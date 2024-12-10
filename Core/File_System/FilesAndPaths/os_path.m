function pth = os_path( path_spec )

pth = path_spec;

if ispc()
  this = '/';
  that = '\';
else
  this = '\';
  that = '/';
end;

pth = strrep( pth, this, that );
