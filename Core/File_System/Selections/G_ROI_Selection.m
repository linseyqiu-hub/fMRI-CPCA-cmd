function varargout = G_ROI_Selection(varargin)
% G_ROI_SELECTION MATLAB code for G_ROI_Selection.fig
%      G_ROI_SELECTION, by itself, creates a new G_ROI_SELECTION or raises the existing
%      singleton*.
%
%      H = G_ROI_SELECTION returns the handle to a new G_ROI_SELECTION or the handle to
%      the existing singleton*.
%
%      G_ROI_SELECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in G_ROI_SELECTION.M with the given input arguments.
%
%      G_ROI_SELECTION('Property','Value',...) creates a new G_ROI_SELECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before G_ROI_Selection_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to G_ROI_Selection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help G_ROI_Selection

% Last Modified by GUIDE v2.5 20-Jan-2014 13:18:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @G_ROI_Selection_OpeningFcn, ...
                   'gui_OutputFcn',  @G_ROI_Selection_OutputFcn, ...
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


% --- Executes just before G_ROI_Selection is made visible.
function G_ROI_Selection_OpeningFcn(hObject, eventdata, handles, varargin)
global Zheader

% Choose default command line output for G_ROI_Selection
handles.output = hObject;
handles.Rstruc = structure_define( 'GROI' );
handles.max_vox = Zheader.min_scans;

% Update handles structure
guidata(hObject, handles);

str = ['Maximum Allowed Voxels: ' num2str( handles.max_vox ) ];
set( handles.lbl_max_voxels, 'String', str);

set( handles.btn_Okay, 'Enable', 'off');



% UIWAIT makes G_ROI_Selection wait for user response (see UIRESUME)
 uiwait(handles.figure1);


 
 
% --- Outputs from this function are returned to the command line.
function varargout = G_ROI_Selection_OutputFcn(hObject, eventdata, handles) 

  varargout{1} = handles.output;
  guidata(handles.figure1, handles);
  delete(handles.figure1);


  
% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)

  handles.output = [];
  guidata(handles.figure1, handles);
  uiresume(handles.figure1);


  
% --- Executes on button press in btn_select_mask.
function btn_select_mask_Callback(hObject, eventdata, handles)

  handles.msk = [];
  
  [msk cancel] = select_mask_image('*.img;*.nii', 'Select your ROI mask');
  if ( cancel )
    set( handles.lbl_selected_mask, 'String', '' );
    set( handles.lbl_mask_voxels, 'String', 'Voxels in Mask: 0' );
    return
  end
  
  set( handles.lbl_selected_mask, 'String', msk.file );

  str = ['Voxels in Mask: ' num2str( msk.x ) ];
  set( handles.lbl_mask_voxels, 'String', str );
 
  s = get( handles.txt_ID, 'String' )
  if msk.x <= handles.max_vox & length(s) > 0 
    set( handles.btn_Okay, 'Enable', 'on');
  else
    set( handles.btn_Okay, 'Enable', 'off');
  end;
  
  handles.msk = msk;
  guidata(handles.figure1, handles);

  

function txt_ID_Callback(hObject, eventdata, handles)

  s = get( handles.txt_ID, 'String' )
  if handles.msk.x <= handles.max_vox & length(s) > 0 
    set( handles.btn_Okay, 'Enable', 'on');
  else
    set( handles.btn_Okay, 'Enable', 'off');
  end;




% --- Executes during object creation, after setting all properties.
function txt_ID_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_Descr_Callback(hObject, eventdata, handles)





% --- Executes during object creation, after setting all properties.
function txt_Descr_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in btn_Okay.
function btn_Okay_Callback(hObject, eventdata, handles)

%handles.msk

  handles.Rstruc.mask.image = handles.msk.file;
  handles.Rstruc.mask.desc = get( handles.txt_Descr, 'String' );
  handles.Rstruc.mask.id = get( handles.txt_ID, 'String' );
  handles.Rstruc.mask.size = [handles.msk.x handles.msk.y];
  
   
  handles.output = handles.Rstruc;
  guidata(hObject, handles);
  uiresume(handles.figure1);

  
  
% --- Executes on button press in btn_Cancel.
function btn_Cancel_Callback(hObject, eventdata, handles)

  handles.output = [];
  guidata(hObject, handles);
  uiresume(handles.figure1);

  
