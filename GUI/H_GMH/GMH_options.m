function varargout = GMH_options(varargin)
% GMH_OPTIONS M-file for GMH_options.fig
%      GMH_OPTIONS, by itself, creates a new GMH_OPTIONS or raises the existing
%      singleton*.
%
%      H = GMH_OPTIONS returns the handle to a new GMH_OPTIONS or the handle to
%      the existing singleton*.
%
%      GMH_OPTIONS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GMH_OPTIONS.M with the given input arguments.
%
%      GMH_OPTIONS('Property','Value',...) creates a new GMH_OPTIONS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GMH_options_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GMH_options_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GMH_options

% Last Modified by GUIDE v2.5 18-Jan-2013 09:14:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GMH_options_OpeningFcn, ...
                   'gui_OutputFcn',  @GMH_options_OutputFcn, ...
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


% --- Executes just before GMH_options is made visible.
function GMH_options_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GMH_options (see VARARGIN)

% Choose default command line output for GMH_options
global Zheader 

  handles.state = [{'off'} {'on'}];
  handles.txt.used = 'Current Disk Usage: ';
  handles.txt.extra = 'Additional Disk Space: ';
  handles.txt.mem = 'Mb';

  handles.values = constant_define( 'GMH_OPTIONS' );

  if(nargin > 3)
    for index = 1:2:(nargin-3),
      if nargin-3==index, break, end
        switch lower(varargin{index})
         case 'vals'
          handles.values = varargin{index+1};

      end
    end
  end

  handles.output = hObject;
%  set( handles.chk_overwrite_existing, 'Enable', char(handles.state(handles.values.ow_flag + 1) ) );

% -- bypass BH and E for now
%  set( handles.chk_process_BH, 'Enable', 'off' );
  set( handles.chk_process_E,  'Enable', 'on' );

  gw = Zheader.Model.mat_y;
  hw = Zheader.Limits.mat_y;
  zd = Zheader.total_scans;
  zw = Zheader.total_columns * Zheader.num_Z_arrays;

  handles.dsk_used = 0;
  dsk_extra = 0;

  if handles.values.exists.ZH
    x = array_sizes( [zd hw ] );
    handles.dsk_used = handles.dsk_used + x.megabytes;    
  end

  if handles.values.exists.Qg
    x = array_sizes( [zd zd ] );
    handles.dsk_used = handles.dsk_used + x.megabytes;    
  end

  if handles.values.exists.Qh
    x = array_sizes( [zw zw ] );
    handles.dsk_used = handles.dsk_used + x.megabytes;    
  end

  if handles.values.exists.GMH
    x = array_sizes( [zd zw ] );
    handles.dsk_used = handles.dsk_used + x.megabytes;    
  end

  if handles.values.exists.BH
    x = array_sizes( [zd zw ] );
    handles.dsk_used = handles.dsk_used + x.megabytes;    
  end

  if handles.values.exists.GC
    x = array_sizes( [zd zw ] );
    handles.dsk_used = handles.dsk_used + x.megabytes;    
  end

  if handles.values.exists.E
    x = array_sizes( [zd zw ] );
    handles.dsk_used = handles.dsk_used + x.megabytes;    
  end

  if handles.dsk_used > 1024 
    handles.dsk_used = handles.dsk_used / 1024;
    handles.txt.mem = 'Gb';
  end

  str = sprintf( [ handles.txt.used '%.2f' handles.txt.mem ], handles.dsk_used );
  set( handles.lbl_current, 'String', str );

  % Update handles structure
  guidata(handles.figure1, handles);

  drawnow();

  update_controls( handles );

% UIWAIT makes GMH_options wait for user response (see UIRESUME)
 uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GMH_options_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.values;
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

  handles.values = [];
  guidata(handles.figure1, handles);
  uiresume(handles.figure1);



% --------------------------------------------
% --- User selection of apply button 
% --------------------------------------------

% --- Executes on button press in chk_process_GMH.
function chk_process_GMH_Callback(hObject, eventdata, handles)
% hObject    handle to chk_process_GMH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.values.GMH.apply = get(hObject,'Value');
  % Update handles structure
  guidata(handles.figure1, handles);
 
  update_controls( handles );
  


% --- Executes on button press in chk_process_BH.
function chk_process_BH_Callback(hObject, eventdata, handles)
% hObject    handle to chk_process_BH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.values.BH.apply = get(hObject,'Value');

  % Update handles structure
  guidata(handles.figure1, handles);

  update_controls( handles );
  


