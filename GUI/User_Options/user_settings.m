function varargout = PREFERENCESs(varargin)
% PREFERENCESS M-file for PREFERENCESs.fig
%      PREFERENCESS, by itself, creates a new PREFERENCESS or raises the existing
%      singleton*.
%
%      H = PREFERENCESS returns the handle to a new PREFERENCESS or the handle to
%      the existing singleton*.
%
%      PREFERENCESS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PREFERENCESS.M with the given input arguments.
%
%      PREFERENCESS('Property','Value',...) creates a new PREFERENCESS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PREFERENCESs_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PREFERENCESs_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PREFERENCESs

% Last Modified by GUIDE v2.5 07-Jun-2019 12:55:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PREFERENCESs_OpeningFcn, ...
                   'gui_OutputFcn',  @PREFERENCESs_OutputFcn, ...
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


% --- Executes just before PREFERENCESs is made visible.
function PREFERENCESs_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for PREFERENCESs
  handles.output = hObject;
  handles.prefs = constant_define( 'PREFERENCES', 'LOAD' );

  set ( handles.chk_Z_GC, 'Value', handles.prefs.general.large_variable_creation(1, 1) );
  set ( handles.chk_Z_E, 'Value',  handles.prefs.general.large_variable_creation(1, 2) );
  set ( handles.chk_H_BH, 'Value', handles.prefs.general.large_variable_creation(2, 1) );
  set ( handles.chk_H_E, 'Value',  handles.prefs.general.large_variable_creation(2, 2) );
  
  set ( handles.txt_max_partition_mem, 'String', num2str( handles.prefs.general.max_partition_mem ) );
  set ( handles.chk_duplicate_images, 'Value', handles.prefs.general.duplicate_images );
  set ( handles.chk_fx, 'Value', handles.prefs.general.fisherXform );
  set ( handles.chk_MissingSourceTiming, 'Value', handles.prefs.general.MissingSourceTiming );
  set ( handles.chk_gray_matter, 'Value', handles.prefs.general.gray_matter );
  set ( handles.chk_white_matter, 'Value', handles.prefs.general.white_matter );
  set ( handles.chk_whole_brain, 'Value', handles.prefs.general.whole_brain );
%   set ( handles.chk_remove_ventricles, 'Value', handles.prefs.general.remove_ventricles );

  handles.prefs.calculate_altPR = handles.prefs.general.calculate_altPR * handles.prefs.general.large_variable_creation(1, 1);
  set ( handles.chk_AltPR, 'Enable', constant_define( 'STATE', handles.prefs.general.large_variable_creation(1, 1) ) );
  set ( handles.chk_AltPR, 'Value', handles.prefs.general.calculate_altPR * handles.prefs.general.large_variable_creation(1, 1) );

  
  set ( handles.txt_gen_decimals, 'String', regexp( handles.prefs.precision.default, '[0-9]', 'match' ) );
  set ( handles.txt_stats_decimals, 'String', regexp( handles.prefs.precision.stats, '[0-9]', 'match' ) );
  set ( handles.txt_ccf_decimals, 'String', regexp( handles.prefs.precision.ccf, '[0-9]', 'match' ) );


  set ( handles.btn_1_percent,  'Value', handles.prefs.threshold.default == 1 );
  set ( handles.btn_5_percent,  'Value', handles.prefs.threshold.default == 2 );
  set ( handles.btn_10_percent, 'Value', handles.prefs.threshold.default == 3 );
  set ( handles.btn_20_percent, 'Value', handles.prefs.threshold.default == 4 );
  set ( handles.btn_30_percent, 'Value', handles.prefs.threshold.default == 5 );

  set ( handles.chk_1_percent,  'Value', handles.prefs.threshold.active(1) );
  set ( handles.chk_5_percent,  'Value', handles.prefs.threshold.active(2) );
  set ( handles.chk_10_percent, 'Value', handles.prefs.threshold.active(3) );
  set ( handles.chk_20_percent, 'Value', handles.prefs.threshold.active(4) );
  set ( handles.chk_30_percent, 'Value', handles.prefs.threshold.active(5) );

  set ( handles.chk_only_default, 'Value', handles.prefs.threshold.default_only );
  set ( handles.txt_cluster_minimum, 'String', num2str( handles.prefs.cluster.minimum_mm3 ) );
  set ( handles.chk_cluster_masks, 'Value', handles.prefs.cluster.create_masks ) ;
  set ( handles.chk_cluster_mean, 'Value', handles.prefs.cluster.calculate_mean | handles.prefs.cluster.calculate_median ) ;


  x = check_memory();
  mgb = x.user.total * handles.prefs.general.cache_percent / 100000;
  str = sprintf( '%.2f GB', mgb );
  set ( handles.lbl_GB_cache, 'String', str );


  chk_Z_GC_Callback( handles.chk_Z_GC, 0, handles );
  chk_H_BH_Callback( handles.chk_H_BH, 0, handles );

  if ~ispc() & ismac()
    disable_frame ( handles.frm_linux_cache );
  end
  
  
  
  % Update handles structure
  guidata(hObject, handles);

  % UIWAIT makes PREFERENCESs wait for user response (see UIRESUME)
  uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PREFERENCESs_OutputFcn(hObject, eventdata, handles) 
  % Get default command line output from handles structure
  varargout{1} = handles.output;
  delete( handles.figure1 );



% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)

  handles.output = [];
  guidata(handles.figure1, handles);
  uiresume(handles.figure1);


% --- Executes on button press in btn_okay.
function btn_okay_Callback(hObject, eventdata, handles)

%   x = get(handles.txt_max_partition_mem,'String');
  handles.prefs.general.max_partition_mem = str2num( get(handles.txt_max_partition_mem,'String') );
  handles.prefs.general.default_ROI_vox = str2num( get(handles.txt_ROI_default_voxels,'String') );
  handles.prefs.precision.default = [ '%.' char(get(handles.txt_gen_decimals ,'String')) 'f'];
  handles.prefs.precision.stats = [ '%.'   char(get(handles.txt_stats_decimals ,'String')) 'f'];
  handles.prefs.precision.ccf = [ '%.'     char(get(handles.txt_ccf_decimals ,'String')) 'f'];
  
%   x = get(handles.txt_gen_decimals ,'String');

%   x = get(handles.txt_stats_decimals ,'String');

  handles.output = handles.prefs;
  guidata(handles.figure1, handles);
  uiresume(handles.figure1);


% --- Executes on button press in btn_cancel.
function btn_cancel_Callback(hObject, eventdata, handles)

  handles.output = [];
  guidata(handles.figure1, handles);
  uiresume(handles.figure1);



function txt_max_partition_mem_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function txt_max_partition_mem_CreateFcn(hObject, eventdata, handles)

  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end



function txt_gen_decimals_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function txt_gen_decimals_CreateFcn(hObject, eventdata, handles)

  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end



function txt_stats_decimals_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function txt_stats_decimals_CreateFcn(hObject, eventdata, handles)

  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end




% --- Executes on button press in btn_1_percent.
function btn_1_percent_Callback(hObject, eventdata, handles)

  handles.prefs.threshold.default = 1;
  set ( handles.btn_1_percent, 'Value', 1 );
  set ( handles.btn_5_percent, 'Value', 0 );
  set( handles.btn_10_percent, 'Value', 0 );
  set( handles.btn_20_percent, 'Value', 0 );
  set( handles.btn_30_percent, 'Value', 0 );

  guidata(handles.figure1, handles);


% --- Executes on button press in btn_5_percent.
function btn_5_percent_Callback(hObject, eventdata, handles)

  handles.prefs.threshold.default = 2;
  set ( handles.btn_1_percent, 'Value', 0 );
  set ( handles.btn_5_percent, 'Value', 1 );
  set( handles.btn_10_percent, 'Value', 0 );
  set( handles.btn_20_percent, 'Value', 0 );
  set( handles.btn_30_percent, 'Value', 0 );
 
  guidata(handles.figure1, handles);


% --- Executes on button press in btn_10_percent.
function btn_10_percent_Callback(hObject, eventdata, handles)

  handles.prefs.threshold.default = 3;
  set ( handles.btn_1_percent, 'Value', 0 );
  set ( handles.btn_5_percent, 'Value', 0 );
  set( handles.btn_10_percent, 'Value', 1 );
  set( handles.btn_20_percent, 'Value', 0 );
  set( handles.btn_30_percent, 'Value', 0 );

  guidata(handles.figure1, handles);


