function varargout = load_hrfmax_state_query(varargin)
% LOAD_HRFMAX_STATE_QUERY MATLAB code for load_hrfmax_state_query.fig
%      LOAD_HRFMAX_STATE_QUERY, by itself, creates a new LOAD_HRFMAX_STATE_QUERY or raises the existing
%      singleton*.
%
%      H = LOAD_HRFMAX_STATE_QUERY returns the handle to a new LOAD_HRFMAX_STATE_QUERY or the handle to
%      the existing singleton*.
%
%      LOAD_HRFMAX_STATE_QUERY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOAD_HRFMAX_STATE_QUERY.M with the given input arguments.
%
%      LOAD_HRFMAX_STATE_QUERY('Property','Value',...) creates a new LOAD_HRFMAX_STATE_QUERY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before load_hrfmax_state_query_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to load_hrfmax_state_query_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help load_hrfmax_state_query

% Last Modified by GUIDE v2.5 03-Sep-2013 14:08:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @load_hrfmax_state_query_OpeningFcn, ...
                   'gui_OutputFcn',  @load_hrfmax_state_query_OutputFcn, ...
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


% --- Executes just before load_hrfmax_state_query is made visible.
function load_hrfmax_state_query_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to load_hrfmax_state_query (see VARARGIN)

% Choose default command line output for load_hrfmax_state_query
handles.output = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes load_hrfmax_state_query wait for user response (see UIRESUME)
 uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = load_hrfmax_state_query_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

varargout{1} = handles.output;
delete(handles.figure1);

% --- Executes on button press in btn_Okay.
function btn_Okay_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Okay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  handles.output = 1;
  guidata(hObject, handles);
  uiresume(handles.figure1);


% --- Executes on button press in btn_Cancel.
function btn_Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  handles.output = 0;
  guidata(hObject, handles);
  uiresume(handles.figure1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.output = 0;
  guidata(hObject, handles);
  uiresume(handles.figure1);
  

