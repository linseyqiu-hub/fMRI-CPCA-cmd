function varargout = Runs_and_Conditions(varargin)
% RUNS_AND_CONDITIONS M-file for Runs_and_Conditions.fig
%      RUNS_AND_CONDITIONS, by itself, creates a new RUNS_AND_CONDITIONS or raises the existing
%      singleton*.
%
%      H = RUNS_AND_CONDITIONS returns the handle to a new RUNS_AND_CONDITIONS or the handle to
%      the existing singleton*.
%
%      RUNS_AND_CONDITIONS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RUNS_AND_CONDITIONS.M with the given input arguments.
%
%      RUNS_AND_CONDITIONS('Property','Value',...) creates a new RUNS_AND_CONDITIONS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Runs_and_Conditions_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Runs_and_Conditions_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Runs_and_Conditions

% Last Modified by GUIDE v2.5 06-Aug-2013 13:27:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Runs_and_Conditions_OpeningFcn, ...
                   'gui_OutputFcn',  @Runs_and_Conditions_OutputFcn, ...
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


% --- Executes just before Runs_and_Conditions is made visible.
function Runs_and_Conditions_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Runs_and_Conditions (see VARARGIN)

  % Choose default command line output for Runs_and_Conditions
  handles.output = hObject;
  handles.allow_import = 1;
  handles.hrf_model = 0;

  if(nargin > 3)
    for index = 1:2:(nargin-3),
      if nargin-3==index, break, end
        switch lower(varargin{index})
         case 'zheader'
          handles.Zheader = varargin{index+1};
         case 'scaninfo'
          handles.scan_information = varargin{index+1};
         case 'import'
          handles.allow_import = varargin{index+1};
         case 'ishrf'
          handles.hrf_model = varargin{index+1};

      end;
    end;
  end
  [handles.Zheader, handles.scan_information] = adjust_headers( handles.Zheader, handles.scan_information, handles.Zheader.Z_Directory );


  set( handles.btn_Okay, 'Enable', 'off' );

  set( handles.btn_load_condition_names, 'Enable', 'on' );


  handles.subjects = handles.scan_information.SubjectID';
  handles.subject = [];

  if ~isempty( handles.Zheader.conditions.Names )
    handles.conditions = handles.Zheader.conditions;
  else
    handles.conditions = struct( 'Names', [], 'subject', [], 'encoded', [], 'allEncoded', 0, 'nonEncoded', 0 );
  end;

  if ( isfield( handles.Zheader, 'conditions' ) )
    if ( isfield( handles.Zheader.conditions, 'Names' ) )
      handles.conditions.Names = handles.Zheader.conditions.Names;
    end;
    if ( isfield( handles.Zheader.conditions, 'subject' ) )
      handles.conditions.subject = handles.Zheader.conditions.subject;
    end;
  end;

  Run = struct( 'conditions', [] );

  update_conditions( handles ) ;

  str = [];
  for ( s = 1:handles.Zheader.num_subjects )
    runs = [];
    for ( ii = 1:handles.Zheader.num_runs )
      run_id = determine_runID( s, ii, handles );
      if length( run_id ) > 0 
        runs = [runs; {run_id}];
      end;
    end;
    str = unique( [str; runs] );
  end;

  set( handles.lst_subjects, 'String', handles.subjects, 'Value', 1 );
  set( handles.lst_subjects, 'Max', handles.Zheader.num_subjects);
  set( handles.lst_runs, 'String', str, 'Value', 1 );
  

  if ( size(handles.conditions.Names,1) > 0 )
    set( handles.lst_conditions, 'String', handles.conditions.Names, 'Value', 1 );
  end;


  handles.lin = '% ------------------------------------------------------';
  handles.hdr = '%s\n%% --- NOTE: The sequence of timing onset definitions is critical.\n%% --- All timing onsets must be prepared in the order displayed in this this file.\n%% --- Timing onsets are NOT be inserted directly into this file, they are imported from a separate text file\n%% --- All timing onsets imported from a separate text file must be prepared in the order displayed below\n%% --- Any onset condition names in an imported text file WILL BE IGNORED and those listed below will be used, in the order listed below\n%s\n\n';

  if ismac
    set( handles.txt_cname, 'HorizontalAlignment', 'center' );
  end

  if handles.scan_information.processing.subjects.tt_count == handles.Zheader.active_runs  
    set( handles.btn_detect_source, 'Visible', 'on' );
  end;
  
  % Update handles structure
  guidata(hObject, handles);

  check_states( handles );

  % UIWAIT makes Runs_and_Conditions wait for user response (see UIRESUME)
  uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Runs_and_Conditions_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
