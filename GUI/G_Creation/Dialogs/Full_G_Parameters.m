function varargout = Full_G_Parameters(varargin)
% FULL_G_PARAMETERS M-file for Full_G_Parameters.fig
%      FULL_G_PARAMETERS, by itself, creates a new FULL_G_PARAMETERS or raises the existing
%      singleton*.
%
%      H = FULL_G_PARAMETERS returns the handle to a new FULL_G_PARAMETERS or the handle to
%      the existing singleton*.
%
%      FULL_G_PARAMETERS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FULL_G_PARAMETERS.M with the given input arguments.
%
%      FULL_G_PARAMETERS('Property','Value',...) creates a new FULL_G_PARAMETERS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Full_G_Parameters_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Full_G_Parameters_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Full_G_Parameters

% Last Modified by GUIDE v2.5 06-Aug-2013 16:27:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Full_G_Parameters_OpeningFcn, ...
                   'gui_OutputFcn',  @Full_G_Parameters_OutputFcn, ...
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


% --- Executes just before Full_G_Parameters is made visible.
function Full_G_Parameters_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Full_G_Parameters (see VARARGIN)
global Zheader scan_information 

% Choose default command line output for Full_G_Parameters
%handles.output = hObject;

  handles.output.gh =   structure_define( 'gheader' );

  if(nargin > 3)
    for index = 1:2:(nargin-3),
      if nargin-3==index, break, end
        switch lower(varargin{index})
         case 'header'
          hdr = varargin{index+1};
          handles.output.gh = adjust_gheader( hdr );

      end
    end
  end

  set( handles.txt_numConditions, 'String', num2str(handles.output.gh.conditions) );
  set( handles.txt_numTimeBins, 'String', num2str(handles.output.gh.bins) );
  set( handles.txt_TimingRate, 'String', num2str(handles.output.gh.TR) );
  set( handles.btn_InScans, 'Value', handles.output.gh.inScans == 1 );
  set( handles.btn_InSeconds, 'Value', handles.output.gh.inScans == 0 );
  set( handles.lst_ConditionNames, 'String', handles.output.gh.condition_name, 'Value', 1 );

  set ( handles.btn_isFIR, 'Value', handles.output.gh.model_type == constant_define( 'FIR_MODEL' ) );
  set ( handles.btn_isHRF, 'Value', handles.output.gh.model_type == constant_define( 'HRF_MODEL' ) );

  chkApplied = length(handles.output.gh.date_applied) > 0 & length(handles.output.gh.applied_to) > 0 ;
  set( handles.chk_Applied, 'Value', chkApplied );

  set( handles.txt_date_applied, 'String', handles.output.gh.date_applied );
  str = short_path( handles.output.gh.applied_to, 5 );
  set( handles.txt_applied_to, 'String', str );
  str = short_path( handles.output.gh.path_to_segs, 5 );
  set( handles.txt_path_to_segs, 'String', str );
  str = short_path( handles.output.gh.source, 4 );
  set( handles.txt_source, 'String', str );

  state = 'off';
  handles.subjectvector = [];

  handles.viewsettings.maxscans = 1200;
  handles.viewsettings.numsubjects = 0;

  lst = [];
  
  if ( length( handles.output.gh.path_to_segs ) > 0 )
    fn = [ handles.output.gh.path_to_segs filesep 'G_S1.mat' ];
    x = exist( fn, 'file' );
    if ( x == 2 )  % okay, the files exsit ( well at least subject 1 )

      this_idx = 1;
      subjectscans = 0;
      while ( subjectscans < min( Zheader.total_scans, handles.viewsettings.maxscans ) )
        for ii = 1:Zheader.num_runs 
          if iscellstr( scan_information.SubjDir(this_idx, ii ) )
            subjectscans = subjectscans + Zheader.timeseries.subject(this_idx).run(ii,1);
          end
        end;
        this_idx = this_idx + 1;
        handles.viewsettings.numsubjects = handles.viewsettings.numsubjects + 1;
      end;

      lst = scan_information.SubjectID;
      if ( size(lst,2) > 0 )
        state = 'on';  
      end;
      handles.subjectvector = [1:size(lst,2)];

    end;
  end;

  set( handles.btn_view_segment, 'Enable', state );
  set( handles.lst_subjects, 'Enable', state );
  set( handles.lst_subjects, 'String', lst, 'Value', 1);
  set( handles.chk_subject_only, 'Enable', state );

  if ~isempty( handles.output.gh.GZheader )
    set( handles.txt_num_subjects, 'String', num2str(handles.output.gh.GZheader.subjects) );
    set( handles.txt_num_runs, 'String', num2str(handles.output.gh.GZheader.runs) );
    set( handles.txt_num_columns, 'String', num2str(handles.output.gh.GZheader.columns) );
    set( handles.txt_sum_diagonal, 'String', num2str(handles.output.gh.GZheader.sum_diagonal) );

    if isfield( handles.output.gh.GZheader, 'path_to_segs' )

      str = short_path( handles.output.gh.GZheader.path_to_segs, 5 );
      set( handles.txt_gz_path_to_segs, 'String', str );

      if ( length( handles.output.gh.GZheader.path_to_segs ) > 0 )
        chkBB = [ handles.output.gh.GZheader.path_to_segs 'GCC.mat' ];
        chkB = [ handles.output.gh.GZheader.path_to_segs 'GC.mat' ];

        x = exist( chkB );  
        y = exist( chkBB );  
  
        if ( x ~=2 | y ~= 2 )
          set( handles.btn_update_Bs, 'Visible', 'on' );
        end;
      end;

    end;

  end;

  if ( ismac )
    set( handles.txt_numConditions, 'HorizontalAlignment', 'center' );
    set( handles.txt_numTimeBins, 'HorizontalAlignment', 'center' );
    set( handles.txt_TimingRate, 'HorizontalAlignment', 'center' );
    
    set( handles.txt_date_applied, 'HorizontalAlignment', 'center' );
