function varargout = Rotation_Settings(varargin)
% ROTATION_SETTINGS M-file for Rotation_Settings.fig
%      ROTATION_SETTINGS, by itself, creates a new ROTATION_SETTINGS or raises the existing
%      singleton*.
%
%      H = ROTATION_SETTINGS returns the handle to a new ROTATION_SETTINGS or the handle to
%      the existing singleton*.
%
%      ROTATION_SETTINGS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ROTATION_SETTINGS.M with the given input arguments.
%
%      ROTATION_SETTINGS('Property','Value',...) creates a new ROTATION_SETTINGS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Rotation_Settings_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Rotation_Settings_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Rotation_Settings

% Last Modified by GUIDE v2.5 27-Jun-2012 15:35:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Rotation_Settings_OpeningFcn, ...
                   'gui_OutputFcn',  @Rotation_Settings_OutputFcn, ...
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


% --- Executes just before Rotation_Settings is made visible.
function Rotation_Settings_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Rotation_Settings (see VARARGIN)
global Zheader scan_information 

  handles.setting = [];
  handles.model = '';
  handles.use_hrfmax = 1;

  if(nargin > 3)
    for index = 1:2:(nargin-3),
        if nargin-3==index, break, end
        switch lower(varargin{index})
         case 'title'
          set(hObject, 'Name', varargin{index+1});
         case 'setting'
          handles.this_setting = varargin{index+1};
         case 'model'
          handles.model = varargin{index+1};
         case 'hrfmax'
          handles.use_hrfmax = varargin{index+1};
        end
    end
  end

  str = '';

  set( handles.chk_alt_UR, 'Visible', 'off' );
  set( handles.chk_alt_UR, 'Value', 0 );

  if ~isempty( Zheader.Limits.path )
    load( Zheader.Limits.path );
    H = load_H_matrix( Hheader );