delete(handles.figure1);


% --- Executes on selection change in lst_subjects.
function lst_subjects_Callback(hObject, eventdata, handles)
% hObject    handle to lst_subjects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  x = get(hObject,'Value');
  y = get(handles.lst_runs,'Value');

  if size(x, 2 ) == 1
    runs = [];
    for ( ii = 1:handles.Zheader.num_runs )
      run_id = determine_runID( x, ii, handles );
      if length( run_id ) > 0 
        runs = [runs; {run_id}];
      end;
    end;

    set( handles.lst_runs, 'String', runs, 'Value', 1 );
  end;

  if ( size( x, 2) > 1 )

    set( handles.btn_apply_all_subs, 'Enable', 'off' );
    set( handles.lst_conditions, 'Value', 1 )

  else
    if ( size( y, 2) > 1 )
      set( handles.btn_apply_all_subs, 'Enable', 'off' );
      set( handles.lst_conditions, 'Value', 1 )
    else
      set( handles.btn_apply_all_subs, 'Enable', 'on' );

      % set selected conditions
      if ( ~isempty( handles.conditions.subject ) )
        set( handles.lst_conditions, 'Value', handles.conditions.subject(x).Run(y).conditions )
      end;
    end;
  end;

  % Update handles structure
  guidata(hObject, handles);

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


% --- Executes on selection change in lst_runs.
function lst_runs_Callback(hObject, eventdata, handles)
% hObject    handle to lst_runs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

rvec = get(hObject,'Value');
y = get(handles.lst_subjects,'Value');

if ( ~isempty( handles.conditions.subject ) )
	for i = 1:size(y, 2)
		% set selected conditions
		set( handles.lst_conditions, 'Value', handles.conditions.subject(y(i)).Run(rvec(1)).conditions )
	end
end;

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function lst_runs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_runs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in lst_conditions.
function lst_conditions_Callback(hObject, eventdata, handles)
% hObject    handle to lst_conditions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns lst_conditions contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lst_conditions
% If double click
if strcmp(get(handles.figure1,'SelectionType'),'open')
	Edit_Condition_Name( hObject, 0, handles );
else
	% --- on a condition change, apply the change to selected subject and run(s) ---
	
	x = get(handles.lst_subjects,'Value');
	for i = 1:size(x, 2)
		rvec = get(handles.lst_runs,'Value');
		
		if ( ~isempty( handles.conditions.subject ) )
			vec = get(handles.lst_conditions, 'Value' );
			for idx = 1:size(rvec,2)
				if ( rvec(idx) <= size( handles.Zheader.timeseries.subject(x(i)).run , 1 ) )
					handles.conditions.subject(x(i)).Run(rvec(idx)).conditions = vec;
				end;
			end;
			
			% Update handles structure
			guidata(hObject, handles);
			
			check_states( handles );
			
		end;
	end
end;


% --- Executes during object creation, after setting all properties.
function lst_conditions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_conditions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_cname_Callback(hObject, eventdata, handles)
% hObject    handle to txt_cname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  drawnow();


% --- Executes during object creation, after setting all properties.
function txt_cname_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_cname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_add_condition.
function btn_add_condition_Callback(hObject, eventdata, handles)
% hObject    handle to btn_add_condition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  lst = get( handles.lst_conditions, 'String' );
  x = get( handles.txt_cname, 'String' );
  lst = [lst; {x}];
  set( handles.lst_conditions, 'String', lst );
  set( handles.txt_cname, 'String', '' );

  handles.conditions.Names = lst';

  % Update handles structure
  guidata(hObject, handles);

  update_conditions( handles );
  check_states( handles );
 

