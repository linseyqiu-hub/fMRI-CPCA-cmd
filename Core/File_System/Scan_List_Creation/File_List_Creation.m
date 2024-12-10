function varargout = File_List_Creation(varargin)
% --- 
% --- Create a text list of scan images to be used to create Z infortmation
% ---
% --- uses 3 levels of directories to determine scan grouping, particpant
% --- lists and session numbers.  Will also allow for multiple frequency
% --- range MEG/EEG beamformed images.
% ---
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

% Edit the above text to modify the response to help File_List_Creation

% Last Modified by GUIDE v2.5 24-May-2016 14:32:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @File_List_Creation_OpeningFcn, ...
                   'gui_OutputFcn',  @File_List_Creation_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before File_List_Creation is made visible.
function File_List_Creation_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to File_List_Creation (see VARARGIN)

  % --- master version setting
  handles.listver = 5;

  thisDir = pwd;
  set( handles.txt_text_file_location, 'String', thisDir );

%  set( handles.btn_verify_wildcard, 'Visible', 'off' );

% Choose default command line output for File_List_Creation
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes File_List_Creation wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = File_List_Creation_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = '';
delete(handles.figure1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
%delete(hObject);
  varargout{1} = '';
  uiresume(handles.figure1);


% --- Executes on button press in btn_select_base_directory.
function btn_select_base_directory_Callback(hObject, eventdata, handles)
% hObject    handle to btn_select_base_directory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  thisdir = get( handles.txt_base_directory, 'String' );
  dirname = uigetdir(thisdir, 'Select the root directory of your subject scan data');

  if ~isequal( dirname, 0)
    set( handles.txt_base_directory, 'String', dirname );

    set(handles.chk_primary_groups,'Value', 0);
    set(handles.chk_primary_ranges,'Value', 0);
    set(handles.chk_primary_subjects,'Value', 0);

    set(handles.chk_secondary_runs,'Value', 0);
    set(handles.chk_secondary_ranges,'Value', 0);
    set(handles.chk_secondary_subjects,'Value', 0);

    update_directory_lists(handles);

    content =  get(handles.lst_sample_wildcards,'String');
    if ~isempty( content )
      this_wc = content{ 1};
      this_wc = regexp( this_wc, ' ', 'split' );
      set( handles.txt_use_wildcard, 'String', char(this_wc(1)) );
    else
      set( handles.txt_use_wildcard, 'String', [] );
    end;

  end;



% ----------------------------------------------------
% double click on a list item in the primary list will
% make that directory the selected base directory and update the lists
% ----------------------------------------------------
function lst_Primary_Callback(hObject, eventdata, handles)
% hObject    handle to lst_Primary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scan_information 

  % If double click
  if strcmp(get(handles.figure1,'SelectionType'),'open')

%    if ( ispc() )  return;  end;   % pc craps out on filesystem - just reselect
    
    thisdir = get( handles.txt_base_directory, 'String' );
    contents = get(handles.lst_Primary,'String');
    thisdir = [thisdir filesep char(contents( get(handles.lst_Primary, 'Value' ) ) ) ];

    set( handles.txt_base_directory, 'String', thisdir );
    update_directory_lists(handles);

    content =  get(handles.lst_sample_wildcards,'String');
    this_wc = content{ 1};
    this_wc = regexp( this_wc, ' ', 'split' );
    set( handles.txt_use_wildcard, 'String', char(this_wc(1)) );

  else

    dirname = get( handles.txt_base_directory, 'String' );

    subdir = '';
    contents = get(handles.lst_Primary,'String');
    if ( size(contents,1) > 0 )
      subdir = strtrim(char(contents{get(handles.lst_Primary,'Value')}));
      dirname = [dirname filesep subdir];
    end; 

    set_subdirlist( handles, handles.lst_Secondary, handles.lst_Primary );

    contents = get(handles.lst_Secondary,'String');
    if ( size(contents,1) > 0 )
      subdir2 = strtrim(char(contents{get(handles.lst_Secondary,'Value')}));
      dirname = [dirname filesep subdir2];
    end; 
    
    if ( length( subdir ) > 0 )
      set_subdirlist( handles, handles.lst_Tertiary, handles.lst_Secondary, [ subdir filesep] );
    end;

    contents = get(handles.lst_Tertiary,'String');
    if ( size(contents,1) > 0 )
      subdir = strtrim(char(contents{get(handles.lst_Tertiary,'Value')}));
      dirname = [dirname filesep subdir];
    end; 

    update_image_wildcards( handles, dirname );  
    
  end;
  


% ----------------------------------------------------
% pressing 'delete' on a list item in the primary list will
% remove that directory from the list (reset by select base dir button)
% mac notes: delete press identified as 'backspace', fn-del as delete
% ----------------------------------------------------
function lst_Primary_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to lst_Primary (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

  deleteItem = strcmp( eventdata.Key, 'delete' );
  if ~deleteItem & ismac()
    deleteItem = strcmp( eventdata.Key, 'backspace' );
  end;

  if deleteItem 
    deleteCurrentItemFromList( hObject );
  end;


% ----------------------------------------------------
% pressing 'delete' on a list item in the secondary list will
% remove that directory from the list (reset by select base dir button)
% ----------------------------------------------------
function lst_Secondary_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to lst_Secondary (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

% --- secondary and tertiary reset when prior list selection made 
% --- cannot remove a subdir unless entire tree contained at this point
% --- ignore secondary deletions for now
return

  deleteItem = strcmp( eventdata.Key, 'delete' );
  if ~deleteItem & ismac()
    deleteItem = strcmp( eventdata.Key, 'backspace' );
  end;

  if deleteItem 
    deleteCurrentItemFromList( hObject );
  end;



% ----------------------------------------------------
% pressing 'delete' on a list item in the tertiary list will
% remove that directory from the list (reset by select base dir button)
% ----------------------------------------------------
% --- Executes on key press with focus on lst_Tertiary and none of its controls.
function lst_Tertiary_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to lst_Tertiary (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

% --- secondary and tertiary reste when prior list selection made 
% --- cannot remove a subdir unless entiore tree contained at this point
% --- ignore secondary deletions for now
return

  deleteItem = strcmp( eventdata.Key, 'delete' );
  if ~deleteItem & ismac()
    deleteItem = strcmp( eventdata.Key, 'backspace' );
  end;

  if deleteItem 
    deleteCurrentItemFromList( hObject );
  end;




% --- Executes during object creation, after setting all properties.
function lst_Primary_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_Primary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in lst_Secondary.
function lst_Secondary_Callback(hObject, eventdata, handles)
% hObject    handle to lst_Secondary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scan_information 

  dirname = get( handles.txt_base_directory, 'String' );

  subdir = '';
  contents = get(handles.lst_Primary,'String');
  if ( size(contents,1) > 0 )
    subdir = strtrim(char(contents{get(handles.lst_Primary,'Value')}));
    dirname = [dirname filesep subdir];
  end; 

  set_subdirlist( handles, handles.lst_Tertiary, handles.lst_Secondary, [ subdir filesep] );

  contents = get(handles.lst_Secondary,'String');
  if ( size(contents,1) > 0 )
    subdir = strtrim(char(contents{get(handles.lst_Secondary,'Value')}));
    dirname = [dirname filesep subdir];
  end; 

  update_image_wildcards( handles, dirname );  
  
  

% --- Executes during object creation, after setting all properties.
function lst_Secondary_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_Secondary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in lst_Tertiary.
function lst_Tertiary_Callback(hObject, eventdata, handles)
% hObject    handle to lst_Tertiary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scan_information 

  dirname = get( handles.txt_base_directory, 'String' );

  subdir = '';
  contents = get(handles.lst_Primary,'String');
  if ( size(contents,1) > 0 )
    subdir = strtrim(char(contents{get(handles.lst_Primary,'Value')}));
    dirname = [dirname filesep subdir];
  end; 

  contents = get(handles.lst_Secondary,'String');
  if ( size(contents,1) > 0 )
    subdir = strtrim(char(contents{get(handles.lst_Secondary,'Value')}));
    dirname = [dirname filesep subdir];
  end; 
  
  contents = get(handles.lst_Tertiary,'String');
  if ( size(contents,1) > 0 )
    subdir = strtrim(char(contents{get(handles.lst_Tertiary,'Value')}));
    dirname = [dirname filesep subdir];
  end; 

  update_image_wildcards( handles, dirname );  
  


% --- Executes during object creation, after setting all properties.
function lst_Tertiary_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_Tertiary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on button press in chk_primary_subjects.
function chk_primary_subjects_Callback(hObject, eventdata, handles)
% hObject    handle to chk_primary_subjects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  x = get(hObject,'Value');
  st = get( handles.chk_primary_groups, 'Visible' );

  y = get(handles.chk_isMulFreq,'Value');

  if ( strcmp( st, 'on' ) )

    if ( x )
      set(handles.chk_primary_groups,'Value', 0);
      set(handles.chk_primary_ranges,'Value', 0);
      if ~y set(handles.chk_secondary_runs,'Value', 1); end;
      set(handles.chk_secondary_subjects,'Value', 0);
    else
%      set(handles.chk_primary_groups,'Value', 1);
      if ~y set(handles.chk_secondary_runs,'Value', 0); 
         set(handles.chk_secondary_subjects,'Value', 1);
      end;
    end;


  else
    set(hObject,'Value', 1);
  end;

  drawnow();

  

% --- Executes on button press in chk_primary_groups.
function chk_primary_groups_Callback(hObject, eventdata, handles)
% hObject    handle to chk_primary_groups (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  x = get(hObject,'Value');
  st = get( handles.chk_primary_subjects, 'Visible' );
  y = get(handles.chk_isMulFreq,'Value');

  if ( strcmp( st, 'on' ) )

    if ( x )
      set(handles.chk_primary_subjects,'Value', 0);
      set(handles.chk_primary_ranges,'Value', 0);
      if ~y set(handles.chk_secondary_runs,'Value', 1); end;
%      set(handles.chk_secondary_subjects,'Value', 1);
    else
      if ~y set(handles.chk_primary_subjects,'Value', 1);
         set(handles.chk_secondary_runs,'Value', 1);
      end;
%      set(handles.chk_secondary_subjects,'Value', 0);
    end;

  else
    set(hObject,'Value', 1);
  end;

  drawnow();


% --- Executes on button press in chk_secondary_runs.
function chk_secondary_runs_Callback(hObject, eventdata, handles)
% hObject    handle to chk_secondary_runs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  set(handles.chk_secondary_subjects,'Value', 0);
  set(handles.chk_secondary_ranges,'Value', 0);


% --- Executes on button press in chk_secondary_subjects.
function chk_secondary_subjects_Callback(hObject, eventdata, handles)
% hObject    handle to chk_secondary_subjects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  x = get(hObject,'Value');
  st = get( handles.chk_primary_groups, 'Visible' );
  y = get(handles.chk_isMulFreq,'Value');

  if ( strcmp( st, 'on' ) )

    if ( x )
      set(handles.chk_primary_subjects,'Value', 0);
      if ~y set(handles.chk_primary_groups,'Value', 1); end;
      set(handles.chk_secondary_runs,'Value', 0);
      set(handles.chk_secondary_ranges,'Value', 0);
    end;


  else
    set(hObject,'Value', 1);
  end;

  drawnow();


% --- Executes on button press in chk_tertiary_runs.
function chk_tertiary_runs_Callback(hObject, eventdata, handles)
% hObject    handle to chk_tertiary_runs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_tertiary_runs



function update_directory_lists( handles )
global scan_information 

  state = [{'off'} {'on'}];

  dirname = get( handles.txt_base_directory, 'String' );
  lst = [];

  if ( ~ isempty( dirname ) )

    [lst numdirs] = directory_list( dirname );
    set( handles.lst_Primary, 'String', lst, 'Value', 1 );
    set( handles.lst_Primary, 'Enable', state{ (size(lst,1) > 0) + 1} );

    has_images = update_image_wildcards( handles, dirname );  
    if ( has_images )
      set( handles.lst_Primary, 'FontWeight', 'bold' );
    else
      set( handles.lst_Primary, 'FontWeight', 'normal' );
    end;


    set_subdirlist( handles, handles.lst_Secondary, handles.lst_Primary );
    if ~isempty( lst )
      set_subdirlist( handles, handles.lst_Tertiary, handles.lst_Secondary, [ char(lst(1)) filesep] );
    end;

    set_check_flags( handles );

  end;

  
   

function set_subdirlist( handles, set_list, from_list, innerpad )
global scan_information 

  state = [{'off'} {'on'}];

  if ( nargin < 4 ) innerpad = ''; end;

  dirname = char(get( handles.txt_base_directory, 'String' ));
  subdir = '';

  contents = get(from_list,'String');
  if ( size(contents,1) > 0 )
    subdir = char(contents{get(from_list,'Value')});
  end; 
    
  lst = [];
  lstname = '';

  if ( length( subdir) > 0 )
    [lst numdirs] = directory_list( [dirname filesep innerpad subdir] );
  end;

  if ~isempty(set_list) 
    set( set_list, 'String', lst, 'Value', 1 );
    set( set_list, 'Enable', state{ (size(lst,1) > 0) + 1} );
  end;
  
  if ( size( lst, 1) > 0 )
    dspec = [ dirname filesep innerpad subdir filesep char(lst(1)) ];
  else
    dspec = [ dirname filesep innerpad subdir ];
  end;

  [nii img] = image_file_count( dspec );
  x = nii + img;
  
  if ( x > 0 )
    if ~isempty(set_list) set( set_list, 'FontWeight', 'bold' );  end;
    wc = image_wildcards( dspec  );

    lst2 = [];
    if size( wc, 1 ) > 0 
      for ii = 1:size(wc, 1 )
        filespec = [ dspec filesep char(wc(ii))];
        D = dir(filespec);
        str = [ char(wc(ii)) ' (' num2str(size(D,1)) ')'] ;
        lst2 = [lst2; {str} ];
      end
    end

    set( handles.lst_sample_wildcards, 'String', lst2, 'Value', 1);

  else
    if ~isempty(set_list)  set( set_list, 'FontWeight', 'normal' );  end;
    if ( size( lst, 1) > 0 )
      set( handles.lst_sample_wildcards, 'String', '', 'Value', 1 );
    end;
  end;

  
  

  
function has_images = update_image_wildcards( handles, dirname )
global scan_information 

  dirsep = char(filesep );
  dirname = strrep( dirname, '\\', '\' );
  
  [nii img] = image_file_count( dirname );
  has_images = nii + img;

  is_nii = nii > 0 & img == 0;
  is_img = img > 0 & nii == 0;

  if ( is_nii | is_img)
    set ( handles.chk_is_nii, 'Value', is_nii );
    set ( handles.chk_is_img, 'Value', is_img );
  end;

  if ( has_images )
    wc = image_wildcards( dirname );

    lst = [];
    if size( wc, 1 ) > 0 
      for ii = 1:size(wc, 1 )
        filespec = [dirname dirsep char(wc(ii))];
        D = dir(filespec);
        str = [ char(wc(ii)) ' (' num2str(size(D,1)) ')'] ;
        lst = [lst; {str} ];
      end
    end

    set( handles.lst_sample_wildcards, 'String', lst, 'Value', 1 );
  end;
  
  
function set_check_flags( handles )

  contents = get(handles.lst_Primary,'String');
  x = size(contents,1);

  contents = get(handles.lst_Secondary,'String');
  x = [x size(contents,1)];

  contents = get(handles.lst_Tertiary,'String');
  x = [x size(contents,1)];

  y = sum(x > 0);  	
  state = 'on';

  meg = get(handles.chk_isMulFreq,'Value');
  if meg  meg_state = 'on'; else meg_state = 'off'; end;

  switch ( y )	

    case 1				% y == 1  ==> primary is subjects

      set( handles.chk_primary_subjects, 'Visible', 'on' );
      set( handles.chk_primary_groups, 'Visible', 'off' );
      set( handles.chk_primary_ranges, 'Visible', meg_state );
      set( handles.chk_secondary_subjects, 'Visible', 'off' );
      set( handles.chk_secondary_runs, 'Visible', 'off' );
      set( handles.chk_secondary_ranges, 'Visible', meg_state );
      set( handles.chk_tertiary_runs, 'Visible', 'off' );

      set( handles.chk_primary_subjects, 'Value', 1 );
      set( handles.chk_primary_groups, 'Value', 0 );
      set( handles.chk_secondary_subjects, 'Value', 0 );
      set( handles.chk_secondary_runs, 'Value', 0 );
      set( handles.chk_tertiary_runs, 'Value', 0 );
      state = 'off';

    case 2				% y == 2  ==> primary may be subjects or groups or ranges  secondary may be subjects or ranges runs

      set( handles.chk_primary_subjects, 'Visible', 'on' );
      set( handles.chk_primary_groups, 'Visible', 'on' );      set( handles.chk_secondary_subjects, 'Value', 1 );
      set( handles.chk_primary_ranges, 'Visible', meg_state );

      set( handles.chk_secondary_subjects, 'Visible', 'on' );
      set( handles.chk_secondary_runs, 'Visible', 'on' );
      set( handles.chk_secondary_ranges, 'Visible', meg_state );
      set( handles.chk_tertiary_runs, 'Visible', 'off' );

      set( handles.chk_primary_subjects, 'Value', x(1)>x(2) );
      set( handles.chk_primary_groups, 'Value', x(1)<=x(2) );
      set( handles.chk_secondary_subjects, 'Value', x(1)<=x(2) );
      set( handles.chk_secondary_runs, 'Value', x(1)>x(2) );
      set( handles.chk_tertiary_runs, 'Value', 0 );

    case 3				% y == 3  ==> primary is groups or ranges  secondary is subjects or ranges  tertiary is runs

      set( handles.chk_primary_subjects, 'Visible', 'on' );
      set( handles.chk_primary_groups, 'Visible', 'on' );
      set( handles.chk_primary_ranges, 'Visible', meg_state );
      set( handles.chk_secondary_subjects, 'Visible', 'on' );
      set( handles.chk_secondary_runs, 'Visible', 'off' );
      set( handles.chk_secondary_ranges, 'Visible', meg_state );
      set( handles.chk_tertiary_runs, 'Visible', 'on' );

      set( handles.chk_primary_subjects, 'Value', 0 );
      set( handles.chk_primary_groups, 'Value', ~meg );
      set( handles.chk_secondary_ranges, 'Value', meg );
      set( handles.chk_secondary_subjects, 'Value', ~meg );
      set( handles.chk_secondary_runs, 'Value', 0 );
      set( handles.chk_tertiary_runs, 'Value', 1 );

      state = 'off';

  end;

  if meg
    set( handles.chk_primary_groups, 'Enable', meg_state  );
    set( handles.chk_secondary_subjects, 'Enable', meg_state );
    set( handles.chk_tertiary_runs, 'Enable', meg_state );

    set( handles.chk_primary_subjects, 'Enable', meg_state );
  else
    set( handles.chk_primary_groups, 'Enable', state  );
    set( handles.chk_secondary_subjects, 'Enable', state );
    set( handles.chk_tertiary_runs, 'Enable', state );

    set( handles.chk_primary_subjects, 'Enable', state );
  end;


function deleteCurrentItemFromList( lstHandle )

    % get the  list
    aa = get( lstHandle, 'String') ;
    [x y] = size( aa );
    if ( x == 0 )  % empty list
      return
    end;

    selected_index = get( lstHandle, 'Value') ;

    % remove this folder from list
    if ( selected_index > 1 )

      if ( selected_index < x )
        bb = [ aa(1:selected_index-1); aa(selected_index+1:x) ];
      else
        bb = aa(1:selected_index-1);
      end;

    else
      bb = aa(2:x);
    end;

    set( lstHandle, 'String', bb, 'Value', 1) ;



function lst_sample_wildcards_Callback(hObject, eventdata, handles)
% hObject    handle to lst_sample_wildcards (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lst_sample_wildcards as text
%        str2double(get(hObject,'String')) returns contents of lst_sample_wildcards as a double

  % If double click
  if strcmp(get(handles.figure1,'SelectionType'),'open')

    content =  get(hObject,'String');
    this_wc = content{ get(hObject,'Value') };
    this_wc = regexp( this_wc, ' ', 'split' );
    set( handles.txt_use_wildcard, 'String', char(this_wc(1)) );

  end;

% --- Executes during object creation, after setting all properties.
function lst_sample_wildcards_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_sample_wildcards (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on lst_sample_wildcards and none of its controls.
function lst_sample_wildcards_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to lst_sample_wildcards (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

%  set( handles.btn_verify_wildcard, 'Visible', 'on' );


% --- Executes on button press in btn_verify_wildcard.
function btn_verify_wildcard_Callback(hObject, eventdata, handles)
% hObject    handle to btn_verify_wildcard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scan_information 

  wc = strtrim(char(get(handles.txt_use_wildcard, 'String' )));

  bd = strtrim(char(get(handles.txt_base_directory, 'String' )));

  c = get(handles.lst_Primary, 'String' );
  if ~isempty(c)
    bd = [bd filesep strtrim(char( c(get(handles.lst_Primary, 'Value' ) ) ) ) ];
  end;

  c = get(handles.lst_Secondary, 'String' );
  if ~isempty(c)
    bd = [bd filesep strtrim(char( c(get(handles.lst_Secondary, 'Value' ) ) ) ) ];
  end;

  c = get(handles.lst_Tertiary, 'String' );
  if ~isempty(c)
    bd = [bd filesep strtrim( char( c(get(handles.lst_Tertiary, 'Value' ) ) ) ) ];
  end;

  txt = {['Directory: ' bd ]};

  bd = [bd filesep wc];

  if ispc() bd = strrep( bd, '\\', '\' );  end;
  
  D = dir( bd );

  txt = [txt; {['File Specification: ' wc ]} ];
  str = sprintf( 'matching files - %d', size(D, 1) );
  txt = [txt; {str}];
  txt = [txt; {'--------------------------------------------------------------'}];

  if size(D,1) > 0 
    for ii = 1:size(D,1)

      potential_err = '*';
      x = char(regexp( D(ii).name, '\d{3,6}', 'match' ));
      if size(x,2) > 0 
        numinstr = strfind( x(size(x,1),:), num2str(ii) );
        if ~isempty( numinstr )
          potential_err = ' ';
        end;
      end;

      str = sprintf( '[%4d] %c %s', ii, potential_err, char(D(ii).name) );
      txt = [txt; {str}];
    end;
  end;

  fsp_results( 'String', txt );


%  set( handles.txt_use_wildcard, 'String', wc );
%  set( hObject, 'Visible', 'off' );


function txt_use_wildcard_Callback(hObject, eventdata, handles)
% hObject    handle to txt_use_wildcard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_use_wildcard as text
%        str2double(get(hObject,'String')) returns contents of txt_use_wildcard as a double


% --- Executes during object creation, after setting all properties.
function txt_use_wildcard_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_use_wildcard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_Okay.
function btn_Okay_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Okay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scan_information 

  file_specs = [{'.img'} {'.nii'}];

  subject_output_line = struct( 'id', '', 'string', [] );
  subject_output = struct( 'fmt', '', 'ptypes', [], 'basedir', '', 'output', [], 'Runs', 0 );

  pop = cpca_progress();
  pop.setMessages( 'File List Creation', 'determining extents. . .', '');
  pop.clearParticipant();
  pop.clearRun();
  pop.show();
  pop.setPong(1);
  
  % -----------------------------------
  % --- determine Primary, Secondary and Tertiary components ---
  % -----------------------------------
  lists = [];

  items.items = get(handles.lst_Primary,'String');
  lists = [lists; items];
  x = size(items.items,1);

  items.items = get(handles.lst_Secondary,'String');
  lists = [lists; items];
  x = [x size(items.items,1)];

  items.items = get(handles.lst_Tertiary,'String');
  lists = [lists; items];
  x = [x size(items.items,1)];

  numlists = sum(x > 0);
  	
  groupList = ['<na>'];
  subjectList = ['<na>'];
  rangeList = ['<na>'];
  rangeNames = '';
  runList = ['<na>'];
  subject_output.baseDir = get( handles.txt_base_directory, 'String' );

  wildcard = get( handles.txt_use_wildcard, 'String' );
  wildcard = regexp( wildcard, ' ', 'split' );
  wildcard = char(wildcard(1));

  wildcard = strrep( wildcard, '.hdr', '' ); % -- make sure user supplied a proper extension
  x = strfind( wildcard, '.nii' );	
  y = strfind( wildcard, '.img' );
  if isempty( x ) & isempty( y )
    x = get( handles.chk_is_img, 'Value' );
    if ( x )
      fs_ext = '.img';
    else
      fs_ext = '.nii';
    end;

    %wildcard = [wildcard fs_ext];

  end;

  isMulFreq = get( handles.chk_isMulFreq, 'Value' );

  A = get(handles.chk_primary_subjects,'Value');
  A = [A; (( get(handles.chk_primary_ranges,'Value') ) * 2)];
  A = [A; (( get(handles.chk_primary_groups,'Value') ) * 3 )];
  P = A;

  A = get(handles.chk_secondary_subjects,'Value');
  A = [A; (( get(handles.chk_secondary_ranges,'Value') ) * 2)];
  A = [A; (( get(handles.chk_secondary_runs,'Value') ) * 4)];
  P = [P A];

  A = [0; 0; (( get(handles.chk_tertiary_runs,'Value') ) * 4)];
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
  end;
  pop.setIterations( numiters,  pop.PRIMARY );
  
  for flist = 1:numlists 
     P = subject_output.ptypes( flist );

     switch(P)

       case 1	% --- subjects
          subjectList = lists( flist ).items;
          numSubjects = size(subjectList, 1);
          if length(subject_output.fmt) > 0  subject_output.fmt = [subject_output.fmt filesep]; end;
          subject_output.fmt = [subject_output.fmt '{subject_dir}'];

          
       case 2	% --- meg ranges
          rangeList = '';
          numRanges =size(lists( flist ).items, 1 );
          for ii = 1:size(lists( flist ).items, 1 )
            if size(rangeList,2) > 0 rangeList = [rangeList '~']; end
            rangeList = [rangeList strtrim(char(lists( flist ).items(ii) ) ) ];
          end;
          if length(subject_output.fmt) > 0  subject_output.fmt = [subject_output.fmt filesep]; end;
          subject_output.fmt = [subject_output.fmt '{frequency_dir}'];

       case 3	% --- groups
          groupList = lists( flist ).items;
          numGroups = size(groupList, 1);
          if length(subject_output.fmt) > 0  subject_output.fmt = [subject_output.fmt filesep]; end;
          subject_output.fmt = [subject_output.fmt '{group_dir}'];

       case 4	% --- runs
          runList = lists( flist ).items;
          numRuns = size(runList, 1);
          if length(subject_output.fmt) > 0  subject_output.fmt = [subject_output.fmt filesep]; end;
          subject_output.fmt = [subject_output.fmt '{run_dir}'];

     end;

  end;


  fl = get( handles.txt_text_file_location, 'String' );
  fn = get( handles.txt_text_file_name, 'String' );
  save_file = [fl filesep fn ];

  n = [];
  sdirlist = [];

  for PrimaryList = 1:size(lists( 1 ).items, 1)
    p = [subject_output.ptypes( 1 ) PrimaryList];
    if subject_output.ptypes( 1 ) ~= 4   t1 = char(lists( 1 ).items(PrimaryList)); else t1 = []; end;

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

              end;
            else
              n = [p; subject_output.ptypes( 2 ) SecondaryList];
              t = [{t1}; {t2}];

              subject_output = parselist( n, t, subject_output );
              numRuns = max( numRuns, subject_output.Runs);
              minRuns = min( minRuns, subject_output.Runs);
            end;

          else

            n = [p; subject_output.ptypes( 2 ) SecondaryList];
            t = [{t1}; {t2}];

            subject_output = parselist( n, t, subject_output );
            numRuns = max( numRuns, subject_output.Runs);
            minRuns = min( minRuns, subject_output.Runs);
          end;

          pop.increment( pop.PRIMARY );
        end;

      else

        if ~isempty(lists( 3 ).items)
          for TertiaryList= 1:size(lists( 3 ).items, 1)
            n = [p; subject_output.ptypes( 3 ) TertiaryList];
            t = [{t1}; {char(lists( 3 ).items(TertiaryList))}];

            subject_output = parselist( n, t, subject_output );
            numRuns = max( numRuns, subject_output.Runs);
            minRuns = min( minRuns, subject_output.Runs);
          end;
          pop.increment( pop.PRIMARY );
        else
          n = p;
          t = {t1};

          subject_output = parselist( n, t, subject_output );
          numRuns = max( numRuns, subject_output.Runs);
          minRuns = min( minRuns, subject_output.Runs);
        end;

      end;

    else;
      n = p;
      t = {t1};

      subject_output = parselist( n, t, subject_output );
      numRuns = max( numRuns, subject_output.Runs);
      minRuns = min( minRuns, subject_output.Runs);

    end;

    pop.increment( pop.PRIMARY );
  end;

  if numGroups > 0 	% --- adjust the subject count
    numSubjects = size(subject_output.output, 1 );
  end;

  if minRuns == 0 minRuns = numRuns; end;

  if ~isempty(save_file)
    fid = fopen ( char(save_file), 'w' );

    fprintf( fid, 'listver:%d\n', handles.listver );
    fprintf( fid, 'Created: %s\n', date );

    str = constant_define( 'REVISION_NUMBER');
%    str = strrep( str, ' ', '_' );
    fprintf( fid, 'Version: cpca_%s\n', str );

    fprintf( fid, 'subjects:%d\n', numSubjects );
    fprintf( fid, 'runs:%d\n', numRuns );
    fprintf( fid, 'minRunCount:%d\n', minRuns );
%    fprintf( fid, 'maxRunCount:%d\n', maxRuns );
    fprintf( fid, 'groups:%d\n', numGroups );
    fprintf( fid, 'multipleFrequency:%d\n', isMulFreq );
    fprintf( fid, 'frequencies:%d\n', numRanges );
    fprintf( fid, 'frlabels:%s\n', rangeList );
    str = strrep(  subject_output.baseDir, ' ', '%20' );
    fprintf( fid, 'base_directory:%s\n', str );
    fprintf( fid, 'format:%s\n', subject_output.fmt );
    fprintf( fid, 'list:%s\n', wildcard );

    for ( ii = 1:size(subject_output.output,1) )

      if size(subject_output.output(ii).string,1) > 1
        for jj = 1:size(subject_output.output(ii).string,1)
          fprintf( fid, '%s\n', char(subject_output.output(ii).string(jj)) );
        end;
      else
       fprintf( fid, '%s\n', char(subject_output.output(ii).string) );
      end;
    end;


    fclose( fid );
  end;
  eval( ['edit ''' strtrim(char(save_file)) '''' ] );

  pop.hide();
  handles.output = '';
  guidata(handles.figure1, handles);
  uiresume(handles.figure1);


% --- Executes on button press in btn_Cancel.
function btn_Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  handles.output = '';
  guidata(handles.figure1, handles);
  uiresume(handles.figure1);



function txt_text_file_name_Callback(hObject, eventdata, handles)
% hObject    handle to txt_text_file_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_text_file_name as text
%        str2double(get(hObject,'String')) returns contents of txt_text_file_name as a double


% --- Executes during object creation, after setting all properties.
function txt_text_file_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_text_file_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_text_file_location_Callback(hObject, eventdata, handles)
% hObject    handle to txt_text_file_location (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_text_file_location as text
%        str2double(get(hObject,'String')) returns contents of txt_text_file_location as a double


% --- Executes during object creation, after setting all properties.
function txt_text_file_location_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_text_file_location (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_select_location.
function btn_select_location_Callback(hObject, eventdata, handles)
% hObject    handle to btn_select_location (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  thisDir = uigetdir('', 'Select the output directory for the file list');

  if ~isequal( thisDir, 0)
    set( handles.txt_text_file_location, 'String', thisDir );
  end;


% --- Executes during object deletion, before destroying properties.
function txt_text_file_location_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to txt_text_file_location (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  handles.output = '';
  guidata(handles.figure1, handles);
  uiresume(handles.figure1);



%function sdirstr = parselist( n, t, fmt, ptypes, baseDir )
function subject_output = parselist( n, t, subject_output )
global scan_information 

  if nargin < 4  item3 = ''; end;
  if nargin < 3  item2 = ''; end;

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

    end; % --- end switch

  end;

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
      if length(runPath) > 0  runPath = [runPath filesep]; end;
      runPath = [runPath strtrim( char(t(ii)) )];
    end;

    TertiaryList = directory_list( [ subject_output.baseDir filesep runPath ] );
    subject_output.Runs = size(TertiaryList, 1 );
    for ii = 1:size(TertiaryList, 1 )
      if length(runList) > 0  runList = [runList '~']; end;
      runList = [runList strtrim(char( TertiaryList(ii) ) )];
    end;

  end;

  sdirstr = strrep( sdirstr, '{runs}', runList );
  sdirstr = strrep( sdirstr, '  ', ' ' );

  idx = 0;
  for ii = 1:size(subject_output.output, 1 );
    if strcmp( subject_output.output(ii).id, sbj );   idx = ii; break; end;
  end;

  if ~idx
    if isempty( subject_output.output )
      subject_output.output = struct( 'id', sbj, 'string', {sdirstr} );
    else
      subject_output.output = [subject_output.output; struct( 'id', sbj, 'string', {sdirstr} )];
    end;
  else
    subject_output.output(idx).string = [subject_output.output(idx).string; {sdirstr}];
  end;





% --- Executes on button press in chk_primary_ranges.
function chk_primary_ranges_Callback(hObject, eventdata, handles)
% hObject    handle to chk_primary_ranges (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  x = get(hObject,'Value');
  st = get( handles.chk_primary_groups, 'Visible' );

  if ( strcmp( st, 'on' ) )

    if ( x )
      set(handles.chk_primary_groups,'Value', 0);
      set(handles.chk_primary_subjects,'Value', 0);
      set(handles.chk_secondary_ranges,'Value', 0);
    end;

  else
    set(hObject,'Value', 1);
  end;

  drawnow();


% --- Executes on button press in chk_secondary_ranges.
function chk_secondary_ranges_Callback(hObject, eventdata, handles)
% hObject    handle to chk_secondary_ranges (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  x = get(hObject,'Value');
  st = get( handles.chk_primary_groups, 'Visible' );

  if ( strcmp( st, 'on' ) )

    if ( x )
      set(handles.chk_primary_ranges,'Value', 0);
      set(handles.chk_secondary_subjects,'Value', 0);
      set(handles.chk_secondary_runs,'Value', 0);
    end;

  else
    set(hObject,'Value', 1);
  end;

  drawnow();


% --- Executes on button press in chk_isMulFreq.
function chk_isMulFreq_Callback(hObject, eventdata, handles)
% hObject    handle to chk_isMulFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  set_check_flags( handles );


% --- Executes on button press in chk_is_img.
function chk_is_img_Callback(hObject, eventdata, handles)
% hObject    handle to chk_is_img (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_is_img


% --- Executes on button press in chk_is_nii.
function chk_is_nii_Callback(hObject, eventdata, handles)
% hObject    handle to chk_is_nii (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_is_nii


% --- Executes on button press in dirfun.
function dirfun_Callback(hObject, eventdata, handles)
% hObject    handle to dirfun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dirfuns();
