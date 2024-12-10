function Z = load_subject_Z( SubjectNo, ftag );
global Zheader scan_information

  if nargin < 2
    ftag = '';
  end;

  Z = zeros( sum(Zheader.timeseries.subject(SubjectNo).run(:,1)), Zheader.total_columns);
  
  Normalized_Z_Dir = Z_Directory();
  ZName = [ Normalized_Z_Dir 'Z' filesep 'Z' num2str(SubjectNo) ftag '.mat'];

  if ~isempty( ftag )
    n = matfile_vars( [Normalized_Z_Dir 'Z' filesep], ['Z' num2str(SubjectNo) ftag '.mat'], 'Z_R1_C1*' );
    if isempty(n)
      ZName = [ Normalized_Z_Dir 'Z' filesep 'Z' num2str(SubjectNo) '.mat'];
    end;
  end;

  end_row = 0;
  for RunNo = 1:Zheader.num_runs
    if isEncodedRun( SubjectNo, RunNo ) 

      start_row = end_row + 1;
      end_row = start_row + Zheader.timeseries.subject(SubjectNo).run(RunNo,1) - 1;
      
      end_col = 0;
      for column = 1:Zheader.partitions.count

        start_col = end_col + 1;
        end_col = start_col + Zheader.partitions.columns(column) - 1;
             
        eval ( [ 'load( ZName, ''Z_R' num2str(RunNo) '_C' num2str(column) ftag ''');'] );
        eval ( [ 'Z(start_row:end_row,start_col:end_col) = Z_R' num2str(RunNo) '_C' num2str(column) ftag ';' ] );

        clear Z_R*;
      end; 
    end; 
  end; 

end


