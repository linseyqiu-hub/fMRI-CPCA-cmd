function varargout = Z_path_repair(varargin)
% Z_PATH_REPAIR M-file for Z_path_repair.fig
%      Z_PATH_REPAIR, by itself, creates a new Z_PATH_REPAIR or raises the existing
%      singleton*.
%
%      H = Z_PATH_REPAIR returns the handle to a new Z_PATH_REPAIR or the handle to
%      the existing singleton*.
%
%      Z_PATH_REPAIR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in Z_PATH_REPAIR.M with the given input arguments.
%
%      Z_PATH_REPAIR('Property','Value',...) creates a new Z_PATH_REPAIR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Z_path_repair_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Z_path_repair_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Z_path_repair

% Last Modified by GUIDE v2.5 26-Nov-2012 09:19:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Z_path_repair_OpeningFcn, ...
                   'gui_OutputFcn',  @Z_path_repair_OutputFcn, ...
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


% --- Executes just before Z_path_repair is made visible.
function Z_path_repair_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Z_path_repair (see VARARGIN)
global Zheader scan_information ;

  [handles.Zheader, handles.scan_information] = adjust_headers( Zheader, scan_information, Zheader.Z_Directory );

  if ispc
    handles.dir_char = '\';
    this_from = '/';
    this_to = '\';
  else
    handles.dir_char = '/';
    this_to = '/';
    this_from = '\';
  end;

  handles.Zheader.Z_File.directory = strrep( handles.Zheader.Z_File.directory, this_from, this_to);	
  handles.Zheader.Z_Directory      = strrep( handles.Zheader.Z_Directory, this_from, this_to);
  handles.Zheader.Z_Original       = strrep( handles.Zheader.Z_Original, this_from, this_to);
  handles.Zheader.Model.path       = strrep( handles.Zheader.Model.path, this_from, this_to);
  handles.Zheader.P.path           = strrep( handles.Zheader.P.path, this_from, this_to);
  handles.Zheader.D.path           = strrep( handles.Zheader.D.path, this_from, this_to);
  handles.Zheader.Contrast.path    = strrep( handles.Zheader.Contrast.path, this_from, this_to);
  handles.Zheader.Limits.path      = strrep( handles.Zheader.Limits.path, this_from, this_to);

  if(nargin > 3)
    for index = 1:2:(nargin-3),
      if nargin-3==index, break, end
        switch lower(varargin{index})
         case 'path'
          handles.zpath = varargin{index+1};
      end
    end
  end

  
  if ismac()
    pos = get(handles.txt_Z_Loc, 'Position' );
    set( handles.txt_Z_Loc, 'Position', [pos(1) pos(2) pos(3) 1.75] );

    pos = get(handles.txt_Mask, 'Position' );
    set( handles.txt_Mask, 'Position', [pos(1) pos(2) pos(3) 1.75] );

    pos = get(handles.txt_G_Loc, 'Position' );
    set( handles.txt_G_Loc, 'Position', [pos(1) pos(2) pos(3) 1.75] );

    pos = get(handles.txt_GS_Loc, 'Position' );
    set( handles.txt_GS_Loc, 'Position', [pos(1) pos(2) pos(3) 1.75] );

    pos = get(handles.txt_G_applied, 'Position' );
    set( handles.txt_G_applied, 'Position', [pos(1) pos(2) pos(3) 1.75] );

    pos = get(handles.txt_GZ_Loc, 'Position' );
    set( handles.txt_GZ_Loc, 'Position', [pos(1) pos(2) pos(3) 1.75] );

    pos = get(handles.txt_H_Loc, 'Position' );
    set( handles.txt_H_Loc, 'Position', [pos(1) pos(2) pos(3) 1.75] );

    pos = get(handles.txt_HS_Loc, 'Position' );
    set( handles.txt_HS_Loc, 'Position', [pos(1) pos(2) pos(3) 1.75] );

  end;
  
  handles.badpath = handles.Zheader.Z_Directory;
  handles.Gheader = structure_define( 'GHEADER' );
  handles.Gheader.GZheader = structure_define( 'GZHEADER' );
  handles.Hheader = structure_define( 'HHEADER' );
  
  txt = get_short_path( handles.zpath, 50 );
  set( handles.txt_Z_Loc, 'String', txt );
  set( handles.txt_G_applied, 'String', txt );

  handles.mpath = strrep( handles.scan_information.mask.file, handles.badpath, handles.zpath );
  txt = get_short_path( handles.mpath, 50 );
  set( handles.txt_Mask, 'String', txt );

  handles.gpath = strrep( handles.Zheader.Model.path, handles.badpath, handles.zpath );
  txt = get_short_path( handles.gpath, 50 );
  set( handles.txt_G_Loc, 'String', txt );

  xx = exist( handles.gpath, 'file' );
  if ( xx ~= 2 )
    set( handles.chk_accept_G, 'Value', 0 );
    set( handles.chk_accept_G, 'Enable', 'off' );

  else
    [Gpath, Gfile] = split_path( handles.gpath, handles.dir_char );
    xx = who_stats( Gpath, Gfile, 'Gheader' );
    if ( ~xx.mat_exists )
      set( handles.chk_accept_G, 'Value', 0 );
      set( handles.chk_accept_G, 'Enable', 'off' );

      set( handles.chk_accept_GS, 'Value', 0 );
      set( handles.chk_accept_GS, 'Enable', 'off' );
    else
      eval( [ 'load( ''' handles.gpath ''', ''Gheader'');' ] );
      Gheader.path_to_segs = [Gpath 'Gsegs' filesep];
      Gheader.applied_to = handles.zpath;
      Gheader.GZheader.path_to_segs = [Gpath 'GZsegs' filesep];
      handles.Gheader = Gheader;
    end;
  end;

  handles.gspath = update_G_Segs( handles );
  handles.gzpath = update_GZ_Segs( handles );
  handles.Gheader.GZheader.path_to_segs = handles.gzpath;
  
  handles.hspath = '';
  if ~isempty(  handles.Zheader.Limits.path )
    handles.hspath = update_H_Segs( handles );
%    handles.Hheader.path_to_segs = handles.hspath;
%  else
%    handles.Hheader.model(1).path_to_segs = handles.hspath;
  end;
  
  handles.hpath = strrep( handles.Zheader.Limits.path, handles.badpath, handles.zpath );
  txt = get_short_path( handles.hpath, 50 );
  set( handles.txt_H_Loc, 'String', txt );

  
  xx = exist( handles.hpath, 'file' );
  if ( xx ~= 2 )
    set( handles.chk_accept_H, 'Value', 0 );
    set( handles.chk_accept_H, 'Enable', 'off' );

  else
    [Hpath, Hfile] = split_path( handles.hpath, handles.dir_char );
    xx = who_stats( Hpath, Hfile, 'Hheader' );
    if ( ~xx.mat_exists )
      set( handles.chk_accept_H, 'Value', 0 );
      set( handles.chk_accept_H, 'Enable', 'off' );

      set( handles.chk_accept_HS, 'Value', 0 );
      set( handles.chk_accept_HS, 'Enable', 'off' );
    else
      eval( [ 'load( ''' handles.hpath ''', ''Hheader'');' ] );
      handles.Hheader = Hheader;
      for ii = 1:size( handles.Hheader.model, 1 )
        handles.Hheader.model(ii).path = strrep( handles.Hheader.model(ii).path, handles.badpath, handles.zpath );
      end;
%      xx = exist( [handles.Hheader.path handles.Hheader.file], 'file' );
%      if ( xx == 2 )
        txt = get_short_path( [handles.Hheader.model(1).path handles.Hheader.model(1).file], 50 );
        set( handles.txt_HS_Loc, 'String', txt );
%      end;

    end;
  end;

  % Choose default command line output for Z_path_repair
  handles.output = hObject;

  % Update handles structure
  guidata(hObject, handles);

  % UIWAIT makes Z_path_repair wait for user response (see UIRESUME)
  uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Z_path_repair_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
  varargout{1} = handles.output;
  varargout{2} = handles.output2;
  varargout{3} = handles.output3;
  varargout{4} = handles.output4;
  delete(handles.figure1);


% --- Executes on button press in btn_okay.
function btn_okay_Callback(hObject, eventdata, handles)
% hObject    handle to btn_okay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  main_accept = get( handles.chk_accept_Z, 'Value' );

  if( main_accept )
    handles.Zheader.Z_Directory = handles.zpath;
%  end

    accept = get( handles.chk_accept_mask, 'Value' );
    if( accept )
      handles.scan_information.mask.file = handles.mpath;
    end

    accept = get( handles.chk_accept_G, 'Value' );
    if( accept )
      handles.Zheader.Model.path = handles.gpath;
    end

    accept = get( handles.chk_accept_GS, 'Value' );
    if( accept )
      handles.Gheader.path_to_segs = handles.gspath;
      a = get( handles.chk_accept_G_applied, 'Value' );
      if( a )
        handles.Gheader.applied_to = handles.zpath;
      end;
    end

    accept = get( handles.chk_accept_GZ, 'Value' );
    if( accept )
      handles.Gheader.GZheader.path_to_segs = handles.gzpath;
    end

    accept = get( handles.chk_accept_H, 'Value' );
    if( accept )
      handles.Zheader.Limits.path = handles.hpath;
    end
 
    accept = get( handles.chk_accept_HS, 'Value' );
    if( accept )
      handles.Hheader.path_to_segs = handles.hspath;
    end
    
  end;

  handles.output = handles.Zheader;
  handles.output2 = handles.scan_information;
  handles.output3 = handles.Gheader;
  handles.output4 = handles.Hheader;
  guidata(handles.figure1, handles);
  uiresume(handles.figure1);


% --- Executes on button press in btn_Cancel.
function btn_Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  handles.output = '';
  handles.output2 = '';
  handles.output3 = '';
  handles.output4 = '';
  guidata(handles.figure1, handles);
  uiresume(handles.figure1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.output = '';
  handles.output2 = '';
  handles.output3 = '';
  handles.output4 = '';
  guidata(handles.figure1, handles);
  uiresume(handles.figure1);




function txt_Z_Loc_Callback(hObject, eventdata, handles)
% hObject    handle to txt_Z_Loc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_Z_Loc as text
%        str2double(get(hObject,'String')) returns contents of txt_Z_Loc as a double


% --- Executes during object creation, after setting all properties.
function txt_Z_Loc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_Z_Loc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_G_Loc_Callback(hObject, eventdata, handles)
% hObject    handle to txt_G_Loc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_G_Loc as text
%        str2double(get(hObject,'String')) returns contents of txt_G_Loc as a double


% --- Executes during object creation, after setting all properties.
function txt_G_Loc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_G_Loc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_browse_G.
function btn_browse_G_Callback(hObject, eventdata, handles)
% hObject    handle to btn_browse_G (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  fullpath = select_file( {'*.mat;','G Matrix'}, ...
                                   'Select your G matrix.');

  if ~isequal( fullpath, 0)
    [Gpath, Gfile] = split_path( fullpath, handles.dir_char );
    xx = who_stats( Gpath, Gfile, 'Gheader' );
    if ( ~xx.mat_exists )
      set( handles.chk_accept_G, 'Value', 0 );
      set( handles.chk_accept_G, 'Enable', 'off' );

      set( handles.chk_accept_GS, 'Value', 0 );
      set( handles.chk_accept_GS, 'Enable', 'off' );
    else
      handles.gpath = fullpath;
      eval( [ 'load( ''' fullpath ''', ''Gheader'');' ] );
      handles.Gheader = Gheader;

      handles.Zheader.Model.path = handles.gpath;
      handles.Zheader.Model.mat_exists = 0;
      handles.Zheader.Model.mat = '';
      handles.Zheader.Model.mat_x = handles.Zheader.total_scans;
      handles.Zheader.Model.mat_y = Gheader.conditions * Gheader.bins * handles.Zheader.num_subjects;
      handles.Zheader.Model.hdr_exists = 1;

    end;

    handles.gzpath = update_GZ_Segs( handles );
    handles.Gheader.GZheader.path_to_segs = handles.gzpath;

    % Update handles structure
    guidata(hObject, handles);

    str = get_short_path( handles.gpath, 50 );
    set( handles.txt_G_Loc, 'String', str );

    handles.gspath = update_G_Segs( handles );

    guidata(handles.figure1, handles);
    drawnow();
  end



% --- Executes on button press in chk_accept_G.
function chk_accept_G_Callback(hObject, eventdata, handles)
% hObject    handle to chk_accept_G (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_accept_G



function txt_GS_Loc_Callback(hObject, eventdata, handles)
% hObject    handle to txt_GS_Loc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_GS_Loc as text
%        str2double(get(hObject,'String')) returns contents of txt_GS_Loc as a double


% --- Executes during object creation, after setting all properties.
function txt_GS_Loc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_GS_Loc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_browse_GS.
function btn_browse_GS_Callback(hObject, eventdata, handles)
% hObject    handle to btn_browse_GS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  dirname = uigetdir('', 'Select the Directory of your G segments');

  if ~isequal( dirname, 0)
    handles.gspath = [ dirname handles.dir_char];
    handles.Gheader.path_to_segs = handles.gspath;
    guidata(handles.figure1, handles);

    handles.gzpath = update_GZ_Segs( handles );
    handles.Gheader.GZheader.path_to_segs = handles.gzpath;

    guidata(handles.figure1, handles);
    drawnow();
  end


% --- Executes on button press in chk_accept_GS.
function chk_accept_GS_Callback(hObject, eventdata, handles)
% hObject    handle to chk_accept_GS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_accept_GS



function txt_G_applied_Callback(hObject, eventdata, handles)
% hObject    handle to txt_G_applied (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_G_applied as text
%        str2double(get(hObject,'String')) returns contents of txt_G_applied as a double


% --- Executes during object creation, after setting all properties.
function txt_G_applied_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_G_applied (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chk_accept_G_applied.
function chk_accept_G_applied_Callback(hObject, eventdata, handles)
% hObject    handle to chk_accept_G_applied (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_accept_G_applied



function txt_GZ_Loc_Callback(hObject, eventdata, handles)
% hObject    handle to txt_GZ_Loc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_GZ_Loc as text
%        str2double(get(hObject,'String')) returns contents of txt_GZ_Loc as a double


% --- Executes during object creation, after setting all properties.
function txt_GZ_Loc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_GZ_Loc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_browse_GZ.
function btn_browse_GZ_Callback(hObject, eventdata, handles)
% hObject    handle to btn_browse_GZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  dirname = uigetdir('', 'Select the Directory of your GZ segments');

  if ~isequal( dirname, 0)
    handles.gzpath = [ dirname handles.dir_char];
    handles.Gheader.GZheader.path_to_segs = handles.gzpath;
    guidata(handles.figure1, handles);

    guidata(handles.figure1, handles);
    drawnow();
  end



% --- Executes on button press in chk_accept_GZ.
function chk_accept_GZ_Callback(hObject, eventdata, handles)
% hObject    handle to chk_accept_GZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_accept_GZ



% --- Executes on button press in btn_browse_Z.
function btn_browse_Z_Callback(hObject, eventdata, handles)
% hObject    handle to btn_browse_Z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  dirname = uigetdir('', 'Select the Directory of your Z data');

  if ~isequal( dirname, 0)
    handles.zpath = [ dirname handles.dir_char];
    txt = get_short_path( handles.zpath, 50 );
    set( handles.txt_Z_Loc, 'String', txt );
    guidata(handles.figure1, handles);

    drawnow();
  end


% --- Executes on button press in chk_accept_Z.
function chk_accept_Z_Callback(hObject, eventdata, handles)
% hObject    handle to chk_accept_Z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  state = 'off';
  val = 0;
  x = get(hObject,'Value');
  if ( x ) state = 'on';  end;

  set( handles.chk_accept_G, 'Enable', state );
  set( handles.chk_accept_GS, 'Enable', state );
  set( handles.chk_accept_G_applied, 'Enable', state );
  set( handles.chk_accept_GZ, 'Enable', state );

  if ( x == 0 ) 
    set( handles.chk_accept_G, 'Value', 0 );
    set( handles.chk_accept_GS, 'Value', 0 );
    set( handles.chk_accept_GZ, 'Value', 0 );
    set( handles.chk_accept_G_applied, 'Value', 0 );
    set( handles.chk_G_applied, 'Value', 0 );
  end;


function txt = get_short_path( path, minlen )

  psegs = 7;
  txt = short_path( path, psegs );
  while ( length(txt) > minlen & psegs > 1 )
    psegs = psegs - 1 ;
    txt = short_path( path, psegs );
  end;



function gspath = update_G_Segs( handles )

  gspath = strrep( handles.Gheader.path_to_segs, handles.badpath, handles.zpath );
  txt = get_short_path( gspath, 50 );
  set( handles.txt_GS_Loc, 'String', txt );

  xx = exist( gspath, 'dir' );
  if ( xx ~= 7 )
    set( handles.chk_accept_GS, 'Value', 0 );
    set( handles.chk_accept_GS, 'Enable', 'off' );
  end;


  
function hspath = update_H_Segs( handles )

  hspath = strrep( handles.Hheader.model(1).path_to_segs, handles.badpath, handles.zpath );
  txt = get_short_path( hspath, 50 );
  set( handles.txt_HS_Loc, 'String', txt );

  xx = exist( hspath, 'dir' );
  if ( xx ~= 7 )
    set( handles.chk_accept_HS, 'Value', 0 );
    set( handles.chk_accept_HS, 'Enable', 'off' );
  end;
  
  
function gzpath = update_GZ_Segs( handles )
  gzpath = '';

  if isfield( handles.Gheader.GZheader, 'path_to_segs' )
    gzpath = strrep( handles.Gheader.GZheader.path_to_segs, handles.badpath, handles.zpath );
    txt = get_short_path( gzpath, 50 );
    set( handles.txt_GZ_Loc, 'String', txt );

    xx = exist( gzpath, 'dir' );
    if ( xx ~= 7 )
      set( handles.chk_accept_GZ, 'Value', 0 );
      set( handles.chk_accept_GZ, 'Enable', 'off' );
    end;

  end;
  


function txt_Mask_Callback(hObject, eventdata, handles)
% hObject    handle to txt_Mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_Mask as text
%        str2double(get(hObject,'String')) returns contents of txt_Mask as a double


% --- Executes during object creation, after setting all properties.
function txt_Mask_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_Mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_browse_mask.
function btn_browse_mask_Callback(hObject, eventdata, handles)
% hObject    handle to btn_browse_mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  fullpath = select_file( {'*.img;*.nii;','image file'}, ...
                                   'Select your Mask file.');

  if ~isequal( fullpath, 0)
    handles.mpath = fullpath;
  end;
  
  txt = get_short_path( handles.mpath, 50 );
  set( handles.txt_Mask, 'String', txt );

  guidata(handles.figure1, handles);
  drawnow();


% --- Executes on button press in chk_accept_mask.
function chk_accept_mask_Callback(hObject, eventdata, handles)
% hObject    handle to chk_accept_mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_accept_mask


% --- Executes on button press in chk_accept_all.
function chk_accept_all_Callback(hObject, eventdata, handles)
% hObject    handle to chk_accept_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_accept_all

  x = get( hObject, 'Value' );

  if ( x )

    set( handles.chk_accept_Z, 'Value', 1 );
    set( handles.chk_accept_mask, 'Value', 1 );
    set( handles.chk_accept_G, 'Value', 1 );
    set( handles.chk_accept_GS, 'Value', 1 );
    set( handles.chk_accept_G_applied, 'Value', 1 );
    set( handles.chk_accept_GZ, 'Value', 1 );
    set( handles.chk_accept_H, 'Value', 1 );
    set( handles.chk_accept_HS, 'Value', 1 );

  end;



function txt_H_Loc_Callback(hObject, eventdata, handles)
% hObject    handle to txt_H_Loc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_H_Loc as text
%        str2double(get(hObject,'String')) returns contents of txt_H_Loc as a double


% --- Executes during object creation, after setting all properties.
function txt_H_Loc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_H_Loc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_browse_H.
function btn_browse_H_Callback(hObject, eventdata, handles)
% hObject    handle to btn_browse_H (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  fullpath = select_file( {'*.mat;','H Matrix'}, ...
                                   'Select your H Header File.');

  if ~isequal( fullpath, 0)
    [Hpath, Hfile] = split_path( fullpath, handles.dir_char );
    xx = who_stats( Hpath, Hfile, 'Hheader' );
    if ( ~xx.mat_exists )
      set( handles.chk_accept_H, 'Value', 0 );
      set( handles.chk_accept_H, 'Enable', 'off' );

      set( handles.chk_accept_HS, 'Value', 0 );
      set( handles.chk_accept_HS, 'Enable', 'off' );
    else
      handles.hpath = fullpath;
      load( fullpath , 'Hheader');
      handles.Hheader.path = Hpath;
      handles.Hheader.file = Hfile;

      handles.Zheader.Limits.path = handles.hpath;
%      handles.Zheader.Limits.mat_exists = 0;
      handles.Zheader.Limits.mat = handles.Hheader.var;
      handles.Zheader.Limits.mat_x = handles.Hheader.size(1);
      handles.Zheader.Limits.mat_y = handles.Hheader.size(2);
      handles.Zheader.Limits.hdr_exists = 1;

    end;


    % Update handles structure
    guidata(hObject, handles);

    str = get_short_path( handles.hpath, 50 );
    set( handles.txt_H_Loc, 'String', str );

    handles.hspath = update_H_Segs( handles );

    guidata(handles.figure1, handles);
    drawnow();
  end


% --- Executes on button press in chk_accept_H.
function chk_accept_H_Callback(hObject, eventdata, handles)
% hObject    handle to chk_accept_H (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_accept_H



function txt_HS_Loc_Callback(hObject, eventdata, handles)
% hObject    handle to txt_HS_Loc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_HS_Loc as text
%        str2double(get(hObject,'String')) returns contents of txt_HS_Loc as a double


% --- Executes during object creation, after setting all properties.
function txt_HS_Loc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_HS_Loc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_browse_HS.
function btn_browse_HS_Callback(hObject, eventdata, handles)
% hObject    handle to btn_browse_HS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  dirname = uigetdir('', 'Select the Directory of your H segments');

  if ~isequal( dirname, 0)
    handles.hspath = [ dirname handles.dir_char];
    handles.Hheader.path_to_segs = handles.hspath;
    guidata(handles.figure1, handles);

    guidata(handles.figure1, handles);
    drawnow();
  end



% --- Executes on button press in chk_accept_HS.
function chk_accept_HS_Callback(hObject, eventdata, handles)
% hObject    handle to chk_accept_HS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_accept_HS


