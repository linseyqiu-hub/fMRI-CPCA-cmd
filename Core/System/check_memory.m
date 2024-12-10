function stats = check_memory()
% check memory availabiltiy

  s = struct ( ...
    'total', 0, ...
    'used', 0, ...
    'free', 0, ...
    'cache', 0 );

  r = struct ( ...
    'per_column', 0, ...
    'per_row', 0, ...
    'total', 0 );

  stats.user = s;
  stats.swap = s;

  stats.matrix = r;
  stats.matrix.instances = 3;	% large data sets require a large amount of free mem for concats and mults
  stats.format = '   Mem:\tTotal\t Used\t Free\tCache\t(Mb)\n%6s:\t%5d\t%5d\t%5d\t%5d\n%6s:\t%5d\t%5d\t%5d\t  ---\n%6s:\t%5d\t%5d\t%5d\n';

  if ispc
    % % --- note on windows applications
    % % --- The MSVC GlobalMemoryStatusEx( %statestruct )
    % % --- returns the true amount of physically installed memory
    % % --- the amount of actual available physical memory is constantly changing
    % % --- and at times reflects additional swap file memory (WTF!!)
    % % --- thus, the total installed memory is fairly reliable
    % % --- the amount of memory available is totally unreliable 
    % 
    % cmd = ['!"' constant_define( 'WIN_MEM_TOOL' ) '\memchk.exe"'];
    % xx = evalc(cmd);
    % stats.user.total=sscanf( char(xx), '%*s%d%*s' );
    % stats.user.free=sscanf( char(xx), '%*s%*d%*s%d' );  % Wayne: stats.user.total;
    % --- use Matlab own memory function, this is more accurate than
    % --- memchk.exe
    [user,sys] = memory;
    stats.user.free=sys.SystemMemory.Available/2^20; %in MB
    stats.user.total=sys.PhysicalMemory.Total/2^20;  %in MB
  else

    if ismac
        
      mem = evalc('!top -l 1 -n 1');

      sp = strfind( mem, 'used')-6;
      ep = strfind( mem, 'unused')-1;   % Wayne: 'free' was used before
      x = strrep( mem(sp:ep), ',', ' ' ); % Wayne: the first char may be a comma, producing errors
      x = strrep( x, ':', ' ' ); % Wayne: add this line
      vals = sscanf( x, '%f%s' );
      stats.user.used = vals(1);
      if ( vals(2) == 71 )
        stats.user.used = stats.user.used * 1024;
      end

      sp = ep-5;
      x = strrep( mem(sp:ep), ',', ' ' );   % on small numbers, the first char may be a comma, producing errors
      x = strrep( x, ':', ' ' ); % Wayne: add this line
      vals = sscanf( x, '%f%s' );
      stats.user.free = vals(1);
      if ( vals(2) == 71 )
        stats.user.free = stats.user.free * 1024;
      end
 
      stats.user.total = stats.user.used + stats.user.free;
      
    else

      mem=evalc('!free -m');
      sz=size(mem,2);

      value=strfind(mem,'Mem:');
      stats.user.total=sscanf(mem(value:sz),'%*s%d%*d%*d%*d%*d');
      stats.user.used=sscanf(mem(value:sz),'%*s%*d%d%*d%*d%*d');
      stats.user.free=sscanf(mem(value:sz),'%*s%*d%*d%d%*d%*d');
      stats.user.cache=sscanf(mem(value:sz),'%*s%*d%*d%*d%*d%*d%d');

      value=strfind(mem,'Swap:');
      stats.swap.total=sscanf(mem(value:sz),'%*s%d%*d%*d%*d%*d');
      stats.swap.used=sscanf(mem(value:sz),'%*s%*d%d%*d%*d%*d');
      stats.swap.free=sscanf(mem(value:sz),'%*s%*d%*d%d%*d%*d');

    end % unix memory check

  end % pc memory check

