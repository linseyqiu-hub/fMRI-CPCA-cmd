function varargout = plotSettings(varargin)
% PLOTSETTINGS M-file for plotSettings.fig
%      PLOTSETTINGS, by itself, creates a new PLOTSETTINGS or raises the existing
%      singleton*.
%
%      H = PLOTSETTINGS returns the handle to a new PLOTSETTINGS or the handle to
%      the existing singleton*.
%
%      PLOTSETTINGS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLOTSETTINGS.M with the given input arguments.
%
%      PLOTSETTINGS('Property','Value',...) creates a new PLOTSETTINGS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before plotSettings_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to plotSettings_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help plotSettings

% Last Modified by GUIDE v2.5 25-Jan-2010 11:33:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @plotSettings_OpeningFcn, ...
                   'gui_OutputFcn',  @plotSettings_OutputFcn, ...
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


% --- Executes just before plotSettings is made visible.
function plotSettings_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to plotSettings (see VARARGIN)
%global scan_information plotting;

% Choose default command line output for plotSettings
%handles.output = hObject;
  handles.output = varargin{:};

  handles.plotstyles = struct ( 'linestyles', [], 'markers', [] );

  handles.plotstyles.linestyles = struct ( 'symbol', '', 'text', '<none>' ) ;
  handles.plotstyles.linestyles = vertcat(handles.plotstyles.linestyles , struct ( 'symbol', '-', 'text', 'solid' ) ) ;
  handles.plotstyles.linestyles = vertcat(handles.plotstyles.linestyles , struct ( 'symbol', '--', 'text', 'dashed' ) ) ;
  handles.plotstyles.linestyles = vertcat(handles.plotstyles.linestyles , struct ( 'symbol', ':', 'text', 'dotted' ) ) ;
  handles.plotstyles.linestyles = vertcat(handles.plotstyles.linestyles , struct ( 'symbol', '-.', 'text', 'dash dot' ) ) ;

  handles.plotstyles.markers = struct ( 'symbol', '', 'text', '<none>' ) ;
  handles.plotstyles.markers = vertcat(handles.plotstyles.markers , struct ( 'symbol', '+', 'text', 'plus sign' ) ) ;
  handles.plotstyles.markers = vertcat(handles.plotstyles.markers , struct ( 'symbol', 'O', 'text', 'circle' ) ) ;
  handles.plotstyles.markers = vertcat(handles.plotstyles.markers , struct ( 'symbol', '*', 'text', 'asterisk' ) ) ;
  handles.plotstyles.markers = vertcat(handles.plotstyles.markers , struct ( 'symbol', '.', 'text', 'point' ) ) ;
  handles.plotstyles.markers = vertcat(handles.plotstyles.markers , struct ( 'symbol', 'x', 'text', 'cross' ) ) ;
  handles.plotstyles.markers = vertcat(handles.plotstyles.markers , struct ( 'symbol', 's', 'text', 'square' ) ) ;
  handles.plotstyles.markers = vertcat(handles.plotstyles.markers , struct ( 'symbol', 'd', 'text', 'diamond' ) ) ;
  handles.plotstyles.markers = vertcat(handles.plotstyles.markers , struct ( 'symbol', '^', 'text', 'triangle up' ) ) ;
  handles.plotstyles.markers = vertcat(handles.plotstyles.markers , struct ( 'symbol', 'v', 'text', 'triangle down' ) ) ;
  handles.plotstyles.markers = vertcat(handles.plotstyles.markers , struct ( 'symbol', '>', 'text', 'triangle right' ) ) ;
  handles.plotstyles.markers = vertcat(handles.plotstyles.markers , struct ( 'symbol', '<', 'text', 'triangle left' ) ) ;
  handles.plotstyles.markers = vertcat(handles.plotstyles.markers , struct ( 'symbol', 'p', 'text', 'pentagram' ) ) ;
  handles.plotstyles.markers = vertcat(handles.plotstyles.markers , struct ( 'symbol', 'h', 'text', 'hexagram' ) ) ;

  % ------------------------------------------
  % enable and set all the global controls
  % ------------------------------------------

  try      set( handles.sel_GlobalLinestyle, 'Value', handles.output.plotting.global.line.style );     catch   end;
  try   str = num2str( handles.output.plotting.global.line.size );  set( handles.txt_GlobalLinesize, 'String', str );     catch   end;

  try      set( handles.sel_GlobalMarkerstyle, 'Value', handles.output.plotting.global.marker.style ); 
           state = 'off';  if ( handles.output.plotting.global.marker.style > 1 ) state = 'on'; end;
           set( handles.txt_GlobalMarkersize, 'Enable', state ); 
           set( handles.btn_GlobalMarkercolor, 'Enable', state ); 
           set_button_text_color( handles.btn_GlobalMarkercolor, handles.output.plotting.global.marker.color );

           set( handles.chk_GlobalMarkeredge, 'Enable', state ); 
           set( handles.chk_GlobalMarkeredge, 'Value', handles.output.plotting.global.marker.edge ); 
           if ( handles.output.plotting.global.marker.edge )  set( handles.btn_GlobalMarkeredgeColor, 'Enable', state );  end;
           set_button_text_color( handles.btn_GlobalMarkeredgeColor, handles.output.plotting.global.marker.edgecolor );
  catch   end;
  try   str = num2str( handles.output.plotting.global.marker.size );  set( handles.txt_GlobalMarkersize, 'String', str );     catch   end;

  % ------------------------------------------
  % enable and set all the extended controls
  % ------------------------------------------

  ext_state = 'off';
  if ( handles.output.plotting.use_extended == 1 ) ext_state = 'on'; end;

  try      set( handles.chk_UseExtended, 'Value', handles.output.plotting.use_extended );  catch  end;

  % ------------------------------------------
  % update the conditions name list
  % ------------------------------------------
  [x y] = size(handles.output.condition_name);

  if ( y > 0 )
    conds = findobj('Tag','lst_ExtConditions');
    bb = get( conds, 'String') ;

    % place each condition anem into the list
    for ii = 1:y
      bb = [bb; handles.output.condition_name(ii)];
    end;
    
    set( handles.btn_DeleteCondition, 'Enable', 'on' );
    set( handles.btn_EditCondition, 'Enable', 'on' );
    set( handles.sel_ConditionLinestyle, 'Enable', 'on' );
    set( handles.sel_ConditionMarkerstyle, 'Enable', 'on' );

