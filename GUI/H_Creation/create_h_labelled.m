function varargout = create_h_labelled(varargin)
% CREATE_H_LABELLED MATLAB code for create_h_labelled.fig
%      CREATE_H_LABELLED, by itself, creates a new CREATE_H_LABELLED or raises the existing
%      singleton*.
%
%      H = CREATE_H_LABELLED returns the handle to a new CREATE_H_LABELLED or the handle to
%      the existing singleton*.
%
%      CREATE_H_LABELLED('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CREATE_H_LABELLED.M with the given input arguments.
%
%      CREATE_H_LABELLED('Property','Value',...) creates a new CREATE_H_LABELLED or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before create_h_labelled_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to create_h_labelled_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help create_h_labelled

% Last Modified by GUIDE v2.5 06-Jun-2019 15:07:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @create_h_labelled_OpeningFcn, ...
                   'gui_OutputFcn',  @create_h_labelled_OutputFcn, ...
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


% --- Executes just before create_h_labelled is made visible.
function create_h_labelled_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to create_h_labelled (see VARARGIN)

% global Zheader scan_information
% 
% % Choose default command line output for create_h
handles.output = hObject;
% 
% hh = structure_define( 'HHEADER' );
% handles.Hstruc = hh.model;
% handles.valid_H = 0;
% handles.num_voxels = Zheader.total_columns * max(1, scan_information.frequencies);
% handles.num_subjects = Zheader.num_subjects;
% 
% handles = check_valid_H( handles );
% 
% % Update handles structure
guidata(hObject, handles)

% UIWAIT makes create_h_labelled wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = create_h_labelled_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
  varargout{1} = handles.output;
  guidata(handles.figure1, handles);
  delete(handles.figure1);



function edit_network_Callback(hObject, eventdata, handles)
% hObject    handle to edit_network (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.label = get(hObject,'String');
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of edit_network as text
%        str2double(get(hObject,'String')) returns contents of edit_network as a double


% --- Executes during object creation, after setting all properties.
function edit_network_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_network (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_files.
function btn_files_Callback(hObject, eventdata, handles)
% hObject    handle to btn_files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[component,path] = uigetfile('*.img;*.nii;*.hdr');
component = fullfile(path,component);
if ~isfield(handles, 'components')
    handles.components = [];
end
num = length(handles.components) + 1;
set(handles.edit_network,'string',['Component ' num2str(num)]);
handles.curr = component;
guidata(hObject,handles);


% --- Executes on selection change in lst_networks.
function lst_networks_Callback(hObject, eventdata, handles)
% hObject    handle to lst_networks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lst_networks contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lst_networks


% --- Executes during object creation, after setting all properties.
function lst_networks_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_networks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_add.
function btn_add_Callback(hObject, eventdata, handles)
% hObject    handle to btn_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);
if ~isfield(handles, 'label')
    handles.label = "";
end
handles.curr = path to file
handles.label = given component label


% --- Executes on button press in btn_createh.
function btn_createh_Callback(hObject, eventdata, handles)
% hObject    handle to btn_createh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);

if isfield(data, 'components') && isfield(data, 'mask')

    fit_to_mask(data.components, data.mask);
    handles.Hstruc.path = [pwd filesep];
    handles.Hstruc.file = 'H.mat';
    handles.Hstruc.var = 'H';

    if (get(handles.chk_constant, 'Value'))
        H = load([handles.Hstruc.path handles.Hstruc.file], handles.Hstruc.var);
        H = H.(handles.Hstruc.var);
        x = size(H);
        if(x(1) == handles.num_voxels && ~(sum(H(:,1)) == handles.num_voxels))
            H = [ones(x(1), 1) H];
            eval([handles.Hstruc.var, ' = H;']);
            save([handles.Hstruc.path handles.Hstruc.file], handles.Hstruc.var, '-append');
        elseif(x(2) == handles.num_voxels && ~(sum(H(1,:)) == handles.num_voxels))
            H = [ones(1, x(2)); H];
            eval([handles.Hstruc.var, ' = H;']);
            save([handles.Hstruc.path handles.Hstruc.file], handles.Hstruc.var, '-append');
        else
            disp('WARNING: H may already have constant');
        end
    end
            
    handles = check_valid_H( handles );
    handles.Hstruc.size = size(H);

    if handles.valid_H
        handles.output = handles.Hstruc;
        guidata(hObject, handles);
        uiresume(handles.figure1);
    else
        set(handles.txt_msg, 'String', 'Invalid H matrix produced. Please select new components');
    end

elseif isfield(data, 'components')
	set(handles.txt_msg, 'String', 'Please select mask file');
elseif isfield(data, 'mask')
	set(handles.txt_msg, 'String', 'Please select component file(s)');
else
    set(handles.txt_msg, 'String', 'Please select component and mask files');
end


% --- Executes on button press in btn_cancel.
function btn_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to btn_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  handles.output = '';
  guidata(hObject, handles);
  uiresume(handles.figure1);


% --- Executes on button press in btn_mask.
function btn_mask_Callback(hObject, eventdata, handles)
% hObject    handle to btn_mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[mask,path] = uigetfile('*.img');
set(handles.txt_mask,'string',mask);
set(handles.txt_mask,'Visible','on');
mask = fullfile(path,mask);
handles.mask = mask;
guidata(hObject,handles);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.output = '';
  guidata(handles.figure1, handles);
  uiresume(handles.figure1);


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