%    if ~isfield( Hheader, 'isRotatable' )
      isRotatable = ~any( sum(H') == 0 );
%    end;
  else
    isRotatable = 1;
  end;

  lst = [];
  rotations = define_rotations();
  x = size(rotations,1);
  this_value = 0;
  if isempty(handles.this_setting)
    handles.this_setting = rotations(1);
  end;
  
%  if ( ~isempty(handles.this_setting) )
    jj = 0;
    for ii = 1:size(rotations,1)
      if ( strcmp(handles.model,'G') )
        lst = [lst {char(rotations(ii).description)} ];
        if ( strcmp( char(handles.this_setting(1).description), char(rotations(ii).description) ) ) this_value = ii;  end;
      else
        if strcmp(handles.model,'GMH') || strcmp(handles.model,'GC')
         
          if ( strcmp(handles.model,'GC') )   % --- make sure the H is actually rotatable in other forms
            if rotations(ii).parameters.HRF || isRotatable
              lst = [lst {char(rotations(ii).description)} ];
            end;

          else           % --- hrfmax only on GMH
            if rotations(ii).parameters.HRF
              lst = [lst {char(rotations(ii).description)} ];
            end;
          end;
          
        end
     end;
    end;

  handles.states = [{'off'} {'on'}];

  set ( handles.lst_method, 'String',lst, 'Value', max(1,this_value) );

  set ( handles.txt_ofn, 'String', handles.this_setting(1).defaults.text );
  
  handles.shapefile = handles.this_setting(1).defaults.hrf_file;
  handles.new_setting = handles.this_setting(1);
  handles.isDirty = 0;

  lst = [];
  for ( ii = 1:size(handles.this_setting,1) )

    if ( handles.model ~= 'G' )
      if ( ~strcmp( char(handles.this_setting(1).description), 'hrfmax' ) )

        handles.new_setting = handles.this_setting(ii);
        guidata(handles.figure1, handles);

        if ( this_value )		% if there are saved rotations passed here, then update list
          str = create_default_filename( handles );
          lst = [lst {str} ];
        end;

      end;

    else

%      if ( ~strcmp( char(handles.this_setting(1).description), 'hrfmax' ) )
        handles.new_setting = handles.this_setting(ii);
        guidata(handles.figure1, handles);

        if ( this_value )		% if there are saved rotations passed here, then update list
          str = create_default_filename( handles );
          lst = [lst {str} ];
        end;
%      end
     
    end
    
  end;
  set ( handles.lst_active_rotations, 'String', lst, 'Value', 1 );

  num_entries = size(lst, 1);
  if ( num_entries > 0 ) state = 'on'; else state = 'off'; end;

  handles.new_setting = handles.this_setting(1);
  handles.new_setting.defaults.reltol = sqrt(eps);
  handles.isDirty = 0;

  set( handles.btn_delete_from_list, 'Enable', state );
  set( handles.btn_update_list, 'Enable', char(handles.states(handles.isDirty+1))  );


  if ( ~isempty( handles.new_setting.defaults.T_mat ) )
    set( handles.chk_Use_T, 'Value', 1 );
    show_T_matrix( handles, handles.new_setting.defaults.T_mat );
    set( handles.chk_load_state_file, 'Value', 0 );
    handles.new_setting.parameters.load_state = 0;
  end;

  if exist( './hrfmax_state.mat', 'file' )
    set( handles.chk_load_state_file, 'Enable', 'on' );
    set( handles.chk_load_state_file, 'Value', handles.new_setting.parameters.load_state );
%    set( handles.chk_Use_T, 'Visible', 'off' );
  else
    set( handles.chk_load_state_file, 'Enable', 'off' );
    set( handles.chk_load_state_file, 'Value', 0 );
    handles.new_setting.parameters.load_state = 0;
%    set( handles.chk_Use_T, 'Visible', 'on' );
  end;


  if ( ismac )
    set( handles.txt_power, 'HorizontalAlignment', 'center' );
    pos = get(handles.txt_power, 'Position' );
    set( handles.txt_power, 'Position', [pos(1) pos(2) pos(3) 1.75] );

    set( handles.txt_gamma, 'HorizontalAlignment', 'center' );
    pos = get(handles.txt_gamma, 'Position' );
    set( handles.txt_gamma, 'Position', [pos(1) pos(2) pos(3) 1.75] );

    set( handles.txt_iterations, 'HorizontalAlignment', 'center' );
    pos = get(handles.txt_iterations, 'Position' );
    set( handles.txt_iterations, 'Position', [pos(1) pos(2) pos(3) 1.75] );

  end
  

  % Choose default command line output for Rotation_Settings
  handles.output = hObject;

  % Update handles structure
  guidata(hObject, handles);

  update_controls( hObject, 0, handles );

  % UIWAIT makes Rotation_Settings wait for user response (see UIRESUME)
  uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Rotation_Settings_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
delete(handles.figure1);


% --- Executes on selection change in lst_method.
function lst_method_Callback(hObject, eventdata, handles)
% hObject    handle to lst_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  contents = get(hObject,'String');
  this_method = contents{get(hObject,'Value')};

  rotations = define_rotations();

  x = size(rotations,1);
  if ( ~isempty(this_method) )
    for ii = 1:x 
      if ( strcmp( char(this_method), char(rotations(ii).description) ) ) handles.new_setting = rotations(ii); end;
    end;
  end

  handles.new_setting.defaults.reltol = sqrt(eps);
  handles.isDirty = 1;

  % Update handles structure
  guidata(hObject, handles);

  update_controls( hObject, 0, handles );


% --- Executes during object creation, after setting all properties.
function lst_method_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function this_index = locate_method( handles, this_method )

  contents = get(handles.lst_method,'String');
  x = size(contents,1);

  this_index = 0;

  if ( ~isempty(this_method) )
    for ii = 1:x 
      if ( strcmp( char(this_method), char(contents(ii)) ) ) this_index = ii; end;
    end;
  end


% --- Executes on button press in btn_hrf_shapes.
function btn_hrf_shapes_Callback(hObject, eventdata, handles)
% hObject    handle to btn_hrf_shapes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Zheader

  varname = '';
  good_shapes = 0;

  fullpath = select_file( {'*.mat','MATLAB .mat files'}, ...
                                   'Select your shapes file');
  if ~isempty( fullpath )

    mat_vars = matfile_vars( '', fullpath );
    [mf_x mf_y] = size( mat_vars );

    if ( mf_x > 0 )    % there are variables in the file
      if ( mf_x == 1 )   % only a single variable in the file

        varname = mat_vars(1).name;

      else

        eval( ['load( ''' fullpath ''', ''shapes'' )' ] );
        if exist( 'shapes', 'var' )
          varname = 'shapes';
        else        

          % get user selection of mat in file to use as Z
          lst = '';
          for ii=1:mf_x
            lst = horzcat( lst, {mat_vars(ii).name});
          end

          x = mat_selection( lst, 'Select your shapes variable' );
          if ( x > 0 )
            varname = mat_vars(x).name;
          end;

        end;  % -- shapes variable loaded

      end;  % more than 1 var in file

    end; 

    good_shapes = 0;
    if ( ~isempty( varname ) )
      load( fullpath, varname);
      load( Zheader.Model.path,'Gheader' );
      eval( [ 'good_shapes = size( ' varname ',2) == Gheader.bins;' ] );
%      eval( [ 'plot( ' varname ''', ''-'');' ] );
    end;


  end

  if good_shapes
    eval( [ 'plot( ' varname ''', ''-'');' ] );
    handles.shapefile = fullpath;
    handles.new_setting.defaults.hrf_file = fullpath;
    handles.new_setting.defaults.hrf_mat = varname;
    handles.isDirty = 1;
    str = short_path( fullpath, 2 );
    set( handles.txt_hrf_file, 'String', str );
    set( handles.txt_hrf_varname, 'String', varname );
  else
      show_message( 'invalid dimension', 'The columns of the Shapes variable does not match the number of bins in the G Model' );
      
  end;
  
  % Update handles structure
  guidata(hObject, handles);
  update_controls( hObject, 0, handles );



% --- Executes on slider movement.
function ctl_gamma_Callback(hObject, eventdata, handles)
% hObject    handle to ctl_gamma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  x = get(hObject,'Value');
  adjust_gamma( handles, x );
  drawnow();



% --- Executes during object creation, after setting all properties.
function ctl_gamma_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ctl_gamma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end




function txt_gamma_Callback(hObject, eventdata, handles)
% hObject    handle to txt_gamma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  str = get(hObject,'String');
  str = validate_numeric_entry( str );

  x = str2double(str);
  val = min(max(0.0,x), 1.0 )
  adjust_gamma( handles, x );


% --- Executes during object creation, after setting all properties.
function txt_gamma_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_gamma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Adjust the gamma control displays, check orthomax gamma adjustment to select varimax etc. . .
function adjust_gamma( handles, gamma_value )

  gamma_value = max( 0.0, min(gamma_value, 1.0) );
  handles.new_setting.defaults.gamma = gamma_value;
  handles.isDirty = 1;
  % Update handles structure
  guidata(handles.figure1, handles);

  contents = get(handles.lst_method,'String');
  this_index = get(handles.lst_method,'Value');
  this_method = char(contents{this_index});

  new_index = 0;

  switch this_method

    case { 'orthomax' 'varimax' 'equimax' 'quartimax'}
      switch gamma_value
        case 1.00
          new_index = locate_method( handles, 'varimax' );

%        case 0.50
%          new_index = locate_method( handles, 'equimax' );

        case 0.00
          new_index = locate_method( handles, 'quartimax' );

        otherwise
          new_index = locate_method( handles, 'orthomax' );

        end;

        str = sprintf( '%4.2f', gamma_value );
        set( handles.txt_gamma, 'String', str );
        set( handles.ctl_gamma, 'Value', gamma_value );
        drawnow();

        if ( new_index ~= this_index ) 
          set( handles.lst_method, 'Value', new_index );

%        lst_method_Callback( handles.lst_method, 0, handles );

        str = sprintf( '%4.2f', gamma_value );
        set( handles.txt_gamma, 'String', str );
        set( handles.ctl_gamma, 'Value', gamma_value );
        drawnow();


      end;


    otherwise
      str = sprintf( '%4.2f', gamma_value );
      set( handles.txt_gamma, 'String', str );
      set( handles.ctl_gamma, 'Value', gamma_value );

  end;

  update_filename( handles );
  handles.isDirty = 1;
  update_controls( hObject, 0, handles );

  drawnow();



% --- Executes on slider movement.
function ctl_power_Callback(hObject, eventdata, handles)
% hObject    handle to ctl_power (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  x = get(hObject,'Value');
  str = sprintf( '%.1f', x );
  set( handles.txt_power, 'String', str );

  handles.new_setting.defaults.power = x;
  handles.isDirty = 1;
  % Update handles structure
  guidata(handles.figure1, handles);

  update_filename( handles );
  update_controls( hObject, 0, handles );


% --- Executes during object creation, after setting all properties.
function ctl_power_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ctl_power (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in chk_normalize.
function chk_normalize_Callback(hObject, eventdata, handles)
% hObject    handle to chk_normalize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.new_setting.defaults.normalize = get(hObject,'Value');
  handles.isDirty = 1;
  % Update handles structure
  guidata(handles.figure1, handles);
  update_controls( hObject, 0, handles );



function txt_iterations_Callback(hObject, eventdata, handles)
% hObject    handle to txt_iterations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  str = get(hObject,'String');
  str = validate_numeric_entry( str );
  set(hObject,'String', str );
  handles.new_setting.defaults.iterations = str2double(str);
  handles.isDirty = 1;
% Update handles structure
guidata(hObject, handles);
  update_filename( handles );
  update_controls( hObject, 0, handles );



% --- Executes during object creation, after setting all properties.
function txt_iterations_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_iterations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chk_orthogonal.
function chk_orthogonal_Callback(hObject, eventdata, handles)
% hObject    handle to chk_orthogonal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%  x = get(hObject,'Value');
%  handles.new_setting.defaults.oblique = ~x;
  handles.new_setting.defaults.oblique = 0;	% do not allow click to turn off
  handles.isDirty = 1;
  % Update handles structure
  guidata(hObject, handles);

  update_controls( hObject, 0, handles );


% --- Executes on button press in chk_oblique.
function chk_oblique_Callback(hObject, eventdata, handles)
% hObject    handle to chk_oblique (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%  handles.new_setting.defaults.oblique = get(hObject,'Value');
  handles.new_setting.defaults.oblique = 1;
  handles.isDirty = 1;
  % Update handles structure
  guidata(hObject, handles);

  update_controls( hObject, 0, handles );



function txt_power_Callback(hObject, eventdata, handles)
% hObject    handle to txt_power (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  str = get(hObject,'String');
  str = validate_numeric_entry( str );

  x = str2double(str);
  val = min(max(1.0,x), 4.0 );

  set( handles.ctl_power, 'Value', val );
  set(hObject,'String', num2str(val) );
  drawnow();

  handles.new_setting.defaults.power = x;
  handles.isDirty = 1;
  % Update handles structure
  guidata(handles.figure1, handles);

  update_filename( handles );
  update_controls( hObject, 0, handles );


% --- Executes during object creation, after setting all properties.
function txt_power_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_power (see GCBO)
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

%  handles.this_setting.defaults.power = min( 4, floor(get( handles.ctl_power, 'Value') ) );
%  handles.this_setting.defaults.iterations = str2double(get( handles.txt_iterations, 'String' ) );
%
%  handles.this_setting.defaults.oblique = get( handles.chk_oblique, 'Value');
%
%  handles.this_setting.defaults.orthogonal_output = get( handles.chk_apply_to_UR, 'Value');
%  handles.this_setting.defaults.gamma = get( handles.ctl_gamma, 'Value' );
%  handles.this_setting.defaults.normalize = get( handles.chk_normalize, 'Value' );
%
%  handles.this_setting.defaults.hrf_file = handles.shapefile;
%  handles.this_setting.defaults.hrf_mat = get( handles.txt_hrf_varname, 'String' );
%  handles.this_setting.defaults.text = handles.txt_ofn;
%
  if isempty(handles.this_setting)
    handles.output = 1;
  else
    handles.output = handles.this_setting;
  end

% Update handles structure
guidata(hObject, handles);

  uiresume(handles.figure1);



% --- Executes on button press in btn_cancel.
function btn_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to btn_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.output = '';
  % Update handles structure
  guidata(hObject, handles);
  uiresume(handles.figure1);



% --- Executes on button press in chk_apply_to_UR.
function chk_apply_to_UR_Callback(hObject, eventdata, handles)
% hObject    handle to chk_apply_to_UR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.new_setting.defaults.apply_to_ur = get(hObject,'Value');

%  if ( handles.new_setting.defaults.apply_to_ur )
%    handles.new_setting.defaults.text = 'UR';
%  else
%    handles.new_setting.defaults.text = '';
%  end;
%
  handles.isDirty = 1;

  % Update handles structure
  guidata(hObject, handles);

  update_controls( hObject, 0, handles );


% --- Executes on button press in chk_quartimax.
function chk_quartimax_Callback(hObject, eventdata, handles)
% hObject    handle to chk_quartimax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.new_setting.defaults.quartiimax = get(hObject,'Value');
  handles.isDirty = 1;
  % Update handles structure
  guidata(hObject, handles);

  update_controls( hObject, 0, handles );


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  handles.output = '';
  % Update handles structure
  guidata(hObject, handles);
  uiresume(handles.figure1);



function update_controls( hObject, eventdata, handles )
global Zheader;

  %------------------------------------------------
  % enable and initialize appropriate controls
  %------------------------------------------------

  condition = [{'off'}; {'on'}];

  if ( handles.new_setting.parameters.power )
    set( handles.ctl_power, 'Value', handles.new_setting.defaults.power );
    set( handles.txt_power, 'String', num2str(handles.new_setting.defaults.power) );
  else
    set( handles.ctl_power, 'Value', 1 );
    set( handles.txt_power, 'String', '' );
  end

  set( handles.ctl_power, 'Enable', char(condition( handles.new_setting.parameters.power + 1) ) );
  set( handles.txt_power, 'Enable', char(condition( handles.new_setting.parameters.power + 1) ) );

  set( handles.txt_iterations, 'String', num2str(handles.new_setting.defaults.iterations) );

  set( handles.chk_orthogonal, 'Enable', char(condition( handles.new_setting.parameters.oblique + 1) ) );
  set( handles.chk_orthogonal, 'Value', handles.new_setting.defaults.oblique == 0 );

  set( handles.chk_oblique, 'Enable', char(condition( handles.new_setting.parameters.oblique + 1) ) );
  set( handles.chk_oblique, 'Value', handles.new_setting.defaults.oblique );

  set( handles.ctl_gamma, 'Enable', char(condition( handles.new_setting.parameters.gamma + 1) ) );
  set( handles.txt_gamma, 'Enable', char(condition( handles.new_setting.parameters.gamma + 1) ) );

  set( handles.ctl_gamma, 'Value', handles.new_setting.defaults.gamma );
  if ( handles.new_setting.defaults.gamma > 0  )
    set( handles.txt_gamma, 'String', num2str(handles.new_setting.defaults.gamma) );
  else
    set( handles.txt_gamma, 'String', '' );
  end;


%   set( handles.chk_apply_to_UR, 'Visible', 'off' );
%   set( handles.chk_apply_to_UR, 'Value', 0 );
% shit
% handles.new_setting.defaults.alternate_ur
  set( handles.chk_normalize, 'Enable', char(condition( handles.new_setting.parameters.normalize + 1) ) );
  set( handles.chk_normalize, 'Value', handles.new_setting.defaults.normalize );

  set( handles.chk_normalize, 'Enable', char(condition( handles.new_setting.parameters.normalize + 1) ) );
  set( handles.chk_normalize, 'Value', handles.new_setting.defaults.normalize );
  set( handles.chk_subject_stats, 'Value', handles.new_setting.defaults.subject_stats );

  set( handles.chk_alt_UR, 'Enable', char(condition( handles.new_setting.parameters.alternate_ur + 1) ) );
  set( handles.chk_alt_UR, 'Value', handles.new_setting.defaults.alternate_ur );

  set( handles.btn_hrf_shapes, 'Enable', char(condition( handles.new_setting.parameters.HRF + 1) ) );
  set( handles.btn_create_shapes, 'Enable', char(condition( handles.new_setting.parameters.HRF + 1) ) );
%   set( handles.txt_T_matrix, 'Visible', char(condition( handles.new_setting.parameters.HRF + 1) ) );
  set( handles.txt_hrf_file, 'Enable', char(condition( handles.new_setting.parameters.HRF + 1) ) );
  set( handles.txt_hrf_varname, 'Enable', char(condition( handles.new_setting.parameters.HRF + 1) ) );
  set( handles.plt_hrf, 'Visible', char(condition( handles.new_setting.parameters.HRF + 1) ) );

  str = short_path( handles.shapefile, 2 );
  set( handles.txt_hrf_file, 'String', str );
  set( handles.txt_hrf_varname, 'String',  handles.new_setting.defaults.hrf_mat );

  set( handles.chk_Use_T, 'Visible', char(condition( handles.new_setting.parameters.HRF + 1) ) );
  if ~isempty(handles.new_setting.defaults.T_mat )
    set( handles.chk_Use_T, 'Value', 1 );
    show_T_matrix( handles, handles.new_setting.defaults.T_mat );
  else
    show_T_matrix( handles, [] );
  end;
  
  if ( handles.new_setting.parameters.HRF == 1 )
    if ( ~isempty( handles.new_setting.defaults.hrf_file ) )
      x = exist( handles.new_setting.defaults.hrf_file, 'file' );
      if ( x == 2 )  % the shapes file still exists
        load( Zheader.Model.path, 'Gheader');

        eval ( [ 'load( ''' handles.new_setting.defaults.hrf_file ''', ''' handles.new_setting.defaults.hrf_mat ''')'] );
        eval( [ 'plot( ' handles.new_setting.defaults.hrf_mat ''', ''-'');' ] );

        xtl = [];
        for ii = 1:Gheader.bins+1
          xtl = [xtl (ii-1)*Gheader.TR];
        end;

        set( handles.plt_hrf, 'XtickLabel', xtl );
        set( handles.plt_hrf, 'Xtick', 0:Gheader.bins );
      else
        handles.new_setting.defaults.hrf_file = '';
      end;
    end
    
  end

  update_filename( handles );

  set( handles.txt_ofn, 'String',  handles.new_setting.defaults.text );

  contents = get(handles.lst_active_rotations,'String'); 
  num_entries = size(contents, 1);
  if ( num_entries > 0 ) state = 'on'; else state = 'off'; end;

  set( handles.btn_delete_from_list, 'Enable', state );
  set( handles.btn_update_list, 'Enable', char(handles.states(handles.isDirty+1)) );

  set( handles.btn_add_to_list, 'Enable', char(handles.states(handles.isDirty+1)) );

  if strcmpi( handles.new_setting.method, 'hrf-procrustes' )
    set( handles.txt_target_vr, 'String', short_path(handles.new_setting.defaults.hrf_file, 3 ) );
  end
  
%    if exist( 'hrfmax_state.mat', 'file' ) 
%      set( handles.chk_select_target_vr, 'Visible', 'on' );
%      set( handles.chk_select_target_vr, 'String', 'Load saved state' );
%    else
%      set( handles.chk_select_target_vr, 'Visible', 'off' );
%      set( handles.chk_select_target_vr, 'String', 'Select Target VR' );
%    end;
%
%  else
%    set( handles.chk_select_target_vr, 'Visible', 'off' );
%    set( handles.chk_select_target_vr, 'String', 'Select Target VR' );
%  end;

  set( handles.chk_load_state_file, 'Value', handles.new_setting.parameters.load_state );

  % that takes care of all the standard settings, now we want to process any special conditions applied to current method

%fprintf( 'checking special instructions . . .\n' );
  if ( isfield( handles.new_setting.parameters, 'special' ) )
%fprintf( 'special instructions exist . . .\n' );
    if ( size( handles.new_setting.parameters.special, 1 ) > 0 )
%fprintf( 'special instructions counted . . .\n' );
      process_special_instructions( handles, handles.new_setting.parameters.special );
    end;
  end;



function process_special_instructions( handles, si )
%fprintf( ' processing instructions . . .\n' );

  for ( instruction = 1:size( si, 1 ) )
    res = exec_condition( handles, si(instruction).condition );
    if ( res )
      res = exec_condition( handles, si(instruction).result );
    end;

  end;


function res = exec_condition( handles, si )
%fprintf( '  - instruction: %s . . .', si.type );
 
  res = 0;

  for ( cmd = 1:size(si,2) )

    switch si(cmd).type
      case 'control_equal'
%        [ 'x = get( handles.' si.control ', ''' si.parameter ''' );' ]
        x = 0;
        eval( [ 'x = get( handles.' si(cmd).control ', ''' si(cmd).parameter ''' );' ] );
        if ( x == si(cmd).equal_to ) res = 1; end;

      case 'control_set'  % --- used to set a control numeric parameter
%        [ 'set( handles.' si.control ', ''' si.parameter ''', si.set_to );' ]
        eval( [ 'set( handles.' si(cmd).control ', ''' si(cmd).parameter ''', ' num2str(si(cmd).set_to) ');' ] );

      case 'control_state'
%        [ 'set( handles.' si.control ', ''' si.parameter ''', si.set_to );' ]
        eval( [ 'set( handles.' si(cmd).control ', ''' si(cmd).parameter ''', ''' si(cmd).set_to ''');' ] );

    end;

  end;


% --- Executes on selection change in lst_active_rotations.
function lst_active_rotations_Callback(hObject, eventdata, handles)
% hObject    handle to lst_active_rotations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns lst_active_rotations contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lst_active_rotations

  idx = get(hObject, 'Value' );
  handles.new_setting = handles.this_setting(idx);
  handles.new_setting.defaults.reltol = sqrt(eps);
  handles.isDirty = 1;

  guidata(handles.figure1, handles);

  method_index = locate_method( handles, {handles.new_setting.method} );
  set( handles.lst_method, 'Value', method_index );

  update_controls( hObject, 0, handles );


% --- Executes during object creation, after setting all properties.
function lst_active_rotations_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_active_rotations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_add_to_list.
function btn_add_to_list_Callback(hObject, eventdata, handles)
% hObject    handle to btn_add_to_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  refresh_new_settings( handles );

  idx = get ( handles.lst_active_rotations, 'Value');
  contents = get(handles.lst_active_rotations,'String'); 
  num_entries = size(contents, 1);

  if ( num_entries > 0 )
    handles.this_setting = [ handles.this_setting ; handles.new_setting ];
  else
    handles.this_setting = handles.new_setting;
  end;

  lst = [];
  for ( ii = 1:size(handles.this_setting,1) )
    handles.new_setting = handles.this_setting(ii);
    guidata(handles.figure1, handles);
    str = create_default_filename( handles );
    lst = [lst {str} ];
  end;
  set ( handles.lst_active_rotations, 'String', lst, 'Value', size(handles.this_setting,1) );

  handles.new_setting = handles.this_setting(idx);
  handles.new_setting.defaults.reltol = sqrt(eps);
  handles.isDirty = 0;
  guidata(handles.figure1, handles);

  update_controls( hObject, 0, handles );

  drawnow();



% --- Executes on button press in btn_update_list.
function btn_update_list_Callback(hObject, eventdata, handles)
% hObject    handle to btn_update_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 

  refresh_new_settings( handles );

  idx = get ( handles.lst_active_rotations, 'Value');
  contents = get(handles.lst_active_rotations,'String'); 
  num_entries = size(contents, 1);

  if ( num_entries > 0 & idx <= num_entries )
    handles.this_setting(idx) = handles.new_setting;

    lst = [];
    for ( ii = 1:size(handles.this_setting,1) )
      handles.new_setting = handles.this_setting(ii);
      guidata(handles.figure1, handles);
      str = create_default_filename( handles );
      lst = [lst {str} ];
    end;
    set ( handles.lst_active_rotations, 'String', lst, 'Value', idx );

    handles.new_setting = handles.this_setting(idx);
    handles.new_setting.defaults.reltol = sqrt(eps);
    handles.isDirty = 0;

    update_controls( hObject, 0, handles );

    drawnow();
  end


% --- Executes on button press in btn_delete_from_list.
function btn_delete_from_list_Callback(hObject, eventdata, handles)
% hObject    handle to btn_delete_from_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


  idx = get ( handles.lst_active_rotations, 'Value');
  iter = size( handles.this_setting, 1 );

  new_settings = [];
  lst = [];

  for ( ii = 1:iter )
    if ( ii ~= idx )
      new_settings = [new_settings; handles.this_setting(ii)];
      str = rotated_output_filename( handles.this_setting(ii) );
      lst = [lst {str} ];
    end;
  end;

  handles.this_setting = new_settings;
  guidata(handles.figure1, handles);

  set ( handles.lst_active_rotations, 'String', lst, 'Value', 1 );

  update_controls( hObject, 0, handles );




function fn = create_default_filename( handles )
  % function overrided to external function for stability of operation
%  fn = rotated_output_filename( handles.new_setting, handles.model );

  theseParms = handles.new_setting;
  fn = fs_filename( 'mat', handles.model, theseParms.method, theseParms.defaults );




function update_filename( handles )

%  if ( isempty( handles.new_setting.defaults.text ) )
    str = create_default_filename( handles );
%  else
%    str = handles.new_setting.defaults.text;
%  end;
  set( handles.txt_output_filename, 'String', str );



function txt_ofn_Callback(hObject, eventdata, handles)
% hObject    handle to txt_ofn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_ofn as text
%        str2double(get(hObject,'String')) returns contents of txt_ofn as a double

  str = char(get(hObject,'String'));
 
  % get rid of irrelevalt leading / trailing spaces
  % make remaining spaces underscore characters
  % eg ' hello there ' bcomes 'hello_there'
  str = strtrim(str);
  str = strrep(str, ' ', '_' );
  set(hObject,'String', str );

  handles.new_setting.defaults.text = str;
  handles.isDirty = 1;

  % Update handles structure
  guidata(handles.figure1, handles);

  drawnow()
  update_filename( handles );
  update_controls( hObject, 0, handles );


% --- Executes on key press with focus on txt_ofn and none of its controls.
function txt_ofn_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to txt_ofn (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)



function refresh_new_settings( handles )

  handles.new_setting.defaults.power = min( 4, floor(get( handles.ctl_power, 'Value') ) );
  handles.new_setting.defaults.iterations = str2double(get( handles.txt_iterations, 'String' ) );

  handles.new_setting.defaults.oblique = get( handles.chk_oblique, 'Value');

  handles.new_setting.defaults.apply_to_ur = get( handles.chk_apply_to_UR, 'Value');
  handles.new_setting.defaults.gamma = get( handles.ctl_gamma, 'Value' );
  handles.new_setting.defaults.normalize = get( handles.chk_normalize, 'Value' );
  handles.new_setting.defaults.alternate_ur = get( handles.chk_alt_UR, 'Value' );

  handles.new_setting.defaults.hrf_file = handles.shapefile;
  handles.new_setting.defaults.hrf_mat = get( handles.txt_hrf_varname, 'String' );
%   handles.new_setting.defaults.target_vr_file = '';
  handles.new_setting.defaults.text = handles.txt_ofn;
  handles.isDirty = 0;


% --- Executes on button press in chk_alt_UR.
function chk_alt_UR_Callback(hObject, eventdata, handles)
% hObject    handle to chk_alt_UR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.new_setting.defaults.alternate_ur = get(hObject,'Value');
  handles.isDirty = 1;
  % Update handles structure
  guidata(handles.figure1, handles);
  update_controls( hObject, 0, handles );


% --- Executes on key press with focus on lst_active_rotations and none of its controls.
function lst_active_rotations_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to lst_active_rotations (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

  deleteItem = strcmp( eventdata.Key, 'delete' );
  if ~deleteItem & ismac()
    deleteItem = strcmp( eventdata.Key, 'backspace' )
  end;

  if ( deleteItem )
    btn_delete_from_list_Callback(hObject, 0, handles)
  end;


% --- Executes on button press in chk_Use_T.
function chk_Use_T_Callback(hObject, eventdata, handles)
% hObject    handle to chk_Use_T (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_Use_T
  if ( length( handles.new_setting.defaults.T_mat ) > 1 )
    hObject.Value = 0;
    handles.new_setting.defaults.T_mat = [];
    handles.new_setting.defaults.T_orient = [];
    set( handles.btn_show_T_data, 'Enable', 'off' );
  else

    fullpath = select_file( {'*.mat','MATLAB .mat file'}, ...
                                   'Select which hrfmax T matrix to use');

    if isempty( fullpath )
      set( hObject, 'Value', 0 );
      handles.new_setting.defaults.T_mat = [];
      handles.new_setting.defaults.T_orient = [];
    else

      eval ( [ 'load( ''' fullpath ''', ''T'', ''component_orientation_data'' );' ] );
      if exist( 'T', 'var' )
        handles.new_setting.defaults.T_mat = T;
        if exist( 'component_orientation_data', 'var' )
          handles.new_setting.defaults.T_orient = component_orientation_data;
        end;
      else
        hObject.Value = 0;
      end;

      idx = get ( handles.lst_active_rotations, 'Value');
      contents = get(handles.lst_active_rotations,'String'); 
      num_entries = size(contents, 1);

      if ( num_entries > 0 & idx <= num_entries )
        handles.this_setting(idx) = handles.new_setting;
      end;
    end;

  end;

  handles.isDirty = 1;

  show_T_matrix( handles, handles.new_setting.defaults.T_mat );

  % Update handles structure
  guidata(handles.figure1, handles);
  update_controls( hObject, 0, handles );



function show_T_matrix( handles, T );

%        tmat = '';
%
%        for ii = 1:size(T,1)
%          for jj = 1:size(T,2)
%            str = sprintf( '%.2f', T(ii,jj) );
%            if ( length( tmat ) > 0 )
%              tmat = [tmat ', ' str ];
%            else
%              tmat = str;
%            end;
%          end;
%        end;
%
        if ( length( handles.new_setting.defaults.T_mat ) > 1 )
          set( handles.btn_show_T_data, 'Enable', 'on' );
%          set( handles.txt_T_matrix, 'String', ['[ ', tmat, ' ]' ] );
        else
          set( handles.btn_show_T_data, 'Enable', 'off' );
%          set( handles.txt_T_matrix, 'String', '' );
        end;


% --- Executes on button press in btn_create_shapes.
function btn_create_shapes_Callback(hObject, eventdata, handles)
% hObject    handle to btn_create_shapes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Zheader scan_information

  if ( ~isempty( Zheader.Model.path ) )
    eval( [ 'load( ''' Zheader.Model.path ''', ''Gheader'')' ] );
    if( exist( 'Gheader', 'var' ) )
%      hrf_shape_creation( 'zheader', Zheader, 'scan_info', scan_information, 'gheader', Gheader );
      create_hrf_shapes( 'zheader', Zheader, 'scan_info', scan_information, 'gheader', Gheader );
    end;
  end;


% --- Executes on button press in chk_subject_stats.
function chk_subject_stats_Callback(hObject, eventdata, handles)
% hObject    handle to chk_subject_stats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.new_setting.defaults.subject_stats = get(hObject,'Value');
  handles.isDirty = 1;
  % Update handles structure
  guidata(handles.figure1, handles);
  update_controls( hObject, 0, handles );


% --- Executes on button press in btn_show_T_data.
function btn_show_T_data_Callback(hObject, eventdata, handles)
% hObject    handle to btn_show_T_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  T_Matrix_Information( 'T', handles.new_setting.defaults.T_mat, 'O', handles.new_setting.defaults.T_orient );


% --- Executes on button press in chk_select_target_vr.
function chk_select_target_vr_Callback(hObject, eventdata, handles)
% hObject    handle to chk_select_target_vr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_select_target_vr

  handles.new_setting.defaults.hrf_file = '';
  handles.new_setting.defaults.hrf_mat = '';

  fullpath = select_file( {'*.mat','MATLAB .mat file'}, ...
                                   'Select which VR result to use as target');

  if ~isempty( fullpath )

    eval ( [ 'load( ''' fullpath ''', ''VR'' );' ] );
    if exist( 'VR', 'var' )
      handles.new_setting.defaults.hrf_file = fullpath;
      handles.new_setting.defaults.hrf_mat = 'VR';
    end;

    idx = get ( handles.lst_active_rotations, 'Value');
    contents = get(handles.lst_active_rotations,'String'); 
    num_entries = size(contents, 1);

    if ( num_entries > 0 && idx <= num_entries )
      handles.this_setting(idx) = handles.new_setting;
    end;
  end;

  handles.isDirty = 1;
  str = short_path( fullpath, 2 );
%   set( handles.txt_target_vr_file, 'String', str );
%   set( handles.txt_hrf_varname, 'String', 'VR' );

  % Update handles structure
  guidata(handles.figure1, handles);
  update_controls( hObject, 0, handles );


% --- Executes on button press in chk_load_state_file.
function chk_load_state_file_Callback(hObject, eventdata, handles)
% hObject    handle to chk_load_state_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.new_setting.parameters.load_state = get( hObject, 'Value' );
  guidata(handles.figure1, handles);
  update_controls( hObject, 0, handles );
  
