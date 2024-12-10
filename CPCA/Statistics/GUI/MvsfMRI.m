function MvsfMRI(varargin)
% MVSFMRI M-file for MvsfMRI.fig
%      MVSFMRI, by itself, creates a new MVSFMRI or raises the existing
%      singleton*.
%
%      H = MVSFMRI returns the handle to a new MVSFMRI or the handle to
%      the existing singleton*.
%
%      MVSFMRI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MVSFMRI.M with the given input arguments.
%
%      MVSFMRI('Property','Value',...) creates a new MVSFMRI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MvsfMRI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MvsfMRI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MvsfMRI

% Last Modified by GUIDE v2.5 13-Jun-2016 18:40:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MvsfMRI_OpeningFcn, ...
                   'gui_OutputFcn',  @MvsfMRI_OutputFcn, ...
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

end
% --- end function


%% --- GUI Initialization function
function MvsfMRI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MvsfMRI (see VARARGIN)
global scan_information Zheader 

  stats_load = stats_load_screen( 'show' );
%  stats_load_screen( 'hide', stats_load );  % uncomment when debugging

  % Choose default command line output for MvsfMRI 
  handles.output = hObject;

  handles.cancel_operation = 0;

  % ---------------------------
  % plotting criteria structure
  % ---------------------------
  handles.criteria = struct ( ...
    'prefix', 'G', ...		% computed_n file name prefix
    'module', '', ...		% used for GMH prefix for modules GMH, GC or BH
    'Hmodel', '', ...		% used to determine which ( ZH, EH or GMH )
    'filename', '', ...		% selected computed_n file name
    'Weights', 0, ...		% PR - HRF shapes for each model
    'mask_registry', 0, ... % Mask registry setting for this analysis set
    'aPR', [], ...          % PR - alternate
    'showApr', 0, ...		% flag indicating plot of alternate PR
    'VR', 0, ...            % plot VR components
    'posLoadings', 0, ...	% zoom into selected percent of positive loadings
    'negLoadings', 0, ...	% zoom into selected percent of positive loadings
    'GI', 0, ...            % group index value
    'condition', 0, ...		% condition number to plot ( 0 = all conditions )
    'Hheader', [], ...		% load in the Hheader if required
    'subject_encoded', [], ...  % subject conditions encoded
    'component', 0 );		% component number to plot ( 0 = all components )

