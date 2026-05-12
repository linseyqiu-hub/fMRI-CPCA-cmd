function Create_File_List(subject_dir,filewildcard,output_dir,filename,isMulFreq)
% ---
% --- Create a text list of scan images to be used to create Z infortmation
% ---
% --- uses 3 levels of directories to determine scan grouping, particpant
% --- lists and session numbers.  Will also allow for multiple frequency
% --- range MEG/EEG beamformed images.
% ---
% --- input:
% ---     subject_dir: specify the folder that contains the fMRI scans,
% ---                  please see the manual the folder structure
%----     filewildcard: scan list wildcard specification, supports .img and
%---                    .nii format, for example 'fsn*.img'
%---      output_dir: output folder for the text file
%---      filename: specify the name of text file
%---      isMulFreq: 1 if multiple frequencies
%---
% --- output:
% ---   text file containing:
% ---     listver:              current text file creation version
% ---     Created:              date of creation
% ---     Version:              cpca version of creation
% ---     subjects:             total number of subject
% ---     runs:                 total number of runs
% ---     minRunCount:          minimum number of runs
% ---     groups:               number of participant groupings
% ---     multipleFrequency:    flag indicating multiple frequency ranged
% ---     frequencies:          number of frequency ranges  ( default 0 )
% ---     frlabels:             labels to use for each frequency
% ---     base_directory:       root directory containing scan data
% ---     format:               format string for determining path from root to scans
% ---     list:                 scan list wildcard specification
% ---     scandir:              text list of each subject included in study
% ---                           6 element pairs containing  id:value
% ---
% ---   scandir format:     scandir:{subject_dir} sdir:s01 id:s01 group:<na> frequency:<na> runs:<na>
% ---                    scandir:{subject_dir}   format string to determine path
% ---                    sdir:s01                subject directory name
% ---                    id:s01                  subject ID label
% ---                    group:<na>              Group id
% ---                    frequency:<na>          Frequeny directory
% ---                    runs:<na>               tilde delimited list of run directories
% ---

% --- Wayne Su April 30, 2024

% ----check inputs--------------------------
% set default values if missing
if nargin < 5  
    isMulFreq = 0; 
end
if nargin < 4  
    filename = 'files.txt'; 
end
if nargin < 3  
    output_dir = subject_dir; 
end

if not(isfolder(subject_dir))
    disp('Subject folder does not exist!');
    return;
end

if not(isfolder(output_dir))
    if not(mkdir(output_dir))
        disp('Cannot create output folder!');
        return;
    end
end

cd(subject_dir);
% clean up the folder
disp('clean up the folder, all processed data will be removed!')
if exist('ZInfo.mat', 'file') >0 
    delete ZInfo.mat
end
if exist('Gheader.mat', 'file') >0 
    delete Gheader.mat
end
if exist('G', 'dir') >0 
    [status, message, messageid] = rmdir('G', 's');
end
if exist('GZsegs', 'dir') >0 
    [status, message, messageid] = rmdir('GZsegs', 's');
end
if exist('Gsegs', 'dir') >0 
    [status, message, messageid] = rmdir('Gsegs', 's');
end
if exist('log', 'dir') >0 
    [status, message, messageid] = rmdir('log', 's');
end
if exist('Z', 'dir') >0 
    [status, message, messageid] = rmdir('Z', 's');
end
if exist('Residual_G', 'dir') >0 
    [status, message, messageid] = rmdir('Residual_G', 's');
end

if exist('mask_logs', 'dir') >0 
    [status, message, messageid] = rmdir('mask_logs', 's');
end
if exist('subject_masks', 'dir') >0 
    [status, message, messageid] = rmdir('subject_masks', 's');
end

% ----initialize data structure--------------------------

