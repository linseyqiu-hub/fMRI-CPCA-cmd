function varargout = create_h(varargin)
% CREATE_H MATLAB code for create_h.fig
%      CREATE_H, by itself, creates a new CREATE_H or raises the existing
%      singleton*.
%
%      H = CREATE_H returns the handle to a new CREATE_H or the handle to
%      the existing singleton*.
%
%      CREATE_H('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CREATE_H.M with the given input arguments.
%
%      CREATE_H('Property','Value',...) creates a new CREATE_H or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before create_h_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to create_h_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help create_h

% Last Modified by GUIDE v2.5 30-May-2019 14:55:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @create_h_OpeningFcn, ...
                   'gui_OutputFcn',  @create_h_OutputFcn, ...
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


% --- Executes just before create_h is made visible.
function create_h_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to create_h (see VARARGIN)

global Zheader scan_information

% Choose default command line output for create_h
handles.output = hObject;

hh = structure_define( 'HHEADER' );
handles.Hstruc = hh.model;
handles.valid_H = 0;
handles.num_voxels = Zheader.total_columns * max(1, scan_information.frequencies);
handles.num_subjects = Zheader.num_subjects;

% Update handles structure
guidata(hObject, handles);

handles = check_valid_H( handles );

% Update handles structure
guidata(hObject, handles);
  
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes create_h wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = create_h_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
  varargout{1} = handles.output;
  guidata(handles.figure1, handles);
  delete(handles.figure1);


% --- Executes on button press in btn_Components.
function btn_Components_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Components (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[components,path] = uigetfile('*.img;*.nii;*.hdr','MultiSelect','on');
if ischar(components)
    components = cellstr(components);
end
s = size(components);
for i = 1:s(2)
    components(i) = fullfile(path,components(i));
end
txt = size(components);
txt = txt(2);
if txt == 1
    txt = sprintf('%d file', txt);
else
    txt = sprintf('%d files', txt);
end
set(handles.txt_num_files,'string',txt);
handles.components = components;
guidata(hObject,handles);
 


% --- Executes on button press in btn_Mask.
function btn_Mask_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[mask,path] = uigetfile('*.img');
set(handles.txt_mask,'string',mask);
set(handles.txt_mask,'Visible','on');
mask = fullfile(path,mask);
handles.mask = mask;
guidata(hObject,handles);


% --- Executes on button press in btn_Cancel.
function btn_Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  handles.output = '';
  guidata(hObject, handles);
  uiresume(handles.figure1);


% --- Executes on button press in btn_Okay.
function btn_Okay_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Okay (see GCBO)
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


function handles = check_valid_H( handles )

 handles.valid_H = 0;
 hcount = 0;
 handles.Hstruc.size = [0 0];

 if isempty( handles.Hstruc.path )  
     return
 end	% --- minimum requirement

 if isempty( handles.Hstruc.file ) |  isempty( handles.Hstruc.var )  
   return; 
 end 

 x = matfile_vars( handles.Hstruc.path, handles.Hstruc.file, handles.Hstruc.var );
 if ~isempty(x)
     handles.valid_H = x.sz_x == handles.num_voxels | x.sz_y == handles.num_voxels;
 end
 
% --- Executes on button press in chk_constant.
function chk_constant_Callback(hObject, eventdata, handles)
% hObject    handle to chk_constant (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_constant


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.output = '';
  guidata(handles.figure1, handles);
  uiresume(handles.figure1);