%    if ( handles.output.conditions >= x ) set( handles.btn_AddCondition, 'Enable', 'off' ); end;
    if ( x == 0 ) 
      set( handles.btn_DeleteCondition, 'Enable', 'off' ); 
      set( handles.btn_EditCondition, 'Enable', 'off' ); 
      set( handles.sel_ConditionLinestyle, 'Enable', 'off' );
      set( handles.sel_ConditionMarkerstyle, 'Enable', 'off' );
    end;

    set( conds, 'String', bb, 'Value', 1) ;
    
  end;

  add_state = 'off';
  if ( handles.output.conditions > x ) add_state = 'on'; end;
  set( handles.btn_AddCondition, 'Enable', add_state );

  % ------------------------------------------
  % ensure each known condition has an attached struct
  % ------------------------------------------
  ext_set = struct( 'name', '', ...
                'settings', struct ( ...
                     'linestyle', 1, 'linecolor', 0, ...
                     'markerstyle', 1, 'markersize', 1, 'markercolor', 0, 'markeredge', 0, 'edgecolor', 0 ) ...
                 );
  [x y] = size(handles.output.plotting.extended.plotting) ;
  if ( x < handles.output.conditions )
    for ii = 1:handles.output.conditions-x
      handles.output.plotting.extended.plotting = [handles.output.plotting.extended.plotting; ext_set];
    end;
  end;

