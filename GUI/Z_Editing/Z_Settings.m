function varargout = Z_Settings(varargin)
% --- Z_SETTINGS M-file for Z_Settings.fig
% ---      Z_SETTINGS, by itself, creates a new Z_SETTINGS or raises the existing
% ---      singleton*.
%
% ---      H = Z_SETTINGS returns the handle to a new Z_SETTINGS or the handle to
% ---      the existing singleton*.
%
% ---      Z_SETTINGS('CALLBACK',hObject,eventData,handles,...) calls the local
% ---      function named CALLBACK in Z_SETTINGS.M with the given input arguments.
%
% ---      Z_SETTINGS('Property','Value',...) creates a new Z_SETTINGS or raises the
% ---      existing singleton*.  Starting from the left, property value pairs are
% ---      applied to the GUI before Z_Settings_OpeningFcn gets called.  An
% ---      unrecognized property name or invalid value makes property application
% ---      stop.  All inputs are passed to Z_Settings_OpeningFcn via varargin.
%
% ---      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
% ---      instance to run (singleton)".
%
% --- See also: GUIDE, GUIDATA, GUIHANDLES

% --- Edit the above text to modify the response to help Z_Settings

% --- Last Modified by GUIDE v2.5 19-Jan-2010 09:09:30

% --- Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Z_Settings_OpeningFcn, ...
                   'gui_OutputFcn',  @Z_Settings_OutputFcn, ...
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
% --- End initialization code - DO NOT EDIT


% --- Executes just before Z_Settings is made visible.
function Z_Settings_OpeningFcn(hObject, eventdata, handles, varargin)
% --- This function has no output args, see OutputFcn.
% --- hObject    handle to figure
% --- eventdata  reserved - to be defined in a future version of MATLAB
% --- handles    structure with handles and user data (see GUIDATA)
% --- varargin   command line arguments to Z_Settings (see VARARGIN)
global Zheader

% --- Choose default command line output for Z_Settings
handles.output = hObject;

  str = sprintf( '%d', Zheader.num_subjects );
  set( handles.txt_Subjects, 'String', str );

  str = sprintf( '%d', Zheader.num_runs );
  set( handles.txt_Runs, 'String', str );

  str = sprintf( '%d', Zheader.total_scans );
  set( handles.txt_Scans, 'String', str );

  if ( ~Zheader.MeanCentered ) 	set( handles.chk_Mean_Center, 'Value', 1 ); set( handles.chk_Mean_Center, 'Enable', 'On' ); end;
  if ( ~Zheader.Normalized ) 	set( handles.chk_Standardize, 'Value', 1 ); set( handles.chk_Standardize, 'Enable', 'On' ); end;

  x = Zheader.MeanCentered * Zheader.Normalized;		% --- quick flag to set enabled status of regression buttons
  if (~x)
    set( handles.chk_Linear, 'Value', 1 ); set( handles.chk_Linear, 'Enable', 'On' );
    set( handles.chk_Quadratic, 'Value', 1 ); set( handles.chk_Quadratic, 'Enable', 'On' );
  end;

  if ( ismac )
    set( handles.txt_Subjects, 'HorizontalAlignment', 'center' );
    pos = get(handles.txt_Subjects, 'Position' );
    set( handles.txt_Subjects, 'Position', [pos(1) pos(2) pos(3) 1.75] );

    set( handles.txt_Runs, 'HorizontalAlignment', 'center' );
    pos = get(handles.txt_Runs, 'Position' );
    set( handles.txt_Runs, 'Position', [pos(1) pos(2) pos(3) 1.75] );

    set( handles.txt_Scans, 'HorizontalAlignment', 'center' );
    pos = get(handles.txt_Scans, 'Position' );
    set( handles.txt_Scans, 'Position', [pos(1) pos(2) pos(3) 1.75] );

  end;

  set( handles.btn_Update, 'Enable', 'off' );

  % --- Update handles structure
  guidata(hObject, handles);

  % --- UIWAIT makes Z_Settings wait for user response (see UIRESUME)
  uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Z_Settings_OutputFcn(hObject, eventdata, handles) 
% --- varargout  cell array for returning output args (see VARARGOUT);
% --- hObject    handle to figure
% --- eventdata  reserved - to be defined in a future version of MATLAB
% --- handles    structure with handles and user data (see GUIDATA)

