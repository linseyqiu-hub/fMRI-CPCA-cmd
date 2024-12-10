function dtyp = cpca_data_type( dt )
  dtyp = [];
 
  dtypes = cpca_data_types();

  dtyp_found = 1;
  for ( ii = 2:size(dtypes,1) )

    if ischar(dt)
      if ( strcmp( dtypes(ii).nifti, upper(dt) ) | strcmp( dtypes(ii).analyse, upper(dt) ) )
        dtyp_found = ii;
        break;
      end;

    else
      if ( dtypes(ii).code == dt )
        dtyp_found = ii;
        break;
      end;
    end;
  end;

  dtyp = dtypes(dtyp_found);

  if ( dtyp.conversion == 0 )		% if no conversion, then use original code
    dtyp.conversion = dtyp.code;
  end;

