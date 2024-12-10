function rtn = calc_column_partitions( scans, vox, max_mem )

  rtn = struct( 'count', 0, 'width', 0, 'mem', 0, 'columns', [], 'last', 0, 'partitioned', 0, 'max_sz', max_mem );

  ii = 1;
  xx = array_sizes( [scans ceil(vox/ii) ] );
  while ( xx.megabytes > max_mem )
    ii = ii + 1;
    xx = array_sizes( [scans ceil(vox/ii) ] );
  end;

  rtn.mem = xx;
  rtn.width = ceil(vox/ii);
  rtn.count = ii;

  for col = 1:(ii-1)
    rtn.columns = [rtn.columns rtn.width];
  end
  rtn.last = ceil(vox/ii) - abs(vox - (ceil(vox/ii)*ii) );
  rtn.columns = [rtn.columns rtn.last];