% --- Executes on button press in chk_process_E.
function chk_process_E_Callback(hObject, eventdata, handles)
% hObject    handle to chk_process_E (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.values.E.apply = get(hObject,'Value');

  % Update handles structure
  guidata(handles.figure1, handles);

  update_controls( handles );



% --- Executes on button press in chk_process_GC.
function chk_process_GC_Callback(hObject, eventdata, handles)
% hObject    handle to chk_process_GC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.values.GC.apply = get(hObject,'Value');

  % Update handles structure
  guidata(handles.figure1, handles);

  update_controls( handles );
  

% --------------------------------------------
% --- User selection of regress button 
% --------------------------------------------

% --- Executes on button press in chk_regress_GMH.
function chk_regress_GMH_Callback(hObject, eventdata, handles)
% hObject    handle to chk_regress_GMH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.values.GMH.regress = get(hObject,'Value');

  % Update handles structure
  guidata(handles.figure1, handles);
  update_controls( handles );
  


% --- Executes on button press in chk_regress_BH.
function chk_regress_BH_Callback(hObject, eventdata, handles)
% hObject    handle to chk_regress_BH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.values.BH.regress = get(hObject,'Value');

  if handles.values.BH.regress

    if ~handles.values.exists.ZH
      handles.values.vars.ZH = handles.values.BH.regress;
    end

    if ~handles.values.exists.Qg
      handles.values.vars.Qg = handles.values.BH.regress;
    end

  else

    handles.values.vars.ZH = 0;
    handles.values.vars.Qg = 0;
  end

  % Update handles structure
  guidata(handles.figure1, handles);

  update_controls( handles );


% --- Executes on button press in chk_regress_GC.
function chk_regress_GC_Callback(hObject, eventdata, handles)
% hObject    handle to chk_regress_GC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.values.GC.regress = get(hObject,'Value');
  if handles.values.GC.regress
    if ~handles.values.exists.Qh
      handles.values.vars.Qh = handles.values.GC.regress;
    end
  else
    handles.values.vars.Qh = 0;
  end

  % Update handles structure
  guidata(handles.figure1, handles);

  update_controls( handles );


% --------------------------------------------
% --- User selection of predefined variable button 
% --------------------------------------------

% --- Executes on button press in chk_require_M.
function chk_require_M_Callback(hObject, eventdata, handles)
% hObject    handle to chk_require_M (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in chk_require_ZH.
function chk_require_ZH_Callback(hObject, eventdata, handles)
% hObject    handle to chk_require_ZH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.values.vars.ZH = get(hObject,'Value');

  % Update handles structure
  guidata(handles.figure1, handles);

  update_controls( handles );



% --- Executes on button press in chk_require_Qg.
function chk_require_Qg_Callback(hObject, eventdata, handles)
% hObject    handle to chk_require_Qg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.values.vars.Qg = get(hObject,'Value');

  % Update handles structure
  guidata(handles.figure1, handles);

  update_controls( handles );



% --- Executes on button press in chk_require_Qh.
function chk_require_Qh_Callback(hObject, eventdata, handles)
% hObject    handle to chk_require_Qh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.values.vars.Qh = get(hObject,'Value');

  % Update handles structure
  guidata(handles.figure1, handles);

  update_controls( handles );


% --- Executes on button press in chk_create_E.
function chk_create_E_Callback(hObject, eventdata, handles)
% hObject    handle to chk_create_E (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  x = get(hObject,'Value');
  handles.values.E.write = x;
  if (x)
    handles.values.GMH.write = x;
    handles.values.BH.write = x;
    handles.values.GC.write = x;
  
    handles.values.vars.ZH = x;
    handles.values.vars.Qg = x;

    handles.values.overwrite = x;
  end;

  % Update handles structure
  guidata(handles.figure1, handles);

  update_controls( handles );
  


% --------------------------------------------
% --- User selection of extract button 
% --------------------------------------------


% --- Executes on button press in chk_extract_GMH.
function chk_extract_GMH_Callback(hObject, eventdata, handles)
% hObject    handle to chk_extract_GMH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.values.GMH.extract = get(hObject,'Value');
  % Update handles structure
  guidata(handles.figure1, handles);

  update_controls( handles );
 

% --- Executes on button press in chk_extract_BH.
function chk_extract_BH_Callback(hObject, eventdata, handles)
% hObject    handle to chk_extract_BH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.values.BH.extract = get(hObject,'Value');
  % Update handles structure
  guidata(handles.figure1, handles);

  update_controls( handles );
 


% --- Executes on button press in chk_extract_GC.
function chk_extract_GC_Callback(hObject, eventdata, handles)
% hObject    handle to chk_extract_GC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.values.GC.extract = get(hObject,'Value');
  % Update handles structure
  guidata(handles.figure1, handles);

  update_controls( handles );
 

% --------------------------------------------
% --- User selection of rotate button 
% --------------------------------------------

% --- Executes on button press in chk_rotate_GMH.
function chk_rotate_GMH_Callback(hObject, eventdata, handles)
% hObject    handle to chk_rotate_GMH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.values.GMH.rotate = get(hObject,'Value');
  % Update handles structure
  guidata(handles.figure1, handles);

  update_controls( handles );


% --- Executes on button press in chk_rotate_BH.
function chk_rotate_BH_Callback(hObject, eventdata, handles)
% hObject    handle to chk_rotate_BH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%  handles.values.BH.rotate = get(hObject,'Value');
%  % Update handles structure
%  guidata(handles.figure1, handles);
%
%  update_controls( handles );


% --- Executes on button press in chk_rotate_GC.
function chk_rotate_GC_Callback(hObject, eventdata, handles)
% hObject    handle to chk_rotate_GC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.values.GC.rotate = get(hObject,'Value');
  % Update handles structure
  guidata(handles.figure1, handles);

  update_controls( handles );


% --------------------------------------------
% --- User selection of rotation settings button 
% --------------------------------------------

% --- Executes on button press in btn_rotation_settings_GMH.
function btn_rotation_settings_GMH_Callback(hObject, eventdata, handles)
% hObject    handle to btn_rotation_settings_GMH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  sett = handles.values.GMH.rotation;
  
  x = Rotation_Settings( 'Setting', sett, 'Title', 'GMH Rotation Settings', 'Model', 'GMH', 'hrfmax', 1 );

  if ( isnumeric(x) )
    handles.values.GMH.rotation = [];
  else
    if (~ isempty( x ))
      handles.values.GMH.rotation = x;
    end
  end
  % Update handles structure
  guidata(handles.figure1, handles);



% --- Executes on button press in btn_rotation_settings_BH.
function btn_rotation_settings_BH_Callback(hObject, eventdata, handles)
% hObject    handle to btn_rotation_settings_BH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%  sett = handles.values.BH.rotation;
%  
%  x = Rotation_Settings( 'Setting', sett, 'Title', 'BH Rotation Settings', 'Model', 'BH', 'hrfmax', 1 );
%
%  if ( isnumeric(x) )
%    handles.values.BH.rotation = [];
%  else
%    if (~ isempty( x ))
%      handles.values.BH.rotation = x;
%    end
%  end
%  % Update handles structure
%  guidata(handles.figure1, handles);


% --- Executes on button press in btn_rotation_settings_GC.
function btn_rotation_settings_GC_Callback(hObject, eventdata, handles)
% hObject    handle to btn_rotation_settings_GC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  sett = handles.values.GC.rotation;
  
  x = Rotation_Settings( 'Setting', sett, 'Title', 'GC Rotation Settings', 'Model', 'GC', 'hrfmax', 1 );

  if ( isnumeric(x) )
    handles.values.GC.rotation = [];
  else
    if (~ isempty( x ))
      handles.values.GC.rotation = x;
    end
  end
  % Update handles structure
  guidata(handles.figure1, handles);


% --------------------------------------------
% --- User selection of components entry 
% --------------------------------------------

function txt_components_GMH_Callback(hObject, eventdata, handles)
% hObject    handle to txt_components_GMH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Zheader

  str = get(hObject,'String');
  str = validate_numeric_vector( str );
  set(hObject,'String', str );

  numcomps = '';
  eval( ['numcomps = [' str '];' ] );
  numcomps = min( Zheader.Limits.mat_y, numcomps );

  % --- GMH extraction cannot exceed the width of the H model
  if size( numcomps,2 ) > 0 
    thesecomps = [];
    for ii = 1:size( numcomps,2 )
      if numcomps(ii) <= Zheader.Limits.mat_y
        thesecomps = [thesecomps numcomps(ii)];
      end;
    end;
    numcomps = thesecomps;
  end;

  handles.values.GMH.components = numcomps;
  % Update handles structure
  guidata(handles.figure1, handles);

  update_controls( handles );



% --- Executes on key press with focus on txt_components_GMH and none of its controls.
function txt_components_GMH_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to txt_components_GMH (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

  k = eventdata.Key;

  if ( strcmp( k, 'return' ) )
    drawnow();				% force text input box update with current value
  end;

  txt_components_GMH_Callback( hObject, 0, handles );




function txt_components_BH_Callback(hObject, eventdata, handles)
% hObject    handle to txt_components_BH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Zheader

  str = get(hObject,'String');
  str = validate_numeric_vector( str );
  set(hObject,'String', str );

  numcomps = '';
  eval( ['numcomps = [' str '];' ] );
  numcomps = min( Zheader.Limits.mat_y, numcomps );

  handles.values.BH.components = numcomps;
  % Update handles structure
  guidata(handles.figure1, handles);

  update_controls( handles );




% --- Executes on key press with focus on txt_components_BH and none of its controls.
function txt_components_BH_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to txt_components_BH (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

  k = eventdata.Key;

  if ( strcmp( k, 'return' ) )
    drawnow();				% force text input box update with current value
  end;

  txt_components_BH_Callback( hObject, 0, handles );


function txt_components_GC_Callback(hObject, eventdata, handles)
% hObject    handle to txt_components_GC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  str = get(hObject,'String');
  str = validate_numeric_vector( str );
  set(hObject,'String', str );

  numcomps = '';
  eval( ['numcomps = [' str '];' ] );

  handles.values.GC.components = numcomps;
  % Update handles structure
  guidata(handles.figure1, handles);

  update_controls( handles );


% --- Executes on key press with focus on txt_components_GC and none of its controls.
function txt_components_GC_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to txt_components_GC (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

  k = eventdata.Key;

  if ( strcmp( k, 'return' ) )
    drawnow();				% force text input box update with current value
  end;

  txt_components_GC_Callback( hObject, 0, handles );



% --------------------------------------------
% --- User selection of full matrix create entry 
% --------------------------------------------

% --- Executes on button press in chk_create_GMH.
function chk_create_GMH_Callback(hObject, eventdata, handles)
% hObject    handle to chk_create_GMH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.values.GMH.write = get(hObject,'Value');
  % Update handles structure
  guidata(handles.figure1, handles);

  update_controls( handles );


% --- Executes on button press in chk_create_BH.
function chk_create_BH_Callback(hObject, eventdata, handles)
% hObject    handle to chk_create_BH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.values.BH.write = get(hObject,'Value');
  % Update handles structure
  guidata(handles.figure1, handles);

  update_controls( handles );


% --- Executes on button press in chk_create_GC.
function chk_create_GC_Callback(hObject, eventdata, handles)
% hObject    handle to chk_create_GC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.values.GC.write = get(hObject,'Value');
  % Update handles structure
  guidata(handles.figure1, handles);

  update_controls( handles );




% --- Executes on button press in chk_overwrite_existing.
function chk_overwrite_existing_Callback(hObject, eventdata, handles)
% hObject    handle to chk_overwrite_existing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.values.overwrite = get(hObject,'Value');

  % Update handles structure
  guidata(handles.figure1, handles);

  update_controls( handles );



% -------------------------------------------
% --- update all control states 
% -------------------------------------------

function update_controls( handles )
global Zheader

  colors = [constant_define( 'COLOR_GREY'); constant_define( 'COLOR_GREEN' ) ];
  textcolors = [0.8 0.8 0.8; 0.0 0.0 0.0];

  state = [{'off'} {'on'} ];

  % --- GMH controls 

  set( handles.chk_process_GMH, 'Value', handles.values.GMH.apply );
  set( handles.chk_process_GMH, 'BackgroundColor', colors(handles.values.GMH.apply + 1,:) );
  
  set( handles.chk_regress_GMH, 'Value', handles.values.GMH.regress & handles.values.GMH.apply );
  set( handles.chk_regress_GMH, 'Enable', char(state(handles.values.GMH.apply + 1 ) )  );


  set( handles.chk_extract_GMH, 'Value', handles.values.GMH.extract & handles.values.GMH.apply );
  set( handles.chk_extract_GMH, 'Enable', char(state(handles.values.GMH.apply + 1 ) )  );

  str = '';
  if ~isempty( handles.values.GMH.components )
    for ii = 1:size(handles.values.GMH.components,2)
      str = [str ' ' num2str(handles.values.GMH.components(ii))]; 
    end
    str = validate_numeric_vector( str );
  end;
  set( handles.txt_components_GMH, 'String', str );
  set( handles.txt_components_GMH, 'Enable', char(state(handles.values.GMH.apply + 1 ) )  );
  set( handles.lbl_numcomp_gmh, 'ForegroundColor', textcolors(handles.values.GMH.apply + 1,:) );

  set( handles.chk_rotate_GMH, 'Value', handles.values.GMH.rotate & handles.values.GMH.apply );
  set( handles.chk_rotate_GMH, 'Enable', char(state(handles.values.GMH.apply + 1 ) )  );
%  set( handles.chk_rotate_GMH, 'Enable', 'off' );

  set( handles.btn_rotation_settings_GMH, 'Enable', char(state(handles.values.GMH.apply + 1 ) )  );
%  set( handles.btn_rotation_settings_GMH, 'Enable', 'off'  );

  set( handles.chk_create_GMH, 'Enable', char(state(handles.values.GMH.apply + 1 ) )  );
  set( handles.chk_create_GMH, 'Value', handles.values.GMH.write & handles.values.GMH.apply );



  % --- BH controls 

  set( handles.chk_process_BH, 'Value', handles.values.BH.apply );
  set( handles.chk_process_BH, 'BackgroundColor', colors(handles.values.BH.apply + 1,:) );
  
  set( handles.chk_regress_BH, 'Value', handles.values.BH.regress & handles.values.BH.apply );
  set( handles.chk_regress_BH, 'Enable', char(state(handles.values.BH.apply + 1 ) )  );

%   if ~handles.values.exists.ZH
%     handles.values.vars.ZH = 1 * handles.values.BH.apply;
%     % Update handles structure
%     guidata(handles.figure1, handles);
%   end;
  set( handles.chk_require_ZH, 'Value', handles.values.vars.ZH);
    set( handles.chk_require_ZH, 'Enable', char(state(handles.values.BH.apply + 1 ) )  );

  if ~handles.values.exists.Qg
    handles.values.vars.Qg = handles.values.BH.apply;
    % Update handles structure
    guidata(handles.figure1, handles);
  end;
  set( handles.chk_require_Qg, 'Value', handles.values.vars.Qg );
    set( handles.chk_require_Qg, 'Enable', char(state(handles.values.BH.apply + 1 ) )  );

  set( handles.chk_extract_BH, 'Value', handles.values.BH.extract & handles.values.BH.apply );
  set( handles.chk_extract_BH, 'Enable', char(state(handles.values.BH.apply + 1 ) )  );

  str = '';
  if ~isempty( handles.values.BH.components )
    for ii = 1:size(handles.values.BH.components,2)
      str = [str ' ' num2str(handles.values.BH.components(ii))]; 
    end
    str = validate_numeric_vector( str );
  end;
  set( handles.txt_components_BH, 'String', str );
  set( handles.txt_components_BH, 'Enable', char(state(handles.values.BH.apply + 1 ) )  );
  set( handles.lbl_numcomp_bh, 'ForegroundColor', textcolors(handles.values.BH.apply + 1,:) );

%  set( handles.chk_rotate_BH, 'Value', handles.values.BH.rotate & handles.values.BH.apply );
%  set( handles.chk_rotate_BH, 'Enable', char(state(handles.values.BH.apply + 1 ) )  );
  set( handles.chk_rotate_BH, 'Enable', 'off' );

%  set( handles.btn_rotation_settings_BH, 'Enable', char(state(handles.values.BH.apply + 1 ) )  );
  set( handles.btn_rotation_settings_BH, 'Enable', 'off'  );
  set( handles.chk_create_BH, 'Enable', char(state(handles.values.BH.apply + 1 ) )  );

  set( handles.chk_create_BH, 'Value', handles.values.BH.write & handles.values.BH.apply );



  % --- GC controls 

  set( handles.chk_process_GC, 'Value', handles.values.GC.apply );
  set( handles.chk_process_GC, 'BackgroundColor', colors(handles.values.GC.apply + 1,:) );
  
  set( handles.chk_regress_GC, 'Value', handles.values.GC.regress & handles.values.GC.apply );
  set( handles.chk_regress_GC, 'Enable', char(state(handles.values.GC.apply + 1 ) )  );

  if ~handles.values.exists.Qh
    handles.values.vars.Qh = handles.values.GC.apply;
    % Update handles structure
    guidata(handles.figure1, handles);
  end

  set( handles.chk_extract_GC, 'Value', handles.values.GC.extract & handles.values.GC.apply );
  set( handles.chk_extract_GC, 'Enable', char(state(handles.values.GC.apply + 1 ) )  );

  str = '';
  if ~isempty( handles.values.GC.components )
    for ii = 1:size(handles.values.GC.components,2)
      str = [str ' ' num2str(handles.values.GC.components(ii))]; 
    end
    str = validate_numeric_vector( str );
  end
  set( handles.txt_components_GC, 'String', str );
  set( handles.txt_components_GC, 'Enable', char(state(handles.values.GC.apply + 1 ) )  );
  set( handles.lbl_numcomp_gc, 'ForegroundColor', textcolors(handles.values.GC.apply + 1,:) );

  set( handles.chk_rotate_GC, 'Value', handles.values.GC.rotate & handles.values.GC.apply );
  set( handles.chk_rotate_GC, 'Enable', char(state(handles.values.GC.apply + 1 ) )  );
%  set( handles.chk_rotate_GC, 'Enable', 'off' );

  set( handles.btn_rotation_settings_GC, 'Enable', char(state(handles.values.GC.apply + 1 ) )  );
%  set( handles.btn_rotation_settings_GC, 'Enable', 'off' );

  set( handles.chk_create_GC, 'Enable', char(state(handles.values.GC.apply + 1 ) )  );
  set( handles.chk_create_GC, 'Value', handles.values.GC.write & handles.values.GC.apply );

  % --- E controls 

  set( handles.chk_process_E, 'Value', handles.values.E.apply );
  set( handles.chk_process_E, 'BackgroundColor', colors(handles.values.E.apply + 1,:) );

  set( handles.chk_create_E, 'Enable', char(state(handles.values.E.apply + 1 ) )  );
  set( handles.chk_create_E, 'Value', handles.values.E.write & handles.values.E.apply );


  set( handles.chk_overwrite_existing, 'Value', handles.values.overwrite );

  dsk_used = 0;
  mem_size = 'Mb';

  gw = Zheader.Model.mat_y;
  hw = Zheader.Limits.mat_y;
  zd = Zheader.total_scans;
  zw = Zheader.total_columns * Zheader.num_Z_arrays;


  if ~handles.values.exists.ZH & handles.values.vars.ZH
    x = array_sizes( [zd hw ] );
    dsk_used = dsk_used + x.megabytes;    
  end

  if ~handles.values.exists.Qg & handles.values.vars.Qg
    x = array_sizes( [zd zd ] );
    dsk_used = dsk_used + x.megabytes;    
  end

  if ~handles.values.exists.Qh & handles.values.vars.Qh 
    x = array_sizes( [zw zw ] );
    dsk_used = dsk_used + x.megabytes;    
  end

  if ~handles.values.exists.GMH & handles.values.GMH.write
    x = array_sizes( [zd zw ] );
    dsk_used = dsk_used + x.megabytes;    
  end

  if ~handles.values.exists.BH & handles.values.BH.write
    x = array_sizes( [zd zw ] );
    dsk_used = dsk_used + x.megabytes;    
  end

  if ~handles.values.exists.GC & handles.values.GC.write
    x = array_sizes( [zd zw ] );
    dsk_used = dsk_used + x.megabytes;    
  end

  if ~handles.values.exists.E & handles.values.E.write
    x = array_sizes( [zd zw ] );
    dsk_used = dsk_used + x.megabytes;    
  end

  if dsk_used > 1024 
    dsk_used = dsk_used / 1024;
    mem_size = 'Gb';
  end

  str = sprintf( [ handles.txt.extra '%.2f' mem_size ], dsk_used );
  set( handles.lbl_additional, 'String', str );

  drawnow();

  


% --- Executes on button press in btn_okay.
function btn_okay_Callback(hObject, eventdata, handles)
% hObject    handle to btn_okay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

 uiresume(handles.figure1);


% --- Executes on button press in btn_Cancel.
function btn_Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.values = [];
  guidata(handles.figure1, handles);
  uiresume(handles.figure1);







% --- Executes during object creation, after setting all properties.
function txt_components_GMH_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_components_GMH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function txt_components_BH_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_components_BH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function txt_components_GC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_components_GC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes during object deletion, before destroying properties.
function chk_overwrite_existing_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to chk_overwrite_existing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
