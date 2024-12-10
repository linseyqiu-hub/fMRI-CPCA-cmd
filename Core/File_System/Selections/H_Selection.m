function varargout = H_Selection(varargin)
% H_SELECTION MATLAB code for H_Selection.fig
%      H_SELECTION, by itself, creates a new H_SELECTION or raises the existing
%      singleton*.
%
%      H = H_SELECTION returns the handle to a new H_SELECTION or the handle to
%      the existing singleton*.
%
%      H_SELECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in H_SELECTION.M with the given input arguments.
%
%      H_SELECTION('Property','Value',...) creates a new H_SELECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before H_Selection_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to H_Selection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help H_Selection

% Last Modified by GUIDE v2.5 03-May-2017 11:55:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @H_Selection_OpeningFcn, ...
                   'gui_OutputFcn',  @H_Selection_OutputFcn, ...
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


% --- Executes just before H_Selection is made visible.
function H_Selection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to H_Selection (see VARARGIN)
global Zheader scan_information

  % Choose default command line output for H_Selection
  handles.output = hObject;

  % --- start with defaults
  % --- single H applied to all subjects
  % --- selected from existing G analysis

  hh = structure_define( 'HHEADER' );
  handles.Hstruc = hh.model;
  handles.incl_constant = get(handles.constant, 'Value');	
  handles.analysis = [];
  handles.valid_H = 0;
  handles.num_voxels = Zheader.total_columns * max(1, scan_information.frequencies);
  handles.num_subjects = Zheader.num_subjects;
  
  handles.buttonLabel = [ {'Select H Directory'} {'Select H File'} ];
  handles.onoff = [ {'off'} {'on'} ];

  % --- disble H per subject for now
  set( handles.chk_individual_H, 'Enable','off' );

  % Update handles structure  
  guidata(hObject, handles);

  handles = set_analysis_list( handles );
  handles = check_valid_H( handles );

  % Update handles structure  
  guidata(hObject, handles);
  set_controls( handles );
  

% UIWAIT makes H_Selection wait for user response (see UIRESUME)
  uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = H_Selection_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
  varargout{1} = handles.output;
  guidata(handles.figure1, handles);
  delete(handles.figure1);


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


