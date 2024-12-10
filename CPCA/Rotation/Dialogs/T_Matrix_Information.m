function varargout = T_Matrix_Information(varargin)
% T_MATRIX_INFORMATION M-file for T_Matrix_Information.fig
%      T_MATRIX_INFORMATION, by itself, creates a new T_MATRIX_INFORMATION or raises the existing
%      singleton*.
%
%      H = T_MATRIX_INFORMATION returns the handle to a new T_MATRIX_INFORMATION or the handle to
%      the existing singleton*.
%
%      T_MATRIX_INFORMATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in T_MATRIX_INFORMATION.M with the given input arguments.
%
%      T_MATRIX_INFORMATION('Property','Value',...) creates a new T_MATRIX_INFORMATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before T_Matrix_Information_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to T_Matrix_Information_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help T_Matrix_Information

% Last Modified by GUIDE v2.5 12-Jan-2011 11:26:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @T_Matrix_Information_OpeningFcn, ...
                   'gui_OutputFcn',  @T_Matrix_Information_OutputFcn, ...
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


% --- Executes just before T_Matrix_Information is made visible.
function T_Matrix_Information_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to T_Matrix_Information (see VARARGIN)

  handles.T = [];
  handles.O = [];

  if(nargin > 3)
    for index = 1:2:(nargin-3),
        if nargin-3==index, break, end
        switch lower(varargin{index})
         case 't'
          handles.T = varargin{index+1};
         case 'o'
          handles.O = varargin{index+1};
        end
    end
  end

  tfmat = '';
  for ii = 1:size(handles.T,1)
    tmat = '';
    for jj = 1:size(handles.T,2)
      str = sprintf( ['\t' constant_define( 'PREFERENCES', 'precision.log' )], handles.T(ii,jj) );
      str2 = sprintf( '%10s', str );
      if ( length( tmat ) > 0 )
        tmat = [tmat '  ' str2 ];
      else
        tmat = str2;
      end;
    end;
    tfmat = [tfmat; {tmat} ];
  end;

  ofmat = '';
  ofmat = [{'Positive    avg      avg     Negative    avg      avg'}; ...
           {' voxels     beta     load     voxels     beta     load'}];

  for ii = 1:size(handles.O,1)
    omat = '';
    for jj = 1:size(handles.O,2)
      if ( jj == 1 | jj == 4 )
        str = sprintf( '%d', handles.O(ii,jj) );
%      str2 = sprintf( '%7s', str );
      else
        str = sprintf( '%.2f', handles.O(ii,jj) );
%      str2 = sprintf( '%7s', str );
      end;

      str2 = sprintf( '%7s', str );
      if ( length( omat ) > 0 )
        if ( jj == 4 )
          omat = [omat '    ' str2 ];
        else
          omat = [omat '  ' str2 ];
        end
      else
        omat = str2;
      end;
    end;
    ofmat = [ofmat; {omat} ];
  end;

  set( handles.txt_T_Matrix, 'String', tfmat );
  set( handles.txt_T_Orientation, 'String', ofmat );

% Choose default command line output for T_Matrix_Information
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes T_Matrix_Information wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = T_Matrix_Information_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
