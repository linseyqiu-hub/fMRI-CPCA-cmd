function mid = mask_identifier( SubjectNo, RunNo )
global scan_information

  mid = '';
  
  if nargin < 2
    return;
  end;
  
  grp = '';
  if ~isempty( regexp( scan_information.scandir_format, '{group_dir}', 'match' ) )
    if ~isempty(scan_information.GroupList)
      for ii = 1:size(scan_information.GroupList)
         sl = str2num(scan_information.GroupList(ii).subjectlist);
         if any(sl == SubjectNo )
           grp = [ scan_information.GroupList(ii).name '_'];
         end;
      end
    end
  end
   
  if size(scan_information.SubjectID, 2 ) >= SubjectNo 
    sid =  strrep( char(scan_information.SubjDir(SubjectNo, RunNo)), filesep, '_' ) ;
    mid = [ grp sid ];
  else
    sid = subject_id( SubjectNo );
    mid = [ grp sid '_run_' num2str(RunNo) ];  
  end;


end

