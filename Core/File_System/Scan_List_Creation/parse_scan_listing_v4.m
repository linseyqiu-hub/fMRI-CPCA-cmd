function parse_scan_listing_v4( filename ) 
% parses the contents of a file list
%
% process the informaton from text file
% scan listing format version 1
% --------------------------------------------------------
% text info format:
% subjects:{n}   	- number of scanned subjects each in their own subdirectory
% runs:{n}   		- number of runs per subject
% groups:{n}   		- number of subject groupings
% meg:{n}
% frequencies:{n}
% base_directory:{str}	- the full path of the main directory each subject directory resides in
% list:{str}		- the file spec for reding image files eg: ws*.img


% actual list entries will now contain all section information
% to maintain a consistant parsing indexing
% sections unused will have a value of '<na>'
%scandir:s05/images25Hz id:s05 group:<na> frequency:images25Hz runs:run1~run2
%scandir:s05/images45Hz id:s05 group:<na> frequency:images45Hz runs:run1~run2
%scandir:s06/images25Hz id:s06 group:<na> frequency:images25Hz runs:run1~run2
%scandir:s06/images45Hz id:s06 group:<na> frequency:images45Hz runs:runa~runb
%


global scan_information 

  % --------------------------------------------------------
  % --- open the file for read access
  fid = fopen( filename, 'r' );
  x = fgets( fid );		  % bypass the version flag
  thisGroup = '';
  theseGroups = '';
  thisGrpIdx = 0;
  grouping = structure_define( 'SUBJECT_GROUP' );
  groupList = [];
  SubjectNo = 0;

  scan_information.NumSubjects = count_subjects(filename);

%              e(1) tag         e(2) subject dir   e(3) ID     e(4) group       e(5) frequency      e(6) runs
%  sdirstr = ['scandir:' fmt ' sdir:{subject}     id:{subject} group:{group} frequency:{frequency} runs:{runs}'];
  idx_tag = 1;
  idx_subject_dir = 2;
  idx_subject_id = 3;
  idx_group = 4;
  idx_frequency = 5;
  idx_runs = 6;

  if ispc
    this_from = '/';
    this_to = '\';
  else
    this_to = '/';
    this_from = '\';
  end;

  this_defined_freq = 0;

  while ~feof( fid )

    input_line = strtrim(fgetl( fid ));		 % input a single line of text - remove CRLF pair or single

    if ( length(input_line) > 0 )
      if ( input_line(1) ~= '#' ) && ( input_line(1) ~= '%' )

        input_line = strrep( input_line, ': ', ':' );		% users have been known to inset spaces on editing file
        input_line = strrep( input_line, this_from, this_to);	% ensure constant path delimiter
        e = parse_input_line( input_line );

        switch e(idx_tag).var

          case 'subjects'         
            NumSubjects = str2double( e(idx_tag).value ) ;
            if NumSubjects ~= scan_information.NumSubjects
              disp( [ 'WARNING: Subject count variable (' e(idx_tag).value ') does not match number of entries in file (' num2str(scan_information.NumSubjects) ') : using number of entries.' ] );
            end;
            
%            SubjectNo = SubjectNo + 1;

          case 'runs'         
            scan_information.NumRuns = str2double( e(idx_tag).value ) ;

          case 'minRunCount'         
            scan_information.MinRuns = str2double( e(idx_tag).value ) ;

          case 'groups'     
            scan_information.NumGroups = str2double( e(idx_tag).value ) ;

          case 'multipleFrequency'     
            scan_information.isMulFreq = str2double( e(idx_tag).value ) ;

          case 'frequencies'     
            scan_information.frequencies = str2double( e(idx_tag).value ) ;

         case 'frlabels'     
            lst = regexp( e(idx_tag).value, '~', 'split');
            scan_information.freq_names = lst;

          case 'list'         
            scan_information.ListSpec = e(idx_tag).value;

          case 'base_directory'         
            scan_information.BaseDir = e(idx_tag).value;
            scan_information.BaseDir = strrep( scan_information.BaseDir, '%20', ' ' );

          case 'format'     
            scan_information.scandir_format = e(idx_tag).value;

                             %  (1)  subjDir          (2) id  (3) group (4) frequency        (5) runs
          case 'scandir'     % scandir:s06/images45Hz id:s06 group:<na> frequency:images45Hz runs:runa~runb

            this_defined_freq = this_defined_freq + 1;
            if ( this_defined_freq > scan_information.frequencies ) this_defined_freq = 1; end;

            SubjectNo = SubjectNo + 1;
