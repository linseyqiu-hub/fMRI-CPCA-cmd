function varargout = Utilities(varargin)
% UTILITIES M-file for Utilities.fig
%      UTILITIES, by itself, creates a new UTILITIES or raises the existing
%      singleton*.
%
%      H = UTILITIES returns the handle to a new UTILITIES or the handle to
%      the existing singleton*.
%
%      UTILITIES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UTILITIES.M with the given input arguments.
%
%      UTILITIES('Property','Value',...) creates a new UTILITIES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Utilities_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Utilities_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Utilities

% Last Modified by GUIDE v2.5 10-Mar-2014 15:10:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Utilities_OpeningFcn, ...
                   'gui_OutputFcn',  @Utilities_OutputFcn, ...
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


% --- Executes just before Utilities is made visible.
function Utilities_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Utilities (see VARARGIN)

% Choose default command line output for Utilities
handles.output = hObject;

  if(nargin > 3)
    for index = 1:2:(nargin-3),
      if nargin-3==index, break, end
        switch lower(varargin{index})
         case 'zheader'
          handles.Zheader = varargin{index+1};
         case 'scaninfo'
          handles.scan_information = varargin{index+1};

      end;
    end;
  end

  handles.Gheader = [];

  if isfield( handles, 'scan_information' )
    if size( handles.scan_information.mask.image, 2 ) > 0 
      set( handles.chk_LeftHemi, 'Enable', 'on' );
      set( handles.chk_RightHemi, 'Enable', 'on' );
    end;
  end;
  
  if length( handles.Zheader.Model.path ) > 0 
    load( handles.Zheader.Model.path,  'Gheader' );
    handles.Gheader = Gheader;
    set( handles.btn_create_G_covariate, 'Enable', 'on' );
  end;

  set( handles.txt_num_subjects, 'String', num2str( handles.Zheader.num_subjects ) );
  set( handles.txt_num_scans, 'String', num2str( handles.Zheader.total_scans ) );
  set( handles.txt_num_voxels, 'String', num2str( handles.Zheader.total_columns ) );

  if isstruct( handles.Gheader )
    if isfield( handles.Gheader, 'conditions' )
      set( handles.txt_num_conditions, 'String', num2str( handles.Gheader.conditions ) );
    end;
    if isfield( handles.Gheader, 'bins' )
      set( handles.txt_num_bins, 'String', num2str( handles.Gheader.bins ) );
    end;

  else
    set( handles.btn_debug_data, 'Enable', 'off' );
%    set( handles.chk_all_sub_all_condition, 'Enable', 'off' );
%    set( handles.chk_all_sub_each_condition, 'Enable', 'off' );
%    set( handles.chk_each_sub_all_condition, 'Enable', 'off' );
%    set( handles.chk_each_sub_each_condition, 'Enable', 'off' );
    set( handles.btn_mean_beta_images, 'Enable', 'off' );

  end;

  handles.algs = [];

  A = struct( 'category', '', 'algs', [] );
  cat = A;
  cat.category = 'General';
  cat.algs = [{'Subject Normalization'} {'normalize_subject'}; ...
 {'Mask Creation'} {'create_mask'}; ...      
 {'Mask Verification'} {'verify_user_mask'}; ...
 {'HRF Shapes'} {'hrf_shape_creation'}];

  handles.algs = [handles.algs; cat];

  cat = A;
  cat.category = 'G Model';
cat.algs = [{'G Creation'} {'create_g_new'}; ...
 {'G Application'} {'apply_partitioned_to_Z'}; ...
 {'Component Extraction'} {'extract_g_components'}; ...
 {'Image Creation'} {'g_images_unrotated'}];

  handles.algs = [handles.algs; cat];

  cat = A;
  cat.category = 'H Processing';
  cat.algs = [{'Apply H to E, Z or GZ'} {'apply_H_to_Z_data'}; {'Extract from HE/HZ'} {'extract_h_components'}; {'Image Creation'} {'h_images_unrotated'}];
  handles.algs = [handles.algs; cat];

  cat = A;
  cat.category = 'Images';
  cat.algs = [{'Nifti Structure'} {'_nifti_structure_definition'}; {'Read NIFTI images'} {'cpca_nifti_vol'}; {'Read ANALYSE images'} {'cpca_analyse_vol'}];
  handles.algs = [handles.algs; cat];

  cat = A;
  cat.category = 'Statistics';
  cat.algs = [{'Beta Calculation'} {'calc_c_betas'}; {'Extreme Pos/Neg'} {'calc_ext_Pos_Neg'}];
  handles.algs = [handles.algs; cat];



  str = [];
  for ( ii = 1:size(handles.algs, 1 ) )
    str = [str; {handles.algs(ii).category}];
  end

  set( handles.lst_algorithm_categories, 'String', str);
  set( handles.lst_algorithms, 'String', handles.algs(1).algs(:,1) );

  % Update handles structure
  guidata(hObject, handles);


