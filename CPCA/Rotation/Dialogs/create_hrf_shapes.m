function create_hrf_shapes(varargin)
% CREATE_HRF_SHAPES M-file for create_hrf_shapes.fig
%      CREATE_HRF_SHAPES, by itself, creates a new CREATE_HRF_SHAPES or raises the existing
%      singleton*.
%
%      H = CREATE_HRF_SHAPES returns the handle to a new CREATE_HRF_SHAPES or the handle to
%      the existing singleton*.
%
%      CREATE_HRF_SHAPES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CREATE_HRF_SHAPES.M with the given input arguments.
%
%      CREATE_HRF_SHAPES('Property','Value',...) creates a new CREATE_HRF_SHAPES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before create_hrf_shapes_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to create_hrf_shapes_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help create_hrf_shapes

% Last Modified by GUIDE v2.5 30-Apr-2013 13:03:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @create_hrf_shapes_OpeningFcn, ...
                   'gui_OutputFcn',  @create_hrf_shapes_OutputFcn, ...
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


% --- Executes just before create_hrf_shapes is made visible.
function create_hrf_shapes_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to create_hrf_shapes (see VARARGIN)

% Choose default command line output for create_hrf_shapes
handles.output = hObject;

  if(nargin > 3)
    for index = 1:2:(nargin-3),
        if nargin-3==index, break, end
        switch lower(varargin{index})
         case 'zheader'
          handles.Zheader = varargin{index+1};
         case 'gheader'
          handles.Gheader = varargin{index+1};
          set( handles.txt_default_bins, 'String', num2str( handles.Gheader.bins ) );          
          set( handles.txt_default_TR, 'String', num2str( handles.Gheader.TR ) );          
         case 'scan_info'
          handles.scan_information = varargin{index+1};
        end
    end
  end

  handles.event_colors = [ ...
    [0 0 1]; ...
    [0 .5 0]; ...
    [.85 .15 0]; ...
    [0 .6 1]; ...
    [.5 .05 .9]; ...
    [.75 .75 0]; ...
    [0 0 0]; ...
    [.365 .365 1]; ...
    [.2 1 .2]; ...
    [1 .4 .2]; ...
    [.2 1 .6]; ...
    [.8 .2 1]; ...
    [.6 .6 0]; ...
    [.4 .4 .4] ];

  % --- global value constants
  handles.defaults.event_displacement = 2000;	% --- we default events at 2 second spacing
  handles.defaults.event_duration = 1000;	% --- we default event durations of 1 second

  handles.shapes.cognitive_events = 0;
  handles.shapes.define = [];
  handles.max_secondaries = 8;
  handles.shapes_spanned = [];

  lst = [];
  set( handles.lst_cognitive_events, 'String', lst );
  set( handles.lst_spanned_events, 'String', lst );

  set( handles.txt_def_onset_spacing, 'String', num2str(handles.defaults.event_displacement) );
  set( handles.txt_def_duration, 'String', num2str(handles.defaults.event_duration) );


  % Update handles structure
  guidata(hObject, handles);

  replot_shapes(handles);

% UIWAIT makes create_hrf_shapes wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = create_hrf_shapes_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
%delete(handles.figure1);




function replot_shapes(handles)

  handles.shape_data = []; % --= 
  x = get( handles.chk_display_events, 'Value' );

  handles.shape_data = [];
  labels = '';

  bins = str2num( get( handles.txt_default_bins, 'String' ) );
  TR   = str2num( get( handles.txt_default_TR, 'String' ) );
  if x == 1 & handles.shapes.cognitive_events > 0 

    lst = get( handles.lst_cognitive_events, 'String' );
    lc_idx = 0;
    for ( ii = 1:size(lst, 1 ) )

      this_shape = char(lst{ii} );

      onsets = str2num(this_shape(7:13) );
      onsets = [onsets str2num(this_shape(15:21) ) ];

      X = calculate_hrf_shape( onsets/1000, bins, TR );

      lc_idx = lc_idx + 1;
      if ( lc_idx > size( handles.event_colors, 1 ) )
        lc_idx = 1;
      end;
      lc = handles.event_colors(lc_idx,:);

      handles.shape_data = [handles.shape_data X];  % --= 

      plot( X, '-', 'Color', lc );
      hold on

      labels = [labels {strtrim(this_shape(22:end) ) } ];

    end;

    % --= 
    guidata(handles.figure1, handles);