% --- Executes on button press in figure1.
function btn_20_percent_Callback(hObject, eventdata, handles)

  handles.prefs.threshold.default = 4;
  set ( handles.btn_1_percent, 'Value', 0 );
  set ( handles.btn_5_percent, 'Value', 0 );
  set( handles.btn_10_percent, 'Value', 0 );
  set( handles.btn_20_percent, 'Value', 1 );
  set( handles.btn_30_percent, 'Value', 0 );

  guidata(handles.figure1, handles);


% --- Executes on button press in btn_30_percent.
function btn_30_percent_Callback(hObject, eventdata, handles)

  handles.prefs.threshold.default = 5;
  set ( handles.btn_1_percent, 'Value', 0 );
  set ( handles.btn_5_percent, 'Value', 0 );
  set( handles.btn_10_percent, 'Value', 0 );
  set( handles.btn_20_percent, 'Value', 0 );
  set( handles.btn_30_percent, 'Value', 1 );

  guidata(handles.figure1, handles);



function txt_cache_percentage_Callback(hObject, eventdata, handles)
% hObject    handle to txt_cache_percentage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.prefs.general.cache_percent = str2num(get(hObject,'String'));
  x = check_memory();
  mgb = x.user.total * handles.prefs.general.cache_percent / 100000;
  str = sprintf( '%.2f GB', mgb );
  set ( handles.lbl_GB_cache, 'String', str );

  guidata(handles.figure1, handles);



% --- Executes during object creation, after setting all properties.
function txt_cache_percentage_CreateFcn(hObject, eventdata, handles)

  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end


% --- Executes on key press with focus on txt_cache_percentage and none of its controls.
function txt_cache_percentage_KeyPressFcn(hObject, eventdata, handles)

  guidata(handles.figure1, handles);

  drawnow();
  txt_cache_percentage_Callback( handles.txt_cache_percentage, 0, handles );


% --- Executes on button press in chk_Z_GC.
function chk_Z_GC_Callback(hObject, eventdata, handles)

  handles.prefs.general.large_variable_creation(1,1) = get(hObject,'Value');
  handles.prefs.general.large_variable_creation(1,2) = handles.prefs.general.large_variable_creation(1,2) * handles.prefs.general.large_variable_creation(1,1);
  handles.prefs.general.calculate_altPR = handles.prefs.general.calculate_altPR * handles.prefs.general.large_variable_creation(1,1);
  guidata(handles.figure1, handles);

  set( handles.chk_Z_E, 'Enable',   constant_define( 'STATE', handles.prefs.general.large_variable_creation(1,1) ) );
  set( handles.chk_AltPR, 'Enable', constant_define( 'STATE', handles.prefs.general.large_variable_creation(1,1) ) );
  set( handles.chk_AltPR, 'Value',  handles.prefs.general.calculate_altPR );



% --- Executes on button press in chk_Z_E.
function chk_Z_E_Callback(hObject, eventdata, handles)

  handles.prefs.general.large_variable_creation(1,2) = get(hObject,'Value');
  handles.prefs.general.large_variable_creation(1,2) = handles.prefs.general.large_variable_creation(1,2) * handles.prefs.general.large_variable_creation(1,1);
  set( handles.chk_Z_E, 'Value',   handles.prefs.general.large_variable_creation(1,2) );
  
  guidata(handles.figure1, handles);


% --- Executes on button press in chk_H_BH.
function chk_H_BH_Callback(hObject, eventdata, handles)

  handles.prefs.general.large_variable_creation(2,1) = get(hObject,'Value');
  handles.prefs.general.large_variable_creation(2,2) = handles.prefs.general.large_variable_creation(2,2) * handles.prefs.general.large_variable_creation(2,1);
  guidata(handles.figure1, handles);

  set( handles.chk_H_E, 'Enable', constant_define( 'STATE', handles.prefs.general.large_variable_creation(2,1) ) );


% --- Executes on button press in chk_H_E.
function chk_H_E_Callback(hObject, eventdata, handles)

  handles.prefs.general.large_variable_creation(2,2) = get(hObject,'Value');
  guidata(handles.figure1, handles);


