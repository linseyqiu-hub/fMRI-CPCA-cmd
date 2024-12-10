function varargout = Range_Editor(varargin)
% RANGE_EDITOR M-file for Range_Editor.fig
%      RANGE_EDITOR, by itself, creates a new RANGE_EDITOR or raises the existing
%      singleton*.
%
%      H = RANGE_EDITOR returns the handle to a new RANGE_EDITOR or the handle to
%      the existing singleton*.
%
%      RANGE_EDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RANGE_EDITOR.M with the given input arguments.
%
%      RANGE_EDITOR('Property','Value',...) creates a new RANGE_EDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Range_Editor_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Range_Editor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Range_Editor

% Last Modified by GUIDE v2.5 15-Apr-2011 09:30:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Range_Editor_OpeningFcn, ...
                   'gui_OutputFcn',  @Range_Editor_OutputFcn, ...
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


% --- Executes just before Range_Editor is made visible.
function Range_Editor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Range_Editor (see VARARGIN)
global Zheader scan_information  ;

  handles.Zheader = Zheader;
  handles.scan_information = scan_information;

  lst = [];
  for ii = 1:size( handles.scan_information.freq_dirs, 2 )
    str = char(handles.scan_information.freq_dirs(ii));
    if ( size(handles.scan_information.freq_names, 2 ) >= ii )
      str = [str ' / ' char(handles.scan_information.freq_names(ii))];
    else
      str = [str ' / ' char(handles.scan_information.freq_dirs(ii)) ];
      handles.scan_information.freq_names(ii) = handles.scan_information.freq_dirs(ii); 
    end;
    lst = [lst; {str}];
  end;

  set( handles.lst_Ranges, 'String', lst, 'Value', 1 );
  set( handles.txt_Directory, 'String', char(handles.scan_information.freq_dirs(1)) );
  set( handles.txt_Label, 'String', char(handles.scan_information.freq_names(1)) );

  % Choose default command line output for Range_Editor
  handles.dirs = '';
  handles.labels = '';

  % Update handles structure
  guidata(hObject, handles);

  % UIWAIT makes Range_Editor wait for user response (see UIRESUME)
  uiwait(hObject);


% --- Outputs from this function are returned to the command line.
function varargout = Range_Editor_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
  varargout{1} = handles.dirs;
  varargout{2} = handles.labels;
  delete(handles.figure1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.dirs = '';
  handles.labels = '';
  guidata( handles.figure1 );
  uiresume( handles.figure1);

% --- Executes on button press in btn_Exit.
function btn_Exit_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  handles.dirs = '';
  handles.labels = '';
  guidata( handles.figure1 );
  uiresume( handles.figure1);


% --- Executes on selection change in lst_Ranges.
function lst_Ranges_Callback(hObject, eventdata, handles)
% hObject    handle to lst_Ranges (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns lst_Ranges contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lst_Ranges

  contents = get(hObject,'String');
  idx = get( hObject, 'Value');

  x = regexp(char(contents(idx)), '/', 'split' );

  set( handles.txt_Directory, 'String', strtrim(char(x(1))) );
  set( handles.txt_Label, 'String', strtrim(char(x(2))) );


% --- Executes during object creation, after setting all properties.
function lst_Ranges_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_Ranges (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_Directory_Callback(hObject, eventdata, handles)
% hObject    handle to txt_Directory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_Directory as text
%        str2double(get(hObject,'String')) returns contents of txt_Directory as a double


% --- Executes during object creation, after setting all properties.
function txt_Directory_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_Directory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_Label_Callback(hObject, eventdata, handles)
% hObject    handle to txt_Label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_Label as text
%        str2double(get(hObject,'String')) returns contents of txt_Label as a double


% --- Executes during object creation, after setting all properties.
function txt_Label_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_Label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_Update.
function btn_Update_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  contents = get(handles.lst_Ranges,'String');
  idx = get( handles.lst_Ranges, 'Value');

  str = char(get( handles.txt_Directory, 'String' ));
  lbl = char(get( handles.txt_Label, 'String' ));
  str = [str ' / ' lbl];

  lst = [];
  for ii = 1:size( contents, 1 )
    if ( ii == idx )
      lst = [lst; {str}];
    else
      lst = [lst; contents(ii)];
    end;
  end;
  set( handles.lst_Ranges, 'String', lst );

  guidata(handles.figure1, handles);


% --- Executes on button press in btn_Okay.
function btn_Okay_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Okay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.dirs = [];
  handles.labels = [];

  contents = get(handles.lst_Ranges,'String');
  for ii = 1:size( contents, 1 )
    x = regexp(char(contents(ii)), '/', 'split' );

    handles.dirs = [handles.dirs {strtrim(char(x(1)))}];
    handles.labels = [handles.labels {strtrim(char(x(2)))}];

  end;

  guidata( handles.figure1, handles );

  uiresume( handles.figure1);