%  set( handles.lst_ExtConditions, 'Enable', ext_state );
  set( handles.lst_ExtConditions, 'Enable', 'on' );
  set( handles.sel_ConditionLinestyle, 'Enable', ext_state );
  try      set( handles.sel_ConditionLinestyle, 'Value', handles.output.plotting.extended.plotting(1).settings.linestyle );  catch end;


  try   str = num2str( handles.output.plotting.extended.plotting(1).settings.markersize );  
        set( handles.txt_ConditionMarkersize, 'String', str );     catch   end;

  if ( handles.output.plotting.extended.plotting(1).settings.linestyle > 1 )
    set( handles.btn_ConditionLinecolor, 'Enable', 'on' );
  else
    set( handles.btn_ConditionLinecolor, 'Enable', 'off' );
  end;
  set_button_text_color( handles.btn_ConditionLinecolor, handles.output.plotting.extended.plotting(1).settings.linecolor );

  set( handles.sel_ConditionMarkerstyle, 'Enable', ext_state );
  try      set( handles.sel_ConditionMarkerstyle, 'Value', handles.output.plotting.extended.plotting(1).settings.markerstyle );  catch end;

  if ( handles.output.plotting.extended.plotting(1).settings.markerstyle > 1 )
    set( handles.txt_ConditionMarkersize, 'Enable', 'on' );
    set( handles.btn_ConditionMarkercolor, 'Enable', 'on' );
    set( handles.chk_ConditionEdge, 'Enable', 'on' );
  else
    set( handles.txt_ConditionMarkersize, 'Enable', 'off' );
    set( handles.btn_ConditionMarkercolor, 'Enable', 'off' );
    set( handles.chk_ConditionEdge, 'Enable', 'off' );
  end;
  set_button_text_color( handles.btn_ConditionMarkercolor, handles.output.plotting.extended.plotting(1).settings.markercolor );

  try      set( handles.chk_ConditionEdge, 'Value', handles.output.plotting.extended.plotting(1).settings.markeredge );  catch end;
  if ( handles.output.plotting.extended.plotting(1).settings.markeredge > 0 )
    set( handles.btn_ConditionEdgecolor, 'Enable', 'on' );
  else
    set( handles.btn_ConditionEdgecolor, 'Enable', 'off' );
  end;
  set_button_text_color( handles.btn_ConditionEdgecolor, handles.output.plotting.extended.plotting(1).settings.edgecolor );

  % set the labels
  set( handles.txt_XAxis, 'String', handles.output.plotting.global.label.x_axis) ;
  set( handles.txt_YAxis, 'String', handles.output.plotting.global.label.y_axis) ;
  set( handles.txt_Title, 'String', handles.output.plotting.global.label.title) ; 
  set( handles.chk_Legend, 'Value', handles.output.plotting.global.label.legend) ;
  

  % ------------------------------------------
  % update the selected conditions name list
  % ------------------------------------------
try
  [x y] = size(handles.output.plotting.selected_conditions);

  if ( x > 0 )
    conds = findobj('Tag','lst_SelectedConditions');
    bb = get( conds, 'String') ;

    % place each condition anem into the list
    for ii = 1:x
      bb = [bb; handles.output.plotting.selected_conditions(ii)];
    end;
    
    set( conds, 'String', bb, 'Value', 1) ;

    set( handles.chk_SelectedConditions, 'Value', handles.output.plotting.use_selected_conditions );
    if ( handles.output.plotting.use_selected_conditions )
      set( handles.lst_SelectedConditions, 'Enable', 'On' );
    end;
    
  end;
catch
end;


  % ------------------------------------------
  % update the beta checking extreme pos neg loadings selection
  % ------------------------------------------
try

  if ~ isfield( handles.output, 'betas' )	 handles.output.betas = 2;	end;

  handles.output.betas = 2;

  conds = findobj('Tag','lst_loadingsIndex');
  bb = [{'Top  1 %'}; {'Top  5 %'};{'Top 10 %'} ];

  set( conds, 'String', bb, 'Value', handles.output.betas ) ;	%defaults to top 5% of loadings

catch
end;

  if ( ismac )   % adjust text controls for mac displays
    set( handles.txt_GlobalLinesize, 'HorizontalAlignment', 'center' );
    pos = get(handles.txt_GlobalLinesize, 'Position' );
    set( handles.txt_GlobalLinesize, 'Position', [pos(1) pos(2) pos(3) 1.75] );

    set( handles.txt_GlobalMarkersize, 'HorizontalAlignment', 'center' );
    pos = get(handles.txt_GlobalMarkersize, 'Position' );
    set( handles.txt_GlobalMarkersize, 'Position', [pos(1) pos(2) pos(3) 1.75] );

    set( handles.txt_ConditionMarkersize, 'HorizontalAlignment', 'center' );
    pos = get(handles.txt_ConditionMarkersize, 'Position' );
    set( handles.txt_ConditionMarkersize, 'Position', [pos(1) pos(2) pos(3) 1.75] );

    set( handles.txt_XAxis, 'HorizontalAlignment', 'center' );
    pos = get(handles.txt_XAxis, 'Position' );
    set( handles.txt_XAxis, 'Position', [pos(1) pos(2) pos(3) 1.75] );

    set( handles.txt_YAxis, 'HorizontalAlignment', 'center' );
    pos = get(handles.txt_YAxis, 'Position' );
    set( handles.txt_YAxis, 'Position', [pos(1) pos(2) pos(3) 1.75] );

    set( handles.txt_Title, 'HorizontalAlignment', 'center' );
    pos = get(handles.txt_Title, 'Position' );
    set( handles.txt_Title, 'Position', [pos(1) pos(2) pos(3) 1.75] );

    pos = get(handles.lst_loadingsIndex, 'Position' );
    set( handles.lst_loadingsIndex, 'Position', [.5 pos(2) 18.5 pos(4)] );

  end;
  
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes plotSettings wait for user response (see UIRESUME)
 uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = plotSettings_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
