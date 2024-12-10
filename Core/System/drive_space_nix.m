function dr = drive_space_nix()
% determine drive space on current working drive
%
% processes fuser to determine most likely drive by file usage.  Root device comparison
% to mtab may be in error if user cd's to a device via a symlink
%
% will return a struct containing the device, total, used and available space
% for ensuring current working space is enough for potential output of matrices

  dr = struct ( ...
    'device', '', ...
    'size', 0, ...
    'used', 0, ...
    'free', 0 );

% --- revised code to eliminate fuser command
% --- network disconnect of NFS drives can cause 2 minute timeout per device check
% ---

  d = evalc( '!mount | grep "/dev/" | grep -v "none" | cut -d \  -f 1,3' );
  d = regexp( d, '\n', 'split');
  p = pwd;

  found = '';
  found_size = 0;
  found_dev = '';

  for dvc = 1:size(d,2)
    if size( char(d(dvc)),2) > 0

      dev = regexp( char(d(dvc)), ' ', 'split' );
      mountpoint = dev(2);
      device = dev(1);

      sz = size( char(mountpoint), 2);
      x = strfind( pwd, char(mountpoint) );
      if ~isempty(x)
        if size( char(mountpoint), 2) > found_size
          if x(1) == 1
            found_size = size( char(mountpoint), 2);
            found = char(mountpoint);
            found_dev = char(device);
          end;
        end;
      end;
    end;

  end;

  if size( found,2) > 0 
    
    command = sprintf( '!df | grep  %s\n', found_dev ); %Wayne: `found` was used before
    xx=evalc( command );
    dr.device = found_dev;
    C = strsplit(xx, found_dev);
    xx = C{1,2};
    dr.size = floor(sscanf( xx, '%d%*d%*d%*d')/1000);
    dr.used = floor(sscanf( xx, '%*d%d%*d')/1000);
    dr.free = floor(sscanf( xx, '%*d%*d%d')/1000);
  end;
