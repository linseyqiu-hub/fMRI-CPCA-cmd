function varargout = G_Regression_Resumption(varargin)
% G_REGRESSION_RESUMPTION MATLAB code for G_Regression_Resumption.fig
%      G_REGRESSION_RESUMPTION, by itself, creates a new G_REGRESSION_RESUMPTION or raises the existing
%      singleton*.
%
%      H = G_REGRESSION_RESUMPTION returns the handle to a new G_REGRESSION_RESUMPTION or the handle to
%      the existing singleton*.
%
%      G_REGRESSION_RESUMPTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in G_REGRESSION_RESUMPTION.M with the given input arguments.
%
%      G_REGRESSION_RESUMPTION('Property','Value',...) creates a new G_REGRESSION_RESUMPTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before G_Regression_Resumption_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to G_Regression_Resumption_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help G_Regression_Resumption

% Last Modified by GUIDE v2.5 11-Jun-2013 12:02:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @G_Regression_Resumption_OpeningFcn, ...
                   'gui_OutputFcn',  @G_Regression_Resumption_OutputFcn, ...
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


% --- Executes just before G_Regression_Resumption is made visible.
function G_Regression_Resumption_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to G_Regression_Resumption (see VARARGIN)

  % Choose default command line output for G_Regression_Resumption
  handles.output = hObject;

  handles.subjects = 0;
  handles.settings = struct( ...
	'resume', 0, ...    	      	      % flag to process from last successfull subject GZ/C creation
	'last_subject', 0, ...    	      % last subject number successfully created for GZ and C
    'CC', 0, ...			      % full C * C' array successfuly created
    'Eigs', 0 );		      % Eigenvalues of C * C' array successfuly calculated

  handles.preserve = handles.settings;
  
  % --- set text of multi participant selector
  if(nargin > 3)
    for index = 1:2:(nargin-3),
      if nargin-3==index, break, end
        switch lower(varargin{index})
         case 'settings'
          handles.settings = varargin{index+1};
          handles.preserve= varargin{index+1};
         case 'subjects'
          handles.subjects = varargin{index+1};
      end
    end
  end

  lst = [];
  if handles.subjects
    for ii = 1:handles.subjects 
      str = sprintf( '%3s ', num2str(ii) );
      id = subject_id( ii );
      lst = [lst; {[ str ' (' id ')']} ];
    end
  end;
  set( handles.lst_subjects, 'String', lst, 'Value', 1 );

  if ~isempty(handles.settings.Reprocess) 
    set( handles.lst_subjects, 'Value', handles.settings.Reprocess );
  else
    set( handles.lst_subjects, 'Value', [] );
  end;
  
  set( handles.txt_last_subject, 'String', num2str( handles.settings.last_subject ) );
  set( handles.txt_subject_count, 'String', [ ' of ' num2str(handles.subjects ) ] );

  set( handles.chk_recreate_CC, 'Value', handles.settings.CC == 0 );
  set( handles.chk_recalulate_eigenvalues, 'Value', ... 
          handles.settings.Eigs == 0 || handles.settings.CC == 0);
  
  % Update handles structure
  guidata(hObject, handles);

  % UIWAIT makes G_Regression_Resumption wait for user response (see UIRESUME)
  uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = G_Regression_Resumption_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
delete(handles.figure1);


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
  handles.output = [];
  guidata(handles.figure1, handles);
  uiresume(handles.figure1);


function txt_last_subject_Callback(hObject, eventdata, handles)
% hObject    handle to txt_last_subject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_last_subject as text
%        str2double(get(hObject,'String')) returns contents of txt_last_subject as a double


% --- Executes during object creation, after setting all properties.
function txt_last_subject_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_last_subject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in lst_subjects.
function lst_subjects_Callback(hObject, eventdata, handles)
% hObject    handle to lst_subjects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lst_subjects contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lst_subjects


% --- Executes during object creation, after setting all properties.
function lst_subjects_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_subjects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_clear_selection.
function btn_clear_selection_Callback(hObject, eventdata, handles)
% hObject    handle to btn_clear_selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

 set( handles.lst_subjects, 'Value', [] );

  handles.settings.CC = handles.preserve.CC;
  handles.settings.Eigs = handles.preserve.Eigs;
  handles.settings.Reprocess = [];
  guidata(handles.figure1, handles);

  set( handles.lst_subjects, 'Value', [] );
  set( handles.chk_recreate_CC, 'Value', handles.settings.CC == 0 );
  set( handles.chk_recalulate_eigenvalues, 'Value', ... 
          handles.settings.Eigs == 0 || handles.settings.CC == 0);
 


% --- Executes on button press in btn_Okay.
function btn_Okay_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Okay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  x = get(handles.lst_subjects, 'Value' );
  if size(x, 2) > 0
    handles.settings.Reprocess = x;
    handles.settings.CC = 0;
    handles.settings.Eigs = 0;
  else
    handles.settings.Reprocess = [];
    handles.settings.CC = ~get(handles.chk_recreate_CC, 'Value');
    handles.settings.Eigs = ~get(handles.chk_recalulate_eigenvalues, 'Value');;
  end;
  
  handles.settings.last_subject = str2num( get( handles.txt_last_subject, 'String' ) );
  
  handles.output = handles.settings;
  guidata(handles.figure1, handles);
  uiresume(handles.figure1);


% --- Executes on button press in ctn_Cancel.
function ctn_Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to ctn_Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  handles.output = [];
  guidata(handles.figure1, handles);
  uiresume(handles.figure1);


% --- Executes on button press in chk_recalulate_eigenvalues.
function chk_recalulate_eigenvalues_Callback(hObject, eventdata, handles)
% hObject    handle to chk_recalulate_eigenvalues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.settings.Eigs = ~get( hObject, 'Value' );
  guidata(handles.figure1, handles);

  set( handles.chk_recreate_CC, 'Value', handles.settings.CC == 0 );
  set( handles.chk_recalulate_eigenvalues, 'Value', ... 
          handles.settings.Eigs == 0 || handles.settings.CC == 0);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over lst_subjects.
function lst_subjects_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to lst_subjects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.settings.CC = 0;
  handles.settings.Eigs = 0;
  guidata(handles.figure1, handles);

  set( handles.chk_recreate_CC, 'Value', handles.settings.CC == 0 );
  set( handles.chk_recalulate_eigenvalues, 'Value', ... 
          handles.settings.Eigs == 0 || handles.settings.CC == 0);