delete(handles.figure1);



function txt_XAxis_Callback(hObject, eventdata, handles)
% hObject    handle to txt_XAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.output.plotting.global.label.x_axis = get(hObject,'String') ;
  % Update handles structure
  guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function txt_XAxis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_XAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in chk_Legend.
function chk_Legend_Callback(hObject, eventdata, handles)
% hObject    handle to chk_Legend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  handles.output.plotting.global.label.legend = get(hObject,'Value');
% Update handles structure
guidata(hObject, handles);



% --- Executes on selection change in sel_GlobalLinestyle.
function sel_GlobalLinestyle_Callback(hObject, eventdata, handles)
% hObject    handle to sel_GlobalLinestyle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  handles.output.plotting.global.line.style = get( hObject, 'Value') ;
% Update handles structure
guidata(hObject, handles);

% Hints: contents = get(hObject,'String') returns sel_GlobalLinestyle contents as cell array
%        contents{get(hObject,'Value')} returns selected item from sel_GlobalLinestyle


% --- Executes during object creation, after setting all properties.
function sel_GlobalLinestyle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sel_GlobalLinestyle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in sel_ConditionMarkerstyle.
function sel_ConditionMarkerstyle_Callback(hObject, eventdata, handles)
% hObject    handle to sel_ConditionMarkerstyle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  selected_index = get( hObject, 'Value') ;
  state = 'off';
  chkd = get(handles.chk_ConditionEdge, 'Value');
  
  if ( selected_index > 1 )  state = 'on'; else chkd = 0; end;
  
  set ( handles.txt_ConditionMarkersize, 'Enable', state );
  set ( handles.btn_ConditionMarkercolor, 'Enable', state );
  
  set ( handles.chk_ConditionEdge, 'Enable', state );
  set ( handles.chk_ConditionEdge, 'Value', chkd );
  chk_ConditionEdge_Callback( handles.chk_ConditionEdge, 0, handles );
  

  idx = get(handles.lst_ExtConditions,'Value');
  handles.output.plotting.extended.plotting(idx).settings.markerstyle = selected_index ;  

  % Update handles structure
  guidata(hObject, handles);

  
  
% Hints: contents = get(hObject,'String') returns sel_ConditionMarkerstyle contents as cell array
%        contents{get(hObject,'Value')} returns selected item from sel_ConditionMarkerstyle


% --- Executes during object creation, after setting all properties.
function sel_ConditionMarkerstyle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sel_ConditionMarkerstyle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_GlobalMarkersize_Callback(hObject, eventdata, handles)
% hObject    handle to txt_GlobalMarkersize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  handles.output.plotting.global.marker.size = str2double(get(hObject,'String'));
% Update handles structure

  str = get(hObject,'String');
  str = validate_numeric_entry( str );
  set(hObject,'String', str );

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function txt_GlobalMarkersize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_GlobalMarkersize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_GlobalMarkercolor.
function btn_GlobalMarkercolor_Callback(hObject, eventdata, handles)
% hObject    handle to btn_GlobalMarkercolor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.output.plotting.global.marker.color = uisetcolor();  
%  clr = uisetcolor( plotting.parameters.global.marker.color );  
  [x y] = size(handles.output.plotting.global.marker.color);
  if ( y > 1 )          % cancel returns a single double value of 0, otherwise 1 x 3 array
    set( hObject, 'ForegroundColor', handles.output.plotting.global.marker.color );
  else
    set( hObject, 'ForegroundColor', [0 0 0] );
  end;
% Update handles structure
guidata(hObject, handles);
  

% --- Executes on button press in btn_GlobalMarkeredgeColor.
function btn_GlobalMarkeredgeColor_Callback(hObject, eventdata, handles)
% hObject    handle to btn_GlobalMarkeredgeColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.output.plotting.global.marker.edgecolor = uisetcolor();  
  [x y] = size(handles.output.plotting.global.marker.edgecolor);
  if ( y > 1 )          % cancel returns a single double value of 0, otherwise 1 x 3 array
    set( hObject, 'ForegroundColor', handles.output.plotting.global.marker.edgecolor );
  else
    set( hObject, 'ForegroundColor', [0 0 0] );
  end;
% Update handles structure
guidata(hObject, handles);