% --- Get default command line output from handles structure
varargout{1} = handles.output;
delete(handles.figure1);



function txt_Subjects_Callback(hObject, eventdata, handles)
% --- hObject    handle to txt_Subjects (see GCBO)
% --- eventdata  reserved - to be defined in a future version of MATLAB
% --- handles    structure with handles and user data (see GUIDATA)

  str = get(hObject,'String');
  str = validate_numeric_entry( str );
  set(hObject,'String', str );


% --- Executes during object creation, after setting all properties.
function txt_Subjects_CreateFcn(hObject, eventdata, handles)
% --- hObject    handle to txt_Subjects (see GCBO)
% --- eventdata  reserved - to be defined in a future version of MATLAB
% --- handles    empty - handles not created until after all CreateFcns called

% --- Hint: edit controls usually have a white background on Windows.
% ---       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_Runs_Callback(hObject, eventdata, handles)
% --- hObject    handle to txt_Runs (see GCBO)
% --- eventdata  reserved - to be defined in a future version of MATLAB
% --- handles    structure with handles and user data (see GUIDATA)

  str = get(hObject,'String');
  str = validate_numeric_entry( str );
  set(hObject,'String', str );


% --- Executes during object creation, after setting all properties.
function txt_Runs_CreateFcn(hObject, eventdata, handles)
% --- hObject    handle to txt_Runs (see GCBO)
% --- eventdata  reserved - to be defined in a future version of MATLAB
% --- handles    empty - handles not created until after all CreateFcns called

% --- Hint: edit controls usually have a white background on Windows.
% ---       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_Scans_Callback(hObject, eventdata, handles)
% --- hObject    handle to txt_Scans (see GCBO)
% --- eventdata  reserved - to be defined in a future version of MATLAB
% --- handles    structure with handles and user data (see GUIDATA)

% --- Hints: get(hObject,'String') returns contents of txt_Scans as text
% ---        str2double(get(hObject,'String')) returns contents of txt_Scans as a double

  str = get(hObject,'String');
  ts = validate_numeric_vector( str );
  set(hObject,'String', ts );

% ---  ts = get(hObject,'String');
  ts = strtrim(ts);
  vec = regexp(ts, ' ', 'split' );

  subj = str2double(get(handles.txt_Subjects,'String'));
  runs = str2double(get(handles.txt_Runs,'String'));

  reqd = subj*runs;
  if ( reqd > 0 )
    [x y] = size(vec);
    if ( y == reqd ) 	set( handles.btn_Update, 'Enable', 'on' );	end;
  end;

% --- Executes during object creation, after setting all properties.
function txt_Scans_CreateFcn(hObject, eventdata, handles)
% --- hObject    handle to txt_Scans (see GCBO)
% --- eventdata  reserved - to be defined in a future version of MATLAB
% --- handles    empty - handles not created until after all CreateFcns called

% --- Hint: edit controls usually have a white background on Windows.
% ---       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- although originally called btn_Okay, this is now the cancel button
% --- the btn_update handles the okay process

% --- Executes on button press in btn_Okay.
function btn_Okay_Callback(hObject, eventdata, handles)
% --- hObject    handle to btn_Okay (see GCBO)
% --- eventdata  reserved - to be defined in a future version of MATLAB
% --- handles    structure with handles and user data (see GUIDATA)
global Zheader scan_information ;

  subj = str2double(get(handles.txt_Subjects,'String'));
  if ( subj > 0 )   Zheader.num_subjects = subj; end;

  runs = str2double(get(handles.txt_Runs,'String'));
  if ( runs > 0 )   Zheader.num_runs = runs; 	end;

  % --------------------------------------------------------
  % --- update header information to avoid having to recalc tsums
  % --------------------------------------------------------
  scan_information.NumSubjects = Zheader.num_subjects; 
  scan_information.NumRuns = Zheader.num_runs;
  scan_information.SubjDir = scan_information.SubjectID';

  if ( length(Zheader.Z_Directory) == 0 )
    Zfile = './ZInfo.mat';
  else
    Zfile = [Zheader.Z_Directory 'ZInfo.mat'];
  end;
  appnd = '';
  x = exist( Zfile );
  if ( x > 0 )
    appnd = '-append';
  end;
