function v = load_subject_Z_var_cmd(Zheader, SubjectNo, varname )

  v = [];
  Normalized_Z_Dir = Z_Directory_cmd(Zheader);
  ZName = [ Normalized_Z_Dir 'Z' filesep 'Z' num2str(SubjectNo) '_vars.mat'];

  if ~exist( ZName, 'file' )  % -- older file system
    ZName = [ Normalized_Z_Dir 'Z' filesep 'Z' num2str(SubjectNo) '.mat'];
  end

  load( ZName, varname );
  if exist( varname, 'var' )
    eval ( [ 'v = ' varname ';' ] );
  end
  
end


