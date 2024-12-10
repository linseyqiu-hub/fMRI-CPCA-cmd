function save_columns_of_Z( Z, SubjectNo, RunNo, FrequencyNo )
global Zheader

  ftag = frequency_tag(FrequencyNo) ;
  Zname = ['Z' filesep 'Z' num2str(SubjectNo) ftag '.mat'];

  start_col = 1;
  for column = 1:size( Zheader.partitions.columns,2)
    end_col = start_col + Zheader.partitions.columns(column) - 1;
    eval ( ['Z_R' num2str(RunNo) '_C' num2str(column) ftag ' = Z(:,start_col:end_col);' ] );
    eval ( [ 'save( ''' Zname ''', ''Z_R' num2str(RunNo) '_C' num2str(column) ftag ''', ''-append'', ''-v7.3'' )' ] );
    start_col = end_col+1;
    eval ( ['clear Z_R' num2str(RunNo) '_C' num2str(column) ftag ] );
  end;

end