% --- for multiple frequency parsing, each subject will have a sequential line for each defined frequency
% --- use if ( prev_id == this id and this_freq < nfreq ) to bypass additions
% --- fsck the prev id value - errors in id may be sequential
% --- the method for ensuring no id overrun os to seqential the lines when isMulFreq

            if this_defined_freq == 1
                
              if ~strcmp(e(idx_runs).value, '<na>' ) ;				% --- test runs dirs for subject before processing subject id's	
                x = strcmp( scan_information.SubjectID, e(idx_subject_id).value ) ; 	% --- is this subject already in place?
                if (~any(x) && scan_information.isMulFreq ) || ~scan_information.isMulFreq
                  scan_information.run_dirs = [ scan_information.run_dirs { e(idx_runs).value} ]; 

                  n = cell( 1, scan_information.NumRuns );
                  runs = regexp(e(idx_runs).value, '~', 'split' );
                  for ii = 1:size(runs,2)
                    n(ii) = {[e(idx_subject_dir).value filesep char(runs(ii))]};
                  end;

                  n = strtrim(n); 
                  scan_information.SubjDir = horzcat([scan_information.SubjDir; n]);

                end;
              end;

              x = strcmp( scan_information.SubjectID, e(idx_subject_id).value ) ;
              if any(x)  scan_information.duplicate_IDs = 1;  end;  	% [2.96]

              scan_information.SubjectID = [ scan_information.SubjectID { e(idx_subject_id).value} ]; 
              scan_information.SubjectDirs= [ scan_information.SubjectDirs { e(idx_subject_dir).value} ]; 

            end;
            
            if ~strcmp(e(idx_frequency).value, '<na>' ) ;
              x = strcmp( scan_information.freq_dirs, e(idx_frequency).value ) ;
              if ~any(x)
%                scan_information.freq_names = [ scan_information.freq_names { e(idx_frequency).value} ]; 
                scan_information.freq_dirs = [ scan_information.freq_dirs { e(idx_frequency).value} ]; 
              end;
            end;

            if ~strcmp(e(idx_group).value, '<na>' ) ;
              x = strcmp( theseGroups, e(idx_group).value ) ;
              if ~any(x)
                groupList = [groupList; grouping];
                grpIdx = size(groupList, 1);
                groupList(grpIdx).name = e(idx_group).value;
                theseGroups = [theseGroups {e(idx_group).value}];
              else
                grpIdx = find(x);
              end;

              groupList(grpIdx).subjectlist = [strtrim(groupList(grpIdx).subjectlist) ' ' num2str(SubjectNo) ];
              groupList(grpIdx).subjectcount = groupList(grpIdx).subjectcount + 1;
            end;



        end;   % --- end switch ---

      end;  % -- inline not commented out
    end;  % -- inline length > 0 

  end;

  fclose(fid);

  scan_information.GroupList = groupList; 
  scan_information.frequencies = max( 1, scan_information.frequencies );

  if isempty( scan_information.freq_names )	scan_information.freq_names = {''};	end;
  if isempty( scan_information.freq_dirs )	scan_information.freq_dirs = {''};	end;
  if isempty( scan_information.SubjDir )	scan_information.SubjDir = scan_information.SubjectDirs';	end;

  for SubjectNo = 1:scan_information.NumSubjects
    for ii = 1:scan_information.NumRuns
      check_rp_file( SubjectNo, ii );
    end;
  end;

function values = parse_input_line( input_line )

  values = [];
  x = struct( 'var', '', 'value', '' );

  line = strrep( input_line, '  ', ' ' );
  e = regexp(strtrim(line), ' ', 'split' );

  for ii = 1:size(e,2)
    thisone = regexp(char(e(ii)), ':', 'split' );
    x.var = strtrim( char( thisone(1) ) );
    x.value = strtrim( char( thisone(2) ) );

    if ( size(thisone,2) > 2 )
      for jj = 3:size(thisone,2)
        x.value = [ x.value ':' strtrim( char( thisone(jj) ) ) ];
      end;
    end;

    values = [values; x];
  end;



function check_rp_file( SubjectNo, RunNo )
global scan_information 

  if iscellstr(scan_information.SubjDir(SubjectNo,RunNo))

    filespec=strcat( scan_information.BaseDir,filesep, char(scan_information.SubjDir(SubjectNo,RunNo)),filesep);

    p = dir( [filespec 'rp_*.txt'] );
    if ( size(p,1) > 0 )
      f = load( [filespec p(1).name] );
      [r c] = get_subject_scan_count( SubjectNo, RunNo );

      if ( size(f,1) == r ) 
        scan_information.processing.subjects.rp_count = scan_information.processing.subjects.rp_count + 1;
      end;
    end;

  end;