%    set( handles.txt_applied_to, 'HorizontalAlignment', 'center' );
%    set( handles.txt_path_to_segs, 'HorizontalAlignment', 'center' );
%    set( handles.txt_source, 'HorizontalAlignment', 'center' );

    set( handles.txt_num_subjects, 'HorizontalAlignment', 'center' );
    set( handles.txt_num_runs, 'HorizontalAlignment', 'center' );
    set( handles.txt_num_columns, 'HorizontalAlignment', 'center' );
    set( handles.txt_sum_diagonal, 'HorizontalAlignment', 'center' );
%    set( handles.txt_gz_path_to_segs, 'HorizontalAlignment', 'center' );

    pos = get(handles.txt_numConditions, 'Position' );
    set( handles.txt_numConditions, 'Position', [pos(1) pos(2) pos(3) 1.75] );
    pos = get(handles.txt_numTimeBins, 'Position' );
    set( handles.txt_numTimeBins, 'Position', [pos(1) pos(2) pos(3) 1.75] );
    pos = get(handles.txt_TimingRate, 'Position' );
    set( handles.txt_TimingRate, 'Position', [pos(1) pos(2) pos(3) 1.75] );

    pos = get(handles.txt_date_applied, 'Position' );
    set( handles.txt_date_applied, 'Position', [pos(1) pos(2) pos(3) 1.75] );
    pos = get(handles.txt_applied_to, 'Position' );
    set( handles.txt_applied_to, 'Position', [pos(1) pos(2) pos(3) 1.75] );
    pos = get(handles.txt_path_to_segs, 'Position' );
    set( handles.txt_path_to_segs, 'Position', [pos(1) pos(2) pos(3) 1.75] );
    pos = get(handles.txt_source, 'Position' );
    set( handles.txt_source, 'Position', [pos(1) pos(2) pos(3) 1.75] );

    pos = get(handles.txt_num_subjects, 'Position' );
    set( handles.txt_num_subjects, 'Position', [pos(1) pos(2) pos(3) 1.75] );
    pos = get(handles.txt_num_runs, 'Position' );
    set( handles.txt_num_runs, 'Position', [pos(1) pos(2) pos(3) 1.75] );
    pos = get(handles.txt_num_columns, 'Position' );
    set( handles.txt_num_columns, 'Position', [pos(1) pos(2) pos(3) 1.75] );
    pos = get(handles.txt_sum_diagonal, 'Position' );
    set( handles.txt_sum_diagonal, 'Position', [pos(1) pos(2) pos(3) 1.75] );
    pos = get(handles.txt_gz_path_to_segs, 'Position' );
    set( handles.txt_gz_path_to_segs, 'Position', [pos(1) pos(2) pos(3) 1.75] );
    
  end;
  

  if ( handles.output.gh.illformed )
    set( handles.btn_view_rank, 'ForegroundColor', constant_define( 'COLOR_RED' ) );
  else
    set( handles.btn_view_rank, 'ForegroundColor', [ 0 0 0 ] );
  end;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Full_G_Parameters wait for user response (see UIRESUME)
 uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Full_G_Parameters_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

