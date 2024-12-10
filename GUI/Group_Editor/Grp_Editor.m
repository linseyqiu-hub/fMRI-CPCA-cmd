function varargout = Grp_Editor(varargin)
% GRP_EDITOR M-file for Grp_Editor.fig
%      GRP_EDITOR, by itself, creates a new GRP_EDITOR or raises the existing
%      singleton*.
%
%      H = GRP_EDITOR returns the handle to a new GRP_EDITOR or the handle to
%      the existing singleton*.
%
%      GRP_EDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GRP_EDITOR.M with the given input arguments.
%
%      GRP_EDITOR('Property','Value',...) creates a new GRP_EDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Grp_Editor_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Grp_Editor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Grp_Editor

% Last Modified by GUIDE v2.5 12-Aug-2013 10:08:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Grp_Editor_OpeningFcn, ...
                   'gui_OutputFcn',  @Grp_Editor_OutputFcn, ...
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


% --- Executes just before Grp_Editor is made visible.
function Grp_Editor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Grp_Editor (see VARARGIN)
%global Zheader scan_information;

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
  [handles.Zheader, handles.scan_information] = adjust_headers( handles.Zheader, handles.scan_information, handles.Zheader.Z_Directory );

  set ( handles.btn_select_subjects, 'Visible', 'off' );

  lst = [];
  nmgrp = 0;
  grps = [];
  for ii = 1:size(handles.scan_information.GroupList,1)  
    if  length(handles.scan_information.GroupList(ii).subjectlist) > 0 nmgrp = nmgrp + 1;  grps = [grps; handles.scan_information.GroupList(ii)]; end;
  end;
  handles.scan_information.NumGroups = nmgrp;
  handles.scan_information.GroupList = grps;


  if ( handles.scan_information.NumGroups > 0 )
    for ( ii = 1:size(handles.scan_information.GroupList,1) )
      lst = [lst; {handles.scan_information.GroupList(ii).name}];
    end;
  end;
  set( handles.lst_Groups, 'String', lst, 'Value', 1 );

  lst = [];
  if ( handles.scan_information.NumSubjects > 0 )
    for ( ii = 1:size(handles.scan_information.SubjectID,2) )
      lst = [lst; {char(handles.scan_information.SubjectID(ii))}];
    end;
  end;
  set( handles.lst_Subjects, 'String', lst, 'Value', 1 );

  if ( handles.scan_information.NumGroups > 0 )
    SubjectVector = handles.scan_information.GroupList(1).subjectlist;
    set_group_subjects( handles, 1, SubjectVector );
  else
    set( handles.lst_GroupSubjects, 'String', [], 'Value', 0 );
  end;
  
  fn = [ handles.Zheader.Z_Directory 'Z' filesep 'Z1.mat' ];
  if ( ~exist( fn, 'file' ) )
    set( handles.btn_recalc_SS, 'Enable', 'off' );
  end;


% Choose default command line output for Grp_Editor
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Grp_Editor wait for user response (see UIRESUME)
 uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Grp_Editor_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
delete(hObject);


