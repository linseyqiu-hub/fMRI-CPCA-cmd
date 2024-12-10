function save_columns_of_Z_cmd( Z,scan_information, SubjectNo, RunNo, FrequencyNo,Zheader )

  ftag = frequency_tag_cmd(FrequencyNo,scan_information) ;
  Zname = ['Z' filesep 'Z' num2str(SubjectNo) ftag '.mat'];

  start_col = 1;
  for column = 1:size( Zheader.partitions.columns,2)
    end_col = start_col + Zheader.partitions.columns(column) - 1;
    eval ( ['Z_R' num2str(RunNo) '_C' num2str(column) ftag ' = Z(:,start_col:end_col);' ] );
    eval ( [ 'save( ''' Zname ''', ''Z_R' num2str(RunNo) '_C' num2str(column) ftag ''', ''-append'' )' ] );
    start_col = end_col+1;
    eval ( ['clear Z_R' num2str(RunNo) '_C' num2str(column) ftag ] );
  end

end