%    plot( handles.shape_data, '-');

  else
    cla
  end;


  x = get( handles.chk_display_spanned, 'Value' );
  if x == 1 & handles.shapes.cognitive_events > 1

    if size(handles.shapes_spanned, 1) > 0

      lst = get( handles.lst_cognitive_events, 'String' );
      lc_idx = 0;
       
      for ii = 1:size(handles.shapes_spanned, 1)

        onsets = [];

        for jj = 1:size(handles.shapes_spanned(ii).index, 2)

          txt = char(lst( handles.shapes_spanned(ii).index(jj) ) );

          n = str2num(txt(7:13) );
          n = [n str2num(txt(15:21) ) ];
          onsets = [onsets; n ];

        end;

        X = calculate_hrf_shape( onsets/1000, bins, TR );

        handles.shape_data = [handles.shape_data X];  % --= 

        lc_idx = lc_idx + 1;;
        if ( lc_idx > size( handles.event_colors, 1 ) )
          lc_idx = 1;
        end;
        lc = handles.event_colors(lc_idx,:);

        plot( X, '--', 'Color', lc );
        hold on

        labels = [labels { ['Span ' num2str(ii)] } ];

      end;

    end;

    % --= 
    guidata(handles.figure1, handles);

  end;

  hold off


  xtl = [];
  for ii = 1:bins  % --- +1
    xtl = [xtl (ii-1)*TR];
  end;

  set( handles.axes1, 'XtickLabel', xtl );
  set( handles.axes1, 'Xtick', 0:bins );

  legend( labels, 'Location', 'Best' );

 

% --- Executes on button press in btn_close.
function btn_close_Callback(hObject, eventdata, handles)
% hObject    handle to btn_close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 delete( handles.figure1);


% --- Executes on button press in btn_save.
function btn_save_Callback(hObject, eventdata, handles)
% hObject    handle to btn_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scan_information 

  dirname = uigetdir('', 'Pick a different drive or directory');
  fnam = char(get( handles.txt_filename, 'String'));
  if ~isequal( dirname, 0)
    fn = [ dirname filesep fnam ];
  else