% --- Executes on selection change in lst_ExtConditions.
function lst_ExtConditions_Callback(hObject, eventdata, handles)
% hObject    handle to lst_ExtConditions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  % If double click
  if strcmp(get(handles.figure1,'SelectionType'),'open')

    c = findobj('Tag','chk_SelectedConditions');
    sel = get( c, 'Value' );
    if (sel )   % select the component
      select_condition( hObject, handles )
    else
      btn_EditCondition_Callback( hObject, 0, handles );
    end;
    return;
  end;

  selected_index = get(hObject,'Value');
  status = 'off';
  if ( selected_index > 0 )  status = 'on'; end;

  set( handles.sel_ConditionLinestyle, 'Enable', status );
  set( handles.sel_ConditionLinestyle,'Value', handles.output.plotting.extended.plotting(selected_index).settings.linestyle );
  [x y] = size(handles.output.plotting.extended.plotting(selected_index).settings.linecolor);
  if ( y > 1 )          % cancel returns a single double value of 0, otherwise 1 x 3 array
    set( handles.btn_ConditionLinecolor, 'ForegroundColor', handles.output.plotting.extended.plotting(selected_index).settings.linecolor );
  else
    set( handles.btn_ConditionLinecolor, 'ForegroundColor', [0 0 0] );
  end;

  set( handles.txt_ConditionMarkersize, 'String', num2str(handles.output.plotting.extended.plotting(selected_index).settings.markersize) );

  set( handles.sel_ConditionMarkerstyle, 'Enable', status );
  set( handles.sel_ConditionMarkerstyle,'Value', handles.output.plotting.extended.plotting(selected_index).settings.markerstyle );
  [x y] = size(handles.output.plotting.extended.plotting(selected_index).settings.markercolor);
  if ( y > 1 )          % cancel returns a single double value of 0, otherwise 1 x 3 array
    set( handles.btn_ConditionMarkercolor, 'ForegroundColor', handles.output.plotting.extended.plotting(selected_index).settings.markercolor );
  else
    set( handles.btn_ConditionMarkercolor, 'ForegroundColor', [0 0 0] );
  end;

  set( handles.chk_ConditionEdge, 'Value', handles.output.plotting.extended.plotting(selected_index).settings.markeredge );

  [x y] = size(handles.output.plotting.extended.plotting(selected_index).settings.edgecolor);
  if ( y > 1 )          % cancel returns a single double value of 0, otherwise 1 x 3 array
    set( handles.btn_ConditionEdgecolor, 'ForegroundColor', handles.output.plotting.extended.plotting(selected_index).settings.edgecolor );
  else
    set( handles.btn_ConditionEdgecolor, 'ForegroundColor', [0 0 0] );
  end;
  

% Hints: contents = get(hObject,'String') returns lst_ExtConditions contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lst_ExtConditions


% --- Executes during object creation, after setting all properties.
function lst_ExtConditions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_ExtConditions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in sel_ConditionLinestyle.
function sel_ConditionLinestyle_Callback(hObject, eventdata, handles)
% hObject    handle to sel_ConditionLinestyle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  selected_index = get( hObject, 'Value') ;
  state = 'off';
 
  if ( selected_index > 1 )  state = 'on'; else chkd = 0; end;

  idx = get(handles.lst_ExtConditions,'Value');

  set ( handles.btn_ConditionLinecolor, 'Enable', state );
  handles.output.plotting.extended.plotting(idx).settings.linestyle = selected_index ;  
% Update handles structure
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function sel_ConditionLinestyle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sel_ConditionLinestyle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in sel_GlobalMarkerstyle.
function sel_GlobalMarkerstyle_Callback(hObject, eventdata, handles)
% hObject    handle to sel_GlobalMarkerstyle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  handles.output.plotting.global.marker.style = get( hObject, 'Value') ;

  state = 'off';
  chkd = get(handles.chk_GlobalMarkeredge, 'Value');
  
  if ( handles.output.plotting.global.marker.style > 1 )  state = 'on'; else chkd = 0; end;
  
  set ( handles.txt_GlobalMarkersize, 'Enable', state );
  set ( handles.btn_GlobalMarkercolor, 'Enable', state );
  
  set ( handles.chk_GlobalMarkeredge, 'Enable', state );
  set ( handles.chk_GlobalMarkeredge, 'Value', chkd );
  chk_GlobalMarkeredge_Callback( handles.chk_GlobalMarkeredge, 0, handles );
% Update handles structure
guidata(hObject, handles);
  
% Hints: contents = get(hObject,'String') returns sel_GlobalMarkerstyle contents as cell array
%        contents{get(hObject,'Value')} returns selected item from sel_GlobalMarkerstyle


