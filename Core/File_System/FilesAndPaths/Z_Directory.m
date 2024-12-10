function zdir = Z_Directory()
global Zheader

    zdir = Zheader.Z_Directory;
    if length( Zheader.Z_Original ) > 0 
      zdir = Zheader.Z_Original;
    end;

    if ~isempty( zdir ) && zdir(end) ~= filesep
       zdir = [zdir filesep];
    end;
