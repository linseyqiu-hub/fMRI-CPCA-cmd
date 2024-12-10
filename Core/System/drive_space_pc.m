function dr = drive_space_pc()
% determine drive space on current working drive
%
% processes fuser to determine most likely drive by file usage.  Root device comparison
% to mtab may be in error if user cd's to a device via a symlink
%
% will return a struct containing the device, total, used and available space
% for ensuring current working space is enough for potential output of matrices

  dr = struct ( ...
    'device', 'pc', ...
    'size', 0, ...
    'used', 0, ...
    'free', 0 );

  xx = evalc('!dir \' );
  sz=size(xx,2);
  
  value=findstr(xx,'Directory of ');
  dr.device = sscanf(xx(value:sz),'%*s%*s%s%*');
  dr.free = floor(str2double(sscanf( xx(1,length(xx)-32:length(xx)), '%*s%s%*s'))/1024000) ;
  

