function dr = drive_space_mac()
% determine drive space on current working drive
%
% processes fuser to determine most likely drive by file usage.  Root device comparison
% to mtab may be in error if user cd's to a device via a symlink
%
% will return a struct containing the device, total, used and available space
% for ensuring current working space is enough for potential output of matrices

% Wayne: borrowed idea from drive_space_nix, the original code is not working
  dr = struct ( ...
    'device', 'mac', ...
    'size', 0, ...
    'used', 0, ...
    'free', 0 );

  %x=evalc('!df | grep Filesystem');
  %nonext = isempty( strfind( x, 'iused' ) );  % -- some macs will return extended information
  
  d = evalc( '!mount | grep "/dev/" | grep -v "none" | cut -d \  -f 1,3' );
  d = regexp( d, '\n', 'split');
  %p = pwd;

  found = '';
  found_size = 0;
  found_dev = '';

  for dvc = 1:size(d,2)
    if size( char(d(dvc)),2) > 0

      dev = regexp( char(d(dvc)), ' ', 'split' );
      mountpoint = dev(2);
      device = dev(1);

      %sz = size( char(mountpoint), 2);
      x = strfind( pwd, char(mountpoint) );
      if ~isempty(x)
        if size( char(mountpoint), 2) > found_size
          if x(1) == 1
            found_size = size( char(mountpoint), 2);
            found = char(mountpoint);
            found_dev = char(device);
          end
        end
      end
    end

  end

  if size( found,2) > 0 
    
    command = sprintf( '!df -P -k | grep  %s\n', found_dev ); %Wayne: `found` was used before, -P used to suppress inode, -k to use 1k
    xx=evalc( command );
    dr.device = found_dev;
    C = strsplit(xx, found_dev);
    xx = C{1, 2};
    dr.size = floor(sscanf( xx, '%d%*d%*d%*d')/1000);
    dr.used = floor(sscanf( xx, '%*d%d%*d')/1000);
    dr.free = floor(sscanf( xx, '%*d%*d%d')/1000);
  end


  % x=evalc('!df | grep Filesystem');
  % nonext = isempty( strfind( x, 'iused' ) );  % -- some macs will return extended information
  % 
  % x=evalc('!df | grep ''/dev/'' | grep -ve ''pts\|tmpfs\|Volumes'' | cut -d \  -f 1');
  % devs=regexp(x, '\n', 'split');
  % sz=size(devs);
  % % first - how many devices are used by matlab?
  % devfs = '';
  % 
  % for  ii = 1:sz(2)
  % 
  %   if length( char(devs(ii)) ) > 0 
  % 
  %     command = sprintf( '!mount | grep %s | cut -d \  -f 3\n', char(devs(ii)) );
  %     str=evalc( command);
  %     s=size(str);
  % 
  %     if s(2) > 0 
  %       if length( devfs) > 0
  %         devfs = strcat( devfs, '~', char(devs(ii)) );
  %       else
  %         devfs = char(devs(ii));
  %       end
  %     end;
  % 
  %   end;
  % 
  % end;
  % 
  % devfs=regexp(devfs, '~', 'split');
  % sz=size(devfs);
  % 
  % if sz(2) == 1  % only 1 device listed - this is the one in use 
  %   command = sprintf( '!df | grep  %s\n', char(devfs(1)) );
  %   xx=evalc( command );
  %   dr.device = char(devs(1));
  %   if nonext
  %     dr.size = floor(sscanf( xx, '%*s%d%*d%*d')/1000);
  %     dr.used = floor(sscanf( xx, '%*s%*d%d%*d')/1000);
  %     dr.free = floor(sscanf( xx, '%*s%*d%*d%d')/1000);
  % 
  %   else  
  %     dr.size = floor(sscanf( xx, '%*s%d%*s%')/1000);
  %     dr.used = floor(sscanf( xx, '%*s%*d%d%*s%')/1000);
  %     dr.free =  floor(sscanf( xx, '%*s%*d%*d%d%*s%')/1000);
  %   end
  % 
  % else
  % 
  %   % if there is more than 1 device entry, the most likely candidate
  %   % would be the one mounted at the root of the pwd
  %   root = regexp( pwd, '/', 'split' );
  %   root = strcat( '/', root(2) );
  %   command = sprintf( '!cat /etc/mtab | grep ''%s''', char(root) );
  % %  rslt = evalc(command);
  % %  devfs = regexp( rslt, ' ', 'split' );
  % %  s = size( devfs );
  % 
  % end;
  % 