% --- Executes on button press in chk_unique_H.
function chk_unique_H_Callback(hObject, eventdata, handles)
% hObject    handle to chk_unique_H (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.Hstruc.unique_H = get( hObject, 'Value' );

  if handles.Hstruc.use_VR
    handles = set_analysis_list( handles );
  end;

  handles = check_valid_H( handles );
  guidata(hObject, handles);
  
  set_controls( handles );


% --- Executes on button press in chk_individual_H.
function chk_individual_H_Callback(hObject, eventdata, handles)
% hObject    handle to chk_individual_H (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.Hstruc.unique_H = ~get( hObject, 'Value' );
  guidata(hObject, handles);

  if handles.Hstruc.use_VR
    handles = set_analysis_list( handles );
  end;

  handles = check_valid_H( handles );
  guidata(hObject, handles);
  set_controls( handles );


% --- Executes on button press in chk_use_VR.
function chk_use_VR_Callback(hObject, eventdata, handles)
% hObject    handle to chk_use_VR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.Hstruc.use_VR = get( hObject, 'Value' );

  if handles.Hstruc.use_VR
    set( handles.lbl_list_type, 'String', 'Select Analysis' );
    handles = set_analysis_list( handles );
  else
    handles.Hstruc.path = '';
    handles.Hstruc.file = '';
    handles.Hstruc.var = '';
    set( handles.lbl_list_type, 'String', 'Select H Variable' );
    set( handles.lst_vars_or_analysis, 'String', [], 'Value', 1);
  end;
  
  handles = check_valid_H( handles );
  guidata(hObject, handles);
  set_controls( handles );


% --- Executes on selection change in lst_vars_or_analysis.
function lst_vars_or_analysis_Callback(hObject, eventdata, handles)
% hObject    handle to lst_vars_or_analysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  ii = get(hObject,'Value');

  if handles.Hstruc.use_VR   	% --- varnames from handles.analysis list
    if ~isempty( handles.analysis )
      if size( handles.analysis, 1 ) == 1
        handles.Hstruc.path = char(handles.analysis(1) );
        handles.Hstruc.file = char(handles.analysis(2) );
      else
        handles.Hstruc.path = char(handles.analysis(ii,1) );
        handles.Hstruc.file = char(handles.analysis(ii,2) );
      end;
      handles.Hstruc.var = 'VR';
    end;

  else
    content = get( hObject, 'String' );
    if size(content, 1 ) > 0 
      handles.Hstruc.var = char(content( get( hObject, 'Value' ) ) );
    end;
  end;

  handles = check_valid_H( handles );
  guidata(hObject, handles);
  set_controls( handles );


% --- Executes during object creation, after setting all properties.
function lst_vars_or_analysis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_vars_or_analysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_select_file_or_folder.
function btn_select_file_or_folder_Callback(hObject, eventdata, handles)
% hObject    handle to btn_select_file_or_folder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  if handles.Hstruc.use_VR   return;  end;	% --- this should never happen

  set( handles.lst_vars_or_analysis, 'String', [], 'Value', 1) ;
  
  handles.Hstruc.path = '';
  handles.Hstruc.file = '';
  handles.Hstruc.var = '';

  if handles.Hstruc.unique_H	% --- select H file and list vars
    fullpath = select_file( {'*.mat','MATLAB .mat file'}, ...
                                   'Select the file containing H Matrix');

    if ~isempty( fullpath )
        
      [path fn] = split_path( fullpath, filesep );
      handles.Hstruc.path = path;
      handles.Hstruc.file = fn;
      
      vlist = matfile_vars( handles.Hstruc.path, handles.Hstruc.file );
      if size(vlist,1) > 0
        for ii = 1:size(vlist, 1 )
            
          if strcmp(vlist(ii).name, 'ID' )
            load( [handles.Hstruc.path handles.Hstruc.file], 'ID' );
            handles.Hstruc.id = ID;
          end;
          
          if strcmp(vlist(ii).name, 'RegionLabels' )
            handles.Hstruc.isRegionalH = 1;
          end;
          
        end;
      end;
      
      handles = set_variable_list( handles );

    end;


  else

    thisdir = handles.Hstruc.path;
    dirname = uigetdir(thisdir, 'Select the directory containing your individual subject H files');

    % --- user defined subject specific H matrices
    % --- * all mat files to exist in a single directory
    % --- * all files to have the name format H_Sn.mat  [ n is the numeric equivalent of the subject number ]
    % ---                                               [ n is not zero padded  eg H_S1.mat  H_S11.mat      ]
    % ---                                               [ proper sync between subject number and subject    ]
    % ---                                               [ is the responsibility of the researcher           ]
    % --- * Variable to be named 'H' in ALL files
    if ~isequal( dirname, 0)

      handles.Hstruc.path = [dirname filesep];
      handles.Hstruc.file = ['H_S' num2str(handles.num_subjects) '.mat'];
      handles.Hstruc.var = 'H';

    end;

  end;

  handles = check_valid_H( handles );
  guidata(hObject, handles);
  set_controls( handles );




% --- Executes on button press in btn_okay.
function btn_okay_Callback(hObject, eventdata, handles)
% hObject    handle to btn_okay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (get(handles.constant, 'Value'))
	H = load([handles.Hstruc.path handles.Hstruc.file], handles.Hstruc.var);
	H = H.(handles.Hstruc.var);
	x = size(H);
	if(x(1) == handles.num_voxels && ~(sum(H(:,1)) == handles.num_voxels));
		H = [ones(x(1), 1) H];
		eval([handles.Hstruc.var, ' = H;']);
		save([handles.Hstruc.path handles.Hstruc.file], handles.Hstruc.var, '-append');
	elseif(x(2) == handles.num_voxels && ~(sum(H(1,:)) == handles.num_voxels));
		H = [ones(1, x(2)); H];
		eval([handles.Hstruc.var, ' = H;']);
		save([handles.Hstruc.path handles.Hstruc.file], handles.Hstruc.var, '-append');
	else
		disp('WARNING: H may already have constant');
	end
end
  handles.output = handles.Hstruc;
  guidata(hObject, handles);
  uiresume(handles.figure1);


% --- Executes on button press in btn_cancel.
function btn_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to btn_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  handles.output = '';
  guidata(hObject, handles);
  uiresume(handles.figure1);


function handles = set_analysis_list( handles )

  lst = [];
  handles.analysis = [];
%  if handles.Hstruc.use_VR

% --- todo: filter subject directory list      

    % ---------------------------
    % add the files from valid subdirectories (n_components)
    % ---------------------------
    valid_dirs = [{'unrotated'}];
    rotations = define_rotations();
    for ii = 1:size(rotations)  valid_dirs = [valid_dirs {rotations(ii).method}]; end;
  
    [comp_list num_comps] = directory_list( [pwd filesep 'G' filesep] );
   
    if num_comps > 0 

      for compcount = 1:size(comp_list, 1 )
        p = [pwd filesep 'G' filesep char( comp_list(compcount) ) filesep];

        [sub_list sub_count] = directory_list( p );
        if sub_count > 0 
          
          for cdir = 1:sub_count
            
            if any( strcmp( char(sub_list(cdir)), valid_dirs)) 

              nc = num2str( validate_numeric_entry ( char( comp_list(compcount) ) ) );
            
              q = [p char(sub_list(cdir)) filesep char(42) '.mat' ];
              q = dir(q);
              if ( size(q, 1) > 0 )
                for jj = 1:size(q,1)
                  str = [p char(sub_list(cdir)) filesep ]; 
                  
                  if ~handles.Hstruc.unique_H  % --- Subject Directories need to exist
                    s = [p char(sub_list(cdir)) filesep 'Subject_Specific' ];

                    [dirlist numdirs] = directory_list ( s );
                    validated = numdirs == handles.num_subjects;
%                    s = dir(s);
%                    validated = ~isempty(s);
                    q(jj).name = strrep( q(jj).name, '.mat', '_alt_vr.mat' );
                    if validated
                      s = [s filesep char(dirlist(1)) filesep ];
                    end;
                  else
                    validated = 1;
                    s = [p char(sub_list(cdir)) filesep];
                  end;
                  
                  if validated 
%                    hrft = who_stats( [p char(sub_list(cdir)) filesep], q(jj).name, 'cpca_version' );
                    hrft = who_stats( s, q(jj).name, 'cpca_version' );
                    if hrft.mat_exists
                      handles.analysis = [handles.analysis; [{str} {q(jj).name}] ];
                      str = q(jj).name;
                      wipe = [ 'G_'];
                      rep = [ '(' num2str(nc) ') ' ];
                      str = strrep( str, wipe, rep );
                      str = strrep( str, '_', ' ' );
                      str = strrep( str, '.mat', '' );
                      lst = horzcat( lst, {str});  
                    end;	% --- not the hrfmax T variable
                  end;
                end;
              end;
            
            end % -- valid data directory

          end % -- check if valid
        end;  % --- extraction directory found
        
      end;  % check each component count directory 
      
    end;  % -- no extracted component directories found for model type
    
%  end;

  set( handles.lst_vars_or_analysis, 'String', lst, 'Value', 1) ;
  if handles.Hstruc.use_VR
    if ~isempty( handles.analysis )
      if size( handles.analysis, 1 ) == 1
        handles.Hstruc.path = char(handles.analysis(1) );
        handles.Hstruc.file = char(handles.analysis(2) );
      else
        handles.Hstruc.path = char(handles.analysis(1,1) );
        handles.Hstruc.file = char(handles.analysis(1,2) );
%        handles.Hstruc.file = char(handles.analysis(1) );
      end;
      handles.Hstruc.var = 'VR';
    end;
  end;
  
%%  guidata(handles.figure1, handles);
 
function handles = set_variable_list( handles )

  lst = [];
  
  vlist = matfile_vars( handles.Hstruc.path, handles.Hstruc.file );
  if size(vlist,1) > 0
    for ii = 1:size(vlist, 1 )
      lst = [lst; {vlist(ii).name} ];
    end;
    set( handles.lst_vars_or_analysis, 'String', lst, 'Value', 1) ;

    if ~isempty(lst)
      if size( lst, 1 ) == 1
        handles.Hstruc.var = char(lst);
      else
        handles.Hstruc.var = char(lst(1));
      end;
    end;

  end;

  
  

function set_controls(handles)
% hObject    handle to btn_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  set( handles.chk_unique_H, 'Value', handles.Hstruc.unique_H );
  set( handles.chk_individual_H, 'Value', ~handles.Hstruc.unique_H );

  set( handles.chk_use_VR, 'Value', handles.Hstruc.use_VR);
% ---  set( handles.chk_use_VR, 'Enable', char(handles.onoff( handles.Hstruc.use_VR + 1 )) );

  set( handles.btn_select_file_or_folder, 'String', char( handles.buttonLabel( handles.Hstruc.unique_H + 1 ) ));
  set( handles.btn_select_file_or_folder, 'Enable', char( handles.onoff( ( ~handles.Hstruc.use_VR) + 1 ) ));

  set( handles.btn_select_file_or_folder, 'Enable', char( handles.onoff( ( ~handles.Hstruc.use_VR) + 1 ) ));
%  set( handles.lst_vars_or_analysis, 'Enable', char( handles.onoff( ( handles.Hstruc.use_VR) + 1 ) ));

  set( handles.btn_okay, 'Enable', char( handles.onoff( handles.valid_H + 1 ) ));




function handles = check_valid_H( handles )
global  scan_information

 handles.valid_H = 0;
 hcount = 0;
 set( handles.txt_status, 'String', {'H Variable: n/a'} );
 handles.Hstruc.size = [0 0];

 if isempty( handles.Hstruc.path )  return; end;	% --- minimum requirement

 if isempty( handles.Hstruc.file ) |  isempty( handles.Hstruc.var )  
   return; 
 end;  

 if handles.Hstruc.unique_H
   fn = exist( [ handles.Hstruc.path handles.Hstruc.file ], 'file' );

 else   % --- determne all subject compeleted by checking last subject file
   if handles.Hstruc.use_VR
     fn = exist( [ handles.Hstruc.path 'Subject_Specific' filesep 'Subject_'  num2str( handles.num_subjects, '%03d' ) filesep handles.Hstruc.file ], 'file' );
   else
     fn = exist( [ handles.Hstruc.path 'H_S'  num2str( handles.num_subjects ) '.mat' ], 'file' );
   end;
 end;

 if fn ~= 2 			% --- no file
  return; 
 end;   				

 if handles.Hstruc.unique_H				% --- use VR for all subjects		
   x = matfile_vars( handles.Hstruc.path, handles.Hstruc.file, handles.Hstruc.var );
   if ~isempty(x)
     handles.valid_H = x.sz_x == handles.num_voxels | x.sz_y == handles.num_voxels;
   end;

 else							% --- individual subject VR
   if handles.Hstruc.use_VR
     x = directory_list( [handles.Hstruc.path 'Subject_Specific' filesep 'Subject*'] );
   else
     x = file_list( [handles.Hstruc.path 'H_S*.mat'] );
   end;

   hasDirs = size(x, 1) == handles.num_subjects;
   if hasDirs
     if handles.Hstruc.use_VR
       x = matfile_vars( [handles.Hstruc.path 'Subject_Specific' filesep 'Subject_'  num2str( handles.num_subjects, '%03d' ) filesep], handles.Hstruc.file, handles.Hstruc.var );
     else
       x = matfile_vars( handles.Hstruc.path, ['H_S' num2str( handles.num_subjects ) '.mat'], handles.Hstruc.var );
     end;

     if ~isempty(x)
       handles.valid_H = x.sz_x == handles.num_voxels | x.sz_y == handles.num_voxels;
     end;

   end;

 end;

 if handles.valid_H

   handles.Hstruc.size = [x.sz_x x.sz_y];
   
   if handles.Hstruc.size(1) == handles.num_voxels
     A = handles.Hstruc.size;
   else
     A = sort( handles.Hstruc.size, 'descend' );
   end;
   sz = [ '[' num2str(A(1)) ' x ' num2str(A(2)) ']' ];

   str = {[ 'Variable: ' handles.Hstruc.var ' ' sz ]};
   if ~handles.Hstruc.unique_H				% --- use VR for all subjects		
%     str = [str; {'Single to all subjects'} ];
%   else
     str = [str; {'Individual subject vectors'} ];
   end;
   set( handles.txt_status, 'String', str );
 end;


% --- Executes on button press in constant.
function constant_Callback(hObject, eventdata, handles)
% hObject    handle to constant (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of constant