% --- Executes during object creation, after setting all properties.
function sel_GlobalMarkerstyle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sel_GlobalMarkerstyle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_ConditionMarkersize_Callback(hObject, eventdata, handles)
% hObject    handle to txt_ConditionMarkersize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  str = get(hObject,'String');
  str = validate_numeric_entry( str );
  set(hObject,'String', str );

  idx = get(handles.lst_ExtConditions,'Value');

  handles.output.plotting.extended.plotting(idx).settings.markersize = str2double(get(hObject,'String'));
  % Update handles structure
  guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function txt_ConditionMarkersize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_ConditionMarkersize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_ConditionLinecolor.
function btn_ConditionLinecolor_Callback(hObject, eventdata, handles)
% hObject    handle to btn_ConditionLinecolor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  idx = get(handles.lst_ExtConditions,'Value');
  handles.output.plotting.extended.plotting(idx).settings.linecolor = uisetcolor();  

  % Update handles structure
  guidata(hObject, handles);

  [x y] = size(handles.output.plotting.extended.plotting(idx).settings.linecolor);
  if ( y > 1 )          % cancel returns a single double value of 0, otherwise 1 x 3 array
    set( hObject, 'ForegroundColor', handles.output.plotting.extended.plotting(idx).settings.linecolor );
  else
    set( hObject, 'ForegroundColor', [0 0 0] );
  end;




% --- Executes on button press in chk_ConditionEdge.
function chk_ConditionEdge_Callback(hObject, eventdata, handles)
% hObject    handle to chk_ConditionEdge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  idx = get(handles.lst_ExtConditions,'Value');
  handles.output.plotting.extended.plotting(idx).settings.markeredge = get(hObject,'Value');

  % Update handles structure
  guidata(hObject, handles);

  state = 'off';
  if ( handles.output.plotting.extended.plotting(idx).settings.markeredge == 1 )  state = 'on'; end;
  set ( handles.btn_ConditionEdgecolor, 'Enable', state );

% Hint: get(hObject,'Value') returns toggle state of chk_ConditionEdge


% --- Executes on button press in btn_ConditionEdgecolor.
function btn_ConditionEdgecolor_Callback(hObject, eventdata, handles)
% hObject    handle to btn_ConditionEdgecolor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  idx = get(handles.lst_ExtConditions,'Value');
  handles.output.plotting.extended.plotting(idx).settings.edgecolor = uisetcolor();  

  % Update handles structure
  guidata(hObject, handles);

  [x y] = size(handles.output.plotting.extended.plotting(idx).settings.edgecolor);
  if ( y > 1 )          % cancel returns a single double value of 0, otherwise 1 x 3 array
    set( hObject, 'ForegroundColor', handles.output.plotting.extended.plotting(idx).settings.edgecolor );
  else
    set( hObject, 'ForegroundColor', [0 0 0] );
  end;


% --- Executes on button press in btn_AddCondition.
function btn_AddCondition_Callback(hObject, eventdata, handles)
% hObject    handle to btn_AddCondition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  newEntry = inputdlg('Enter the condition name','Add condition name');
  if ( ~isempty( newEntry ) ) 
      
    conds = findobj('Tag','lst_ExtConditions');
    bb = get( conds, 'String') ;
    bb = [bb; newEntry];
    set( conds, 'String', bb, 'Value', 1) ;
      
  end;
  handles.output.condition_name = bb;
  % Update handles structure
  guidata(hObject, handles);
  [x y] = size(handles.output.condition_name);
  if ( handles.output.conditions <= x ) set( handles.btn_AddCondition, 'Enable', 'off' ); end;
  if ( y > 0 ) 
    set( handles.btn_DeleteCondition, 'Enable', 'on' ); 
    set( handles.btn_EditCondition, 'Enable', 'on' ); 
  end;
  
  
% --- Executes on button press in btn_DeleteCondition.
function btn_DeleteCondition_Callback(hObject, eventdata, handles)
% hObject    handle to btn_DeleteCondition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  % get the selected subjects list
  sels = findobj('Tag','lst_ExtConditions');
  aa = get( sels, 'String') ;
  [x y] = size( aa );
  if ( x == 0 )  % empty list
    return
  end;

  selected_index = get( sels, 'Value') ;

  % remove this subject from selected list
  if ( selected_index > 1 )

    if ( selected_index < x )
      bb = [ aa(1:selected_index-1); aa(selected_index+1:x) ];
    else
      bb = aa(1:selected_index-1);
    end;

  else
    bb = aa(2:x);
  end;

  set( sels, 'String', bb, 'Value', 1) ;
  handles.output.condition_name = bb;

  % Update handles structure
  guidata(hObject, handles);
  [x y] = size(handles.output.condition_name);
  if ( handles.output.conditions > x ) set( handles.btn_AddCondition, 'Enable', 'on' ); end;
  if ( y == 0 ) 
    set( handles.btn_DeleteCondition, 'Enable', 'off' ); 
    set( handles.btn_EditCondition, 'Enable', 'off' ); 
    set( handles.sel_ConditionLinestyle, 'Enable', 'off' );
    set( handles.sel_ConditionMarkerstyle, 'Enable', 'off' );
  end;


