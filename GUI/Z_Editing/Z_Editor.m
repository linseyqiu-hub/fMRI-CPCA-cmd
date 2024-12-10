function varargout = Z_Editor(varargin)
% Z_EDITOR M-file for Z_Editor.fig
%      Z_EDITOR, by itself, creates a new Z_EDITOR or raises the existing
%      singleton*.
%
%      H = Z_EDITOR returns the handle to a new Z_EDITOR or the handle to
%      the existing singleton*.
%
%      Z_EDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in Z_EDITOR.M with the given input arguments.
%
%      Z_EDITOR('Property','Value',...) creates a new Z_EDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Z_Editor_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Z_Editor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Z_Editor

% Last Modified by GUIDE v2.5 26-Apr-2011 11:38:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Z_Editor_OpeningFcn, ...
                   'gui_OutputFcn',  @Z_Editor_OutputFcn, ...
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


% --- Executes just before Z_Editor is made visible.
function Z_Editor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Z_Editor (see VARARGIN)
global Zheader scan_information  ;

  [handles.Zheader, handles.scan_information] = adjust_headers( Zheader, scan_information, Zheader.Z_Directory );
  handles.dir_char = '/';
  handles.conditions_changed = 0;
  handles.progressBar = cpca_progress();
  if ( strcmp( class(handles.progressBar), 'cpca_progress' ) )
    handles.progressBar.hide();
  end;

  if ( ispc )	handles.dir_char = '\'; 	end;

%  set( handles.btn_Cancel, 'String', 'Done' );		% [4.1.3] Cancel is now Done button

  str = num2str( handles.Zheader.num_subjects );
  set( handles.txt_num_subjects, 'String', str );

  str = num2str( handles.Zheader.num_runs );
  set( handles.txt_num_runs, 'String', str );

  str = num2str( handles.Zheader.total_columns );
  set( handles.txt_num_voxels, 'String', str );

  str = num2str( handles.Zheader.total_scans );
  set( handles.txt_num_scans, 'String', str );

  set( handles.chk_isMulFreq, 'Value', scan_information.isMulFreq );
  str = num2str( handles.scan_information.frequencies );
  set( handles.txt_meg_ranges, 'String', str );

  str = num2str( handles.Zheader.min_scans );
  set( handles.txt_min_scans, 'String', str );

  str = num2str( handles.Zheader.max_scans );
  set( handles.txt_max_scans, 'String', str );

  set( handles.txt_Z0_location, 'String', handles.Zheader.Z_Directory );

  calculate_partitioning_information( handles );

  str = num2str( handles.Zheader.tsum );
  set( handles.txt_Z_SoS, 'String', str );

  tss = 'off';
  if ( ~isempty( Zheader.Z_Directory ) )
    fn = [Zheader.Z_Directory 'Z' filesep 'Z1.mat' ];
    x = exist( fn, 'file' );
    if ( x == 2 )
      tss = 'on';
    end;
  end;
  set( handles.btn_Z_SoS, 'Enable', tss );

  % ---------------------------------------------
  % fill in the subject stats: subject, # run #, ID, start point, scan length
  % ---------------------------------------------
  reset_scan_list( handles );

  Enabled = 'off'; State = 0;
  if ( ~isempty( handles.Zheader.Z_File.name ) )  Enabled = 'on'; State = 1; end

  set( handles.chk_from_Z, 'Value', ~isempty( handles.Zheader.Z_File.name ) );
  set( handles.chk_from_scan, 'Value', ~isempty( handles.scan_information.BaseDir ) );
%  set( handles.btn_browse_source, 'Enable', Enabled );

  Enabled = 'off'; 
  if ( ~isempty( handles.scan_information.FileList ) ) 
    x = exist( handles.scan_information.FileList, 'file' );
    if ( x == 7 )
      Enabled = 'on'; 
    end;