dataStruct.txt_base_directory = subject_dir;
dataStruct.txt_use_wildcard = filewildcard;
dataStruct.txt_text_file_location = output_dir;
dataStruct.txt_text_file_name = filename;
dataStruct.chk_isMulFreq.Value = isMulFreq; % multiple frequencies
dataStruct.chk_primary_groups.Value = 0;
dataStruct.chk_primary_ranges.Value = 0;
dataStruct.chk_primary_subjects.Value = 0;
dataStruct.chk_secondary_runs.Value = 0;
dataStruct.chk_secondary_ranges.Value = 0;
dataStruct.chk_secondary_subjects.Value = 0;
dataStruct.lst_Primary.String = '';
dataStruct.lst_Primary.Value = 0;
dataStruct.lst_Secondary.String = '';
dataStruct.lst_Secondary.Value = 0;
dataStruct.lst_Tertiary.String = '';
dataStruct.lst_Tertiary.Value = 0;
dataStruct.listver = 5;
dataStruct.REVISION_NUMBER =constant_define( 'REVISION_NUMBER' );

disp('checking subject folder...')
update_directory_lists();
verify_scans();
% file_specs = [{'.img'} {'.nii'}]; % only img and nii format supported

% subject_output_line = struct( 'id', '', 'string', [] );

subject_output = struct( 'fmt', '', 'ptypes', [], 'basedir', '', 'output', [], 'Runs', 0 );


% -----------------------------------
% --- determine Primary, Secondary and Tertiary components ---
% -----------------------------------
lists = [];

items.items = dataStruct.lst_Primary.String; % group info Contorls and Patients
lists = [lists; items];
x = size(items.items,1);

items.items = dataStruct.lst_Secondary.String; % subject info s01 and s03
lists = [lists; items];
x = [x size(items.items,1)];

items.items = dataStruct.lst_Tertiary.String; % runs runa and runb
lists = [lists; items];
x = [x size(items.items,1)];

numlists = sum(x > 0);

% groupList = '<na>';
% subjectList = '<na>';
rangeList = '<na>';
% rangeNames = '';
% runList = '<na>';
subject_output.baseDir = dataStruct.txt_base_directory; % output base

wildcard = dataStruct.txt_use_wildcard; % 'fsn*.img'
wildcard = regexp( wildcard, ' ', 'split' );
wildcard = char(wildcard(1));

wildcard = strrep( wildcard, '.hdr', '' ); % -- make sure user supplied a proper extension
% x = strfind( wildcard, '.nii' );
% y = strfind( wildcard, '.img' );
% if isempty( x ) & isempty( y )
%   x = get( dataStruct.chk_is_img, 'Value' );
%   if ( x )
%     fs_ext = '.img';
%   else
%     fs_ext = '.nii';
%   end
%
%   %wildcard = [wildcard fs_ext];
%
% end

% isMulFreq = dataStruct.chk_isMulFreq.Value; % multiple frequencies

A = dataStruct.chk_primary_subjects.Value;  % 0
A = [A; (( dataStruct.chk_primary_ranges.Value ) * 2)];  % 0
A = [A; (( dataStruct.chk_primary_groups.Value ) * 3 )]; % 1
P = A;

A = dataStruct.chk_secondary_subjects.Value;   % 1
A = [A; (( dataStruct.chk_secondary_ranges.Value ) * 2)]; % 0
A = [A; (( dataStruct.chk_secondary_runs.Value ) * 4)]; % 0
P = [P A];

A = [0; 0; (( dataStruct.chk_tertiary_runs.Value ) * 4)]; %0
P = [P A];

subject_output.ptypes = sum(P);

numGroups = 0;
numRanges = 0;
numRuns = 1;
minRuns = 9999;
numSubjects = 0;

% sdir:s01 id:s01
% sdir:s01 id:s01 run:run1~run2
% sdir:patients/s01 id:s01 group:patients run:run1~run2

% sdir:{group}/{id}/{range} id:s01 group:patients frequency:45Hz run:run1~run2
numiters = 0;
for flist = 1:numlists
    numiters = numiters + size( lists( flist ).items, 1 );
end


