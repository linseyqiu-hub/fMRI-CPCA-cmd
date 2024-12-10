function varargout = label_coords(varargin)
% LABEL_COORDS MATLAB code for label_coords.fig
%      LABEL_COORDS, by itself, creates a new LABEL_COORDS or raises the existing
%      singleton*.
%
%      H = LABEL_COORDS returns the handle to a new LABEL_COORDS or the handle to
%      the existing singleton*.
%
%      LABEL_COORDS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LABEL_COORDS.M with the given input arguments.
%
%      LABEL_COORDS('Property','Value',...) creates a new LABEL_COORDS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before label_coords_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to label_coords_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help label_coords

% Last Modified by GUIDE v2.5 29-May-2019 12:25:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @label_coords_OpeningFcn, ...
                   'gui_OutputFcn',  @label_coords_OutputFcn, ...
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
end


% --- Executes just before label_coords is made visible.
function label_coords_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to label_coords (see VARARGIN)

% Choose default command line output for label_coords
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes label_coords wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end


% --- Outputs from this function are returned to the command line.
function varargout = label_coords_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end


% --- Executes on button press in btn_coordinate_files.
function btn_coordinate_files_Callback(hObject, eventdata, handles)
% hObject    handle to btn_coordinate_files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

coordfiles = uigetfile('*.txt','MultiSelect','on');
if ischar(coordfiles)
    coordfiles = cellstr(coordfiles);
end
txt = size(coordfiles);
txt = txt(2);
if txt == 1
    txt = sprintf('%d file', txt);
else
    txt = sprintf('%d files', txt);
end
set(handles.txt_num_files,'string',txt);
handles.coordfiles = coordfiles;
guidata(hObject,handles);
end 


% --- Executes on button press in btn_atlases.
function btn_atlases_Callback(hObject, eventdata, handles)
% hObject    handle to btn_atlases (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

atlasfile = uigetfile('*.txt');
set(handles.txt_atlas_file,'string',atlasfile);
set(handles.txt_atlas_file,'Visible','on');
handles.atlasfile = atlasfile;
guidata(hObject,handles);
end


% --- Executes on button press in btn_cancel.
function btn_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to btn_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
closereq;
end


% --- Executes on button press in btn_okay.
function btn_okay_Callback(hObject, eventdata, handles)
% hObject    handle to btn_okay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);

if isfield(data, 'coordfiles') && isfield(data, 'atlasfile')
    mni_to_label(data.coordfiles, data.atlasfile);
    closereq;
elseif isfield(data, 'coordfiles')
	errordlg('Please select atlas file');
elseif isfield(data, 'atlasfile')
	errordlg('Please select coordinate file(s)');
else
    errordlg('Please select files');
end
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over btn_coordinate_files.
function btn_coordinate_files_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to btn_coordinate_files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end
