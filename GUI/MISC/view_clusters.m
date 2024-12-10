function view_clusters(varargin)
% VIEW_CLUSTERS M-file for view_clusters.fig
%      VIEW_CLUSTERS, by itself, creates a new VIEW_CLUSTERS or raises the existing
%      singleton*.
%
%      H = VIEW_CLUSTERS returns the handle to a new VIEW_CLUSTERS or the handle to
%      the existing singleton*.
%
%      VIEW_CLUSTERS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIEW_CLUSTERS.M with the given input arguments.
%
%      VIEW_CLUSTERS('Property','Value',...) creates a new VIEW_CLUSTERS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before view_clusters_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to view_clusters_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help view_clusters

% Last Modified by GUIDE v2.5 11-Jan-2013 11:09:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @view_clusters_OpeningFcn, ...
                   'gui_OutputFcn',  @view_clusters_OutputFcn, ...
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


% --- Executes just before view_clusters is made visible.
function view_clusters_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to view_clusters (see VARARGIN)
global Zheader scan_information

  % ---------------------------
  % cluster information
  % ---------------------------
  handles.MNI = [];
  handles.filename = '';
  handles.cdir = '';
  if(nargin > 3)
    for index = 1:2:(nargin-3),
        if nargin-3==index, break, end
        switch lower(varargin{index})
         case 'clusters'
          handles.MNI = varargin{index+1};
         case 'file'
          handles.filename = varargin{index+1};
         case 'dir'
          handles.cdir = varargin{index+1};
        end
    end
  end


  str = [ 'Cluster Information' ];
  set( hObject, 'NumberTitle' , 'off' );
  set( hObject, 'Name', str );

  str = ['File: ' handles.filename];
  set( handles.txt_filename, 'String', str );

  show_cluster_summary( handles, Zheader.pct_threshold )
  show_cluster_list( handles, 0 );  % list all components;

  str = [];
  if isfield( handles.MNI, 'component' )		
    for ii = 1:size(Zheader.pct_value, 2 )
      str = [str; {[ 'top ' num2str(Zheader.pct_value(ii) ) '%']} ];
    end;
  else
    str = {[ num2str(Zheader.pct_value(Zheader.pct_threshold) ) '% of loadings']};
  end;
  set( handles.lst_thresholds, 'String', str, 'Value', Zheader.pct_threshold );


  if ( ismac )
    set( handles.txt_mask_name, 'HorizontalAlignment', 'center' );
    pos = get(handles.txt_mask_name, 'Position' );
    set( handles.txt_mask_name, 'Position', [pos(1) pos(2) pos(3) 1.75] );
  end;
  
  if Zheader.conditions.nonEncoded
    set( handles.btn_cluster_betas, 'Enable', 'off' );    % -- no Betas if any condition not encoded
  end;
  
% Choose default command line output for view_clusters
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes view_clusters wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = view_clusters_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = '';
%delete(handles.figure1);