for flist = 1:numlists
    P = subject_output.ptypes( flist );

    switch(P)

        case 1	% --- subjects
            subjectList = lists( flist ).items;
            numSubjects = size(subjectList, 1);
            if length(subject_output.fmt) > 0
                subject_output.fmt = [subject_output.fmt filesep];
            end
            subject_output.fmt = [subject_output.fmt '{subject_dir}'];


        case 2	% --- meg ranges
            rangeList = '';
            numRanges =size(lists( flist ).items, 1 );
            for ii = 1:size(lists( flist ).items, 1 )
                if size(rangeList,2) > 0 
                    rangeList = [rangeList '~']; 
                end
                rangeList = [rangeList strtrim(char(lists( flist ).items(ii) ) ) ];
            end
            if length(subject_output.fmt) > 0
                subject_output.fmt = [subject_output.fmt filesep];
            end
            subject_output.fmt = [subject_output.fmt '{frequency_dir}'];

        case 3	% --- groups
            groupList = lists( flist ).items;
            numGroups = size(groupList, 1);
            if length(subject_output.fmt) > 0
                subject_output.fmt = [subject_output.fmt filesep];
            end
            subject_output.fmt = [subject_output.fmt '{group_dir}'];

        case 4	% --- runs
            runList = lists( flist ).items;
            numRuns = size(runList, 1);
            if length(subject_output.fmt) > 0
                subject_output.fmt = [subject_output.fmt filesep];
            end
            subject_output.fmt = [subject_output.fmt '{run_dir}'];

    end

end


fl = dataStruct.txt_text_file_location; % output base
fn = dataStruct.txt_text_file_name;  % files.txt
save_file = [fl filesep fn ];

n = [];
% sdirlist = [];

for PrimaryList = 1:size(lists( 1 ).items, 1)
    p = [subject_output.ptypes( 1 ) PrimaryList];
    if subject_output.ptypes( 1 ) ~= 4
        t1 = char(lists( 1 ).items(PrimaryList));
    else
        t1 = [];
    end

    if ~isempty(lists( 2 ).items)

        Subdirectories = directory_list( [ subject_output.baseDir filesep t1 ] );

        if subject_output.ptypes( 2 ) ~= 4
            for SecondaryList = 1:size(Subdirectories, 1)
                s = [subject_output.ptypes( 2 ) SecondaryList];

                t2 = char(Subdirectories(SecondaryList));

                if ~isempty(lists( 3 ).items)
                    if subject_output.ptypes( 3 ) ~= 4
                        for TertiaryList= 1:size(lists( 3 ).items, 1)
                            n = [p; s; subject_output.ptypes( 3 ) TertiaryList];
                            t = [{t1}; {t2}; {char(lists( 3 ).items(TertiaryList))}];

                            subject_output = parselist( n, t, subject_output );
                            numRuns = max( numRuns, subject_output.Runs);
                            minRuns = min( minRuns, subject_output.Runs);

                        end
                    else
                        n = [p; subject_output.ptypes( 2 ) SecondaryList];
                        t = [{t1}; {t2}];

                        subject_output = parselist( n, t, subject_output );
                        numRuns = max( numRuns, subject_output.Runs);
                        minRuns = min( minRuns, subject_output.Runs);
                    end

                else

                    n = [p; subject_output.ptypes( 2 ) SecondaryList];
                    t = [{t1}; {t2}];

                    subject_output = parselist( n, t, subject_output );
                    numRuns = max( numRuns, subject_output.Runs);
                    minRuns = min( minRuns, subject_output.Runs);
                end


            end

        else

            if ~isempty(lists( 3 ).items)
                for TertiaryList= 1:size(lists( 3 ).items, 1)
                    n = [p; subject_output.ptypes( 3 ) TertiaryList];
                    t = [{t1}; {char(lists( 3 ).items(TertiaryList))}];

                    subject_output = parselist( n, t, subject_output );
                    numRuns = max( numRuns, subject_output.Runs);
                    minRuns = min( minRuns, subject_output.Runs);
                end

            else
                n = p;
                t = {t1};

                subject_output = parselist( n, t, subject_output );
                numRuns = max( numRuns, subject_output.Runs);
                minRuns = min( minRuns, subject_output.Runs);
            end

        end

    else
        n = p;
        t = {t1};

        subject_output = parselist( n, t, subject_output );
        numRuns = max( numRuns, subject_output.Runs);
        minRuns = min( minRuns, subject_output.Runs);

    end


end



if numGroups > 0 	% --- adjust the subject count
    numSubjects = size(subject_output.output, 1 );