%    fn = fnam;
    return;	% --- user cancelled save
  end;

  shapes = handles.shape_data';

  shape_data = struct( 'defined', [], 'spanned', [] );
  shape_data.defined = get( handles.lst_cognitive_events, 'String' );
  shape_data.spanned = handles.shapes_spanned;

  shape_data.bins = str2num( get( handles.txt_default_bins, 'String' ) );
  shape_data.TR   = str2num( get( handles.txt_default_TR, 'String' ) );
  
  eval( [ 'save( ''' fn ''', ''shapes'', ''shape_data'' );' ] );
  str = [ 'file: ' fnam ' created.' ];
  show_message( 'File Saved', str );



% --- Executes on button press in btn_load_data.
function btn_load_data_Callback(hObject, eventdata, handles)
% hObject    handle to btn_load_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  fn = select_file( {'*.mat','MATLAB .mat file'}, ...
                                   'Select your saved shapes file');

  if ~isempty( fn )
    eval( [ 'load( ''' fn ''', ''shape_data'' );' ] );

    if ~exist( 'shape_data', 'var' )

      str = [ {'There were no pre-defined events in the selected file.'} {fn} ];
      show_message( 'No Defined Events', str );

    else

      handles.shapes.cognitive_events = size( shape_data.defined, 1 );
      set( handles.lst_cognitive_events, 'String', shape_data.defined );
      handles.shapes_spanned = shape_data.spanned;

      contents = [];
      for ii = 1:size(handles.shapes_spanned, 1 )
        str = '';
        for jj = 1:size(handles.shapes_spanned(ii).index, 2 )
          if size(str,2) > 0   str = [str ', ']; end;
          str = [str 'event ' num2str(handles.shapes_spanned(ii).index(jj))];
        end;
        contents = [contents; {['Span: ' str ]} ];
      end
   
      set(handles.lst_spanned_events, 'String', contents, 'Value', 1 );

      if isfield( shape_data, 'bins' )
        set(handles.txt_default_bins, 'String', num2str( shape_data.bins ) );
        set(handles.txt_default_TR, 'String', num2str( shape_data.TR ) );
      end;
        
      guidata(hObject, handles);
      replot_shapes(handles);

    end;

  end;




function txt_filename_Callback(hObject, eventdata, handles)
% hObject    handle to txt_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function txt_filename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in lst_cognitive_events.
function lst_cognitive_events_Callback(hObject, eventdata, handles)
% hObject    handle to lst_cognitive_events (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  get(handles.figure1,'SelectionType');
  
  % If double click
  if strcmp(get(handles.figure1,'SelectionType'),'open')
    contents = get(hObject,'String');

    if ~isempty( contents )
      idx = get(hObject,'Value');
      str = char(contents(idx ) );

      s = struct( 'num_defined_events', 0, 'event_no', 0, 'onset', 0, 'duration', 0, 'description', '' );
      s.num_defined_events = size( contents, 1 );
      s.event_no = s.num_defined_events;
      s.onset = str2num(str(7:13) );
      s.duration = str2num(str(15:21) );
      s.description = strtrim(str(22:end) );

      res = edit_shape_parameters( s, handles );
      if size( res,2 ) > 0 
        contents(idx) = {res};
        set( hObject, 'String', contents );

        handles.shapes.cognitive_events = size( contents, 1 );
        guidata(handles.figure1, handles);

        replot_shapes(handles);
     end;

   end;

%  else
%    contents = cellstr(get(hObject,'String'));
  end
%  contents{get(hObject,'Value')};


% --- Executes during object creation, after setting all properties.
function lst_cognitive_events_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_cognitive_events (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chk_display_events.
function chk_display_events_Callback(hObject, eventdata, handles)
% hObject    handle to chk_display_events (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  replot_shapes(handles);



% --- Executes on selection change in lst_spanned_events.
function lst_spanned_events_Callback(hObject, eventdata, handles)
% hObject    handle to lst_spanned_events (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function lst_spanned_events_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_spanned_events (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chk_display_spanned.
function chk_display_spanned_Callback(hObject, eventdata, handles)
% hObject    handle to chk_display_spanned (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  replot_shapes(handles);



% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over lst_cognitive_events.
function lst_cognitive_events_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to lst_cognitive_events (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  % If right mouse click - add a new event
  if strcmp(get(handles.figure1,'SelectionType'),'alt')
    add_cognitive_event( hObject, handles )
  end;


function lst_spanned_events_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to lst_spanned_events (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  % If right mouse click - add a new event if more than 1 object selected in events list
  if strcmp(get(handles.figure1,'SelectionType'),'alt')
    add_spanned_event(hObject, handles);
  end;




function txt = edit_shape_parameters( s, handles )

  txt = '';

  prompt = {'onset (ms):','duration (ms):', 'description:'};
  def = {num2str(s.onset), num2str(s.duration), s.description};

  res = inputdlg(prompt,'Event Parameters',1,def);
  if ~isempty( res )
    txt = sprintf( ' %3d  %6d  %6d  %s', s.event_no, str2num(char(res{1})), str2num(char(res{2})), char(res{3}) );
  end;


function add_cognitive_event( hObject, handles )

    contents = get(hObject,'String');
    idx = get(hObject,'Value');

    s = struct( 'num_defined_events', 0, 'event_no', 0, 'onset', 0, 'duration', 0, 'description', '' );
    s.num_defined_events = size( contents, 1 );
    s.event_no = s.num_defined_events + 1;
    s.onset = handles.defaults.event_displacement;
    s.duration = handles.defaults.event_duration;
    s.description = ['Event ' num2str(s.event_no ) ];

    if s.num_defined_events > 0 
      str = char(contents(s.num_defined_events ) );
      last_onset = str2num(str(7:13) );
      s.onset = last_onset + handles.defaults.event_displacement;
    end;

    res = edit_shape_parameters( s, handles );
    if size( res,2 ) > 0 
      contents = [contents; {res} ];
      set( hObject, 'String', contents, 'Value', max( size(contents, 1), 1 ) );

      handles.shapes.cognitive_events = size( contents, 1 );
      guidata(handles.figure1, handles);

      replot_shapes(handles);

    end;




function add_spanned_event(hObject, handles)
    % --- only add a spanned event if the main selection has more than 1 selected
    selected_index = get(handles.lst_cognitive_events,'Value');
    if size( selected_index, 2 ) > 1 
      
      duplicate_entry = 0;
      if size(handles.shapes_spanned, 1) > 0
        for ii = 1:size(handles.shapes_spanned, 1)
          if size(handles.shapes_spanned(ii).index, 2) == size(selected_index,2)
            if sum(handles.shapes_spanned(ii).index == selected_index) == size(selected_index,2) duplicate_entry = 1; end;
          end
        end;
      end

      if ~duplicate_entry
        handles.shapes_spanned = [handles.shapes_spanned; struct( 'index', selected_index)];

        contents = get(handles.lst_spanned_events,'String');
        str = '';
        for ii = 1:size(selected_index, 2 )
          if size(str,2) > 0   str = [str ', ']; end;
          str = [str 'event ' num2str(selected_index(ii))];
        end
   
        contents = [contents; {['Span: ' str ]} ];
        set(hObject,'String', contents, 'Value', max( size(contents, 1), 1 ) );

        guidata(handles.figure1, handles);

        replot_shapes(handles);

      end;

    end;

% --- Executes on key press with focus on lst_cognitive_events and none of its controls.
function lst_cognitive_events_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to lst_cognitive_events (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

  deleteItem = strcmp( eventdata.Key, 'delete' );
  if ~deleteItem & ismac()

    % If right mouse click - add a new event
    if strcmp( eventdata.Key, 'i' ) || strcmp( eventdata.Key, 'I' );
      add_cognitive_event( hObject, handles );
      return
    end;

    deleteItem = strcmp( eventdata.Key, 'backspace' );
  end;

  if ( deleteItem )

    contents = get(hObject,'String');

    if ~isempty( contents )
      idx = get(hObject,'Value');  % --- delete this item

      lst = [];
      this_idx = 0;

      for ii = 1:size(contents,1)
        if ii ~= idx
          this_idx = this_idx + 1;

          this_shape = char(contents{ii} );

          s = struct( 'event_no', 0, 'onset', 0, 'duration', 0, 'description', '' );
          s.event_no = this_idx;
          s.onset = str2num(this_shape(7:13) );
          s.duration = str2num(this_shape(15:21) );
          s.description = strtrim(this_shape(22:end) );

          txt = sprintf( ' %3d  %6d  %6d  %s', s.event_no, s.onset, s.duration, s.description );
          lst = [lst; {txt}];
 
        end
 
      end

      set( handles.lst_cognitive_events, 'String', lst, 'Value', min( idx, size(lst,1) ) );
      handles.shapes.cognitive_events = size( lst, 1 );
      guidata(handles.figure1, handles);

      if size( handles.shapes_spanned, 1 ) > 0
        new_span = [];
        new_content = [];

        for ii=1:size( handles.shapes_spanned, 1 )     
          str = '';
          if ~any( handles.shapes_spanned(ii).index == idx )
            n = handles.shapes_spanned(ii).index >= idx;
            this_span = handles.shapes_spanned(ii).index - n;
            new_span = [new_span; struct( 'index', this_span) ];
            for jj = 1:size(this_span, 2 )
              if size(str,2) > 0   str = [str ', ']; end;
              str = [str 'event ' num2str(this_span(jj))];
            end
            new_content = [new_content; {['Span: ' str ]} ];
          end;

        end;

        handles.shapes_spanned = new_span;
        guidata(handles.figure1, handles);

        set(handles.lst_spanned_events,'String', new_content, 'Value', max( size(new_content, 1), 1 ) );
        replot_shapes(handles);

      end;

    end;

  end;



% --- Executes on key press with focus on lst_spanned_events and none of its controls.
function lst_spanned_events_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to lst_spanned_events (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

  deleteItem = strcmp( eventdata.Key, 'delete' );
  if ~deleteItem & ismac()
    if strcmp( eventdata.Key, 'i' ) || strcmp( eventdata.Key, 'I' );
      add_spanned_event( hObject, handles );
      return
    end;
    deleteItem = strcmp( eventdata.Key, 'backspace' );
  end;

  if ( deleteItem )

    if size( handles.shapes_spanned, 1 ) > 0
      idx = get(hObject,'Value');  % --- delete this item

      new_span = [];
      new_content = [];

      for ii=1:size( handles.shapes_spanned, 1 )
        if ( ii ~= idx )  
          str = '';
          this_span = handles.shapes_spanned(ii).index;
          new_span = [new_span; struct( 'index', this_span) ];
          for jj = 1:size(this_span, 2 )
            if size(str,2) > 0   str = [str ', ']; end;
            str = [str 'event ' num2str(this_span(jj))];
          end
          new_content = [new_content; {['Span: ' str ]} ];

        end;

      end;

      handles.shapes_spanned = new_span;
      guidata(handles.figure1, handles);

      set(handles.lst_spanned_events,'String', new_content, 'Value', max( size(new_content, 1), 1 ) );
      replot_shapes(handles);

    end;

  end;




function txt_def_onset_spacing_Callback(hObject, eventdata, handles)
% hObject    handle to txt_def_onset_spacing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  str = get(hObject,'String');
  str = validate_numeric_entry( str );
  handles.defaults.event_displacement = str2num( str );
  set( handles.txt_def_onset_spacing, 'String', num2str(handles.defaults.event_displacement) );

  guidata(handles.figure1, handles);



% --- Executes during object creation, after setting all properties.
function txt_def_onset_spacing_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_def_onset_spacing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_def_duration_Callback(hObject, eventdata, handles)
% hObject    handle to txt_def_duration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  str = get(hObject,'String');
  str = validate_numeric_entry( str );
  handles.defaults.event_duration = str2num( str );
  set( handles.txt_def_duration, 'String', num2str(handles.defaults.event_duration) );

  guidata(handles.figure1, handles);



% --- Executes during object creation, after setting all properties.
function txt_def_duration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_def_duration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_default_bins_Callback(hObject, eventdata, handles)
% hObject    handle to txt_default_bins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_default_bins as text
%        str2double(get(hObject,'String')) returns contents of txt_default_bins as a double


% --- Executes during object creation, after setting all properties.
function txt_default_bins_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_default_bins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_default_TR_Callback(hObject, eventdata, handles)
% hObject    handle to txt_default_TR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_default_TR as text
%        str2double(get(hObject,'String')) returns contents of txt_default_TR as a double


% --- Executes during object creation, after setting all properties.
function txt_default_TR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_default_TR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
