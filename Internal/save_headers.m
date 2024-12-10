function save_headers()
global Zheader scan_information 

% --- revision 1.0  Oct 1, 2012
% --- continuous use of 'append' to save changing Zheader and 
% --- scan_information data appears to have an accumulated effect on ZInfo data
% --- file size.  One instance saw a 250Mb file, which, when loaded and resaved,
% --- reduced down to 890Kb.  Function altered to load other variables and
% --- resave entire file without append;

  if ( length( Zheader.Z_Directory ) == 0 )  return; end;

  Zfile = [pwd filesep 'ZInfo.mat'];

  x = exist( Zfile );
  if ( x == 0 )		% copy original ZInfo to local to preserve all summary data
    if ( length(Zheader.Z_Directory) > 0 )

      origZfile = [Zheader.Z_Directory 'ZInfo.mat'];

      y = exist( origZfile );
      if ( y == 2 )		% copy original ZInfo to local to preserve all summary data
        copyfile( [Zheader.Z_Directory 'ZInfo.mat'], Zfile );

        if length( Zheader.Z_Original) == 0
          Zheader.Z_Original = Zheader.Z_Directory;
        end;
      end;

      Zheader.Z_Directory = pwd;
    end;
  end;

  secondaries = '';
  x = exist( Zfile );
  if ( x > 0 )
    
    load( Zfile, 'SD', 'tsum_removed' );
    
    if exist( 'SD', 'var' )
      secondaries = ', ''SD''';
      isSD = 1;
    end;

    if exist( 'tsum_removed', 'var' )
      if isSD
        secondaries = [secondaries ', ''tsum_removed'''];
      else
        secondaries = ', ''tsum_removed''';
      end;
      isSD = 1;  % -- this format allows variabloe expansion
    end;
    
  end;

  eval( [ 'save( ''' Zfile ''', ''Zheader'', ''scan_information''' secondaries ', ''-v7.3'')'] );