end

X = [ 'Number of groups: ', num2str(numGroups) ];
disp(X)
X = [ 'Number of subjects: ', num2str(numSubjects) ];
disp(X)
X = [ 'Number of runs: ', num2str(numRuns) ];
disp(X)
X = [ 'Min number of runs: ', num2str(minRuns) ];
disp(X)

if dataStruct.chk_isMulFreq.Value
    X = [ 'Number of frequencies: ', num2str(numRanges) ];
    disp(X)
    X = [ 'Frequency labels: ', rangeList ];
    disp(X)
end

disp('creating file list ...')
if ~isempty(save_file)
    fid = fopen ( char(save_file), 'w' );

    fprintf( fid, 'listver:%d\n', dataStruct.listver );  % listver=5
    fprintf( fid, 'Created: %s\n', char(datetime) );

    str = dataStruct.REVISION_NUMBER;  %REVISION_NUMBER='1.2.2(19)-dev'
    %    str = strrep( str, ' ', '_' );
    fprintf( fid, 'Version: cpca_%s\n', str );
   
    fprintf( fid, 'subjects:%d\n', numSubjects );
    fprintf( fid, 'runs:%d\n', numRuns );
    fprintf( fid, 'minRunCount:%d\n', minRuns );
    %    fprintf( fid, 'maxRunCount:%d\n', maxRuns );
    fprintf( fid, 'groups:%d\n', numGroups );
    fprintf( fid, 'multipleFrequency:%d\n', dataStruct.chk_isMulFreq.Value );
    fprintf( fid, 'frequencies:%d\n', numRanges );
    fprintf( fid, 'frlabels:%s\n', rangeList );
    str = strrep(  subject_output.baseDir, ' ', '%20' );
    fprintf( fid, 'base_directory:%s\n', str );
    fprintf( fid, 'format:%s\n', subject_output.fmt );
    fprintf( fid, 'list:%s\n', wildcard );

    for ii = 1:size(subject_output.output,1) 

        if size(subject_output.output(ii).string,1) > 1
            for jj = 1:size(subject_output.output(ii).string,1)
                fprintf( fid, '%s\n', char(subject_output.output(ii).string(jj)) );
            end
        else
            fprintf( fid, '%s\n', char(subject_output.output(ii).string) );
        end
    end


    fclose( fid );
end

