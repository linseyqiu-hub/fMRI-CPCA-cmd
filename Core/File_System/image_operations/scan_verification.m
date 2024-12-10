function varargout = scan_verification(varargin)
% SCAN_VERIFICATION M-file for scan_verification.fig
%      SCAN_VERIFICATION, by itself, creates a new SCAN_VERIFICATION or raises the existing
%      singleton*.
%
%      H = SCAN_VERIFICATION returns the handle to a new SCAN_VERIFICATION or the handle to
%      the existing singleton*.
%
%      SCAN_VERIFICATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SCAN_VERIFICATION.M with the given input arguments.
%
%      SCAN_VERIFICATION('Property','Value',...) creates a new SCAN_VERIFICATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before scan_verification_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to scan_verification_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help scan_verification

% Last Modified by GUIDE v2.5 19-Aug-2010 10:35:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @scan_verification_OpeningFcn, ...
                   'gui_OutputFcn',  @scan_verification_OutputFcn, ...
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


% --- Executes just before scan_verification is made visible.
function scan_verification_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to scan_verification (see VARARGIN)
global Zheader scan_information;

  [handles.Zheader, handles.scan_information] = adjust_headers( Zheader, scan_information, Zheader.Z_Directory );
  handles.dir_char = '/';
  handles.summary_type = 1;		% 1 = all, 2 = errors, 3 = good
  handles.reparse = 0;			% flag file list requiring reparsing

  if ( ispc )	handles.dir_char = '\'; 	end;

  set( handles.lst_subjects, 'String', handles.scan_information.SubjectID', 'Value', 1 );

  x = exist( './scan_verification.mat', 'file' );
  if ( x == 2 )
    load scan_verification;

    update_scan_results( handles, subject_verification );
    show_total( handles, total_verification );

    if ( total_verification.bad > 0 )
      set( handles.btn_save_errors, 'Visible', 'on' );
    else
      set( handles.btn_save_errors, 'Visible', 'off' );
    end;

  end;

  set( handles.chk_verify_all_subjects, 'Value', 1 );
  idx = [1:size(handles.scan_information.SubjectID, 2)];
  set( handles.lst_subjects, 'Value', idx );

   if ismac()
    p = get( handles.txt_current, 'Position' );
    p(4) = p(4)*1.1;
    set( handles.txt_current, 'Position', p );
    
    p = get( handles.txt_total, 'Position' );
    p(4) = p(4)*1.1;
    set( handles.txt_total, 'Position', p );
  end;

  % Choose default command line output for scan_verification
  handles.output = hObject;

  % Update handles structure
  guidata(hObject, handles);

  % UIWAIT makes scan_verification wait for user response (see UIRESUME)
  uiwait(handles.figure1);



% --- Outputs from this function are returned to the command line.
function varargout = scan_verification_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
  varargout{1} = handles.reparse;
  delete(handles.figure1);


% --- Executes on button press in btn_done.
function btn_done_Callback(hObject, eventdata, handles)
% hObject    handle to btn_done (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%  varargout{1} = '';
  uiresume(handles.figure1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.reparse = 0;
  uiresume(handles.figure1);



% --- Executes on selection change in lst_subjects.
function lst_subjects_Callback(hObject, eventdata, handles)
% hObject    handle to lst_subjects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns lst_subjects contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lst_subjects
  x = get(hObject,'Value');

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


% --- Executes on button press in chk_verify_all_subjects.
function chk_verify_all_subjects_Callback(hObject, eventdata, handles)
% hObject    handle to chk_verify_all_subjects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  lst = get(handles.lst_subjects,'String');

  x = get(hObject,'Value');
  if ( x )
    idx = [1:size(handles.scan_information.SubjectID, 2)];
    set( handles.lst_subjects, 'String', lst, 'Value', idx );
  else
    set( handles.lst_subjects, 'String', lst, 'Value', 1 );
  end


function lst_results_Callback(hObject, eventdata, handles)
% hObject    handle to lst_results (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lst_results as text
%        str2double(get(hObject,'String')) returns contents of lst_results as a double


% --- Executes during object creation, after setting all properties.
function lst_results_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_results (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_verify.
function btn_verify_Callback(hObject, eventdata, handles)
% hObject    handle to btn_verify (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  lst = get(handles.lst_subjects,'String');
  subject_vector = get(handles.lst_subjects,'Value');
  set( handles.lst_results, 'String', [] );

  txt = [];
  v = struct ( 'SubjectID', '', 'Freq', '', 'RunNo', 0, 'good', 0, 'bad', 0, 'wrong_dim', 0, 'count', 0, 'dim', [], 'pixdim', [], 'files', struct( 'name', [] ) );

  subject_verification = [];
  total_verification = v;
  initial_dim = [];
  initial_pixdim = [];

  for FrequencyNo = 1:handles.Zheader.num_Z_arrays
  for Subject = 1:size(subject_vector, 2 )
    SubjectNo = subject_vector(Subject);
    SubjectID = char(lst(SubjectNo));

    set( handles.lst_subjects, 'Value', SubjectNo );

    for RunNo = 1:handles.Zheader.num_runs

      if iscellstr( handles.scan_information.SubjDir( Subject, RunNo ) )

        verification = v;
        verification.SubjectID = SubjectID;
        verification.RunNo = RunNo;

        verification.Freq = '';

        if handles.scan_information.frequencies > 0 
          if ( length(char(handles.scan_information.freq_names(FrequencyNo))) > 0 )  
            if ( ~strcmp( char(handles.scan_information.freq_names(FrequencyNo)), '<na>') )  
              verification.Freq = char(handles.scan_information.freq_names(FrequencyNo)); 
            end;
          end;
        end;

        time_series = handles.Zheader.timeseries.subject(SubjectNo).run(RunNo,1);

        %------------------------------------------------
        % full path of subject scan files for directory reading 
        %------------------------------------------------
        subject_dir = subject_scan_directory( SubjectNo, RunNo, FrequencyNo);
        dirspec = [ subject_dir filesep handles.scan_information.ListSpec ];

        % --------------------------------------------------------
        % read directory and process individual files
        % --------------------------------------------------------
        D=dir(dirspec);
        n_files=size(D,1);

        for scan_no = 1:n_files

          %------------------------------------------------
          % full path of subject individual scan file
          %------------------------------------------------
          filespec = [ subject_dir filesep D(scan_no).name ];

          pathspec= [ subject_dir filesep ];
           
          %------------------------------------------------
          % load in scan image and place in holding matrix
          %------------------------------------------------
          img = cpca_read_vol( filespec );
          verification.count = verification.count + 1;
          total_verification.count = total_verification.count + 1;

          if isfield( img.header, 'error' )
            verification.bad = verification.bad + 1;
            total_verification.bad = total_verification.bad + 1;

% --- place in secondary display
            fn = strrep( img.header.error, pathspec, '' );
            name = strrep( fn, 'file corrupted ', '' );
            verification.files.name = [verification.files.name; {name} ];
          else

            if isempty( initial_dim )   initial_dim = img.vol.dim;  end;
            if isempty( initial_pixdim )   initial_pixdim = img.header.pixdim(2:4);  end;

            verification.dim = img.vol.dim;
            verification.pixdim = img.header.pixdim(2:4);

            if all(verification.dim == initial_dim) & all(verification.pixdim == initial_pixdim)
              verification.good = verification.good + 1;
              total_verification.good = total_verification.good + 1;
            else
              verification.bad = verification.bad + 1;
              total_verification.bad = total_verification.bad + 1;

              verification.wrong_dim = verification.wrong_dim + 1;
              total_verification.wrong_dim = total_verification.wrong_dim + 1;
            end;

          end;

          summary = sprintf( '%s %s run%d  (%6d:%6d) %6d/%6d', SubjectID, verification.Freq, RunNo, verification.bad, verification.wrong_dim, verification.good, verification.count );
          set( handles.txt_current, 'String', summary );
          drawnow();

        end;  % --- each scan image ---

        subject_verification = [subject_verification; verification ];
        update_scan_results( handles, subject_verification );
        set( handles.lst_results, 'Value', size(subject_verification,1) );

        show_total( handles, total_verification );

      end;  % --- Subject contains run ---
    end;  % --- each run ---

  end;  % --- each selected subject ---
  end;  % --- each frequency range

%  set( handles.lst_subjects, 'Value', 1 );
  show_total( handles, total_verification );

  set( handles.txt_current, 'String', '' );
  set( handles.lst_results, 'Value', 1 );

  save scan_verification subject_verification total_verification;

  if ( total_verification.bad > 0 )
    set( handles.btn_save_errors, 'Visible', 'on' );
  else
    set( handles.btn_save_errors, 'Visible', 'off' );
  end;



% --- Executes on button press in btn_save_errors.
function btn_save_errors_Callback(hObject, eventdata, handles)
% hObject    handle to btn_save_errors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  % do not assume the file exists

  x = exist( './scan_verification.mat', 'file' );
  if ( x == 2 )
    load scan_verification;

    text_file = 'scan_verification.txt';
    fid = fopen( text_file, 'w' );
    if ( fid )

      for ii = 1:size(subject_verification, 1 )

        if ( subject_verification(ii).bad > 0 )

          fprintf( fid, '%s %s run%d  (%6d) %6d/%6d', ...
            subject_verification(ii).SubjectID, ...
            subject_verification(ii).Freq, ...
            subject_verification(ii).RunNo, ...
            subject_verification(ii).bad, ...
            subject_verification(ii).good, ...
            subject_verification(ii).count );

          for ( jj = 1:size(subject_verification(ii).files.name, 1) )
            fn = char(subject_verification(ii).files.name(jj));
            fprintf( fid, ' file: %s\n', fn );
          end;
          fprintf( fid, '\n' );

        end;
      end;

      fclose( fid );

      eval( ['edit ' text_file ] );

    end;
  end;

function txt_current_Callback(hObject, eventdata, handles)
% hObject    handle to txt_current (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_current as text
%        str2double(get(hObject,'String')) returns contents of txt_current as a double


% --- Executes during object creation, after setting all properties.
function txt_current_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_current (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_total_Callback(hObject, eventdata, handles)
% hObject    handle to txt_total (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_total as text
%        str2double(get(hObject,'String')) returns contents of txt_total as a double


% --- Executes during object creation, after setting all properties.
function txt_total_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_total (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function show_total( handles, total_verification )

%  summary = sprintf( ' Total:  count: %6d  good:%6d  err: %6d', ...
  summary = sprintf( ' %6d scans  %6d good  %6d read err  %6d dim err', ...
    total_verification.count, ...
    total_verification.good, ...
    total_verification.bad, ...
    total_verification.wrong_dim );
  set( handles.txt_total, 'String', summary );


function update_scan_results( handles, subject_verification )

  txt = [];
  for ii = 1:size(subject_verification, 1 )

    summary = sprintf( '%s %s run%d  (%6d:%6d) %6d/%6d', ...
      subject_verification(ii).SubjectID, ...
      subject_verification(ii).Freq, ...
      subject_verification(ii).RunNo, ...
      subject_verification(ii).bad, ...
      subject_verification(ii).good, ...
      subject_verification(ii).wrong_dim, ...
      subject_verification(ii).count );

    switch (handles.summary_type)
      case 2
        if ( subject_verification(ii).bad > 0 )
          txt = [txt; {summary}];
        end;

      case 3
        if ( subject_verification(ii).bad == 0 )
          txt = [txt; {summary}];
        end;

      otherwise
        txt = [txt; {summary}];
    end;
    
  end;
  set( handles.lst_results, 'String', txt, 'Value', 1 );


% --- Executes on button press in chk_view_all.
function chk_view_all_Callback(hObject, eventdata, handles)
% hObject    handle to chk_view_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  set( hObject, 'Value', 1 );
  set( handles.chk_view_errors, 'Value', 0 );
  set( handles.chk_view_good, 'Value', 0 );
  handles.summary_type = 1;		% 1 = all, 2 = errors, 3 = good
  % Update handles structure
  guidata(hObject, handles);

  x = exist( './scan_verification.mat', 'file' );
  if ( x == 2 )
    load scan_verification;
    update_scan_results( handles, subject_verification );
  end;

% --- Executes on button press in chk_view_errors.
function chk_view_errors_Callback(hObject, eventdata, handles)
% hObject    handle to chk_view_errors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  set( handles.chk_view_all, 'Value', 0 );
  set( hObject, 'Value', 1 );
  set( handles.chk_view_good, 'Value', 0 );
  handles.summary_type = 2;		% 1 = all, 2 = errors, 3 = good
  % Update handles structure
  guidata(hObject, handles);

  x = exist( './scan_verification.mat', 'file' );
  if ( x == 2 )
    load scan_verification;
    update_scan_results( handles, subject_verification );
  end;


% --- Executes on button press in chk_view_good.
function chk_view_good_Callback(hObject, eventdata, handles)
% hObject    handle to chk_view_good (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  set( handles.chk_view_all, 'Value', 0 );
  set( handles.chk_view_errors, 'Value', 0 );
  set( hObject, 'Value', 1 );
  handles.summary_type = 3;		% 1 = all, 2 = errors, 3 = good
  % Update handles structure
  guidata(hObject, handles);

  x = exist( './scan_verification.mat', 'file' );
  if ( x == 2 )
    load scan_verification;
    update_scan_results( handles, subject_verification );
  end;


% --- Executes on button press in btn_remove_from_list.
function btn_remove_from_list_Callback(hObject, eventdata, handles)
% hObject    handle to btn_remove_from_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  content = get(handles.lst_results,'String');
  entry = char(content(get(handles.lst_results,'Value'),:) );
  subs = get(handles.lst_subjects,'String');

  xx = regexp( entry, ' ', 'split' );
  sid = char(xx(1));

  if ( ispc() ) dchr = '\'; else dchr = '/'; end;

  regex = ['sdir:.*' sid];
  tmpfile = tempname();
  tmpfile = tmpfile( max( find(tmpfile == dchr ) ) + 1:end ); 

  path = handles.scan_information.FileList( 1:max( find(handles.scan_information.FileList == dchr ) ) ) ;
  if ispc() 
    fn = handles.scan_information.FileList( max( find(handles.scan_information.FileList == dchr ) ) + 1:end ) ;
  end;
  tmpfile = [path tmpfile];

  fid = fopen( handles.scan_information.FileList, 'r' );
  wfid = fopen( tmpfile, 'w' );

  while ~feof( fid )

    x = fgetl( fid );		  % input a single line of text - remove CRLF pair or single
    if ( length(x) > 8 )
      if ( strcmp( x(1:8), 'subjects' ) )
        x = ['subjects:' num2str(size(subs,1)-1) ];
      end;
    end;

    xx = regexp( x, regex, 'match' );
    if ( ~isempty(xx))
      x = strrep( x, 'sdir:', '#sdir:' );
    end;

    fprintf( wfid, '%s\n', x );		  % input a single line of text - remove CRLF pair or single

  end;

  fclose(fid);
  fclose(wfid);
  
  if ~ispc() 
    eval( ['!mv ' tmpfile ' ' handles.scan_information.FileList ] );
  else
    delete( handles.scan_information.FileList );
    eval( [ '!RENAME "' tmpfile '" ' fn ] );
  end

  lst = [];
  for ii = 1:size(subs,1)
    if ( ~strcmp( char(subs(ii)), sid ) )
      lst = [lst; subs(ii) ];
    end;    
  end;    

  set( handles.chk_verify_all_subjects, 'Value', 1 );
  idx = [1:size(lst, 2)];
  set(handles.lst_subjects,'String', lst, 'Value', idx );

  handles.reparse = 1;			% flag file list requiring reparsing

  % Update handles structure
  guidata(hObject, handles);

