function varargout = Select_A(varargin)
% SELECT_A MATLAB code for Select_A.fig
%      SELECT_A, by itself, creates a new SELECT_A or raises the existing
%      singleton*.
%
%      H = SELECT_A returns the handle to a new SELECT_A or the handle to
%      the existing singleton*.
%
%      SELECT_A('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELECT_A.M with the given input arguments.
%
%      SELECT_A('Property','Value',...) creates a new SELECT_A or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Select_A_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Select_A_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Select_A

% Last Modified by GUIDE v2.5 14-Feb-2014 11:35:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Select_A_OpeningFcn, ...
                   'gui_OutputFcn',  @Select_A_OutputFcn, ...
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


% --- Executes just before Select_A is made visible.
function Select_A_OpeningFcn(hObject, eventdata, handles, varargin)
global Zheader

handles.Aheader = structure_define( 'AHEADER' );

handles.op = 'new';
handles.edit = [];

if(nargin > 0)
  handles.op = varargin{1};
end

load( Zheader.Model.path, 'Gheader' );
handles.A.GH = Gheader;

handles.output = [];

if strcmp( handles.op, 'edit' )
  handles.edit = varargin{2};
else
    
  handles.Aheader.model.bins = 1;
  
end


set( handles.txt_NumBins, 'String', num2str( handles.Aheader.model.bins ) );
set( handles.lst_Contrasts, 'String', handles.Aheader.model.contrast_name );
set( handles.txt_NumContrasts, 'String', handles.Aheader.model.contrasts );


% Update handles structure
guidata(hObject, handles);

set_widgets( handles );

% UIWAIT makes Select_A wait for user response (see UIRESUME)
 uiwait(handles.figure1);


 
 
function set_widgets( handles )
% --- fill the widgets with current data
  set( handles.lst_Contrasts,    'String', handles.Aheader.model.contrast_name );
  set( handles.txt_NumBins,      'String', num2str( handles.Aheader.model.bins ) );
  set( handles.txt_NumContrasts, 'String', handles.Aheader.model.contrasts );
  set( handles.txt_ID,           'String', handles.Aheader.model.id );

  
% --- Outputs from this function are returned to the command line.
function varargout = Select_A_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;
delete(handles.figure1);


% --- Executes on selection change in lst_Contrasts.
function lst_Contrasts_Callback(hObject, eventdata, handles)

  % If double click
  if strcmp(get(handles.figure1,'SelectionType'),'open')

    aa = get( hObject, 'String') ;
    [x y] = size( aa );
    if ( x == 0 )  % empty list
      return
    end;

    selected_index = get( hObject, 'Value') ;
    newEntry = inputdlg('Enter the Contrast Name','Edit Contrast Name', 1, aa(selected_index) );
    if ( ~isempty( newEntry ) ) 

      handles.Aheader.model.contrast_name(selected_index) = newEntry;
      set( handles.lst_Contrasts, 'String', handles.Aheader.model.contrast_name );
      
    end; 

 % Update handles structure
    guidata(hObject, handles);
   
  end;


% --- Executes during object creation, after setting all properties.
function lst_Contrasts_CreateFcn(hObject, eventdata, handles)

  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end



function txt_ContrastName_Callback(hObject, eventdata, handles)
  drawnow();
  

% --- Executes on key press with focus on txt_ContrastName and none of its controls.
function txt_ContrastName_KeyPressFcn(hObject, eventdata, handles)

  if ( strcmp( eventdata.Key , 'return' )  )
    txt_ContrastName_Callback(hObject, 0, handles);
    drawnow();
    btn_Add_Callback(handles.btn_Add, 0, handles);
    set( handles.btn_Add, 'Enable', 'off' );
    drawnow();
    return;
  end;

  drawnow();


% --- Executes during object creation, after setting all properties.
function txt_ContrastName_CreateFcn(hObject, eventdata, handles)
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end


% --- Executes on button press in btn_Add.
function btn_Add_Callback(hObject, eventdata, handles)

  x = get( handles.txt_ContrastName, 'String' );
  handles.Aheader.model.contrast_name = [handles.Aheader.model.contrast_name {x}];
  set( handles.lst_Contrasts, 'String', handles.Aheader.model.contrast_name );
  set( handles.txt_ContrastName, 'String', '' );

  % Update handles structure
  guidata(hObject, handles);



% --- Executes on button press in btn_Load.
function btn_Load_Callback(hObject, eventdata, handles)

  fullpath = select_file( {'*.txt;*.mat','text file, MATLAB file'}, ...
                                   'Select your text or MATLAB file');
  if ~isempty( fullpath )

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
          var_index = mat_selection( cont, 'Select Contrast Names' );

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

    set( handles.lst_Contrasts, 'String', lst );
    set( handles.txt_ContrastName, 'String', '' );

    handles.Aheader.model.contrast_name = lst';

    % Update handles structure
    guidata(hObject, handles);

  end;


function txt_NumBins_Callback(hObject, eventdata, handles)

  handles.Aheader.model.bins = str2num( get( hObject, 'String' ) );
  guidata(hObject, handles);
  set_widgets( handles );
  


% --- Executes during object creation, after setting all properties.
function txt_NumBins_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_NumContrasts_Callback(hObject, eventdata, handles)

  handles.Aheader.model.contrasts = str2num( get( hObject, 'String' ) );
  guidata(hObject, handles);
  set_widgets( handles );


% --- Executes during object creation, after setting all properties.
function txt_NumContrasts_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_SelectA.
function btn_SelectA_Callback(hObject, eventdata, handles)
global Zheader

  str = '';
  ndir = 5;
  
  [fn, path] = uigetfile('*.*', 'Select your A Matrix or definition text' );

  if isequal(fn,0) || isequal(path,0)
    str = ' < no A Matrix Selected >'
    set( handles.lbl_AMatrix, 'String', str );
    handles.A.m = [];

  else

    % --- was a mat file selected, or a text file defining A matrix parameters
    if isempty(strfind( fn, '.mat' ))

      A_def = read_definition_data( [ path fn], [], 'definitions' );
      A_lab = read_definition_data( [ path fn], [], 'labels' );
      
      if A_def.nvars > 0 
        if isfield( A_def.vars, 'contrasts' )    handles.Aheader.model.contrasts = str2double( A_def.vars.contrasts );  end;
        if isfield( A_def.vars, 'bins' )         handles.Aheader.model.bins      = str2double( A_def.vars.bins );       end;
        if isfield( A_def.vars, 'id' )           handles.Aheader.model.id        = A_def.vars.id;                       end;
        if isfield( A_def.vars, 'description' )  handles.Aheader.model.descr     = A_def.vars.description;              end;
        if isfield( A_def.vars, 'matfile' )      handles.Aheader.model.path      = A_def.vars.matfile;                  end;
        if isfield( A_def.vars, 'varname' )      handles.Aheader.model.var       = A_def.vars.varname;                  end;
      end;

      if A_lab.nvars > 0 
        fld = fieldnames( A_lab.vars );
        for ii = 1:A_lab.nvars
          eval( [ 'handles.Aheader.model.contrast_name = [handles.Aheader.model.contrast_name {A_lab.vars.' char(fld(ii)) '}];' ] );
        end;
      end

      [a b c] = fileparts( handles.Aheader.model.path );
      Am = who_stats( [a filesep], [b c], handles.Aheader.model.var );

      handles.Aheader.model.mat_x = Am.mat_x;
      handles.Aheader.model.mat_y = Am.mat_y;

      set_widgets( handles );
      
      y = Am.mat_y / handles.Aheader.model.bins;
      if int16(y) * handles.Aheader.model.bins  == Am.mat_y
        str = short_path(handles.Aheader.model.path, ndir);
      else
        str = ['Dimension Mismatch : A ' num2str( Am.mat_x ) 'x' num2str(Am.mat_y) ];
      end
      
    else
      Am = who_stats( path, fn, 'A' );
   
      if ~Am.mat_exists == 1
        mat_vars = matfile_vars( '', [path fn] );
        if size(mat_vars, 1 ) > 1
          lst = '';
          for ii=1:size(mat_vars, 1 )
            lst = horzcat( lst, {[mat_vars(ii).name ' : ' num2str(mat_vars(ii).sz_x) 'x' num2str(mat_vars(ii).sz_y)]});
          end

          x = mat_selection( lst );
          Am = who_stats( path, fn, mat_vars(x).name );
        else
          Am = who_stats( path, fn, mat_vars(1).name );
        end
        
        handles.Aheader.model.id = Am.mat;

      end
      
      Am.each = 1;
       
      str = [path fn];
      str = short_path(str, ndir);

      x = str2num( get( handles.txt_NumBins, 'String' ) );
      y = Am.mat_y / x;
        
      if int16(y) * x == Am.mat_y
        handles.Aheader.model.mat_x = Am.mat_x;
        handles.Aheader.model.mat_y = Am.mat_y;
        handles.Aheader.model.path  = Am.path;
        handles.Aheader.model.var   = Am.mat;
        handles.Aheader.model.contrasts = y;
      else
        str = ['Dimension Mismatch : A ' num2str( Am.mat_x ) 'x' num2str(Am.mat_y) ];
      end;
        
    end;
  
  end;
  
  set( handles.lbl_AMatrix, 'String', str );
  
  % Update handles structure
  guidata(hObject, handles);

  set_widgets( handles );

  

% --- Executes on button press in btn_Okay.
function btn_Okay_Callback(hObject, eventdata, handles)

  handles.output = handles.Aheader;
  % Update handles structure
  guidata(hObject, handles);
  uiresume(handles.figure1);


% --- Executes on button press in btn_Cancel.
function btn_Cancel_Callback(hObject, eventdata, handles)

  handles.output = [];
  % Update handles structure
  guidata(hObject, handles);
  uiresume(handles.figure1);



function txt_ID_Callback(hObject, eventdata, handles)

  handles.Aheader.model.id = get( hObject, 'String' );
  guidata(hObject, handles);
  set_widgets( handles );
  

% --- Executes during object creation, after setting all properties.
function txt_ID_CreateFcn(hObject, eventdata, handles)

  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end


% --- Executes on button press in btn_add_description.
function btn_add_description_Callback(hObject, eventdata, handles)

  Descr = inputdlg('Enter the Contrast Description','Description', 1, {handles.Aheader.model.descr} );
  if ( ~isempty( Descr ) ) 
    handles.Aheader.model.descr = char(Descr);
    guidata(hObject, handles);
    set_widgets( handles );
  end
    

