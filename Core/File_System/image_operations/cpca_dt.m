function typ = cpca_dt( dt )

  typ = '';
  s = cpca_data_type( dt );	% --- full dtat type structure

  if ~isempty( s.analyse )
    typ = lower( s.analyse );
  else
    typ = lower( s.nifti );
  end;

