function varargout = array_memory_usage(varargin)
% ARRAY_MEMORY_USAGE MATLAB code for array_memory_usage.fig
%      ARRAY_MEMORY_USAGE, by itself, creates a new ARRAY_MEMORY_USAGE or raises the existing
%      singleton*.
%
%      H = ARRAY_MEMORY_USAGE returns the handle to a new ARRAY_MEMORY_USAGE or the handle to
%      the existing singleton*.
%
%      ARRAY_MEMORY_USAGE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ARRAY_MEMORY_USAGE.M with the given input arguments.
%
%      ARRAY_MEMORY_USAGE('Property','Value',...) creates a new ARRAY_MEMORY_USAGE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before array_memory_usage_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to array_memory_usage_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help array_memory_usage

% Last Modified by GUIDE v2.5 10-Mar-2014 15:18:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @array_memory_usage_OpeningFcn, ...
                   'gui_OutputFcn',  @array_memory_usage_OutputFcn, ...
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


% --- Executes just before array_memory_usage is made visible.
function array_memory_usage_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to array_memory_usage (see VARARGIN)

% Choose default command line output for array_memory_usage
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes array_memory_usage wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = array_memory_usage_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function txt_rows_Callback(hObject, eventdata, handles)
% hObject    handle to txt_rows (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_rows as text
%        str2double(get(hObject,'String')) returns contents of txt_rows as a double


% --- Executes during object creation, after setting all properties.
function txt_rows_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_rows (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_cols_Callback(hObject, eventdata, handles)
% hObject    handle to txt_cols (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_cols as text
%        str2double(get(hObject,'String')) returns contents of txt_cols as a double


% --- Executes during object creation, after setting all properties.
function txt_cols_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_cols (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_calc.
function btn_calc_Callback(hObject, eventdata, handles)
  x = str2double(get(handles.txt_rows,'String'));
  y = str2double(get(handles.txt_cols,'String'));

  if x > 0 & y > 0
    res = array_sizes( [ x y ] );
    str = [ ...
         {['     bytes: ' num2str( res.bytes )]};, ...
         {[' kilobytes: ' num2str( res.kilobytes, '%.2f' ) ]};, ...
         {[' megabytes: ' num2str( res.megabytes, '%.2f' ) ]};, ...
         {[' gigabytes: ' num2str( res.gigabytes, '%.2f' ) ]};, ...
         {['terrabytes: ' num2str( res.gigabytes, '%.2f' ) ]};, ...
         {['    memory: ' strtrim(res.mem_display) ]} ];

    show_message( ['Memory usage for array' strtrim( res.sz_display ) ], str );
    
  end
      