% --- Executes on button press in btn_EditCondition.
function btn_EditCondition_Callback(hObject, eventdata, handles)
% hObject    handle to btn_EditCondition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  sels = findobj('Tag','lst_ExtConditions');
  aa = get( sels, 'String') ;
  [x y] = size( aa );
  if ( x == 0 )  % empty list
    return
  end;

  selected_index = get( sels, 'Value') ;
  newEntry = inputdlg('Enter the condition name','Add condition name', 1, aa(selected_index) );
  if ( ~isempty( newEntry ) ) 
    aa(selected_index) = newEntry;
    set( sels, 'String', aa, 'Value', 1) ;
    
  end; 
  handles.output.condition_name = aa;
 % Update handles structure
guidata(hObject, handles);
 

% --- Executes on button press in btn_Okay.
function btn_Okay_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Okay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 uiresume(handles.figure1);


% --- Executes on button press in btn_Cancel.
function btn_Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = '';
% Update handles structure
guidata(hObject, handles);
uiresume(handles.figure1);



function txt_YAxis_Callback(hObject, eventdata, handles)
% hObject    handle to txt_YAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  handles.output.plotting.global.label.y_axis = get(hObject,'String') ;
  % Update handles structure
  guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function txt_YAxis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_YAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_Title_Callback(hObject, eventdata, handles)
