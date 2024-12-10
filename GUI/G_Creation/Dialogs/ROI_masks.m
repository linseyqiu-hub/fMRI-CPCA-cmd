function varargout = ROI_masks(varargin)
% ROI_MASKS M-file for ROI_masks.fig
%      ROI_MASKS, by itself, creates a new ROI_MASKS or raises the existing
%      singleton*.
%
%      H = ROI_MASKS returns the handle to a new ROI_MASKS or the handle to
%      the existing singleton*.
%
%      ROI_MASKS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ROI_MASKS.M with the given input arguments.
%
%      ROI_MASKS('Property','Value',...) creates a new ROI_MASKS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ROI_masks_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ROI_masks_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ROI_masks

% Last Modified by GUIDE v2.5 25-Oct-2010 13:13:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ROI_masks_OpeningFcn, ...
                   'gui_OutputFcn',  @ROI_masks_OutputFcn, ...
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


% --- Executes just before ROI_masks is made visible.
function ROI_masks_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ROI_masks (see VARARGIN)

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

  handles.maskfile = '';
  handles.images = [];
  handles.opdir = pwd;

  lst = {};
  set( handles.lst_roi_files, 'String', lst );
  set( handles.btn_combine, 'Enable', 'Off' );
  set( handles.btn_okay, 'Enable', 'Off' );
  set( handles.lbl_region_count, 'String', '' );
  set( handles.lbl_voxel_count, 'String', '' );
  set( handles.txt_location, 'String', '' );

%  m = abs(diag(handles.scan_information.raw_data.img.vol.mat(1:3,1:3)));
  m = handles.scan_information.raw_data.header.pixdim(2:4); 

  str = sprintf( 'dim: %d %d %d (%dx%dx%d)',  ...
   handles.scan_information.raw_data.header.pixdim(2), ...
   handles.scan_information.raw_data.header.pixdim(3), ...
   handles.scan_information.raw_data.header.pixdim(4), ...
   m(1), m(2), m(3) );
  set( handles.lbl_list_title, 'String', str );

  opd = short_path( handles.opdir, 4);
  set( handles.txt_location, 'String', opd );


  % Choose default command line output for ROI_masks
  handles.output = handles.maskfile;

  % Update handles structure
  guidata(hObject, handles);

  % UIWAIT makes ROI_masks wait for user response (see UIRESUME)
  uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ROI_masks_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  % Get default command line output from handles structure
  varargout{1} = handles.maskfile;
  delete(handles.figure1);


% --- Executes on selection change in lst_roi_files.
function lst_roi_files_Callback(hObject, eventdata, handles)
% hObject    handle to lst_roi_files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns lst_roi_files contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lst_roi_files


% --- Executes during object creation, after setting all properties.
function lst_roi_files_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_roi_files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_add_files.
function btn_add_files_Callback(hObject, eventdata, handles)
% hObject    handle to btn_add_files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  [fn, path] = uigetfile( ...
    {'*.img;*.;*.nii','Image Files (*.img,*.;*.nii)'}, ...
    'Select your Regions of Interest', ...
    'MultiSelect','on');

  images_added = [];

  if ~isequal(fn,0) 

    if ( iscell(fn) )
      for ( ii = 1:size(fn, 2) )		% --- each selected mask file in that location
        fnm = [ path char(fn(ii))];
        roimsk = cpca_read_vol( fnm );

        roimsk.ind = find( roimsk.image);

        msk.file = char(fn(ii));
        msk.path = path;
        msk.dim = roimsk.vol.dim;
        msk.pixdim = abs(diag(roimsk.vol.mat(1:3,1:3)))';
        msk.voxels = size(roimsk.ind,1);

        images_added = [images_added; msk];

      end;
    else

      fnm = [ path char(fn)]
      roimsk = cpca_read_vol( fnm );

      roimsk.ind = find( roimsk.image);

      msk.file = char(fn);
      msk.path = path;
      msk.dim = roimsk.vol.dim;
      msk.pixdim = abs(diag(roimsk.vol.mat(1:3,1:3)))';
      msk.voxels = size(roimsk.ind,1);

      images_added = [images_added; msk];

    end;

    handles.images = [handles.images; images_added];
    % Update handles structure
    guidata(hObject, handles);

    update_image_list( handles.lst_roi_files, 0, handles );

  end;



function update_image_list( hObject, eventdata, handles );
%  content = get(hObject, 'String' )
  cidx = get(hObject, 'Value' );

  filecount = 0;
  voxcount = 0;

  lst = [];
  for ( ii = 1:size(handles.images,1) )

    fn = [handles.images(ii).path handles.images(ii).file];
    fn = short_path(fn, 2);

    filecount = filecount + 1;
    voxcount = voxcount + handles.images(ii).voxels;

%    flags = '   ';
%    if any( handles.images(ii).dim ~= handles.scan_information.raw_data.img.vol.dim  )
%      flags(1) = '*';
%    end;
    mdim = sprintf( '%d %d %d', ...
     handles.images(ii).dim(1), handles.images(ii).dim(2), handles.images(ii).dim(3) );

    msz = sprintf( ' (%dx%dx%d)', ...
     handles.images(ii).pixdim(1), handles.images(ii).pixdim(2), handles.images(ii).pixdim(3) );

