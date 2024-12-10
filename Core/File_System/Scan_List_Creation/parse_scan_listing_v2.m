function parse_scan_listing_v2( filename ) 
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
  frlabel = [];

  while ~feof( fid )

    input_line = strtrim(fgetl( fid ));		 % input a single line of text - remove CRLF pair or single

    if ( length(input_line) > 0 )
      if ( input_line(1) ~= '#' )

        input_line = strrep( input_line, ': ', ':' );	% users have been known to inset spaces on editing file
        e = parse_input_line( input_line );

        switch e(1).var

          case 'subjects'         
            scan_information.NumSubjects = str2double( e(1).value ) ;
%            SubjectNo = SubjectNo + 1;

          case 'runs'         
            scan_information.NumRuns = str2double( e(1).value ) ;

          case 'groups'     
            scan_information.NumGroups = str2double( e(1).value ) ;

          case 'multipleFrequency'     
            scan_information.isMulFreq = str2double( e(1).value ) ;

          case 'frequencies'     
            scan_information.frequencies = str2double( e(1).value ) ;

          case 'frlabels'    
             if ~strcmp( e(1).value, '<na>' );
               x = regexp(e(1).value, ':', 'split' );
               frlabel = x;

             end;
             
          case 'list'         
            scan_information.ListSpec = e(1).value;

          case 'base_directory'         
            scan_information.BaseDir = e(1).value;
            scan_information.BaseDir = strrep( scan_information.BaseDir, '%20', ' ' );

          case 'format'     
            scan_information.scandir_format = e(1).value;

                             %  (1)  subjDir          (2) id  (3) group (4) frequency        (5) runs
          case 'scandir'     % scandir:s06/images45Hz id:s06 group:<na> frequency:images45Hz runs:runa~runb

            SubjectNo = SubjectNo + 1;

            if ~strcmp(e(5).value, '<na>' ) ;				% --- test runs dirs for subject before processing subject id's	
              x = strcmp( scan_information.SubjectID, e(2).value ) ; 	% --- is this subject already in place?
              if ~any(x)
                scan_information.run_dirs = [ scan_information.run_dirs { e(5).value} ]; 

                runs = regexp(e(5).value, '~', 'split' );
                for ii = 1:size(runs,2)
                  runs(ii) = {[e(2).value filesep char(runs(ii))]};
                end;

                scan_information.SubjDir = vertcat([scan_information.SubjDir; runs]);
                scan_information.SubjDir = strtrim(scan_information.SubjDir); 

              end;
            end;

            x = strcmp( scan_information.SubjectID, e(2).value ) ;
            if any(x)  scan_information.duplicate_IDs = 1;  end;  	% [2.96]

            scan_information.SubjectID = [ scan_information.SubjectID { e(2).value} ]; 
            scan_information.SubjectDirs= [ scan_information.SubjectDirs { e(2).value} ]; 

            if ~strcmp(e(4).value, '<na>' ) ;
              x = strcmp( scan_information.freq_names, e(4).value ) ;
              if ~any(x)
                scan_information.freq_names = [ scan_information.freq_names { e(4).value} ]; 
                scan_information.freq_dirs = [ scan_information.freq_dirs { e(4).value} ]; 
              end;
            end;

            if ~strcmp(e(3).value, '<na>' ) ;
              x = strcmp( theseGroups, e(3).value ) ;
              if ~any(x)
                groupList = [groupList; grouping];
                grpIdx = size(groupList, 1);
                groupList(grpIdx).name = e(3).value;
                theseGroups = [theseGroups {e(3).value}];
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

  if ~isempty(frlabel) ;			
    scan_information.freq_names = frlabel;
  end;

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