% UIWAIT makes Utilities wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Utilities_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btn_debug_data.
function btn_debug_data_Callback(hObject, eventdata, handles)
% hObject    handle to btn_debug_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  eval( ['load( '''  handles.Zheader.Model.path  ''', ''Gheader'' )' ] );
  x = exist( 'Gheader', 'var' );
  if ( x )
    x = debug_data(Gheader);
    str = evalc( ['debug_data_display( x, Gheader)'] );

    if length(str) > 0 
      fid = fopen( 'debug_information.txt', 'w' );
      if (fid )
        fprintf( fid, '%s', str );
        fclose( fid );
      end;
    end;

  else
    str = [{'Unable to load Gheader from path:'} {handles.Zheader.Model.path}];
  end;

  set( handles.txt_results, 'String', str );


% --- Executes on button press in btn_analysis_mem.
function btn_analysis_mem_Callback(hObject, eventdata, handles)
% hObject    handle to btn_analysis_mem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  nsubs = str2num(get( handles.txt_num_subjects, 'String' ));
  nscans = str2num(get( handles.txt_num_scans, 'String' ));
  nvox = str2num(get( handles.txt_num_voxels, 'String' ));

  nconds = str2num(get( handles.txt_num_conditions, 'String' ) );
  nbins = str2num(get( handles.txt_num_bins, 'String' ));

  txt = [];
  
  mx = array_sizes( [round(nscans/nsubs) nvox] );

  x = array_sizes( [(nscans * nsubs) nvox] );
  str = ['Z: [' num2str((nscans * nsubs)) ' x ' num2str(nvox) ']   ' x.mem_display ];
  txt = [txt;  {str}];

  gw = nconds*nbins*nsubs;
  x = array_sizes( [(nscans * nsubs) gw] );
  str = ['G: [' num2str((nscans * nsubs)) ' x ' num2str(gw) ']   ' x.mem_display ];
  txt = [txt; {str}];
  if ( x.bytes > mx.bytes ) mx = x; end;

  x = array_sizes( [gw nvox] );
  str = ['C: [' num2str(gw) ' x ' num2str(nvox) ']   ' x.mem_display ];
  txt = [txt; {str}];
  if ( x.bytes > mx.bytes ) mx = x; end;

  x = array_sizes( [gw gw] );
  str = ['CC: [' num2str(gw) ' x ' num2str(gw) ']   ' x.mem_display ];
  txt = [txt; {str}];
  if ( x.bytes > mx.bytes ) mx = x; end;

  x = array_sizes( [gw nconds] );
  str = ['U: [' num2str(gw) ' x ' num2str(nconds) ']   ' x.mem_display ];
  txt = [txt; {str}];
  if ( x.bytes > mx.bytes ) mx = x; end;

  x = array_sizes( [(nscans * nsubs) nconds] );
  str = ['F: [' num2str((nscans * nsubs)) ' x ' num2str(nconds) ']   ' x.mem_display ];
  txt = [txt; {str}];
  if ( x.bytes > mx.bytes ) mx = x; end;

  x = array_sizes( [(nscans * nsubs) nconds] );
  str = ['V: [' num2str(nvox) ' x ' num2str(nconds) ']   ' x.mem_display ];
  txt = [txt; {str}];
  if ( x.bytes > mx.bytes ) mx = x; end;

  inst_mem = [{'2 GB'} {'4 GB'} {'8 GB'} {'16 GB'} {'24 GB'} {'32 GB'} {'64 GB'} {'96+ GB'}  ];
  int_cmp =  [ 2e+09    4e+09    8e+09    16e+09    24e+09    32e+09    64e+09     96e+09];

  ii = 1;
  while ( mx.bytes > int_cmp(ii) )
    ii = ii + 1;
    if ( ii > size(int_cmp,2) )  ii = size(int_cmp,2); break; end;
  end;

  str = ['minimum suggested installed memory: ' char(inst_mem(ii)) ];
  txt = [txt; {' '}; {str}];

  
  set( handles.txt_results, 'String', txt );



function txt_num_subjects_Callback(hObject, eventdata, handles)
% hObject    handle to txt_num_subjects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_num_subjects as text
%        str2double(get(hObject,'String')) returns contents of txt_num_subjects as a double


% --- Executes during object creation, after setting all properties.
function txt_num_subjects_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_num_subjects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_num_scans_Callback(hObject, eventdata, handles)
% hObject    handle to txt_num_scans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_num_scans as text
%        str2double(get(hObject,'String')) returns contents of txt_num_scans as a double


% --- Executes during object creation, after setting all properties.
function txt_num_scans_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_num_scans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_num_voxels_Callback(hObject, eventdata, handles)
% hObject    handle to txt_num_voxels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_num_voxels as text
%        str2double(get(hObject,'String')) returns contents of txt_num_voxels as a double


% --- Executes during object creation, after setting all properties.
function txt_num_voxels_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_num_voxels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_num_conditions_Callback(hObject, eventdata, handles)
% hObject    handle to txt_num_conditions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_num_conditions as text
%        str2double(get(hObject,'String')) returns contents of txt_num_conditions as a double


% --- Executes during object creation, after setting all properties.
function txt_num_conditions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_num_conditions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_num_bins_Callback(hObject, eventdata, handles)
% hObject    handle to txt_num_bins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_num_bins as text
%        str2double(get(hObject,'String')) returns contents of txt_num_bins as a double


% --- Executes during object creation, after setting all properties.
function txt_num_bins_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_num_bins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_results_Callback(hObject, eventdata, handles)
% hObject    handle to txt_results (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_results as text
%        str2double(get(hObject,'String')) returns contents of txt_results as a double


% --- Executes during object creation, after setting all properties.
function txt_results_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_results (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_mean_beta_images.
function btn_mean_beta_images_Callback(hObject, eventdata, handles)
% hObject    handle to btn_mean_beta_images (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  eval( ['load( '''  handles.Zheader.Model.path  ''', ''Gheader'' )' ] );
  x = exist( 'Gheader', 'var' );
  if ( x )
    txt = [{'Creating beta average images . . . please wait . . '}];
    set( handles.txt_results, 'String', txt );
    drawnow();

    mean_beta_images( Gheader );

    txt = [txt; {' --- [Done]'}; {' '}];
    set( handles.txt_results, 'String', txt );

  else

    set( handles.txt_results, 'String', 'Error loading the G header' );
  
  end

  drawnow();



function txt_arr_rows_Callback(hObject, eventdata, handles)
% hObject    handle to txt_arr_rows (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_arr_rows as text
%        str2double(get(hObject,'String')) returns contents of txt_arr_rows as a double
  x = str2double(get(handles.txt_arr_cols,'String'));
  if ( x > 0 ) set( handles.btn_array_sizes, 'Enable', 'on' ); end;


% --- Executes during object creation, after setting all properties.
function txt_arr_rows_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_arr_rows (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_arr_cols_Callback(hObject, eventdata, handles)
% hObject    handle to txt_arr_cols (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_arr_cols as text
%        str2double(get(hObject,'String')) returns contents of txt_arr_cols as a double
  x = str2double(get(handles.txt_arr_rows,'String'));
  if ( x > 0 ) set( handles.btn_array_sizes, 'Enable', 'on' ); end;


% --- Executes during object creation, after setting all properties.
function txt_arr_cols_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_arr_cols (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_array_sizes.
function btn_array_sizes_Callback(hObject, eventdata, handles)
% hObject    handle to btn_array_sizes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  x = str2double(get(handles.txt_arr_rows,'String'));
  y = str2double(get(handles.txt_arr_cols,'String'));

  res = array_sizes( [ x y ] );
  set( handles.lbl_arr_mem, 'String', res.mem_display );


% --- Executes on selection change in lst_algorithms.
function lst_algorithms_Callback(hObject, eventdata, handles)
% hObject    handle to lst_algorithms (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns lst_algorithms contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lst_algorithms


% --- Executes during object creation, after setting all properties.
function lst_algorithms_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_algorithms (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chk_append_code.
function chk_append_code_Callback(hObject, eventdata, handles)
% hObject    handle to chk_append_code (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_append_code


% --- Executes on button press in btn_show_algorithm.
function btn_show_algorithm_Callback(hObject, eventdata, handles)
% hObject    handle to btn_show_algorithm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  x = get( handles.lst_algorithms, 'Value' );
  y = get( handles.chk_append_code, 'Value' );
  idx = get( handles.lst_algorithm_categories,'Value');
 
  str = char(handles.algs(idx).algs( x, 2 ) );

  txt = [];
  if ( y )
    txt = get( handles.txt_results, 'String');
  end;

  mc = retrieve_math( str );
  txt = [txt; mc ];
  set( handles.txt_results, 'String', txt);


% --- Executes on selection change in lst_algorithm_categories.
function lst_algorithm_categories_Callback(hObject, eventdata, handles)
% hObject    handle to lst_algorithm_categories (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns lst_algorithm_categories contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lst_algorithm_categories
  x = get(hObject,'Value');
  set( handles.lst_algorithms, 'String', handles.algs(x).algs(:,1) );

% --- Executes during object creation, after setting all properties.
function lst_algorithm_categories_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_algorithm_categories (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chk_LeftHemi.
function chk_LeftHemi_Callback(hObject, eventdata, handles)
% hObject    handle to chk_LeftHemi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%  set(hObject,'Value', ~get(hObject,'Value'));
  x = get(hObject,'Value') | get( handles.chk_RightHemi, 'Value' );
  if(x)
    set( handles.btn_Create_Hemi, 'Enable', 'on' );
  else
    set( handles.btn_Create_Hemi, 'Enable', 'off' );
  end;

% --- Executes on button press in chk_RightHemi.
function chk_RightHemi_Callback(hObject, eventdata, handles)
% hObject    handle to chk_RightHemi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%  set(hObject,'Value', ~get(hObject,'Value'));

  x = get(hObject,'Value') | get( handles.chk_LeftHemi, 'Value' );
  if(x)
    set( handles.btn_Create_Hemi, 'Enable', 'on' );
  else
    set( handles.btn_Create_Hemi, 'Enable', 'off' );
  end;


% --- Executes on button press in btn_Create_Hemi.
function btn_Create_Hemi_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Create_Hemi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  vol = handles.scan_information.mask;

  if get( handles.chk_LeftHemi, 'Value' )
    mni = find(vol.MNI(1,vol.ind(:))<0);
    img = zeros(size(vol.ind));
    img(mni(:)) = 1;
    write_cpca_image( '', 'left_hemisphere.img', img, vol );
    set( handles.chk_LeftHemi, 'Value', 0 );
  end;
  
  if get( handles.chk_RightHemi, 'Value' )
    mni = find(vol.MNI(1,vol.ind(:))>=0);
    img = zeros(size(vol.ind));
    img(mni(:)) = 1;
    write_cpca_image('', 'right_hemisphere.img', img, vol )
    set( handles.chk_RightHemi, 'Value', 0 );
  end;

  set( handles.btn_Create_Hemi, 'Enable', 'off' );
  
  


% --- Executes on button press in btn_create_G_covariate.
function btn_create_G_covariate_Callback(hObject, eventdata, handles)
% hObject    handle to btn_create_G_covariate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Zheader

  load( Zheader.Model.path, 'Gheader' );
  
  [s,v] = listdlg('PromptString','Select Conditions','ListString', Gheader.condition_name, 'InitialValue', 1 );

  if v
    conds = s;

    set( handles.txt_results, 'String', '');

    regression_conds = Gheader.condition_name( conds(:) );
    txt = 'creating covariates from G: ' ;
    for ii = 1:size(conds,2)
      txt = [txt [char(regression_conds(ii)) '  ' ] ] ;
    end
    set( handles.txt_results, 'String', txt);

    fn = 'covariates_derived_from_G.txt';
    if exist( fn, 'file' )
      txt = get( handles.txt_results, 'String');
      txt = [{txt}; {['Deleting file: ' fn]} ];
      set( handles.txt_results, 'String', txt);
      eval( [ 'delete ' fn] );
    end;
    
    
    for sno = 1:Zheader.num_subjects
      msg = ['Subject ' num2str(sno) ' of ' num2str(Zheader.num_subjects) ];
      set( handles.txt_results, 'String', [txt; {msg}]);
      
      A=[];
      eval( [ 'A = load( ''' [Gheader.path_to_segs 'G_S' num2str(sno) '.mat'] ''', ''Graw'' );'] );
        
      G = zeros( size(A.Graw,1), Gheader.bins);
      for c = 1:size(conds,2)
        cond = conds(c);
        s = (cond-1) * Gheader.bins + 1;
        e = s + Gheader.bins - 1;
        G = G + A.Graw(:,s:e);
      end;
      
      x = find(G);
      G(x(:)) = 1;
      G = normalize_me( G );
      
      save( fn, 'G', '-ASCII', '-APPEND' );
    end;
  
    set( handles.txt_results, 'String', [txt; {'Done . . .'}]);
    
  end;
  


% --- Executes on button press in btn_hrf_shapes_creation.
function btn_hrf_shapes_creation_Callback(hObject, eventdata, handles)
% hObject    handle to btn_hrf_shapes_creation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  create_hrf_shapes();
  