varargout{1} = handles.output.gh;
delete(handles.figure1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
  handles.output.gh = '';
  guidata(handles.figure1, handles);
  uiresume(handles.figure1);



% --- Executes on selection change in lst_ConditionNames.
function lst_ConditionNames_Callback(hObject, eventdata, handles)
% hObject    handle to lst_ConditionNames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  % If double click
  if strcmp(get(handles.figure1,'SelectionType'),'open')

    sels = findobj('Tag','lst_ConditionNames');
    aa = get( sels, 'String') ;
    [x y] = size( aa );
    if ( x == 0 )  % empty list
      return
    end;

    selected_index = get( sels, 'Value') ;
    newEntry = inputdlg('Enter the condition name','Edit condition name', 1, aa(selected_index) );
    if ( ~isempty( newEntry ) ) 
      aa(selected_index) = newEntry;
      set( sels, 'String', aa, 'Value', 1) ;
    end; 
    handles.output.gh.condition_name = aa;
    guidata(hObject, handles);

  end;


% --- Executes during object creation, after setting all properties.
function lst_ConditionNames_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_ConditionNames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_numConditions_Callback(hObject, eventdata, handles)
% hObject    handle to txt_numConditions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  str = get(hObject,'String');
  str = validate_numeric_entry( str );
  set(hObject,'String', str );


% --- Executes during object creation, after setting all properties.
function txt_numConditions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_numConditions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


function txt_numTimeBins_Callback(hObject, eventdata, handles)
% hObject    handle to txt_numTimeBins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  str = get(hObject,'String');
  str = validate_numeric_entry( str );
  set(hObject,'String', str );


% --- Executes during object creation, after setting all properties.
function txt_numTimeBins_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_numTimeBins (see GCBO)
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
global Zheader

  % --------------------------------
  % Number of conditions
  % --------------------------------
  handles.output.gh.conditions = str2double(get(handles.txt_numConditions,'String')); 

  % --------------------------------
  % Number of timebins
  % --------------------------------
  handles.output.gh.bins = str2double(get(handles.txt_numTimeBins,'String')); 

  % --------------------------------
  % Timing Rate
  % --------------------------------
  handles.output.gh.TR = str2double(get(handles.txt_TimingRate,'String')); 

  % --------------------------------
  % Model Type  0 = FIR, 1 = HRF
  % --------------------------------
  handles.output.gh.model_type = get( handles.btn_isHRF, 'Value' );

  % --------------------------------
  % Timing in Seconds or Scans
  % --------------------------------
  handles.output.gh.inScans = ( get(handles.btn_InScans,'Value') == 1 ); 

  % --------------------------------
  % Condition Names
  % --------------------------------
  sels = findobj('Tag','lst_selectedConditionNames');
  handles.output.gh.condition_name = get( handles.lst_ConditionNames, 'String') ;

  % --------------------------------
  % G application information
  % --------------------------------
  handles.output.gh.date_applied = get(handles.txt_date_applied,'String');
  % handles.output.gh.applied_to = get(handles.txt_applied_to,'String');  		% set during changes - view is shortened
  % handles.output.gh.path_to_segs = get(handles.txt_path_to_segs,'String');		% set during changes - view is shortened
  % handles.output.gh.source = get(handles.txt_source,'String');			% set during changes - view is shortened

  handles.output.gh.GZheader.subjects = str2num(get(handles.txt_num_subjects,'String'));
  handles.output.gh.GZheader.runs = str2num(get(handles.txt_num_runs,'String'));
  handles.output.gh.GZheader.columns = str2num(get(handles.txt_num_columns,'String'));
  handles.output.gh.GZheader.sum_diagonal = str2num(get(handles.txt_sum_diagonal,'String'));
  % handles.output.gh.GZheader.path_to_segs = get(handles.txt_gz_path_to_segs,'String');	% set during changes - view is shortened

  % Update handles structure
  guidata(hObject, handles);

  uiresume(handles.figure1);


% --- Executes on button press in btn_Cancel.
function btn_Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  handles.output.gh = '';
  guidata(handles.figure1, handles);
  uiresume(handles.figure1);


% --- Executes on button press in btn_InSeconds.
function btn_InSeconds_Callback(hObject, eventdata, handles)
% hObject    handle to btn_InSeconds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

 this_btn = get(hObject,'Value'); % returns toggle state of btn_HRF
 set ( handles.btn_InScans, 'Value', ( this_btn == 0 ) );
 set ( handles.btn_InSeconds, 'Value', ( this_btn == 1 ) );


% --- Executes on button press in btn_InScans.
function btn_InScans_Callback(hObject, eventdata, handles)
% hObject    handle to btn_InScans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

 this_btn = get(hObject,'Value'); % returns toggle state of btn_HRF
 set ( handles.btn_InScans, 'Value', ( this_btn == 1 ) );
 set ( handles.btn_InSeconds, 'Value', ( this_btn == 0 ) );


function txt_TimingRate_Callback(hObject, eventdata, handles)
% hObject    handle to txt_TimingRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  str = get(hObject,'String');
  str = validate_numeric_entry( str );
  set(hObject,'String', str );


% --- Executes during object creation, after setting all properties.
function txt_TimingRate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_TimingRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on txt_numConditions and none of its controls.
function txt_numConditions_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to txt_numConditions (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

  k = eventdata.Key;

  if ( strcmp( k, 'return' ) )
    drawnow();				% force text inoput box update with current value

    numConds = str2double( get( handles.txt_numConditions,'String') );

    aa = get( handles.lst_ConditionNames, 'String') ;
    [x y] = size( aa );

    if ( x < numConds )
      xx = x + 1;
      for ii = xx:numConds
        str = sprintf( 'Condition %d', ii );
        aa = [aa; {str}];
      end;

      set( handles.lst_ConditionNames, 'String', aa, 'Value', 1 );
   
    else

      if ( x > numConds )
        aa = aa(1:numConds);
        set( handles.lst_ConditionNames, 'String', aa, 'Value', 1 );
      end

    end;
    
  end;



function txt_source_Callback(hObject, eventdata, handles)
% hObject    handle to txt_source (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_source as text
%        str2double(get(hObject,'String')) returns contents of txt_source as a double


% --- Executes during object creation, after setting all properties.
function txt_source_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_source (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_date_applied_Callback(hObject, eventdata, handles)
% hObject    handle to txt_date_applied (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_date_applied as text
%        str2double(get(hObject,'String')) returns contents of txt_date_applied as a double


% --- Executes during object creation, after setting all properties.
function txt_date_applied_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_date_applied (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_applied_to_Callback(hObject, eventdata, handles)
% hObject    handle to txt_applied_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function txt_applied_to_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_applied_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_applied_to.
function btn_applied_to_Callback(hObject, eventdata, handles)
% hObject    handle to btn_applied_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


  fullpath = select_file( {'ZInfo.mat;','CPCA ZInfo file'}, ...
                                   'Select your file Processed Data set');

  if ~isequal( fullpath, 0)
    [p f] = split_path( fullpath, filesep );
    handles.output.gh.applied_to = p;

    % Update handles structure
    guidata(hObject, handles);

    str = short_path( handles.output.gh.applied_to, 5 );
    set( handles.txt_applied_to, 'String', str );
    drawnow();
  end


function txt_path_to_segs_Callback(hObject, eventdata, handles)
% hObject    handle to txt_path_to_segs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_path_to_segs as text
%        str2double(get(hObject,'String')) returns contents of txt_path_to_segs as a double


% --- Executes during object creation, after setting all properties.
function txt_path_to_segs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_path_to_segs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_path_to_segs.
function btn_path_to_segs_Callback(hObject, eventdata, handles)
% hObject    handle to btn_path_to_segs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  dirname = uigetdir('', 'Select the Directory of your G segments');

  if ~isequal( dirname, 0)
    handles.output.gh.path_to_segs = [ dirname filesep];

    % Update handles structure
    guidata(hObject, handles);

    str = short_path( handles.output.gh.path_to_segs, 5 );
    set( handles.txt_path_to_segs, 'String', str );
    drawnow();
  end



function txt_num_subjects_Callback(hObject, eventdata, handles)
% hObject    handle to txt_num_subjects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  str = get(hObject,'String');
  str = validate_numeric_entry( str );
  set(hObject,'String', str );


% --- Executes during object creation, after setting all properties.
function txt_num_subjects_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_num_subjects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_num_runs_Callback(hObject, eventdata, handles)
% hObject    handle to txt_num_runs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  str = get(hObject,'String');
  str = validate_numeric_entry( str );
  set(hObject,'String', str );


% --- Executes during object creation, after setting all properties.
function txt_num_runs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_num_runs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_num_columns_Callback(hObject, eventdata, handles)
% hObject    handle to txt_num_columns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  str = get(hObject,'String');
  str = validate_numeric_entry( str );
  set(hObject,'String', str );


% --- Executes during object creation, after setting all properties.
function txt_num_columns_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_num_columns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_sum_diagonal_Callback(hObject, eventdata, handles)
% hObject    handle to txt_sum_diagonal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  str = get(hObject,'String');
  str = validate_numeric_entry( str );
  set(hObject,'String', str );


% --- Executes during object creation, after setting all properties.
function txt_sum_diagonal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_sum_diagonal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_gz_path_to_segs_Callback(hObject, eventdata, handles)
% hObject    handle to txt_gz_path_to_segs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function txt_gz_path_to_segs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_gz_path_to_segs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% --- Executes on button press in btn_gz_path_to_segs.
function btn_gz_path_to_segs_Callback(hObject, eventdata, handles)
% hObject    handle to btn_gz_path_to_segs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Zheader 

  dirname = uigetdir('', 'Select the Dirctory of your GZ output');

  if ~isequal( dirname, 0)
    handles.output.gh.GZheader.path_to_segs = [dirname filesep];

    % Update handles structure
    guidata(hObject, handles);

    str = short_path( handles.output.gh.GZheader.path_to_segs, 5 );
    set( handles.txt_gz_path_to_segs, 'String', str );

    state = 'off';

    if ( length( handles.output.gh.GZheader.path_to_segs ) > 0 )

      chkBB = [ handles.output.gh.GZheader.path_to_segs 'GCC.mat' ];
      chkB = [ handles.output.gh.GZheader.path_to_segs 'GC.mat' ];

      x = exist( chkB );  
      y = exist( chkBB );  

      if ( x ~=2 | y ~= 2 )  state = 'on';  end;

    end;

    % determine the number of subjects, runs and columns in the processed data
    x=0;
    eval ( [ 'x = who_count( ''' handles.output.gh.GZheader.path_to_segs ''', ''GC_S1.mat'', ''GC_C*'' );' ] );
    handles.output.gh.GZheader.columns = x;

    x = dir( [ handles.output.gh.GZheader.path_to_segs 'GZ_S*' ] );
    handles.output.gh.GZheader.subjects = size(x,1);

%    eval ( [ 'x = who_count( ''' handles.output.gh.GZheader.path_to_segs ''', ''GZ_S1.mat'', ''GZ*'' );' ] );
    eval ( [ 'x = who_count( ''' Zheader.Z_Directory 'Z' filesep ''', ''Z1.mat'', ''Z_R*'' );' ] );
    handles.output.gh.GZheader.runs =x;

    chkGZ = [ handles.output.gh.GZheader.path_to_segs '../GZ.mat' ];
    x = exist( chkGZ );  
    if ( x == 2 )	% we may have an older data GZ file in parent directory

      eval ( [ 'x = who_stats( ''' handles.output.gh.GZheader.path_to_segs '../'', ''GZ.mat'', ''GCsd'' );' ] );
      if ( x.mat_exists )
        eval ( [ 'load( ''' handles.output.gh.GZheader.path_to_segs '../GZ.mat'', ''GCsd'')' ] );
        handles.output.gh.GZheader.sum_diagonal = GCsd;
        set( handles.txt_sum_diagonal, 'String', num2str(handles.output.gh.GZheader.sum_diagonal) );

      end;

    end;

    % Update handles structure
    guidata(hObject, handles);

    set( handles.txt_num_subjects, 'String', num2str(handles.output.gh.GZheader.subjects) );
    set( handles.txt_num_runs, 'String', num2str(handles.output.gh.GZheader.runs) );
    set( handles.txt_num_columns, 'String', num2str(handles.output.gh.GZheader.columns) );

    set( handles.btn_update_Bs, 'Visible',state );
    drawnow();

  end


% --- Executes on button press in btn_source.
function btn_source_Callback(hObject, eventdata, handles)
% hObject    handle to btn_source (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  fullpath = select_file( {'*.txt;*.m;*.mat','Timing Onsets file, or G matrix'}, ...
                                   'Select your timing onsets or G Matrix');

  if ~isequal( fullpath, 0)
    handles.output.gh.source = fullpath;

    % Update handles structure
    guidata(hObject, handles);

    str = short_path( handles.output.gh.source, 4 );
    set( handles.txt_source, 'String', str );
    drawnow();
  end


% --- Executes on button press in btn_recalc_GCsd.
function btn_recalc_GCsd_Callback(hObject, eventdata, handles)
% hObject    handle to btn_recalc_GCsd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Zheader 

  % determine the number of subjects, runs and columns in the processed data
  x=0;
  eval ( [ 'x = who_count( ''' handles.output.gh.GZheader.path_to_segs ''', ''GC_S1.mat'', ''GC_C*'' );' ] );
  handles.output.gh.GZheader.columns = x;

  x = dir( [ handles.output.gh.GZheader.path_to_segs 'GZ_S*' ] );
  handles.output.gh.GZheader.subjects = size(x,1);

%  eval ( [ 'x = who_count( ''' handles.output.gh.GZheader.path_to_segs ''', ''GZ_S1.mat'', ''GZ*'' );' ] );
  eval ( [ 'x = who_count( ''' Zheader.Z_Directory 'Z' filesep ''', ''Z1.mat'', ''Z_R*'' );' ] );
  handles.output.gh.GZheader.runs =x;

  % Update handles structure
  guidata(hObject, handles);

  set( handles.txt_num_subjects, 'String', num2str(handles.output.gh.GZheader.subjects) );
  set( handles.txt_num_runs, 'String', num2str(handles.output.gh.GZheader.runs) );
  set( handles.txt_num_columns, 'String', num2str(handles.output.gh.GZheader.columns) );

  drawnow();

  GCsd = 0;
  iterations = Zheader.num_subjects * Zheader.num_runs;

  pb = cpca_progress();
  pb.setWindowTitle( 'Recalculating' );
  pb.setMessage( 'Recalculating GC sum diagonal value', '', '' );
  pb.setIterations( iterations );

  for SubjectNo=1:Zheader.num_subjects

    in_GC_file = [ handles.output.gh.GZheader.path_to_segs 'GC_S' num2str(SubjectNo) ];
    sid = subject_id( SubjectNo );
%    for RunNo = 1:Zheader.num_runs

      pb.setParticipant( SubjectNo, Zheader.num_subjects, sid );
      pb.increment();

      for column = 1:size( Zheader.partitions.columns,2)
        str = [ 'Column ' num2str(column) ' of ' num2str(size( Zheader.partitions.columns,2)) ];
        pb = pb.setStatus( str );
        pb.refresh();
        eval ( [ 'load( ''' in_GC_file '.mat'', ''GC_C' num2str(column) ''')' ] );
        eval ( ['GCsd = GCsd + sum_diagonal( GC_C' num2str(column) ') );' ] );
      end;
%    end;

  end;
  pb.hide();
  clear pb;
  
  if ( GCsd > 0 )
    handles.output.gh.GZheader.sum_diagonal = GCsd / (Zheader.total_scans - 1);

    % Update handles structure
    guidata(hObject, handles);

    set( handles.txt_sum_diagonal, 'String', num2str(handles.output.gh.GZheader.sum_diagonal) );
    drawnow();
  end;


% --- Executes on button press in btn_update_Bs.
function btn_update_Bs_Callback(hObject, eventdata, handles)
% hObject    handle to btn_update_Bs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  % ------------------------------------
  % -- ensure we have a proper output directory specified
  % ------------------------------------
  chkGZ = [ handles.output.gh.GZheader.path_to_segs 'GZ_S1.mat' ];
  x = exist( chkGZ );  
  if ( x == 2 )
  
    chkBB = [ handles.output.gh.GZheader.path_to_segs 'GCC.mat' ];
    y = exist( chkBB );  
    if ( y ~= 2 )

      % ------------------------------------
      % -- locate a BBG_nd* file in the parent directory
      % ------------------------------------
      z = dir( [ handles.output.gh.GZheader.path_to_segs '../GCC*' ] );
      if ( size(z,1) > 0 )
        fn = [ handles.output.gh.GZheader.path_to_segs '../' z(1).name ];
        [ copied errmsg errno] = copyfile ( fn, chkBB );
        if ( copied == 0 )
          str = [ 'unable to copy file ' fn ' to ' chkBB ' - error message: ' errmsg ];
          show_message( 'File Copy Failure', str );
          return;
        end;
      end;

    end;


    chkB = [ handles.output.gh.GZheader.path_to_segs 'GC.mat' ];
    y = exist( chkB );  
    if ( y ~= 2 )

      % ------------------------------------
      % -- locate a BG_nd* file in the parent directory
      % ------------------------------------
      z = dir( [ handles.output.gh.GZheader.path_to_segs '../BG*' ] );
      if ( size(z,1) > 0 )
        fn = [ handles.output.gh.GZheader.path_to_segs '../' z(1).name ];
        [ copied errmsg errno] = copyfile ( fn, chkB );
        if ( copied == 0 )
          str = [ 'unable to copy file ' fn ' to ' chkB ' - error message: ' errmsg ];
          show_message( 'File Copy Failure', str );
          return;
        end;
      end;

    end;

  end;


  chkBB = [ handles.output.gh.GZheader.path_to_segs 'GCC.mat' ];
  chkB = [ handles.output.gh.GZheader.path_to_segs 'GC.mat' ];

  x = exist( chkB );  
  y = exist( chkBB );  
  
  if ( x ==2 & y == 2 )
    set( handles.btn_update_Bs, 'Visible', 'off' );
    drawnow();
  end;


% --- Executes on button press in btn_view_segment.
function btn_view_segment_Callback(hObject, eventdata, handles)
% hObject    handle to btn_view_segment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Zheader scan_information 

% this need to be rewritten to accomodate multiple subject/run viewing
% number of sujects tro view dependant on number or runs ( min 1 subject for multiple runs)
% base on a maximum G depth of ~1200 - 1500 scans maximum )
% this value should be adjustable by user

  subjectno = get(handles.lst_subjects,'Value');
  contents = get(handles.lst_subjects,'String') ;
  subjectid = char( contents{subjectno} );

  G = [];
  x = get( handles.chk_subject_only, 'Value' );

  if ( x == 1 ) 		% show single subject only 
    lastsub = subjectno;  
  else
    lastsub = min(subjectno+handles.viewsettings.numsubjects-1, Zheader.num_subjects );
  end;

  for sno = subjectno:lastsub

    Gs = [];

%    for ii = 1:Zheader.num_runs
      fn = [ handles.output.gh.path_to_segs filesep 'G_S' num2str(sno) ];
      eval( ['load( ''' fn '.mat'', ''' handles.output.gh.raw ''')' ] );
      eval( ['Gs = [Gs; ' handles.output.gh.raw ' ];' ] );
%    end;

    if ( handles.output.gh.model_type == constant_define( 'FIR_MODEL' ) )
      % now we need to pad G if it needs it;
      if ( size(G,2) > 0 )
        G = [G zeros( size(G,1), size(Gs,2) )];
        G = [G; [zeros( size(Gs,1), size(G,2) - size(Gs,2) ) Gs ] ];
      else    
        G = Gs;
      end;

    else
      if exist( 'G', 'var' )
        G = [G; Gs];
      else
        G = Gs;
      end;

    end;

  end;

  if ( size( G,1 ) > 0 )

    if ( lastsub == subjectno )
      viewTitle = sprintf ( 'Subject %d (%s)', subjectno, char(contents(subjectno)) );
    else
      viewTitle = sprintf ( 'Subjects %d (%s) - %d (%s)', subjectno, char(contents(subjectno)), lastsub, char(contents(lastsub)) );
    end;

    if handles.output.gh.model_type == constant_define( 'HRF_MODEL' )
      h = figure; plot( G, '-' );
    else
      h = figure; colormap(gray); imagesc( G );
    end;
    set( h, 'NumberTitle' , 'off' );
    set( h, 'Name' , viewTitle );
  end;



% --- Executes on selection change in lst_subjects.
function lst_subjects_Callback(hObject, eventdata, handles)
% hObject    handle to lst_subjects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns lst_subjects contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lst_subjects


% --- Executes during object creation, after setting all properties.
function lst_subjects_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_subjects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_load_new.
function btn_load_new_Callback(hObject, eventdata, handles)
% hObject    handle to btn_load_new (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Zheader

  fullpath = select_file( {'*.mat','MATLAB .mat file'}, ...
                                   'Select your G Header file');
  if ~isempty( fullpath )

    [path fn] = split_path( fullpath, filesep );
    xx = who_stats( path, fn, 'Gheader' );
    if xx.mat_exists == 1
      evalc(  ['load( ''' fullpath '''. ''Gheader'')'] );

      hdr = Gheader;
      if isfield( hdr, 'conditions' ) 		handles.output.gh.conditions = hdr.conditions;		end;
      if isfield( hdr, 'bins' ) 		handles.output.gh.bins = hdr.bins;			end;
      if isfield( hdr, 'TR' ) 			handles.output.gh.TR = hdr.TR;				end;
      if isfield( hdr, 'prefix' ) 		handles.output.gh.prefix = hdr.prefix;			end;
      if isfield( hdr, 'inScans' ) 		handles.output.gh.inScans = hdr.inScans;		end;
      if isfield( hdr, 'condition_name' ) 	handles.output.gh.condition_name = hdr.condition_name;	end;
      if isfield( hdr, 'path_to_segs' ) 	handles.output.gh.path_to_segs = hdr.path_to_segs;	end;
      if isfield( hdr, 'applied_to' ) 		handles.output.gh.applied_to = hdr.applied_to;		end;
      if isfield( hdr, 'source' ) 		handles.output.gh.source = hdr.source;			end;
      if isfield( hdr, 'date_applied' ) 	handles.output.gh.date_applied = hdr.date_applied;	end;

      if isfield( hdr, 'GZheader' ) 	

        if isfield( hdr.GZheader, 'prefix' ) 		handles.output.gh.GZheader.prefix = hdr.GZheader.prefix;		end;
        if isfield( hdr.GZheader, 'columns' ) 		handles.output.gh.GZheader.columns = hdr.GZheader.columns;		end;
        if isfield( hdr.GZheader, 'runs' ) 		handles.output.gh.GZheader.runs = hdr.GZheader.runs;			end;
        if isfield( hdr.GZheader, 'subjects' ) 		handles.output.gh.GZheader.subjects = hdr.GZheader.subjects;		end;
        if isfield( hdr.GZheader, 'sum_diagonal' ) 	handles.output.gh.GZheader.sum_diagonal = hdr.GZheader.sum_diagonal;	end;
        if isfield( hdr.GZheader, 'path_to_segs' ) 	handles.output.gh.GZheader.path_to_segs = hdr.GZheader.path_to_segs;	end;

      else
        handles.output.gh.GZHeader = new_GZheader();
      end;

      handles.output.gh.prefix = 'G';
      if isfield( hdr, 'raw' ) 			handles.output.gh.raw = hdr.raw;			end;
      if isfield( hdr, 'norm' ) 		handles.output.gh.norm = hdr.norm;			end;

      guidata(hObject, handles);

      set( handles.txt_numConditions, 'String', num2str(handles.output.gh.conditions) );
      set( handles.txt_numTimeBins, 'String', num2str(handles.output.gh.bins) );
      set( handles.txt_TimingRate, 'String', num2str(handles.output.gh.TR) );
      set( handles.btn_InScans, 'Value', handles.output.gh.inScans == 1 );
      set( handles.btn_InSeconds, 'Value', handles.output.gh.inScans == 0 );
      set( handles.lst_ConditionNames, 'String', handles.output.gh.condition_name, 'Value', 1 );

      chkApplied = length(handles.output.gh.date_applied) > 0 & length(handles.output.gh.applied_to) > 0 ;
      set( handles.chk_Applied, 'Value', chkApplied );

      set( handles.txt_date_applied, 'String', handles.output.gh.date_applied );
      str = short_path( handles.output.gh.applied_to, 5 );
      set( handles.txt_applied_to, 'String', str );
      str = short_path( handles.output.gh.path_to_segs, 5 );
      set( handles.txt_path_to_segs, 'String', str );
      str = short_path( handles.output.gh.source, 4 );
      set( handles.txt_source, 'String', str );

      state = 'off';
      lst = {'<none>'};
      if ( ~ispc() )			% Linux Mac for now
        d = dir( [ handles.output.gh.path_to_segs 'G_S*.mat'] );
        if ( size(d,1) == Zheader.num_subjects ) 
          state = 'on';  
          lst = [];
          for ( ii = 1:size(d,1) )
            x = d(ii).name;
            x = strrep( x, 'G_S', 'S: ' );
            x = strrep( x, '.mat', '' );
            x = strrep( x, '_', ' Rn: ' );
            lst = [lst; {x}];
          end;
        end;
      end
      set( handles.btn_view_segment, 'Enable', state );
      set( handles.lst_subjects, 'Enable', state );
      set( handles.lst_subjects, 'String', lst, 'Value', 1);
      set( handles.chk_subject_only, 'Enable', state );

      set( handles.txt_num_subjects, 'String', num2str(handles.output.gh.GZheader.subjects) );
      set( handles.txt_num_runs, 'String', num2str(handles.output.gh.GZheader.runs) );
      set( handles.txt_num_columns, 'String', num2str(handles.output.gh.GZheader.columns) );
      set( handles.txt_sum_diagonal, 'String', num2str(handles.output.gh.GZheader.sum_diagonal) );
      str = short_path( handles.output.gh.GZheader.path_to_segs, 5 );
      set( handles.txt_gz_path_to_segs, 'String', str );

    else

      str = sprintf( 'There is no Gheader variable found in the selected file' );
      show_message( 'No Header Found', str );
    end;

  end;


% --- Executes on button press in chk_subject_only.
function chk_subject_only_Callback(hObject, eventdata, handles)
% hObject    handle to chk_subject_only (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_subject_only


% --- Executes on button press in btn_Model_Notes.
function btn_Model_Notes_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Model_Notes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  desc = '';

  if isfield( handles.output.gh, 'Description' )
    if ( iscell( handles.output.gh.Description ) )
      desc = handles.output.gh.Description;
    else
      desc = {handles.output.gh.Description};
    end;
  end;

  newEntry = inputdlg('notes', 'Enter your notes for this model', constant_define( 'INPUT_DLG_SIZE' ), desc );

  if ( ~isempty( newEntry ) )
    handles.output.gh.Description = newEntry;
    % Update handles structure
    guidata(hObject, handles);
  end;


% --- Executes on button press in btn_isFIR.
function btn_isFIR_Callback(hObject, eventdata, handles)
% hObject    handle to btn_isFIR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.output.gh.model_type = constant_define( 'FIR_MODEL' );
  guidata(handles.figure1, handles);

  set ( handles.btn_isFIR, 'Value', handles.output.gh.model_type == constant_define( 'FIR_MODEL' ) );
  set ( handles.btn_isHRF, 'Value', handles.output.gh.model_type == constant_define( 'HRF_MODEL' ) );




% --- Executes on button press in btn_isHRF.
function btn_isHRF_Callback(hObject, eventdata, handles)
% hObject    handle to btn_isHRF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.output.gh.model_type = constant_define( 'HRF_MODEL' );
  guidata(handles.figure1, handles);

  set ( handles.btn_isFIR, 'Value', handles.output.gh.model_type == constant_define( 'FIR_MODEL' ) );
  set ( handles.btn_isHRF, 'Value', handles.output.gh.model_type == constant_define( 'HRF_MODEL' ) );


% --- Executes on button press in btn_view_rank.
function btn_view_rank_Callback(hObject, eventdata, handles)
% hObject    handle to btn_view_rank (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  edit( [handles.output.gh.path_to_segs 'G_Ranking.txt'] );