% eval( ['edit ''' strtrim(char(save_file)) '''' ] );
disp('Done!')

    function update_directory_lists( )


        % state = [{'off'} {'on'}];

        dirname = dataStruct.txt_base_directory;
        lst = [];

        if ( ~ isempty( dirname ) )

            [lst, numdirs] = directory_list( dirname );
            dataStruct.lst_Primary.String = lst;
            dataStruct.lst_Primary.Value = 1;
            % set( dataStruct.lst_Primary, 'Enable', state{ (size(lst,1) > 0) + 1} );

            has_images = update_image_wildcards( dirname );
            % if ( has_images )
            %     set( dataStruct.lst_Primary, 'FontWeight', 'bold' );
            % else
            %     set( dataStruct.lst_Primary, 'FontWeight', 'normal' );
            % end


            set_subdirlist( dataStruct.lst_Secondary, dataStruct.lst_Primary );
            if ~isempty( lst )
                set_subdirlist( dataStruct.lst_Tertiary, dataStruct.lst_Secondary, [ char(lst(1)) filesep] );
            end

            set_check_flags();

        end

    end


    function set_subdirlist( set_list, from_list, innerpad )


        if ( nargin < 3 ) 
            innerpad = ''; 
        end

        dirname = char(dataStruct.txt_base_directory);
        subdir = '';

        contents = from_list.String;
        if ( size(contents,1) > 0 )
            subdir = char(contents{from_list.Value});
        end

        lst = [];
        lstname = '';

        if ( length( subdir) > 0 )
            [lst, numdirs] = directory_list( [dirname filesep innerpad subdir] );
        end

        if ~isempty(set_list)
            if ( nargin < 3 )
                dataStruct.lst_Secondary.String = lst ;
                dataStruct.lst_Secondary.Value = 1;
            else
                dataStruct.lst_Tertiary.String = lst ;
                dataStruct.lst_Tertiary.Value = 1;
            end
            % set( set_list, 'Enable', state{ (size(lst,1) > 0) + 1} );
        end

        if ( size( lst, 1) > 0 )
            dspec = [ dirname filesep innerpad subdir filesep char(lst(1)) ];
        else
            dspec = [ dirname filesep innerpad subdir ];
        end

        [nii, img] = image_file_count( dspec );
        x = nii + img;

        if ( x > 0 )
            % if ~isempty(set_list) set( set_list, 'FontWeight', 'bold' );  end;
            wc = image_wildcards( dspec  );

            lst2 = [];
            if size( wc, 1 ) > 0
                for iii = 1:size(wc, 1 )
                    filespec = [ dspec filesep char(wc(iii))];
                    D = dir(filespec);
                    str = [ char(wc(iii)) ' (' num2str(size(D,1)) ')'] ;
                    lst2 = [lst2; {str} ];
                end
            end

            dataStruct.lst_sample_wildcards.String = lst2;
            dataStruct.lst_sample_wildcards.Value = 1;

        else
            % if ~isempty(set_list)  set( set_list, 'FontWeight', 'normal' );  end
            if ( size( lst, 1) > 0 )
                dataStruct.lst_sample_wildcards.String = '';
                dataStruct.lst_sample_wildcards.Value = 1;
            end
        end

    end



    function has_images = update_image_wildcards( dirname )

        dirsep = char(filesep );
        dirname = strrep( dirname, '\\', '\' );

        [nii, img] = image_file_count( dirname );
        has_images = nii + img;

        is_nii = nii > 0 & img == 0;
        is_img = img > 0 & nii == 0;

        if ( is_nii | is_img)
            dataStruct.chk_is_nii.Value = is_nii;
            dataStruct.chk_is_img.Value = is_img;
        end

        if ( has_images )
            wc = image_wildcards( dirname );

            lst = [];
            if size( wc, 1 ) > 0
                for iii = 1:size(wc, 1 )
                    filespec = [dirname dirsep char(wc(iii))];
                    D = dir(filespec);
                    str = [ char(wc(iii)) ' (' num2str(size(D,1)) ')'] ;
                    lst = [lst; {str} ];
                end
            end

            dataStruct.lst_sample_wildcards.String = lst;
            dataStruct.lst_sample_wildcards.Value = 1;
        end

    end

    function set_check_flags( )

        contents = dataStruct.lst_Primary.String;
        x = size(contents,1);

        contents = dataStruct.lst_Secondary.String;
        x = [x size(contents,1)];

        contents = dataStruct.lst_Tertiary.String;
        x = [x size(contents,1)];

        y = sum(x > 0);

        meg = dataStruct.chk_isMulFreq.Value;
        

        switch ( y )

            case 1				% y == 1  ==> primary is subjects

                dataStruct.chk_primary_subjects.Value = 1;
                dataStruct.chk_primary_groups.Value = 0;
                dataStruct.chk_secondary_subjects.Value = 0;
                dataStruct.chk_secondary_runs.Value = 0;
                dataStruct.chk_tertiary_runs.Value = 0;


            case 2				% y == 2  ==> primary may be subjects or groups or ranges  secondary may be subjects or ranges runs

                dataStruct.chk_primary_subjects.Value = x(1)>x(2);
                dataStruct.chk_primary_groups.Value = x(1)<=x(2);
                dataStruct.chk_secondary_subjects.Value = x(1)<=x(2);
                dataStruct.chk_secondary_runs.Value = x(1)>x(2);
                dataStruct.chk_tertiary_runs.Value = 0;

            case 3				% y == 3  ==> primary is groups or ranges  secondary is subjects or ranges  tertiary is runs

                dataStruct.chk_primary_subjects.Value = 0;
                dataStruct.chk_primary_groups.Value = ~meg;
                dataStruct.chk_secondary_ranges.Value = meg;
                dataStruct.chk_secondary_subjects.Value = ~meg;
                dataStruct.chk_secondary_runs.Value = 0;
                dataStruct.chk_tertiary_runs.Value = 1;

        end


    end

    function verify_scans()

        wc = strtrim(char(dataStruct.txt_use_wildcard));

        bd = strtrim(char(dataStruct.txt_base_directory));

        c = dataStruct.lst_Primary.String;  % group list    
        if ~isempty(c)
            bd = [bd filesep strtrim(char( c(dataStruct.lst_Primary.Value ) ) ) ];
        end

        c = dataStruct.lst_Secondary.String; % subject list
        if ~isempty(c)
            bd = [bd filesep strtrim(char( c(dataStruct.lst_Secondary.Value ) ) ) ];
        end

        c = dataStruct.lst_Tertiary.String;  % runs list
        if ~isempty(c)
            bd = [bd filesep strtrim( char( c(dataStruct.lst_Tertiary.Value ) ) ) ];
        end

        txt = ['Directory: ' bd ];
        disp(txt);

        bd = [bd filesep wc];

        if ispc() bd = strrep( bd, '\\', '\' );  end

        D = dir( bd );

        txt = ['File Specification: ' wc ];
        disp(txt);

        str = sprintf( 'matching files of first scan - %d', size(D, 1) );
        disp(str);
        disp('--------------------------------------------------------------');

        if size(D,1) > 0
            for iii = 1:size(D,1)

                potential_err = '*';
                x = char(regexp( D(iii).name, '\d{3,6}', 'match' ));
                if size(x,2) > 0
                    numinstr = strfind( x(size(x,1),:), num2str(iii) );
                    if ~isempty( numinstr )
                        potential_err = ' ';
                    end
                end

                str = sprintf( '[%4d] %c %s', iii, potential_err, char(D(iii).name) );
                disp(str);
            end
        end

    end

end

function subject_output = parselist( n, t, subject_output )

if nargin < 4  item3 = ''; end
if nargin < 3  item2 = ''; end

sbj = '<na>';
rng = '<na>';
grp = '<na>';
rns = '<na>';

sdirstr = ['scandir:' subject_output.fmt ' sdir:{subject} id:{subject} group:{group} frequency:{frequency} runs:{runs}'];

for ii = 1:size(n,1)

    switch n(ii,1)   % --- each entry list
        case 1
            sbj = char( strtrim(t(ii)) );
        case 2
            rng = char( strtrim(t(ii)) );
        case 3
            grp = char( strtrim(t(ii)) );

    end % --- end switch

end

%  sdirstr = strrep( sdirstr, '{subject_dir}', sbj );
sdirstr = strrep( sdirstr, '{subject}', sbj );

sdirstr = strrep( sdirstr, '{frequency_dir}', rng );
sdirstr = strrep( sdirstr, '{frequency}', rng );

sdirstr = strrep( sdirstr, '{group_dir}', grp );
sdirstr = strrep( sdirstr, '{group}', grp );

x = find(subject_output.ptypes==4);
runList = '<na>';
if ~isempty(x)
    runList = [];
    runPath = '';

    for ii = 1:(x-1)
        if length(runPath) > 0  
            runPath = [runPath filesep]; 
        end
        runPath = [runPath strtrim( char(t(ii)) )];
    end

    TertiaryList = directory_list( [ subject_output.baseDir filesep runPath ] );
    subject_output.Runs = size(TertiaryList, 1 );
    for ii = 1:size(TertiaryList, 1 )
        if length(runList) > 0  
            runList = [runList '~']; 
        end
        runList = [runList strtrim(char( TertiaryList(ii) ) )];
    end

end

sdirstr = strrep( sdirstr, '{runs}', runList );
sdirstr = strrep( sdirstr, '  ', ' ' );

idx = 0;
for ii = 1:size(subject_output.output, 1 )
    if strcmp( subject_output.output(ii).id, sbj );   idx = ii; break; end
end

if ~idx
    if isempty( subject_output.output )
        subject_output.output = struct( 'id', sbj, 'string', {sdirstr} );
    else
        subject_output.output = [subject_output.output; struct( 'id', sbj, 'string', {sdirstr} )];
    end
else
    subject_output.output(idx).string = [subject_output.output(idx).string; {sdirstr}];
end
end

