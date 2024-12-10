function varargout = select_components(varargin)
% SELECT_COMPONENTS MATLAB code for select_components.fig
%      SELECT_COMPONENTS, by itself, creates a new SELECT_COMPONENTS or raises the existing
%      singleton*.
%
%      H = SELECT_COMPONENTS returns the handle to a new SELECT_COMPONENTS or the handle to
%      the existing singleton*.
%
%      SELECT_COMPONENTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELECT_COMPONENTS.M with the given input arguments.
%
%      SELECT_COMPONENTS('Property','Value',...) creates a new SELECT_COMPONENTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before select_components_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to select_components_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% return selected list - button ( 0 = cancel, 1 = ok 

% Edit the above text to modify the response to help select_components

% Last Modified by GUIDE v2.5 27-Jun-2013 13:51:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @select_components_OpeningFcn, ...
                   'gui_OutputFcn',  @select_components_OutputFcn, ...
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


% --- Executes just before select_components is made visible.
function select_components_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to select_components (see VARARGIN)

% Choose default command line output for select_components
handles.output = hObject;

  if(nargin > 3)
    for index = 1:2:(nargin-3),
        if nargin-3==index, break, end
        switch lower(varargin{index})
         case 'list'
          handles.numcomps = varargin{index+1};
          handles.list = [];

          for ii = 1:handles.numcomps
            handles.list = [handles.list {num2str(ii)}];
          end;

         case 'select'
          handles.select = varargin{index+1};
%          handles.select = str2num(str);
        end
    end
  end
  
  set( handles.lst_components, 'String', handles.list, 'Value', handles.select );
  
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes select_components wait for user response (see UIRESUME)
  uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = select_components_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.v;
varargout{2} = handles.s;
delete(handles.figure1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.v = [];
  handles.s = [];
  guidata(handles.figure1, handles);
  uiresume(handles.figure1);


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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
 handles.select = [1:handles.numcomps];
 guidata(hObject, handles);

 set( handles.lst_components, 'Value', handles.select );
 drawnow();
 
% --- Executes on button press in btn_okay.
function btn_okay_Callback(hObject, eventdata, handles)
% hObject    handle to btn_okay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.v = get( handles.lst_components, 'Value' );
  handles.s = 1;
  guidata(hObject, handles);
  uiresume(handles.figure1);

% --- Executes on button press in btn_cancel.
function btn_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to btn_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.v = [];
  handles.s = 0;
  guidata(hObject, handles);
  uiresume(handles.figure1);