%    m = abs(diag(handles.scan_information.raw_data.img.vol.mat(1:3,1:3)))';
%    if any( handles.images(ii).pixdim ~= m )
%      flags(2) = '=';
%    end;

    vcnt = sprintf( ' %4d ', handles.images(ii).voxels );

    str = [mdim msz vcnt fn];
    lst = [lst; {str}];

  end;

  if ( size( lst,1) < cidx )
    cidx = size( lst,1);
  end

  set( handles.lst_roi_files, 'String', lst, 'Value', cidx );
  str = '';
  if ( filecount > 0 ) str = [ num2str(filecount) ' Regions.'];  end;
  set( handles.lbl_region_count, 'String', str );

  str = '';
  if ( voxcount > 0 ) str = [ num2str(voxcount) ' Voxels.'];  end;
  set( handles.lbl_voxel_count, 'String', str );

  if ( filecount > 0 ) 
    set( handles.btn_combine, 'Enable', 'on');
  else
    set( handles.btn_combine, 'Enable', 'off');
  end;


% --- Executes on button press in btn_combine.
function btn_combine_Callback(hObject, eventdata, handles)
% hObject    handle to btn_combine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  pth = get(handles.txt_location, 'String' );
  fn  = get(handles.txt_mask_name, 'String' );
  filename = [ handles.opdir filesep fn ]

  for ii = 1:size( handles.images, 1)

    fnm = [ handles.images(ii).path char(handles.images(ii).file)];
    roimsk = cpca_read_vol( fnm );

    if ( ii == 1 )  
      msk = roimsk; 
      msk.image = zeros( prod( msk.vol.dim ), 1);	% --- storage area for finale written image --
    end;

    roimsk.ind = find( roimsk.image);
    msk.image( roimsk.ind ) = 1;
  end;

  msk.image = reshape( msk.image ,msk.vol.dim);		% --- and reshaping the result to the mask volume dimensions ---

  dtyp = cpca_data_type( 'double' );
  src_prec = dtyp.analyse;
  if length( src_prec ) == 0
    src_prec = dtyp.nifti;
  end;
  if isBigendian()  en = 'LE'; else en = 'BE'; end;
  dtype = [src_prec '-' en];

  msk.vol.dt = [dtyp.conversion isBigendian()];			% we default data type to signed double (float 64 )
  msk.header.datatype = dtyp.conversion;
  msk.header.bitpix = dtyp.bits;
  msk.vol.fname = filename;

  if isfield( msk.header, 'scl_slope')
    msk.header.scl_slope = 1;
  end;
    
  msk.vol.pinfo(1) = 1;
  msk.vol.private.dat.dtype = dtype;

  err = cpca_write_vols( msk );
  if ( ~isempty( err ) )
    show_message( 'Error Writing Image', err );
    return;
  end;

  xx = exist( filename, 'file');
  if xx == 2
    str = ['The ROI mask (' fn ') has been created.'];
    show_message( 'ROI Mask Created',str );
  end;

  set( handles.btn_okay, 'Enable', 'on' );

% --- Executes on button press in btn_okay.
function btn_okay_Callback(hObject, eventdata, handles)
% hObject    handle to btn_okay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  fn  = get(handles.txt_mask_name, 'String' );
  handles.maskfile = [ handles.opdir filesep fn ];
  guidata(hObject, handles);
  uiresume(handles.figure1);


% --- Executes on button press in btn_cancel.
function btn_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to btn_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  handles.maskfile = '';
  uiresume(handles.figure1);


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


% --- Executes on button press in btn_browse_destination.
function btn_browse_destination_Callback(hObject, eventdata, handles)
% hObject    handle to btn_browse_destination (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  thisDir = uigetdir('', 'Select the output directory for the mask file');

  if ~isequal( thisDir, 0)
    handles.opdir = thisDir;
    opd = short_path( handles.opdir, 4);
    set( handles.txt_location, 'String', opd );
  end;


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.maskfile = '';
  uiresume(handles.figure1);


% --- Executes on key press with focus on lst_roi_files and none of its controls.
function lst_roi_files_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to lst_roi_files (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

  % -- Linux/PC: 'delete'  mac: 'backspace'
  if ismac()
    deletethis = strcmp( eventdata.Key, 'backspace' );
  else
    deletethis = strcmp( eventdata.Key, 'delete' );
  end;


  if deletethis
    idx = get( handles.lst_roi_files, 'Value' );
    content = get( handles.lst_roi_files, 'String' );
    lst = {};

    new_images = [];

    for ii = 1:size( content, 1) 
      if ( ii ~= idx )
        lst = [lst; content(ii)];
        new_images = [new_images; handles.images(ii)];
      end;
    end;

    handles.images = new_images;

    if ( size( lst,1) < idx )
      idx = size( lst,1);
    end

%    set( handles.lst_roi_files, 'String', lst, 'Value', idx );
    % Update handles structure
    guidata(hObject, handles);
    update_image_list( handles.lst_roi_files, 0, handles );

  end;