% --- Executes on key press with focus on txt_cname and none of its controls.
function txt_cname_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to txt_cname (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

  if ( strcmp( eventdata.Key , 'return' )  )
    txt_cname_Callback(hObject, 0, handles);
    drawnow();
    btn_add_condition_Callback(handles.btn_add_condition, 0, handles);
    set( handles.btn_add_condition, 'Enable', 'off' );
    drawnow();
    return;
  end;

  txt_cname_Callback(hObject, 0, handles);
  drawnow();
  x = get( hObject, 'String' );

  if ( length(x) > 0 ) 
    set( handles.btn_add_condition, 'Enable', 'on' );
    return;
  end;

  str = eventdata.Character;
  x = regexp( str, '([a-zA-Z0-9\s_])', 'match' );

  if ( ~isempty(x) > 0 ) 
    set( handles.btn_add_condition, 'Enable', 'on' );
  else
    set( handles.btn_add_condition, 'Enable', 'off' );
  end;

  % Update handles structure
  guidata(hObject, handles);

  check_states( handles );


function Edit_Condition_Name(hObject, eventdata, handles)
% hObject    handle to lst_Conditions
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  aa = get( hObject, 'String') ;
  [x y] = size( aa );
  if ( x == 0 )  % empty list
    return
  end;

  selected_index = get( hObject, 'Value') ;
  newEntry = inputdlg('Enter the Condition Name','Edit Condition Name', 1, aa(selected_index) );
  if ( ~isempty( newEntry ) ) 
    aa(selected_index) = newEntry;
    set( hObject, 'String', aa, 'Value', 1) ;

    handles.conditions.Names(selected_index) = newEntry;
  end; 

 % Update handles structure
  guidata(hObject, handles);
 
  check_states( handles );


% --- Executes on button press in btn_Okay.
function btn_Okay_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Okay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.conditions.Names = get( handles.lst_conditions, 'String' )' ;

  % -- reset the list of encoded conditions per subject
  handles.conditions.encoded = [];
  handles.conditions.allEncoded = 0;
  handles.conditions.nonEncoded = 0;

  for SubjectNo = 1:handles.Zheader.num_subjects

    z.condition = zeros( 1, size( handles.conditions.Names,2) );

    for cond = 1:size( handles.conditions.Names,2)

      for RunNo = 1:handles.Zheader.num_runs
        if iscellstr( handles.scan_information.SubjDir(SubjectNo, RunNo ) )
          if any ( handles.conditions.subject(SubjectNo).Run(RunNo).conditions == cond )
            z.condition(cond) = 1;
            handles.conditions.allEncoded = handles.conditions.allEncoded + 1;
          else
            handles.conditions.nonEncoded = handles.conditions.nonEncoded + 1;
          end;
        end;  % --- run encoded
      end;  % --- each run

    end; % --- each condition

    handles.conditions.encoded = [handles.conditions.encoded; z];

  end;  % --- each subject

  guidata(hObject, handles);

  handles.output = handles.conditions;
  % Update handles structure
  guidata(hObject, handles);
  uiresume(handles.figure1);


% --- Executes on button press in btn_Cancel.
function btn_Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  handles.output = [];
  % Update handles structure
  guidata(hObject, handles);
  uiresume(handles.figure1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.output = [];
  % Update handles structure
  guidata(hObject, handles);
  uiresume(handles.figure1);


% --- Executes on button press in chk_all_conditions_encoded.
function chk_all_conditions_encoded_Callback(hObject, eventdata, handles)
% hObject    handle to chk_all_conditions_encoded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_all_conditions_encoded


% --- Executes on button press in chk_all_runs_encoded.
function chk_all_runs_encoded_Callback(hObject, eventdata, handles)
% hObject    handle to chk_all_runs_encoded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_all_runs_encoded


% --- Executes on button press in btn_apply_all_subs.
function btn_apply_all_subs_Callback(hObject, eventdata, handles)
% hObject    handle to btn_apply_all_subs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

   vec = get(handles.lst_conditions, 'Value' );
   y = get(handles.lst_runs,'Value');
   for ( x = 1:handles.Zheader.num_subjects )
     if ( size(y,2) > 1 )
       for ii = 1:size( handles.Zheader.timeseries.subject(x).run , 1 )
         handles.conditions.subject(x).Run(y(ii)).conditions = vec;
       end;
     else
       handles.conditions.subject(x).Run(y).conditions = vec;
     end;
   end;


  % Update handles structure
  guidata(hObject, handles);

  check_states( handles );


% --- Executes on button press in btn_apply_all_runs.
function btn_apply_all_runs_Callback(hObject, eventdata, handles)
% hObject    handle to btn_apply_all_runs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

   vec = get(handles.lst_conditions, 'Value' );
   x = get(handles.lst_subjects,'Value');

   for y = 1:handles.Zheader.num_runs
	   for i =1:size(x, 2) 
			handles.conditions.subject(x(i)).Run(y).conditions = vec;
	   end
   end;

  % Update handles structure
  guidata(hObject, handles);

  check_states( handles );


function check_states( handles )

  state = [ {'off'} {'on'} ];

  if ( ~isempty(handles.conditions.subject) )

    all_subs = [];
    all_runs = [];
    for ( ii = 1:handles.Zheader.num_subjects )
      n = [];
      for ( jj = 1:size( handles.Zheader.timeseries.subject(ii).run , 1 ) )
        n = [n handles.conditions.subject(ii).Run(jj).conditions ]; 
        all_runs = [all_runs ~isempty(handles.conditions.subject(ii).Run(jj).conditions)];
      end
      n = unique(n);
%      all_subs = [all_subs ( size(n,2) == size(handles.conditions.Names, 2 ) )];
      all_subs = [ all_subs size(n,2) ];

    end;

    x = find( all_runs == 0 );
%    good_subs = sum(find(all_subs)) == handles.Zheader.num_subjects;
    good_subs = size(find(all_subs),2) == handles.Zheader.num_subjects;
    good_runs = isempty(x);

%good_subs = sum(all_subs) > 0;
%    set( handles.chk_all_conditions_encoded, 'Value', good_subs );
    set( handles.chk_all_conditions_encoded, 'Visible', 'off' );
    set( handles.chk_all_runs_encoded, 'Value', good_runs );

    onoff = ( good_subs & good_runs ) + 1;
%    onoff = good_runs + 1;
    set( handles.btn_create_template, 'Enable', char(state( onoff ) ) );
    set( handles.btn_Okay, 'Enable', char(state( onoff ) ) );

    if ( handles.allow_import )
      fid = fopen( constant_define( 'G_TEMPLATE_NAME' ), 'r' );
      if ( fid > 0 )
        timings = next_entry( fid );
        if ( length( timings) == 0 )
          set( handles.btn_import_onsets, 'Visible', 'on' );
        else
          set( handles.btn_import_onsets, 'Visible', 'off' );
        end;
        fclose ( fid );
      end;
    end

  else

    set( handles.btn_create_template, 'Enable', 'off' );
    set( handles.btn_import_onsets, 'Visible', 'off' );
    set( handles.btn_Okay, 'Enable', 'off' );

    set( handles.chk_all_conditions_encoded, 'Value', 0 );
    set( handles.chk_all_runs_encoded, 'Value', 0 );
  end;

  drawnow();


% --- Executes on button press in btn_select_all_subjects.
function btn_select_all_subjects_Callback(hObject, eventdata, handles)
% hObject    handle to btn_select_all_subjects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  vec = [1:handles.Zheader.num_subjects];
  set( handles.lst_subjects, 'Value', vec );

  % Update handles structure
  guidata(hObject, handles);

  check_states( handles );


% --- Executes on button press in btn_select_all_runs.
function btn_select_all_runs_Callback(hObject, eventdata, handles)
% hObject    handle to btn_select_all_runs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  vec = [1:handles.Zheader.num_runs];
  set( handles.lst_runs, 'Value', vec );

  % Update handles structure
  guidata(hObject, handles);

  check_states( handles );


% --- Executes on button press in btn_select_all_conditions.
function btn_select_all_conditions_Callback(hObject, eventdata, handles)
% hObject    handle to btn_select_all_conditions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  lst = get( handles.lst_conditions, 'String' );
  vec = [1:size(lst,1)];
  set( handles.lst_conditions, 'Value', vec );

  % Update handles structure
  guidata(hObject, handles);

  check_states( handles );


function update_conditions( handles ) 

  if ( size( handles.conditions.subject, 2 ) < handles.Zheader.num_subjects ) & ( size( handles.conditions.Names, 2 ) > 0 )
    for ( ii = size( handles.conditions.subject, 1 )+1:handles.Zheader.num_subjects )

      subject = struct( 'Run', [] );
      for ( jj = 1:handles.Zheader.num_runs )
        Run.conditions = []; % 1:size( handles.conditions.Names, 2 );
        if ( isempty( subject.Run ) )
          subject.Run = Run;
        else
          subject.Run = [subject.Run; Run];
        end;
      end;  % --- each run ---

      if ( isempty ( handles.conditions.subject ) )
        handles.conditions.subject = subject;
      else
        handles.conditions.subject = [handles.conditions.subject; subject];
      end
    end;  % -- each missing subject --
  end;  % all subject data in structure? ---

  % Update handles structure
  guidata(handles.figure1, handles);


% --- Executes on button press in btn_create_template.
function btn_create_template_Callback(hObject, eventdata, handles)
% hObject    handle to btn_create_template (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


  fid = fopen( constant_define( 'G_TEMPLATE_NAME' ), 'w' );

  if ( fid ) fprintf( fid, handles.hdr, handles.lin, handles.lin );  end;

  for ( subject = 1:handles.Zheader.num_subjects )
    s_id = char(handles.scan_information.SubjectID( subject ) );

    if ( fid ) fprintf( fid, '%s\n%% --- timing onsets for subject %s\n%s\n', handles.lin, char(s_id), handles.lin );  end;

    for runno = 1:handles.Zheader.num_runs
      if iscellstr( handles.scan_information.SubjDir( subject, runno ) )
          
        run_id = determine_runID( subject, runno, handles );

        for cond = 1:size( handles.conditions.subject(subject).Run(runno).conditions, 2) ;

%          if any( handles.conditions.subject(subject).Run(runno).conditions == cond )

            cond_id = char( handles.conditions.Names( handles.conditions.subject(subject).Run(runno).conditions( cond )  ) );

            var_id = [s_id '_' run_id '_' cond_id ];
            var_id = strrep( var_id, '__', '_' );
            var_id = strrep( var_id, ' ', '_' );

            if ( fid ) fprintf( fid, '%s = [ ];\n', char(var_id) );  end;
            if ( handles.hrf_model  ) 
              fprintf( fid, '%s_dur = [ ];\n', char(var_id) );  
            end;

%          end; % --- this condition assigned to this subject run
        
        end;  % --- each subject run condition ---
  
        if ( fid ) if ( size(handles.conditions.subject,1) > 2 ) fprintf( fid, '\n' );  end;  end;

      end;  % --- subject contains run ---

    end;  % --- each subject run ---

    if ( fid ) fprintf( fid, '\n' );  end;

  end;  % --- each subject ---

  if ( fid ) 
    fclose( fid );
    eval( [ 'edit ' constant_define( 'G_TEMPLATE_NAME' ) ';' ] );
  end;

  check_states( handles );





% --- Executes on key press with focus on lst_conditions and none of its controls.
function lst_conditions_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to lst_conditions (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

  deleteItem = strcmp( eventdata.Key, 'delete' );
  if ~deleteItem & ismac()
    deleteItem = strcmp( eventdata.Key, 'backspace' );
  end;

  if ( deleteItem )
    lst = get( handles.lst_conditions, 'String' );
    idx = get( handles.lst_conditions, 'Value' );

    new_lst = [];
    for ii = 1:size(lst,1)
      if ( ii ~= idx )
        new_lst = [new_lst; lst(ii)];
      end;
    end;

    set( handles.lst_conditions, 'String', new_lst );

    handles.conditions.Names = new_lst';

    % ---------------------------------------
    % --- deleting a condition corrupts all entries
    % --- so reset all entries to to empty set
    % ---------------------------------------
    handles.conditions.subject = [];

    for ( ii = 1:handles.Zheader.num_subjects )

      subject = struct( 'Run', [] );
      for ( jj = 1:handles.Zheader.num_runs )
        Run.conditions = [1]; % 1:size( handles.conditions.Names, 2 );
        if ( isempty( subject.Run ) )
          subject.Run = Run;
        else
          subject.Run = [subject.Run; Run];
        end;
      end;  % --- each run ---

      if ( isempty ( handles.conditions.subject ) )
        handles.conditions.subject = subject;
      else
        handles.conditions.subject = [handles.conditions.subject; subject];
      end
    end;  % -- each missing subject --

    % Update handles structure
    guidata(hObject, handles);


    lst_runs_Callback( handles.lst_runs, 0, handles );
    update_conditions( handles );
    check_states( handles );
  end


% --- Executes on button press in btn_import_onsets.
function btn_import_onsets_Callback(hObject, eventdata, handles)
% hObject    handle to btn_import_onsets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  fl = import_onsets_list( handles );
  if ( length( fl ) > 0 )
      eval( [ 'edit ''' fl ''';' ] );
  end


% --- Executes on button press in btn_load_condition_names.
function btn_load_condition_names_Callback(hObject, eventdata, handles)
% hObject    handle to btn_load_condition_names (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  fullpath = select_file( {'*.txt;*.mat','text file, MATLAB file'}, ...
                                   'Select your text or MATLAB file');
  if ~isempty( fullpath )
    lst = 0;
    str = regexp( fullpath, '.mat$', 'match' );
    x = size(str);
    if  x(1) > 0 

      mat_vars = matfile_vars( '', fullpath );
      [mf_x mf_y] = size( mat_vars );

      if ( mf_x > 0 )    % there are variables in the file
        if ( mf_x == 1 )   % only a single variable in the file

          eval ( ['load( ''' fullpath ''', ''' mat_vars.name ''')'] );
          eval ( ['lst = ' mat_vars.name ';'] );

        else

          cont = '';
          for ii=1:mf_x
            cont = horzcat( cont, {mat_vars(ii).name});
          end
          var_index = mat_selection( cont, 'Select Condition Names' );

          if ( x )		% --- user made a selection ---

            eval ( ['load( ''' fullpath ''', ''' char(mat_vars(var_index).name) ''')'] );
            eval ( ['lst = ' char(mat_vars(var_index).name) ';'] );

          else
            return;
          end;

        end;
      end;

    else

      a = textread( fullpath, '%s', 'whitespace', '' );
      a = strtrim(a);
      a = strrep(a, '_', ' ');
      x = regexp( char(a), '\n', 'split' );
      lst = x';

    end;

    set( handles.lst_conditions, 'String', lst );
    set( handles.txt_cname, 'String', '' );

    handles.conditions.Names = lst';

    % Update handles structure
    guidata(hObject, handles);

    update_conditions( handles );
    check_states( handles );

  end;


% --- Executes on button press in btn_detect_source.
function btn_detect_source_Callback(hObject, eventdata, handles)
% hObject    handle to btn_detect_source (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

   % --- detect what named conditions are encoded for each subjecty and run
   nm = get(handles.lst_conditions, 'String' );
   vec = [1:size(nm,1)];

   for (SubjectNo = 1:handles.Zheader.num_subjects )
     set( handles.lst_subjects, 'Value', SubjectNo );
     drawnow();
     
     for (RunNo = 1:handles.Zheader.num_runs )
         
       this_vec = [];
       
       if iscellstr( handles.scan_information.SubjDir(SubjectNo, RunNo ) )

         fullpath =  [char(handles.scan_information.BaseDir) filesep char(handles.scan_information.SubjDir( SubjectNo, RunNo )) filesep ];
         d = dir( [ fullpath constant_define( 'SOURCE_TIMING_SPEC' ) ] );
         if size( d, 1 ) == 1
      
           onsetsfile = [ fullpath d(1).name ];
           fidr = fopen ( onsetsfile, 'r' );
           if fidr
             run_id = determine_runID( SubjectNo, RunNo, handles );

             for cond = 1:size( vec, 2) ;
               cond_id = char( handles.conditions.Names(cond ) );
               cond_id = strrep( cond_id, ' ', '_' );   % --- replace any spaces with underscore characters
            
               [timings f] = find_entry( fidr, cond_id );
               x = [];
               eval( [ 'x = [ ' timings '];' ] );
               if ~isempty(x)
                 this_vec = [this_vec cond];
               end
             end;  % --- each named condition
             
             fclose( fidr );
           end;
           
         end; % --- trial onsets file found

       end;  % --- run encoded

       handles.conditions.subject(SubjectNo).Run(RunNo).conditions = this_vec;

     end;  % --- each run
     
   end;  % --- each subject
   

  set( handles.lst_subjects, 'Value', 1 );
  set( handles.lst_runs, 'Value', 1 );
  drawnow();


  % Update handles structure
  guidata(hObject, handles);

  check_states( handles );

