function sz = array_sizes( arrsz, typ )
% --- returns a structure containing the amount of memory the arry consumes
% ---  sz.bytes
% ---  sz.kilobytes
% ---  sz.megabytes
% ---  sz.gigabytes
% ---
% --- type indicate what data type the array uses - default is double (8 byte)

  if nargin < 2 typ = 'double';  end;

  sz = struct ( ...
    'bytes'    , 0, ...
    'kilobytes', 0, ...
    'megabytes', 0, ...
    'gigabytes', 0, ...
    'terrabytes', 0, ...
    'sz_display', '', ...
    'mem_display', '');

  switch lower(typ)
    case {'double'},    bsize = 8;
    case {'float'},     bsize = 8;
    case {'int16'},     bsize = 2;
    case {'int32'} ,    bsize = 4;
    otherwise,          bsize = 8;
  end;
  
  sz.bytes = arrsz(1) * arrsz(2) * bsize;
  sz.kilobytes = sz.bytes / 1024;
  sz.megabytes = sz.kilobytes / 1000;
  sz.gigabytes = sz.megabytes / 1000;
  sz.terrabytes = sz.gigabytes / 1000;

  sz.sz_display = sprintf( '(%6d x %6d)', arrsz(1), arrsz(2) ); 
  if ( floor( sz.terrabytes ) > 0 ) sz.mem_display = sprintf( '%9.02f Tb', sz.terrabytes ); return; end;
  if ( floor( sz.gigabytes ) > 0 ) sz.mem_display = sprintf( '%9.02f Gb', sz.gigabytes ); return; end;
  if ( floor( sz.megabytes ) > 0 ) sz.mem_display = sprintf( '%9.02f Mb', sz.megabytes ); return; end;
  if ( floor( sz.kilobytes ) > 0 ) sz.mem_display = sprintf( '%9.02f Kb', sz.kilobytes ); return; end;
  sz.mem_display = sprintf( '%10d bytes', sz.bytes );

