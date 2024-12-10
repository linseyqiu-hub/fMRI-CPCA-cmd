
function filename = select_file( filespec, title )
% show a select file dialog box
%
% return filename as full path

  filename = '';

  [fn, path] = uigetfile(filespec, title );

  if isequal(filename,0) || isequal(path,0)
     cancelled = 1;
  else
    filename = [path fn];
  end;


