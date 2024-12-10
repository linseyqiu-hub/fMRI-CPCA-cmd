function varargout = Images_From_Results(varargin)
% IMAGES_FROM_RESULTS M-file for Images_From_Results.fig
%      IMAGES_FROM_RESULTS, by itself, creates a new IMAGES_FROM_RESULTS or raises the existing
%      singleton*.
%
%      H = IMAGES_FROM_RESULTS returns the handle to a new IMAGES_FROM_RESULTS or the handle to
%      the existing singleton*.
%
%      IMAGES_FROM_RESULTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMAGES_FROM_RESULTS.M with the given input arguments.
%
%      IMAGES_FROM_RESULTS('Property','Value',...) creates a new IMAGES_FROM_RESULTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Images_From_Results_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Images_From_Results_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Images_From_Results

% Last Modified by GUIDE v2.5 13-Oct-2011 14:40:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Images_From_Results_OpeningFcn, ...
                   'gui_OutputFcn',  @Images_From_Results_OutputFcn, ...
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


% --- Executes just before Images_From_Results is made visible.
function Images_From_Results_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Images_From_Results (see VARARGIN)

  % Choose default command line output for Images_From_Results
  handles.Zheader = [];

  if(nargin > 3)
    for index = 1:2:(nargin-3),
      if nargin-3==index, break, end
        switch lower(varargin{index})
         case 'zheader'
          handles.Zheader = varargin{index+1};
      end
    end
  end

  if ispc
    handles.dirchar = '\';
  else
    handles.dirchar = '/';
  end;

  eval( [ 'load( ''' handles.Zheader.Model.path ''', ''Gheader'');' ] );
  Gpath = Gheader.GZheader.path_to_segs;

  Normalized_Z_Dir = Z_Directory();
  Hpath = [ Normalized_Z_Dir 'Hsegs' handles.dirchar ];

  handles.state = [{'off'} {'on'}];

  handles.output = [];
  handles.output.selected_matrix = [ 0 0 0 0 0; 0 0 0 0 0];
  handles.output.selected_variable = [ ...
    { [ Gpath '|G|GE' ] } ...
    { [ Hpath 'HZ' handles.dirchar '|HZ|E' ] } ...
    { [ Hpath 'HE' handles.dirchar '|HE|E' ] } ...
    { [ Hpath 'GMH' handles.dirchar '|GMH|GMH' ] } ...
    { [ Hpath 'GMH' handles.dirchar '|GMH|E' ] }; ...
    { [ Gpath '|G|GC' ] } ... 
    { [ Hpath 'HZ' handles.dirchar '|HZ|HB' ] } ...
    { [ Hpath 'HE' handles.dirchar '|HE|HB' ] } ...
    { [ Hpath 'GMH' handles.dirchar '|GMH|GC' ] } ... 
    { [ Hpath 'GMH' handles.dirchar '|GMH|BH' ] } ];

  handles.output.base_directory = [ pwd handles.dirchar 'results_as_scans'];
                 % ---   G  HZ  HE  GMH
                 % --- [ E  E   E   GMH E ] 
                 % --- [ C  B   B   GC  B ] 
  handles.enabling_matrix = [0 0 0 0 0; 0 0 0 0 0];

  % Update handles structure
  handles.enabling_matrix = detect_available_variables( handles.Zheader );

  guidata(hObject, handles);

  set( handles.chk_image_GE, 'Enable', char(handles.state( handles.enabling_matrix(1,1)+1 ) ) );
  set( handles.chk_image_GC, 'Enable', char(handles.state( handles.enabling_matrix(2,1)+1 ) ) );
  set( handles.chk_image_GE, 'Value', handles.output.selected_matrix(1,1) );
  set( handles.chk_image_GC, 'Value', handles.output.selected_matrix(2,1) );

  set( handles.chk_image_HZE, 'Enable', char(handles.state( handles.enabling_matrix(1,2)+1 ) ) );
  set( handles.chk_image_HZB, 'Enable', char(handles.state( handles.enabling_matrix(2,2)+1 ) ) );
  set( handles.chk_image_HZE, 'Value', handles.output.selected_matrix(1,2) );
  set( handles.chk_image_HZB, 'Value', handles.output.selected_matrix(2,2) );

  set( handles.chk_image_HEE, 'Enable', char(handles.state( handles.enabling_matrix(1,3)+1 ) ) );
  set( handles.chk_image_HEB, 'Enable', char(handles.state( handles.enabling_matrix(2,3)+1 ) ) );
  set( handles.chk_image_HEE, 'Value', handles.output.selected_matrix(1,3) );
  set( handles.chk_image_HEB, 'Value', handles.output.selected_matrix(2,3) );

  set( handles.chk_image_GMHGMH, 'Enable', char(handles.state( handles.enabling_matrix(1,4)+1 ) ) );
  set( handles.chk_image_GMHGC, 'Enable', char(handles.state( handles.enabling_matrix(2,4)+1 ) ) );
  set( handles.chk_image_GMHE, 'Enable', char(handles.state( handles.enabling_matrix(1,5)+1 ) ) );
  set( handles.chk_image_GMBH, 'Enable', char(handles.state( handles.enabling_matrix(2,5)+1 ) ) );

  set( handles.chk_image_GMHGMH, 'Value', handles.output.selected_matrix(1,4) );
  set( handles.chk_image_GMHGC, 'Value', handles.output.selected_matrix(2,4) );
  set( handles.chk_image_GMHE, 'Value', handles.output.selected_matrix(1,5) );
  set( handles.chk_image_GMBH, 'Value', handles.output.selected_matrix(2,5) );

%  sz = 8;
%  txt = short_path( handles.output.base_directory, sz );
%  while ( length(txt) > 80 )
%    sz = sz - 1;
%    txt = short_path( handles.output.base_directory, sz );
% end;
%
%  set( handles.txt_base_directory, 'String', txt );
  set( handles.txt_base_directory, 'String', handles.output.base_directory );
 
  % UIWAIT makes Images_From_Results wait for user response (see UIRESUME)
  uiwait(handles.figure1);



% --- Outputs from this function are returned to the command line.
function varargout = Images_From_Results_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
delete(handles.figure1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.output = [];
  guidata(handles.figure1, handles);
  uiresume(handles.figure1);



% --- Executes on button press in chk_choose_output_directory.
function chk_choose_output_directory_Callback(hObject, eventdata, handles)
% hObject    handle to chk_choose_output_directory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  thisdir = get( handles.txt_base_directory, 'String' );
  dirname = uigetdir(thisdir, 'Select the root directory of your subject scan data');

  if ~isequal( dirname, 0)
    set( handles.txt_base_directory, 'String', dirname );

    handles.output.base_directory = dirname;
    guidata(handles.figure1, handles);
  end;
  

function txt_base_directory_Callback(hObject, eventdata, handles)
% hObject    handle to txt_base_directory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_base_directory as text
%        str2double(get(hObject,'String')) returns contents of txt_base_directory as a double


% --- Executes during object creation, after setting all properties.
function txt_base_directory_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_base_directory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_okay.
function btn_okay_Callback(hObject, eventdata, handles)
% hObject    handle to btn_okay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  uiresume(handles.figure1);


% --- Executes on button press in btn_cancel.
function btn_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to btn_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.output = [];
  guidata(handles.figure1, handles);
  uiresume(handles.figure1);


% --- Executes on button press in chk_image_GE.
function chk_image_GE_Callback(hObject, eventdata, handles)
% hObject    handle to chk_image_GE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.output.selected_matrix(1,1) = get( handles.chk_image_GE, 'Value');
  guidata(handles.figure1, handles);


% --- Executes on button press in chk_image_GC.
function chk_image_GC_Callback(hObject, eventdata, handles)
% hObject    handle to chk_image_GC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.output.selected_matrix(2,1) = get(handles.chk_image_GC, 'Value') ;
  guidata(handles.figure1, handles);



% --- Executes on button press in chk_image_HZE.
function chk_image_HZE_Callback(hObject, eventdata, handles)
% hObject    handle to chk_image_HZE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.output.selected_matrix(1,2) = get(handles.chk_image_HZE, 'Value') ;
  guidata(handles.figure1, handles);


% --- Executes on button press in chk_image_HZB.
function chk_image_HZB_Callback(hObject, eventdata, handles)
% hObject    handle to chk_image_HZB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.output.selected_matrix(2,2) = get(handles.chk_image_HZB, 'Value');
  guidata(handles.figure1, handles);


% --- Executes on button press in chk_image_HEE.
function chk_image_HEE_Callback(hObject, eventdata, handles)
% hObject    handle to chk_image_HEE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.output.selected_matrix(1,3) = get(handles.chk_image_HEE, 'Value');
  guidata(handles.figure1, handles);


% --- Executes on button press in chk_image_HEB.
function chk_image_HEB_Callback(hObject, eventdata, handles)
% hObject    handle to chk_image_HEB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.output.selected_matrix(2,3) = get(handles.chk_image_HEB, 'Value');
  guidata(handles.figure1, handles);

% --- Executes on button press in chk_image_GMHGMH.
function chk_image_GMHGMH_Callback(hObject, eventdata, handles)
% hObject    handle to chk_image_GMHGMH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.output.selected_matrix(1,4) = get(handles.chk_image_GMHGMH, 'Value');
  guidata(handles.figure1, handles);


% --- Executes on button press in chk_image_GMHGC.
function chk_image_GMHGC_Callback(hObject, eventdata, handles)
% hObject    handle to chk_image_GMHGC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.output.selected_matrix(2,4) = get(handles.chk_image_GMHGC, 'Value');
  guidata(handles.figure1, handles);


% --- Executes on button press in chk_image_GMHE.
function chk_image_GMHE_Callback(hObject, eventdata, handles)
% hObject    handle to chk_image_GMHE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.output.selected_matrix(1,5) = get(handles.chk_image_GMHE, 'Value');
  guidata(handles.figure1, handles);


% --- Executes on button press in chk_image_GMBH.
function chk_image_GMBH_Callback(hObject, eventdata, handles)
% hObject    handle to chk_image_GMBH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.output.selected_matrix(2,5) = get(handles.chk_image_GMBH, 'Value');
  guidata(handles.figure1, handles);


function mtx = detect_available_variables( Zh )

% ---   G  HZ  HE  GMH
% --- [ E  E   E   E ] 
% --- [ C  B   B   B ] 
  
  mtx = [0 0 0 0; 0 0 0 0];

  if ispc
    dirchar = '\';
  else
    dirchar = '/';
  end;

  Normalized_Z_Dir = Z_Directory();

  if ~isempty( Zh.Model.path )
    eval( [ 'load( ''' Zh.Model.path ''', ''Gheader'');' ] );

    if ~isempty( Gheader.GZheader ) 
      x = exist( Gheader.GZheader.path_to_segs, 'dir' );
      if ( x == 7 )

        d = dir( [Gheader.GZheader.path_to_segs 'GE_S*'] );
        mtx(1,1) = size(d,1) == Zh.num_subjects;

        d = dir( [Gheader.GZheader.path_to_segs 'GC_S*'] );
        mtx(2,1) = size(d,1) == Zh.num_subjects;

        d = dir( [Normalized_Z_Dir 'Hsegs' dirchar 'HZ' dirchar 'HZ_S*'] );
        mtx(1,2) = size(d,1) == Zh.num_subjects;

        d = dir( [Normalized_Z_Dir 'Hsegs' dirchar 'HZ' dirchar 'HB_S*'] );
        mtx(2,2) = size(d,1) == Zh.num_subjects;

        d = dir( [Normalized_Z_Dir 'Hsegs' dirchar 'HE' dirchar 'HE_S*'] );
        mtx(1,3) = size(d,1) == Zh.num_subjects;

        d = dir( [Normalized_Z_Dir 'Hsegs' dirchar 'HE' dirchar 'HB_S*'] );
        mtx(2,3) = size(d,1) == Zh.num_subjects;

% --- GMH variables not run/frequency specific yet
        d = dir( [Normalized_Z_Dir 'Hsegs' dirchar 'GMH' dirchar 'GMH_S*'] );
        mtx(1,4) = size(d,1) == Zh.num_subjects;

        d = dir( [Normalized_Z_Dir 'Hsegs' dirchar 'GMH' dirchar 'GC_S*'] );
        mtx(2,4) = size(d,1) == Zh.num_subjects;

        d = dir( [Normalized_Z_Dir 'Hsegs' dirchar 'GMH' dirchar 'E_S*'] );
        mtx(1,5) = size(d,1) == Zh.num_subjects;

        d = dir( [Normalized_Z_Dir 'Hsegs' dirchar 'GMH' dirchar 'BH_S*'] );
        mtx(2,5) = size(d,1) == Zh.num_subjects;

      end;

    end;

  end;



