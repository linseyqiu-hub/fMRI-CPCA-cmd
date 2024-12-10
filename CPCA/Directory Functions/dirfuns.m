function varargout = dirfuns(varargin)
% DIRFUNS MATLAB code for dirfuns.fig
%      DIRFUNS, by itself, creates a new DIRFUNS or raises the existing
%      singleton*.
%
%      H = DIRFUNS returns the handle to a new DIRFUNS or the handle to
%      the existing singleton*.
%
%      DIRFUNS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DIRFUNS.M with the given input arguments.
%
%      DIRFUNS('Property','Value',...) creates a new DIRFUNS or raises
%      the existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dirfuns_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dirfuns_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dirfuns

% Last Modified by GUIDE v2.5 02-Jun-2016 13:45:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dirfuns_OpeningFcn, ...
                   'gui_OutputFcn',  @dirfuns_OutputFcn, ...
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

% --- Executes just before dirfuns is made visible.
function dirfuns_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dirfuns (see VARARGIN)

% Choose default command line output for dirfuns
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

initialize_gui(hObject, handles, false);

% UIWAIT makes dirfuns wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = dirfuns_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function density_CreateFcn(hObject, eventdata, handles)
% hObject    handle to density (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function density_Callback(hObject, eventdata, handles)
handles.working_dir = get(hObject, 'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function volume_CreateFcn(hObject, eventdata, handles)


function volume_Callback(hObject, eventdata, handles)


% --- Executes on button press in remove_spaces_folder.
function remove_spaces_folder_Callback(hObject, eventdata, handles)
% hObject    handle to remove_spaces_folder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
args = {handles.working_dir, '_'};
Recurse_Folders(args, 'Remove_Space');

% --- Executes on button press in remove_spaces_files.
function remove_spaces_files_Callback(hObject, eventdata, handles)
% hObject    handle to remove_spaces_files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
args = {handles.working_dir, '_'};
Recurse_Files(args, 'Remove_Space');

% --- Executes on button press in reset.
function reset_Callback(hObject, eventdata, handles)
% hObject    handle to reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

initialize_gui(gcbf, handles, true);

% --- Executes when selected object changed in unitgroup.
function unitgroup_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in unitgroup 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (hObject == handles.english)
    set(handles.text4, 'String', 'lb/cu.in');
    set(handles.text5, 'String', 'cu.in');
    set(handles.text6, 'String', 'lb');
else
    set(handles.text4, 'String', 'kg/cu.m');
    set(handles.text5, 'String', 'cu.m');
    set(handles.text6, 'String', 'kg');
end

% --------------------------------------------------------------------
function initialize_gui(fig_handle, handles, isreset)
% If the metricdata field is present and the reset flag is false, it means
% we are we are just re-initializing a GUI by calling it from the cmd line
% while it is up. So, bail out as we dont want to reset the data.


% --- Executes on button press in rename.
function rename_Callback(hObject, eventdata, handles)
% hObject    handle to rename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(ischar(handles.rename) && ischar(handles.rename_to))  
    args = {handles.working_dir, ...
            handles.rename, ...
            handles.rename_to};
        Recurse_Folders(args, 'Rename_File');
else 
    disp('Enter a string to replace and a string to replace it with');
end


function to_replace_Callback(hObject, eventdata, handles)
% hObject    handle to to_replace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of to_replace as text
%        str2double(get(hObject,'String')) returns contents of to_replace as a double
handles.rename = get(hObject, 'String');
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function to_replace_CreateFcn(hObject, eventdata, handles)
% hObject    handle to to_replace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function replace_with_Callback(hObject, eventdata, handles)
% hObject    handle to replace_with (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of replace_with as text
%        str2double(get(hObject,'String')) returns contents of replace_with as a double
handles.rename_to = get(hObject, 'String');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function replace_with_CreateFcn(hObject, eventdata, handles)
% hObject    handle to replace_with (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rename_files.
function rename_files_Callback(hObject, eventdata, handles)
% hObject    handle to rename_files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(ischar(handles.rename_files) && ischar(handles.rename_files_to))  
    args = {handles.working_dir, ...
            handles.rename_files, ...
            handles.rename_files_to};
        Recurse_Files(args, 'Rename_File');
else 
    disp('Enter a string to replace and a string to replace it with');
end



function replace_file_name_Callback(hObject, eventdata, handles)
% hObject    handle to replace_file_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of replace_file_name as text
%        str2double(get(hObject,'String')) returns contents of replace_file_name as a double
handles.rename_files = get(hObject, 'String');
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function replace_file_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to replace_file_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rename_file_to_Callback(hObject, eventdata, handles)
% hObject    handle to rename_file_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rename_file_to as text
%        str2double(get(hObject,'String')) returns contents of rename_file_to as a double
handles.rename_files_to = get(hObject, 'String');
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function rename_file_to_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rename_file_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in movefiles.
function movefiles_Callback(hObject, eventdata, handles)
% hObject    handle to movefiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(ischar(handles.Move_Files_with_name) && ischar(handles.Move_To_File)) 
    args = {handles.working_dir, handles.Move_To_File, handles.Move_Files_with_name};
    Recurse_Files(args, 'Move_Files');
else
    disp('Enter a pattern to match and a folder to move it to');
end




function Move_Files_with_name_Callback(hObject, eventdata, handles)
% hObject    handle to Move_Files_with_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Move_Files_with_name as text
%        str2double(get(hObject,'String')) returns contents of Move_Files_with_name as a double
    handles.Move_Files_with_name = get(hObject, 'String');
    guidata(hObject,handles);




% --- Executes during object creation, after setting all properties.
function Move_Files_with_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Move_Files_with_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Move_To_File_Callback(hObject, eventdata, handles)
% hObject    handle to Move_To_File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Move_To_File as text
%        str2double(get(hObject,'String')) returns contents of Move_To_File as a double
    handles.Move_To_File  = get(hObject, 'String');
    guidata(hObject,handles);
    



% --- Executes during object creation, after setting all properties.
function Move_To_File_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Move_To_File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in movefolders.
function movefolders_Callback(hObject, eventdata, handles)
% hObject    handle to movefolders (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(ischar(handles.Move_Folder_with_name) && ischar(handles.Move_To_Folder)) 
    args = {handles.working_dir, handles.Move_To_Folder, handles.Move_Folder_with_name};
    Recurse_Folders(args, 'Move_Files');
else
    disp('Enter a pattern to match and a folder to move it to');
end



function Move_Folders_with_name_Callback(hObject, eventdata, handles)
% hObject    handle to Move_Folders_with_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Move_Folders_with_name as text
%        str2double(get(hObject,'String')) returns contents of Move_Folders_with_name as a double
    handles.Move_Folder_with_name = get(hObject, 'String');
    guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function Move_Folders_with_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Move_Folders_with_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Move_to_Folder_Callback(hObject, eventdata, handles)
% hObject    handle to Move_to_Folder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Move_to_Folder as text
%        str2double(get(hObject,'String')) returns contents of Move_to_Folder as a double
    handles.Move_To_Folder  = get(hObject, 'String');
    guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function Move_to_Folder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Move_to_Folder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function run_folder_name_Callback(hObject, eventdata, handles)
% hObject    handle to run_folder_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of run_folder_name as text
%        str2double(get(hObject,'String')) returns contents of run_folder_name as a double
handles.run_folder_name = get(hobject, 'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function run_folder_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to run_folder_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in setPwd.
function setPwd_Callback(hObject, eventdata, handles)
% hObject    handle to setPwd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.working_dir = pwd;
    set(handles.density, 'String', pwd);
    guidata(hObject, handles);
