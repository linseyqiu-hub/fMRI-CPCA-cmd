function Z = load_Z_column( SubjectNo, RunNo, column, ftag );
global Zheader

  if nargin < 4
    ftag = '';
  end;

  Z = [];

  if nargin < 3
    disp( [ 'ERROR: load_Z_column passed no information on which column to load.' ] );
    return
  end;
  
  Normalized_Z_Dir = Z_Directory();
  ZName = [ Normalized_Z_Dir 'Z' filesep 'Z' num2str(SubjectNo) ftag '.mat'];

  if ~isempty( ftag )
    n = matfile_vars( [Normalized_Z_Dir 'Z' filesep], ['Z' num2str(SubjectNo) ftag '.mat'], 'Z_R1_C1*' );
    if isempty(n)
      ZName = [ Normalized_Z_Dir 'Z' filesep 'Z' num2str(SubjectNo) '.mat'];
    end;
  end;

  %  eval ( [ 'load( ''' Normalized_Z_Dir 'Z' filesep 'Z' num2str(SubjectNo) ftag '.mat'', ''Z_R' num2str(RunNo) '_C' num2str(column) ftag ''');'] );
  eval ( [ 'load( ZName, ''Z_R' num2str(RunNo) '_C' num2str(column) ftag ''');'] );
  eval ( [ 'Z = Z_R' num2str(RunNo) '_C' num2str(column) ftag ';' ] );

end