% --- Executes on selection change in lst_Groups.
function lst_Groups_Callback(hObject, eventdata, handles)
% hObject    handle to lst_Groups (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  grpno = get(hObject,'Value');

  if ( ~isempty( grpno ) )		% trap user double click on empty list

    % If double click - add selected subject to selected list
    if strcmp(get(handles.figure1,'SelectionType'),'open')
      contents = get(hObject,'String');
      grpname = contents{grpno};

      newEntry = inputdlg('Group Name', 'Edit Group Name', 1, {grpname} );
      if ( ~isempty( newEntry ) ) 
        contents(grpno) = newEntry;
        set( handles.lst_Groups, 'String', contents, 'Value', grpno );

        handles.scan_information.GroupList(grpno).name = char(newEntry);
        % Update handles structure
        guidata(hObject, handles);

      end

    else
% --- TODO: Allow multiple group selection to allow for combination of existing groups
      SubjectVector = [];
      for ii = 1:size(grpno, 2)
        SubjectVector = [SubjectVector str2num(handles.scan_information.GroupList(grpno(ii)).subjectlist )];
      end
      set_group_subjects( handles, grpno, SubjectVector );		
      set( handles.lst_Subjects, 'Value', SubjectVector );
    end;

  end;

% --- Executes during object creation, after setting all properties.
function lst_Groups_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_Groups (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in lst_Subjects.
function lst_Subjects_Callback(hObject, eventdata, handles)
% hObject    handle to lst_Subjects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  % If double click - add selected subject to selected list
  if strcmp(get(handles.figure1,'SelectionType'),'open')

    contents = get(hObject,'String');
    SubjectNo = get(hObject,'Value');
    Subject = char(contents{SubjectNo});
    grpno = get( handles.lst_Groups, 'Value');

    SubjectVector = [];
    contents = get(handles.lst_GroupSubjects,'String');
    for ( ii = 1:size(contents,1) )
      if strcmp( Subject, char(contents( ii )) )  return; end	% subject already in list

      for ( jj = 1:size(handles.scan_information.SubjectID,2) )
        if ( strcmp( char(contents( ii )), char(handles.scan_information.SubjectID( jj )) ) )
          SubjectVector = [SubjectVector jj];
        end
      end
    end;
   
    SubjectVector  = [SubjectVector SubjectNo];

    set_group_subjects( handles, grpno, SubjectVector );

  end;


% --- Executes during object creation, after setting all properties.
function lst_Subjects_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_Subjects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in lst_GroupSubjects.
function lst_GroupSubjects_Callback(hObject, eventdata, handles)
% hObject    handle to lst_GroupSubjects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns lst_GroupSubjects contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lst_GroupSubjects

  % If double click - remove subject from selected list
  if strcmp(get(handles.figure1,'SelectionType'),'open')

    grpno = get( handles.lst_Groups, 'Value');

    SubjectNo = get(hObject,'Value');
    adj = [];

    SubjectVector = [];
    contents = get(handles.lst_GroupSubjects,'String');
    for ( ii = 1:size(contents,1) )
      for ( jj = 1:size(handles.scan_information.SubjectID,2) )
        if ( strcmp( char(contents( ii )), char(handles.scan_information.SubjectID( jj )) ) )
          SubjectVector = [SubjectVector jj];
        end
      end
    end;

    for ( ii = 1:size(SubjectVector, 2 ) )
      if ( ii ~= SubjectNo )
        adj = [adj SubjectVector(ii) ];
      end;
    end;

    % Update handles structure
    guidata(hObject, handles);

    set_group_subjects( handles, grpno, adj );

  end;

% --- Executes during object creation, after setting all properties.
function lst_GroupSubjects_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_GroupSubjects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function set_group_subjects( handles, grpno, SubjectVector )

  if ~isnumeric( SubjectVector ) SubjectVector = str2num(SubjectVector);  end;

  lst = [];
  handles.tsum = 0;
  handles.tsumr = 0;
  handles.sdepth = 0;

  txt = 'determining extents: ';
  nm = [ ' of ' num2str( size(SubjectVector,2) ) ];
  for ( ii = 1:size(SubjectVector,2) )
    set( handles.lbl_calculating, 'String', [txt num2str(ii) nm ] );
    lst = [lst; {char(handles.scan_information.SubjectID(SubjectVector(ii)))}];

    fn = [ handles.Zheader.Z_Directory 'Z' filesep 'Z' num2str(SubjectVector(ii)) '.mat' ];
    if ( exist( fn, 'file' ) )
      eval( ['load ( ''' fn ''', ''tsum*'') '] );
    end;
    if ( exist('tsum_subject', 'var' ) )       handles.tsum = handles.tsum + tsum_subject;		end;
    if ( exist('tsum_removed', 'var' ) )       handles.tsumr = handles.tsumr + tsum_removed;		end;
    handles.sdepth = handles.sdepth + sum(handles.Zheader.timeseries.subject(SubjectVector(ii)).run(:,1));
  end;
  set( handles.lbl_calculating, 'String', '' );
  set( handles.lst_GroupSubjects, 'String', lst, 'Value', 1 );

  str = sprintf( ' Subjects: %d', size(SubjectVector,2) );
  set( handles.lbl_numSubjects, 'String', str );

  str = sprintf( ' Scans: %d', handles.sdepth );
  set( handles.lbl_depth, 'String', str );

  str = sprintf( ' SS: %.2f', handles.tsum );
  set( handles.lbl_SS, 'String', str );

  if ( handles.tsumr > 0 & handles.tsum > 0 )
    regressed_out = handles.tsumr/handles.tsum * 100;
    str = sprintf( ' SS Removed: %.2f%%', regressed_out );
  else 
    str = ' SS Removed: N/A';
  end;
  set( handles.lbl_Regressed, 'String', str );



% --- Executes on button press in btn_update.
function btn_update_Callback(hObject, eventdata, handles)
% hObject    handle to btn_update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  lst = get(handles.lst_Subjects,'String');
  s = get(handles.lst_Subjects,'Value');
  
  lst2 = lst(s);
  set( handles.lst_GroupSubjects, 'String', lst2, 'Value', 1 );

  grpno = get( handles.lst_Groups, 'Value');

  tsum = 0;
  tsumr = 0;
  sdepth = 0;

  SubjectVector = [];
  contents = get(handles.lst_GroupSubjects,'String');
  for ( ii = 1:size(contents,1) )
    for ( jj = 1:size(handles.scan_information.SubjectID,2) )
      if ( strcmp( char(contents( ii )), char(handles.scan_information.SubjectID( jj )) ) )
        SubjectVector = [SubjectVector jj];
      end
    end
  end;

  for ( ii = 1:size(SubjectVector,2) )
    fn = [ handles.Zheader.Z_Directory 'Z' filesep 'Z' num2str(SubjectVector(ii)) ];
    eval( ['load ( ''' fn '.mat'', ''tsum*'') '] );
    if ( exist('tsum_subject', 'var' ) )       tsum = tsum + tsum_subject;		end;
    if ( exist('tsum_removed', 'var' ) )       tsumr = tsumr + tsum_removed;		end;
    sdepth = sdepth + sum(handles.Zheader.timeseries.subject(SubjectVector(ii)).run(:,1));
  end;

  handles.scan_information.GroupList(grpno).tsum = tsum;
  handles.scan_information.GroupList(grpno).tsum_removed = tsumr;
  handles.scan_information.GroupList(grpno).subjectdepth = sdepth;
  handles.scan_information.GroupList(grpno).subjectcount = size(SubjectVector,2);
  handles.scan_information.GroupList(grpno).subjectlist  = num2str(SubjectVector);
  % Update handles structure
  guidata(handles.figure1, handles);


% --- Executes on button press in btn_add.
function btn_add_Callback(hObject, eventdata, handles)
% hObject    handle to btn_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  lst = get(handles.lst_Subjects,'String');
  s = get(handles.lst_Subjects,'Value');
  
  lst2 = lst(s);
  set( handles.lst_GroupSubjects, 'String', lst2, 'Value', 1 );

  grp = structure_define( 'SUBJECT_GROUP' );
  grp.name = 'New Group';

  tsum = 0;
  tsumr = 0;
  sdepth = 0;

  SubjectVector = [];
  contents = get(handles.lst_GroupSubjects,'String');
  for ( ii = 1:size(contents,1) )
    for ( jj = 1:size(handles.scan_information.SubjectID,2) )
      if ( strcmp( char(contents( ii )), char(handles.scan_information.SubjectID( jj )) ) )
        SubjectVector = [SubjectVector jj];
      end
    end
  end;

  for ( ii = 1:size(SubjectVector,2) )
    if( length(handles.Zheader.Z_Directory) > 0 ) cwd = ''; else cwd = './';  end;
    fn = [ handles.Zheader.Z_Directory cwd 'Z' filesep 'Z' num2str(SubjectVector(ii)) '.mat' ];
    if ( exist( fn, 'file' ) )
      eval( ['load ( ''' fn ''', ''tsum*'') '] );
    end;
    if ( exist('tsum_subject', 'var' ) )       tsum = tsum + tsum_subject;		end;
    if ( exist('tsum_removed', 'var' ) )       tsumr = tsumr + tsum_removed;		end;
    sdepth = sdepth + sum(handles.Zheader.timeseries.subject(SubjectVector(ii)).run(:,1));
  end;

  grp.tsum = tsum;
  grp.tsum_removed = tsumr;
  grp.subjectdepth = sdepth;
  grp.subjectcount = size(SubjectVector,2);
  grp.subjectlist  = num2str(SubjectVector);

  handles.scan_information.GroupList = [handles.scan_information.GroupList; grp ];
  handles.scan_information.NumGroups = handles.scan_information.NumGroups + 1;
  % Update handles structure
  guidata(handles.figure1, handles);

  contents = get(handles.lst_Groups,'String');
  contents = [contents; {grp.name}];
  set(handles.lst_Groups,'String', contents, 'Value', size(contents,1) );


% --- Executes on button press in btn_clr.
function btn_clr_Callback(hObject, eventdata, handles)
% hObject    handle to btn_clr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  set( handles.lst_GroupSubjects, 'String', [], 'Value', 0 );

% --- Executes on button press in btn_okay.
function btn_okay_Callback(hObject, eventdata, handles)
% hObject    handle to btn_okay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.output = handles.scan_information.GroupList;

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


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
%delete(hObject);
  handles.output = '';

  guidata(handles.figure1, handles);
  uiresume(handles.figure1);


% --- Executes on button press in btn_recalc_SS.
function btn_recalc_SS_Callback(hObject, eventdata, handles)
% hObject    handle to btn_recalc_SS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  grpno = get( handles.lst_Groups, 'Value');
  SubjectVector = str2num(handles.scan_information.GroupList(grpno).subjectlist);

  tsum_v = 0;

  for idx=1:size(SubjectVector,2)

    set( handles.lst_GroupSubjects, 'Value', idx );
    drawnow();

    SubjectNo = SubjectVector( idx );
    tsum_subject = 0;

    for RunNo = 1:handles.Zheader.num_runs;

      %------------------------------------------------
      % load in the normalized Z segment
      %  model application is done on full subject width
      %------------------------------------------------

      time_series = handles.Zheader.timeseries.subject(SubjectNo).run(RunNo,1);
      Z = zeros(time_series, handles.Zheader.total_columns );

      start_col = 1;
      end_col = 1;

      for column = 1:size( handles.Zheader.partitions.columns,2)

        eval ( [ 'load( ''' handles.Zheader.Z_Directory 'Z' filesep 'Z' num2str(SubjectNo) '.mat'', ''Z_R' num2str(RunNo) '_C' num2str(column) ''')'] );
        eval( ['end_col = start_col + size( Z_R' num2str(RunNo) '_C' num2str(column) ', 2 ) - 1;' ] );
        eval ( [ 'Z(1:' num2str(time_series) ',' num2str(start_col) ':' num2str(end_col) ') = Z_R' num2str(RunNo) '_C' num2str(column) ';' ] );

        start_col = end_col + 1;
        eval( ['clear Z_R' num2str(RunNo) '_C' num2str(column) ] );
      end;


      for jj=1:size(Z,2)		% each column of Z
        tsum_v = Z(:,jj)' * Z(:,jj);
        tsum_subject = tsum_subject + tsum_v;
        handles.scan_information.GroupList(grpno).tsum = handles.scan_information.GroupList(grpno).tsum + tsum_v;
      end

      guidata(handles.figure1, handles);

      str = sprintf( ' SS: %.2f', handles.scan_information.GroupList(grpno).tsum );
      set( handles.lbl_SS, 'String', str );
      drawnow();

      eval ( [ 'save( ''' handles.Zheader.Z_Directory 'Z' filesep 'Z' num2str(SubjectNo) '.mat'', ''tsum_subject'', ''-append'')' ] );

    end;	% --- each run ---

  end;	% --- each Subject ---

  set( handles.lst_GroupSubjects, 'Value', 1 );


% --- Executes on button press in btn_select_subjects.
function btn_select_subjects_Callback(hObject, eventdata, handles)
% hObject    handle to btn_select_subjects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  lst = get(handles.lst_Subjects,'String');
  
  [s,v] = listdlg('PromptString','Select Subjects for Group','ListString', lst );
  if ( v );
    lst2 = lst(s);
    set( handles.lst_GroupSubjects, 'String', lst2, 'Value', 1 );
  end;


% --- Executes on key press with focus on lst_Groups and none of its controls.
function lst_Groups_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to lst_Groups (see GCBO)
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

    idx = get( hObject, 'Value' );
    content = get( hObject, 'String' );

    new_grouplist = [];
    lst = [];

    for ( ii = 1:size(content,1) )
      if ( ii ~= idx )
        str = char(content(ii));
        lst = [lst {str} ];
 
        new_grouplist = [new_grouplist; handles.scan_information.GroupList(ii)];

      end;
    end;

    set ( hObject, 'String', lst, 'Value', 1 );
    handles.scan_information.GroupList = new_grouplist;

    guidata(handles.figure1, handles);
 
  end;