% ---  command = ['save ''' Zfile ''' Zheader scan_information' appnd ];
  eval( [ 'save( ''' Zfile ''', ''Zheader'', ''scan_information'', ''' appnd ''' )' ] );

handles.output = '';
% --- Update handles structure
guidata(hObject, handles);
uiresume(handles.figure1);


% --- Executes on button press in btn_Update.
function btn_Update_Callback(hObject, eventdata, handles)
% --- hObject    handle to btn_Update (see GCBO)
% --- eventdata  reserved - to be defined in a future version of MATLAB
% --- handles    structure with handles and user data (see GUIDATA)
global Zheader scan_information ;

  set( handles.btn_Okay, 'Enable', 'off' );

  ts = get(handles.txt_Scans,'String');
  ts = strtrim(ts);
  vec = regexp(ts, ' ', 'split' );

  subj = str2double(get(handles.txt_Subjects,'String'));
  runs = str2double(get(handles.txt_Runs,'String'));
  Zheader.num_subjects = subj;
  Zheader.num_runs = runs;
  mc = get( handles.chk_Mean_Center, 'Value' );
  sd = get( handles.chk_Standardize, 'Value' );
  lr = get( handles.chk_Linear, 'Value' );
  qr = get( handles.chk_Quadratic, 'Value' );

  ftag = '';  
  Zheader.timeseries.subject = [];

  ts_offset = 1;
  iterations = subj * runs;

  MainText = 'Splitting Subject runs to subject files for processing.';
  pb = cpca_progress();
  pb.setWindowTitle( 'Creating Subject Files' );
  thisText = [MainText ' Please wait . . .'];
  pb.setMessage( MainText,  'Setting Vectors', '');
  pb.setIterations( iterations );

  tsum_v = [];
  % --------------------------------------------------------
  % --- set time series vectors
  % --------------------------------------------------------
  for SubjectNo=1:subj

    run = [];

    for RunNo = 1:runs
      ii = ( (SubjectNo - 1) * runs ) + RunNo;

      r = str2double(char(vec( ii ) ) );
      run = vertcat( run, [r max(1, ts_offset)]);     
      ts_offset = ts_offset + r;


      if SubjectNo == 1 & RunNo == 1   % --- this is where katies 335 min went missing (run2 subj 1 was 340 )
        Zheader.min_scans = r;
        Zheader.max_scans = r;
      else
        Zheader.min_scans = min( Zheader.min_scans, r );
        Zheader.max_scans = max( Zheader.max_scans, r );
      end;

    end;  % --- each Run

    subject = struct( 'run', [] );
    subject.run  = run;

    Zheader.timeseries.subject = vertcat(Zheader.timeseries.subject, subject);

  end;  % --- each Subject


  [x y] = size(Zheader.timeseries.subject);
  if ( x == Zheader.num_subjects )

    % --------------------------------------------------------
    % --- load up the Z matrix and split into subject files for processing
    % --------------------------------------------------------
    pb.setMessage( MainText,  'Loading Z Matrix', '');

    ZMatrix = Zheader.Z_File.variable.name;
    eval( [ 'load( ''' Zheader.Z_File.directory Zheader.Z_File.name ''', ''' ZMatrix ''') ' ] );


    Zheader.tsum = 0;
    Zheader.tsum_trends = 0;
    Zheader.tsum_with_trends = 0;

    x = exist( 'Z', 'dir' );
    if ( x ~= 7 )  % the directory does not exist
      mkdir Z;
    end;

    scan_information.SubjectID = [];

    for SubjectNo=1:Zheader.num_subjects

      sid = subject_id( SubjectNo );
      pb.setParticipant( SubjectNo, Zheader.num_subjects, sid );

      tsum_subject = 0;			% --- tsum for each subject
      tsum_removed = 0;			% --- tsum regressed out for each subject

      thisSubj = ['Z' filesep 'Z' num2str(SubjectNo)];
      thisSubjID = sprintf( 's%02d', SubjectNo );
      scan_information.SubjectID = [scan_information.SubjectID {thisSubjID}];

      ver = Zheader.header_version;
      eval ( ['save ' thisSubj ' ver;' ] );

      beta = [];
      for RunNo = 1:Zheader.num_runs

        pb.setRun( RunNo, Zheader.num_runs );
    	pb.increment();

        thisRun = sprintf( 'Z%d', RunNo );

        start = Zheader.timeseries.subject(SubjectNo).run(RunNo, 2);
        segend = start - 1 + Zheader.timeseries.subject(SubjectNo).run(RunNo, 1);
        ts =   Zheader.timeseries.subject(SubjectNo).run(RunNo, 1) ;    
        command = sprintf( '%s = %s(%d:%d,:);', thisRun, ZMatrix, start , segend );
        eval( command );


        if ( lr | qr )
          %------------------------------------------------
          % --- mean center calculations
          %------------------------------------------------

          eval( ['column_mean = mean( ' thisRun ' );'] );
          SoS=zeros(1, Zheader.total_columns );

          pb.setMessage( MainText,  'Calculating Mean. . .', '');
          bar_max = ts * 2;
          for ii = 1:ts
            eval( [ thisRun '(' num2str(ii) ',:)=(' thisRun '(' num2str(ii) ',:)-column_mean(1,:));' ] );
            pb.increment();
          end;

          eval( ['SD = samp_dev( ' thisRun ' );'] );
          pb.setMessage( MainText,  'Standardizing. . .', '');
          for ii = 1:ts
            % ---   Z1(ii,:) = Z1(ii,:) ./ SD(1,:);   --- %
            eval( [ thisRun '(' num2str(ii) ',:)=(' thisRun '(' num2str(ii) ',:)./SD(1,:));' ] );
            pb.increment();

          end;

          pb.setMessage( MainText,  'Calculating Sum of Squares. . .', '');
          
          for jj=1:Zheader.total_columns
              
            eval( [ 'tsum_v = ' thisRun '(:,' num2str(jj) ')'' * ' thisRun '(:,' num2str(jj) ');' ] );
            Zheader.tsum_with_trends = Zheader.tsum_with_trends + tsum_v;

            pb.increment();
          end

          pb.setMessage( MainText,  'Removing Trends. . .', '');

          X = [];
          C = [];
          linear = [];
          quadratic = [];
          G = [];

          %------------------------------------------------
          % --- remove Linear trends and preserve percentage
          %------------------------------------------------
          X = [];
          C = [];
          bar_max = (Zheader.total_columns * lr) + (Zheader.total_columns * qr) ;
          pct_count = 0;
          voxels = Zheader.total_columns;

          if ( lr )
            linear = [1:ts]';
            linear = linear - ones(ts,1) * mean(linear);

            pb.setMessage( MainText,  'Removing Trends. . .', 'Linear Regression' );

            X = blkdiag(X,linear);
            C = blkdiag(C,ones(Zheader.timeseries.subject(SubjectNo).run(RunNo,1),1));
            AX = [X C];
            eval( ['beta = pinv(AX)*Z' num2str(RunNo) ftag ';' ] );
            Z_Linear_Trends = X*beta(1:size(X,2),:);

            for jj=1:voxels
              tsum_v = (Z_Linear_Trends(:,jj)' * Z_Linear_Trends(:,jj) );
              Zheader.tsum_linear_trends = Zheader.tsum_linear_trends + tsum_v;
              tsum_removed = tsum_removed + tsum_v;
              Zheader.tsum_trends = Zheader.tsum_trends + tsum_v;

%              if isfield( scan_information, 'GroupList' ) 
%                if ( size( scan_information.GroupList,1) > 0 );
%                  for ( ii = 1:size( scan_information.GroupList,1) )
%                    x = find( str2num(scan_information.GroupList(ii).subjectlist ) == SubjectNo );
%                    if ~isempty(x)
%                      scan_information.GroupList(ii).tsum_linear_removed = scan_information.GroupList(ii).tsum_linear_removed + tsum_v;
%                    end;
%                  end;
%                end;
%              end;

              pb.increment();

            end

            eval ( [ 'Z' num2str(RunNo) ftag ' = Z' num2str(RunNo) ftag ' - Z_Linear_Trends; '; ] );

            clear Z_Linear_Trends
            pct_count = pct_count + 1;
          end;


          X = [];
          C = [];

          %------------------------------------------------
          % --- remove Quadratic trends and preserve percentage
          %------------------------------------------------
          if ( qr )

            quadratic = linear.^2;
            quadratic = quadratic - ones(ts,1) * mean(quadratic);

            pb.setMessage( MainText,  'Removing Trends. . .', 'Quadratic Regression' );

            X = blkdiag(X,quadratic);
            C = blkdiag(C,ones(Zheader.timeseries.subject(SubjectNo).run(RunNo,1),1));
            AX = [X C];
            eval( ['beta = pinv(AX)*Z' num2str(RunNo) ftag ';' ] );
            Z_quadratic_Trends = X*beta(1:size(X,2),:);

            for jj=1:voxels
              tsum_v = (Z_quadratic_Trends(:,jj)' * Z_quadratic_Trends(:,jj) );
              Zheader.tsum_quadratic_trends = Zheader.tsum_quadratic_trends + tsum_v;
              tsum_removed = tsum_removed + tsum_v;
              Zheader.tsum_trends = Zheader.tsum_trends + tsum_v;

%              if isfield( scan_information, 'GroupList' ) 
%                if ( size( scan_information.GroupList,1) > 0 );
%                  for ( ii = 1:size( scan_information.GroupList,1) )
%                    x = find( str2num(scan_information.GroupList(ii).subjectlist ) == SubjectNo );
%                    if ~isempty(x)
%                      scan_information.GroupList(ii).tsum_quadratic_removed = scan_information.GroupList(ii).tsum_quadratic_removed + tsum_v;
%                    end;
%                  end;
%                end;
%              end;

              pb.increment();

            end

            eval ( [ 'Z' num2str(RunNo) ftag ' = Z' num2str(RunNo) ftag ' - Z_quadratic_Trends; '; ] );
            clear Z_quadratic_Trends
            pct_count = pct_count + 1;

          end;

        end;  % --- perform regression


        %------------------------------------------------
        % --- mean center calculations
        %------------------------------------------------

        if ( mc )
          eval( ['column_mean = mean( ' thisRun ' );'] );

          SoS=zeros(1, Zheader.total_columns );

          pb.setMessage( MainText,  'Calculating Mean. . .', '' );

          for ii = 1:ts
            % --- mean center the segment data if requested
            %------------------------------------------------
             eval( [ thisRun '(' num2str(ii) ',:)=(' thisRun '(' num2str(ii) ',:)-column_mean(1,:));' ] );
          end;
        end;
 
        if ( sd )
          eval( ['SD = samp_dev( ' thisRun ' );'] );
          for ii = 1:ts
            % ---   Z1(ii,:) = Z1(ii,:) ./ SD(1,:);   --- %
            eval( [ thisRun '(' num2str(ii) ',:)=(' thisRun '(' num2str(ii) ',:)./SD(1,:));' ] );
          end;

        end;
	  
        command = sprintf( 'sm=%s(%d,:).*%s(%d,:);', thisRun, ii, thisRun, ii );
        eval(command);

        command = sprintf( 'SoS(1,:)=SoS(1,:)+sm(1,:);' );
        eval(command);


        appnd = '';
        if ( RunNo > 1 )   appnd = '-append';	end;
  
        start_col = 1;
        for column = 1:size( Zheader.partitions.columns,2)
          end_col = start_col + Zheader.partitions.columns(column) - 1;
          eval ( ['Z_R' num2str(RunNo) '_C' num2str(column) ' = ' thisRun '(:,' num2str(start_col) ':' num2str(end_col) ' );'; ] );
          eval ( [ 'save ' thisSubj ' Z_R' num2str(RunNo) '_C' num2str(column) ' -append '] );
          start_col = end_col+1;
          eval ( ['clear Z_R' num2str(RunNo) '_C' num2str(column) ] );
        end;

        eval( ['save ' thisSubj ' tsum_subject tsum_removed -append' ] );

        if ( strcmp(ZMatrix, thisRun ) )
          % --------------------------------------------------------
          % --- Zn = Zn(x,y) call - reload Z matrix
          % --------------------------------------------------------
          eval( [ 'load( ''' Zheader.Z_File.directory Zheader.Z_File.name ''', ''' ZMatrix ''' )' ] );
        end;
	  
      end; % --- each run
         
      %------------------------------------------------
      % --- calculate total sums of squares
      %------------------------------------------------

      pb.setMessage( MainText,  'Calculating Sum of Squares. . .', '' );

      for jj=1:Zheader.total_columns
        command=sprintf('tsum_v = ( %s(:,%d)''*%s(:,%d) );', thisRun, jj, thisRun, jj );
        eval(command);

        tsum_subject = tsum_subject + tsum_v;
        Zheader.tsum = Zheader.tsum + tsum_v;

      end;


    end;  % --- each subject

    Zheader.older_Z = 0;
    x = [pwd filesep];
    Zheader.Z_Directory = x;

  end;

  % --------------------------------------------------------
  % --- update header information to avoid having to recalc tsums
  % --------------------------------------------------------
  scan_information.NumSubjects = Zheader.num_subjects; 
  scan_information.NumRuns = Zheader.num_runs;
  scan_information.processing.subjects.normalized = date;
  scan_information.SubjDir = scan_information.SubjectID';

  if ( mc ) Zheader.MeanCentered = 1; end;
  if ( sd ) Zheader.Normalized = 1; end;

  if ( length(Zheader.Z_Directory) == 0 )
    Zfile = './ZInfo.mat';
  else
    Zfile = [Zheader.Z_Directory 'ZInfo.mat'];
  end;
  appnd = '';
  x = exist( Zfile );
  if ( x > 0 )
    appnd = '-append';
  end;
  eval(['save( ''' Zfile ''', ''Zheader'', ''scan_information'', ''' appnd ''' )' ]);

  pb.hide();
  clear pb;
 
handles.output = 'Done';
% --- Update handles structure
guidata(hObject, handles);

uiresume(handles.figure1);


% --- Executes on button press in btn_Estimate.
function btn_Estimate_Callback(hObject, eventdata, handles)
% --- hObject    handle to btn_Estimate (see GCBO)
% --- eventdata  reserved - to be defined in a future version of MATLAB
% --- handles    structure with handles and user data (see GUIDATA)
global Zheader;

  s = str2double(get(handles.txt_Subjects,'String'));
  r = str2double(get(handles.txt_Runs,'String'));

  if ( s > 0 & r > 0 )
    str = '';
    ts_scans = floor(Zheader.total_scans/(s*r));
    ts_remain = mod(Zheader.total_scans, ts_scans);
    for ( ii = 1:(s*r))  
      ts = ts_scans; 
      if (ii == (s*r) ) 
        ts = ts + ts_remain; 
      end; 
      str = [str ' ' num2str(ts)];
    end;

    set( handles.txt_Scans, 'String', str );
    set( handles.btn_Update, 'Enable', 'on' );

  end;


% --- Executes on button press in chk_Mean_Center.
function chk_Mean_Center_Callback(hObject, eventdata, handles)
% --- hObject    handle to chk_Mean_Center (see GCBO)
% --- eventdata  reserved - to be defined in a future version of MATLAB
% --- handles    structure with handles and user data (see GUIDATA)

% --- Hint: get(hObject,'Value') returns toggle state of chk_Mean_Center


% --- Executes on button press in chk_Standardize.
function chk_Standardize_Callback(hObject, eventdata, handles)
% --- hObject    handle to chk_Standardize (see GCBO)
% --- eventdata  reserved - to be defined in a future version of MATLAB
% --- handles    structure with handles and user data (see GUIDATA)

% --- Hint: get(hObject,'Value') returns toggle state of chk_Standardize


% --- Executes on button press in chk_Linear.
function chk_Linear_Callback(hObject, eventdata, handles)
% --- hObject    handle to chk_Linear (see GCBO)
% --- eventdata  reserved - to be defined in a future version of MATLAB
% --- handles    structure with handles and user data (see GUIDATA)

% --- Hint: get(hObject,'Value') returns toggle state of chk_Linear
  state = get(hObject,'Value');
  if ( state == 0 )
    set( handles.chk_Quadratic, 'Value', 0 ); set( handles.chk_Quadratic, 'Enable', 'Off' );
  else
    set( handles.chk_Quadratic, 'Enable', 'On' );
  end;

% --- Executes on button press in chk_Quadratic.
function chk_Quadratic_Callback(hObject, eventdata, handles)
% --- hObject    handle to chk_Quadratic (see GCBO)
% --- eventdata  reserved - to be defined in a future version of MATLAB
% --- handles    structure with handles and user data (see GUIDATA)

% --- Hint: get(hObject,'Value') returns toggle state of chk_Quadratic