% hObject    handle to txt_Title (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_Title as text
%        str2double(get(hObject,'String')) returns contents of txt_Title as a double


% --- Executes during object creation, after setting all properties.
function txt_Title_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_Title (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_ConditionMarkercolor.
function btn_ConditionMarkercolor_Callback(hObject, eventdata, handles)
% hObject    handle to btn_ConditionMarkercolor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  idx = get(handles.lst_ExtConditions,'Value');
  handles.output.plotting.extended.plotting(idx).settings.markercolor = uisetcolor();  

  % Update handles structure
  guidata(hObject, handles);

  [x y] = size(handles.output.plotting.extended.plotting(idx).settings.markercolor);
  if ( y > 1 )          % cancel returns a single double value of 0, otherwise 1 x 3 array
    set( hObject, 'ForegroundColor', handles.output.plotting.extended.plotting(idx).settings.markercolor );
  else
    set( hObject, 'ForegroundColor', [0 0 0] );
  end;



function txt_GlobalLinesize_Callback(hObject, eventdata, handles)
% hObject    handle to txt_GlobalLinesize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  str = get(hObject,'String');
  str = validate_numeric_entry( str );
  set(hObject,'String', str );

  handles.output.plotting.global.line.size = str2double(str);
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function txt_GlobalLinesize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_GlobalLinesize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chk_GlobalMarkeredge.
function chk_GlobalMarkeredge_Callback(hObject, eventdata, handles)
% hObject    handle to chk_GlobalMarkeredge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.output.plotting.global.marker.edge = get(hObject,'Value');
  state = 'off';
  if ( handles.output.plotting.global.marker.edge == 1 )  state = 'on'; end;
  set ( handles.btn_GlobalMarkeredgeColor, 'Enable', state );
% Update handles structure
guidata(hObject, handles);

% Hint: get(hObject,'Value') returns toggle state of chk_GlobalMarkeredge


% --- Executes on button press in chk_UseExtended.
function chk_UseExtended_Callback(hObject, eventdata, handles)
% hObject    handle to chk_UseExtended (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  handles.output.plotting.use_extended = get(hObject,'Value');
  % Update handles structure
  guidata(hObject, handles);

  ext_state = 'off';
  if ( handles.output.plotting.use_extended == 1 ) ext_state = 'on'; end;

  [x y] = size(handles.output.condition_name);
  if ( handles.output.conditions > x ) set( handles.btn_AddCondition, 'Enable', ext_state ); end;
  if ( y == 0 ) 
    set( handles.btn_DeleteCondition, 'Enable', 'off' ); 
    set( handles.btn_EditCondition, 'Enable', 'off' ); 
    set( handles.sel_ConditionLinestyle, 'Enable', 'off' );
    set( handles.sel_ConditionMarkerstyle, 'Enable', 'off' );
  else
    set( handles.lst_ExtConditions, 'Enable', ext_state );
    set( handles.btn_AddCondition, 'Enable', ext_state );
    set( handles.btn_DeleteCondition, 'Enable', ext_state ); 
    set( handles.btn_EditCondition, 'Enable', ext_state ); 
    set( handles.sel_ConditionLinestyle, 'Enable', ext_state );
    set( handles.sel_ConditionMarkerstyle, 'Enable', ext_state );
  end;
  


% --- Executes on button press in btn_PreviewPlot.
function btn_PreviewPlot_Callback(hObject, eventdata, handles)
% hObject    handle to btn_PreviewPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%global plotstyles;

  r = handles.output.conditions;
  % create a random array for each condition, which cleary distinguishes
  % between each condition
  smp = [];
  mul = 0;
  neg = 1;
  for ( ii = 1: r )
%    add2 = floor(mul);
    add2 = ii -1;
    smp = [smp (rand( 10, 1 )+add2)*neg];     % a random array of n conditions
%    neg = neg * -1;
%    mul = mul + .5;
  end;

  show_plot( smp, handles.output, 'Plot Preview' );

  


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = '';
% Update handles structure
guidata(hObject, handles);
uiresume(handles.figure1);
%delete(hObject);



function set_button_text_color( button_handle, color )
  enabled = get( button_handle, 'Enable' );
  if ( strcmp ( enabled, 'on' ) )
    [x y] = size(color);
    if ( y > 1 )          % cancel returns a single double value of 0, otherwise 1 x 3 array
      set( button_handle, 'ForegroundColor', color );
    else
      set( button_handle, 'ForegroundColor', [0 0 0] );
    end;

  else
    set( button_handle, 'ForegroundColor', [0 0 0] );
  end;


% --- Executes on selection change in lst_SelectedConditions.
function lst_SelectedConditions_Callback(hObject, eventdata, handles)
% hObject    handle to lst_SelectedConditions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns lst_SelectedConditions contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lst_SelectedConditions
  % If double click
  if strcmp(get(handles.figure1,'SelectionType'),'open')

    % get the selected conditions list
    sels = findobj('Tag','lst_SelectedConditions');
    aa = get( sels, 'String') ;
    [x y] = size( aa );
    if ( x == 0 )  % empty list
      return
    end;

    selected_index = get( sels, 'Value') ;

    % remove this condition from selected list
    if ( selected_index > 1 )

      if ( selected_index < x )
        bb = [ aa(1:selected_index-1); aa(selected_index+1:x) ];
      else
        bb = aa(1:selected_index-1);
      end;

    else
      bb = aa(2:x);
    end;

    bb = sort(bb);
    set( sels, 'String', bb, 'Value', 1) ;

    handles.output.plotting.selected_conditions = bb;
    guidata(hObject, handles);

  end;


% --- Executes during object creation, after setting all properties.
function lst_SelectedConditions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_SelectedConditions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chk_SelectedConditions.
function chk_SelectedConditions_Callback(hObject, eventdata, handles)
% hObject    handle to chk_SelectedConditions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  x = get(hObject,'Value');
  h = findobj('Tag','lst_SelectedConditions');
  if ( x )
    set( h, 'Enable', 'On' );
  else
    set( h, 'Enable', 'Off' );
  end;

  handles.output.plotting.use_selected_conditions = x;
  guidata(hObject, handles);


function select_condition( hObject, handles )

  conds = findobj('Tag','lst_ExtConditions');
  selected_index = get( conds, 'Value') ;
  aa = get( conds, 'String') ;

  [x y] = size( aa );
  if ( x == 0 )  % empty list
    return
  end;

  thisone = aa{selected_index};

  sels = findobj('Tag','lst_SelectedConditions');
  bb = get( sels, 'String') ;

  % place this subject into selected list
  [x y] = size( bb );
  if ( y > 0 )  % non empty list
    bb = [bb; {thisone}];
  else
    bb = {thisone};
  end;
  bb = sort(bb);

  set( sels, 'String', bb, 'Value', 1) ;
  thisone = aa{selected_index};

  handles.output.plotting.selected_conditions = bb;
  guidata(hObject, handles);


% --- Executes on selection change in lst_loadingsIndex.
function lst_loadingsIndex_Callback(hObject, eventdata, handles)
% hObject    handle to lst_loadingsIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.output.betas = get(hObject,'Value');
  guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function lst_loadingsIndex_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_loadingsIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