%  else; 
%    Enabled = 'off'; 
  end;
  set( handles.btn_edit_file_list, 'Enable', Enabled );

  if ( ~isempty( handles.Zheader.Z_File.name ) )

    str = strrep( handles.Zheader.Z_File.name, ' ', '?' );
    txt = short_path( str, 4 );
    if ( length(txt) > 60 )
      txt = short_path( str, 3 );
    end;

    set( handles.txt_Z_location, 'String', txt );
    set( handles.txt_Z_file, 'String', handles.Zheader.Z_File.name );
    set( handles.txt_Z_variable, 'String', handles.Zheader.Z_File.variable.name );

    set( handles.chk_Z_mean_centered, 'Value', handles.Zheader.Z_File.mean_centered );
    set( handles.chk_z_standardized, 'Value', handles.Zheader.Z_File.normalized );
    set( handles.chk_Z_mean_centered, 'Enable', 'on' );
    set( handles.chk_z_standardized, 'Enable', 'on' );

    set( handles.btn_verify_scans, 'Enable', 'off' );

  else

    str = strrep( handles.scan_information.BaseDir, ' ', '?' );
    txt = short_path( str, 4 );
    if ( length(txt) > 60 )
      txt = short_path( str, 3 );
    end;

    set( handles.txt_Z_location, 'String', txt );
    set( handles.txt_Z_file, 'String', '' );
    set( handles.txt_Z_variable, 'String', '' );

    set( handles.chk_Z_mean_centered, 'Value', 0 );
    set( handles.chk_z_standardized, 'Value', 0 );
    set( handles.chk_Z_mean_centered, 'Enable', 'off' );
    set( handles.chk_z_standardized, 'Enable', 'off' );

    set( handles.btn_verify_scans, 'Enable', 'on' );

  end;

  if ( ismac )
    set( handles.txt_num_subjects, 'HorizontalAlignment', 'center' );
    set( handles.txt_num_runs, 'HorizontalAlignment', 'center' );
    set( handles.txt_num_voxels, 'HorizontalAlignment', 'center' );
    set( handles.txt_num_scans, 'HorizontalAlignment', 'center' );
    set( handles.txt_min_scans, 'HorizontalAlignment', 'center' );
    set( handles.txt_max_scans, 'HorizontalAlignment', 'center' );

    set( handles.txt_num_partitions, 'HorizontalAlignment', 'center' );
    set( handles.txt_partition_width, 'HorizontalAlignment', 'center' );
    set( handles.txt_last_partition_width, 'HorizontalAlignment', 'center' );
    set( handles.txt_partition_memory, 'HorizontalAlignment', 'center' );

  end;

% default command line output for Z_Editor
handles.output = hObject;
handles.output2 = hObject;
handles.output3 = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Z_Editor wait for user response (see UIRESUME)
 uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Z_Editor_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
varargout{2} = handles.output2;
varargout{3} = handles.output3;
delete(handles.figure1);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.output = '';
  handles.output2 = '';
  handles.output3 = 0;
  guidata(handles.figure1, handles);
  uiresume(handles.figure1);
%delete(hObject);



function txt_num_subjects_Callback(hObject, eventdata, handles)
% hObject    handle to txt_num_subjects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_num_subjects as text

  handles.Zheader.num_subjects = str2num(get(hObject,'String'));
  handles.scan_information.NumSubjects = str2num(get(hObject,'String'));
  guidata(handles.figure1, handles);

  slen = handles.Zheader.num_subjects * handles.Zheader.num_runs;
  lst = get( handles.lst_timeseries, 'String') ;

  if ( size(lst,1) > slen )
    set( handles.btn_prune, 'Enable', 'on' );
  else
    set( handles.btn_prune, 'Enable', 'off' );
  end

  if ( size(lst,1) < slen )
    set( handles.btn_add_scans, 'Enable', 'on' );
  else
    set( handles.btn_add_scans, 'Enable', 'off' );
  end


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



function txt_num_runs_Callback(hObject, eventdata, handles)
% hObject    handle to txt_num_runs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_num_runs as text
  handles.Zheader.num_runs = str2num(get(hObject,'String'));
  handles.scan_information.NumRuns = str2num(get(hObject,'String'));
  guidata(handles.figure1, handles);

  slen = handles.Zheader.num_subjects * handles.Zheader.num_runs;
  lst = get( handles.lst_timeseries, 'String') ;

  if ( size(lst,1) > slen )
    set( handles.btn_prune, 'Enable', 'on' );
  else
    set( handles.btn_prune, 'Enable', 'off' );
  end

  if ( size(lst,1) < slen )
    set( handles.btn_add_scans, 'Enable', 'on' );
  else
    set( handles.btn_add_scans, 'Enable', 'off' );
  end


% --- Executes during object creation, after setting all properties.
function txt_num_runs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_num_runs (see GCBO)
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



