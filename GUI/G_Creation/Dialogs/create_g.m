function varargout = create_g(varargin)
% --- input form for creation of a G Matrix for applying to normalized subject data
% --- 
% --- usage requires user to supply a timing vector file, contents of the form
% ---  subjID~runID~componentName = [ timing onsets . . .];
% --- 
% --- it is best if the SubjID and runID equate to subject and run folder names
% --- for example:  C01_run1
% --- 
% --- the runID component is optional
% --- 

% --- Edit the above text to modify the response to help create_g

% --- Last Modified by GUIDE v2.5 17-Jul-2013 09:21:57

% --- Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @create_g_OpeningFcn, ...
                   'gui_OutputFcn',  @create_g_OutputFcn, ...
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
end


% --- Executes just before create_g is made visible.
function create_g_OpeningFcn(hObject, eventdata, handles, varargin)
% --- This function has no output args, see OutputFcn.
% --- hObject    handle to figure
% --- eventdata  reserved - to be defined in a future version of MATLAB
% --- handles    structure with handles and user data (see GUIDATA)
% --- varargin   command line arguments to create_g (see VARARGIN)

global Zheader scan_information 

  Gheader = structure_define( 'GHEADER' );

  if(nargin > 3)
    for index = 1:2:(nargin-3),
      if nargin-3==index, break, end
        switch lower(varargin{index})
         case 'header'
          hdr = varargin{index+1};
          Gheader = adjust_gheader( hdr );
      end
    end
  end

  % --- Choose default command line output for create_g
  handles.output.gh = Gheader;
  handles.Zheader = Zheader;
  handles.scan_information = scan_information;
  handles.last_entered_timebins = 0;
  handles.imported_from = '';
  handles.normalize_me = 1;

  set ( handles.chk_normalize, 'Value', handles.normalize_me );
  set ( handles.chk_normalize, 'Visible', 'on' );

  set( hObject, 'Name', 'G Matrix Creation' );
  set ( handles.btn_Scans, 'Value', 1 );
  set ( handles.btn_Seconds, 'Value', 0 );
  set ( handles.txt_timingRate, 'String', '1' );

  if ( ismac )
    set( handles.txt_timingRate, 'HorizontalAlignment', 'center' );
    pos = get(handles.txt_timingRate, 'Position' );
    set( handles.txt_timingRate, 'Position', [pos(1) pos(2) pos(3) 1.75] );

    set( handles.txt_timeBins, 'HorizontalAlignment', 'center' );
    pos = get(handles.txt_timeBins, 'Position' );
    set( handles.txt_timeBins, 'Position', [pos(1) pos(2) pos(3) 1.75] );

  end;

  set ( handles.btn_FIR, 'Value', handles.output.gh.model_type == constant_define( 'FIR_MODEL' ) );
  set ( handles.btn_HRF, 'Value', handles.output.gh.model_type == constant_define( 'HRF_MODEL' ) );
  
  if ( handles.output.gh.model_type == constant_define( 'FIR_MODEL' ) )
    set ( handles.txt_timeBins, 'Enable', 'on' );
  else
    set ( handles.txt_timeBins, 'Enable', 'off' );
    set ( handles.txt_timeBins, 'String', '1' );
  end;

  set( handles.lst_subjects, 'String', handles.scan_information.SubjectID', 'Value', 1 );

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
  
  set( handles.lst_runs, 'String', str, 'Value', 1 );

  if ( size(handles.Zheader.conditions.subject,1) > 0 )
    set( handles.lst_conditionNames, 'String', handles.Zheader.conditions.Names', 'Value', handles.Zheader.conditions.subject(1).Run(1).conditions );
  end;

  handles.lin = '% ------------------------------------------------------';
  handles.hdr = '%s\n%% --- NOTE: The sequence of timing onset definitions is critical.\n%% --- All timing onsets must be prepared in the order displayed in this this file.\n%% --- Timing onsets may be inserted directly into this file, or imported from a separate text file\n%% --- All timing onsets imported from a separate text file must be prepared in the order displayed below\n%% --- Any onset condition names in an imported text file WILL BE IGNORED and those listed below will be used, in the order listed below\n%s\n\n';


  % --- Update handles structure
  guidata(hObject, handles);

  create_button_state( handles );

  % --- UIWAIT makes create_g wait for user response (see UIRESUME)
  uiwait(handles.figure1);
end


% --- Outputs from this function are returned to the command line.
function varargout = create_g_OutputFcn(hObject, eventdata, handles) 
% --- varargout  cell array for returning output args (see VARARGOUT);
% --- hObject    handle to figure
% --- eventdata  reserved - to be defined in a future version of MATLAB
% --- handles    structure with handles and user data (see GUIDATA)

% --- Get default command line output from handles structure
varargout{1} = handles.output.gh;
varargout{2} = handles.conditions;
delete(handles.figure1);
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% --- hObject    handle to figure1 (see GCBO)
% --- eventdata  reserved - to be defined in a future version of MATLAB
% --- handles    structure with handles and user data (see GUIDATA)

  handles.output.gh = '';
  handles.conditions = [];
  guidata(handles.figure1, handles);
  uiresume(handles.figure1);
end



% --- Executes during object creation, after setting all properties.
function txt_timingRate_CreateFcn(hObject, eventdata, handles)
% --- hObject    handle to txt_timingRate (see GCBO)
% --- eventdata  reserved - to be defined in a future version of MATLAB
% --- handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on key press with focus on txt_timingRate and none of its controls.
function txt_timingRate_KeyPressFcn(hObject, eventdata, handles)
% --- hObject    handle to txt_timingRate (see GCBO)
% --- eventdata  structure with the following fields (see UICONTROL)
% --- 	Key: name of the key that was pressed, in lower case
% --- 	Character: character interpretation of the key(s) that was pressed
% --- 	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% --- handles    structure with handles and user data (see GUIDATA)

  txt_timingRate_Callback(hObject, 0, handles);
end



function txt_timingRate_Callback(hObject, eventdata, handles)
% --- hObject    handle to txt_timingRate (see GCBO)
% --- eventdata  reserved - to be defined in a future version of MATLAB
% --- handles    structure with handles and user data (see GUIDATA)

  str = get(hObject,'String');
  str = validate_numeric_entry( str );
  set(hObject,'String', str );

  create_button_state( handles );
end



% --- Executes during object creation, after setting all properties.
function txt_timeBins_CreateFcn(hObject, eventdata, handles)
% --- hObject    handle to txt_timeBins (see GCBO)
% --- eventdata  reserved - to be defined in a future version of MATLAB
% --- handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on key press with focus on txt_timeBins and none of its controls.
function txt_timeBins_KeyPressFcn(hObject, eventdata, handles)
% --- hObject    handle to txt_timeBins (see GCBO)
% --- eventdata  structure with the following fields (see UICONTROL)
% --- 	Key: name of the key that was pressed, in lower case
% --- 	Character: character interpretation of the key(s) that was pressed
% --- 	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% --- handles    structure with handles and user data (see GUIDATA)
end


function txt_timeBins_Callback(hObject, eventdata, handles)
% --- hObject    handle to txt_timeBins (see GCBO)
% --- eventdata  reserved - to be defined in a future version of MATLAB
% --- handles    structure with handles and user data (see GUIDATA)

  str = get(hObject,'String');
  str = validate_numeric_entry( str );
  set(hObject,'String', str );
  create_button_state( handles );

  handles.last_entered_timebins = str2num( str );
  guidata(handles.figure1, handles);
end



% --- Executes on button press in btn_Seconds.
function btn_Seconds_Callback(hObject, eventdata, handles)
% --- hObject    handle to btn_Seconds (see GCBO)
% --- eventdata  reserved - to be defined in a future version of MATLAB
% --- handles    structure with handles and user data (see GUIDATA)

 this_btn = get(hObject,'Value'); % --- returns toggle state of btn_HRF
 if ( this_btn == 1 )
   set ( handles.btn_Scans, 'Value', 0 );
   state = 'on';   
 else
   set ( handles.btn_Scans, 'Value', 1 );
   state = 'on';   
 end;

 set ( handles.lbl_timingRate, 'Visible', state );
 set ( handles.txt_timingRate, 'Visible', state );
 create_button_state( handles );
end


% --- Executes on button press in btn_Scans.
function btn_Scans_Callback(hObject, eventdata, handles)
% --- hObject    handle to btn_Scans (see GCBO)
% --- eventdata  reserved - to be defined in a future version of MATLAB
% --- handles    structure with handles and user data (see GUIDATA)

 this_btn = get(hObject,'Value'); % --- returns toggle state of btn_HRF
 if ( this_btn == 1 )
   set ( handles.btn_Seconds, 'Value', 0 );
   state = 'on';   
 else
   set ( handles.btn_Seconds, 'Value', 1 );
   state = 'on';   
 end;
 set ( handles.lbl_timingRate, 'Visible', state );
 set ( handles.txt_timingRate, 'Visible', state );
 create_button_state( handles );
end


% --- Executes on button press in btn_HRF.
function btn_HRF_Callback(hObject, eventdata, handles)
% --- hObject    handle to btn_HRF (see GCBO)
% --- eventdata  reserved - to be defined in a future version of MATLAB
% --- handles    structure with handles and user data (see GUIDATA)
 


  handles.output.gh.model_type = get(handles.btn_HRF,'Value'); % --- returns toggle state of btn_HRF
  guidata(handles.figure1, handles);

  if ~( handles.output.gh.model_type == constant_define( 'FIR_MODEL' ) )
   set ( handles.btn_FIR, 'Value', 0 );
   set ( handles.txt_timeBins, 'String', '1' );
   set ( handles.txt_timeBins, 'Enable', 'off' );
 else
   set ( handles.btn_FIR, 'Value', 1 );
   set ( handles.txt_timeBins, 'String', num2str(handles.last_entered_timebins) );
   set ( handles.txt_timeBins, 'Enable', 'on' );
 end;
end


% --- Executes on button press in btn_fir.
function btn_FIR_Callback(hObject, eventdata, handles)
% --- hObject    handle to btn_fir (see GCBO)
% --- eventdata  reserved - to be defined in a future version of MATLAB
% --- handles    structure with handles and user data (see GUIDATA)

  handles.output.gh.model_type = get(handles.btn_HRF,'Value'); % --- returns toggle state of btn_HRF
  guidata(handles.figure1, handles);

  if ~( handles.output.gh.model_type == constant_define( 'FIR_MODEL' ) )
    set ( handles.btn_HRF, 'Value', 0 );
    set ( handles.txt_timeBins, 'String', num2str(handles.last_entered_timebins) );
    set ( handles.txt_timeBins, 'Enable', 'on' );
  else
    set ( handles.btn_HRF, 'Value', 1 );
    set ( handles.txt_timeBins, 'String', '1' );
    set ( handles.txt_timeBins, 'Enable', 'off' );
  end;
end




% --- Executes on selection change in lst_subjects.
function lst_subjects_Callback(hObject, eventdata, handles)
% --- hObject    handle to lst_subjects (see GCBO)
% --- eventdata  reserved - to be defined in a future version of MATLAB
% --- handles    structure with handles and user data (see GUIDATA)

  % --- If double click
%   if strcmp(get(handles.figure1,'SelectionType'),'open')
%     btn_selectSubject_Callback( hObject, 0, handles );
%   end;
end


% --- Executes during object creation, after setting all properties.
function lst_subjects_CreateFcn(hObject, eventdata, handles)
% --- hObject    handle to lst_subjects (see GCBO)
% --- eventdata  reserved - to be defined in a future version of MATLAB
% --- handles    empty - handles not created until after all CreateFcns called
  
% --- Hint: listbox controls usually have a white background on Windows.
% ---      See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



% --- Executes on selection change in lst_conditionNames.
function lst_conditionNames_Callback(hObject, eventdata, handles)
% --- hObject    handle to lst_conditionNames (see GCBO)
% --- eventdata  reserved - to be defined in a future version of MATLAB
% --- handles    structure with handles and user data (see GUIDATA)

  % --- If double click
%   if strcmp(get(handles.figure1,'SelectionType'),'open')
%     btn_selectCondition_Callback( hObject, 0, handles );
%   end;
end


% --- Executes during object creation, after setting all properties.
function lst_conditionNames_CreateFcn(hObject, eventdata, handles)
% --- hObject    handle to lst_conditionNames (see GCBO)
% --- eventdata  reserved - to be defined in a future version of MATLAB
% --- handles    empty - handles not created until after all CreateFcns called

% --- Hint: listbox controls usually have a white background on Windows.
% ---      See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on button press in btn_getFileList.
function btn_getFileList_Callback(hObject, eventdata, handles)
% --- hObject    handle to btn_getFileList (see GCBO)
% --- eventdata  reserved - to be defined in a future version of MATLAB
% --- handles    structure with handles and user data (see GUIDATA)

  handles.conditions = handles.Zheader.conditions;
  guidata(handles.figure1, handles);
  handles.output.gh = get_G_settings( handles );

  x = get( handles.chk_use_source_onsets, 'Value' );
  if x
    for SubjectNo = 1:handles.Zheader.num_subjects
      [fl imp] = import_subject_run_onsets( handles, handles.output.gh.conditions,SubjectNo );
    end;
  
  else
    [fl imp] = import_onsets_list( handles, handles.output.gh.conditions );
  end;
  
  
  create_button_state( handles );
  if ( length( fl ) > 0 )
      handles.imported_from = imp;
      guidata(handles.figure1, handles);
      eval( [ 'edit ''' fl ''';' ] );
  end
end


function create_button_state( handles )
global Zheader scan_information

  bins = str2double(get(handles.txt_timeBins,'String'));
  ignoreTR = get(handles.btn_Scans,'Value') ;
  tr = str2double(get(handles.txt_timingRate,'String')) ;

  state = 'off';

  if size( handles.Zheader.conditions.Names, 2 ) > 0 

    state = 'off';
      
    fid = fopen( constant_define( 'G_TEMPLATE_NAME'), 'r' );
    if ( fid > 0 )
      [timings good] = next_entry( fid );
      if ( good )
        state = 'on';
      end;
      fclose ( fid );
    end;

    set( handles.btn_getFileList, 'Visible', state );
    
    if scan_information.processing.subjects.tt_count == Zheader.active_runs
      set( handles.chk_use_source_onsets, 'Visible', state );
    end      
    
    if ( strcmp( state, 'on' ) )

      fid = fopen( constant_define( 'G_IMPORT_NAME' ), 'r' );
      if ( fid > 0 )
        timings = next_entry( fid );
        if ( length( timings) > 0 )
          state = 'on';
        else
          state = 'off';
        end;
        fclose ( fid );
      else
        state = 'off';
      end;

    else
      set( handles.btn_getFileList, 'Visible', 'off' );
      state = 'off';
    end;

  end;

  
  if ( strcmp( state, 'on' ) )

    if ~( bins > 0 & ( tr > 0 | ignoreTR > 0 ))
      state = 'off';
    end;

  end;


  set( handles.btn_okay, 'Enable', state) ;

  drawnow();
end




% --- Executes on button press in btn_cancel.
function btn_cancel_Callback(hObject, eventdata, handles)
% --- hObject    handle to btn_cancel (see GCBO)
% --- eventdata  reserved - to be defined in a future version of MATLAB
% --- handles    structure with handles and user data (see GUIDATA)
  handles.output.gh = '';
  handles.conditions = [];
  guidata(handles.figure1, handles);
  uiresume(handles.figure1);
end


% --- Executes on button press in btn_okay.
function btn_okay_Callback(hObject, eventdata, handles)
% --- hObject    handle to btn_okay (see GCBO)
% --- eventdata  reserved - to be defined in a future version of MATLAB
% --- handles    structure with handles and user data (see GUIDATA)

% --- set( hObject, 'Enable', 'off') ;	% --- avoid users pressing twice when lagging
% --- drawnow();
  pop = cpca_progress();
  if ( strcmp( class(pop), 'cpca_progress' ) )
    pop.unsetHRFMAX();
    pop.setWindowTitle( 'Creating G . . .' );
    pop.setIterations( 100, pop.PRIMARY );
    pop.setIterations( 100, pop.SECONDARY );
    pop.setMessages( '', '','' );
    pop.setPong( 0 );
    pop.clearParticipant();
    pop.clearRun();
    pop.show();
  end
  
  % --------------------------------
  % --- Number of conditions
  % --------------------------------
  handles.output.gh.conditions = size(handles.Zheader.conditions.Names, 2 );

  % --------------------------------
  % --- Number of timebins
  % --------------------------------
  handles.output.gh.bins = str2double(get(handles.txt_timeBins,'String')); 

  % --------------------------------
  % --- Timing Rate  
  % --------------------------------
  handles.output.gh.TR = str2double(get(handles.txt_timingRate,'String')); 
  onsvec = [];

  % --------------------------------
  % --- Timing in Seconds or Scans
  % --------------------------------
  handles.output.gh.inScans = get(handles.btn_Scans,'Value'); 
  handles.output.gh.model_type = get(handles.btn_HRF,'Value'); 

  handles.output.gh.condition_name = handles.Zheader.conditions.Names ;
  handles.output.gh.Import_File = handles.imported_from;
  handles.output.gh.source = handles.imported_from;

  % --------------------------------
  % --- path to segmented output
  % --------------------------------
  handles.output.gh.path_to_segs = [ pwd filesep 'Gsegs' filesep];

  duration = handles.output.gh.bins * handles.output.gh.TR;

  pMessage( 'Condition Encoding . . .', pop );
  
  handles.output.gh.subject_encoded = [];
  if ( size(handles.Zheader.conditions.encoded,1) > 0 )
    for ii = 1:size(handles.Zheader.conditions.encoded,1)
      handles.output.gh.subject_encoded = [handles.output.gh.subject_encoded sum( handles.Zheader.conditions.encoded(ii).condition ) ];
    end;
  end;

  handles.conditions = handles.Zheader.conditions;

  pMessage( '', pop );

  TR = 1;
  if( ~handles.output.gh.inScans ) 
    TR = handles.output.gh.TR;
  end;


  % --- Update handles structure
  guidata(hObject, handles);


  sid = get( handles.lst_subjects, 'String') ;

  flags = eye( handles.output.gh.bins, handles.output.gh.bins );	% --- our inset is a (n,n) diagonal
  wdth = handles.output.gh.bins*handles.output.gh.conditions;
  
  x = exist( 'Gsegs', 'dir' )
  if ( x ~= 7 )  % --- the directory does not exist
    mkdir Gsegs;
  end;

  gsWidth = handles.output.gh.bins * handles.output.gh.conditions;

  fid = fopen ( constant_define( 'G_IMPORT_NAME'), 'r' );  % --= 

  all_onsets = [];

  if ( fid ) 

    pMessage( 'Processing Event Onsets . . .', pop );
       
    num_overrun = 0;
    max_overrun = 0;
    invalid_start_point = 0;

    grank = fopen( ['Gsegs' filesep 'G_Ranking.txt'], 'w' );
    fprintf( grank, 'Expected subject G rank: %d\n\n', gsWidth );

    subRank = [];
    % --= 
    % --= for each subject
    for  SubjectNo = 1:handles.Zheader.num_subjects;

      sid = subject_id( SubjectNo );
      if ( strcmp( class(pop), 'cpca_progress' ) )
        pop.setParticipant( SubjectNo, handles.Zheader.num_subjects, sid  );
      end
        
      gsw = sum( handles.Zheader.conditions.encoded(SubjectNo).condition );

%      handles.output.gh.subject_encoded = [handles.output.gh.subject_encoded gsw];
      gsWidth = gsw * handles.output.gh.bins;

      Gnorm = [];
      initialize_mat_file( ['Gsegs' filesep 'G_S' num2str(SubjectNo) '.mat'] );  
      eval( [ 'save( ''Gsegs' filesep 'G_S' num2str(SubjectNo) '.mat'', ''Gnorm'', ''-append'', ''-v7.3'' )'] );

      Rstart = 0;  % --=

      set( handles.lst_subjects, 'Value', SubjectNo ) ;
      drawnow();

      % ------------------------------------------------------
      % --- produce the full subject G for all subject runs
      % --=   Graw = zeros( numscans_thisrun, gsWidth);
      % ------------------------------------------------------
      GG = zeros( gsWidth );
      Graw = [];

      % --= 
      % --=   for each run
%      for RunNo = 1:size( handles.Zheader.timeseries.subject(SubjectNo).run , 1 )
      for RunNo = 1:handles.Zheader.num_runs

        var = ['Gr' num2str(RunNo) ];
        evalin( 'base', [ var ' = [];'] );
          
        if ( strcmp( class(pop), 'cpca_progress' ) )
          pop.setRun( RunNo, handles.Zheader.num_runs  );
        end
          
        if iscellstr( handles.scan_information.SubjDir(SubjectNo, RunNo ) )
          % --=     Rstart = ( numscans_thisrun ) * ( RunNo - 1 );
          % --= 
          if ( handles.output.gh.model_type == constant_define( 'FIR_MODEL') )
            eval( ['Gr' num2str(RunNo) ' = zeros( handles.Zheader.timeseries.subject(SubjectNo).run(RunNo,1),' num2str(gsWidth) ');'] );
%          end;
          else
            eval( ['Gr' num2str(RunNo) ' = [];'] );
          end;

          set( handles.lst_runs, 'Value', RunNo ) ;

          cond = 0;
 
          for condno = 1:handles.output.gh.conditions

            if ( handles.Zheader.conditions.encoded(SubjectNo).condition(condno) )

              cond = cond + 1;
              
              if any( handles.Zheader.conditions.subject(SubjectNo).Run(RunNo).conditions == condno )

                pComment( ['condition ' num2str(condno) ': ' char(handles.Zheader.conditions.Names(condno)) ], pop );
                  
                % --=  % read the next timing onsets line from input file
                % --= 
                timings = next_entry( fid ); % --= 
                if ( length(timings) > 0 ) % --= 
                  onsets = [];
                  eval( [ 'onsets = [' timings '];' ] ); % --= 
                  for ii = 1:size(onsets, 2 )
                    onsvec = [onsvec onsets(ii) - floor(onsets(ii) )];
                  end;

                  % no NOT!! divide HRF model by TR - that is done in algorithm called later
                  if( ~handles.output.gh.inScans & handles.output.gh.model_type == constant_define( 'FIR_MODEL') ) 
                     onsets = onsets / TR;
                     scan_hrf_offset = handles.output.gh.displacement;   % seek HRF shape at n.n seconds after event
                  else
                     scan_hrf_offset = handles.output.gh.displacement/handles.output.gh.TR;   % seek HRF shape at n.n seconds after event
                  end;

                  if ( handles.output.gh.model_type == constant_define( 'FIR_MODEL') )

                    scan0 = sort(floor(onsets)); 		% --=   absolute scan 0 of event
                    onsets = scan0 + 1; 				% --=   always start at scan after event - TODO  add adjust from scan0 by 1 and 2

                    [x y] = size(onsets);		% --=

                    cstart = ( (cond - 1) * handles.output.gh.bins ) + 1;
                    cend = cstart + handles.output.gh.bins - 1;
                    flagdepth = handles.output.gh.bins;

                    for ii = 1:y  % --= 

                      gMax = min( max(onsets(ii),1)+handles.output.gh.bins-1, handles.Zheader.total_scans );
                      fMax = min( handles.output.gh.bins, gMax-onsets(ii)+1);
                      Gdepth = 0;
                      eval( ['Gdepth = size( Gr' num2str(RunNo) ', 1 );' ] );

                      if ( gMax > Gdepth)  	% --= scan depth issue - perhaps should be seconds
                        num_overrun = num_overrun + 1;	% --=
                        % --=           flagdepth = nbins - (gMax - size(Graw,1) );
                        flagdepth = handles.output.gh.bins - (gMax - Gdepth );
                        gMax = Gdepth;		% --= 
                        % --=           max_overrun = max( flagdepth * TR, max_overrun );
                        max_overrun = max( flagdepth*handles.output.gh.TR, max_overrun );
                      end  % --= 
  
                      % --=       
                      if ( max(onsets(ii),1) <= Gdepth )		% --= 
                        command = sprintf( 'Gr%d(%d:%d,%d:%d) = Gr%d(%d:%d,%d:%d) + flags(1:%d,:);\n', ... 	% --= 
                            RunNo, max(onsets(ii),1), gMax, cstart, cend, ...	% --= 
                            RunNo, max(onsets(ii),1), gMax, cstart, cend, flagdepth );	% --= 
                        eval( command );% --= 
                      else  % --= 
                        invalid_start_point = invalid_start_point + 1;  % --= 
                      end  % --= 
      
                    end;  % --= each onset value ---

                  else  % -- model is HRF

                    timings = next_entry( fid ); % --= 
                    t_dur = [];
                    eval( [ 't_dur = [' timings '];' ] ); % --= 

                    if size(t_dur,2) == 1	% allow a single duration entry to be used as default
                      t_durations = ones( size( onsets ) ) * t_dur; 
                    else
                      t_durations = t_dur; 
                    end;

                    t_onsets = calculate_hrf_shape( [onsets' t_durations'], handles.Zheader.timeseries.subject(SubjectNo).run(RunNo,1), TR );
                    eval( [ 'Gr' num2str(RunNo) ' = [Gr' num2str(RunNo) ' t_onsets];' ] );

                  end  % --- model specific switch ---

                end  % --- timing entry found ---

              else
                % - condition encoded in subject, but not this run - pad (
                % watch split conditions
                if ( handles.output.gh.model_type == constant_define( 'HRF_MODEL' ) )
                  eval( [ 'Gr' num2str(RunNo) ' = [Gr' num2str(RunNo) ' zeros( size( Gr' num2str(RunNo) ' , 1), 1 ) ];' ] );
                end;
              end; % --- this condition encoded within the subject run

            end; % --- this condition encoded within the subject

            pComment( '', pop );
            
          end  % --= each condition ---

          eval ( [ 'G_R' num2str(RunNo) ' = Gr' num2str(RunNo) ';' ] );	% --=
          eval ( [ 'G_R' num2str(RunNo) '(find(G_R' num2str(RunNo) ')) = 1;' ] );	% --=

          if handles.normalize_me

            pComment( 'Normalizing . . .', pop);
              
            mn = 0;
            eval ( [ 'mn = mean(Gr' num2str(RunNo) ');' ] );	% --=
            % --= 
            xx = 0;
            eval ( [ 'xx = size(G_R' num2str(RunNo) ',2);' ] );	
            for jj = 1:xx	% --=
              eval ( [ 'G_R' num2str(RunNo) '(:,jj) = G_R' num2str(RunNo) '(:,jj)-mn(1,jj);' ] );	% --=
            end;	% --=
            % --= 
            st = 0;
            eval ( [ 'st = samp_dev( G_R' num2str(RunNo) ' );' ] );	% --=
            for jj = 1:xx	% --=
              if ( st(1,jj) ~= 0 )  % -- avoid Nan in response to divide by 0 errors
                eval ( [ 'G_R' num2str(RunNo) '(:,jj) = G_R' num2str(RunNo) '(:,jj) ./ st(1,jj);' ] );	% --=  
              end;
            end;	% --=

            % for non encoded conditions
            mn = 0;
            x = 0;
            eval( [' mn = min( min( G_R' num2str(RunNo) ' ) );' ] );
            eval( [' x = find( G_R' num2str(RunNo) ' == 0 );' ] );
            if size( x, 1 ) > 0 
              eval( [' G_R' num2str(RunNo) '(x(:)) = mn;' ] );
            end;

            pComment( '', pop );
            
          end;
 
          pComment( 'Finalizing . . .', pop );
          
          eval ( [ 'Gnorm = [Gnorm; G_R' num2str(RunNo) ' ];' ] );
          eval ( [ 'Graw = [Graw; Gr' num2str(RunNo) ' ];' ] );

          eval( [ 'GG_R' num2str(RunNo) ' = G_R' num2str(RunNo) ''' * G_R' num2str(RunNo) ';' ] );
          eval( [ 'GG = GG + GG_R' num2str(RunNo) ';' ] );

          pComment( 'Saving . . .', pop );
          eval( [ 'save( ''Gsegs' filesep 'G_S' num2str(SubjectNo) '.mat'', ''G_R*'', ''Gr*'', ''Gn*'', ''-append'', ''-v7.3'' )'] );

          clear G_* GG_* 
          eval( ['clear Gr' num2str(RunNo) ] );

          pComment( '', pop);
          
        end  % --= subject contains run ---
      end  % --= each run ---


      pComment( 'Checking Rank . . .', pop );
      this_rank = rank( Gnorm );
      this_rcond = rcond(Gnorm'*Gnorm);
      if ( ~this_rcond > (eps*1.1) )
        handles.output.gh.illformed = 1;
        handles.output.gh.subjects = [handles.output.gh.subjects SubjectNo];
        
        sr = sprintf( 'Subject %3d: id: %s  rank: %d ', SubjectNo, subject_id( SubjectNo), this_rank );
        subRank = [subRank; {sr}];
        
      end;

      pComment( 'Calculating Projection . . .', pop );
      
      try
        gg = sqrtm(pinv(GG));
        str = format_value(  sum( sum( gg ) ), '%.2f' );
      catch e
          x = e;
          str = 'ERR';
      end
      eval( [ 'save( ''Gsegs' filesep 'G_S' num2str(SubjectNo) '.mat'', ''GG'', ''gg'', ''Graw'', ''-append'', ''-v7.3'' )'] );

      fprintf( grank, 'Subject %3d: rank: %d   rcond:%s    gg: %s\n', SubjectNo, this_rank, num2str(this_rcond), str );
      pComment( '', pop );
%toc
    end;  % --= each subject ---
    % --= 

    handles.output.gh.mean_tr = mean( onsvec );

  end  % --- onsets input file opened ---

  if ( fid )  fclose( fid ); end;
  if ( grank )  fclose( grank ); end;

  set( handles.lst_subjects, 'Value', 1 ) ;
  drawnow();

  % --- Update handles structure
  guidata(hObject, handles);

  
  if handles.output.gh.illformed
    title = center_text( 'Potentially Rank Deficient G', 50 );
    str = 'We discovered a potential deficiency in one ore more of your subjects G matrices.';
    show_message( title, [{str}; subRank ] );
  end

  Gheader = handles.output.gh;
  save Gheader Gheader

  if ( strcmp( class(pop), 'cpca_progress' ) )
    pop.hide();
  end

  dt = date;
  crt = 'created partitioned G matrix' ;
  src = [ ' From: ' char(Gheader.source) ];
  loc = [ 'Store: ' Gheader.path_to_segs ];
  dim = [ 'Stats: Conditions: ' num2str(Gheader.conditions) '   Bins: ' num2str(Gheader.bins) ];
  write_log( dt, crt, src, loc, dim );

  if ( (invalid_start_point + num_overrun) > 0 )
    str = sprintf( '%d onsets encoded beyond the depth of the run : %d onsets started encoding beyond the depth of the run.  Perhaps the onsets are in seconds rather than scans.', num_overrun, invalid_start_point );
    show_message( 'Warning!  Onset Depth Exceeded', str );
  end;

  uiresume(handles.figure1);
end

  % --- nested progress update messaging controls

  function pComment( txt, pop )
    if ( strcmp( class(pop), 'cpca_progress' ) )
      pop.setComment( txt );
    end
  end

  function pMessage( txt, pop )
    if ( strcmp( class(pop), 'cpca_progress' ) )
      pop.setMessage( txt );
    end
  end
  
%end



% --- Executes on selection change in lst_runs.
function lst_runs_Callback(hObject, eventdata, handles)
% --- hObject    handle to lst_runs (see GCBO)
% --- eventdata  reserved - to be defined in a future version of MATLAB
% --- handles    structure with handles and user data (see GUIDATA)

  x = get(handles.lst_subjects,'Value');
  y = get(hObject,'Value');
  if ( ~isempty( handles.Zheader.conditions.subject ) )
    % --- set selected conditions
    set( handles.lst_conditionNames, 'Value', handles.Zheader.conditions.subject(x).Run(y).conditions )
  end;
end


% --- Executes during object creation, after setting all properties.
function lst_runs_CreateFcn(hObject, eventdata, handles)
% --- hObject    handle to lst_runs (see GCBO)
% --- eventdata  reserved - to be defined in a future version of MATLAB
% --- handles    empty - handles not created until after all CreateFcns called

% --- Hint: listbox controls usually have a white background on Windows.
% ---      See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on button press in btn_runs_and_conditions.
function btn_runs_and_conditions_Callback(hObject, eventdata, handles)
% --- hObject    handle to btn_runs_and_conditions (see GCBO)
% --- eventdata  reserved - to be defined in a future version of MATLAB
% --- handles    structure with handles and user data (see GUIDATA)

  % --- do not allow import in runs and conditions dialog, as not all structure data may be preserved ---
  GH = get_G_settings( handles );

  x = Runs_and_Conditions( 'zheader',  handles.Zheader, 'scaninfo', handles.scan_information, 'import', 0, 'isHRF', GH.model_type );

  if ( ~isempty( x ) )
    handles.Zheader.conditions = x;
    % --- Update handles structure
    guidata(hObject, handles);


    if ( size(handles.Zheader.conditions.subject,1) > 0 )
      x = max( 1, get(handles.lst_subjects,'Value') );
      y = max( 1, get(handles.lst_runs,'Value') );
      set( handles.lst_conditionNames, 'String', handles.Zheader.conditions.Names', 'Value', handles.Zheader.conditions.subject(x).Run(y).conditions );
    end;

    % --- Update handles structure
    guidata(hObject, handles);
 
    % --- save changes to Zheader and scan_information directly
    save_headers()

    create_button_state( handles );
  end;
end



function GH = get_G_settings ( handles );

  GH = structure_define( 'GHEADER' );

  GH.conditions = size(handles.Zheader.conditions.Names, 2 );
  GH.bins = str2double(get(handles.txt_timeBins,'String')); 
  GH.TR = str2double(get(handles.txt_timingRate,'String')); 
  GH.inScans = get(handles.btn_Scans,'Value'); 
  GH.model_type = get(handles.btn_HRF,'Value'); 

  GH.condition_name = handles.Zheader.conditions.Names ;
end



% --- Executes on button press in chk_normalize.
function chk_normalize_Callback(hObject, eventdata, handles)
% hObject    handle to chk_normalize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.normalize_me = get(hObject,'Value');

  % --- Update handles structure
  guidata(hObject, handles);
end



% --- Executes on button press in chk_use_source_onsets.
function chk_use_source_onsets_Callback(hObject, eventdata, handles)
% hObject    handle to chk_use_source_onsets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    create_button_state( handles );

end