% --- Executes on button press in chk_fx.
function chk_fx_Callback(hObject, eventdata, handles)

  handles.prefs.general.fisherXform = get(hObject,'Value');
  guidata(handles.figure1, handles);


% --- Executes on button press in chk_only_default.
function chk_only_default_Callback(hObject, eventdata, handles)

  x = get(hObject,'Value') ;
  handles.prefs.threshold.default_only = x;
  guidata(handles.figure1, handles);


% --- Executes on button press in chk_1_percent.
function chk_1_percent_Callback(hObject, eventdata, handles)

  x = get(hObject,'Value') ;
  handles.prefs.threshold.active(1) = x;
  guidata(handles.figure1, handles);


% --- Executes on button press in chk_5_percent.
function chk_5_percent_Callback(hObject, eventdata, handles)

  x = get(hObject,'Value') ;
  handles.prefs.threshold.active(2) = x;
  guidata(handles.figure1, handles);


% --- Executes on button press in chk_10_percent.
function chk_10_percent_Callback(hObject, eventdata, handles)

  x = get(hObject,'Value') ;
  handles.prefs.athreshold.active(3) = x;
  guidata(handles.figure1, handles);


% --- Executes on button press in chk_20_percent.
function chk_20_percent_Callback(hObject, eventdata, handles)

  x = get(hObject,'Value') ;
  handles.prefs.threshold.active(4) = x;
  guidata(handles.figure1, handles);


% --- Executes on button press in chk_30_percent.
function chk_30_percent_Callback(hObject, eventdata, handles)

  x = get(hObject,'Value') ;
  handles.prefs.threshold.active(5) = x;
  guidata(handles.figure1, handles);
 



function txt_cluster_minimum_Callback(hObject, eventdata, handles)

  handles.prefs.cluster.minimum_mm3 = str2num(get(hObject,'String'));
  guidata(handles.figure1, handles);


% --- Executes during object creation, after setting all properties.
function txt_cluster_minimum_CreateFcn(hObject, eventdata, handles)

  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end


% --- Executes on button press in chk_duplicate_images.
function chk_duplicate_images_Callback(hObject, eventdata, handles)

  handles.prefs.general.duplicate_images = get(hObject,'Value');
  guidata(handles.figure1, handles);


% --- Executes on button press in chk_AltPR.
function chk_AltPR_Callback(hObject, eventdata, handles)

  handles.prefs.general.calculate_altPR = get(hObject,'Value');;
  guidata(handles.figure1, handles);


% --- Executes on button press in chk_MissingSourceTiming.
function chk_MissingSourceTiming_Callback(hObject, eventdata, handles)

  handles.prefs.general.MissingSourceTiming = get(hObject,'Value');;
  guidata(handles.figure1, handles);



function txt_ccf_decimals_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function txt_ccf_decimals_CreateFcn(hObject, eventdata, handles)

  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end


% --- Executes on button press in chk_cluster_masks.
function chk_cluster_masks_Callback(hObject, eventdata, handles)

  x = get(hObject,'Value') ;
  handles.prefs.cluster.create_masks = x;
  guidata(handles.figure1, handles);

% --- Executes on button press in chk_cluster_mean.
function chk_cluster_mean_Callback(hObject, eventdata, handles)
  x = get(hObject,'Value') ;
  handles.prefs.cluster.calculate_mean = x;
  handles.prefs.cluster.calculate_median = x;
  guidata(handles.figure1, handles);



function txt_ROI_default_voxels_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function txt_ROI_default_voxels_CreateFcn(hObject, eventdata, handles)

  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end


% --- Executes on button press in chk_gray_matter.
function chk_gray_matter_Callback(hObject, eventdata, handles)

  handles.prefs.general.gray_matter = get(hObject,'Value');
  guidata(handles.figure1, handles);


% --- Executes on button press in chk_white_matter.
function chk_white_matter_Callback(hObject, eventdata, handles)

  handles.prefs.general.white_matter = get(hObject,'Value');
  guidata(handles.figure1, handles);


% --- Executes on button press in chk_whole_brain.
function chk_whole_brain_Callback(hObject, eventdata, handles)

  handles.prefs.general.whole_brain = get(hObject,'Value');
  guidata(handles.figure1, handles);


% --- Executes during object creation, after setting all properties.
function chk_Z_E_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chk_Z_E (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
