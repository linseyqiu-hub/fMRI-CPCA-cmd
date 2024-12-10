% This simple tool will allow you to select a directory containing the 
% subject subdirectories containing scan information. It will create a sample 
% files.txt you can quickly edit to run the CPCA application on.

  if ispc
    dircmd = '!dir /AD /ON /B "%s"';
  else
    dircmd = '!ls -l ''%s'' | grep -e ''^d.*'' | cut -d : -f 2 | cut -d \\  -f 2 | sed ''s/^/sdir /'' | sort';
  end;
  
  dirname = uigetdir('', 'Select the directory that contains your subjects');

  if isequal( dirname, 0)
    return;
  end;

  command = sprintf( dircmd, dirname );
  xx = evalc( command );

  D = dir(dirname);
  sz = size(D);
  Subjects = sz(1) - 2;  % remove the . .. directories - not 100% accurate, but good enough for now
  
  prompt = {'What filename do you want for the file list?'};
  dlg_title = 'Subject Scan Files List';
  num_lines = 1;
  def = cellstr( 'files.txt' );
  fn = inputdlg(prompt,dlg_title,num_lines,def );

  if ~isempty(fn)
    fid = fopen ( char(fn), 'w' );
    fprintf( fid, 'subjects %d\n', Subjects );
    fprintf( fid, '%s', xx );
    fprintf( fid, 'base_directory %s\n', dirname );
    fprintf( fid, 'list ws*.img\n' );
    fclose ( fid );

    fprintf( '%s contains:\n', char(fn) );
    filetext = readFiles(char(fn));
    filetext
  end;

  
