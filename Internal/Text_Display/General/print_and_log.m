function print_and_log( fid, fmt, varargin )


  optargin = size(varargin,2);
  flds = [];
  fldn = '';
  for ii = 1:optargin
    fldn = sprintf( 'fld%d', ii );
    flds = [flds {fldn}];
  end;

  cmd = [ 'fprintf( ''' fmt '''' ];
  cmdf = [ 'fprintf( ' num2str(fid) ', ''' fmt '''' ];

  if ( optargin )
    these = cell2struct( varargin, flds, 2 );

    for ii = 1:optargin
      fldn = sprintf( 'fld%d', ii );
      evalc( [ 'xx = ischar( these.' fldn ');'] );
      cmd = [ cmd ', these.' fldn ];
      cmdf = [ cmdf ', these.' fldn ];
    end;

  end;

  cmd = [ cmd ');' ];
  cmdf = [ cmdf ');' ];

  eval(cmd)

  if ( fid )
    eval(cmdf)
  end;



