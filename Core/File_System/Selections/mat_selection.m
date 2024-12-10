function varargout = mat_selection( selection_list, title )
% mat_selection: Select a Z matrix from the pop-up menu
global selected_mat

  selected_mat = 0;

  % a default list
  if nargin < 2
    title = 'Select Z matrix';
    if nargin == 0
      selection_list = {'N/A'};
    end;
  end;

  varargout{1} = '';

  %  Initialize and hide the GUI as it is being constructed.
  f = figure('Visible','off','Position',[360,500,250,100]);
  set( f, 'Tag', 'mat_selection' );
  pcbh = findobj('Tag', 'mat_selection' );

  handles.f = f;
  handles.pcbh = pcbh;
  handles.pbh = 0;
  handles.hpopup = 0;
  handles.output = 0;

  guidata(f, handles);
  
  hpopup = uicontrol('Style','popupmenu',...
    'String',selection_list,...
    'Position',[30,40,200,50], ...
    'Callback',{@selectbox_Callback,handles});

  handles.hpopup = hpopup;
  guidata(f, handles);

  pbh = uicontrol(f,'Style','pushbutton', ...
    'String','Okay',...
    'Position',[30,15,200,30] );  % , ...

  handles.pbh = pbh;
  guidata(f, handles);

  set( pbh, 'Callback', {@okay_Callback,handles});

  set( f, 'MenuBar', 'none' );
  set( f, 'Name', title );
  set( f, 'NumberTitle', 'off' );
  movegui( f, 'center' );

  % make the gui visible
  set( f, 'Visible', 'on' );

  % Make the GUI modal
  set(f,'WindowStyle','modal');

  selectbox_Callback( handles.hpopup, [], handles );

  % UIWAIT makes dialog wait for user response (see UIRESUME)
  uiwait(handles.f);

  varargout{1} = selected_mat; 	

  try 
    delete(handles.f); 
  catch 
  end;





function selectbox_Callback(hObject,eventdata,handles) 
global selected_mat;

  selected_mat = get(hObject,'Value');


function okay_Callback(hObject,eventdata, handles)
  uiresume( handles.f);


function figure1_CloseRequestFcn(hObject, eventdata, handles)
global selected_mat;

  selected_mat = 0;
  uiresume(handles.f);