% --- Executes on button press in btn_Close.
function btn_Close_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%  uiresume(handles.figure1);
delete(handles.figure1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
%  uiresume(handles.figure1);
delete(hObject);



% --- Executes on selection change in lst_cluster_summary.
function lst_cluster_summary_Callback(hObject, eventdata, handles)
% hObject    handle to lst_cluster_summary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns lst_cluster_summary contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lst_cluster_summary
  cno = get( hObject, 'Value' ) - 1;
  show_cluster_list( handles, cno );

% --- Executes during object creation, after setting all properties.
function lst_cluster_summary_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_cluster_summary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in lst_thresholds.
function lst_thresholds_Callback(hObject, eventdata, handles)
% hObject    handle to lst_thresholds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  thr = get(hObject, 'Value' );
  comp = get(handles.lst_cluster_summary, 'Value' );

  show_cluster_summary( handles, thr );
  set(handles.lst_cluster_summary, 'Value', comp );

  show_cluster_list( handles, thr );


% Hints: contents = cellstr(get(hObject,'String')) returns lst_thresholds contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lst_thresholds


% --- Executes during object creation, after setting all properties.
function lst_thresholds_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_thresholds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function show_cluster_summary( handles, thr )  % list all components;
global scan_information

  handles.tot_pos_clusters = 0;
  handles.tot_neg_clusters = 0;
  str = {};

  if isfield( handles.MNI, 'component' )		
    num_comps = size( handles.MNI.component,1) / max(scan_information.frequencies,1);
  else
    num_comps = size( handles.MNI,1) / max(scan_information.frequencies,1);
  end;

  for FrequencyNo = 1:max(scan_information.frequencies, 1)
    ftag = frequency_tag(FrequencyNo) ;

    for comp = 1:num_comps

      num_pos_clusters = 0;
      num_neg_clusters = 0;

      if isfield( handles.MNI, 'component' )		
        num_pos_clusters = num_pos_clusters + size( handles.MNI.component(comp).threshold(thr).pos,1);
        num_neg_clusters = num_neg_clusters + size( handles.MNI.component(comp).threshold(thr).neg,1);
      else
        num_pos_clusters = num_pos_clusters + size( handles.MNI(comp).pos,1); 
        num_neg_clusters = num_neg_clusters + size( handles.MNI(comp).neg,1); 
      end;

      ln = sprintf( '%.2d%s: clusters: %.3d [pos: %.3d neg: %.3d]', comp, ftag,(num_pos_clusters+num_neg_clusters), num_pos_clusters, num_neg_clusters);
      str = [str; {ln}];

      handles.tot_pos_clusters = handles.tot_pos_clusters + num_pos_clusters;
      handles.tot_neg_clusters = handles.tot_neg_clusters + num_neg_clusters;

    end;

  end;

  set( handles.lst_cluster_summary, 'String', str, 'Value', 1 );

  str = sprintf( ' clusters: %3d [pos: %3d neg: %3d]', (handles.tot_pos_clusters+handles.tot_neg_clusters), handles.tot_pos_clusters, handles.tot_neg_clusters);
  set( handles.txt_cluster_summary, 'String', str );


function show_cluster_list( handles, cmpno )  % list all components;
global Zheader scan_information

  num_voxels = 0;

  comp = get(handles.lst_cluster_summary, 'Value' );
  thr = get(handles.lst_thresholds, 'Value' );

  str = [];
  str_inc = [];
  str_exc = [];

  num_pos_clusters = 0;
  num_neg_clusters = 0;
  set( handles.btn_create_mask, 'Enable', 'off' );
  set( handles.btn_Create_H, 'Enable', 'off' );

  if isfield( handles.MNI, 'component' )		
    thisMNI = handles.MNI.component(comp).threshold(thr);
  else
    thisMNI = handles.MNI(comp );
  end;

  ext = '.img';
  if scan_information.mask.niiSingle   ext = '.nii';  end;

%  for cno = start_comp:end_comp 

    num_pos_clusters = num_pos_clusters + size( thisMNI.pos,1); 
    num_neg_clusters = num_neg_clusters + size( thisMNI.neg,1); 

% ---  #  voxels  mm^3   Peak Coords   Load
    if num_pos_clusters > 0 

      
      for clusterno = 1:size(  thisMNI.pos, 1 )

        voxels = thisMNI.pos(clusterno).voxels; 
        area = thisMNI.pos(clusterno).mm3;
        stat = '  ';
        if ( thisMNI.pos(clusterno).Masks.include == 1 ) 
          stat = ' >'; 
          ln = sprintf( '%3d %s %4d  %4d %5d', comp, 'pos', clusterno, voxels, area);
          str_inc = [str_inc; {ln}];
%          set( handles.btn_create_mask, 'Enable', 'on' );
          num_voxels = num_voxels + voxels;
        end;
        if ( thisMNI.pos(clusterno).Masks.exclude == 1 ) 
          stat = '< '; 
          ln = sprintf( '%3d %s %4d  %4d %5d', comp, 'pos', clusterno, voxels, area);
          str_exc = [str_exc; {ln}];
          num_voxels = num_voxels - voxels;
        end;
        vl = sprintf( '%-.5f', thisMNI.pos(clusterno).peak.value );
        ln = sprintf( '%s%3d %s  %4d   %4d    %5d  %4d %4d %4d   %8s', ...
          stat, comp, 'pos', clusterno, voxels, area, ...
          thisMNI.pos(clusterno).peak.mni(1), ...
          thisMNI.pos(clusterno).peak.mni(2), ...
          thisMNI.pos(clusterno).peak.mni(3), ...
          vl );
        str = [str; {ln}];
      end;
    end;

    if num_neg_clusters > 0 

      for clusterno = 1:size( thisMNI.neg, 1 )

        voxels = thisMNI.neg(clusterno).voxels; 
        area = thisMNI.neg(clusterno).mm3;
        stat = '  ';
        if ( thisMNI.neg(clusterno).Masks.include == 1 )
          stat = ' >'; 
          ln = sprintf( '%3d %s %4d  %4d %5d', comp, 'neg', clusterno, voxels, area);
          str_inc = [str_inc; {ln}];
%          set( handles.btn_create_mask, 'Enable', 'on' );
          num_voxels = num_voxels + voxels;
        end;
        if ( thisMNI.neg(clusterno).Masks.exclude == 1 )
          stat = '< '; 
          ln = sprintf( '%3d %s %4d  %4d %5d', comp, 'neg', clusterno, voxels, area);
          str_exc = [str_exc; {ln}];
          num_voxels = num_voxels - voxels;
        end;
        vl = sprintf( '%-.5f', thisMNI.neg(clusterno).peak.value );
        ln = sprintf( '%s%3d %s  %4d   %4d    %5d  %4d %4d %4d   %8s', ...
          stat, comp, 'neg', clusterno, voxels, area, ...
          thisMNI.neg(clusterno).peak.mni(1), ...
          thisMNI.neg(clusterno).peak.mni(2), ...
          thisMNI.neg(clusterno).peak.mni(3), ...
          vl );
        str = [str; {ln}];
      end;
    end;

%  end;


  set( handles.lst_clusters, 'String', str, 'Value', 1 );

  set( handles.lst_included, 'String', str_inc, 'Value', 1 );
%  set( handles.lst_excluded, 'String', str_exc, 'Value', 1 );

  num_voxels = max( num_voxels, 0 );
%  if ( num_voxels >= Zheader.Model.mat_y )
  if ( ~isempty( str_inc) )
    set( handles.btn_create_mask, 'Enable', 'on' );
    set( handles.btn_Create_H, 'Enable', 'on' );
  end;
  str = [ num2str( num_voxels) ' voxels selected' ];
  set( handles.lbl_mask_width, 'String', str );

  state = 'off';
  
  if size(str_inc,1) == 1
    state = 'on';
    pntext = ['Positive'; 'Negative'];
    [cno clno pn] = parse_include_exclude_item(str_inc);

    if ( pn == 1 )
      if isfield( handles.MNI, 'component' )	
        mnistr = num2str(handles.MNI.component(comp).threshold(thr).neg(clno).peak.mni);
      else
        mnistr = num2str(handles.MNI(comp).neg(clno).peak.mni);
      end;
    else
      if isfield( handles.MNI, 'component' )		
        mnistr = num2str(handles.MNI.component(comp).threshold(thr).pos(clno).peak.mni);
      else
        mnistr = num2str(handles.MNI(comp).pos(clno).peak.mni);
      end;
    end;

    mnistr = strrep( mnistr, ' ', '_');
    mnistr = strrep( mnistr, '__', '_');

    str = {[ pntext(pn+1,:) '_Cluster_' num2str(clno) '_MNI_' mnistr ext]};
    set( handles.txt_mask_name, 'String', str );
    set( handles.txt_mask_name, 'Enable', 'off' );

    set( handles.txt_H_File, 'String', [ pntext(pn+1,:) '_Cluster_' num2str(clno)] );
    set( handles.txt_H_ID, 'String', mnistr );

  else
    set( handles.txt_mask_name, 'String', {['cluster_mask' ext]}' );
    set( handles.txt_mask_name, 'Enable', 'on' );
    
    set( handles.txt_H_File, 'String', 'Multiple_Cluster' );
    set( handles.txt_H_ID, 'String', 'multi' );
    
  end

  if size(str_inc,1) > 0
    state = 'on';
  end;
  
  set( handles.txt_H_File, 'Enable', state );
  set( handles.txt_H_ID, 'Enable', state );
  set( handles.chk_by_cluster, 'Enable', state );
  if ~isempty( scan_information.mask.tal_index )
    set( handles.chk_by_talairach, 'Enable', state );
  end
      
      

% --- Executes on selection change in lst_clusters.
function lst_clusters_Callback(hObject, eventdata, handles)
% hObject    handle to lst_clusters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Zheader scan_information

  if strcmp(get(handles.figure1,'SelectionType'),'open')

      
    thresh_index = get(handles.lst_thresholds, 'Value' );

    idx = get(hObject,'Value');
    if ( idx > 0 )
        
      model = regexp( handles.filename, '_', 'split' );
      rotation = char(model(2));
      model = char(model(1));
      if model == 'G'
        load( Zheader.Model.path, 'Gheader' );
        if strcmp( rotation, 'unrotated' )
          rotation_params.method = 'unrotated';
          rotation_params.defaults = struct( 'empty', 1 );
          rotation_params.fs = 'unrotated';
          rotation_params.model = model;
       else
          rotation_params = locate_rotation( rotation );
          rotation_params.fs = 'rotated';
          rotation_params.htype = 'G';
          rotation_params.mode = '';
        end;
      else
        return;		% --- only plot G clusters for now
      end;
        
      contents = get(hObject,'String');
      for ii = 1:size(idx, 2 )
        selected_item = contents{ idx(ii)};

        c = regexp( char(selected_item), '\w+', 'match');
        cno = str2num(char(c(1)));
        clno = str2num(char(c(3)));
        if ( char(c(2)) == 'neg' ) pn = 1; else pn = 0; end;

        if ( pn == 1 )
          mni = handles.MNI.component(cno).threshold(thresh_index).neg(clno);
          posneg = 'Negative';
        else
          mni = handles.MNI.component(cno).threshold(thresh_index).pos(clno);
          posneg = 'Positive';
        end;

       
        rotation_params.thresh_index = thresh_index;
        rotation_params.threshold = global_threshold_value( rotation_params.thresh_index );
        rotation_params.defaults.cluster = sprintf('%03d', clno);
        rotation_params.defaults.posneg = posneg;
        rotation_params.defaults.component = cno;
        rotation_params.defaults.cluster = clno;
        

        nbins = calculate_nbins();
      
        Zindex = mni.Masks.Zindex;
        pk = num2str( mni.peak.mni );
        pkv = sprintf( '%.5f', mni.peak.value );
        if isfield( rotation_params, 'threshold' )
          mni_coords = [ 'Peak MNI: ' pk ' (' pkv ')  ' num2str( mni.mm3 ) ' cubic mm  @ ' num2str(rotation_params.threshold) '%' ];
        else
          mni_coords = [ 'Peak MNI: ' pk ' (' pkv ')  ' num2str( mni.mm3 ) ' cubic mm' ];
        end;

        Cn = [];
        C = [];
        for sn = 1:Zheader.num_subjects
          eval( [ 'load( ''' Gheader.GZheader.path_to_segs 'GC_S' num2str(sn) '.mat'', ''C_S' num2str(sn) ''');'] ); 
          eval( [ 'C = C_S' num2str(sn) '(:,Zindex(:));' ] );
          eval( [ 'clear  C_S' num2str(sn) ';' ] );

          % --- handle non encoded conditions
          Cm = mean(C,2);
          Cx = [];
          er = 0;
          for cond = 1:size(Zheader.conditions.Names, 2 )
            if isEncoded( sn, cond )
              sr = er + 1;
              er = sr + nbins - 1;
              Cx = [Cx; Cm(sr:er, :)];
            else
              Cx = [Cx; zeros(nbins, 1 )];
            end;

          end;
          Cn = [Cn Cx];
      
          clear C Cx Cm
        end;

        Cn = mean( Cn,2);

        graphdata = [];
        er = 0;
        for ii = 1:scan_information.processing.model.parameters.conditions
          sr = er + 1;
          er = sr + scan_information.processing.model.parameters.bins - 1;
          graphdata = [graphdata Cn(sr:er)];
        end

        h = figure; 
        plot( graphdata, '-' );

        minmax = min_max_limits( graphdata );
        fh = get(h, 'CurrentAxes' );
        set(fh,'YLim',minmax);
        set(fh,'XGrid','on'); 

        xtl = [0];
        for ii = 0:scan_information.processing.model.parameters.bins
          xtl = [xtl ii*scan_information.processing.model.parameters.TR];
        end;
        set( fh, 'XtickLabel', xtl )
        set( fh, 'Xtick', 0:scan_information.processing.model.parameters.bins );	% -=== [1.0.0]

        legend( Zheader.conditions.Names, 'Location', 'Best' );

        ttle = ['Betas Component ' num2str( rotation_params.defaults.component ) ' ' rotation_params.defaults.posneg ' Cluster  ' num2str( rotation_params.defaults.cluster ) ];
        title( mni_coords );
        set( h, 'NumberTitle' , 'off' );
        set( h, 'Name' , ttle );

        clear h
      end;

    end;
  end;
 


% --- Executes during object creation, after setting all properties.
function lst_clusters_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_clusters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function out = padstr(in, ln)
  if length(in) >= ln out = in; return; end;
  out = in;
  while length(out) < ln
    out = [' ' out];
  end;
return;

function cluster = set_include_exclude( adj )

  cluster = adj;  
 
  if ( cluster.include )		% --- this cluster is include - set to excluded
    cluster.include = 0;
%    cluster.exclude = 1;
    cluster.exclude = 0;        % --- exclusion to be removed
  else
%     if ( cluster.exclude )	% --- this cluster is excluded - set to neither
%       cluster.include = 0;
%       cluster.exclude = 0;
%     else
      cluster.include = 1;
      cluster.exclude = 0;
%    end;      
  end;      


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over lst_clusters.
function lst_clusters_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to lst_clusters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  if ( strcmp(get(handles.figure1,'SelectionType'), 'alt') )

    thr = get(handles.lst_thresholds, 'Value' );

    idx = get(hObject,'Value');
    if ( idx > 0 )
      contents = get(hObject,'String');
      selected_item = contents{get(hObject,'Value')};

      c = regexp( char(selected_item), '\w+', 'match');
      cno = str2num(char(c(1)));
      clno = str2num(char(c(3)));
      if ( char(c(2)) == 'neg' ) pn = 1; else pn = 0; end;

      if ( pn == 1 )
        if isfield( handles.MNI, 'component' )		
          handles.MNI.component(cno).threshold(thr).neg(clno).Masks = set_include_exclude( handles.MNI.component(cno).threshold(thr).neg(clno).Masks );
        else
          handles.MNI(cno).neg(clno).Masks = set_include_exclude( handles.MNI(cno).neg(clno).Masks );
        end;
      else
        if isfield( handles.MNI, 'component' )		
          handles.MNI.component(cno).threshold(thr).pos(clno).Masks = set_include_exclude( handles.MNI.component(cno).threshold(thr).pos(clno).Masks );
        else
          handles.MNI(cno).pos(clno).Masks = set_include_exclude( handles.MNI(cno).pos(clno).Masks );
        end
      end;      
      % Update handles structure
      guidata(handles.figure1, handles);

      show_cluster_list( handles, 0 );
      set( handles.lst_clusters, 'Value', idx );

    end;

  end;


% --- Executes on button press in btn_include_voxels.
function btn_include_voxels_Callback(hObject, eventdata, handles)
% hObject    handle to btn_include_voxels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  idx = get(handles.lst_clusters, 'Value');
  thr = get(handles.lst_thresholds, 'Value' );

  if ( size(idx,2) > 0 )
    contents = get(handles.lst_clusters,'String');

    for ii = 1:size(idx,2)
      selected_item = contents{idx(ii)};

      c = regexp( char(selected_item), '\w+', 'match');
      cno = str2num(char(c(1)));
      clno = str2num(char(c(3)));
      if ( strcmp( char(c(2)), 'neg' ) ) pn = 1; else pn = 0; end;

      if ( pn == 1 )
        if isfield( handles.MNI, 'component' )		
          handles.MNI.component(cno).threshold(thr).neg(clno).Masks.include = 1;
          handles.MNI.component(cno).threshold(thr).neg(clno).Masks.exclude = 0;
        else
          handles.MNI(cno).neg(clno).Masks.include = 1;
          handles.MNI(cno).neg(clno).Masks.exclude = 0;
        end;
      else
        if isfield( handles.MNI, 'component' )		
          handles.MNI.component(cno).threshold(thr).pos(clno).Masks.include = 1;
          handles.MNI.component(cno).threshold(thr).pos(clno).Masks.exclude = 0;
        else
          handles.MNI(cno).pos(clno).Masks.include = 1;
          handles.MNI(cno).pos(clno).Masks.exclude = 0;
        end;      
      end;      
   
    end;

    % Update handles structure
    guidata(handles.figure1, handles);

    show_cluster_list( handles, 0 );
    set( handles.lst_clusters, 'Value', idx );

  end;


% --- Executes on button press in btn_exclude_voxels.
function btn_exclude_voxels_Callback(hObject, eventdata, handles)
% hObject    handle to btn_exclude_voxels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  idx = get(handles.lst_clusters, 'Value');
  thr = get(handles.lst_thresholds, 'Value' );

  if ( size(idx,2) > 0 )
    contents = get(handles.lst_clusters,'String');

    for ii = 1:size(idx,2)
      selected_item = contents{idx(ii)};

      c = regexp( char(selected_item), '\w+', 'match');
      cno = str2num(char(c(1)));
      clno = str2num(char(c(3)));
      if ( char(c(2)) == 'neg' ) pn = 1; else pn = 0; end;

      if ( pn == 1 )
        if isfield( handles.MNI, 'component' )		
          thisMNI.component(cno).threshold(thr).neg(clno).Masks.include = 0;
          thisMNI.component(cno).threshold(thr).neg(clno).Masks.exclude = 1;
        else
          handles.MNI(cno).neg(clno).Masks.include = 0;
          handles.MNI(cno).neg(clno).Masks.exclude = 1;
        end;

      else
        if isfield( handles.MNI, 'component' )		
          thisMNI.component(cno).threshold(thr).pos(clno).Masks.include = 0;
          thisMNI.component(cno).threshold(thr).pos(clno).Masks.exclude = 1;
        else
          handles.MNI(cno).pos(clno).Masks.include = 0;
          handles.MNI(cno).pos(clno).Masks.exclude = 1;
        end;      
      end;      
   
    end;

    % Update handles structure
    guidata(handles.figure1, handles);

    show_cluster_list( handles, 0 );
    set( handles.lst_clusters, 'Value', idx );

  end;



% --- Executes on button press in btn_clear_state.
function btn_clear_state_Callback(hObject, eventdata, handles)
% hObject    handle to btn_clear_state (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  idx = get(handles.lst_clusters, 'Value');
  thr = get(handles.lst_thresholds, 'Value' );

%  if ( size(idx,2) > 0 )
    contents = get(handles.lst_clusters,'String');

    for ii = 1:size(contents,1)
      selected_item = contents{ii};

      c = regexp( char(selected_item), '\w+', 'match');
      cno = str2num(char(c(1)));
      clno = str2num(char(c(3)));
      if ( char(c(2)) == 'neg' ) pn = 1; else pn = 0; end;

      if ( pn == 1 )
        if isfield( handles.MNI, 'component' )		
          thisMNI.component(cno).threshold(thr).neg(clno).Masks.include = 0;
          thisMNI.component(cno).threshold(thr).neg(clno).Masks.exclude = 0;
        else
          handles.MNI(cno).neg(clno).Masks.include = 0;
          handles.MNI(cno).neg(clno).Masks.exclude = 0;
        end;      

      else
        if isfield( handles.MNI, 'component' )		
          thisMNI.component(cno).threshold(thr).pos(clno).Masks.include = 0;
          thisMNI.component(cno).threshold(thr).pos(clno).Masks.exclude = 0;
        else
          handles.MNI(cno).pos(clno).Masks.include = 0;
          handles.MNI(cno).pos(clno).Masks.exclude = 0;
        end;      
      end;      
   
    end;

    % Update handles structure
    guidata(handles.figure1, handles);

    show_cluster_list( handles, 0 );
    set( handles.lst_clusters, 'Value', idx );

%  end;



% --- Executes on selection change in lst_included.
function lst_included_Callback(hObject, eventdata, handles)
% hObject    handle to lst_included (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns lst_included contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lst_included


% --- Executes during object creation, after setting all properties.
function lst_included_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_included (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in lst_excluded.
function lst_excluded_Callback(hObject, eventdata, handles)
% hObject    handle to lst_excluded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Hints: contents = get(hObject,'String') returns lst_excluded contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lst_excluded


% --- Executes during object creation, after setting all properties.
function lst_excluded_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_excluded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in btn_create_mask.
function btn_create_mask_Callback(hObject, eventdata, handles)
% hObject    handle to btn_create_mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Zheader scan_information 

  thr = get(handles.lst_thresholds, 'Value' );
  if isfield( handles.MNI, 'component' )		
    nd = size( handles.MNI.component,1);
  else
    nd = size( handles.MNI,1);
  end;

  meth = 'rotated';
  p.method = mvs_rotation_method( handles.filename );
  x = regexp( handles.filename, '_', 'split' );
  p.model = char( x(1));
  
  if strcmp( p.method, 'unrotated' )
    meth = p.method;
  end;

  noParms = struct( 'empty', 1 );
  has_dir = fs_create_path( meth, 'clusters', nd, 0, p);

  op_dir = fs_path( meth, 'clusters', nd, 0, p );
  op_dir = [pwd filesep op_dir];

  ext = '.img';
  if scan_information.mask.niiSingle   ext = '.nii';  end;

  contents = get(handles.lst_included,'String');

  Zmask = zeros(1,Zheader.total_columns);			% the mask for Z data extraction
  Imask = zeros(1,prod(scan_information.mask.vol.dim));	% the mask for producing imagery

  if ( size(contents,1) > 0 )

    for ii = 1:size(contents,1)

      [cno clno pn] = parse_include_exclude_item( contents{ii} );      
          
      if ( pn == 1 )
        if isfield( handles.MNI, 'component' )		
          Zmask(handles.MNI.component(cno).threshold(thr).neg(clno).Masks.Zindex) = 1;
          Imask(handles.MNI.component(cno).threshold(thr).neg(clno).Masks.Mindex) = 1;
        else
          Zmask(handles.MNI(cno).neg(clno).Masks.Zindex) = 1;
          Imask(handles.MNI(cno).neg(clno).Masks.Mindex) = 1;
        end;

      else
        if isfield( handles.MNI, 'component' )		
          Zmask(handles.MNI.component(cno).threshold(thr).pos(clno).Masks.Zindex) = 1;
          Imask(handles.MNI.component(cno).threshold(thr).pos(clno).Masks.Mindex) = 1;
        else
          Zmask(handles.MNI(cno).pos(clno).Masks.Zindex) = 1;
          Imask(handles.MNI(cno).pos(clno).Masks.Mindex) = 1;
        end;
      end;

    end;

  end;

  % --- test mask creation not on width of G, but on conditions*bins - [5.4.5]
  eval( [ 'load( ''' Zheader.Model.path ''', ''Gheader'');' ] );
  minwidth = Gheader.conditions * Gheader.bins;  

  filename = char(get( handles.txt_mask_name, 'String' ));
  [f e] = split_filename( filename );
  filename = [f ext];

  msk = scan_information.mask;
  write_cpca_image( '', filename, Zmask, msk );

  xx = exist( filename, 'file');
  if xx == 2
    disp( ['The cluster mask (' filename ') has been created in the current directory.'] );
  end;



function [cno clno pn] = parse_include_exclude_item(selected_item )
% --- parses an include list item and returns
% ---   cno = component number
% ---  clno = cluster number
% ---    pn = positive/negative flag  ( 0 = pos, 1 = neg )
    c = regexp( char(selected_item), '\w+', 'match');
    cno = str2num(char(c(1)));
    clno = str2num(char(c(3)));
    if ( strcmp( char(c(2)), 'neg' ) ) pn = 1; else pn = 0; end;


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


% --- Executes on button press in btn_cluster_betas.
function btn_cluster_betas_Callback(hObject, eventdata, handles)
% hObject    handle to btn_cluster_betas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Zheader scan_information 

  comp = get(handles.lst_cluster_summary, 'Value' );
  thr = get(handles.lst_thresholds, 'Value' );

  cls = get(handles.lst_clusters, 'String' );
  cls_idx = get(handles.lst_clusters, 'Value' );

  eval( [ 'load( ''' handles.cdir filesep handles.filename '.mat'', ''ep'', ''VR'');' ] );
  if ~exist( 'ep', 'var' )  return;  end;

  threshold = ep(comp).percentiles(thr).threshold;	% top n% of component weights

  eval( [ 'load( ''' handles.cdir filesep 'Images' filesep 'image-loadings_' handles.filename '.mat'', ''MNI'');' ] );
  eval( [ 'load( ''' Zheader.Model.path ''', ''Gheader'');' ] );

  nconds = Gheader.conditions;
  nbins = Gheader.bins;
  clusternotext = '';
  cluster_list = [' top ' num2str(Zheader.pct_value(thr) ) '% '];
  mni_coords = '';

  if size( cls_idx, 2 ) == 1 
    x = sscanf( char(cls(cls_idx)), '%d%s%d%%' );
    posnegtext = char(x(2:end-1))';
    cluster_no = x(end);
    voxels = ep(comp).percentiles(thr).voxels;
    cluster_list = [ posnegtext ' ' num2str(cluster_no)];

    if strcmp( posnegtext, 'pos' )
      Zindex = MNI.component(comp).threshold(thr).pos(cluster_no).Masks.Zindex;
      pk = num2str( MNI.component(comp).threshold(thr).pos(cluster_no).peak.mni );
      pkv = sprintf( '%.5f', MNI.component(comp).threshold(thr).pos(cluster_no).peak.value );

      mni_coords = [ 'Peak MNI: ' pk ' (' pkv ')  ' num2str( MNI.component(comp).threshold(thr).pos(cluster_no).mm3 ) ' cubic mm  @ ' num2str(Zheader.pct_value(thr) ) '%' ];
    else
      Zindex = MNI.component(comp).threshold(thr).neg(cluster_no).Masks.Zindex;
      pk = num2str( MNI.component(comp).threshold(thr).neg(cluster_no).peak.mni );
      pkv = sprintf( '%.5f', MNI.component(comp).threshold(thr).neg(cluster_no).peak.value );
      mni_coords = [ 'Peak MNI: ' pk ' (' pkv ')  ' num2str( MNI.component(comp).threshold(thr).neg(cluster_no).mm3 ) ' cubic mm  @ ' num2str(Zheader.pct_value(thr) ) '%' ];
    end;

  else

    Zindex = [];

    last_pos_neg = '' ;
    for ii = 1:size( cls_idx, 2 )

      x = sscanf( char(cls(cls_idx(ii))), '%d%s%d%%' );
      posnegtext = char(x(2:end-1))';
      cluster_no = x(end);
      if ii == 1 || ~strcmp( last_pos_neg, posnegtext )
        cluster_list = [cluster_list ' ' posnegtext ' ' num2str(cluster_no)];
      else
        cluster_list = [cluster_list ' ' num2str(cluster_no)];
      end;
      last_pos_neg = posnegtext ;

      if strcmp( posnegtext, 'pos' )
        Zindex = [Zindex; MNI.component(comp).threshold(thr).pos(cluster_no).Masks.Zindex];
      else
        Zindex = [Zindex; MNI.component(comp).threshold(thr).neg(cluster_no).Masks.Zindex];
      end;

    end;

    Zindex = unique( Zindex );
    posnegtext = 'multiple';
    cluster_no = 0;
  end;


  if cluster_no > 0 
    clusternotext = num2str( cluster_no );
  end

  Cn = [];  % --- subject mean
  C = [];
  for sn = 1:Zheader.num_subjects
    eval( [ 'load( ''' Gheader.GZheader.path_to_segs 'GC_S' num2str(sn) '.mat'', ''C_S' num2str(sn) ''');'] ); 
    eval( [ 'C = C_S' num2str(sn) '(:,Zindex(:));' ] );
    Cn = [Cn mean(C,2)];
    eval( [ 'clear C_S' num2str(sn) ';' ] );
  end;

  produce_output = get( handles.chk_betas_text, 'Value' );   % --- produce text output if checkbox marked
  if produce_output
    fn = sprintf('Component_%d_cluster_betas', comp );
% ---    write_cluster_means( Cn', Cm', fn, cluster_list, Gheader );
    write_cluster_means( Cn', fn, cluster_list, Gheader );
  end;
  
  C = mean( Cn,2);

  graphdata = [];
  er = 0;
  for ii = 1:nconds
    sr = er + 1;
    er = sr + nbins - 1;
    graphdata = [graphdata C(sr:er)];
  end


  mdl_view = scan_information.processing.model;
  mdl_view.parameters.plotting.global.label.xgrid = 'on';

  if ( Gheader.model_type == constant_define( 'HRF_MODEL' ) )
    h = figure; bar( graphdata, 'c' );
    ttle = ['Component ' num2str(comp) ' ' posnegtext ' cluster ' clusternotext ' (' num2str(size(Zindex,1)) ')'];
    title( ttle );
    set( h, 'NumberTitle' , 'off' );
    set( h, 'Name' , ttle );

  else
      mdl_view.parameters.plotting.global.label.title = mni_coords;
      plot_name = sprintf('Component %d %s cluster %s (%d)', comp, posnegtext, clusternotext, size(Zindex,1) );
      mdl_view.parameters.plotting.global.label.legend = 1;
      show_plot( graphdata, mdl_view.parameters, plot_name );
  end;

  if nbins > 1 
    minmax = min_max_limits( graphdata );
    axis( [1, nbins, minmax(1), minmax(2)] );
  end;
  ylabel( 'Mean Betas' );

  if produce_output
    mean_output = sprintf( '%s_mean.txt', fn );
% ---    median_output = sprintf( '%s_median.txt', fn );
    eval( ['edit ' mean_output ] );
% ---    eval( ['edit ' median_output ] );
  end;



% --- function write_cluster_means( avg_conditions, med_conditions, fn, cluster_list, Gheader )
function write_cluster_means( avg_conditions, fn, cluster_list, Gheader )
global Zheader scan_information 

  nbins = calculate_nbins();

  mean_output = sprintf( '%s_mean.txt', fn );
% ---  median_output = sprintf( '%s_median.txt', fn );

  mean_fid = fopen( mean_output, 'w' );
% ---  median_fid = fopen( median_output, 'w' );

  str = [cpca constant_define( 'REVISION_NUMBER' ) ];
  fprintf(  mean_fid, 'created: %s - %s\n', date, str );
  fprintf(  mean_fid, 'clusters: %s\n', cluster_list );
  fprintf(  mean_fid, '------------------------------------------\n' );


  for s = 1:size( avg_conditions, 1 )
    fprintf(    mean_fid, 'S%d', s );
% ---    fprintf(  median_fid, 'S%d', s );

    if ( size( scan_information.SubjectID, 2 ) >= s )
      fprintf(    mean_fid, '\t%s', char(scan_information.SubjectID(s)) );
% ---      fprintf(  median_fid, '\t%s', char(scan_information.SubjectID(s)) );
    end;

    for ii = 1:size( avg_conditions, 2 )

      if avg_conditions(s,ii) == constant_define( 'NON_ENCODED_COND_FLAG')
        fprintf(    mean_fid, '\t --- ');
      else
        fprintf(    mean_fid, ['\t' constant_define( 'PREFERENCES', 'precision.log' ) ], avg_conditions(s,ii) );
      end;


    end;
 
    fprintf(    mean_fid, '\n' );
% ---    fprintf(  median_fid, '\n' );
  end;

  fprintf(    mean_fid, '\nAll\t --- ', s );
% ---  fprintf(  median_fid, '\nAll\t --- ', s );

  Cn = mean( avg_conditions);
% ---  Cm = median( med_conditions);

  for ii = 1:size( avg_conditions, 2 )

    if avg_conditions(s,ii) == constant_define( 'NON_ENCODED_COND_FLAG')
      fprintf(    mean_fid, '\t --- ');
    else
      fprintf(    mean_fid, ['\t' constant_define( 'PREFERENCES', 'precision.log' )], Cn(ii) );
    end;


  end;
 
  fprintf(    mean_fid, '\n' );
  

  fclose(   mean_fid );


% --- Executes on button press in chk_betas_text.
function chk_betas_text_Callback(hObject, eventdata, handles)
% hObject    handle to chk_betas_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_betas_text


% --- Executes on button press in btn_Create_H.
function btn_Create_H_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Create_H (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scan_information

  byCluster = get( handles.chk_by_cluster, 'Value' ) == 1;

  contents = get(handles.lst_included,'String');
  thr = get(handles.lst_thresholds, 'Value' );

  HFile = char(get( handles.txt_H_File, 'String' ));
  [f e] = split_filename( HFile );
  if isempty(f)
    HFile = [HFile '.mat'];
  end
  ID = char( get( handles.txt_H_ID, 'String' ) );

  % --- if selectedRegions is empty, then RegionLabels will be the H column
  % --- definition of the cluster comprising the active voxels
  selectedRegions = [];
  RegionLabels = [];
  threshold_values = constant_define( 'PREFERENCES', 'threshold.values' );

  if byCluster
    H = zeros( size( scan_information.mask.ind, 1), size(contents, 1) );

    for ii = 1:size(contents,1)

      [cno clno pn] = parse_include_exclude_item( contents{ii} );    
      
      if ( pn == 1 )
        if isfield( handles.MNI, 'component' )	
          H(handles.MNI.component(cno).threshold(thr).neg(clno).Masks.Zindex(:), ii) = 1;
          txt = ['Negative cluster Comp ' num2str( cno ) ' cluster ' num2str(clno) ' @ ' num2str(threshold_values( thr )) '% '  num2str(handles.MNI.component(cno).threshold(thr).neg(clno).peak.mni)];
        else
          H(handles.MNI(cno).neg(clno).Masks.Zindex(:), ii) = 1;
          txt = ['Negative cluster Comp ' num2str( cno ) ' cluster ' num2str(clno) ' ' num2str(handles.MNI.component(cno).neg(clno).peak.mni)];
        end;

      else
        if isfield( handles.MNI, 'component' )	
          H(handles.MNI.component(cno).threshold(thr).pos(clno).Masks.Zindex(:), ii) = 1;
          txt = ['Positive cluster Comp ' num2str( cno ) ' cluster ' num2str(clno) ' @ ' num2str(threshold_values( thr )) '% '  num2str(handles.MNI.component(cno).threshold(thr).pos(clno).peak.mni)];
        else
          H(handles.MNI(cno).pos(clno).Masks.Zindex(:), ii) = 1;
          txt = ['Positive cluster Comp ' num2str( cno ) ' cluster ' num2str(clno) ' ' num2str(handles.MNI.component(cno).pos(clno).peak.mni)];
        end;
      end;
    
      RegionLabels = [RegionLabels; {txt}];
      
    end;
    
  else

    vx = [];
    for ii = 1:size(contents,1)

      [cno clno pn] = parse_include_exclude_item( contents{ii} );    
      if ( pn == 1 )
        vx = [vx; handles.MNI.component(cno).threshold(thr).neg(clno).Masks.Zindex ];
      else
        vx = [vx; handles.MNI.component(cno).threshold(thr).pos(clno).Masks.Zindex ];
      end;
    end;
     
    selectedRegions = uint32(unique(scan_information.mask.tal_index(vx(:),1)));
    RegionLabels =  cell(size(selectedRegions,1),1);
      
    H = zeros( size( scan_information.mask.ind, 1), size(selectedRegions,1) );
    for ii = 1:size(selectedRegions,1)
      y = find( scan_information.mask.tal_index(  vx(:),1) == selectedRegions(ii) );
      H( vx(y(:)), ii ) = 1;

    end;
  end;

  HFile = strrep( HFile, ' ', '_' );
  H_mask = any(H' == 1 )';
  imgName = [ 'H_' ID '.img' ];
  write_cpca_image( '', imgName, H_mask, scan_information.mask );

  save( HFile, 'H', 'ID', 'selectedRegions', 'RegionLabels', 'H_mask' );
  
  xx = exist( HFile, 'file');
  if xx == 2
    disp( ['The H file (' HFile ') has been created in the current directory.'] );
  end;





function txt_H_File_Callback(hObject, eventdata, handles)
% hObject    handle to txt_H_File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_H_File as text
%        str2double(get(hObject,'String')) returns contents of txt_H_File as a double


% --- Executes during object creation, after setting all properties.
function txt_H_File_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_H_File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_H_ID_Callback(hObject, eventdata, handles)
% hObject    handle to txt_H_ID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_H_ID as text
%        str2double(get(hObject,'String')) returns contents of txt_H_ID as a double


% --- Executes during object creation, after setting all properties.
function txt_H_ID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_H_ID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chk_by_cluster.
function chk_by_cluster_Callback(hObject, eventdata, handles)
% hObject    handle to chk_by_cluster (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set( hObject, 'Value', 1 );
set( handles.chk_by_talairach, 'Value', 0 );


% --- Executes on button press in chk_by_talairach.
function chk_by_talairach_Callback(hObject, eventdata, handles)
% hObject    handle to chk_by_talairach (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set( hObject, 'Value', 1 );
set( handles.chk_by_cluster, 'Value', 0 );
