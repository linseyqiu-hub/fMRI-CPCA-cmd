function varargout = mask_verification(varargin)
% MASK_VERIFICATION M-file for mask_verification.fig
%      MASK_VERIFICATION, by itself, creates a new MASK_VERIFICATION or raises the existing
%      singleton*.
%
%      H = MASK_VERIFICATION returns the handle to a new MASK_VERIFICATION or the handle to
%      the existing singleton*.
%
%      MASK_VERIFICATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MASK_VERIFICATION.M with the given input arguments.
%
%      MASK_VERIFICATION('Property','Value',...) creates a new MASK_VERIFICATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mask_verification_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mask_verification_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mask_verification

% Last Modified by GUIDE v2.5 24-Jun-2013 13:50:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mask_verification_OpeningFcn, ...
                   'gui_OutputFcn',  @mask_verification_OutputFcn, ...
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


% --- Executes just before mask_verification is made visible.
function mask_verification_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mask_verification (see VARARGIN)
global Zheader scan_information;

  [handles.Zheader, handles.scan_information] = adjust_headers( Zheader, scan_information, Zheader.Z_Directory );
  handles.dir_char = '/';
  handles.summary_type = 1;		% 1 = all, 2 = errors, 3 = good
  handles.reparse = 0;			% flag file list requiring reparsing

  handles.isNII = strfind( lower(handles.scan_information.mask.file), '.nii') > 0 | handles.scan_information.mask.niiSingle ;
  if handles.isNII
    handles.new_mask_name = 'new_mask.nii'; % file name to use when creating new mask
  else
    handles.new_mask_name = 'new_mask.img'; % file name to use when creating new mask
  end;

  set( handles.btn_new_mask, 'Visible', 'off' );
  set( handles.txt_mask_name, 'Visible', 'off' );
  set( handles.chk_NII_single, 'Visible', 'off' );
  set( handles.chk_NII_single, 'Enable', 'off' );

  set( handles.txt_mask_name, 'String', handles.new_mask_name );
  set( handles.chk_NII_single, 'Value', handles.scan_information.mask.niiSingle );

  if ( ispc )	handles.dir_char = '\'; 	end;

  set( handles.lst_subjects, 'String', handles.scan_information.SubjectID', 'Value', 1 );

  x = exist( './mask_verification.mat', 'file' );
  if ( x == 2 )
    load mask_verification;

    update_scan_results( handles, subject_verification );
    show_total( handles, total_verification );

    voxel_errors = total_verification.bad > 0 | total_verification.columns_with_zeros > 0 | total_verification.columns_with_inf > 0 ;
    if ( voxel_errors )
      set( handles.btn_new_mask, 'Visible', 'on' );
      set( handles.txt_mask_name, 'Visible', 'on' );
      if handles.isNII
        set( handles.chk_NII_single, 'Visible', 'on' );
      end;
    end;

    if ( ~isempty( handles.scan_information.FileList ) )  Enabled = 'on'; else; Enabled = 'off'; end

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


  % Choose default command line output for mask_verification
  handles.output = hObject;

  % Update handles structure
  guidata(hObject, handles);

  % UIWAIT makes mask_verification wait for user response (see UIRESUME)
  uiwait(handles.figure1);



% --- Outputs from this function are returned to the command line.
function varargout = mask_verification_OutputFcn(hObject, eventdata, handles) 
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
global Zheader scan_information 

  doRank = get( handles.chk_Rank, 'Value');  
  
  lst = get(handles.lst_subjects,'String');
  subject_vector = get(handles.lst_subjects,'Value');
  set( handles.lst_results, 'String', [] );

  txt = [];
  v = struct ( 'SubjectID', '', 'Freq', '', 'RunNo', 0, 'Scans', 0 , 'good', 0, 'bad', 0, 'count', 0, ...
      'scans_with_zeros', 0, 'scans_with_nanorinf', 0, ...
      'columns_with_zeros', 0, 'columns_with_nan', 0, 'columns_with_inf', 0, ...
      'files', struct( 'name', [] ) , 'columns_of_zeros', [], 'columns_of_inf', [], 'isSingular', -1, 'rcond', 0, 'rank', 0 );

  subject_verification = [];
  total_verification = v;

  for Subject = 1:size(subject_vector, 2 )

    SubjectNo = subject_vector(Subject);
    SubjectID = char(lst(SubjectNo));
    set( handles.lst_subjects, 'Value', SubjectNo );

    for FrequencyNo = 1:handles.Zheader.num_Z_arrays

      ftag = frequency_tag(FrequencyNo);
      ftag = strrep( ftag, '_', '' );

      for RunNo = 1:handles.Zheader.num_runs

        if iscellstr( handles.scan_information.SubjDir( Subject, RunNo ) )
          
          verification = v;
          verification.SubjectID = SubjectID;
          verification.RunNo = RunNo;
          verification.Freq = ftag;

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
          verification.Scans = n_files;
          total_verification.Scans = total_verification.Scans + n_files;
          
          Z = zeros( n_files, Zheader.total_columns );

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

            if isfield( img.header, 'error' )
              verification.bad = verification.bad + 1;
              total_verification.bad = total_verification.bad + 1;

              % --- place in secondary display
              fn = strrep( img.header.error, pathspec, '' );
              name = strrep( fn, 'file corrupted ', '' );
              verification.files.name = [verification.files.name; {name} ];

            else
              verification.good = verification.good + 1;
              total_verification.good = total_verification.good + 1;

              Z(scan_no,:) = img.image( scan_information.mask.ind(:) )';

              x = find( Z(scan_no,:) == 0 );
              if ~isempty( x )   
                verification.scans_with_zeros = verification.scans_with_zeros + 1;  
                total_verification.scans_with_zeros = total_verification.scans_with_zeros + 1;
              end;

              x = sum( Z(scan_no,:) );
              if isnan(x) | isinf(x)  
                verification.scans_with_nanorinf = verification.scans_with_nanorinf + 1;  
                total_verification.scans_with_nanorinf = total_verification.scans_with_nanorinf + 1;  
              end;

         
            end;

            summary = sprintf( '%s %s run%d  [scans:  %d/%d  zero:%d  inf/nan:%d] [ columns: zero:%d inf:%d nan:%d]', SubjectID, ftag, RunNo, ...
                      verification.good, time_series, ...
                      verification.scans_with_zeros,  verification.scans_with_nanorinf, ...
                      verification.columns_with_zeros, verification.columns_with_inf, verification.columns_with_nan );

            set( handles.txt_current, 'String', summary );
            drawnow();

            voxel_errors = verification.bad > 0 | verification.scans_with_zeros > 0 | verification.scans_with_nanorinf > 0 ;
            if ( voxel_errors )
              set( handles.btn_new_mask, 'Visible', 'on' );
              set( handles.txt_mask_name, 'Visible', 'on' );
              if handles.isNII
                set( handles.chk_NII_single, 'Visible', 'on' );
              end;
              drawnow();
            end;

          end;  % --- each scan image ---

          if verification.bad == 0 
            sd = stddev(Z);
            verification.rcond = rcond( Z * Z' );
            verification.isSingular = ~verification.rcond > (eps * 1.1 );

            if doRank
              s = svd(Z, 'econ');
              tol = max(size(Z)) * eps(max(s));
              verification.rank = sum(s > tol);
            end;
            
            verification.columns_of_zeros = find( sd == 0 );
            if ~isempty(verification.columns_of_zeros)              
              verification.columns_with_zeros = size(verification.columns_of_zeros,2);	
              total_verification.columns_of_zeros = unique([verification.columns_of_zeros total_verification.columns_of_zeros]);
              total_verification.columns_with_zeros = size(total_verification.columns_of_zeros,2);	
            end;

            verification.columns_of_inf = find( sd == inf );
            if ~isempty(verification.columns_of_inf)              
              verification.columns_with_inf = size(verification.columns_of_inf,2);	
              verification.columns_of_inf = unique([verification.columns_of_inf total_verification.columns_of_inf]);
              total_verification.columns_with_inf = size(total_verification.columns_of_inf,2);	
            end;

            x = isnan(sum(sd));
            if (x)                      
              verification.columns_with_nan = 1;		
              total_verification.columns_with_nan = 1;		
            end;

          end;
          subject_verification = [subject_verification; verification ];
          update_scan_results( handles, subject_verification );
          set( handles.lst_results, 'Value', size(subject_verification,1) );

          show_total( handles, total_verification );

        end;  % --- Subject contains run ---
      
      end;  % --- each run ---

    end;  % --- each frequency range

  end;  % --- each selected subject ---

%  set( handles.lst_subjects, 'Value', 1 );
  show_total( handles, total_verification );

  set( handles.txt_current, 'String', '' );
  set( handles.lst_results, 'Value', 1 );

  save mask_verification subject_verification total_verification;

  singular_values = [ {''} {''} {' [singular]'} ];

  text_file = 'mask_verification.txt';
  fid = fopen( text_file, 'w' );
  if ( fid )

    for ii = 1:size(subject_verification, 1 )

      if ~isfield( subject_verification(ii), 'isSingular' ) % --- older version did no singularity check
        subject_verification(ii).isSingular = -1;
      end;
    
      fmt = '%s %s run%d  [scans:  %d/%d  zero:%d  inf/nan:%d] [ columns: zero:%d inf:%d nan:%d]';
      if doRank          
        fmt = [fmt ' rank: ' num2str(subject_verification(ii).rank) ];
      end
      fmt = [fmt ' rcond: %e %s'];
      
        fprintf( fid, [fmt '\n'], ...
          subject_verification(ii).SubjectID, ...
          subject_verification(ii).Freq, ...
          subject_verification(ii).RunNo, ...
          subject_verification(ii).good, ...
          subject_verification(ii).Scans, ...
          subject_verification(ii).scans_with_zeros, ...
          subject_verification(ii).scans_with_nanorinf, ...
          subject_verification(ii).columns_with_zeros, ...
          subject_verification(ii).columns_with_inf, ...
          subject_verification(ii).columns_with_nan, ...
          subject_verification(ii).rcond, ...
          char(singular_values( subject_verification(ii).isSingular + 2) ) ); % , ...

    end;

      fprintf( fid, '\nTotal: [scans:  %d/%d  zero:%d  inf/nan:%d] [ columns: zero:%d inf:%d nan:%d] eps: %e\n', ...
      total_verification.good, total_verification.Scans, ...
      total_verification.scans_with_zeros,  total_verification.scans_with_nanorinf, ...
      total_verification.columns_with_zeros, total_verification.columns_with_inf, ...
      total_verification.columns_with_nan, eps   );

    fclose( fid );

  end;
  
  if ( ~isempty( handles.scan_information.FileList ) )  Enabled = 'on'; else; Enabled = 'off'; end


% --- Executes on button press in btn_save_errors.
function btn_save_errors_Callback(hObject, eventdata, handles)
% hObject    handle to btn_save_errors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  % do not assume the file exists

%                        -1      0      1
  singular_values = [ {''} {''} {' [singular]'} ];
  
  x = exist( './mask_verification.mat', 'file' );
  if ( x == 2 )
    load mask_verification;

    text_file = 'mask_verification_errors.txt';
    fid = fopen( text_file, 'w' );
    if ( fid )

      for ii = 1:size(subject_verification, 1 )

      if ~isfield( subject_verification(ii), 'isSingular' ) % --- older version did no singularity check
        subject_verification(ii).isSingular = -1;
      end;
    
          
        if ( subject_verification(ii).bad > 0 ) || subject_verification(ii).isSingular > 0

          fprintf( fid, '%s %s run%d  [scans:  %d/%d  zero:%d  inf/nan:%d] [ columns: zero:%d inf:%d nan:%d] %s', ...
            subject_verification(ii).SubjectID, ...
            subject_verification(ii).Freq, ...
            subject_verification(ii).RunNo, ...
            subject_verification(ii).good, ...
            subject_verification(ii).Scans, ...
            subject_verification(ii).scans_with_zeros, ...
            subject_verification(ii).scans_with_nanorinf, ...
            subject_verification(ii).columns_with_zeros, ...
            subject_verification(ii).columns_with_inf, ...
            subject_verification(ii).columns_with_nan, ...
            char(singular_values( subject_verification(ii).isSingular + 2) ) );

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

      
    summary = sprintf( 'Total: [scans:  %d/%d  zero:%d  inf/nan:%d] [ columns: zero:%d inf:%d nan:%d]  eps: %e', ...
      total_verification.good, total_verification.Scans, ...
      total_verification.scans_with_zeros,  total_verification.scans_with_nanorinf, ...
      total_verification.columns_with_zeros, total_verification.columns_with_inf, total_verification.columns_with_nan, eps   );

  set( handles.txt_total, 'String', summary );


function update_scan_results( handles, subject_verification )

  singular_values = [ {''} {''} {'[singular]'} ];
  doRank = get( handles.chk_Rank, 'Value');  

  txt = [];
  for ii = 1:size(subject_verification, 1 )

    if ~isfield( subject_verification(ii), 'isSingular' ) % --- older version did no singularity check
      subject_verification(ii).isSingular = -1;
    end;

    fmt = '%s %s run%d  [scans:  %d/%d  zero:%d  inf/nan:%d] [ columns: zero:%d inf:%d nan:%d]';
    if doRank          
      fmt = [fmt ' rank: ' num2str(subject_verification(ii).rank) ];
    end
    fmt = [fmt ' rcond: %e %s'];
    
    summary = sprintf( fmt, ...
      subject_verification(ii).SubjectID, ...
      subject_verification(ii).Freq, ...
      subject_verification(ii).RunNo, ...
      subject_verification(ii).good, ...
      subject_verification(ii).Scans, ...
      subject_verification(ii).scans_with_zeros, ...
      subject_verification(ii).scans_with_nanorinf, ...
      subject_verification(ii).columns_with_zeros, ...
      subject_verification(ii).columns_with_inf, ...
      subject_verification(ii).columns_with_nan, ...
      subject_verification(ii).rcond, ...
      char(singular_values( subject_verification(ii).isSingular + 2) ) ...
    );

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




% --- Executes on button press in btn_new_mask.
function btn_new_mask_Callback(hObject, eventdata, handles)
% hObject    handle to btn_new_mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scan_information

  load mask_verification;
  vox2remove = unique( [total_verification.columns_of_zeros total_verification.columns_of_inf] );

  msk = [];
  msk.header = scan_information.mask.header;
  msk.image = scan_information.mask.image;
  msk.vol = scan_information.mask.vol;

  msk.image( scan_information.mask.ind(vox2remove) ) = 0;
  msk.vol.fname = get( handles.txt_mask_name, 'String' );

  err = cpca_write_vols( msk ); % --= 
  if ( ~isempty( err ) )
    show_message( 'Image Write Error', err );
  end;
  

function txt_mask_name_Callback(hObject, eventdata, handles)
% hObject    handle to txt_mask_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_mask_name as text
%        str2double(get(hObject,'String')) returns contents of txt_mask_name as a double


% --- Executes during object creation, after setting all properties.
function txt_mask_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_mask_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chk_NII_single.
function chk_NII_single_Callback(hObject, eventdata, handles)
% hObject    handle to chk_NII_single (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_NII_single


% --- Executes on button press in chk_Rank.
function chk_Rank_Callback(hObject, eventdata, handles)
% hObject    handle to chk_Rank (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_Rank
