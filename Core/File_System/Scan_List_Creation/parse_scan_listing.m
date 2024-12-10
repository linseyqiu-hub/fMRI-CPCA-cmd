function parse_scan_listing( filename ) 
% parses the contents of a file list
%
% process the informaton from text file
% --------------------------------------------------------
% text info format:
% subjects {n}   	- number of scanned subjects each in their own subdirectory
% sdir {str}     	- the name of the subdirectory for each subject
% sdir {...}     	  - for multiple runs, each subject dir lists the run directories ( see sample below)
% base_directory {str}	- the full path of the main directory each subject directory resides in
% list {str}		- the file spec for reding image files eg: ws*.img
%
% sample:
%
%subjects 1
%runs 1
%sdir s01
%list ws*.img
%base_directory /home/data/example_data/Pilot/Pilot/Data
%
%subjects 2
%runs 2
%sdir c01 run1 run2
%sdir c02 run1 run2
%list sw*.nii
%base_directory /home/data/example_data/Pilot/Pilot/Data

global scan_information;

  % --------------------------------------------------------
  % --- is this the new style of scan listing ( listver:# )
  fid = fopen( filename, 'r' );
  x = fgets( fid );		  % x = listver:n
  fclose(fid);
  if ( size(x,2) > 7 )
    if strcmp(x(1:7),'listver')
      xx = regexp(x,':','split');
      ver = str2num(char(xx(2)));
      eval( [ 'parse_scan_listing_v' num2str(ver) '( filename );'] );
      return;
    end;
  end;


%  scan_info = scan_information;
  imageFiles=readFiles(filename);

  % --------------------------------------------------------
  % convert the character array into cells - each line of text is a new cell
  cellptr = cellstr(imageFiles);
  sz = size(cellptr);

  clear imageFiles;
  processed_subjects = 0;
  scan_information.SubjectID = {};

  for ii = 1:sz(1)

    % split the cell text on space character, t = variable name (tag)  v= value
    % --------------------------------------------------------
    [str value] = strtok( cellptr( ii ) );
    str = char( str );
    value = char( value );

    if strcmp( str, scan_information.tags.subjects ) 
      scan_information.NumSubjects = str2double( value ); 
    end;

    if strcmp( str, scan_information.tags.runs ) 
      scan_information.NumRuns = str2double( value ); 
    end;

    if strcmp( str, scan_information.tags.basedir ) 
      value=strtrim(value); 
      scan_information.BaseDir = value; 
    end;
    if strcmp( str, scan_information.tags.listspec ) 
      value=strtrim(value); 
      scan_information.ListSpec = value; 
    end;

    if strcmp( str, scan_information.tags.subjectdir) 

      processed_subjects = processed_subjects + 1;
      if scan_information.NumRuns > 1
        [sr srr] = strtok( value );
      else
        sr = value;
      end;

      scan_information.SubjectID(processed_subjects) = {strtrim(sr)};

      if scan_information.NumRuns > 1

        [sbjdir sbjrundir] = strtok( value );
        runs=regexp(strtrim(sbjrundir), ' ', 'split' );   
        [rx ry] = size(runs);
	for jj = 1:ry      
	  runs(jj) = {[char(sbjdir) '/' char(runs(jj))]};
	end;

      else
       runs = {strtrim(value)};
%        runs=strtrim(value);      
      end;

      scan_information.SubjDir = vertcat([scan_information.SubjDir; runs]); 
%      scan_information.SubjDir = strcat(scan_information.SubjDir, ' ', value); 
    end;

  end;
  clear ii;

  % take space delimited subdir string and make it a 1*n matrix
  % --------------------------------------------------------
%  scan_information.SubjDir = strtrim(scan_information.SubjDir);
%  scan_information.SubjDir = regexp(scan_information.SubjDir, ' ', 'split');