% --- handles.criteria.module is empty if not a GMH::* module

  % ---------------------------
  % plotting criteria structure
  % ---------------------------
  if(nargin > 3)
    for index = 1:2:(nargin-3),
        if nargin-3==index, break, end
        switch lower(varargin{index})
         case 'prefix'
          str = varargin{index+1};
          handles.criteria.prefix = char(str(1));
          if strcmp( handles.criteria.prefix, 'H' ) || size( str, 2 ) > 1
            handles.criteria.prefix = 'H';              % --- GMH will set this to G - reset in case
            handles.criteria.Hmodel = varargin{index+1};
            load( Zheader.Limits.path );
            handles.criteria.Hheader = Hheader;

          end;
         case 'module'
          str = varargin{index+1};
          handles.criteria.module = char(str);
        end
    end
  end


  if isempty( handles.criteria.Hmodel )
    handles.model_display = handles.criteria.prefix;
    if isempty( handles.criteria.module )
      handles.criteria.module = handles.criteria.prefix;
    end;
  else
    if isempty( handles.criteria.module )
      handles.model_display = handles.criteria.Hmodel;
      handles.criteria.module = handles.criteria.Hmodel;
    else
      handles.model_display = handles.criteria.module;
    end;
  end;

  % -----------------------------------------------
  % --- we have 14 predefined individual condition colors
  % -----------------------------------------------
  handles.condition_colors = [ ...
    [0.10 .30 .15]; ...
    [0.90 .50 .20]; ...
    [0 0 1]; ...
    [0 .5 0]; ...
    [.85 .15 0]; ...
    [0 .6 1]; ...
    [.5 .05 .9]; ...
    [.75 .75 0]; ...
    [0 0 0]; ...
    [.365 .365 1]; ...
    [.2 1 .2]; ...
    [1 .4 .2]; ...
    [.2 1 .6]; ...
    [.8 .2 1]; ...
    [.6 .6 0]; ...
    [.4 .4 .4] ];

  % -----------------------------------------------
  % --- we have only 4 line styles to work with
  % --- these will differentiate between groups
  % -----------------------------------------------
  handles.group_styles = [{'-'} {'--'} {'-.'} {':'}];
  handles.figure_plot = 0;

  handles.plotstyles = struct ( 'linestyles', []', 'markers', [], 'colors', [], 'keys', [] );
  handles.plotstyles.linestyles = struct ( 'symbol', '', 'text', '<none>' ) ;
  handles.plotstyles.linestyles = vertcat(handles.plotstyles.linestyles , struct ( 'symbol', '-', 'text', 'solid' ) ) ;
  handles.plotstyles.linestyles = vertcat(handles.plotstyles.linestyles , struct ( 'symbol', '--', 'text', 'dashed' ) ) ;
  handles.plotstyles.linestyles = vertcat(handles.plotstyles.linestyles , struct ( 'symbol', ':', 'text', 'dotted' ) ) ;
  handles.plotstyles.linestyles = vertcat(handles.plotstyles.linestyles , struct ( 'symbol', '-.', 'text', 'dash dot' ) ) ;

  handles.plotstyles.markers = struct ( 'symbol', '', 'text', '<none>' ) ;
  handles.plotstyles.markers = vertcat(handles.plotstyles.markers , struct ( 'symbol', '+', 'text', 'plus sign' ) ) ;
  handles.plotstyles.markers = vertcat(handles.plotstyles.markers , struct ( 'symbol', 'O', 'text', 'circle' ) ) ;
  handles.plotstyles.markers = vertcat(handles.plotstyles.markers , struct ( 'symbol', '*', 'text', 'asterisk' ) ) ;
  handles.plotstyles.markers = vertcat(handles.plotstyles.markers , struct ( 'symbol', '.', 'text', 'point' ) ) ;
  handles.plotstyles.markers = vertcat(handles.plotstyles.markers , struct ( 'symbol', 'x', 'text', 'cross' ) ) ;
  handles.plotstyles.markers = vertcat(handles.plotstyles.markers , struct ( 'symbol', 's', 'text', 'square' ) ) ;
  handles.plotstyles.markers = vertcat(handles.plotstyles.markers , struct ( 'symbol', 'd', 'text', 'diamond' ) ) ;
  handles.plotstyles.markers = vertcat(handles.plotstyles.markers , struct ( 'symbol', '^', 'text', 'triangle up' ) ) ;
  handles.plotstyles.markers = vertcat(handles.plotstyles.markers , struct ( 'symbol', 'v', 'text', 'triangle down' ) ) ;
  handles.plotstyles.markers = vertcat(handles.plotstyles.markers , struct ( 'symbol', '>', 'text', 'triangle right' ) ) ;
  handles.plotstyles.markers = vertcat(handles.plotstyles.markers , struct ( 'symbol', '<', 'text', 'triangle left' ) ) ;
  handles.plotstyles.markers = vertcat(handles.plotstyles.markers , struct ( 'symbol', 'p', 'text', 'pentagram' ) ) ;
  handles.plotstyles.markers = vertcat(handles.plotstyles.markers , struct ( 'symbol', 'h', 'text', 'hexagram' ) ) ;

  if ~isempty( handles.criteria.Hmodel ) 
    str = [ 'Multivariate Statistics - components of ' handles.criteria.Hmodel '::' handles.model_display ];
    if size( handles.criteria.Hheader.model, 1 ) > 1
      if ~isempty(handles.criteria.Hheader.model( handles.criteria.Hheader.Hindex ).id) 
        str = [str '  (' handles.criteria.Hheader.model( handles.criteria.Hheader.Hindex ).id ')' ]; 
      end;
    end;
  else
    str = [ 'Multivariate Statistics - components of ' handles.model_display ];
  end;
  
  set( hObject, 'NumberTitle' , 'off' );
  set( hObject, 'Name', str );

  str = ['SS explained by ' handles.model_display ];
  set( handles.lbl_Explained, 'String', str );

  str = [ '   % of Explained by ' handles.model_display ];
  set( handles.lbl_PctExplByModel, 'String', str );

  lst = '';

  % ---------------------------
  % add the files from valid subdirectories (n_components)
  % ---------------------------
  rs = define_rotations();
  valid_dirs = {'unrotated'};
  for ii = 1:size(rs)  
    valid_dirs = [valid_dirs {rs(ii).method}]; 
  end;
  
  [comp_list num_comps] = directory_list( [pwd filesep handles.criteria.prefix filesep] );
   
  if num_comps > 0 

    for compcount = 1:size(comp_list, 1 )
      comp_dir = [pwd filesep handles.criteria.prefix filesep char( comp_list(compcount) ) filesep];
      if ~isempty( handles.criteria.Hmodel )
        comp_dir = [comp_dir handles.criteria.Hmodel filesep];
      end;

      [sub_list sub_count] = directory_list( comp_dir );
      if sub_count > 0 
          
        for cdir = 1:sub_count
            
          if any( strcmp( char(sub_list(cdir)), valid_dirs)) 

            nc = num2str( validate_numeric_entry ( char( comp_list(compcount) ) ) );
            
            if ~isempty( handles.criteria.Hmodel )
              H_ID = H_path_spec( handles.criteria.Hheader, handles.criteria.Hmodel );
              if ~strcmp( char(sub_list(cdir)), 'unrotated' )
                noParms = struct( 'model', 'H', 'mode', handles.criteria.Hmodel, 'hindex',  H_ID, 'method', char(sub_list(cdir))  );
                p =  fs_path( 'rotated', 'output', nc, 0, noParms );
              else
                noParms = struct( 'model', 'H', 'mode', handles.criteria.Hmodel, 'hindex',  H_ID );
                p =  fs_path( 'unrotated', 'output', nc, 0, noParms );
              end;
              q = [p char(42) '.mat'];
              %q = [p char(sub_list(cdir)) filesep handles.criteria.module char(42) '.mat' ];
            else
              p = [comp_dir char(sub_list(cdir)) filesep ];
              q = [p char(42) '.mat' ];
            end;
            
            addlst = get_matfile_entries( p, nc, handles );
            lst = [lst addlst];

            [A_list A_count] = directory_list( p );
            if A_count > 0 
              for A_ii = 1:A_count
                clear addlst
                addlst = get_matfile_entries( [comp_dir char(sub_list(cdir)) filesep char(A_list(A_ii)) filesep], nc, handles, 1 );
                if ~isempty(addlst)
                  for A_jj = 1:size(addlst,2)
                    if ~strcmp( char(A_list(A_ii)), 'ROI' ) 
                      lst = [lst [char(addlst(A_jj)) ' [' char(A_list(A_ii)) ']' ]];
                    else
                      lst = [ lst char(addlst(A_jj)) ];
                    end
                        
                  end
                end
              end
            end

            
          end % -- valid data directory

        end % -- check if valid
      end;  % --- extraction directory found
        
    end;  % check each component count directory 
      
  end;  % -- no extracted component directories found for model type
  
  set( handles.lst_computedFiles, 'String', lst, 'Value', 1) ;

  [cdir fn] = filename_from_list( 1, handles );

  rstyle = mvs_rotation_style( fn );
  set( handles.chk_view_PRA, 'Enable', 'off' );

  load( [pwd filesep cdir fn], 'VR', 'ep', 'alternatePR', 'GroupIndex', 'mask_registry', 'process_date' );
  handles.criteria.Weights = load([pwd filesep cdir fn], 'PR*');
  %eval ( [ 'handles.criteria.Weights = load( ''' cdir fn ''', ''PR*'' );' ] );
  if ~isfield( handles.criteria.Weights, 'PRh' )
    handles.criteria.Weights.PRh = [];
  end;
  handles.criteria.mask_registry = 0;
  if exist( 'mask_registry', 'var' )
    handles.criteria.mask_registry = mask_registry;
  end;
  
  set( handles.chk_PR_of_G, 'Enable', constant_define( 'STATE', ~isempty(handles.criteria.Weights.PR) ) );
  set( handles.chk_PR_of_H, 'Enable',  constant_define( 'STATE', ~isempty(handles.criteria.Weights.PRh) ) );
  if ~isempty( handles.criteria.Weights.PR )
    set( handles.chk_PR_of_G, 'Value', 1 );
    set( handles.chk_PR_of_H, 'Value', 0 );
  else
    set( handles.chk_PR_of_G, 'Value', 0 );
    set( handles.chk_PR_of_H, 'Value', 1 );
  end;

  if exist( 'alternatePR', 'var' )
    handles.criteria.aPR = alternatePR;
    set( handles.chk_view_PRA, 'Enable', 'on' );
  end;

  handles.criteria.VR = VR;
  handles.criteria.GI = 0;
  handles.criteria.select_grps = 0;

  handles.group_selection_window = 0;

  str = '';
  rv = matfile_vars( cdir, fn, 'v_*' );
  if size(rv, 1 ) > 0 
    v = strrep(rv(1).name, 'v_', '');
    v1 = hex2dec( v(1:2) );
    v2 = hex2dec( v(3:4) );
    v3 = hex2dec( v(5:6) );
    ver = sprintf( 'cpca %d.%d.%d(%02d)', mod( v1, 10 ), v1-10, v2, v3 );
  end;

  if exist( 'process_date', 'var' )	   	str = {[ 'Processed: ' process_date]};		end;
  if exist( 'ver', 'var' )	   		str = [str; {[ 'Version: ' ver]}];				end;
  set( handles.lbl_process_date, 'String', str ) ;

  % Update handles structure
  guidata(hObject, handles);

  set_source_components( handles.lst_computedFiles, 0, handles );
  set_general_statistics( handles );


  if ( ~strcmp( handles.criteria.prefix(1), 'G' ) )
    set( handles.chk_show_legend, 'Value', 0 );
    set( handles.chk_plot_subjects, 'Enable', 'off' );
  end;

  % -----------------------------------------
  % -- update list of subject groups
  % -----------------------------------------
  lst = [];
%   groupState = 'off';
  if isfield( scan_information, 'GroupList' )
    if ( size( scan_information.GroupList,1) > 0 )
      lst = [lst; {'All'}];
      for ii = 1:size( scan_information.GroupList,1)
        lst = [lst; {char(scan_information.GroupList(ii).name)}];
      end;
    end;
  end;
%   if ~isempty( lst )
%     groupState = 'on';
%   end;
  set( handles.chk_displayGroups, 'Enable', constant_define( 'STATE', ~isempty(lst) ) );
  set( handles.chk_displayGroups, 'Value', 0 );

  set( handles.lst_plot_group, 'String', lst, 'Value', 1 );
  set( handles.lst_plot_group, 'Enable', 'off' );

  lst = [];
  if ~strcmp( handles.criteria.prefix, 'H' ) || ...
      ( strcmp( handles.criteria.prefix, 'H' ) && ~strcmp( handles.criteria.module, 'BH' ) );

    lst = [];
    for ii = 1:size( Zheader.conditions.Names,2) 
      lst = [lst; {char(Zheader.conditions.Names(ii))}];
    end;
    
    set( handles.lst_plot_conditions, 'String', lst, 'Value', 1 );
    set( handles.lst_plot_conditions, 'Max', 3 );
    set( handles.lst_plot_conditions, 'Min', 1 );

    [handles.group_selection_window handles.criteria.chk_selection] = create_selection_window( handles );
    guidata(hObject, handles);
    
    for ii = 1:size(handles.criteria.chk_selection)
      set( handles.criteria.chk_selection(ii), 'UserData', handles.criteria );
    end;

    set(handles.group_selection_window, 'UserData', handles );
    
  else
    set( handles.lst_plot_conditions, 'String', lst );
    set( handles.lst_plot_conditions, 'Enable', 'off' );
    
    set( handles.chk_AllConditions, 'Enable', 'off' );
    set( handles.chk_AllConditions, 'Value', 0 );
    set( handles.chk_AvgConditions, 'Enable', 'off' );
    set( handles.chk_AvgConditions, 'Value', 0 );
    set( handles.chk_displayGroups, 'Enable', 'off' );
    set( handles.chk_displayGroups, 'Value', 0 );
    set( handles.chk_plot_subjects, 'Enable', 'off' );
    set( handles.chk_plot_subjects, 'Value', 0 );
  end;
  
  % -----------------------------------------
  % -- flipping and scree not available if no GZsegs GC data
  % -----------------------------------------
  has_CC = 0;
  has_eigs = 0;
  handles.criteria.subject_encoded = 0;
  
  
  if strcmp( handles.criteria.prefix, 'G' )
    if isfield(Zheader.Model, 'path') & ~isempty(Zheader.Model.path) 
      load( Zheader.Model.path, 'Gheader' );	% do not assume Gheader is pre-loaded
      has_CC = has_GC_var( Gheader, 'CC' );
      has_eigs = has_GC_var( Gheader, 'C_Eigenvalues' );
      handles.criteria.subject_encoded = Gheader.subject_encoded;
    end
  else
      
    if isfield(Zheader.Limits, 'path') & ~isempty(Zheader.Limits.path) 
      load( Zheader.Limits.path );	% do not assume Hheader is pre-loaded
      
      if strcmp(handles.criteria.Hmodel, 'GMH' )
        has_eigs = has_GMH_var( Hheader, handles.criteria.module, 'C_Eigenvalues');

        CCvar = 'ZZZ';  % --- dummy value to force no flip option
        switch handles.criteria.module
            case 'GC' 
              CCvar = 'AA';
%            case 'GMH' 
%              CCvar = 'BB';
        end
        has_CC = has_GMH_var( Hheader, handles.criteria.module, CCvar );   
      end;
      
    end;
    
  end
  
  set(handles.btn_Flip, 'Enable', constant_define( 'STATE', has_eigs ) );
  set(handles.btn_PlotBetas, 'Enable', constant_define( 'STATE',  has_CC) );
  set(handles.btn_Plot_Eigenvalues, 'Enable', constant_define( 'STATE', has_eigs) );

  % -- no beta plotting for HZ, HE
  if ( strcmp( handles.criteria.Hmodel, 'ZH' ) | strcmp( handles.criteria.Hmodel, 'EH' ) ) % --- | ...
  % ---   ( strcmp( handles.criteria.Hmodel, 'GMH' ) & strcmp( handles.criteria.module, 'GMH' ) )
    set(handles.btn_PlotBetas, 'Enable', 'off' );
    set(handles.btn_Flip, 'Enable', 'off' );
  end
  
  set( handles.btn_view_clusters, 'Enable', 'off' );

  lst = [];

  if exist( 'ep', 'var' )  % -- we have a loaded ep variable - set active threshold values

    handles.active_thresholds = zeros( 1, size(ep(1).percentiles,1) );
    handles.threshold_values = handles.active_thresholds;

    for ii = 1:size(ep(1).percentiles, 1)		% -- data set may have thresholds different from active list
      if ep(1).percentiles(ii).cutoff > 0 
        lst = [lst {[num2str( ep(1).percentiles(ii).cutoff ) '%']} ];
        idx = threshold_index( ep(1).percentiles(ii).cutoff );
        handles.active_thresholds(ii) = 1;
        handles.threshold_values(ii) = ep(1).percentiles(ii).cutoff;
      end
    end
  
  else    
      % -- set initial list of available percentage views based on global thresholds
    handles.threshold_values = constant_define( 'PREFERENCES', 'threshold.values' );
    handles.active_thresholds =  constant_define( 'PREFERENCES', 'threshold.actives' );
  end

  handles.selected_threshold = constant_define( 'PREFERENCES', 'threshold.default', 3 );
  set( handles.lbl_EP_Thresh, 'String', lst', 'Value', min(1, handles.selected_threshold ));
  
  guidata(hObject, handles);

 stats_load_screen( 'hide', stats_load );
 clear stats_load;
 
  % UIWAIT makes MvsfMRI wait for user response (see UIRESUME)
%  uiwait(handles.output );

%  delete(handles.output);
end
% --- end function


% --- Outputs from this function are returned to the command line.
function varargout = MvsfMRI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = '';
end
% --- end function



% --- Executes on selection change in lst_computedFiles.
function lst_computedFiles_Callback(hObject, eventdata, handles)
% hObject    handle to lst_computedFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global  Zheader

  idx = get(handles.lst_computedFiles,'Value');
  [cdir fn] = filename_from_list( idx, handles );

  cidx = get(handles.lst_Components,'Value');

  rstyle = mvs_rotation_style( fn );


  load( [pwd filesep cdir fn], 'VR', 'ep', 'alternatePR', 'GroupIndex', 'mask_registry', 'process_date' );
  handles.criteria.Weights = load([pwd filesep cdir fn], 'PR*');
  %eval ( [ 'handles.criteria.Weights = load( ''' cdir fn ''', ''PR*'' );' ] );
  if ~isfield( handles.criteria.Weights, 'PRh' )
    handles.criteria.Weights.PRh = [];
  end;
  handles.criteria.mask_registry = 0;
  if exist( 'mask_registry', 'var' )
    handles.criteria.mask_registry = mask_registry;
  end;


  list_content = get(handles.lst_computedFiles, 'String');
  str = regexp(char(list_content(idx)), ' ', 'split' );
  lst = [];
  if strcmp( char(str(2)), 'GA' )
    load( Zheader.Contrast.path );
    Aidx = Aheader_index( Aheader, handles );
    for cond = 1:size( Aheader.model( Aidx ).contrast_name, 2 )
      lst = [ lst; Aheader.model( Aidx ).contrast_name(cond) ];
    end
    
  else
    if ~strcmp( char(str(2)), 'ROI' )
      for ii = 1:size( Zheader.conditions.Names,2) 
        lst = [lst; {char(Zheader.conditions.Names(ii))}];
      end;
    end
  end
  set( handles.lst_plot_conditions, 'String', lst, 'Value', 1 );
  

  if exist( 'alternatePR', 'var' )
    handles.criteria.aPR = alternatePR;
    set( handles.chk_view_PRA, 'Enable', 'on' );
  else
    handles.chk_view_PRA = [];
    set( handles.chk_view_PRA, 'Enable', 'off' );
  end

  handles.criteria.VR = VR;

  if ( exist( 'GroupIndex', 'var' ) )
    handles.criteria.GI = GroupIndex;
  else
    handles.criteria.GI = 0;
  end

  str = '';
  if exist( 'process_date', 'var' )	   str = [ 'Processed: ' process_date];		end
  set( handles.lbl_process_date, 'String', str ) ;

  set( handles.btn_view_clusters, 'Enable', 'off' );

  % -- update list of available percentage views
  lst = [];
  handles.active_thresholds = zeros( 1, size(ep(1).percentiles,1) );
  handles.threshold_values = handles.active_thresholds;

  for ii = 1:size(ep(1).percentiles, 1)		% -- data set may have thresholds different from active list
    if ep(1).percentiles(ii).cutoff > 0 
      lst = [lst {[num2str( ep(1).percentiles(ii).cutoff ) '%']} ];
      idx = threshold_index( ep(1).percentiles(ii).cutoff );
      handles.active_thresholds(ii) = constant_define( 'PREFERENCES', 'threshold.default', 3 );
      handles.threshold_values(ii) = ep(1).percentiles(ii).cutoff;
    end
  end
  set( handles.lbl_EP_Thresh, 'String', lst, 'Value', min(1, handles.selected_threshold) );

  if strcmp( handles.criteria.prefix, 'H' )
    set( handles.chk_AllConditions, 'Enable', 'off' );
    set( handles.chk_AvgConditions, 'Enable', 'off' );
  end;
  
  % Update handles structure
  guidata(hObject, handles);

  set_source_components( handles.lst_computedFiles, 0, handles );
  set_general_statistics( handles ); 
  cla

  lst = get(handles.lst_Components,'String');
  if ( cidx <= size(lst,1))
    set( handles.lst_Components, 'Value', cidx) ;
    lst_Components_Callback( handles.lst_Components, 0, handles );
  end
guidata(hObject, handles);
end
% --- end function


% --- Executes during object creation, after setting all properties.
function lst_computedFiles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_computedFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end

end
% --- end function



% --- Executes on selection change in lst_Components.
function lst_Components_Callback(hObject, eventdata, handles)
% hObject    handle to lst_Components (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global  Zheader scan_information

  if ( ~handles.figure_plot )
    uicontrol( hObject );
  end

  Gheader = [];
  Aheader = [];
  
  SubjectVector = [ 1:Zheader.num_subjects ];
  need_full_max = 0;

  idx = get(handles.lst_computedFiles,'Value');
  [cdir fn] = filename_from_list( idx, handles );

  contents = get(handles.lst_Components,'String') ;		% returns lst_Components contents as cell array
  str = contents{get(handles.lst_Components,'Value')}; 	% returns selected item from lst_Components
  handles.criteria.component = str2num( char(str) );

  load( Zheader.Model.path, 'Gheader' );
  
  % Update handles structure
  guidata(handles.output, handles);
  
  set_component_statistics( handles );
  set_coefficient_statistics( handles )

  list_content = get( handles.lst_computedFiles, 'String' ) ;
  str = char(list_content(idx));
  str2 = regexp(str, ' ', 'split' );
  this_plot.isGA  = strcmp( char(str2(2)), 'GA' );
  this_plot.isGAA = strcmp( char(str2(2)), 'GAA' );
  this_plot.isROI = strcmp( char(str2(2)), 'ROI' );
  
  this_plot.show_by_subjects = get( handles.chk_plot_subjects, 'Value' );
  this_plot.actual_group = 0;
  this_plot.average_groups = get(handles.chk_displayGroups, 'Value');
  
  if this_plot.average_groups
    this_plot.actual_group = get(handles.lst_plot_group, 'Value') - 1;
    if this_plot.actual_group == 0
      handles.criteria.GI = [1:size(scan_information.GroupList, 1 )];
    else
      handles.criteria.GI = this_plot.actual_group;
    end
  end
  
  this_plot.average_conditions = 0;
  this_plot.actual_condition = get(handles.lst_plot_conditions, 'Value') - 2;
  if (this_plot.actual_condition < 0 ) this_plot.actual_condition = 0; end
  this_plot.method = upper( mvs_rotation_method( fn ) );

  if this_plot.average_groups

    if numel(handles.criteria.GI) > 0
      if handles.criteria.GI(1) > 0  
        SubjectVector = [];
        for ( ii = 1:size(handles.criteria.GI, 2 ) )
          if ( size( scan_information.GroupList,1) >= handles.criteria.GI(ii) );
            SubjectVector = [SubjectVector; scan_information.GroupList(handles.criteria.GI(ii)) ];
            need_full_max = 1;
          end
        end
      end
    end
  end

  ls_idx = 1;
  lc_idx = 1;

  plot_ur = get( handles.chk_show_PR, 'Value' );

  if ( handles.criteria.component > 0 )

    state = 'off';
    if ~isMultiFrequency()	% --- bypass cluster data on meg data for now
      if strcmp(handles.criteria.prefix, 'G' )
        state = 'on';
      end
    end
    set( handles.btn_view_clusters, 'Enable', state );


    % -----------------------------------------------
    % --- set the generic global plotting properties for sub functions
    % -----------------------------------------------
    
    this_plot.comp = handles.criteria.component;
    this_plot.nbins = scan_information.processing.model.parameters.bins;
    if this_plot.isGA
      load( Zheader.Contrast.path );
      this_plot.nconds = Aheader.model( Aheader.Aindex).contrasts;
      this_plot.nbins = Aheader.model( Aheader.Aindex).bins;
    else
      if this_plot.isROI
        this_plot.nconds = 1;
        this_plot.nbins = size(handles.criteria.Weights.PR, 1) / Zheader.num_subjects ;
      else
        this_plot.nconds = Gheader.conditions;
        this_plot.nbins = Gheader.bins;
      end
    end
    
    x = get( handles.chk_AllConditions, 'Value' );
    if x   % --- plot all conditions
      this_plot.start_cond = 1;
      this_plot.end_cond = this_plot.nconds;
      this_plot.conditions = [1:this_plot.nconds];
    
    else % --- plot a single condition
      
      content2 = get(handles.lst_plot_conditions,'String');  	% lst_Components contents as cell array
      this_plot.conditions = get(handles.lst_plot_conditions,'Value');
      this_plot.average_conditions = get( handles.chk_AvgConditions, 'Value' );
      this_plot.start_cond = min(this_plot.conditions); % - 1;
      this_plot.end_cond = max(this_plot.conditions); %  - 1;
      need_full_max = 1;
    end

    if ~plot_ur
      plot_vr_average( this_plot, SubjectVector, handles ) ;
      return;
    end

    
    aprText = '';
    if handles.criteria.showApr
      aprText = ' - Alternate PR';
    end

    this_plot.minmax = [0 0];
    
    condition_name = [];
    if this_plot.isGA
      % --- determine which A index value to use   
      
      condition_name = [];
      Aidx = Aheader_index( Aheader, handles );
      for ii = 1:size( this_plot.conditions, 2 )
        cond = this_plot.conditions(ii);		% --- create the matrix for all conditions ---
        condition_name = [ condition_name Aheader.model( Aidx ).contrast_name(cond) ];
      end
     
    else
        
      if this_plot.isGAA
        this_plot.nconds = 1;
        this_plot.conditions = 1;
        SubjectVector = 1;       
      else
        if ~this_plot.isROI
          condition_name = selected_condition_names( this_plot );
        else
          condition_name = [];
        end;
      end
    end
    ur_graphdata = prepare_PR_graph( this_plot, SubjectVector, handles );

    % -----------------------------------------------
    % --- plot AR from H and return
    % -----------------------------------------------
    p = get( handles.chk_PR_of_H, 'Value' );
    if p
      plot_PRh();
      return;
    end
    
    minmax = min_max_limits( ur_graphdata );
    
    % --- plot functions are nested to share variable space
    if ( this_plot.show_by_subjects > 0 )

      if ( this_plot.average_groups > 0  )
        % --- SubjectVector is an array of subjects for each group
        plot_average_conditions_by_groups() ;
      else
        % --- SubjectVector is the array of all subjects
        plot_conditions_over_subjects() ;
      end

    else

      if ( this_plot.average_groups )
        % --- SubjectVector is an array of subjects for each group
        plot_average_conditions_by_groups() ;
      else
        SubjectVector = [ 1:Zheader.num_subjects ];
        plot_average_by_conditions() ;
      end

    end

  else
    cla
    set( handles.btn_view_clusters, 'Enable', 'off' );
  end

  handles.figure_plot = 0;
  guidata(hObject, handles);

  
%% --- plot_average_by_conditions()
  function plot_average_by_conditions()

  idx = get(handles.lst_computedFiles,'Value');
  [cdir fn] = filename_from_list( idx, handles );
  load([pwd filesep cdir fn], 'mask_registry' ) ;
  if ~exist( 'mask_registry', 'var' ),  mask_registry = 0;  end;
  
  p = get( handles.chk_PR_of_H, 'Value' );
  if p

    plot_PRh( cdir, fn, handles );
    return;
  end

  ur.parameters.plotting.global.label.ylim = this_plot.minmax;

  set ( handles.plt_component, 'NextPlot', 'replace' );

  ls_idx = 1;
  lc_idx = this_plot.start_cond;

  if ( handles.figure_plot )
    h = figure;
  else
    fh = gca;
    cla
  end

  if ( scan_information.processing.model.parameters.model_type == constant_define( 'HRF_MODEL' ) )  

    barg = [];
    for ii = 1:size( this_plot.conditions, 2 )
      cond = this_plot.conditions(ii);		% --- create the matrix for all conditions ---
      barg = [barg ur_graphdata(:,cond) ];
    end

    bar( barg, 'c'  );

    if ( handles.figure_plot )
      fh = get(h, 'CurrentAxes' );

      ttle = ['Estimated HDR ' this_plot.method ' Component ' num2str( this_plot.comp ) aprText  ];
      title( ttle );
      set( h, 'NumberTitle' , 'off' );
      set( h, 'Name' , ttle );

    end

    set(fh,'YLim',minmax);

    Xtick = [0.5];
    XLabel = [{' '}];
    tc = 0;
    for cond = 1:size( this_plot.conditions, 2 )
      tc = tc + 1;
      XLabel = [XLabel; {char(condition_name(cond))}];
      Xtick = [Xtick; tc];
    end
    XLabel = [XLabel; {' '}];

    set( fh, 'Xtick', Xtick);
    set( fh, 'XtickLabel', XLabel);

    x = get( handles.chk_show_grid_lines, 'Value' );
    if ( x ) set(fh,'XGrid','on');   end

    return

  else

    ls = char( handles.group_styles( 1 ) );

%     if this_plot.isGAA
%       this_plot.nconds = 1;
%       condition_name = [{'All Contrasts'}];
%       this_plot.conditions = 1;
%       ur_graphdata = mean( ur_graphdata, 2 );
%     end;
%       
    if this_plot.isROI
%       bar( ur_graphdata' );
      plot( ur_graphdata, ls  );
  
    else
    for ii = 1:size( this_plot.conditions, 2 )

      cond = this_plot.conditions(ii);		% --- create the matrix for all conditions ---

      lc_idx = cond;
      if ( lc_idx > this_plot.nconds | lc_idx > size(handles.condition_colors, 1 ) | lc_idx > this_plot.end_cond ) 
        lc_idx = this_plot.start_cond; 
      end
      lc = handles.condition_colors(lc_idx,:);

      if ( size(ur_graphdata, 2 ) > 1 )
        plot( ur_graphdata(:,cond), ls, 'Color', lc  );
      else
        plot( ur_graphdata, ls, 'Color', lc  );
      end
      hold on
    end
    end   
%    end  % GA plot
      
    if ( handles.figure_plot )
      fh = get(h, 'CurrentAxes' );
    end

    if minmax(1) > 0 & minmax(2) > minmax(1)
      minmax(1) = 0;
    end;
    
    set(fh,'YLim',minmax);
    x = get( handles.chk_show_grid_lines, 'Value' );
    if ( x ) set(fh,'XGrid','on');   end

    if ( scan_information.processing.model.parameters.TR > 1 )
      xtl = [0];
      for ii = 0:this_plot.nbins
        tr = 1;
        if ~this_plot.isROI 
          tr = scan_information.processing.model.parameters.TR;
        end
        xtl = [xtl ii*tr];
      end
      set( fh, 'XtickLabel', xtl )
      set( fh, 'Xtick', 0:this_plot.nbins );	% -=== [1.0.0]
    end
    
    set ( handles.plt_component, 'FontSize', 8.0 );

    if ~this_plot.isROI  
      x = get(handles.chk_show_legend, 'Value' );
      if ( x ) legend( condition_name, 'Location', 'Best' );   end
    end
  end

  if ( handles.figure_plot )

    if ~this_plot.isROI  
      ttle = ['Estimated HDR ' this_plot.method ' Component ' num2str( this_plot.comp )  aprText constant_define( 'REGISTRATION_FULL', mask_registry) ];
    else
      ttle = ['Estimated HDR ' this_plot.method ' Component ' num2str( this_plot.comp )  aprText '[ROI]' ];
    end
    
    title( ttle );
    set( h, 'NumberTitle' , 'off' );
    set( h, 'Name' , ttle );

  end

  hold off

  drawnow();

  end
  % --- end nested function

  
  %% --- plot_conditions_over_subjects() 
  function plot_conditions_over_subjects() 

  if ( isstruct( SubjectVector ) )
    SubjectVector = handles.criteria.GI;
  end

  % ---------------------------------------------
  % --- plot by individual subject ---
  % ---------------------------------------------

  if ( handles.figure_plot )
    h = figure;
  else
    fh = gca;
    cla
  end

  subject_legend = [];

  if ( scan_information.processing.model.parameters.model_type == constant_define( 'HRF_MODEL' ) )   

    barg = [];
    for ii = 1:size( this_plot.conditions, 2 )
      cond = this_plot.conditions(ii);		% --- create the matrix for all conditions ---
      barg = [barg ur_graphdata(:,cond) ];
    end

    bar( barg, 'c'  );

    if ( handles.figure_plot )
      fh = get(h, 'CurrentAxes' );

      ttle = ['Estimated HDR ' this_plot.method ' Component ' num2str( this_plot.comp ) aprText ];
      if ( this_plot.average_groups )	
        ttle = [ttle ' Avg''d over Subjects/Groups' ];
      else
        ttle = [ttle ' Averaged over Subjects' ];
      end

      title( ttle );
      set( h, 'NumberTitle' , 'off' );
      set( h, 'Name' , ttle );

    end
    
    minmax = min_max_limits( ur_graphdata );
    set(fh,'YLim',minmax);

    Xtick = [0.5];
    XLabel = [];
    tc = 0;
    for subject = 1:size(SubjectVector,2)
      XLabel = [XLabel; {subject_id( SubjectVector(subject) )}];
    end;
    set( fh, 'XtickLabel', XLabel);

    x = get( handles.chk_show_grid_lines, 'Value' );
    if ( x ) set(fh,'XGrid','on');   end


    return;

  end

  [rows num_cols] = size(ur_graphdata);
    
  ur.parameters.condition_name = subject_legend;

  ls_idx = 1;

  lc_idx = this_plot.start_cond;

  for subject = 1:size(SubjectVector,2)

    if ( this_plot.average_groups )	

        for grp = 1:size( scan_information.GroupList, 1 )
          x = any( str2num( scan_information.GroupList(grp).subjectlist ) == subject );
          if x > 0 ls_idx = grp; end
        end
    end

    ls_style = mod( ls_idx, size( handles.group_styles, 2 ));
    if ( ls_style == 0 ) ls_style =  size( handles.group_styles, 2 ); end
    ls = char( handles.group_styles( ls_style) );

    for ii = 1:size( this_plot.conditions, 2 )
      cond = this_plot.conditions(ii);		% --- create the matrix for all conditions ---

      lc_idx = cond;
      if ( lc_idx > this_plot.nconds | lc_idx > size(handles.condition_colors, 1 ) | lc_idx > this_plot.end_cond ) 
        lc_idx = this_plot.start_cond; 
      end
      lc = handles.condition_colors(lc_idx,:);

      plot( ur_graphdata(:,(subject-1)*this_plot.nconds+cond), ls, 'Color', lc  );
      hold on

    end

  end

  hold off


  if ( handles.figure_plot )
    fh = get(h, 'CurrentAxes' );
  end

  set(fh,'YLim',minmax);

  x = get( handles.chk_show_grid_lines, 'Value' );
  if ( x ) set(fh,'XGrid','on');   end

  if ( scan_information.processing.model.parameters.TR > 1 )
    xtl = [0];
    for ii = 0:this_plot.nbins
      xtl = [xtl ii*scan_information.processing.model.parameters.TR];
    end
    set( fh, 'XtickLabel', xtl )
    set( fh, 'Xtick', 0:this_plot.nbins );	% -=== [1.0.0]
  end

  set ( handles.plt_component, 'FontSize', 8.0 );

  x = get(handles.chk_show_legend, 'Value' );
  if ( x ) legend( condition_name, 'Location', 'Best' );   end

  if ( handles.figure_plot )

    ttle = ['Estimated HDR ' this_plot.method ' Component ' num2str( this_plot.comp ) aprText  ];
    if ( this_plot.average_groups )	
      ttle = [ttle ' Avg''d over Subjects/Groups' ];
    else
      ttle = [ttle ' Averaged over Subjects' ];
    end

    title( ttle );
    set( h, 'NumberTitle' , 'off' );
    set( h, 'Name' , ttle );

  end

  end
  % --- end nested function


  %% --- plot_average_conditions_by_groups( )
  function plot_average_conditions_by_groups( )

  ur.parameters.plotting.global.label.ylim = this_plot.minmax;

  set ( handles.plt_component, 'NextPlot', 'replace' );

  if ( handles.figure_plot )
    h = figure;
  else
    fh = gca;
    cla
  end

  set ( handles.plt_component, 'NextPlot', 'replace' );

  ls_idx = 1;
  start_group = 1;
  end_group = size(SubjectVector,1);

  lc_idx = this_plot.start_cond;

  for grp = start_group:end_group

    ls_style = mod( grp, size( handles.group_styles, 2 ));
    if ( ls_style == 0 ) ls_style =  size( handles.group_styles, 2 ); end
    ls = char( handles.group_styles( ls_style) );
      
    for ii = 1:size( this_plot.conditions, 2 )
      cond = this_plot.conditions(ii);		% --- create the matrix for all conditions ---

      lc_idx = cond;
      if ( lc_idx > this_plot.nconds | lc_idx > size(handles.condition_colors, 1 ) | lc_idx > this_plot.end_cond ) 
        lc_idx = this_plot.start_cond; 
      end
      lc = handles.condition_colors(lc_idx,:);

      rs = (grp-1)*this_plot.nbins+1;
      re = rs+ this_plot.nbins - 1;
      plot( ur_graphdata(rs:re,cond)', ls, 'Color', lc  );
      hold on

    end    

  end

  if ( handles.figure_plot )
   fh = get(h, 'CurrentAxes' );
  end

  set(fh,'YLim',minmax);

  x = get( handles.chk_show_grid_lines, 'Value' );
  if ( x ) set(fh,'XGrid','on');   end

  if ( scan_information.processing.model.parameters.TR > 1 )
    xtl = [0];
    for ii = 0:this_plot.nbins
      xtl = [xtl ii*scan_information.processing.model.parameters.TR];
    end
    set( fh, 'XtickLabel', xtl )
    set( fh, 'Xtick', 0:this_plot.nbins );	% -=== [1.0.0]
  end

  set ( handles.plt_component, 'FontSize', 8.0 );

  x = get(handles.chk_show_legend, 'Value' );
  if ( x ) 
    str = [];
    if this_plot.show_by_subjects
      for ii = 1:size( scan_information.GroupList, 1 )
      end   
    else
        
      for ii = 1:size(SubjectVector,1)
        for jj = 1:size(condition_name, 2 )
          str = [str; { [char(SubjectVector(ii).name) ':' char(condition_name(jj)) ] }];
        end
      end
    end
    legend( str, 'Location', 'Best' );   
  end

  if ( handles.figure_plot )

    ttle = ['Estimated HDR ' this_plot.method ' Component ' num2str( this_plot.comp ) aprText ];
    title( ttle );
    set( h, 'NumberTitle' , 'off' );
    set( h, 'Name' , ttle );

  end

  hold off

  drawnow();
  
  end
  % --- end nested function


  

  %% --- plot_sorted PR of H
  function plot_PRh()

    % ---------------------------------------
    % --- plot the Predictor Weights of H matrix ---
    % ---------------------------------------

    if ( handles.figure_plot )
      h = figure;
    else
      fh = gca;
      cla
    end
    
%     if strcmp(rotation_params.method, 'procrustes' ) & strcmp(rotation_params.htype, 'GMH' )
    
%    PR = sort(handles.criteria.Weights.PRh(:,handles.criteria.component ) );
    PR = handles.criteria.Weights.PRh(:,handles.criteria.component );
    bar( PR' );

    if ( handles.figure_plot )
      fh = get(h, 'CurrentAxes' );

      ttle = ['Average Predictor Weights Component ' num2str( handles.criteria.component ) ];
      title( ttle );
      set( h, 'NumberTitle' , 'off' );
      set( h, 'Name' , ttle );
    end

    Xtick = 0:10:size(PR,1)+1;
    set( fh, 'Xtick', Xtick);

    x = get( handles.chk_show_grid_lines, 'Value' );
    if ( x ) set(fh,'XGrid','on');   end

  end
  % --- end nested function

end
% --- end function



function plot_vr_average( this_plot, SubjectVector, handles ) 

  idx = get(handles.lst_computedFiles,'Value');
  [cdir fn] = filename_from_list( idx, handles );

  eval( ['load( ''', pwd filesep cdir fn ''', ''ep'' );' ] );

  VRsorted = sort( handles.criteria.VR(:,this_plot.comp), 'descend' );

  if handles.criteria.posLoadings | handles.criteria.negLoadings
    contents = get(handles.lbl_EP_Thresh,'String') ;		% returns threshold list
    str = contents{get(handles.lbl_EP_Thresh,'Value')}; 	        % returns selected item from threshold list
    thval = str2num(validate_numeric_entry( str ));		% threshold value as integer

    thr = 0;
    for ii = 1:size( ep(1).percentiles, 1 )
      if ep(1).percentiles(ii).cutoff == thval
        thr = ii;
      end
    end

    if handles.criteria.posLoadings
      x = find( VRsorted > ep(this_plot.comp).percentiles(thr).threshold );
    else
      x = find( VRsorted < (ep(this_plot.comp).percentiles(thr).threshold * -1 ) );
    end

    VRsorted = VRsorted(x(:));

  end

  if ( handles.figure_plot )
    h = figure;
  else
    fh = gca;
    cla
  end

  plot(VRsorted, '-')

  if ( handles.figure_plot )
    fh = get(h, 'CurrentAxes' );
    set( h, 'NumberTitle' , 'off' );
    set( h, 'Name' , ['VR Distribution - Component ' num2str(this_plot.comp)] );
  end

  ylb = zeros(1,(size(ep(this_plot.comp).percentiles, 1 )*2)+1 );
  for ii = 1:size(ep(this_plot.comp).percentiles, 1 )
    str = sprintf( '%.3f', ep(this_plot.comp).percentiles(ii).threshold);
    ylb(ii) = str2num(str);
    ylb(end-(ii-1)) = str2num(str)*-1;
  end
  
  ylbp = [];
  for ii = 1:size(ep(this_plot.comp).percentiles, 1 )
    if ep(this_plot.comp).percentiles(ii).threshold > 0
      ylbp = [ylbp ep(this_plot.comp).percentiles(ii).threshold ];
    end
  end
  
  ylbn = ylbp * -1;
  ylb = sort( [0 ylbp ylbn ] );
  
  set(fh, 'YTick', ylb );
  set(fh, 'YtickLabel', ylb );
  set(fh, 'YGrid', 'on');
end
% --- end function





% --- Executes during object creation, after setting all properties.
function lst_Components_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_Components (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end
end
% --- end function



% --- Executes on button press in btn_PlotOptions.
function btn_PlotOptions_Callback(hObject, eventdata, handles)
% hObject    handle to btn_PlotOptions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Zheader scan_information;

  p = plotSettings( scan_information.processing.model.parameters );
  if ( ~isempty(p) )
    scan_information.processing.model.parameters = p;

    % --------------------------------------------------------
    % update header information
    % --------------------------------------------------------
    Zfile = [Zheader.Z_Directory 'ZInfo.mat'];
    command = ['save( ''' Zfile ''', ''scan_information'', ''-append'')' ];
    eval(command);

  end
end
% --- end function



% --- Executes on button press in btn_Close.
function btn_Close_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%  uiresume( handles.output );

  if ~isempty( handles.group_selection_window )
    set( handles.group_selection_window, 'Visible', 'off' );
    uicontrol( hObject );
  end

  delete(handles.output);
end
% --- end function



% --- Executes on button press in btn_Flip.
function btn_Flip_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Flip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scan_information Zheader  process_information

  idx = get(handles.lst_computedFiles,'Value');
  [cdir fn] = filename_from_list( idx, handles );

  contents = get(handles.lst_Components,'String') ;	% returns lst_Components contents as cell array
  str = contents{get(handles.lst_Components,'Value')}; 	% returns selected item from lst_Components
  numcomps = size(contents, 1) - 1;

  comps_to_flip = get(handles.lst_Components,'Value') - 1;
  [s v] = select_components( 'list', numcomps, 'select', max(1,comps_to_flip) );
%  [s,v] = listdlg('PromptString','Flip Components','ListString', nc, 'InitialValue', max(1, comps_to_flip) );

  if v
    comps_to_flip = s;
  else
    return
  end
  
  method = mvs_rotation_method( fn );
  rstyle = mvs_rotation_style( fn );
  
  GAtyp = 'G';
  Aidx = 0;
  str = regexp( fn, '_', 'split' );
  isGA = strcmp( char(str(1)), 'GA' ) | strcmp( char(str(1)), 'GAA' );
  if isGA
    GAtyp = 'GA';
    load( Zheader.Contrast.path );
    Aidx = Aheader_index( Aheader, handles );
  else
    GAtyp = char(str(1) );
  end;
  
  pop = cpca_progress();
  pop.setWindowTitle( 'Flipping Data' );
  pop.unsetHRFMAX();
  pop.clearMessages();
  pop.show();
  pop.setPong( true );

  if ( comps_to_flip == 0 )
    MainText = [ 'Flip all components ( UR VR PR ) in ' fn ];  
  else
    MainText = [ 'Flip component ' num2str(comps_to_flip) ' ( UR VR PR ) in ' fn ];  
  end

  pop.setProcess( MainText );
  pop.setMessage( 'Loading Data' );

% --- snr, T & rotation_params do not exist in unrotated solution
  load( [pwd filesep cdir fn], 'UR', 'VR', 'PR*', 'snr', 'tsum', 'betas_c*', 'rotation_params', 'T', 'cvar*', 'alternatePR', 'mask_registry' );
  if ~exist( 'mask_registry', 'var' ),  mask_registry = 0;  end;
  
  ind = [];
  if mask_registry > 0 
    [~, ind] = mask_registrations( scan_information.mask, mask_registry );
  end
  nvox = Zheader.total_columns;
    if ~isempty( ind )
      nvox = numel( ind );
    end
  
  if exist('rotation_params', 'var' )
    rotation_params = rotation_params;
  else
    rotation_params = [];
  end
  rotation_params.model = handles.criteria.prefix;

  if ~isfield( rotation_params, 'defaults' )
    rotation_params.defaults = [];
  end

  if ~isfield( rotation_params, 'method' )
    rotation_params.method = method;
  end

  Mode = handles.criteria.prefix;

  if handles.criteria.prefix == 'H'
    rotation_params.mode = handles.criteria.Hmodel;
    rotation_params.htype = handles.criteria.module;
    
    rotation_params.hindex = H_path_spec( handles.criteria.Hheader, handles.criteria.module );
    
    Mode = handles.criteria.Hmodel; 
    if size( handles.criteria.module,2) > 0 
      Mode = handles.criteria.module;
    end
  end

  meth = 'rotated';
  if strcmp( rotation_params.method, 'unrotated' )
    meth = rotation_params.method;
  end
 
  if isGA & Aidx > 1
    rotation_params.hindex = Aheader.model( Aidx ).id;
  end;
  rotation_params.Aindex = Aidx;

%   if mask_registry > 0 && constant_define( 'PREFERENCES', 'general.gray_white_split' )
     rotation_params.defaults.reg =  mask_registry;
     rotation_params.defaults.regTag = constant_define( 'REGISTRATION_TAG', mask_registry);
%   end
  
  image_directory = fs_path( meth, 'images', numcomps, 0, rotation_params );
  mni_file = fs_filename( 'loadings', GAtyp, rotation_params.method, rotation_params.defaults );
  load( [pwd filesep image_directory mni_file], 'MNI' );

  plot_directory = fs_path( meth, 'plots', numcomps, 0, rotation_params );
  plot_directory = [ pwd filesep plot_directory ];

  component_directory = fs_path( meth, 'output', numcomps, 0, rotation_params );

  pop.setMessage( 'Flipping Components' );

  % --- make a flip log entry for these flipped components
  % --- and preserve original content
  [logok logdir] = fs_create_path(meth, 'fliplog', numcomps, 0, rotation_params );

  if logok 
    logfile = [ logdir 'fliplog.log' ];
      
    TS = datestr(now, 'HH_MM_PM' );
    append_flip_log( logfile, MainText );

    logbu = [ logdir  datestr(now, 'mmm_dd_yyyy' ) filesep TS filesep ];
    
    if ~exist( logbu, 'dir' )
       mkdir( logbu );
       mkdir( [ logbu 'Images' ] );
    end
   
    eval( [ 'copyfile( ''' component_directory char(42) '.txt'', ''' logbu ''' );' ] );
    eval( [ 'copyfile( ''' component_directory 'Images' filesep char(42) ''', ''' logbu 'Images'' );' ] );
	copyfile([component_directory fn], logbu); 
	movefile([logbu fn], [logbu 'original_G_unrotated.mat']);
  end
  
  % --- ---------------------
  % --- flip VR, UR and PR 
  % --- ---------------------
  if ( comps_to_flip == 0 )
    UR  = UR  .* -1;
    VR  = VR  .* -1;
    PR  = PR  .* -1;
    PRh = PRh .* -1;

    % --- ---------------------
    % --- flip alternate PR 
    % --- ---------------------
    if exist( 'alternatePR', 'var' )

      for cmp = 1:size(VR,2)
        n = alternatePR.component(cmp).pos;
        p = alternatePR.component(cmp).neg;

        n.PR = n.PR * -1;
        n.avg = n.avg * -1;
        p.PR = p.PR * -1;
        p.avg = p.avg * -1;
        alternatePR.component(cmp).pos = p;
        alternatePR.component(cmp).neg = n;

        alternatePR.component(cmp).all.PR = alternatePR.component(cmp).all.PR * -1;
        alternatePR.component(cmp).all.avg = alternatePR.component(cmp).all.avg * -1;
      end

    end


  else
    % --- ---------------------
    % --- flip Component VR, UR and PR 
    % --- ---------------------
    UR(:,comps_to_flip) = UR(:,comps_to_flip) .* -1;
    VR(:,comps_to_flip) = VR(:,comps_to_flip) .* -1;
    if ~isempty( PR )
      PR(:,comps_to_flip) = PR(:,comps_to_flip) .* -1;
    end
    if ~isempty( PRh )
      PRh(:,comps_to_flip) = PRh(:,comps_to_flip) .* -1;
    end
    
    % --- ---------------------
    % --- flip Component alternate PR 
    % --- ---------------------
    if exist( 'alternatePR', 'var' )
      n = alternatePR.component(comps_to_flip).pos;
      p = alternatePR.component(comps_to_flip).neg;

      n.PR = n.PR * -1;
      n.avg = n.avg * -1;
      p.PR = p.PR * -1;
      p.avg = p.avg * -1;
      alternatePR.component(comps_to_flip).pos = p;
      alternatePR.component(comps_to_flip).neg = n;

      alternatePR.component(comps_to_flip).all.PR = alternatePR.component(comps_to_flip).all.PR * -1;
      alternatePR.component(comps_to_flip).all.avg = alternatePR.component(comps_to_flip).all.avg * -1;

    end


    % --- ---------------------
    % --- flip Component cluster MNI data
    % --- ---------------------

    if ~isMultiFrequency()
      if isfield( MNI, 'component' )
        if ~isempty( MNI.component )		% --- no cluster info for BH components
          for cno = 1:size( comps_to_flip, 2 )
            
            for thr = 1:size(MNI.component(comps_to_flip(cno)).threshold, 1 )

              p = flip_MNI_values( MNI.component(comps_to_flip(cno)).threshold(thr).neg );
              n = flip_MNI_values( MNI.component(comps_to_flip(cno)).threshold(thr).pos );
 
              MNI.component(comps_to_flip(cno)).threshold(thr).pos = p;
              MNI.component(comps_to_flip(cno)).threshold(thr).neg = n;
       
            end % --- each threshold of component
          end % --- each component to flip
        
          save( [image_directory mni_file], 'MNI', '-append', '-v7.3'  );

        end  % --- MNI contains cluster information
      end  % --- MNI contains component field
    end  % --- no MNI data on beamformed MEG images
    
    % --- ---------------------
    % --- loadings for component recalculated during image creation
    % --- ---------------------

  end

  if rotation_params.model == 'H'
    H = load_H_matrix( handles.criteria.Hheader );
    ep = calc_ext_Pos_Neg(VR); % --= 
  else
    ep = calc_ext_Pos_Neg(VR);
  end
  
  % -- reset the altered data 
  handles.criteria.Weights.PR = PR;
  handles.criteria.Weights.PRh = PRh;
  handles.criteria.VR = VR;
  if exist( 'alternatePR', 'var' )
    handles.criteria.aPR = alternatePR;
  end
  
  guidata(hObject, handles);
  
  if exist( 'alternatePR', 'var' )
    save( [cdir fn], 'UR*', 'VR', 'PR*', 'alternatePR', 'ep', '-append', '-v7.3' );
  else
    save( [cdir fn], 'UR*', 'VR', 'PR*', 'ep', '-append', '-v7.3' );
  end
  
  % --- ---------------------
  % --- recalculate Component pos/neg betas 
  % --- ---------------------
  tag = 'GC';
  tsum = Zheader.tsum;
  
  if ( strcmp( handles.criteria.prefix(1), 'H' ) )

    sumDiag = 0;
    eval( ['sumDiag = handles.criteria.Hheader.model(handles.criteria.Hheader.Hindex).sum_diagonal.' rotation_params.htype ';' ] );  

    if ~strcmp( handles.criteria.Hmodel, 'GMH' );

      in_dir = [Zheader.Z_Directory 'Hsegs' filesep ];			% eg: GZ_segs, GAZ_segs
      in_h = [ in_dir handles.criteria.Hmodel '.mat' ];

      pop.setMessage( 'Calculating Positive Betas' );
      betas_c_pos = calc_b_betas( [cdir fn], in_h, 1 );

      pop.setMessage( 'Calculating Negative Betas' );
      betas_c_neg = calc_b_betas( [cdir fn], in_h );
    else

      pop.setMessage( 'Calculating Positive Betas' );
      betas_c_pos = calc_gmh_gm_betas( [cdir fn], handles.criteria.Hheader, 1, 1 );

      pop.setMessage( 'Calculating Negative Betas' );
      betas_c_neg = calc_gmh_gm_betas( [cdir fn], handles.criteria.Hheader, 0, 1 );

    end

  else
    load( Zheader.Model.path, 'Gheader' );

    if isGA
      sumDiag = Aheader.model(Aidx).sd(1 + strcmp( GAtyp, 'GAA' ) );
    else
      sumDiag = Gheader.GZheader.sum_diagonal;
      switch mask_registry
        case 1
          sumDiag = Gheader.GZheader.rsum(1) + sum(Gheader.GZheader.rsum(4:5));
          tsum = Zheader.rsum(1) + sum(Zheader.rsum(4:5));
%          tag = 'GC Gm';
         case 2
           sumDiag = Gheader.GZheader.rsum(2);
           tsum = Zheader.rsum(2);
%          tag = 'GC Wm';
      end
        
    end
    
    pop.setMessage( 'Calculating Positive Betas' );
    betas_c_pos = calc_c_betas( [cdir fn], Gheader, 1, 0, GAtyp, mask_registry );

    pop.setMessage( 'Calculating Negative Betas' );
    betas_c_neg = calc_c_betas( [cdir fn], Gheader, 0, 0, GAtyp, mask_registry );

  end

  ftext = '';
  
  if exist( 'rotation_params', 'var' )
    if isfield( rotation_params, 'defaults' )
      theseParms = rotation_params;
    end
  end

  % --- ---------------------
  % -- refresh original output file
  % --- ---------------------
  pop.setMessage( 'Updating Output Files . . .' );

%   if mask_registry > 0
%     theseParms.defaults.reg =  mask_registry;
%     theseParms.defaults.regTag = constant_define( 'REGISTRATION_TAG', mask_registry);
%   end
  
  ftext = GAtyp;
  if strcmp( GAtyp, 'GA' ),    ftext = 'AnotG';  end;
  if strcmp( GAtyp, 'GAA' ),   ftext = 'GnotA';  end;
  
  text_file = fs_filename( 'txt', ftext, method, theseParms.defaults );
  text_file = [ 'output_' text_file ];

  ftext = [ GAtyp 'C'];
  if strcmp( GAtyp, 'GA' ) 
    ftext = GAtyp;
  end;
  if strcmp( GAtyp, 'GAA' ) 
    ftext = 'GnotA';
  end;
%   ftext = [ftext constant_define( 'REGISTRATION_SUMMARY_TAG', mask_registry) ];

  fid = fopen( [cdir text_file], 'w' );
  text_file_header( numcomps, fid, 0, cdir, text_file, rotation_params.Aindex, nvox ) ;
  if handles.criteria.prefix == 'H'
    H_matrix_header(handles.criteria.Hheader, fid);
  end
  pca_summary( sumDiag, [ftext constant_define( 'REGISTRATION_SUMMARY_TAG', mask_registry)], cvariance_rotated_tot, fid, tsum );
  pca_summary( sumDiag, [ftext constant_define( 'REGISTRATION_SUMMARY_TAG', mask_registry)], cvariance_rotated_tot, 1, tsum );
%  pca_summary( sumDiag, ftext, cvariance_rotated_tot, 1 );

  
  print_UR_coefficents( fid, corrcoef( UR ) );
  if exist( 'T', 'var' )
    print_matrix_values( fid, T, 'T matrix:' );
  end
  display_extremes_pos_neg(ep, cvariance_rotated_tot, tsum, fid, 2, 0 );

  if ~isGA
    print_subject_variances( fid, mask_registry )      
  end;
  
  if ( fid ) fclose( fid ); fid = 0; end


  % --- ---------------------
  % --- refresh PR(HRF) output file
  % --- refresh alternate PR(HRF) output file
  % --- ---------------------

  thoseParms = theseParms;

  theseParms.defaults.var = 'HRF';
  theseParms.defaults.component = 999;
  text_file = fs_filename( 'txt', Mode, method, theseParms.defaults );

  if ~isempty(PR) & ~isGA
    output_HRF( cdir, text_file, PR, Gheader, 0, nvox);
    if exist( plot_directory, 'dir' )
      plot_HRF( plot_directory, PR, Gheader, thoseParms );
    end
  end
  
  if ~isempty(PRh)
      
    eval( ['sumDiag = handles.criteria.Hheader.model(handles.criteria.Hheader.Hindex).sum_diagonal.' rotation_params.htype ';' ] );  
    if rotation_params.mode(1) == 'E'
      tsums = Zheader.tsum_E;
    else
      tsums = Zheader.tsum;
    end
    ftag = '';
    
    mniParms.text = ftag;
    mniParms.var = 'Predictor_Weights';
    for component_no = 1:size(PRh,2)
      mniParms.component = component_no;
      mni_file = fs_filename( 'txt', rotation_params.htype, 'unrotated', mniParms );

      fid = fopen( [cdir mni_file], 'w' );
      text_file_header( numcomps, fid, 0, cdir, mni_file, rotation_params.Aindex, nvox );
      if handles.criteria.prefix == 'H'
        H_matrix_header(handles.criteria.Hheader, fid);
      end
      pca_summary( sumDiag, rotation_params.htype, cvariance_rotated_tot, fid );
      print_formatted_ep( ep, component_no, fid, 0 );
      show_PR_weights( PRh(:,component_no), VR(:,component_no), handles.criteria.Hheader, 1, fid );

      if ( fid)  fclose(fid); end
    end
  end
  
  % --- ---------------------
  if exist( 'Alternate_PR', 'var' )
  % --- ---------------------
    aPR = [];
    for comp = 1:size(alternatePR.component, 1 )
      aPR = [aPR alternatePR.component(comp).all.PR(:) ];
    end

    theseParms.defaults.text = 'Alternate_PR';
    thoseParms.defaults.text = 'Alternate_PR';
    text_file = fs_filename( 'txt', Mode, method, theseParms.defaults );
    output_HRF( cdir, text_file, aPR, Gheader);
    plot_HRF( plot_directory, aPR, Gheader, thoseParms );
  end
  
  % --- ---------------------
  % -- recreate component images
  % --- ---------------------
  pop.setMessage( 'Recreating Images' );
  if ~isfield( rotation_params, 'htype' )
    rotation_params.htype = [];
  end

  if ( strcmp( handles.criteria.prefix(1), 'H' ) )
    if ( strcmp( handles.criteria.Hmodel, 'GMH' ) )
      recreate_gmh_images( rotation_params, Mode, numcomps, comps_to_flip, 0 );
    else    
      recreate_h_images( rotation_params, handles.criteria.Hmodel, numcomps, 0 );
    end

  else
    recreate_g_images( rotation_params, numcomps, comps_to_flip, 0, GAtyp, mask_registry );
  end
  load([pwd filesep cdir fn], 'component_loadings');
  %eval( ['load( ''' cdir fn ''', ''component_loadings'' )'] );

  if ~isMultiFrequency() && ~isGA	% --- bypass cluster data on meg data for now
    rotation_params.fs = meth;
    if ~isfield( rotation_params, 'htype' )
      rotation_params.htype = 'G';
    end
    rotation_params.component_vector = comps_to_flip;
    if ~strcmp( handles.criteria.Hmodel, 'GMH' ) & ~strcmp( handles.criteria.Hmodel, 'BH' )
        
      if isempty( rotation_params.htype )
        rotation_params.htype = Mode;  % --- changes to flip GMH vars may cause loss of G prefix
      end
      
%      write_cluster_beta_mean_median( rotation_params, Gheader, size(VR,2) );
%      write_cluster_masks( rotation_params, size(VR,2), rotation_params.htype );
      if constant_define( 'PREFERENCES', 'cluster.create_masks' , 1 )
        write_cluster_masks( rotation_params, size(VR,2), rotation_params.htype, pop );
      end
      if constant_define( 'PREFERENCES', 'cluster.calculate_mean' , 0 ) | ...
        constant_define( 'PREFERENCES', 'cluster.calculate_median' , 0 )
        write_cluster_beta_mean_median( rotation_params, Gheader, size(VR,2), pop );
      end
    end
  end

  if exist( 'alternatePR', 'var' )
    handles.criteria.aPR = alternatePR;
  end

  handles.criteria.VR = VR;

  guidata(hObject, handles);

  pop.setPong( false );
  pop.hide();
  clear pop
 

  cla
  lst_Components_Callback( handles.lst_Components, eventdata, handles );

  % ---------------------------------------
  % --- UR has changed - reset the correlation coefficient display ---
  % ---------------------------------------
  set_coefficient_statistics( handles );
  drawnow();

  if size(process_information.sudo.user, 2) > 0 & process_information.sudo.confirmed == 1
    cmd = ['!chown -R ' process_information.sudo.user '.' process_information.sudo.group ' *' ];
    eval( cmd );
  end

end
% --- end function




% --- Executes on button press in btn_Plot.
function btn_Plot_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scan_information Zheader;

  % --------------------------------------------------
  % this function will only plot the UR components
  % beta checks are handled in Plot_VR()
  % --------------------------------------------------
  handles.figure_plot = 1;
  guidata(hObject, handles);

  lst_Components_Callback(handles.lst_Components, eventdata, handles);

  handles.figure_plot = 0;
  guidata(hObject, handles);

end
% --- end function



% --- Executes on button press in btn_PlotBetas.
function btn_PlotBetas_Callback(hObject, eventdata, handles)
% hObject    handle to btn_PlotBetas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  Plot_Betas( hObject, handles );	
end
% --- end function

  

% ------------------------------------------
% separate function for Beta check plotting ( VR )
% ------------------------------------------
function Plot_Betas( hObject, handles, do_threshold )
global scan_information Zheader  

  set( handles.btn_Cancel, 'Visible', 'On' );

  if ( nargin < 3 ) do_threshold = 1; end

  SubjectVector = [ 1:Zheader.num_subjects ];

  if ~ isfield( scan_information.processing.model.parameters, 'betas' )	  
    scan_information.processing.model.parameters.betas = 2;	
  end

  idx = get(handles.lst_computedFiles,'Value');
  [cdir fn] = filename_from_list( idx, handles );

  % if the component index is > 0, the we plot all componenets
  % otherwise just a single component
  content2 = get(handles.lst_Components,'String');  	% lst_Components contents as cell array
  cmpnum = get(handles.lst_Components,'Value');
  cmpnum = cmpnum - 1;

  nd = mvs_component_number( fn );
  method = mvs_rotation_method ( fn );
  rstyle = mvs_rotation_style ( fn );

  GAtyp = 'G';
  this_plot.isGA  = 0;
  this_plot.isGAA = 0;
  str2 = regexp(fn, '_', 'split' );
  if strcmp( char(str2(1)), 'GA' )
    this_plot.isGA = 1;
    GAtyp = 'GA';
  end
  if strcmp( char(str2(1)), 'GAA' )
    this_plot.isGAA = 1;
    GAtyp = 'GAA';
  end
  
  if ( cmpnum == 0 )
    start_comp = 1;
    end_comp = size(content2, 1) - 1;
  else
    start_comp = cmpnum;
    end_comp = cmpnum;
  end
  
  load( [pwd filesep cdir fn], 'VR', 'ep', 'mask_registry' );
  if ~exist( 'mask_registry', 'var' ), mask_registry = 0;  end;
 
  ind = [];
  if mask_registry > 0
    R = mask_registrations( scan_information.mask );
    switch mask_registry
      case 1,           % Gray Matter includes Brain Stem and Cerebellum
        ind = unique( [ R.ind(1).zref; R.ind(4).zref; R.ind(5).zref ] );
      case 2,           % White Matter only
        ind = R.ind(2).zref;
    end
  end
  
  load( Zheader.Model.path, 'Gheader' );

  vr = scan_information.processing.model;

%  nbins = scan_information.processing.model.parameters.bins;
%  nconds = scan_information.processing.model.parameters.conditions;
  if (this_plot.isGA)
    load( Zheader.Contrast.path );
    Aidx = Aheader_index( Aheader, handles );
    nconds = Aheader.model(Aidx).contrasts;
    nbins = Aheader.model(Aidx).bins;
    C_loc = Aheader.model(Aidx).path_to_GA;
    vr.parameters.condition_name = [];
    for cond = 1:nconds
%       cond = this_plot.conditions(ii);		% --- create the matrix for all conditions ---
      vr.parameters.condition_name = [ vr.parameters.condition_name Aheader.model( Aidx ).contrast_name(cond) ];
    end

  else
    nconds = Gheader.conditions;
    nbins = Gheader.bins;

    if (this_plot.isGAA)
      C_loc = Aheader.model(Aidx).path_to_GAA;
    else 
      if handles.criteria.prefix == 'H'
        [H_ID C_loc] = H_path_spec( handles.criteria.Hheader, handles.criteria.module );
      else
        C_loc = Gheader.GZheader.path_to_segs;        
      end
    end
  end

  vr.parameters.conditions = nconds;
  vr.parameters.bins = nbins;

  t_label = ' - All Loadings';

  mx = max(mean(VR)) * 3;
  mn = min(mean(VR)) * 3;

  x = exist( 'ep' );
  if ( x ~= 1 )   % variable ep does not exist
    ep = calc_ext_Pos_Neg( VR );	% recalculate extreme pos/neg values
  end

  if ( do_threshold )
    BetaStyle = 'Check ';
  else
    BetaStyle = 'Confirmation ';
  end

  Txt = sprintf( 'Performing Beta %s', BetaStyle );
  pop = cpca_progress();
  pop.setWindowTitle( 'Calculating Betas' );
  pop.setMessages( Txt, 'Loading Data' , '' );
  pop.show();

  % -----------------------------------
  % revised betas check - pos neg on extreme 5% of loadings
  % -----------------------------------
  for comp = start_comp:end_comp

    if ( handles.cancel_operation ) 
      set( handles.btn_Cancel, 'Visible', 'Off' );
      pop.hide();
      return;
    end


    contents = get(handles.lbl_EP_Thresh,'String') ;		% returns threshold list
    str = contents{get(handles.lbl_EP_Thresh,'Value')}; 	% returns selected item from threshold list
    thval = str2num(validate_numeric_entry( str ));		% threshold value as integer

    thr = locate_threshold_index( handles, thval );
    if ( do_threshold )
      threshold = ep(comp).percentiles(thr).threshold;	% top n% of component weights
    else
      threshold = 0;
    end
    voxels = ep(comp).percentiles(thr).voxels;

    for posneg = 1:2  % 1 = positive  2 = negative

      if ( handles.cancel_operation ) 
        set( handles.btn_Cancel, 'Visible', 'Off' );
        pop.hide();
        clear pb;
        return;
      end

      if ( posneg == 1 )
        t_label = ' - Positive Loadings';
      else
        t_label = ' - Negative Loadings';
      end

      MainText = sprintf( 'Computing Averages for component %d%s', comp, t_label );
      pop.setMessage( 'Applying C to component' );

      % ------------------------------------------------
      % contains plotting parameters
      % ------------------------------------------------
      vr_graphdata=[];

      % ------------------------------------------------
      % load the single component
      % ------------------------------------------------
      vr_cmp = VR(:,comp);

      % ------------------------------------------------
      % index the voxels above the threshold for this component  
      % ------------------------------------------------
      if ( posneg == 1 )
        vox_idx = find( vr_cmp > threshold );
        pop.setComment(  'Positive Loadings' );
      else
        threshold = threshold * -1;
        vox_idx = find( vr_cmp < threshold );
        pop.setComment(  'Negative Loadings' );
      end

      if ( size(vox_idx,1) > 1 )		% ensure that there are loadings above threshold
        Cn = [];
  
        for sn = 1:Zheader.num_subjects
          C = [];
          
          if handles.criteria.prefix ~= 'H'

            for FrequencyNo = 1:max(scan_information.frequencies, 1)
              ftag = frequency_tag(FrequencyNo) ;
              Cs = load_subject_C( Gheader, sn, ftag );
              if ~isempty( Cs )
                if ~isempty( ind )
                  Cs = Cs( :, ind);
                end
                C = [C Cs];
              end;
            end

          else

            load( Zheader.Limits.path );	% do not assume Hheader is pre-loaded
              
            if ~isempty( strfind( C_loc, 'GMH' ) )
              eval ( [ 'load( ''' pwd filesep C_loc 'GMH_S' num2str(sn) '.mat'', ''MH_S' num2str(sn) ''');'] );
              eval ( [ 'C_S' num2str(sn) ' = MH_S' num2str(sn) ';'] );
              eval ( [ 'clear M_S' num2str(sn) ';'] );

            else
              eval( [ 'C_S' num2str(sn) ' = [];' ] );
              for FrequencyNo=1:max(scan_information.frequencies, 1)
                ftag = frequency_tag(FrequencyNo) ;
                retrieve_subject_GMH_C( Hheader, sn, ftag, 'Cs' );
                C = [C Cs];
              end
              
            end
          end

          C = C(:,vox_idx(:));

          % --- handle non encoded conditions
          Cm = mean(C,2);
          Cn = [Cn Cm];
      
          clear C Cx Cm
          
        end

        Cn = mean( Cn, 2);

        er = 0;
        for ii = 1:max(Gheader.subject_encoded)
          sr = er + 1;
          er = sr + nbins - 1;
          vr_graphdata = [vr_graphdata Cn(sr:er)];
        end

      else  % there are no loadings

        vr_graphdata = zeros( nbins, nconds );

      end	% discovered top n% of loadings

      x = get( handles.chk_show_grid_lines, 'Value' );
      if ( x )
        vr.parameters.plotting.global.label.xgrid = 'on';
      else
        vr.parameters.plotting.global.label.xgrid = 'off';
      end

      if ( Gheader.model_type == constant_define( 'HRF_MODEL' ) )
        h = figure; bar( vr_graphdata, 'c' );
        ttle = ['Betas Component ' num2str(comp) t_label];
        title( ttle );
        set( h, 'NumberTitle' , 'off' );
        set( h, 'Name' , ttle );

      else
        contents = get(handles.lbl_EP_Thresh,'String') ;		% returns threshold list
        str = contents{get(handles.lbl_EP_Thresh,'Value')}; 	% returns selected item from threshold list
        thval = str2num(validate_numeric_entry( str ));		% threshold value as integer

        thr = locate_threshold_index( handles, thval );
        th = handles.threshold_values( thr );
        
        vr.parameters.plotting.global.label.title = sprintf('Beta %s Component %d%s %d%% (%d)%s', ...
            BetaStyle, comp, t_label, th, size(vox_idx,1), constant_define( 'REGISTRATION_FULL', mask_registry) );
        vr.parameters.plotting.global.label.legend = 1;
      
           
         show_plot( vr_graphdata, vr.parameters, vr.parameters.plotting.global.label.title ); 
        
      end

      ylabel( 'Mean Betas' );

    end   %  pos / neg

  end   %  each component ( single or all )


  set( handles.btn_Cancel, 'Visible', 'Off' );
  pop.hide();
  clear pop
  
end
% --- end function



% ------------------------------------------
% reset the component selection list on extraction file selection
% ------------------------------------------
function set_source_components( hObject, eventdata, handles )

  lst = '<N/A>';
  contents = get(hObject,'String');  		% lst_Components contents as cell array

  idx = get(hObject,'Value');

  if ( ~isempty(contents) )

    [cdir fn] = filename_from_list( idx, handles );		% selected file name

    x = regexp( cdir, '_', 'split' );
    x1 = regexp( char(x(1)), '[0-9]', 'match' );
    strx = [];
    for ii = 1:size(x1,2)
      strx = [strx char(x1(ii) )];
    end
    numcomps = str2num(strx);

    for ii = 1:numcomps
      p = sprintf( '%d', ii );
      lst = horzcat( lst, {p});
    end

  end

  set( handles.lst_Components, 'String', lst, 'Value', 1) ;
  handles.criteria.component = 0;

  % --- check the number of cluster associated with this component

  % Update handles structure
  guidata(handles.output, handles);
end
% --- end function



% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
%uiresume(hObject);
  if ~isempty( handles.group_selection_window )
    set( handles.group_selection_window, 'Visible', 'off' );
    uicontrol( hObject );
  end

  delete(handles.output);
end
% --- end function



% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end
% --- end function



function set_general_statistics( handles )
global Zheader scan_information

  % ---------------------------
  % set the general statistics information
  % ---------------------------

  contents = get(handles.lst_computedFiles,'String');  	% lst_Components contents as cell array
  idx = get(handles.lst_computedFiles,'Value');
  fn = contents{idx} ;					% selected item
  nd = mvs_component_number( fn );
  [cdir in_file] = filename_from_list( idx, handles );
  
  load( [pwd filesep cdir in_file], 'cvariance_rotated_tot', 'GroupIndex' );

  str = sprintf( '%.2f', cvariance_rotated_tot.stats.ss_Z );
  set( handles.txt_TSS, 'String', str );

  if ( sum(Zheader.rfac) ) > 0 
    nremoved = [sum(Zheader.rfac) Zheader.rfac];
  else
    nremoved = Zheader.tsum_linear_trends + Zheader.tsum_quadratic_trends + Zheader.tsum_hm_trends + Zheader.tsum_user_trends;
    nremoved = [nremoved Zheader.tsum_linear_trends];
    nremoved = [nremoved Zheader.tsum_quadratic_trends];
    nremoved = [nremoved Zheader.tsum_hm_trends];	% --- head movement values
    nremoved = [nremoved Zheader.tsum_user_trends];	% --- user defined values
    nremoved = nremoved/cvariance_rotated_tot.stats.ss_Z * 100;
  end

  if exist( 'GroupIndex', 'var' )
    if GroupIndex > 0 
      if ( size( scan_information.GroupList,1) >= GroupIndex );
        nremoved = [scan_information.GroupList(GroupIndex).tsum_trends 0 0 0 0];
      end
    end
  end

  for ii = 1:5
    if ( nremoved(ii) > 0 & cvariance_rotated_tot.stats.ss_Z > 0 )
      strval = sprintf( '%.2f%%', nremoved(ii) );
    else
      strval = '0.00%';
    end

    switch( ii )

      case 1
        set( handles.txt_TSS_regressed_out, 'String', ['Total: ' strval] );

      case 2
        set( handles.txt_linear_regressed, 'String', ['Linear: ' strval] );

      case 3
        set( handles.txt_quadratic_regressed, 'String', ['Quadratic: ' strval] );

      case 4
        set( handles.txt_head_movement_regressed, 'String', ['Head: ' strval] );

      case 5
        set( handles.txt_user_covariant_regressed, 'String', ['User: ' strval] );

    end

  end

  if exist( 'cvariance_rotated_tot', 'var' ) 
    str = sprintf( '%.2f', cvariance_rotated_tot.stats.ss_GC );
    set( handles.txt_Explained, 'String', str );

    if isfield( cvariance_rotated_tot.stats, 'GC_variance_explained_in_Z' )
      SSPct = sprintf( '%.2f', cvariance_rotated_tot.stats.GC_variance_explained_in_Z * 100 );
      ExplainedND = sprintf( '%.2f',  cvariance_rotated_tot.stats.ss_GC * (cvariance_rotated_tot.variance_explained_in_GC/100) );
      PctExplByModel = sprintf( '%.2f', cvariance_rotated_tot.variance_explained_in_GC );
      PctTotSS = sprintf( '%.2f', cvariance_rotated_tot.variance_explained_in_Z );
    else  % --- process older variance structure
      SSPct = sprintf( '%.2f', cvariance_rotated_tot.stats.ss_GC / cvariance_rotated_tot.stats.ss_Z * 100 );
      var = sum(cvariance_rotated_tot.sum_variance ./ ( cvariance_rotated_tot.stats.ss_GC / cvariance_rotated_tot.stats.nr ) );
      ExplainedND = sprintf( '%.2f',  cvariance_rotated_tot.stats.ss_GC * (var/100) );
      PctExplByModel = sprintf( '%.2f',  sum(cvariance_rotated_tot.sum_variance ./ ( cvariance_rotated_tot.stats.ss_GC / cvariance_rotated_tot.stats.nr ) ) );
      PctTotSS = sprintf( '%.2f', sum(cvariance_rotated_tot.sum_variance ./ ( cvariance_rotated_tot.stats.ss_Z / cvariance_rotated_tot.stats.nr ) ) );
    end

    set( handles.txt_SSPct, 'String', SSPct );
    set( handles.txt_ExplainedND, 'String', ExplainedND );
    set( handles.txt_PctExplByModel, 'String', PctExplByModel );  
    set( handles.txt_PctTotSS, 'String', PctTotSS );

  else
    set( handles.txt_Explained, 'String', '<na>' );
    set( handles.txt_ExplainedND, 'String', str );

    set( handles.txt_SSPct, 'String', '<na>' );
    set( handles.txt_PctExplByModel, 'String', '' );  
    set( handles.txt_PctTotSS, 'String', '' );
  end

  set_component_statistics( handles );
  set_coefficient_statistics( handles );

end
% --- end function



function set_component_statistics( handles )
global Zheader scan_information 

  % ---------------------------
  % set the component statistics
  % ---------------------------
  contents2 = get(handles.lst_Components,'String'); 		% returns lst_Components contents as cell array
  x = get(handles.lst_Components,'Value');
  str = char(contents2(x)); 					% returns selected item from lst_Components
  cmpno = str2num( char(str) );

  if ( strcmp( handles.criteria.prefix(1), 'H' ) ) 
    iload = 'image-loadings-H';
    dec_format = '%.4f';
    beta_col_start = 1;
  else
    iload = 'image-loadings';
    dec_format = '%.2f';
    beta_col_start = 3;
  end

  if ( cmpno > 0 )

    p = get( handles.chk_PR_of_H, 'Value' );
    if p
      HRF = handles.criteria.Weights.PRh;
    else
      HRF = handles.criteria.Weights.PR;
    end
    
    contents = get(handles.lst_computedFiles,'String') ; 	% lst_Components contents as cell array
    idx = get(handles.lst_computedFiles,'Value');		% selected item
    [cdir fn] = filename_from_list( idx, handles );		% selected file name
    
    x = regexp( cdir, '_', 'split' );
    x1 = regexp( char(x(1)), '[0-9]', 'match' );
    strx = [];
    for ii = 1:size(x1,2)
      strx = [strx char(x1(ii) )];
    end
    numcomps = str2num(strx);
    
    method = mvs_rotation_method( fn );
    image_directory = [cdir 'Images' filesep];
     
    image_mat = [image_directory 'image-loadings_' fn];

    load( [pwd filesep cdir fn], 'ep', 'cvariance*', 'beta*', 'component_loadings' );
        
    contents = get(handles.lbl_EP_Thresh,'String') ;		% returns threshold list
    str = contents{get(handles.lbl_EP_Thresh,'Value')}; 	% returns selected item from threshold list
    thval = str2num(validate_numeric_entry( str ));		% threshold value as integer

    thr = locate_threshold_index( handles, thval );
 
    flip_alert = 0;
    
    if ( exist( 'betas_c_pos', 'var' ) )
      if ( size(betas_c_pos(cmpno).threshold(thr).betas,1) > 1 )
        avg_pos = mean(mean(betas_c_pos(cmpno).threshold(thr).betas(beta_col_start:end,:)));
        avg_neg = mean(mean(betas_c_neg(cmpno).threshold(thr).betas(beta_col_start:end,:)));
      else
        avg_pos = mean(betas_c_pos(cmpno).threshold(thr).betas);
        avg_neg = mean(betas_c_neg(cmpno).threshold(thr).betas);
      end
      
      flip_alert = ( ( avg_pos < 0 & avg_neg > 0 ) | ...
         ( avg_pos < 0 & avg_neg == 0 & ep(cmpno).percentiles( thr ).neg_voxels == 0 ) | ...
         ( avg_pos == 0 & avg_neg > 0 & ep(cmpno).percentiles( thr ).pos_voxels == 0 ) );
      
    else
      if ( exist( 'betas', 'var' ) )
        avg_pos = 0;
        avg_neg = 0;
        mn = mean(betas(:,cmpno));
        mnP = mean(HRF(:,cmpno));
        if mn > 0 
          avg_pos = mn;
          flip_alert = mnP < 0;
        else
          avg_neg = mn;
          flip_alert = mnP > 0;
        end
      else
        avg_pos = 0;
        avg_neg = 0;
      end
    end


    str = sprintf( dec_format, component_loadings(cmpno).pos.threshold(thr).mean );
    set( handles.txt_load_avg_pos, 'String', str );

    str = sprintf( dec_format, component_loadings(cmpno).neg.threshold(thr).mean );
    set( handles.txt_load_avg_neg, 'String', str );

    set( handles.txt_PosLoadings, 'String', num2str(component_loadings(cmpno).pos.threshold(thr).loadings ) );
    str = sprintf( dec_format, component_loadings(cmpno).pos.threshold(thr).max );
    set( handles.txt_MaxPosLoadings, 'String', str );

    if ( avg_pos < 0 & flip_alert ) fcolor = [0.847 0.161 0.0]; else fcolor = [ 0 0 0 ]; end
    str = sprintf( dec_format, avg_pos );
    set( handles.txt_beta_avg_pos, 'String', str );
    set( handles.txt_beta_avg_pos, 'ForegroundColor', fcolor );


    set( handles.txt_NegLoadings, 'String', num2str(component_loadings(cmpno).neg.threshold(thr).loadings ) );
    str = sprintf( dec_format, component_loadings(cmpno).neg.threshold(thr).max );
    set( handles.txt_MaxNegLoadings, 'String', str );

    if ( avg_neg > 0 & flip_alert ) fcolor = [0.847 0.161 0.0]; else fcolor = [ 0 0 0 ]; end
    str = sprintf( dec_format, avg_neg );
    set( handles.txt_beta_avg_neg, 'String', str );
    set( handles.txt_beta_avg_neg, 'ForegroundColor', fcolor );

    if ( flip_alert )
      set( handles.lbl_flip_alert, 'Visible', 'on' );
    else
      set( handles.lbl_flip_alert, 'Visible', 'off' );
    end

    str = sprintf( dec_format, ep(cmpno).percentiles( thr ).threshold );
    set( handles.txt_EP_Threshold_05, 'String', str );
    set( handles.txt_EP_Above_05, 'String', num2str(ep(cmpno).percentiles( thr ).voxels) );
    set( handles.txt_EP_PosVox_05, 'String', num2str(ep(cmpno).percentiles( thr ).pos_voxels) );
    set( handles.txt_EP_NegVox_05, 'String', num2str(ep(cmpno).percentiles( thr ).neg_voxels) );

    meth = mvs_rotation_method( fn );

    cvar = '';
    eval( [ 'cvar = cvariance_rotated_tot;' ] );
    if isfield( cvar, 'component_variance' )
      str = sprintf( '%.2f', cvar.component_variance(cmpno) );
      str2 = sprintf( [dec_format ' %% '], cvar.percent_explained_in_GC(cmpno) );
      str3 = sprintf( [dec_format ' %% '], cvar.percent_explained_in_Z(cmpno) );
    else
      str = sprintf( '%.2f', cvar.sum_variance(cmpno) );
      str2 = sprintf( [dec_format ' %% '], cvar.percent_of_n_dimension(cmpno) );
      str3 = sprintf( [dec_format ' %% '], cvar.percent_of_total(cmpno) );
    end

    set( handles.txt_variance, 'String', str );
    set( handles.txt_VarND, 'String', str2 );
    set( handles.txt_VarTotal, 'String', str3 );

  else

    str = '';
    set( handles.frm_PosNeg, 'Title', str );

    set( handles.txt_PosLoadings, 'String', str );
    set( handles.txt_beta_avg_pos, 'String', str );
    set( handles.txt_MaxPosLoadings, 'String', str );

    set( handles.txt_NegLoadings, 'String', str );
    set( handles.txt_beta_avg_neg, 'String', str );
    set( handles.txt_MaxNegLoadings, 'String', str );

    set( handles.lbl_flip_alert, 'Visible', 'off' );

    set( handles.txt_EP_Threshold_05, 'String', str );
    set( handles.txt_EP_Above_05, 'String', str );
    set( handles.txt_EP_PosVox_05, 'String', str );
    set( handles.txt_EP_NegVox_05, 'String', str );

    set( handles.txt_variance, 'String', str );
    set( handles.txt_VarND, 'String', str );
    set( handles.txt_VarTotal, 'String', str );

  end

  drawnow();
end
% --- end function




function set_coefficient_statistics( handles )


  % ---------------------------
  % set the correlation coefficients of UR display
  % ---------------------------

  idx = get(handles.lst_computedFiles,'Value');
  [cdir fn] = filename_from_list( idx, handles );

  load( [pwd filesep cdir fn], 'UR' );

  x = exist( 'UR' );
  if ( x == 1 )
    ccf = corrcoef(UR);
    mtxsz = size(ccf,1);	% size of user matrix
  else
    mtxsz = 0;
  end

  for ( r = 1:6 )	% each row in our display matrix
    for ( c = 1:4 )	% each column in our display matrix

      str = ' ';

      ctl = ['txt_ccf_' num2str(r) '_' num2str(c)];
      if ( r <= mtxsz & c <= mtxsz)
        str = sprintf( constant_define( 'PREFERENCES', 'precision.ccf', '%.2f' ), ccf(r,c) );
      end

      h = findobj( 'Tag', ctl );       
      set( h, 'String', str );

    end
  end


  % ---------------------------
  % display or hide our correlation coefficients scroll controls
  % ---------------------------
 
  mx_hz = max(1,mtxsz-3);
  mx_vt = max(1,mtxsz-5);

  set( handles.ccf_scroll_horz, 'Max',  mx_hz );
  set( handles.ccf_scroll_horz, 'Min', 1.0 );
  set( handles.ccf_scroll_horz, 'Value', 1.0 );
  set( handles.ccf_scroll_vert, 'Max',  mx_vt );
  set( handles.ccf_scroll_vert, 'Min', 1.0 );
  set( handles.ccf_scroll_vert, 'Value', mx_vt );

  str = sprintf( 'Columns offset by %d', 0 );
  set( handles.ccf_scroll_horz, 'TooltipString', str );
  str = sprintf( 'Rows offset by %d', 0 );
  set( handles.ccf_scroll_vert, 'TooltipString', str );

  % Update handles structure
  guidata(handles.ccf_scroll_horz, handles);

end
% --- end function




function reset_coefficient_statistics( handles, r_offset, c_offset )

  % ---------------------------
  % set the correlation coefficients of UR display
  % ---------------------------

  idx = get(handles.lst_computedFiles,'Value');
  [cdir fn] = filename_from_list( idx, handles );

  load( [pwd filesep cdir fn], 'UR' );

  x = exist( 'UR' );
  if ( x == 1 )
    ccf = corrcoef(UR);
    mtxsz = size(ccf,1);	% size of user matrix
  else
    mtxsz = 0;
  end

  for ( r = 1:6 )	% each row in our display matrix
    for ( c = 1:4 )	% each column in our display matrix

      this_r = r + r_offset;
      this_c = c + c_offset;
      str = ' ';

      ctl = ['txt_ccf_' num2str(r) '_' num2str(c)];
      if ( this_r <= mtxsz & this_c <= mtxsz)
        str = sprintf( constant_define( 'PREFERENCES', 'precision.ccf', '%.2f' ), ccf(this_r,this_c) );
      end

      h = findobj( 'Tag', ctl );       
      set( h, 'String', str );

    end
  end

  str = sprintf( 'Columns offset by %d', c_offset );
  set( handles.ccf_scroll_horz, 'TooltipString', str );
  str = sprintf( 'Rows offset by %d', r_offset );
  set( handles.ccf_scroll_vert, 'TooltipString', str );

end
% --- end function




% --- Executes on button press in btn_Cancel.
function btn_Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.cancel_operation = 1;
end
% --- end function



% ------------------------------------------
% --- Process Horizontal Correlation Coefficient scroll
% ------------------------------------------
function ccf_scroll_horz_Callback(hObject, eventdata, handles)
% hObject    handle to ccf_scroll_horz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


  % ------------------------------------------
  % --- snap the control to whole values
  % ------------------------------------------
  col_pos = floor( get( hObject, 'Value' ) + 0.45 );
  set( handles.ccf_scroll_horz, 'Value', col_pos );
  drawnow();

  ctl_row_pos = floor( get( handles.ccf_scroll_vert, 'Value' ) );
  mx = get(handles.ccf_scroll_vert, 'Max' );
  row_pos = mx -  ctl_row_pos;

  reset_coefficient_statistics( handles, row_pos, col_pos - 1 );
end
% --- end function



% --- Executes during object creation, after setting all properties.
function ccf_scroll_horz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ccf_scroll_horz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
  if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
  end
end
% --- end function



% ------------------------------------------
% --- Process Vertical Correlation Coefficient scroll
% ------------------------------------------
function ccf_scroll_vert_Callback(hObject, eventdata, handles)
% hObject    handle to ccf_scroll_vert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  % ------------------------------------------
  % --- snap the control to whole values
  % ------------------------------------------
  ctl_row_pos = floor( get( hObject, 'Value' ) + 0.45 );
  set( handles.ccf_scroll_vert, 'Value', ctl_row_pos );
  drawnow();

  col_pos = floor( get( handles.ccf_scroll_horz, 'Value' ) );
  mx = get(hObject, 'Max' );
  row_pos = mx - ctl_row_pos;

  reset_coefficient_statistics( handles, row_pos, col_pos - 1 );
end
% --- end function



% --- Executes during object creation, after setting all properties.
function ccf_scroll_vert_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ccf_scroll_vert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
  if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
  end
end
% --- end function



% --- Executes on button press in btn_Plot_Eigenvalues.
function btn_Plot_Eigenvalues_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Plot_Eigenvalues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Zheader scan_information 

  % ---------------------------
  % scree plot - eigenvalues
  % ---------------------------

  C_Eigenvalues = [];
  [cdir fn] = filename_from_list( get( handles.lst_computedFiles, 'Value' ), handles );
  ftext = '';
  divBy = Zheader.total_scans - 1;
  Aidx = 0;
  
  load( [pwd filesep cdir fn], 'mask_registry' );
  if ~exist( 'mask_registry', 'var' ), mask_registry = 0;  end
  eig_var = ['C' constant_define( 'REGISTRATION_TAG', mask_registry) '_Eigenvalues' ];
  reg_label = constant_define( 'REGISTRATION_FULL', mask_registry);
  
  if ( ~strcmp( handles.criteria.prefix(1), 'G' ) )
    if ~isempty( Zheader.Limits.path )
      load( Zheader.Limits.path );
      C_Eigenvalues = load_BH_var( Hheader, handles.criteria.module, eig_var );
    end;
  else
    if ~isempty( Zheader.Model.path )
      load( Zheader.Model.path, 'Gheader' );

      GAtyp = 'G';
      str = regexp( fn, '_', 'split' );
      if length( char(str(1)) ) > 1
        GAtyp = char(str(1));
        load( Zheader.Contrast.path );
      end;

      ftext = [' - ' GAtyp ];
      if ~strcmp( GAtyp, 'G');
        Aidx = Aheader_index( Aheader, handles );
        if strcmp( GAtyp, 'GAA' )
          ftext = ' - GnotA';
        end
      end
      
      C_Eigenvalues = load_GC_var( Gheader, eig_var, GAtyp, Aidx );
    end;
  
  end;

  if ~isempty( C_Eigenvalues )
    maxplot = str2double(get(handles.txt_max_eigs,'String'));

    ext = min(maxplot, size(C_Eigenvalues,1) );
    Ce = C_Eigenvalues(1:ext,:)./divBy;
    h = figure;
    plot( Ce, '-O', 'MarkerSize', 5 );

    set( h, 'NumberTitle' , 'off' );
    set( h, 'Name' , ['Scree Plot' ftext reg_label ] );
  end;
  
end
% --- end function



function txt_max_eigs_Callback(hObject, eventdata, handles)
% hObject    handle to txt_max_eigs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

end
% --- end function


% --- Executes during object creation, after setting all properties.
function txt_max_eigs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_max_eigs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end
end
% --- end function



% --- Executes on button press in chk_show_legend.
function chk_show_legend_Callback(hObject, eventdata, handles)
% hObject    handle to chk_show_legend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_show_legend
  lst_Components_Callback( handles.lst_Components, eventdata, handles );
end
% --- end function



% --- Executes on button press in chk_show_grid_lines.
function chk_show_grid_lines_Callback(hObject, eventdata, handles)
% hObject    handle to chk_show_grid_lines (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_show_grid_lines
  lst_Components_Callback( handles.lst_Components, eventdata, handles );
end
% --- end function



% --- Executes on selection change in lst_plot_group.
function lst_plot_group_Callback(hObject, eventdata, handles)
% hObject    handle to lst_plot_group (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global scan_information

  GI = max( 0, get(hObject,'Value') - 2 );
  handles.criteria.GI = [];

  if ( GI == 0 )
    for ( ii = 1:size(scan_information.GroupList,1 ) )
      handles.criteria.GI = [handles.criteria.GI ii ];
    end

  else
    handles.criteria.GI = GI;
  end


  if handles.criteria.select_grps

    if numel(handles.criteria.GI) > 0
      if handles.criteria.GI(1) > 0  
        SubjectVector = [];
        for ( ii = 1:size(handles.criteria.GI, 2 ) )
          if ( size( scan_information.GroupList,1) >= handles.criteria.GI(ii) );
            SubjectVector = [SubjectVector; scan_information.GroupList(handles.criteria.GI(ii)) ];
            need_full_max = 1;
          end
        end
      end
    end
  end

  show_me = 'off';
  if ( handles.criteria.select_grps & size(scan_information.GroupList,1 ) > 2 ) show_me = 'on'; end
  set( handles.group_selection_window , 'Visible', show_me );

  this_one = 0;
  for ( ii = size( handles.criteria.chk_selection, 1 ):-1:1 )
    this_one = this_one + 1;
    V = any( handles.criteria.GI == ii) ;
    set( handles.criteria.chk_selection(this_one), 'Value', V );
  end

  uicontrol(hObject);

  % Update handles structure
  guidata(hObject, handles);

  lst_Components_Callback( handles.lst_Components, eventdata, handles );
end
% --- end function



% --- Executes during object creation, after setting all properties.
function lst_plot_group_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_plot_group (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end
end
% --- end function



% --- Executes on button press in chk_plot_subjects.
function chk_plot_subjects_Callback(hObject, eventdata, handles)
% hObject    handle to chk_plot_subjects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Zheader

  x = get( hObject, 'Value' );
  if x
    set(handles.chk_displayGroups, 'Value', 0 );   % --- subjects and groups not interactive
    set(handles.chk_AvgConditions, 'Value', 0 );   % --- This is the default anyway
  end
  
  if ( Zheader.num_subjects > 5 )
    set(handles.chk_show_legend, 'Value', 0 );
  end

  drawnow();
  lst_Components_Callback( handles.lst_Components, 0, handles );
end
% --- end function



function [ cmpdir fn] = filename_from_list( idx, handles )
global scan_information

  list_content = get( handles.lst_computedFiles, 'String' ) ;
  str = char(list_content(idx));
  isGA = 0;
  isROI = 0;
  
  str2 = regexp(str, ' ', 'split' );
  method = char(str2(2));
  if strcmp( method, 'GMH' ) || strcmp( method, 'GnotH' ) || strcmp( method, 'HnotG' )
    method = char(str2(3));
  end
  
  if strcmp( method, 'GA' ) || strcmp( method, 'GAA' )
    method = char(str2(3));
    isGA = 1;
  end
%   if strcmp( method, 'GAA' )
%     method = char(str2(3));
%     isGA = 1;
%   end
  if strcmp( method, 'ROI' ) 
    method = char(str2(3));
    isROI = 1;
  end
  
  x = regexp( str(1,1:4), '[0-9]', 'match' );
  strx = [];
  for ii = 1:size(x,2)
    strx = [strx char(x(ii) )];
  end
  nc = str2num(strx);
  
  if ~isempty( handles.criteria.Hmodel )
    htyp = handles.criteria.module;
    switch handles.criteria.module 
      case 'GC'
        htyp = 'GnotH';
      case 'BH'
        htyp = 'HnotG';
    end
    
    H_ID  = H_path_spec( handles.criteria.Hheader, 'GMH') ;
    prm = struct( 'model', handles.criteria.prefix, 'mode', handles.criteria.Hmodel, 'hindex', H_ID );
  else
    prm = struct( 'model', handles.criteria.prefix );

    if isROI
      roi_id = strrep(  strrep( char(str2(4)), '(', '' ),  ')', '' );
      prm.hindex = [ 'ROI' filesep roi_id ];
      prm.model = 'G';
%       noParms.ROIGZ = [ noParms.model filesep strrep( G_ROI.mask( G_ROI.Rindex).id, ' ', '_' ) filesep 'GZsegs'];
    end
    
  end
  
  if ( any(strcmp( str2, 'unrotated' ) ) );
    cmpdir = fs_path( 'unrotated', 'output', nc, 0, prm  );
  else
    prm.method = method;
    cmpdir = fs_path( 'rotated', 'output', nc, 0, prm );
  end

  x = strfind( str, '[' );
  if x
    y = strfind( str, ']' );
    if y
      pth_add = str(x+1:y-1);
      str = strtrim(strrep( str, ['[' pth_add ']'], '' ));
      cmpdir = [cmpdir pth_add filesep ];
    end
  end
  
%   wipe = [ '[' num2str(nc) ']' ];
%   if length( handles.criteria.Hmodel ) == 0
%     fn = strrep( str, wipe, handles.criteria.prefix(1));
%   else
%     fn = strrep( str, wipe, handles.criteria.Hmodel);
%   end
  
  wipe = [ '(' num2str(nc) ')' ];

  if length( handles.criteria.Hmodel ) == 0
    if isGA
      fn = strrep( str, [wipe ' '], '');
    else
      if ~isROI
        fn = strrep( str, wipe, handles.criteria.prefix(1));
      else
        fn = strrep( str, wipe, '');
        if ~isempty( strfind( fn, ' (' ))
         fn = strtrim( fn(1:strfind( fn, ' (' )) );
        end
      end
      
    end
  else
    if length( handles.criteria.module ) == 0
      fn = strrep( str, wipe, handles.criteria.Hmodel);
    else
      fn = strrep( str, [wipe ' '], '' );
    end
  end

  fn = strrep( fn, ' ', '_' );
  fn = [ fn '.mat' ];
end
% --- end function




% --- Executes on selection change in lst_plot_conditions.
function lst_plot_conditions_Callback(hObject, eventdata, handles)
% hObject    handle to lst_plot_conditions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


  lst_Components_Callback( handles.lst_Components, eventdata, handles );
end
% --- end function



% --- Executes during object creation, after setting all properties.
function lst_plot_conditions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_plot_conditions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end
end
% --- end function



% --- Executes on button press in chk_view_PRA.
function chk_view_PRA_Callback(hObject, eventdata, handles)
% hObject    handle to chk_view_PRA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  if isempty( handles.criteria.aPR )
    return;
  end
  handles.criteria.showApr = ~handles.criteria.showApr;
  guidata(hObject, handles);
  set( hObject, 'Value',  handles.criteria.showApr );
  lst_Components_Callback( handles.lst_Components, 0, handles );
end
% --- end function



% --- Executes on button press in btn_view_clusters.
function btn_view_clusters_Callback(hObject, eventdata, handles)
% hObject    handle to btn_view_clusters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scan_information 

  idx = get(handles.lst_computedFiles,'Value');
  [cdir fn] = filename_from_list( idx, handles );

  contents = get(handles.lst_Components,'String'); 		% returns lst_Components contents as cell array
  numcomps = size(contents, 1) - 1;

  method = mvs_rotation_method( fn );

  image_mat = [pwd filesep cdir 'Images' filesep 'image-loadings_' fn];

  eval( ['load( ''' image_mat ''', ''MNI'' );' ] );

  % --- view_clusters will be used to view all clusters for all components 
  fn = strrep( fn, '.mat', '' );
  view_clusters( 'clusters', MNI, 'file', fn, 'dir', cdir );
end
% --- end function



function [group_selection_window chk_selection] = create_selection_window( handles )

global scan_information

  group_selection_window = 0;
  chk_selection = [];

  num_controls = size( scan_information.GroupList,1);
  x = get( handles.output, 'Position' );

  x(1) = x(1) * 6;		% -- main dialog in inches - scale to pixel based on average aspect ratio
  x(2) = x(2) * 14;
  x(3) = 200;
  x(4) = (num_controls*20) + 10;

  x(1) = x(1) - x(3);
  x(2) = x(2) + x(4);

  group_selection_window = figure('Position',x,'Toolbar','none','MenuBar','none', 'Name', 'Selected Groups', 'NumberTitle', 'off', 'Visible', 'off');

  if ~isempty( group_selection_window )

    control_pos = [10, 10, 180, 15];
    this_one = -1;
    for ii = size( scan_information.GroupList,1):-1:1
      this_one = this_one + 1;
      control_pos(2) = control_pos(2) + ( 20 * (this_one > 0 ) );
      chk_selection = [chk_selection; uicontrol(group_selection_window, ...
          'Style','checkbox',...
          'Position', control_pos,...
          'String', scan_information.GroupList(ii).name,...
          'Value', 1,...
          'Interruptible', 'on', ...
          'Callback',@chk_toggled ) ];

    end

  end
end
% --- end function


    
function chk_toggled(hObject, eventdata)
% hObject    handle to chk_selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


  % -------------------------------------
  % --- each checkbox control contains the full array of
  % ---  checkbox handles in the UserData field
  % -------------------------------------
  controls = get( hObject, 'UserData' );
  this_one = 0;
  these_ones = [];
  for ii = size(controls.chk_selection):-1:1
    this_one = this_one + 1;
    x = get( controls.chk_selection(ii), 'Value' );
    if ( x == 1 ) these_ones = [these_ones this_one];  end
  end


  % -------------------------------------
  % --- the full handles structure is contained in the UserData
  % --- field of the parent window containing the checkbox controls
  % -------------------------------------
  x = get(hObject, 'Parent');
  handles = get(x, 'UserData');
  handles.criteria.GI = 0;

  if ~isempty( these_ones )
    handles.criteria.GI = these_ones;
    % Update handles structure
    guidata(x, handles);
  end

  lst_Components_Callback( handles.lst_Components, 0, handles );
end
% --- end function



% --- Executes on button press in chk_show_PR.
function chk_show_PR_Callback(hObject, eventdata, handles)
% hObject    handle to chk_show_PR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  x = get( hObject, 'Value' );

  set( handles.chk_show_VR, 'Value', 0 );
  set( handles.chk_show_PR, 'Value', 1 );
  guidata(hObject, handles);

  set( handles.btn_zoom_pos_loadings, 'Enable', 'off' );
  set( handles.btn_zoom_neg_loadings, 'Enable', 'off' );

  handles.criteria.posLoadings = 0;
  handles.criteria.negLoadings = 0;
  guidata(hObject, handles);

%  if ( x )
    lst_Components_Callback( handles.lst_Components, 0, handles );
%  end
end
% --- end function



% --- Executes on button press in chk_show_VR.
function chk_show_VR_Callback(hObject, eventdata, handles)
% hObject    handle to chk_show_VR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  x = get( hObject, 'Value' );

  set( handles.chk_show_PR, 'Value', 0 );
  set( handles.chk_show_VR, 'Value', 1 );

  handles.criteria.posLoadings = 0;
  handles.criteria.negLoadings = 0;

  set( handles.btn_zoom_pos_loadings, 'Enable', 'on' );
  set( handles.btn_zoom_neg_loadings, 'Enable', 'on' );

  guidata(hObject, handles);

%  if ( x )
    lst_Components_Callback( handles.lst_Components, 0, handles );
%  end
end
% --- end function



% --- Executes on selection change in lbl_EP_Thresh.
function lbl_EP_Thresh_Callback(hObject, eventdata, handles)
% hObject    handle to lbl_EP_Thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns lbl_EP_Thresh contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lbl_EP_Thresh

  contents = get(handles.lbl_EP_Thresh,'String') ;		% returns threshold list
  str = contents{get(handles.lbl_EP_Thresh,'Value')}; 	% returns selected item from threshold list
  thval = str2num(validate_numeric_entry( str ));		% threshold value as integer
  handles.selected_threshold = threshold_index( thval );
  guidata(hObject, handles);

  lst_Components_Callback( handles.lst_Components, 0, handles );
  guidata(hObject, handles);
end
% --- end function




function idx = threshold_list_index( handles, t )

  idx = 0;

  contents = get(handles.lbl_EP_Thresh,'String') ;		% returns threshold list
  str = contents{get(handles.lbl_EP_Thresh,'Value')}; 	% returns selected item from threshold list
  thval = str2num(validate_numeric_entry( str ));		% threshold value as integer

  for ii = 1:size(contents,1)
    if thval == handles.threshold_value( ii)
      idx = ii;
      return;
    end
  end
end
% --- end function



function idx = locate_threshold_index( handles, t )

  idx = 0;
  for ii = 1:size(handles.threshold_values, 2 )
    if t == handles.threshold_values( ii) & handles.active_thresholds(ii) ~= 0
      idx = ii;
      return;
    end
  end
end
% --- end function



% --- Executes on button press in btn_zoom_pos_loadings.
function btn_zoom_pos_loadings_Callback(hObject, eventdata, handles)
% hObject    handle to btn_zoom_pos_loadings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.criteria.posLoadings = 1;
  handles.criteria.negLoadings = 0;
  guidata(hObject, handles);

  lst_Components_Callback( handles.lst_Components, 0, handles );
end
% --- end function



% --- Executes on button press in btn_zoom_neg_loadings.
function btn_zoom_neg_loadings_Callback(hObject, eventdata, handles)
% hObject    handle to btn_zoom_neg_loadings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  handles.criteria.posLoadings = 0;
  handles.criteria.negLoadings = 1;
  guidata(hObject, handles);

  lst_Components_Callback( handles.lst_Components, 0, handles );
end
% --- end function



% --- Executes on button press in chk_PR_of_G.
function chk_PR_of_G_Callback(hObject, eventdata, handles)
% hObject    handle to chk_PR_of_G (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  set( handles.chk_PR_of_G, 'Value', 1 );
  set( handles.chk_PR_of_H, 'Value', 0 );

  if strcmp( handles.criteria.module, 'GMH' )
    set( handles.chk_AllConditions, 'Enable', 'on' );
    set( handles.chk_AvgConditions, 'Enable', 'on' );
  end;
  
  guidata(hObject, handles);

  lst_Components_Callback( handles.lst_Components, 0, handles );
end
% --- end function



% --- Executes on button press in chk_PR_of_H.
function chk_PR_of_H_Callback(hObject, eventdata, handles)
% hObject    handle to chk_PR_of_H (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  set( handles.chk_PR_of_G, 'Value', 0 );
  set( handles.chk_PR_of_H, 'Value', 1 );
  
  if strcmp( handles.criteria.module, 'GMH' )
    set( handles.chk_AllConditions, 'Enable', 'off' );
    set( handles.chk_AvgConditions, 'Enable', 'off' );
  end;
  guidata(hObject, handles);

  lst_Components_Callback( handles.lst_Components, 0, handles );
end
% --- end function



% --- Executes on button press in chk_AllConditions.
function chk_AllConditions_Callback(hObject, eventdata, handles)
% hObject    handle to chk_AllConditions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  lst_Components_Callback( handles.lst_Components, eventdata, handles );
end
% --- end function



% --- Executes on button press in chk_AvgConditions.
function chk_AvgConditions_Callback(hObject, eventdata, handles)
% hObject    handle to chk_AvgConditions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  x = get( hObject, 'Value' );
  if x
    set( handles.chk_plot_subjects, 'Value', 0 );
  end;
  lst_Components_Callback( handles.lst_Components, eventdata, handles );
end
% --- end function



% --- Executes on button press in chk_displayGroups.
function chk_displayGroups_Callback(hObject, eventdata, handles)
% hObject    handle to chk_displayGroups (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  groupState = 'off';
  handles.criteria.select_grps = get(hObject,'Value');
  if handles.criteria.select_grps
    groupState = 'on';
    set( handles.chk_plot_subjects, 'Value', 0 );    % --- subjects and groups not interactive
  end
  set( handles.lst_plot_group, 'Enable', groupState );
  
  lst_Components_Callback( handles.lst_Components, eventdata, handles );
 end
% --- end function


  

function HRF = select_valid_PR( this_plot, handles )
  
  HRF = [];

  if handles.criteria.showApr
    HRF = handles.criteria.aPR.component(this_plot.comp).all.PR(:);
  else

    p = get( handles.chk_PR_of_H, 'Value' );
    
    if p
      if isempty( handles.criteria.Weights.PRh )
        HRF = handles.criteria.Weights.PR(:,this_plot.comp);
        set( handles.chk_PR_of_H, 'Value', 0 );
        set( handles.chk_PR_of_G, 'Value', 1 );
      else
        HRF = handles.criteria.Weights.PRh(:,this_plot.comp);
      end
      
    else
        
      if isempty( handles.criteria.Weights.PR )
        HRF = handles.criteria.Weights.PRh(:,this_plot.comp);
        set( handles.chk_PR_of_H, 'Value', 1 );
        set( handles.chk_PR_of_G, 'Value', 0 );
      else
        HRF = handles.criteria.Weights.PR(:,this_plot.comp);
      end
    end
  end
end
% --- end function



function condition_name = selected_condition_names( this_plot )
global Zheader

  condition_name = [];
  
  for ii = 1:size( this_plot.conditions, 2 )
    cond = this_plot.conditions(ii);		% --- create the matrix for all conditions ---
    condition_name = [ condition_name Zheader.conditions.Names(cond) ];
  end
end
% --- end function
  

  
  
function ur_graphdata = prepare_PR_graph( this_plot, SubjectVector, handles )
%% --- prepare the full PR plot graph of all PR conditions 
%  ---
%  ---  returns all conditions of PR in plot form
%  ---  SubjectVector is empty for group plots
global  Zheader scan_information

  ur_graphdata = [];
  
  HRF = select_valid_PR( this_plot, handles );

  p = get( handles.chk_PR_of_H, 'Value' );
  if p
%      plot_PRh();
    return;
  end
  
  ur_comp = [];
  ur_cond = [];
  
  if ~isstruct( SubjectVector )

    %% --- prepare plot data for average conditions
    if ~this_plot.show_by_subjects

      for cond = 1:this_plot.nconds	% --- create the matrix for all conditions ---
    
        ur_cond = [];
        er = 0;
        for subject = 1:size(SubjectVector,2)
        
            SubjectNo = SubjectVector( subject );
            
            if this_plot.isGA || this_plot.isROI
              encoded = 1;
              sr = ( (subject-1) *  this_plot.nconds * this_plot.nbins ) + 1 + ( (cond-1) * this_plot.nbins );
              er = sr + this_plot.nbins - 1;
            else
              [encoded, sr, er] = PR_condition_position( SubjectNo, cond, this_plot.nbins  );
            end
            
            if encoded
                temp=HRF(sr:er);
                ur_cond = [ur_cond temp];
            else
                ur_cond = [ur_cond zeros(this_plot.nbins, 1 )];
            end
        
        end  % --- each subject ---
 
        if this_plot.isROI || ( scan_information.processing.model.parameters.model_type == constant_define( 'HRF_MODEL' ))   
          ur_comp = [ur_comp; ur_cond];
        else
   
          ur_cond = ur_cond';
          ur_comp = [ur_comp  ur_cond];
    
          if ( Zheader.num_subjects > 1 & ~this_plot.isGAA  )
              ur_graphdata = [ur_graphdata transpose(mean(ur_cond))];
          else
              ur_graphdata = [ur_graphdata transpose(ur_cond)];
          end
    
        end

      end  % --- each condition ---

      if this_plot.isROI ||( scan_information.processing.model.parameters.model_type == constant_define( 'HRF_MODEL' ) )   
        ur_graphdata = mean(ur_comp');
  
      else
%         if this_plot.isGAA
%           ur_graphdata = reshape( ur_comp, this_plot.nbins, this_plot.nconds )
%         end
        
        if ( this_plot.average_conditions )		% single line plot of average of all conditions
          ur_graphdata = mean(ur_graphdata' )';
          this_plot.end_cond = this_plot.start_cond;
        end

      end   % --- hrf model

    %% --- prepare plot data for average conditions over subjects
    else

      for subject = 1:size(SubjectVector,2)
    
        SubjectNo = SubjectVector( subject );
    
        ur_cond = zeros( size(this_plot.conditions, 2), this_plot.nbins );
        this_cond = 1;
    
        for cond = 1:this_plot.nconds		% --- create the matrix for all conditions ---
        
          [encoded sr er] = PR_condition_position( SubjectNo, cond, this_plot.nbins );
          if encoded
            temp=HRF(sr:er);
            ur_cond(this_cond,:) = temp';
          end
        
          this_cond = this_cond + 1;
        
        end  % each condition
    
        if ( this_plot.average_conditions )		% single line plot of average of all conditions
          ur_cond = mean(ur_cond );
        end
    
        ur_graphdata = [ur_graphdata ur_cond'];
    
      end	% each subject

%      ur_graphdata = ur_graphdata';

    end

  %% --- prepare plot data for average conditions over groups
  else

    for cond = 1:this_plot.nconds  % --- start_cond:end_cond		% --- create the matrix for all conditions ---
    
      ur_cond = [];
    
      for grp = 1:size(SubjectVector,1)
        SubjectList = str2num(char(SubjectVector(grp).subjectlist));
        
        ur_groupcond=[];
        
        for subject = 1:size(SubjectList,2)
            
          SubjectNo = SubjectList( subject );
          [encoded sr er] = PR_condition_position( SubjectNo, cond, this_plot.nbins );
          if encoded
            temp=HRF(sr:er);
            ur_groupcond = [ur_groupcond; temp'];
          end
            
        end  % --- each subject in the group ---
        
        if isempty( ur_groupcond )
          ur_groupcond = zeros( 1, this_plot.nbins );
        end
        
        if ( size(SubjectList,2) > 1 & this_plot.show_by_subjects == 0)
          ur_cond = [ur_cond vectored_mean(ur_groupcond)'];
        else
          ur_cond = [ur_cond ur_groupcond'];
        end
        
      end  % --- each group ---
    
      if ( this_plot.average_conditions & ~this_plot.average_groups )		% single line plot of average of all conditions
        ur_cond = vectored_mean(ur_cond' )';
      end
    
      ur_graphdata = [ur_graphdata ur_cond(:)];
    
    end  % --- each condition ---

  end
  
end
% --- end function
  
  
function lst = get_matfile_entries( folder, nc, handles, dosubs )

if nargin < 4
  dosubs = 0;
end

lst = [];
dirlist = {folder};

if dosubs
  [dlist dircount] = directory_list( folder );
  
  dirlist = {folder};
  if ~isempty( dlist )
    for ii = 1:size( dlist, 1 )
      dirlist = [dirlist; {[folder char(dlist(ii) )]} ];
    end
  end
end
 
  
for ii = 1:size( dirlist, 1 )

  folder = strrep( [char( dirlist(ii) ) filesep ], [filesep filesep], filesep );
  
  matlist = dir([folder char(42) '.mat' ]);

  if ( size(matlist, 1) > 0 )

    for jj = 1:size(matlist,1)

      if isempty( strfind( matlist(jj).name, '_T_' ))
        hrft = who_stats( folder, matlist(jj).name, 'cpca_version' );

        if hrft.mat_exists    % ---- valid cpca output mat
            
          validP = who_stats( folder, matlist(jj).name, 'PR' );
          if validP.mat_exists    % ---- valid cpca extraction/rotation output mat

            str = matlist(jj).name;

            if ~isempty( handles.criteria.Hmodel )
              wipe = [ handles.criteria.Hmodel '_'];
              rep = [ '(' num2str(nc) ') ' handles.criteria.Hmodel ' ' ];
              str = strrep( str, wipe, rep );

              repas = handles.criteria.module;
              if strcmp(handles.criteria.module,'GC' )
                repas = 'GnotH';
              else
                if strcmp(handles.criteria.module,'BH' )
                  repas = 'HnotG';
                end
              end
              wipe = [ handles.criteria.module '_'];
              rep = [ '(' num2str(nc) ') ' repas ' ' ];
              str = strrep( str, wipe, rep );
            end
              
            wipe = [ handles.model_display '_'];
            rep = [ '(' num2str(nc) ') ' ];
            str = strrep( str, wipe, rep );

            wipe = 'GA_';
            rep = [ '(' num2str(nc) ') GA ' ];
            str = strrep( str, wipe, rep );

            wipe = 'GAA_';
            rep = [ '(' num2str(nc) ') GAA ' ];
            str = strrep( str, wipe, rep );
                    
            str = strrep( str, '_', ' ' );
            str = strrep( str, '.mat', '' );
            
rep = [ '(' num2str(nc) ') ' ];
if isempty( strfind( str, rep ) )
  str = [rep str ];
end

if ~isempty( strfind( str, 'ROI' ) )
  roi_id = strrep( folder, char( dirlist(1) ), '' );
  roi_id = strrep( roi_id, filesep, '' );
  
  str = [ str, ' (', roi_id ')' ];
end


            lst = horzcat( lst, {str});
          end;

        end;
      end;	% --- not the hrfmax T variable
    end;
  end;

end

end
% --- end function

function Aidx = Aheader_index( Aheader, handles )

  Aidx = 0;
  
  list_content = get( handles.lst_computedFiles, 'String' ) ;
  idx = get(handles.lst_computedFiles,'Value');
  str = char(list_content(idx));
  [cdir fn] = filename_from_list( idx, handles );
  
  prm = struct( 'model', handles.criteria.prefix );
  method = mvs_rotation_method( fn );
  rot = 'unrotated';
      
  if ~strcmp( method, 'unrotated' )
    rot = 'rotated';
    prm.method = method;
  end

  x = str2num(char(regexp( str(1:5), '[0-9]', 'match' )));
  if size(x,1) == 1
    nc = x;
  else
    nc = x(1) + (x(2) * 10);
    if size(x,1) == 3
      nc = nc + (x(3) * 100);  % - doubtful, but let's not assume
    end;
    
  end
  
  rdir = fs_path( rot, 'output', nc, 0, prm );
  pth = strrep( cdir, rdir, '' );

  Aidx = 1;
  if ~isempty( pth )
    for ii = 1:size( Aheader.model, 1 )
      if strcmp( Aheader.model(ii).id,  pth(1:length(pth)-1 ) );
        Aidx = ii;
        break
      end;
    end;
  end
end


% --- Executes during object creation, after setting all properties.
function lbl_EP_Thresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lbl_EP_Thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end