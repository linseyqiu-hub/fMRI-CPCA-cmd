function varargout = flip_components(varargin)
% FLIP_COMPONENTS MATLAB code for flip_components.fig
%      FLIP_COMPONENTS, by itself, creates a new FLIP_COMPONENTS or raises the existing
%      singleton*.
%
%      H = FLIP_COMPONENTS returns the handle to a new FLIP_COMPONENTS or the handle to
%      the existing singleton*.
%
%      FLIP_COMPONENTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FLIP_COMPONENTS.M with the given input arguments.
%
%      FLIP_COMPONENTS('Property','Value',...) creates a new FLIP_COMPONENTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before flip_components_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to flip_components_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% return selected list - button ( 0 = cancel, 1 = ok 

% Edit the above text to modify the response to help flip_components

% Last Modified by GUIDE v2.5 27-Jun-2013 13:29:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @flip_components_OpeningFcn, ...
                   'gui_OutputFcn',  @flip_components_OutputFcn, ...
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


% --- Executes just before flip_components is made visible.
function flip_components_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to flip_components (see VARARGIN)

% Choose default command line output for flip_components
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes flip_components wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = flip_components_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in lst_components.
function lst_components_Callback(hObject, eventdata, handles)
% hObject    handle to lst_components (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lst_components contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lst_components


% --- Executes during object creation, after setting all properties.
function lst_components_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_components (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_select.
function btn_select_Callback(hObject, eventdata, handles)
% hObject    handle to btn_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in btn_okay.
function btn_okay_Callback(hObject, eventdata, handles)
% hObject    handle to btn_okay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in btn_cancel.
function btn_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to btn_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