function txt_min_scans_Callback(hObject, eventdata, handles)
% hObject    handle to txt_min_scans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_min_scans as text
%        str2double(get(hObject,'String')) returns contents of txt_min_scans as a double


% --- Executes during object creation, after setting all properties.
function txt_min_scans_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_min_scans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_max_scans_Callback(hObject, eventdata, handles)
% hObject    handle to txt_max_scans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_max_scans as text
%        str2double(get(hObject,'String')) returns contents of txt_max_scans as a double


% --- Executes during object creation, after setting all properties.
function txt_max_scans_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_max_scans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in lst_timeseries.
function lst_timeseries_Callback(hObject, eventdata, handles)
% hObject    handle to lst_timeseries (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns lst_timeseries contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lst_timeseries

  % If double click
  if strcmp(get(handles.figure1,'SelectionType'),'open')

    % ------------------------------------
    % --- first, confirm that subject ID's exist and match list count ---
    % ------------------------------------
    pos = get( handles.lst_timeseries, 'Value' );		% preserve current index
    sids = size(handles.scan_information.SubjectID, 2);
    lst = {};

    if ( sids < handles.Zheader.num_subjects )
      for s = sids:handles.Zheader.num_subjects-1
        handles.scan_information.SubjectID = [handles.scan_information.SubjectID {'     '}];
      end;
      guidata(handles.figure1, handles);
    end;

    aa = get( handles.lst_timeseries, 'String') ;
    x = size( aa, 1 );
    if ( x == 0 )  % empty list
      return
    end;

    selected_index = get( handles.lst_timeseries, 'Value');

    s = max(1,ceil(selected_index/handles.Zheader.num_runs));
    r = selected_index - ((s-1)*handles.Zheader.num_runs);

    prompt = {'Enter the number of scans:','Enter Ths Subject ID:'};
    defa = {num2str(handles.Zheader.timeseries.subject(s).run(r,1)), char(handles.scan_information.SubjectID(s))} ;

    newEntry = inputdlg(prompt,'Edit Subject Scans', 1, defa );
    if ( ~isempty( newEntry ) ) 

      if ( size( char(newEntry(1)) ) > 0 )
        x = validate_numeric_entry( char(newEntry(1)) );
        x = str2num(x);
        if ( x > 0 )   handles.Zheader.timeseries.subject(s).run(r,1) = x; end;
      end;

      if ( size( char(newEntry(2)) ) > 0 )
        handles.scan_information.SubjectID(s) = {char(newEntry(2))};
      end;

      % ---------------------------------------------
      % Update handles structure
      % ---------------------------------------------
      guidata(hObject, handles);

      % ---------------------------------------------
      % now reset all subject scan start position based on altered depths
      % ---------------------------------------------
      spos = 1;
      rpos = 0;

      sbjs = str2double(get(handles.txt_num_subjects,'String'));
      rws = str2double(get(handles.txt_num_runs,'String'));

      for s = 1:sbjs
        for r = 1:rws

          handles.Zheader.timeseries.subject(s).run(r,2) = spos;

          % ---------------------------------------------
          % adjust the depth of the final subject only
          % ---------------------------------------------
          if ( s == sbjs & r == rws )
            handles.Zheader.timeseries.subject(s).run(r,1) =  handles.Zheader.total_scans - spos + 1;
          else
            spos = spos + handles.Zheader.timeseries.subject(s).run(r,1);
          end;
        end;
      end;

      % ---------------------------------------------
      % Update handles structure
      % ---------------------------------------------
      guidata(hObject, handles);

      reset_scan_list( handles );

    end; 

  end;


% --- Executes during object creation, after setting all properties.
function lst_timeseries_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_timeseries (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_num_partitions_Callback(hObject, eventdata, handles)
% hObject    handle to txt_num_partitions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_num_partitions as text
%        str2double(get(hObject,'String')) returns contents of txt_num_partitions as a double


% --- Executes during object creation, after setting all properties.
function txt_num_partitions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_num_partitions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_partition_width_Callback(hObject, eventdata, handles)
% hObject    handle to txt_partition_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_partition_width as text
%        str2double(get(hObject,'String')) returns contents of txt_partition_width as a double


% --- Executes during object creation, after setting all properties.
function txt_partition_width_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_partition_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_last_partition_width_Callback(hObject, eventdata, handles)
% hObject    handle to txt_last_partition_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_last_partition_width as text
%        str2double(get(hObject,'String')) returns contents of txt_last_partition_width as a double


% --- Executes during object creation, after setting all properties.
function txt_last_partition_width_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_last_partition_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_partition_memory_Callback(hObject, eventdata, handles)
% hObject    handle to txt_partition_memory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_partition_memory as text
%        str2double(get(hObject,'String')) returns contents of txt_partition_memory as a double


% --- Executes during object creation, after setting all properties.
function txt_partition_memory_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_partition_memory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_Z0_location_Callback(hObject, eventdata, handles)
% hObject    handle to txt_Z0_location (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_Z0_location as text
%        str2double(get(hObject,'String')) returns contents of txt_Z0_location as a double

  tss = 'off';
  if ( ~isempty( handles.Zheader.Z_Directory ) )
    fn = [handles.Zheader.Z_Directory 'Z' filesep  'Z1.mat' ];
    x = exist( fn, 'file' );
    if ( x == 2 )
      tss = 'on';
    end;
  end;
  set( handles.btn_Z_SoS, 'Enable', tss );



% --- Executes during object creation, after setting all properties.
function txt_Z0_location_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_Z0_location (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_browse_location.
function btn_browse_location_Callback(hObject, eventdata, handles)
% hObject    handle to btn_browse_location (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  dirname = uigetdir('', 'Pick a different drive or directory for your ZInfo location');

  if ~isempty( dirname )

    handles.Zheader.Z_Directory = [dirname handles.dir_char];
    % Update handles structure
    guidata(hObject, handles);

    calculate_partitioning_information( handles );

    set( handles.txt_Z0_location, 'String', dirname );
    drawnow();
    txt_Z0_location_Callback( handles.txt_Z0_location, 0, handles );
  
  end


% --- Executes on button press in btn_browse_source.
function btn_browse_source_Callback(hObject, eventdata, handles)
% hObject    handle to btn_browse_source (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  if ( ~isempty( handles.Zheader.Z_File.name ) )
    txtPrompt = 'Select the Z Matrix this data derived from';
    listspec = {'*.mat','Z matrix'};
  else
    txtPrompt = 'Select the File List this data derived from';
    listspec = {'*.txt','text file'};
  end;

  fullpath = select_file( listspec, txtPrompt);


  if ( ~isempty( handles.Zheader.Z_File.name ) )
    mat_vars = matfile_vars( '', fullpath );
    [mf_x mf_y] = size( mat_vars );

    if ( mf_x > 0 )    % there are variables in the file

      if ( mf_x == 1 )   % only a single variable in the file
        handles.Zheader.Z_File.variable = mat_vars;

      else

        % get user selection of mat in file to use as Z
        lst = '';
        for ii=1:mf_x
          lst = horzcat( lst, {mat_vars(ii).name});
        end

        x = mat_selection( lst );
        handles.Zheader.Z_File.variable = mat_vars(x);

      end;  % more than 1 var in file

      if ~isempty( handles.Zheader.Z_File.variable.name )

        x = findstr( handles.dir_char, fullpath );
        xx=size(x);
        sz = size( fullpath );
        handles.Zheader.Z_File.directory = fullpath(1:x(xx(2)));
        handles.Zheader.Z_File.name = fullpath(x(xx(2))+1:sz(2));
        handles.Zheader.older_Z = 1;

        % Update handles structure
        guidata(hObject, handles);

        Enabled = 'off'; State = 0;
        if ( ~isempty( handles.Zheader.Z_File.name ) )  Enabled = 'on'; State = 1; end

        set( handles.chk_from_Z, 'Value', State );
        set( handles.btn_browse_source, 'Enable', Enabled );

        if ( State )
          set( handles.txt_Z_location, 'String', handles.Zheader.Z_File.directory );
          set( handles.txt_Z_file, 'String', handles.Zheader.Z_File.name );
          set( handles.txt_Z_variable, 'String', handles.Zheader.Z_File.variable.name );

          set( handles.chk_Z_mean_centered, 'Value', handles.Zheader.Z_File.mean_centered );
          set( handles.chk_z_standardized, 'Value', handles.Zheader.Z_File.normalized );
        else
          str = '';
          set( handles.txt_Z_location, 'String', str );
          set( handles.txt_Z_file, 'String', str );
          set( handles.txt_Z_variable, 'String', str );

          set( handles.chk_Z_mean_centered, 'Value', 0 );
          set( handles.chk_z_standardized, 'Value', 0 );
        end;

      end;  

    end;  

  else	% file list text selection
    handles.scan_information.FileList = fullpath;
    if ( ~isempty( handles.scan_information.FileList ) )  Enabled = 'on'; else; Enabled = 'off'; end
    set( handles.btn_edit_file_list, 'Enable', Enabled );
  end;

  % Update handles structure
  guidata(hObject, handles);


% --- Executes on button press in chk_from_Z.
function chk_from_Z_Callback(hObject, eventdata, handles)
% hObject    handle to chk_from_Z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_from_Z
  x = get( hObject, 'Value' );
  if ( x ) 
    set( handles.chk_from_scan, 'Value', 0 );
    handles.scan_information.BaseDir = '';
  else
    set( handles.chk_from_scan, 'Value', 1 );
    handles.Zheader.Z_File.directory = '';
    handles.Zheader.Z_File.name = '';
    handles.Zheader.Z_File.variable.name  = '';
  end;

  % Update handles structure
  guidata(hObject, handles);



% --- Executes on button press in chk_Z_mean_centered.
function chk_Z_mean_centered_Callback(hObject, eventdata, handles)
% hObject    handle to chk_Z_mean_centered (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_Z_mean_centered


% --- Executes on button press in chk_z_standardized.
function chk_z_standardized_Callback(hObject, eventdata, handles)
% hObject    handle to chk_z_standardized (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_z_standardized


% --- Executes on button press in btn_Okay.
function btn_Okay_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Okay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.output = handles.Zheader;
  handles.output2 = handles.scan_information;

  % Update handles structure
  guidata(hObject, handles);

%  uiresume(handles.figure1);   [ 4.1.3] uopdate no longer closes dialog, but does save the data headers

  % --------------------------------------------------------
  % update header information
  % --------------------------------------------------------
  Zfile = [pwd filesep 'ZInfo.mat'];

  x = exist( Zfile );
  if ( x == 0 )		% copy original ZInfo to local to preserve all summary data
    if ( length(handles.Zheader.Z_Directory) > 0 )
      % copyfile( [handles.Zheader.Z_Directory 'ZInfo.mat'], Zfile );
      disp("please wait for the system to write Z matrix to the drive.");
      uiresume(handles.figure1);
      return;
    end
  end

  appnd = '';
  x = exist( Zfile );
  if ( x > 0 )
    appnd = '-append';
  end;

  Zheader = handles.Zheader;
  scan_information = handles.scan_information;
  eval( ['save( ''' Zfile ''', ''Zheader'', ''scan_information'', ''' appnd ''' )' ] );


  if ( handles.conditions_changed )	% --- update changes to encoded conditions in Gheader
    if ( length( Zheader.Model.path ) > 0 & Zheader.Model.hdr_exists == 1 )
      eval( ['load( ''' Zheader.Model.path ''', ''Gheader'');' ] );
      if exist( 'Gheader', 'var' ) 
        Gheader.subject_encoded = [];
        for  SubjectNo = 1:handles.Zheader.num_subjects;
          Gheader.subject_encoded = [Gheader.subject_encoded sum( Zheader.conditions.encoded(SubjectNo).condition ) ];
        end;
        eval( ['save( ''' Zheader.Model.path ''', ''Gheader'', ''-append'');' ] );
      end;
    end;
  end;

  uiresume(handles.figure1);   % --- [ 7.1.0] update changed to OKAY - save and close


% --- Executes on button press in btn_Cancel.
function btn_Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%  handles.output = '';		% [4.1.3] close now returns data for adjustment in cpca memory
%  handles.output2 = '';

  handles.output = handles.Zheader;
  handles.output2 = handles.scan_information;

  guidata(handles.figure1, handles);
  uiresume(handles.figure1);


% --- Executes on button press in btn_prune.
function btn_prune_Callback(hObject, eventdata, handles)
% hObject    handle to btn_prune (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  slen = handles.Zheader.num_subjects * handles.Zheader.num_runs;

  aa = get( handles.lst_timeseries, 'String') ;
  if ( size(aa,1) > slen )
    aa = aa(1:slen);
    set( handles.lst_timeseries, 'String', aa, 'Value', 1 );
  end;

  set( handles.btn_prune, 'Enable', 'off' );


function reset_scan_list( handles )

  pos = get( handles.lst_timeseries, 'Value' );		% preserve current index
  sids = size(handles.scan_information.SubjectID, 2);
  lst = {};

  if ( sids < handles.Zheader.num_subjects )
    for s = sids:handles.Zheader.num_subjects-1
      handles.scan_information.SubjectID = [handles.scan_information.SubjectID {'     '}];
    end;
    guidata(handles.figure1, handles);
  end;

  minscans = 0;
  maxscans = 0;

  for s = 1:handles.Zheader.num_subjects
    for r = 1:handles.Zheader.num_runs

      if iscellstr( handles.scan_information.SubjDir( s, r ) )
        
        thisID = strtrim(char(handles.scan_information.SubjectID(s)));
        mx = min( length(thisID), 5 );
        if ( mx > 0 )
          thisID = thisID(1:mx);
        else
          thisID = ' ';
        end;

        str = sprintf( '%3d.%d %5s %7d %4d', s, r, thisID, ...
           handles.Zheader.timeseries.subject(s).run(r,2), ...
           handles.Zheader.timeseries.subject(s).run(r,1) );

        lst = [lst; {str}];
        if ( minscans > 0 )
          minscans = min( minscans, handles.Zheader.timeseries.subject(s).run(r,1) );
          maxscans = max( maxscans, handles.Zheader.timeseries.subject(s).run(r,1) );
        else
          minscans = handles.Zheader.timeseries.subject(s).run(r,1);
          maxscans = handles.Zheader.timeseries.subject(s).run(r,1);
        end;

      end;
    end;
  end;

  if ( minscans > 0 )
    handles.Zheader.min_scans = minscans;
    handles.Zheader.max_scans = maxscans;
    guidata(handles.figure1, handles);

    str = num2str( handles.Zheader.min_scans );
    set( handles.txt_min_scans, 'String', str );

    str = num2str( handles.Zheader.max_scans );
    set( handles.txt_max_scans, 'String', str );

  end

  if ( pos > size(lst,1) )  pos = max(size(lst, 1 ),1);  end;
  set( handles.lst_timeseries, 'String', lst, 'Value', pos) ;

  lst = get( handles.lst_timeseries, 'String') ;
  slen = handles.Zheader.num_subjects * handles.Zheader.num_runs;
  if ( size(lst,1) > slen )
    set( handles.btn_prune, 'Enable', 'on' );
  else
    set( handles.btn_prune, 'Enable', 'off' );
  end
  if ( size(lst,1) < slen )
    set( handles.btn_add_scans, 'Enable', 'on' );
  else
    set( handles.btn_add_scans, 'Enable', 'off' );
  end



% --- Executes on button press in btn_add_scans.
function btn_add_scans_Callback(hObject, eventdata, handles)
% hObject    handle to btn_add_scans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  aa = get( handles.lst_timeseries, 'String') ;
  x = min(size(aa,1),1);

  s = max(1,ceil(x/handles.Zheader.num_runs));
  r = x - ((s-1)*handles.Zheader.num_runs);

  str = sprintf( '%3d.%d %5s %7d %4d', s, r, '     ', 0, 0 );
  aa = [aa; {str}];
  set( handles.lst_timeseries, 'String', aa, 'Value', 1) ;


% --- Executes on button press in btn_recalc_scans.
function btn_recalc_scans_Callback(hObject, eventdata, handles)
% hObject    handle to btn_recalc_scans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  s = str2double(get(handles.txt_num_subjects,'String'));
  r = str2double(get(handles.txt_num_runs,'String'));
  sbj = [];

  if ( s > 0 & r > 0 )

    spos = 1;
    handles.Zheader.timeseries.subject = [];
    str = '';
    ts_scans = floor(handles.Zheader.total_scans/(s*r));
    ts_remain = mod(handles.Zheader.total_scans, ts_scans);

    for sno = 1:s;
      run = [];

      for rno = 1:r
        val = ts_scans;
        if ( sno == s & rno == r )
          if ts_remain > 0 val = ts_scans + ts_remain; end;
        end;
        run = [run; [val spos] ] ;  
        spos = spos + val;
   
      end; 

      subject = struct( 'run', [] );
      subject.run  = run;

      handles.Zheader.timeseries.subject = vertcat(handles.Zheader.timeseries.subject, subject);

    end;

    % ---------------------------------------------
    % Update handles structure
    % ---------------------------------------------
    guidata(hObject, handles);

    reset_scan_list( handles );

  end;


function calculate_partitioning_information( handles )
  % ---------------------------------------------
  % --- Partitioning information - calculate only ---
  % ---------------------------------------------

  x = who_count( [handles.Zheader.Z_Directory 'Z' filesep], 'Z1.mat', 'Z_R1_*' );
  if ( x > 0 ) 

    handles.Zheader.partitions.partitioned = 1;
    handles.Zheader.partitions.count = x;
    xx = who_stats( [handles.Zheader.Z_Directory 'Z' filesep], 'Z1.mat', 'Z_R1_C1' );
    handles.Zheader.partitions.width = xx.mat_y;

    matname = ['Z_R1_C' num2str(x)];
    xx = who_stats( [handles.Zheader.Z_Directory 'Z' filesep], 'Z1.mat', matname );
%    eval ( [ 'xx = who_stats( handles.Zheader.Z_Directory, ''Z1.mat'', ''Z_R1_C' num2str(x) ''');' ] );
    handles.Zheader.partitions.last = xx.mat_y;

    handles.Zheader.partitions.columns = [];
    for ( ii = 1:(x-1) )
      handles.Zheader.partitions.columns = [handles.Zheader.partitions.columns handles.Zheader.partitions.width];
    end;
    handles.Zheader.partitions.columns = [handles.Zheader.partitions.columns handles.Zheader.partitions.last];

    handles.Zheader.partitions.mem = array_sizes( [handles.Zheader.total_scans handles.Zheader.partitions.width ] );

    guidata(handles.figure1, handles);

  end;
 
  str = num2str( handles.Zheader.partitions.count );
  set( handles.txt_num_partitions, 'String', str );
  set( handles.txt_num_partitions, 'Enable', 'off' );

  str = num2str( handles.Zheader.partitions.width );
  set( handles.txt_partition_width, 'String', str );
  set( handles.txt_partition_width, 'Enable', 'off' );

  str = num2str( handles.Zheader.partitions.last );
  set( handles.txt_last_partition_width, 'String', str );
  set( handles.txt_last_partition_width, 'Enable', 'off' );

  mem = array_sizes( [handles.Zheader.total_columns handles.Zheader.total_scans ] );
  v = ceil( mem.megabytes/100) * 100;
  str = num2str(v );
  set( handles.txt_partition_memory, 'String', str );
  set( handles.txt_partition_memory, 'Enable', 'off' );


% --- Executes on button press in btn_Z_SoS.
function btn_Z_SoS_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Z_SoS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Zheader globls

  % recalculate Z Sum Of Squares
  sm = [];
  SoS = zeros(1,Zheader.total_columns);

  if ( strcmp( class(handles.progressBar), 'cpca_progress' ) )
    handles.clearMessages();
    handles.setTitle(  'Calculating . . .' );
    handles.setProcess(  'Z Sum of Squares' );
    handles.setMessage( 'Recalculating sum diagonal of Z' );
    handles.clearParticipant();
    handles.clearRun();
    handles.clearFrequency();
    handles.setPong( 0);
    handles.show();
  end

  SoS = recalculate_ZSD( Zheader );

  if ( strcmp( class(handles.progressBar), 'cpca_progress' ) )
    handles.hide();
  end
  
%  handles.Zheader.tsum = sum(SoS);
  handles.Zheader.tsum = SoS.Zsd;

  % Update handles structure
  guidata(hObject, handles);

  set(hObject,'BackgroundColor',constant_define( 'COLOR_GREY' ) );

  str = num2str( handles.Zheader.tsum );
  set( handles.txt_Z_SoS, 'String', str );
  drawnow();


% --- Executes on button press in btn_view_groups.
function btn_view_groups_Callback(hObject, eventdata, handles)
% hObject    handle to btn_view_groups (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  x = Grp_Editor('zheader', handles.Zheader, 'scaninfo', handles.scan_information );

  if ~isempty(x)
    handles.scan_information.GroupList = x;
    handles.scan_information.NumGroups = size(x,1);

    % --- [7.1.0] ensure no empty groups added
    nmgrp = 0;
    grps = [];
    for ii = 1:size(handles.scan_information.GroupList,1)  
      if  length(handles.scan_information.GroupList(ii).subjectlist) > 0 nmgrp = nmgrp + 1;  grps = [grps; handles.scan_information.GroupList(ii)]; end;
    end;
    handles.scan_information.NumGroups = nmgrp;
    handles.scan_information.GroupList = grps;

    % Update handles structure
    guidata(hObject, handles);
  end;


% --- Executes on button press in btn_runs_and_conditions.
function btn_runs_and_conditions_Callback(hObject, eventdata, handles)
% hObject    handle to btn_runs_and_conditions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  x = Runs_and_Conditions( 'zheader',  handles.Zheader, 'scaninfo', handles.scan_information, 'import', 0 );

  if ( ~isempty( x ) )
    handles.Zheader.conditions = x;
    handles.scan_information.processing.model.parameters.condition_name = handles.Zheader.conditions.Names;

    handles.conditions_changed = 1;	% --- flag to update Gheader.subject_encoded

    % Update handles structure
    guidata(hObject, handles);
  end;


% --- Executes on button press in btn_description.
function btn_description_Callback(hObject, eventdata, handles)
% hObject    handle to btn_description (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  if ( iscell( handles.Zheader.Description ) )
    desc = handles.Zheader.Description;
  else
    desc = {handles.Zheader.Description};
  end;

  newEntry = inputdlg('notes', 'Enter your notes for this subject data', constant_define( 'INPUT_DLG_SIZE' ), desc );

  if ( ~isempty( newEntry ) )
    handles.Zheader.Description = newEntry;
    % Update handles structure
    guidata(hObject, handles);
  end;



% --- Executes on button press in chk_from_scan.
function chk_from_scan_Callback(hObject, eventdata, handles)
% hObject    handle to chk_from_scan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_from_scan
  x = get( hObject, 'Value' );
  if ( x ) 
    set( handles.chk_from_Z, 'Value', 0 );
%    handles.scan_information.BaseDir = '';
  else
    set( handles.chk_from_Z, 'Value', 1 );
%    handles.Zheader.Z_File.directory = '';
%    handles.Zheader.Z_File.name = '';
%    handles.Zheader.Z_File.variable.name  = '';
  end;

  % Update handles structure
  guidata(hObject, handles);



% --- Executes on button press in btn_verify_scans.
function btn_verify_scans_Callback(hObject, eventdata, handles)
% hObject    handle to btn_verify_scans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.output3 = scan_verification();
  % Update handles structure
  guidata(hObject, handles);


% --- Executes on button press in btn_edit_file_list.
function btn_edit_file_list_Callback(hObject, eventdata, handles)
% hObject    handle to btn_edit_file_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  eval( ['edit ''' handles.scan_information.FileList '''' ] );


% --- Executes on button press in chk_isMulFreq.
function chk_isMulFreq_Callback(hObject, eventdata, handles)
% hObject    handle to chk_isMulFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_isMulFreq



function txt_meg_ranges_Callback(hObject, eventdata, handles)
% hObject    handle to txt_meg_ranges (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_meg_ranges as text
%        str2double(get(hObject,'String')) returns contents of txt_meg_ranges as a double


% --- Executes during object creation, after setting all properties.
function txt_meg_ranges_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_meg_ranges (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_view_meg.
function btn_view_meg_Callback(hObject, eventdata, handles)
% hObject    handle to btn_view_meg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  [x y] = Range_Editor();
  if ~isempty(x)

    handles.scan_information.freq_dirs = x;
    handles.scan_information.freq_names = y;

    % Update handles structure
    guidata(hObject, handles);

    % --------------------------------------------------------
    % update header information
    % --------------------------------------------------------
    Zfile = [pwd filesep 'ZInfo.mat'];

    x = exist( Zfile );
    if ( x == 0 )		% copy original ZInfo to local to preserve all summary data
      if ( length(handles.Zheader.Z_Directory) > 0 )
        copyfile( [handles.Zheader.Z_Directory 'ZInfo.mat'], Zfile );
      end;
    end;

    appnd = '';
    x = exist( Zfile );
    if ( x > 0 )
      appnd = '-append';
    end;

    Zheader = handles.Zheader;
    scan_information = handles.scan_information;
    eval( ['save( ''' Zfile ''', ''Zheader'', ''scan_information'', ''' appnd ''' )' ] );

 end;

% Wayne: removed, duplicated
% % --- Executes on button press in chk_isMulFreq.
% function chk_isMulFreq_Callback(hObject, eventdata, handles)
% % hObject    handle to chk_isMulFreq (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hint: get(hObject,'Value') returns toggle state of chk_isMulFreq


