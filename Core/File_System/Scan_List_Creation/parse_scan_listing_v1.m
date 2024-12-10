function parse_scan_listing_v1( filename ) 
% parses the contents of a file list
%
% process the informaton from text file
% scan listing format version 1
% --------------------------------------------------------
% text info format:
% Groups:{n}   		- number of subject groupings
% subjects:{n}   	- number of scanned subjects each in their own subdirectory
% runs:{n}   		- number of runs per subject
% base_directory:{str}	- the full path of the main directory each subject directory resides in
% list:{str}		- the file spec for reding image files eg: ws*.img

% actual list entries vary depending on format
% sdir:s01 id:s01
% sdir:s01 id:s01 run:run1~run2
% sdir:Controls/s01 id:s01 group:Controls
% sdir:Controls/s01 id:s01 group:Controls run:runa~runb
%
% first 2 entries will always be source directory and subject ID code
% if a third and/or fourth entry exist )
%   third entry will be Group name if Groups > 0, otherwise runs
%   fourth entry will be always be runs


global scan_information 

  % --------------------------------------------------------
  % --- open the file for read access
  fid = fopen( filename, 'r' );
  x = fgets( fid );		  % bypass the version flag
  thisGroup = '';
  thisGrpIdx = 0;
  grouping = structure_define( 'SUBJECT_GROUP' );
  groupList = [];
  SubjectNo = 0;

  while ~feof( fid )

    x = fgetl( fid );		  % input a single line of text - remove CRLF pair or single

    if ( length(x) > 0 )
      if ( x(1) ~= '#' )

        x = strrep( x, ': ', ':' );	% users have been known to inset spaces on editing file

        entry = regexp(x, ' ', 'split' );
        if ( size( entry,2) == 1 )	% basic entry

          e = regexp(char(entry), ':', 'split' );
          switch strtrim(char(e(1)))
            case 'groups'     
              scan_information.NumGroups = str2double( strtrim(char(e(2))) );
            case 'subjects'         
              scan_information.NumSubjects = str2double( strtrim(char(e(2))) ) ;
            case 'runs'         
              scan_information.NumRuns = str2double( strtrim(char(e(2))) ) ;
            case 'list'         
             scan_information.ListSpec = strtrim(char(e(2)));
            case 'base_directory'         
             if ( ispc() )
               scan_information.BaseDir = [strtrim(char(e(2))) ':' strtrim(char(e(3))) ];
             else
               scan_information.BaseDir = strtrim(char(e(2)));
             end;
             scan_information.BaseDir = strrep( scan_information.BaseDir, '%20', ' ' );

          end;

        else

          for ii = 1:2

            e = regexp(char(entry(ii)), ':', 'split' );
            switch strtrim(char(e(1)))

              case 'sdir'     
                runIdx = size(entry,2);
                SubjectNo = SubjectNo + 1;
                if scan_information.NumGroups > 1
                  grpIdx = size(entry,2) - ( scan_information.NumRuns > 1 ) ;
                  xx = regexp(char(entry(grpIdx)), ':', 'split' );
                  if ~strcmp( thisGroup, char(xx(2)) )
                    thisGroup = char(xx(2));
                    thisGrpIdx = thisGrpIdx + 1;
                    groupList = [groupList; grouping];
                    groupList(thisGrpIdx).name = char(xx(2));
                  end;
  
                  groupList(thisGrpIdx).subjectlist = [strtrim(groupList(thisGrpIdx).subjectlist) ' ' num2str(SubjectNo) ];
                  groupList(thisGrpIdx).subjectcount = groupList(thisGrpIdx).subjectcount + 1;
  
                end;

                
%                if scan_information.NumRuns > 1
                if runIdx > 2
                  xx = regexp(char(entry(runIdx)), ':', 'split' );
                  if strcmp( char(xx(1)), 'run')
                    runs = regexp(char(xx(2)), '~', 'split' );
                    for ii = 1:size(runs,2)
                      runs(ii) = {[char(e(2)) filesep char(runs(ii))]};
                    end;

                    scan_information.SubjDir = vertcat([scan_information.SubjDir; runs]);
                    scan_information.SubjDir = strtrim(scan_information.SubjDir); 

                    for ii = 1:size(runs,2)
                      check_rp_file( SubjectNo, ii );
                    end;
                  else
                    runs = {char(e(2))};
                    scan_information.SubjDir = vertcat([scan_information.SubjDir; runs]);
                    scan_information.SubjDir = strtrim(scan_information.SubjDir); 
                  end;
                  
                else
                  runs = {char(e(2))};
                  scan_information.SubjDir = vertcat([scan_information.SubjDir; runs]);
                  scan_information.SubjDir = strtrim(scan_information.SubjDir); 
                  check_rp_file( SubjectNo, 1 );
                end;  

%                scan_information.SubjDir = vertcat([scan_information.SubjDir; runs]);

              case 'id'     
                scan_information.SubjectID = [ scan_information.SubjectID {char(e(2))} ]; 

            end;   % --- end switch ---
          end;   % --- end for loop  ---

        end;  % -- inline == sdir
      end;  % -- inline not commented out
    end;  % -- inline length > 0 

  end;

  fclose(fid);

%  scan_information.SubjDir = strtrim(scan_information.SubjDir); 
%  scan_information.SubjectID = strtrim(scan_information.SubjectID); 
  scan_information.GroupList = groupList; 



function check_rp_file( SubjectNo, RunNo )
global scan_information

  filespec=strcat( scan_information.BaseDir,filesep, char(scan_information.SubjDir(SubjectNo,RunNo)),filesep);

  if ispc()
    x = file_count_pc( filespec, 'rp_*.txt' );
  else
    x = str2num( evalc( [ '!ls ''' filespec ''' | grep -ce "rp_.*.txt"' ]) );
  end;

  if ( x == 1 )
    p = dir( [filespec 'rp_*.txt'] );
    if ( size(p,1) > 0 )
      f = load( [filespec p(1).name] );
      [r c] = get_subject_scan_count( SubjectNo, RunNo );

      if ( size(f,1) == r ) 
        scan_information.processing.subjects.rp_count = scan_information.processing.subjects.rp_count + 1;
      end;
    end;

  end;


