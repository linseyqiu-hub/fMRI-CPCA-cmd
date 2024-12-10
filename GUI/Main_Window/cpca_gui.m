function varargout = cpca_gui(varargin)
% CPCA M-file for cpca.fig
%      CPCA, by itself, creates a new CPCA or raises the existing
%      singleton*.
%
%      H = CPCA returns the handle to a new CPCA or the handle to
%      the existing singleton*.
%
%      CPCA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CPCA.M with the given input arguments.
%
%      CPCA('Property','Value',...) creates a new CPCA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before cpca_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cpca_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cpca

% Last Modified by GUIDE v2.5 01-May-2014 09:44:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cpca_OpeningFcn, ...
                   'gui_OutputFcn',  @cpca_OutputFcn, ...
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

warning( 'off', 'all' );
end


% --- Executes just before cpca_gui is made visible.
function cpca_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.

global scan_information Zheader process_information ;

  scan_information = legacy_define( 'scan_information' );
  process_information = legacy_define( 'process_info' );
  Zheader  = legacy_define( 'ZHeader' );

  % --- allow java loader to crash before showing splash screen
  handles.progressBar = cpca_progress();
  if ( isa( handles.progressBar, 'cpca_progress' ) )
    handles.progressBar.hide();
  end;

  splash = splash_screen( 'show' );
  
  % --- uncomment for debugging opening procedures - avoid popup corruption
  splash_screen( 'hide', splash );

  check_user_settings();
  
  x = check_memory();

  process_information.control_text = set_control_text();   
  process_information.done_bar.length = 13;

  handles.processingData = 0;
  handles.H_screeview = '';

  handles.funcs.memory_stats = [];
  handles.funcs.clear_cache = [];
  handles.funcs.clear_model = @clear_model;
  % Choose default command line output for cpca
  handles.output = hObject;

  % set the GUI Title to display revision number
  set( hObject, 'Name', [ 'cpca ' constant_define( 'REVISION_NUMBER')  ' [ ' short_path(pwd, 6) ' ]' ] );

  if ismac 
    process_information.sys = '_mac'; 
  end;

  [process_information.is64bit process_information.hasCacheDrop process_information.sudoUser process_information.isRoot process_information.HDF5] = ...
      system_settings( process_information.cache_buffer );

  if size( process_information.sudoUser, 2 ) > 0  % --- running as sudo - ownership changes required
    process_information.sudo.confirmed = 0;
  else  % --- running as root - no ownership changes required
    process_information.sudo.confirmed = 1;
  end;    

  % set the GUI control texts
  if isfield( process_information, 'control_text' )
    if ( ~isempty(process_information.control_text) )		% default setting of 0 is a 1 x 1 double - ignore it
      for jj = 1:size(process_information.control_text, 1)
        h = findobj( 'Tag', process_information.control_text(jj).control );
        set(h,'String',process_information.control_text(jj).text );
      end;
    end;
  end;


  set( handles.btn_SelectMask, 'Enable', 'off' );
  set( handles.btn_Select_ROI, 'Enable', 'off' );
  set( handles.btn_SelectG, 'Enable', 'off' );
  set( handles.btn_createG, 'Enable', 'off' );
  set( handles.btn_addA, 'Enable', 'off' );
  set( handles.Btn_SelectA, 'Enable', 'off' );
  set( handles.lst_A, 'Enable', 'off' );
  set( handles.Btn_SelectH, 'Enable', 'off' );
  set( handles.btn_addH,    'Enable', 'off' );
  set( handles.Btn_createH, 'Enable', 'off' );
  set( handles.lst_H, 'Enable', 'off' );

  set( handles.txt_GROI_num_voxels, 'String', num2str( constant_define( 'PREFERENCES', 'general.default_ROI_vox' )) );

  set( handles.btn_Scree_Plot, 'Enable', 'off' );
  set( handles.btn_G_Stats, 'Enable', 'off' );
  set( handles.btn_GH_Stats, 'Enable', 'off' );
  set( handles.btn_view_EH, 'Enable', 'off' );
  set( handles.btn_view_ZH, 'Enable', 'off' );
  set( handles.btn_view_GMH, 'Enable', 'off' );
  set( handles.btn_view_BH, 'Enable', 'off' );
  set( handles.btn_view_GC, 'Enable', 'off' );
  set( handles.btn_HScree_Plot, 'Enable', 'off' );

  set( handles.NumComp_GMH, 'Enable', 'off');

  set( handles.btn_Rotate_GMH_Settings, 'Visible', 'off');
  set( handles.btn_clr_rotations_gmh, 'Visible', 'off');

  % -- internal release Allows normalize Z option
  set( handles.chk_mean_center, 'Visible', 'on' );
  set( handles.chk_standardize, 'Visible', 'on' );

  handles.addH = 0;

  % Update handles structure
  guidata(hObject, handles);

  [path f] = cpca_log_file();
  if ( isempty( path) )  		% if permissions errors or environment unaccessible, abort logging
    set( handles.btn_view_log, 'Enable', 'off' );
  end;		

  if isunix() && ~ismac()
    set( handles.btn_clear_cache, 'Enable', 'on' );
    if (process_information.isRoot )  % -- also set on sudo matlab
      set( handles.chk_auto_cache, 'Enable', 'on' );

      if size( process_information.sudoUser, 2 ) > 0 
        process_information.sudo.confirmed = confirm_sudo_user_and_group( handles );
      end;

      if process_information.sudo.confirmed
        set( handles.button_reset_fs_permission, 'Enable', 'on' );
      else
        set( handles.button_reset_fs_permission, 'Enable', 'off' );
      end;

    end;

  else
    set( handles.chk_auto_cache, 'Visible', 'off' );
    set( handles.btn_clear_cache, 'String', 'Cache: <na>' );
    set( handles.button_reset_fs_permission, 'Enable', 'off' );
  end;
 
  if ismac()    % --- [7.2.3-RC.5 mac]
    pos = get(handles.NumComp_GA, 'Position' );
    set( handles.NumComp_GA, 'Position', [pos(1) pos(2) pos(3) 1.5] );
    set(handles.NumComp_GA, 'HorizontalAlignment', 'center' );
    
    pos = get(handles.NumComp_H, 'Position' );
    set( handles.NumComp_H, 'Position', [pos(1) pos(2) pos(3) 1.5] );
    set(handles.NumComp_H, 'HorizontalAlignment', 'center' );
  end;

  handles.funcs.memory_stats = @update_memory_stats;

  if exist( 'splash', 'var' )
    splash_screen( 'hide', splash );
  end
  
    % Update handles structure
  guidata(hObject, handles);

  update_process_buttons( handles );
  
  set( handles.btn_run_h_process, 'Enable', 'off' );
  set( handles.chk_apply_HZ, 'Enable', 'off' );
  set( handles.chk_apply_gh, 'Enable', 'off' );
  
% UIWAIT makes cpca_gui wait for user response (see UIRESUME)
% uiwait(handles.cpca_gui);
end


% --- Outputs from this function are returned to the command line.
function varargout = cpca_OutputFcn(hObject, eventdata, handles) 

  if isunix() && ~ismac()
    % --- turn off auto cache clearing if user forgot to ---
    x = evalc( '!ps -af | grep cache_keepalive | grep -v grep' );
    if ~isempty( x )
      pid = str2num(x(10:18) );
      eval( ['!kill -9 ' num2str(pid)] )
    end
  end

  handles.funcs.clear_cache = [];

  % Get default command line output from handles structure
  varargout{1} = handles.output;
end




% --- Executes during object creation, after setting all 
function MainDialog_CreateFcn(hObject, eventdata, handles)

end



% --- Executes during object creation, after setting all properties.
function SystemPanel_CreateFcn(hObject, eventdata, handles)

end



% --- Executes during object creation, after setting all properties.
function NumComp_GA_CreateFcn(hObject, eventdata, handles)

  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end
end



% --- Executes during object creation, after setting all properties.
function NumComp_H_CreateFcn(hObject, eventdata, handles)

  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end
end

% --- Executes during object creation, after setting all properties.
function NumComp_GMH_CreateFcn(hObject, eventdata, handles)
  
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end

end



% --- Executes during object creation, after setting all properties.
function NumComp_PD_CreateFcn(hObject, eventdata, handles)

  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end
end


 

%% ---------------------------------------------------------------------------
% --- Selection Buttons 
% ---------------------------------------------------------------------------


% ---
% --- SubjectSelect - select scan list or pre-processed ZInfo data
% ---
function SubjectSelect_Callback(hObject, eventdata, handles)
% ---
% --- Select a data source.  Data source can be one of:
% ---
% --- scan file list text file created by File_List_Creation()
% ---
% --- mat file containing a matrix to be used as Z
% ---     WARNING: legacy process from early inception - not reliable !!!
% ---
% --- Zinfo.mat file containing study information structures
% ---
  global scan_information Zheader process_information;

  fullpath = select_file( {'*.txt;*.mat','scan file list text file, or Z matrix'}, ...
                                   'Select your file list text file or Z Matrix');
  if ~isempty( fullpath )
    
    % user possibly selecting a new file to process - reset the Z informational matrices
    % --------------------------------------------------------
    scan_information = legacy_define( 'scan_information' );
    process_information = legacy_define( 'process_info' );
    Zheader  = legacy_define( 'ZHeader' );
    if ispc 
      process_information.sys = '_pc'; 
    end


    if ismac 
      process_information.sys = '_mac'; 
    end

    str = regexp( fullpath, '.mat$', 'match' );
    x = size(str);

    if  x(1) > 0 

      str = regexp( fullpath, 'ZInfo.mat$', 'match' );
      xx = size(str);

      if  xx(1) > 0 
        slash = filesep;
        [Zpath, Zfile] = split_path( fullpath, slash );

        % --- check the lowest allowable revision numbers
        eval( [ 'x = load( ''' fullpath ''', ''Zheader'' ); '] );
        this_revision = revision_value(  x.Zheader.cpca_version );
        lowest_revision = revision_value( constant_define( 'LOWEST_REVISION' ) );

        vsn = cpca_revision_number( x.Zheader.cpca_version );
        reapply_revision = revision_value( constant_define( 'REAPPLY_REVISION' ) );

        if this_revision < lowest_revision | this_revision <= reapply_revision
          if this_revision < lowest_revision
            str = ['This data set was created with a version of CPCA that is no longer supportable. [' vsn ']' ];
            title = 'Unsupported Legacy Version';
          else
            str = ['This data set was created with a version of CPCA that requires you to reapply the G Model and extract/rotate the components. [' vsn ']   You need not re-normalize or recreate the Z data.'];
            title = 'G Re-application Required';
          end
          
          show_message( title, str );
          return;
        end


        % user selected an existing ZInfo.mat file =- load the stats into memory
        % --------------------------------------------------------
        eval( [ 'load( ''' fullpath ''') ' ] );
        hdr_version = Zheader.header_version;


        % adjust the header data to the current model if required
        % --------------------------------------------------------
        [Zheader, scan_information] = adjust_headers( Zheader, scan_information, Zpath );
        process_information = adjust_process_info();
        if Zheader.Model.hdr_exists && isempty( Zheader.conditions.sp )
          load( Zheader.Model.path, 'Gheader');
          Zheader.conditions.sp = condition_start_columns( Gheader.conditions, Gheader.bins );
        end

        % check that the adjustment did not corrupt the partitioning status
        % --------------------------------------------------------
        if ( Zheader.partitions.partitioned == 0 )

          x = who_count( [Zpath filesep 'Z' filesep], 'Z1.mat', 'Z_R1_*' );
          if ( x > 0 ) 

            Zheader.partitions.partitioned = 1;
            Zheader.partitions.count = x;
            xx = who_stats( [Zpath filesep 'Z' filesep], 'Z1.mat', 'Z_R1_C1' );
            Zheader.partitions.width = xx.mat_y;

            eval ( [ 'xx = who_stats( ''' [Zpath filesep 'Z' filesep] ''', ''Z1.mat'', ''Z_R1_C' num2str(x) ''');' ] );
            Zheader.partitions.last = xx.mat_y;

            Zheader.partitions.columns = [];
            for ii = 1:(x-1)
              Zheader.partitions.columns = [Zheader.partitions.columns Zheader.partitions.width];
            end
            Zheader.partitions.columns = [Zheader.partitions.columns Zheader.partitions.last];

            Zheader.partitions.mem = array_sizes( [Zheader.total_scans Zheader.partitions.width ] );

          end
        end

        save_headers();

        % verify data is actually at absolute path indicated in header
        % if data was backed up to another location we need to adjust it.
        % --------------------------------------------------------

        % this indicates subject normalization process was run (even if not completed )
        % --------------------------------------------------------
        if scan_information.processing.subjects.process.last_subject > 0

          d = dir( [ Z_Directory() 'Z' filesep 'Z1*.mat'] );

          if ( size(d,1) == 0 )  % --- okay, the absolute location is farked
            % --- absolute paths to adjust
            % --- Zheader.Z_Directory: '/home/woodward/Desktop/tgt_v1_test/cpca/'
            % --- header.Model.path: '/home/woodward/Desktop/tgt_v1_test/cpca/G.mat'
            % --- Gheader.path_to_segs: '/home/woodward/Desktop/tgt_v1_test/cpca/Gsegs/'
            % --- Gheader.applied_to: '/home/woodward/Desktop/tgt_v1_test/cpca/'
            % --- Gheader.GZheader.path_to_segs: '/home/woodward/Desktop/tgt_v1_test/cpca/GZsegs/'

            [z s g h] = Z_path_repair( 'path', [pwd filesep] );

            if ~isempty( z );
              Zheader = z;
              scan_information = s;
              save ZInfo Zheader scan_information -append

              if ~isempty( g.path_to_segs )
                Gheader = g;
                eval( [ 'save( ''' Zheader.Model.path ''', ''Gheader'', ''-append'');' ] );
              end

              if ~isempty( h.path_to_segs )
                Hheader = h;
                eval( [ 'save( ''' Zheader.Limits.path ''', ''Hheader'', ''-append'');' ] );
              end
              
            end

          end

        end


        % if there is a defined G, is it processed with a header?
        % --------------------------------------------------------
        if ( Zheader.Model.file_exists )
          [Gpath, Gfile] = split_path( Zheader.Model.path, filesep );

          xx = who_stats( Gpath, Gfile, 'Gheader' );
          if ( ~xx.mat_exists )
            Gheader = Full_G_Parameters(); 
            if ( ~isempty( Gheader ) ) 
              eval ( ['save( ''' Zheader.Model.path ''', ''Gheader'', ''-append'')' ] );  
              scan_information.processing.model.parameters.condition_name = Gheader.condition_name;
              scan_information.processing.model.parameters.model_type = Gheader.model_type;
              scan_information.processing.model.parameters.conditions = Gheader.conditions;
              scan_information.processing.model.parameters.bins = Gheader.bins;
              scan_information.processing.model.parameters.TR = Gheader.TR ;
              scan_information.processing.model.parameters.inScans = Gheader.inScans;
              save_headers();
            end
          else
            % there is a defined G, but is it a current design?
            % --------------------------------------------------------
            load( Zheader.Model.path, 'Gheader');
            Gheader = adjust_gheader( Gheader );
            if ( ~isfield( Gheader, 'prefix' ) )
              str = 'Your present G model appears to have been created in an older format of the CPCA GUI.  Please reselect or recreate it to ensure the proper application of this G to your data.' ;
              show_message( 'G Model Not Current', str );
            end

          end
        end

        % if the G has been applied, is it processed with new file structure? ( v 3.3.0 - Mar 01, 2010 )
        % --------------------------------------------------------
        if ( str2num(hdr_version) < 2.0 )  % we need to process any GZSegs/GZ_S{n} files

          gzpth = get_GZsegs_path();
          x = exist( gzpth, 'dir' );
          if ( x == 7 )  % the directory exists - loacte the last subject file
            last_file = [ 'GZ_S' num2str(Zheader.num_subjects) '.mat' ];
            x = who_stats( gzpth, last_file, 'Bn' );
            if ( x.mat_exists )   % we have an older file that needs to be processed

              str = sprintf( 'The existing GZ data set was processed under an older CPCA version, and needs to have some of it''s data moved to new files to increase speed.\n\nPress ''Yes'' to perform this update.' );
              myAnswer = questdlg(str,'WARNING!','Yes');
              if strcmp(myAnswer, 'Yes')
                update_GZSegs();
              else
                Zheader.header_version = hdr_version;
                save_headers();
              end

            end
          end

        end

        % update the subject ID's if necessary
        % --------------------------------------------------------
        if ( isempty(scan_information.SubjectID ) && isempty(Zheader.Z_File.name) )
          for S = 1:Zheader.num_subjects 
            if ( size(scan_information.SubjDir,1) >= S && ~isempty(scan_information.SubjDir) )
              x = regexp( char(scan_information.SubjDir(S,1)), filesep, 'split' );
              scan_information.SubjectID = [scan_information.SubjectID {char(x(1))} ];
            else
              scan_information.SubjectID = [scan_information.SubjectID {'     '} ];
            end
          end
          save_headers();
        end


      else
        % user selected an existing stand alone mat file - get the variable names
        % --------------------------------------------------------

        % processing a Z file where a current set exists 
        % will destroy the normalized subject data
        % --------------------------------------------------------
        p = pwd;
        fn = [p filesep 'Z' filesep 'Z1.mat'];

        if ( exist( fn, 'file' ) )
          str = sprintf( 'There appears to be an existing subject set in your present directory.  It is suggested you change directory before continuing, otherwise your existing data headers will be overwritten, and the normalized data set rendered useless!\n\nDo you want to risk overwiting this data?' );
          myAnswer = questdlg(str,'WARNING!','Okay','NO!','NO!');
          if strcmp(myAnswer, 'NO!')	
            return; 
          end

        end


        mat_vars = matfile_vars( '', fullpath );
        [mf_x mf_y] = size( mat_vars );

        if ( mf_x > 0 )    % there are variables in the file
          if ( mf_x == 1 )   % only a single variable in the file

            Zheader.Z_File.variable = mat_vars;

          else

            % get user selection of mat in file to use as Z
            lst = '';
            for ii=1:mf_x
              lst = horzcat( lst, {mat_vars(ii).name});
            end

            x = mat_selection( lst );
            Zheader.Z_File.variable = mat_vars(x);

          end  % more than 1 var in file

          % selected matrix - set structure
          if ~isempty( Zheader.Z_File.variable.name )
            memory = check_memory();
            memory_required = ceil( (Zheader.Z_File.variable.sz_x * Zheader.Z_File.variable.sz_y * constant_define( 'SIZE_QWORD') )/ constant_define( 'SIZE_MB') ); 
            mem_max = memory.user.free;
            if ( memory_required > memory.user.free - 100 )
              str = sprintf( 'The chosen matrix is too large to process - you may need to re-normalize the subject scans using the GUI\n' );
              show_message( 'Memory Problem', str );
              return;
            end

            x = findstr( filesep, fullpath );
            xx=size(x);
            sz = size( fullpath );
            Zheader.Z_File.directory = fullpath(1:x(xx(2)));
            Zheader.Z_File.name = fullpath(x(xx(2))+1:sz(2));
            Zheader.older_Z = 1;
            
            mk_zh_from_z();
            x = Z_Settings();
            clear Z_settings

            load( './ZInfo.mat', 'Zheader', 'scan_information');
            hdr_version = Zheader.header_version;

%            update_subject_stats();

          end

        end  % we have vars in the file

      end


    else

      % parse the contents of a text file of subject scans
      % --------------------------------------------------------
      scan_information.NumSubjects = 0;
      scan_information.BaseDir= '';
      scan_information.ListSpec = '';
      scan_information.SubjDir = '';
      scan_information.FileList = fullpath;
       
      parse_scan_listing( fullpath );

      % confirm the directory pointed to still exists ( may be a removable drive )
      % --------------------------------------------------------
      x = exist( char(scan_information.BaseDir), 'dir' ) == 7;
      h = findobj('Tag','chk_ScanDirExists');
      set(h,'Visible', constant_define( 'STATE', x) );

      % --------------------------------------------------------
      % we need to determine the number of scans for all subjects
      % and calculate how much memory the full Z matrix will require
      % if more than available user memory, determine level of columnar segmentation
      % --------------------------------------------------------
      sum_subject_scans();

      % confirm the directory pointed to contains scan images
      % --------------------------------------------------------
      if Zheader.total_scans == 0 
        str = sprintf( 'There appears to be no scan images found in %s\n', scan_information.BaseDir );
        show_message( 'No Images Found', str );
        
        return
      end

      % processing a subject scan list where a current set exists 
      % will destroy the normalized subject data
      % --------------------------------------------------------
      p = pwd;
      fn = [p filesep 'ZInfo.mat'];

      % exist will return 0 if the file does not exist
      % it will return 1 if the file exists in the current workspace
      % it will return 2 if the file exists in the current path
      % avoid condition 2, only check if it exists in the current workspace
      % --------------------------------------------------------
      if ( exist( fn, 'file' ) )
        str = sprintf( 'There appears to be an existing subject set in your present directory.  It is suggested you change directory before continuing, otherwise your existing data headers will be overwritten, and the normalized data set rendered useless!' );
        show_message( 'Study Conflict!', str );

      end
     
    end

  end

  
  lst = [];
  idx = 0;

  if ~isempty( Zheader.Contrast.path )

    load( Zheader.Contrast.path );

    if exist( 'Aheader', 'var' )

      idx = Aheader.Aindex;

      if isfield( Aheader, 'model' )
        for ii = 1:size( Aheader.model, 1)
          if ~isempty( Aheader.model(ii).id )
             lst = [lst; {Aheader.model(ii).id}];
          else
             lst = [lst; {['A ' num2str(ii)]}];
          end
                 
        end
      else
        lst = {['A ' num2str(ii)]};
      end
      
    end
  end
  
  set( handles.lst_A, 'String', lst, 'Value', idx );
  
  
  lst = [];
  idx = 0;

  if ~isempty( Zheader.Limits.path )

    load( Zheader.Limits.path );

    if exist( 'Hheader', 'var' )

      Hheader = adjust_hheader( Hheader );
      save( Zheader.Limits.path, 'Hheader' );

      idx = Hheader.Hindex;

      if isfield( Hheader, 'model' )
        for ii = 1:size( Hheader.model, 1)
          if ~isempty( Hheader.model(ii).id )
             lst = [lst; {Hheader.model(ii).id}];
          else
             lst = [lst; {['H ' num2str(ii)]}];
          end
                 
        end
      else
        lst = {['H ' num2str(ii)]};
      end
      
    end
  end
  
  set( handles.lst_H, 'String', lst, 'Value', idx );
  save_headers();

  if exist('G_ROI.mat', 'file' )
    load G_ROI
  end;
  
  lst = [];
  if exist( 'G_ROI', 'var' )

    if isfield( G_ROI, 'mask' )
      for ii = 1:size( G_ROI.mask, 1)
        if ~isempty( G_ROI.mask(ii).id )
          lst = [lst; {G_ROI.mask(ii).id}];
        else
          lst = [lst; {['G ROI ' num2str(ii)]}];
        end
                 
      end
    else
      lst = {['G ROI ' num2str(ii)]};
    end

    set( handles.lst_GROI, 'String', lst, 'Value', G_ROI.Rindex );
    
  end

  update_process_buttons( handles );  
  drawnow();
end




% ---
% --- SelectMask - select mask image
% ---
function btn_SelectMask_Callback(hObject, eventdata, handles)

global Zheader scan_information 

  scan_information.mask.file = '';
  h = findobj('Tag','lbl_MaskName');
  set(h,'String','');
  set(h,'BackgroundColor',constant_define( 'COLOR_GREY' ));

  while isempty( scan_information.mask.file )

    cancel = 0;
    hdr = -1;
    sz = [0 0];

    [msk cancel] = select_mask_image('*.img;*.nii', 'Select your mask.img');
    if ( cancel )
      return
    end

    msk.ind = find( msk.image);
    
    scan_information.mask = msk;

    % compare mask image dimensions and voxel sizing to raw data images
    % --------------------------------------------------------
    if isfield( scan_information.raw_data.header, 'dim' )   
      x = prod(scan_information.mask.header.dim(2:4)) == prod(scan_information.raw_data.header.dim(2:4));
      y = prod(scan_information.mask.header.pixdim(2:4)) == prod(scan_information.raw_data.header.pixdim(2:4));
    else % if from an older Z, there is no raw data, compare mask size to processed size
      x = size(msk.ind) ;
      y = ( x(1) == Zheader.total_columns );
      x = 1;
    end
    
    % --------------------------------------------------------
    if ( x ~= 1 || y ~= 1 )	% mask dimensions do not match
      title = 'Mask Dimension Mismatch';
      text = 'The mask image dimensions or voxel sizes do not match the dimensions or voxel sizes of the raw data images.';
      show_message( title, text );
      scan_information.mask.file = '';
      return;
    end

        
    if cancel == 1
      update_process_buttons( handles );  
      return;
    
    else

      if isempty(scan_information.mask.header)
        str = ['There is no header file associated with this image<br>' scan_information.mask.file ];
        show_message( 'Image Data corrupted', str);
        scan_information.mask.file = '';
      end

    end

  end

  sz = size( scan_information.mask.ind );
  scan_information.mask.x = sz(1);
  scan_information.mask.y = sz(2);
  Zheader.total_columns = scan_information.mask.x;
  Zheader.partitions = calc_column_partitions( Zheader.total_scans, Zheader.total_columns, constant_define( 'PARTITION_MAX' ) );

  if size(scan_information.mask.image,2 ) < 3
    D = reshape( scan_information.mask.image, scan_information.mask.vol.dim);
  else
    D = scan_information.mask.image;
  end
 
  ind = [1:prod(scan_information.mask.vol.dim)];
  [I J K] = ind2sub(size(D), ind);
  IJK = [I; J; K];

  scan_information.mask.isRegistered = isRegistered( scan_information.mask ) ;
  scan_information.mask.MNI = scan_information.mask.vol.mat(1:3,:)*[IJK; ones(1,size(IJK,2))];
  
  if ( isempty( Zheader.Z_Directory ) ) && prod( sz ) > 1 
    Zheader.Z_Directory = [ pwd filesep ];
    save_headers();
  end

  % resetting the mask may have different resulting dimensions on Z matrices  
  if ( isempty( Zheader.Z_File.name )  && exist(scan_information.BaseDir, 'dir') == 7 )
    sum_subject_scans();
  end

  update_process_buttons( handles );  
  
  save_headers();

  drawnow();
end


% ---
% --- SelectG - select G Model
% ---
function btn_SelectG_Callback(hObject, eventdata, handles)

global Zheader scan_information 


  G_var = '';
  g_okay =  0;

  fullpath = select_file( {'*.mat','MATLAB .mat file'}, ...
                                   'Select your G Matrix');
  if ~isempty( fullpath )

    Zheader.Model.file_exists = 1;
    Zheader.Model.path = fullpath;

    [path fn] = split_path( fullpath, filesep );

    mat_vars = matfile_vars( '', fullpath );
    [mf_x mf_y] = size( mat_vars );

    if ( mf_x > 0 )    % there are variables in the file
      if ( mf_x == 1 )   % only a single variable in the file

        if ( ~strcmp(mat_vars.name, 'Gheader' ) )
          if mat_vars.sz_x ~= Zheader.total_scans 
            str = sprintf( 'The selected G Model depth does not match the depth of the subject data (%d scans)', Zheader.total_scans );
            show_message( 'G model size error', str );
            return
          end

          if mat_vars.sz_y < (Zheader.num_subjects * 2 )
            str = sprintf( 'The selected G Model width (%d) appears to be less than the minimum width for a FIR model applied to %d subjects.', ...
mat_vars.sz_y, Zheader.num_subjects );
            show_message( 'G model size error', str );
            return
          end

        end

        if ( strcmp(mat_vars.name, 'Gheader' ) )
          load( fullpath, 'Gheader');
          hdr = Full_G_Parameters( 'Header', Gheader );	 
          Zheader.Model.mat = mat_vars.name;

          pth = [pwd filesep];
          if ( ~strcmp( path, pth) )
            path = [pwd filesep];
            Gfile = [path 'Gheader.mat' ];
            eval ( ['save( ''' Gfile ''', ''Gheader'',''-append'' )'] );
          end

        else

          Zheader.Model.mat = mat_vars.name;
          Zheader.Model.mat_exists = 1;
          Zheader.Model.mat_x = mat_vars.sz_x;
          Zheader.Model.mat_y = mat_vars.sz_y;
        end

      else

        % get user selection of mat in file to use as G
        lst = '';
        for ii=1:mf_x
          lst = horzcat( lst, {mat_vars(ii).name});
        end
        x = mat_selection( lst, 'Select G Matrix' );

        if ( ~strcmp(mat_vars(x).name, 'Gheader' ) && mat_vars(x).sz_x ~= Zheader.total_scans )
          str = sprintf( 'The selected G Model depth does not match the depth of the subject data (%d scans)', Zheader.total_scans );
          show_message( 'G model size error', str );
          return
        end

        Zheader.Model.mat = mat_vars(x).name;
        Zheader.Model.mat_exists = 1;
        Zheader.Model.mat_x = mat_vars(x).sz_x;
        Zheader.Model.mat_y = mat_vars(x).sz_y;

      end  % more than 1 var in file

      g_okay = Zheader.Model.mat_exists && (Zheader.Model.mat_x == Zheader.total_scans) || Zheader.Model.hdr_exists;

    end


    xx = who_stats( path, fn, 'Gheader' );
    Gfile = [path fn ];
    Zheader.Model.hdr_exists = xx.mat_exists;

    if ~xx.mat_exists

      x = [pwd filesep];
      currfile = '';

      if ( length(path) == length(x) )
        if ( sum( x == path ) == length(path) )
          afile = sprintf( 'G_%f', now )

          % --------------------------------------------------
          % matlab load does not like filename with periods, unless extension is added - lets be safe
          % --------------------------------------------------
          afile = strrep( afile, '.', '_' ); 
          currfile = [path afile '.mat' ];
        end
      end

      if ( isempty( currfile ) )
        currfile = [pwd filesep 'Gheader.mat'];
      end

      Gfile = currfile;
      hdr = structure_define( 'GHEADER' );

      subj_width = Zheader.Model.mat_y/(Zheader.num_subjects);  % --- *Zheader.num_runs);
      load( Zheader.Model.path, Zheader.Model.mat );
      % ------------------------------------------------
      % --- find the first row containing a value of 1
      % ------------------------------------------------
      eval ( ['g_one = max(max(' Zheader.Model.mat ')) - .5;' ] );
      eval ( ['eye_start = find(' Zheader.Model.mat '> g_one );' ] );
    
      % ------------------------------------------------
      % --- and get a square matrix from that point of the subject width
      % ------------------------------------------------
      S1 = zeros( subj_width);
      eval ( ['x = find( ' Zheader.Model.mat '( eye_start(1):eye_start(1)+subj_width-1,1:subj_width ) > g_one ); '] );
      S1(x(:)) = 1;

      hdr.bins = sum(sum(eye(subj_width).*S1));
      hdr.conditions = subj_width/hdr.bins;
      hdr.source = [path fn ];		% point to original G.mat as source
      hdr.path_to_segs = [pwd filesep 'Gsegs' filesep ];

      if size( Zheader.conditions.Names, 2 ) > 0 
        hdr.condition_name = Zheader.conditions.Names;
        hdr.conditions = size( Zheader.conditions.Names, 2 );
      else
        for ii = 1:hdr.conditions
          str = sprintf( 'Condition %d', ii );
          hdr.condition_name = [hdr.condition_name; {str}];
        end
      end

      hdr = Full_G_Parameters('Header', hdr); 
      if ( ~isempty(hdr ) )
        hdr.source = [path fn ];		% point to original G.mat as source
      else
        return;
      end
    end

    % previous line wipes out parameters.plotting stuct - reset and fill what info applies
    if ( ~isempty(hdr ) )

      Gheader = adjust_gheader ( hdr );

      eval ( ['save( ''' Gfile ''', ''Gheader'', ''-append'')'] );
      G_to_Gsegs( Gheader );

      g_okay = Zheader.Model.mat_x == Zheader.total_scans && Gheader.conditions > 0;

      scan_information.processing.model.parameters.condition_name = Gheader.condition_name;
      scan_information.processing.model.parameters.model_type = Gheader.model_type;
      scan_information.processing.model.parameters.conditions = Gheader.conditions;
      scan_information.processing.model.parameters.bins = Gheader.bins;
      scan_information.processing.model.parameters.TR = Gheader.TR ;
      scan_information.processing.model.parameters.inScans = Gheader.inScans;
      Zheader.conditions.Names = Gheader.condition_name';

      if isempty( Zheader.conditions.encoded )

        for s = 1:Zheader.num_subjects
          encoded.condition = ones( 1,Gheader.conditions);
          Zheader.conditions.encoded = [Zheader.conditions.encoded; encoded];

          subject.Run = [];
          Run.conditions = [];
          
          for r = 1:Zheader.num_runs
            Run.conditions = [Run.conditions; 1:Gheader.conditions];
            subject.Run = [subject.Run; Run];
          end

          Zheader.conditions.subject = [Zheader.conditions.subject; subject];

        end
      end
       
      Zheader.conditions.sp = condition_start_columns( Gheader.conditions, Gheader.bins );

      Zheader.Model.path = Gfile;
      Zheader.Model.mat_exists = 1;
      Zheader.Model.mat_x = Zheader.total_scans;
      Zheader.Model.mat_y = sum( Gheader.subject_encoded) * Gheader.bins;
      Zheader.Model.hdr_exists = 1;

      scan_information.processing.model.parameters.plotting  = struct( 'global', '', 'extended', '', 'use_extended', 0 );
      scan_information.processing.model.parameters.plotting.global = struct( 'line', '', 'marker', '', 'label', '' );
      scan_information.processing.model.parameters.plotting.global.line = struct( 'style', 2, 'size', 1 );
      scan_information.processing.model.parameters.plotting.global.marker = struct( 'style', 1, 'size', 1, 'color', [0 0 0], 'edge', 0, 'edgecolor', [0 0 0] );
      scan_information.processing.model.parameters.plotting.global.label = struct( 'y_axis', 'Mean Predictor Weights', 'x_axis', 'Time', 'title', '', 'legend', 1 );
      scan_information.processing.model.parameters.plotting.extended = struct ( 'conditions', Gheader.conditions, 'plotting', '' );

      scan_information.processing.model.process.components = 2;	
      scan_information.processing.H_model.process.components = 2;
      scan_information.processing.PD_model.process.components = 2;


      dt = date;
      crt = 'created partitioned G matrix' ;
      src = [ ' From: ' char(Gheader.source) ];
      loc = [ 'Store: ' Gheader.path_to_segs ];
      dim = [ 'Stats: Conditions: ' num2str(Gheader.conditions) '   Bins: ' num2str(Gheader.bins) ];
      write_log( dt, crt, src, loc, dim );

    end
    if ~isempty(Gheader.applied_to)
     try 
        old_Z = load([Gheader.applied_to 'ZInfo.mat']);
        Zheader.conditions = old_Z.Zheader.conditions;
     catch
        disp('could not find ZInfo');
     end
      
    end
  end

  calc_gaz_extents();  

  scan_information.processing.model.apply = g_okay;
  scan_information.processing.model.process.apply_g = g_okay;
  scan_information.processing.model.process.extract_g = 0;  % g_okay;
  scan_information.processing.model.process.rotate_g = 0;  %g_okay;
  scan_information.processing.model.applied.apply_g = 0;
  scan_information.processing.model.applied.rotate_g = 0;

  a_okay = 0;
  if ( Zheader.Contrast.mat_exists )  % change of G requires A application
    a_okay =  g_okay && Zheader.Contrast.mat_exists && ((Zheader.Contrast.mat_x * Zheader.num_subjects) == Zheader.Model.mat_y );
  end

  scan_information.processing.model.process.apply_ga = 0;  %a_okay;
  scan_information.processing.model.process.extract_ga = 0;  %a_okay;
  scan_information.processing.model.process.apply_gaa = 0;  %a_okay;
  scan_information.processing.model.applied.apply_ga = 0;
  scan_information.processing.model.applied.extract_ga = 0;
  scan_information.processing.model.applied.apply_gaa = 0;

  save_headers();
  update_process_buttons( handles );
  
end


% ---
% --- create G - create G Model
% ---
function btn_createG_Callback(hObject, eventdata, handles)

global Zheader scan_information 

  Gheader = structure_define( 'GHEADER' );
  if ~isempty( Zheader.Model.path )
    load( Zheader.Model.path, 'Gheader');
  end

  if isstruct( Gheader )	
    [GH conds] = create_g( 'header', Gheader );
  else
    [GH conds] = create_g;
  end

  clear create_g

  g_okay = 0;

  if ( ~isempty( GH )  )

    % --------------------------------------------
    % --- G creation may have required redefinition of Runs and Conditions
    % --- contained in Zheader - reload to be safe
    % --------------------------------------------

    Zheader.conditions = conds;
    Gheader = GH;
    Zheader.conditions.sp = condition_start_columns( Gheader.conditions, Gheader.bins );

    Gheader.subjects = conds.subject;
    Gheader.subject_encoded = [];
    if ( size(conds.encoded,1) > 0 )
      for ii = 1:size(conds.encoded,1)
        Gheader.subject_encoded = [Gheader.subject_encoded sum( conds.encoded(ii).condition ) ];
      end
    end

    p = [pwd() filesep];
    eval( [ 'save( ''' p 'Gheader.mat'', ''Gheader'', ''-append'');' ] );
	 
    Zheader.Model = who_stats( p, 'Gheader.mat', 'Gheader' );
    Zheader.Model.hdr_exists = Zheader.Model.mat_exists;

    if Zheader.Model.hdr_exists == 1
      Zheader.Model.mat_x = Zheader.total_scans;
      Zheader.Model.mat_y = sum( Gheader.subject_encoded) * Gheader.bins;

    end

    g_okay = ( Zheader.Model.mat_exists || Zheader.Model.hdr_exists ) && (Zheader.Model.mat_x == Zheader.total_scans) && Gheader.conditions > 0;

    scan_information.processing.model.parameters.model_type = Gheader.model_type;
    scan_information.processing.model.parameters.conditions = Gheader.conditions;
    scan_information.processing.model.parameters.bins = Gheader.bins;
    scan_information.processing.model.parameters.TR = Gheader.TR;
    scan_information.processing.model.parameters.inScans = Gheader.inScans;
    scan_information.processing.model.parameters.condition_name = Gheader.condition_name;

    scan_information.processing.model.parameters.plotting  = struct( 'global', '', 'extended', '', 'use_extended', 0 );
    scan_information.processing.model.parameters.plotting.global = struct( 'line', '', 'marker', '', 'label', '' );
    scan_information.processing.model.parameters.plotting.global.line = struct( 'style', 2, 'size', 1 );
    scan_information.processing.model.parameters.plotting.global.marker = struct( 'style', 1, 'size', 1, 'color', [], 'edge', 0, 'edgecolor', [] );
    scan_information.processing.model.parameters.plotting.global.label = struct( 'y_axis', 'Mean Predictor Weights', 'x_axis', 'Time', 'title', '', 'legend', 1 );
    scan_information.processing.model.parameters.plotting.extended = struct ( 'conditions', Gheader.conditions, 'plotting', '' );

    scan_information.processing.model.process.components = 2;
    scan_information.processing.H_model.process.components = 2;
    scan_information.processing.PD_model.process.components = 2;

   
    calc_gaz_extents();  

    scan_information.processing.model.apply = g_okay;
    scan_information.processing.model.process.extract_g = 0;  %scan_information.processing.model.process.apply_g;
    scan_information.processing.model.process.rotate_g = 0;  %scan_information.processing.model.process.apply_g;
    scan_information.processing.model.applied.apply_g = 0;
    scan_information.processing.model.applied.extract_g = 0;
    scan_information.processing.model.applied.rotate_g = 0;

    a_okay = 0;
    if ( Zheader.Contrast.mat_exists )  % change of G requires A application
      a_okay =  g_okay && Zheader.Contrast.mat_exists && ((Zheader.Contrast.mat_x * Zheader.num_subjects) == Zheader.Model.mat_y )
    end

    scan_information.processing.model.process.apply_ga = 0;  %a_okay;
    scan_information.processing.model.process.extract_ga = 0;  %a_okay;
    scan_information.processing.model.process.apply_gaa = 0;  %a_okay;
    scan_information.processing.model.applied.apply_ga = 0;
    scan_information.processing.model.applied.extract_ga = 0;
    scan_information.processing.model.applied.apply_gaa = 0;

    %  Update handles structure
    guidata(hObject, handles);

    save_headers();
    update_process_buttons( handles );

    drawnow();

  end
  
end

  

% ---
% --- addA - add an A Contrast
% ---
function btn_addA_Callback(hObject, eventdata, handles)

  Btn_SelectA_Callback(hObject, eventdata, handles)

end


% ---
% --- SelectA - select A Contrast
% ---
function Btn_SelectA_Callback(hObject, eventdata, handles)

global Zheader scan_information 

  op = 'new';
  nm = get( hObject, 'tag' );
  if strcmp( nm, 'btn_addA' )
    op = 'add';
  end;
  
  Am = Select_A( op );
  
  if ~isempty( Am )
    load( Zheader.Model.path, 'Gheader' );

    switch op
        case 'new'
          Aheader = Am;
          save Aheader Aheader;
          Zheader.Contrast =  who_stats( [pwd filesep],  'Aheader.mat', 'Aheader' );
          
        case 'add'
          load( Zheader.Contrast.path  );
          Aheader.model = [Aheader.model; Am.model ];
          Aheader.Aindex = Aheader.Aindex + 1;
          save Aheader Aheader;
        case 'edit'
    end
    
    lst = '';
    for Alist = 1:size( Aheader.model, 1 );
      lst = [lst {Aheader.model(Alist).id} ];
    end;
    set( handles.lst_A, 'String', lst, 'Value', Aheader.Aindex );
    
    x = Aheader.model(Aheader.Aindex).mat_x;
    y = Aheader.model(Aheader.Aindex).mat_y;
    load( Zheader.Contrast.path  );

    Amodel = Aheader.model(Aheader.Aindex);

    pth_add = '';
    if Aheader.Aindex > 1
      pth_add = strrep( [ Aheader.model(Aheader.Aindex).id filesep], ' ', '_' );
    end
      
    Aheader.model(Aheader.Aindex).path_to_G = [ Gheader.path_to_segs pth_add ];
    if ~exist( Aheader.model(Aheader.Aindex).path_to_G, 'dir' )
      eval( [ 'mkdir ' Aheader.model(Aheader.Aindex).path_to_G ';' ] );
    end;
      
    save Aheader Aheader;
    
    for SubjectNo = 1:Zheader.num_subjects
          
      OutFile = [ Aheader.model(Aheader.Aindex).path_to_G 'GA_S' num2str(SubjectNo) '.mat'];
      initialize_mat_file( OutFile );  
        
      G = [];
      for RunNo = 1:Zheader.num_runs     
        if iscellstr( scan_information.SubjDir(SubjectNo, RunNo ) )
          G = [ G; load_run_G( Gheader, SubjectNo, RunNo, 'GA' ) ];
        end
      end;
      GG = G' * G;
      gg = sqrtm(pinv( GG ) );
      save( OutFile, 'GG', 'gg', '-append', '-v7.3' );
        
    end;

  end;
  

  calc_gaz_extents();  

  g_okay = ( Zheader.Model.mat_exists || Zheader.Model.hdr_exists ) && (Zheader.Model.mat_x == Zheader.total_scans );
  a_okay = g_okay && Zheader.Contrast.mat_exists;

  scan_information.processing.model.process.apply_ga = a_okay;
  scan_information.processing.model.process.extract_ga = 0;  
  scan_information.processing.model.process.apply_gaa = 0;  
  scan_information.processing.model.applied.apply_ga = 0;
  scan_information.processing.model.applied.extract_ga = 0;
  scan_information.processing.model.applied.apply_gaa = 0;

  save_headers();
  update_process_buttons( handles );

end



  
% --- Executes on button press in btn_addH.
function btn_addH_Callback(hObject, eventdata, handles)

global Zheader scan_information 

  handles.addH = ~isempty(Zheader.Limits.path);
  
  % Update handles structure  
  guidata(hObject, handles);
  Btn_SelectH_Callback(hObject, eventdata, handles, handles.addH);
  
  handles.addH = 0;
end

  

% ---
% --- SelectH - select H Limits
% ---
function Btn_SelectH_Callback(hObject, eventdata, handles, from_add)

global Zheader scan_information 

  H_var = '';
  h_okay =  0;
  Hindex = 1;
  if nargin < 4  from_add = 0; end
  
 
  Hm = H_Selection();
  if ~isempty( Hm )

    if from_add
      load( Zheader.Limits.path );
      Hn = structure_define( 'HHEADER' );
      Hheader.model = [Hheader.model; Hn.model];
      Hheader.Hindex = size( Hheader.model, 1 );

    else
      Hheader = structure_define( 'HHEADER' );
    end
      
    Hheader.model(Hheader.Hindex) = Hm;
    
    % H will need to be partitioned by frequency if beamformed data 
    Hheader.model(Hheader.Hindex).partitions = calc_Qh_Blocksize( Zheader.total_columns, constant_define( 'PARTITION_MAX' ) );

    x = who_stats( Hheader.model(Hheader.Hindex).path, Hheader.model(Hheader.Hindex).file, 'HRegions');

    Zheader.Limits.path = [pwd filesep 'Hheader.mat' ];
    Zheader.Limits.hdr_exists = 1;
    Zheader.Limits.mat_exists = 1;                % --- dialog would not return if it did not
    if Hheader.model(Hheader.Hindex).size(1) == Zheader.total_columns
      A = Hheader.model(Hheader.Hindex).size;
    else
      A = sort( Hheader.model(Hheader.Hindex).size, 'descend' );
    end
      
    Zheader.Limits.mat_x = A(1);                  % --- note: x,y diplay may be swapped from actual orientation
    Zheader.Limits.mat_y = A(2);		  % --- always reorient from actual orientation from Hheader.size
    Zheader.Limits.mat = Hheader.model(Hheader.Hindex).var;

    if isempty( Hheader.model( Hheader.Hindex ).id )
      Hheader.model( Hheader.Hindex ).id = Hheader.model( Hheader.Hindex ).var;
    end
    
    save( Zheader.Limits.path, 'Hheader');

    if handles.addH
      lst = get( handles.lst_H, 'String' );
    else
      lst = [];
    end
    
    if ~isempty( Hheader.model(Hheader.Hindex).id )
      lst = [lst; {Hheader.model(Hheader.Hindex).id}];
    else
      lst = [lst; {['H ' num2str(Hheader.Hindex)]}];
    end
                 
    set( handles.lst_H, 'String', lst, 'Value', Hheader.Hindex );
    
  end

  calc_gaz_extents();  
  save_headers();
  update_process_buttons( handles );

  
  % Update handles structure  
  guidata(hObject, handles);
  
end


 


  
% --- Executes on button press in Btn_SelectP.
function Btn_SelectP_Callback(hObject, eventdata, handles)

global Zheader scan_information 

  [fn, path] = uigetfile('*.mat', 'Select your P Matrix' );

  if isequal(fn,0) || isequal(path,0)
    Zheader.P = handles.funcs.clear_model();
  else

    Zheader.P = who_stats( path, fn, 'P' );
    if Zheader.P.mat_exists == 1
    end

  end

  calc_gaz_extents();  
  save_headers();
  update_process_buttons( handles );

end



% --- Executes on button press in Btn_SelectD.
function Btn_SelectD_Callback(hObject, eventdata, handles)

global Zheader scan_information 

  [fn, path] = uigetfile('*.mat', 'Select your D Matrix' );

  if isequal(fn,0) || isequal(path,0)
    Zheader.D = handles.funcs.clear_model();
  else

    Zheader.D = who_stats( path, fn, 'D' );
    if Zheader.D.mat_exists == 1
    end

  end

  calc_gaz_extents();  
  save_headers();
  update_process_buttons( handles );

end




  
% ---
% --- ChangeDirectory - change present directory
% ---
function btn_ChangeDirectory_Callback(hObject, eventdata, handles)

  dirname = uigetdir('', 'Pick a different drive or directory');

  if ~isequal( dirname, 0)
    command = sprintf( 'cd ''%s''', dirname );
    eval ( command );

    update_process_buttons( handles );

    % set the GUI Title to display revision number
    set( handles.output, 'Name', [ 'cpca ' constant_define( 'REVISION_NUMBER')  ' [ ' short_path(pwd, 6) ' ]' ] );

  end
end


  


% ---------------------------------------------------------------------------
% --- Processing Buttons 
% ---------------------------------------------------------------------------


% ---
% --- PerformCPCA - perform all selected processes
% ---
function btn_PerformCPCA_Callback(hObject, eventdata, handles)

global scan_information

  set( hObject, 'Enable', 'off' );
  set( handles.btn_UnloadData, 'Enable', 'off' );
  set( handles.btn_ChangeDirectory, 'Enable', 'off' );

% --- check if hrfmax has a state file to load
  for idx = 1:size(scan_information.processing.model.rotation, 1)
    if strcmp( lower(scan_information.processing.model.rotation(idx).method), 'hrfmax' )
      if exist( 'hrfmax_state.mat', 'file' ) && ~scan_information.processing.model.rotation(idx).parameters.load_state
        scan_information.processing.model.rotation(idx).parameters.load_state = load_hrfmax_state_query();        
      else
        if ~exist( 'hrfmax_state.mat', 'file' )
          scan_information.processing.model.rotation(idx).parameters.load_state = 0;
          save_headers();
        end
      end
    end
  end

  process_data(hObject, eventdata, handles);

  set( hObject, 'Enable', 'on' );
  set( handles.btn_UnloadData, 'Enable', 'on' );
  set( handles.btn_ChangeDirectory, 'Enable', 'on' );

  save_headers();
  update_process_buttons( handles );
  
end




% ---
% --- NumComp_GA - retrieve the number of components to extract
% ---
function NumComp_GA_Callback(hObject, eventdata, handles)

global scan_information;

  str = get(hObject,'String');
  str = validate_numeric_vector( str );
  set(hObject,'String', str );

  numcomps = '';
  eval( ['numcomps = [' str '];' ] );

  scan_information.processing.model.process.components = numcomps;
  scan_information.processing.model.process.svd = ones(1, size( numcomps, 2 ) );
  save_headers();
  
end


% ---
% --- NumComp_GA - retrieve the number of components to extract when changing
% ---
function NumComp_GA_KeyPressFcn(hObject, eventdata, handles)

  k = eventdata.Key;

  if ( strcmp( k, 'return' ) )
    drawnow();				% force text input box update with current value
  end

  NumComp_GA_Callback( hObject, 0, 0 );
  
end


% ---
% --- NumComp_H - retrieve number of components to extract from H
% ---
function NumComp_H_Callback(hObject, eventdata, handles)

global scan_information;

  str = get(hObject,'String');
  str = validate_numeric_vector( str );
  set(hObject,'String', str );

  numcomps = '';
  eval( ['numcomps = [' str '];' ] );

  scan_information.processing.H_model.process.components = numcomps;
  save_headers();
  
end


% ---
% --- NumComp_H - retrieve the number of components to extract when changing
% ---
function NumComp_H_KeyPressFcn(hObject, eventdata, handles)

  drawnow();				% force text input box update with current value
  NumComp_H_Callback( hObject, 0, 0 );
  
end


function NumComp_GMH_Callback(hObject, eventdata, handles)

global scan_information;

  str = get(hObject,'String');
  str = validate_numeric_vector( str );
  set(hObject,'String', str );

  numcomps = '';
  eval( ['numcomps = [' str '];' ] );

  scan_information.processing.GMH_model.process.components = numcomps;
  save_headers();
  
end


% --- Executes on key press with focus on NumComp_GMH and none of its controls.
function NumComp_GMH_KeyPressFcn(hObject, eventdata, handles)

  drawnow();				% force text input box update with current value
  NumComp_GMH_Callback( hObject, 0, 0 );
  
end


% ---
% --- NumComp_PD - retrieve the number of components to extract
% ---
function NumComp_PD_Callback(hObject, eventdata, handles)

global scan_information;
  str = get(hObject,'String');
  str = validate_numeric_vector( str );
  set(hObject,'String', str );

  numcomps = '';
  eval( ['numcomps = [' str '];' ] );

  scan_information.processing.PD_model.process.components = numcomps;
  
end


% ---
% --- NumComp_PD - retrieve the number of components to extract when changing
% ---
function NumComp_PD_KeyPressFcn(hObject, eventdata, handles)

global scan_information;
  scan_information.processing.PD_model.components = str2double(get(hObject,'String'));
  NumComp_PD_Callback( hObject, 0, 0 );
  
end




  

% ---------------------------------------------------------------------------
% --- Toggle Buttons
% ---------------------------------------------------------------------------

% --- Executes on button press in chk_GOkay.
function chk_GOkay_Callback(hObject, eventdata, handles)

end



% --- Executes on button press in chk_PDOkay.
function chk_PDOkay_Callback(hObject, eventdata, handles)

end




% --- Executes on button press in chk_MCScans.
function chk_MCScans_Callback(hObject, eventdata, handles)

  global scan_information;
  scan_information.mean_center_subjects = get(hObject,'Value');
  
end





% --- Executes on button press in chk_MeanCentered.
function chk_MeanCentered_Callback(hObject, eventdata, handles)

  global scan_information;
  scan_information.mean_center_subjects = get(hObject,'Value');
  
end


% --- Executes on button press in chk_Normalized.
function chk_Normalized_Callback(hObject, eventdata, handles)

  global scan_information;
  scan_information.normalize_subjects = get(hObject,'Value');
  
end



% ---------------------------------------------------------------------------
% --- Display Functions
% ---------------------------------------------------------------------------

% ---
% --- update_memory_stats() - update the displayed memory statistics
% ---
function update_memory_stats()

global Zheader 

  memory = check_memory();
  pct_cached = (memory.user.cache/memory.user.total ) * 100;
  mem_max = memory.user.free;
  max_reqd = 0;                     % --- amount of memory required for operation
  
  if ~isempty( Zheader.ts_vector )
    user_mem = array_sizes( [ max(Zheader.ts_vector) Zheader.partitions.width ] );
    max_reqd = user_mem.megabytes;
    if ( ~isempty( Zheader.Model.path ) )
       B_mem = array_sizes( [ Zheader.Model.mat_y Zheader.total_columns] );
       max_reqd = max( user_mem.megabytes, B_mem.megabytes );
    end
  end


  
  % --- show the amount of available memory
  if ( mem_max < 500 )
    str = sprintf( '%.02f MB', mem_max );
  else
    str = sprintf( '%.02f GB', mem_max/1000 );
  end

  h = findobj('Tag','txt_AvailMem');
  set(h,'String',str);

  
  % --- show the amount of cached memory
  fwgt = 'normal';                                          % normal font
  bgcolor = constant_define( 'COLOR_GREY' );                % normal background
%  if exist( 'Zheader', 'var' )  %%%% here to 1750 commented out by paul
% 
%     dp = max_reqd / mem_max * 100;
%     if ( dp >= 80 )
%       bgcolor = constant_define( 'COLOR_YELLOW' );			% yellow background ( caution )
%       fwgt = 'bold';			% bold font
% 
%       if ( dp > 90 )
%         bgcolor = constant_define( 'COLOR_ORANGE' );		% orange background ( critical )
%       end
% 
%       if ( dp > 98 )
%         bgcolor = constant_define( 'COLOR_RED' ) ;          % red background ( your screwed )
%       end
%     end
% 
%  end

  h = findobj('Tag','txt_CachedMem');
  set(h,'String',str);
  set(h,'BackgroundColor',bgcolor);
  set(h,'FontWeight',fwgt);

  % --- show the warning level of cached memory
  h = findobj('Tag','btn_clear_cache');
  bgcolor = constant_define( 'COLOR_GREY' );		% normal background

  if ( isunix() && ~ismac() ) 
    if ( memory.user.cache < 100 )
      str = sprintf( 'Cache: %.02f MB', memory.user.cache );
    else
      str = sprintf( 'Cache: %.02f GB', memory.user.cache/1000 );
    end

    if pct_cached > 40
      bgcolor = constant_define( 'COLOR_YELLOW' );			% yellow background ( caution )
      if ( pct_cached > 80 )
        bgcolor = constant_define( 'COLOR_ORANGE' );		% orange background ( critical )
      else
        if ( pct_cached > 90 )
          bgcolor = constant_define( 'COLOR_RED' );         % red background ( your screwed )
        end
      end

    end

    set( h, 'String', str );

  end

  set(h,'BackgroundColor',bgcolor);
  drawnow();
  
end




% ---------------------------------------------------------------------------
% --- Miscellaneous Functions
% ---------------------------------------------------------------------------

function btn_FileList_Callback(hObject, eventdata, handles)

  File_List_Creation();
  clear File_List_Creation

  update_process_buttons( handles );
  drawnow();
  
end
  



  
% ---------------------------------------------------------------------------
% --- Main Processing Loop
% ---------------------------------------------------------------------------
function process_data(hObject, eventdata, handles)
global scan_information Zheader process_information;

  log_results = 1;		% set to 0 if you want to run tests without a ton of files in the directory
  Gheader = [];
  Hheader = [];
  
  handles.processingData = 1;

  timing_stats = struct ( 'start_time', 0, 'end_time', 0, 'duration', 0 );
  timers = struct ( ...
     'Normalize', timing_stats,...
     'ApplyG', timing_stats,...
     'ExtractG', timing_stats,...
     'ApplyGA', timing_stats,...
     'ExtractGA', timing_stats,...
     'ApplyGAA', timing_stats,...
     'ApplyH', timing_stats,...
     'ApplyPD', timing_stats,...
     'Overall', timing_stats );


  timers.Overall.start_time = clock;

  MainText = 'Performing Constrained PCA on all subjects.';

  if ( isa( handles.progressBar, 'cpca_progress' ) )
    handles.progressBar.unsetHRFMAX();
    handles.progressBar.setWindowTitle( MainText );
    handles.progressBar.show();
    handles.progressBar.setIterations( 100, handles.progressBar.PRIMARY );
    handles.progressBar.setIterations( 100, handles.progressBar.SECONDARY );
    handles.progressBar.setMessages( '', '','' );
    handles.progressBar.setPong( 0 );
  end
  
  abort_process = 0;		% flag from process indicating a critical error requiring graceful termination
  isROI = get( handles.lbl_GROI, 'Value' );
  if isROI
    load G_ROI
  end

  dt = date;
  cl = clock;
  ampm = 'AM';

  if cl(4) > 12
    ampm = 'PM';
    cl(4) = cl(4) - 12;
  end

  hr = sprintf( '%02d', cl(4) );
  mn = sprintf( '%02d', cl(5) );

  noParms = struct( 'empty', 1 );

  mkdir log;

  log_fn = ['log/cpca_processing_' dt '_' hr ':' mn '_' ampm '.txt' ];
  log_fn = strrep( log_fn, ':', '_' );

  if log_results
    log_fid = fopen( log_fn, 'w' );
    if log_fid == -1  
      log_fid = 0;  
    end   % -- some remote systems may fail on log opening
  else
    log_fid = 0;
    print_title( 'Output logging is off.' );
  end
  
  SSQ = [];
  
  % ----------------------------------------
  % load and normalize subject data
  % ----------------------------------------
  if scan_information.processing.subjects.apply == 1 
    process_subject_normalization();
    % --- Zheader and Scan_info have changed
    load( 'ZInfo.mat', 'Zheader', 'scan_information' );

    scan_information.processing.subjects.apply = 0;  		% flag no longer needing to scan the subjects
    scan_information.processing.subjects.normalized = date;  	
    scan_information.processing.subjects.process.apply_regression = 0;
    scan_information.processing.subjects.process.linear_regress = 0;
    scan_information.processing.subjects.process.quadratic_regress = 0;
    scan_information.processing.subjects.process.movement_regress = 0;
    scan_information.processing.subjects.process.mean_center = 0;
    scan_information.processing.subjects.process.standardize = 0;
    scan_information.processing.subjects.process.create_ZZ = 0;
    scan_information.processing.subjects.process.extract_clusters = 0;
    scan_information.processing.subjects.process.create_Z = 0;

    save_headers();
    
  end
  
  if ( isa( handles.progressBar, 'cpca_progress' ) )
    handles.progressBar.clearParticipant();
    handles.progressBar.clearRun();
  end

  if ~isempty(Zheader.Model.path) 
    load( Zheader.Model.path, 'Gheader' );
  end
  
  Aheader = [];
  
  % -----------------------------------------------------------
  % G/A processing
  % -----------------------------------------------------------
  if scan_information.processing.model.apply == 1 

    b = findobj( 'Tag', 'btn_run_ga_process' );
    set( b, 'BackgroundColor', constant_define( 'COLOR_YELLOW' ) );
    drawnow();

    condition = [' No'; 'Yes'];

   
    %% -----------------------------------------------------------
    % Apply G to Z
    % -----------------------------------------------------------

    if scan_information.processing.model.process.apply_g == 1

      model = 'G';
      if isChecked( handles.chk_apply_ga )
        model = 'GA';
      end;
      if isChecked( handles.chk_apply_gaa )
        model = 'GAA';
      end;

      
      Gpath = '';
      iters = 0;
      
      regress_G();

      % Gheader GZheader altered and saved, but not global - reload for logging
      load( Zheader.Model.path, 'Gheader' );
     
      if isROI
        save G_ROI G_ROI

        roi_id = strrep( G_ROI.mask( G_ROI.Rindex).id, ' ', '_' );
        Gpath = [ 'GZsegs' filesep 'ROI' filesep roi_id filesep ];			% eg: GZ_segs, GAZ_segs
  
        txt = G_ROI.mask( G_ROI.Rindex).id;

      else
        if ~strcmp( model, 'G' )
          load( Zheader.Contrast.path );
          eval( [ 'Gpath = Aheader.model( Aheader.Aindex).path_to_' model ';' ] );
          txt = 'GAC';
        else
          eval( [ 'Gpath = Gheader.' model 'Zheader.path_to_segs;' ] );
          txt = 'GC';
        end
      end
      
      if ~strcmp( model, 'GAA' )
        varf = [ Gpath 'GC_vars.mat' ];
      else
        varf = [ Gpath 'BB_vars.mat' ];
        txt = 'GnotAC';
      end
        
      if ~exist( varf, 'file' )
        show_message( 'Missing GC information', ['Unable to locate file containg GC information<br>file: ' varf] );
%        initialize_mat_file( varf );
        return;
      end
      
      if isROI
        SSQ = GC_sum_of_squares( Gpath, 'ROI' );
        G_ROI.mask( G_ROI.Rindex).sum_diagonal = SSQ.sd;
        save G_ROI G_ROI

        GC_SD_Report( Gpath, 'ROI' );

      else
        SSQ = GC_sum_of_squares( Gheader, model );
        
        if ~strcmp( model, 'G' )
          idx = 1 + strcmp( model, 'GAA' );
          Aheader.model( Aheader.Aindex).sd(idx) = SSQ.sd;
        else
          Gheader.GZheader.rsum = SSQ.Rsd;
          save( Zheader.Model.path, 'Gheader' );
        end;

        GC_SD_Report( Gheader, model, txt );

        if ( Gheader.model_type == constant_define( 'FIR_MODEL') & ~strcmp( model, 'GA' ) & ~strcmp( model, 'GAA' ) )
          mean_beta_images(Gheader, handles.progressBar);
        end
        
      end
      
      
      dt = date;

%      Zheader.rsum = SSQ.Rsd;
      Zheader.cpca_version = constant_define( 'REVISION' );   % ---  update created revision number to bypass UR/FR alterations later
      scan_information.processing.model.process.apply_g = 0;
      scan_information.processing.model.applied.apply_g = 1;
      scan_information.processing.model.applied.resume_g.resume = 0;
      save_headers();

      h = findobj('Tag', 'chk_apply_G');
      set(h, 'Value',scan_information.processing.model.process.apply_g );

      set( handles.lbl_G_applied, 'Visible', 'on' );
      set( handles.chk_resume_apply_g, 'Visible', 'off' );
      set( handles.btn_regress_G_settings, 'Visible', 'off' );

      update_process_buttons( handles );
   
      drawnow();
      
    end


    %% -----------------------------------------------------------
    % Extract and Rotate G unrotated components
    % -----------------------------------------------------------
    if scan_information.processing.model.process.extract_g == 1 || scan_information.processing.model.process.subject_specific == 1 || ...
       scan_information.processing.model.process.rotate_g == 1  || scan_information.processing.model.process.subject_specific_rotated == 1
      tic;
      timers.Extract_G.start_time = clock;
      num_procs = size(scan_information.processing.model.process.components, 2);
      
      model = 'G';
      if isChecked( handles.chk_apply_ga ),         model = 'GA';      end;
      if isChecked( handles.chk_apply_gaa ),        model = 'GAA';     end;
      
      if isa( handles.progressBar, 'cpca_progress' )

        % --- extraction
        handles.progressBar.setIterations( Zheader.num_subjects * 2, handles.progressBar.PRIMARY );
        % --- imaging
        handles.progressBar.addIterations( max(scan_information.frequencies, 1) * ...
                                   sum(scan_information.processing.model.process.components) * ...
                                   (num_active_thresholds() * 6 ), handles.progressBar.PRIMARY );

        % --- rotation
        handles.progressBar.setIterations( 4 * size(scan_information.processing.model.rotation, 1), handles.progressBar.PRIMARY );
        % --- imaging
        handles.progressBar.addIterations( max(scan_information.frequencies, 1) * ...
                                   sum(scan_information.processing.model.process.components) * ...
                                   (num_active_thresholds() * 6 ) ...
          * size(scan_information.processing.model.process.components, 2) ...
          * size(scan_information.processing.model.rotation, 1) ...
          , handles.progressBar.PRIMARY );
      end
      
      Aheader = [];
      
      for comp_idx = 1:size(scan_information.processing.model.process.components, 2)

        nd = scan_information.processing.model.process.components(comp_idx);
        if ( nd > 0 )  

%          ext = ['Extract ' num2str(nd) ' components'];
          
          if scan_information.processing.model.process.extract_g == 1 || scan_information.processing.model.process.subject_specific == 1
              
            if scan_information.processing.model.process.extract_g == 1 || ...
                    scan_information.processing.model.process.subject_specific == 1 
              extract_components_of_G();
            end
            

            scan_information.processing.model.process.extract_g == 0; 
            update_process_buttons( handles );
            drawnow();
            
          end ; % --- extract components 

          if scan_information.processing.model.process.rotate_g == 1 || ...        
             scan_information.processing.model.process.subject_specific_rotated == 1

           rotate_components_of_G();
           
          end; % --- rotate components 
          
        end ; % --- valid number of components to extract

       
      end ; % --- each entered component value ---

      timers.Extract_G.end_time = clock;
      timers.Extract_G.duration = toc;
      display_timer( timers.Extract_G, 'Extract G');

      scan_information.processing.model.applied.extract_g = scan_information.processing.model.process.extract_g;
      scan_information.processing.model.applied.rotate_g = scan_information.processing.model.process.rotate_g;
      scan_information.processing.model.process.extract_g = 0;
      scan_information.processing.model.process.rotate_g = 0;
      scan_information.processing.model.process.subject_specific = 0;
      scan_information.processing.model.process.subject_specific_rotated = 0;
      save_headers();

      update_process_buttons( handles );
      drawnow();

    end

    b = findobj( 'Tag', 'btn_run_ga_process' );
    set( b, 'Value', 0 );
    set( b, 'BackgroundColor', constant_define( 'COLOR_GREY' ) );
    drawnow();

  end

  

  %% ----------------------------------------
  % Apply H processing to normalized Z data
  % ----------------------------------------
  
  if ~isempty(Zheader.Limits.path) 
    load( Zheader.Limits.path );
  end
  
  if scan_information.processing.H_model.apply || scan_information.processing.H_model.extract || scan_information.processing.H_model.rotate

    set( handles.btn_run_h_process, 'BackgroundColor', constant_define( 'COLOR_YELLOW' ) );
    drawnow();

    tic
    timers.ApplyH.start_time = clock;

    condition = [' No'; 'Yes'];

    if ( isa( handles.progressBar, 'cpca_progress' ) )
      handles.progressBar.setProcess( 'Applying H Model to Z' );
    end

    if scan_information.processing.H_model.apply
 
      model = 'G';
      if isChecked( handles.chk_apply_ga )
        model = 'GA';
      end;
      if isChecked( handles.chk_apply_gaa )
        model = 'GAA';
      end;
        
      if ( scan_information.processing.H_model.process.hz )

        if ( isa( handles.progressBar, 'cpca_progress' ) )
          handles.progressBar.setIterations( Zheader.active_runs * 2 , handles.progressBar.PRIMARY );
        end

         
        SoS =  apply_H_to_Z_data( handles.funcs, 'Z', model, handles.progressBar );

        if ( SoS == 0 )
          if ( isa( handles.progressBar, 'cpca_progress' ) )
            handles.progressBar.hide();
          end
          return;
        end
        load( Zheader.Limits.path );   % --- reload the Hheader
        BH_SD_Report( Hheader, 'ZH' );

        scan_information.processing.H_model.applied.apply_hz = 1;

      end

      if ( scan_information.processing.H_model.process.he )
    
        if ( isa( handles.progressBar, 'cpca_progress' ) )
          handles.progressBar.setIterations( Zheader.active_runs * 2 , handles.progressBar.PRIMARY );
        end

        SoS =  apply_H_to_Z_data( handles.funcs, 'E', model, handles.progressBar );

        if ( SoS == 0 )
          if ( strcmp( class(progress.pb), 'cpca_progress' ) )
            handles.progressBar.hide();
          end
          return;
        end

        scan_information.processing.H_model.applied.apply_he = 1;

      end  

      timers.ApplyH.end_time = clock;
      timers.ApplyH.duration = toc;
      display_timer( timers.ApplyH, 'Apply H' );

      dt = date;

      scan_information.processing.H_model.apply = 0;
      scan_information.processing.H_model.applied.apply_h = 1;
      scan_information.processing.H_model.applied.resume_h.resume = 0;
      save_headers();

      update_process_buttons( handles );
      drawnow();

    end  % --- H application ---

    % -----------------------------------------------------------
    % Extract HZ/HE unrotated components
    % -----------------------------------------------------------
    if scan_information.processing.H_model.extract
      tic;
      timers.Extract_H.start_time = clock;
      num_extractions = size(scan_information.processing.H_model.process.components, 2);

      if ( isa( handles.progressBar, 'cpca_progress' ) )
        handles.progressBar.setIterations( Zheader.active_runs * ...
          ( sum(scan_information.processing.model.process.components) * ...
            max(scan_information.frequencies, 1) ) * ...
             num_extractions ...
          , handles.progressBar.PRIMARY );
      end

      for ( comp_idx = 1:num_extractions )

        nd = scan_information.processing.H_model.process.components(comp_idx);
        if nd > 0 

          if scan_information.processing.H_model.process.hz

            str = sprintf( 'Extracting %d components from ZH', nd );
            print_title( str );
            if ( isa( handles.progressBar, 'cpca_progress' ) )
              handles.progressBar.setProcess( str );
            end

            abort_process = extract_h_components(nd, 'ZH', handles.progressBar );

            if ( abort_process )
              if ( isa( handles.progressBar, 'cpca_progress' ) )
                handles.progressBar.hide();
              end
              return;
            end

            scan_information.processing.H_model.applied.extract_hz = 1;

            save_headers();

            [H_ID H_Segments] = H_path_spec( Hheader, 'ZH' );
            noParms = struct( 'model', 'H', 'mode', 'ZH', 'hindex',  H_ID );
            component_directory = fs_path( 'unrotated', 'output', nd, 0, noParms );

            in_file = fs_filename( 'mat', 'ZH', 'unrotated', struct( 'model', 'H', 'mode', 'ZH')  );
            in_file = [component_directory in_file];

            x=exist( in_file );
            if x == 2   % the file exists
              h_images_unrotated( nd, 'ZH', log_fid, handles.progressBar );
            end

            update_process_buttons( handles );
            btn_view_ZH_Callback(handles.btn_view_ZH, [], handles)
            drawnow();

          end


          if scan_information.processing.H_model.process.he

            str = sprintf( 'Extracting %d components from EH', nd );
            print_title( str );
            if ( isa( handles.progressBar, 'cpca_progress' ) )
              handles.progressBar.setProcess( str );
            end

            abort_process = extract_h_components(nd, 'EH', handles.progressBar );

            if ( abort_process )
              if ( isa( handles.progressBar, 'cpca_progress' ) )
                handles.progressBar.hide();
              end
              return;
            end

            scan_information.processing.H_model.applied.extract_he = 1;

            save_headers();

            [H_ID H_Segments] = H_path_spec( Hheader, 'EH' );
            noParms = struct( 'model', 'H', 'mode', 'EH', 'hindex',  H_ID );
            component_directory = fs_path( 'unrotated', 'output', nd, 0, noParms );

            in_file = fs_filename( 'mat', 'EH', 'unrotated', struct( 'model', 'H', 'mode', 'EH')  );
            in_file = [component_directory in_file];

            x=exist( in_file );
            if x == 2   % the file exists
              h_images_unrotated( nd, 'EH', log_fid, handles.progressBar );
            end

            update_process_buttons( handles );
            btn_view_EH_Callback(handles.btn_view_EH, [], handles)
            drawnow();

          end


%           dt = date;
%           ext = ['Extract ' num2str(nd) ' components' ];
%           src = [ ' From: ' Zheader.Z_Directory 'ZInfo' ];
%           out_file = ['Store: ' pwd '/GH_nd' num2str(nd) '_unrotated.mat' ];
% 
%           img_dir = '';
%           images_done = '';


        end ; % --- valid component number ---

      end ; % --- each entered component value ---

      timers.Extract_H.end_time = clock;
      timers.Extract_H.duration = toc;
      display_timer( timers.Extract_H, 'Extract H');

      scan_information.processing.H_model.extract = 0;
      scan_information.processing.model.applied.extract = 1;


      save_headers();

      update_process_buttons( handles );
      drawnow();

    end  % -- extract H components ---


    % -----------------------------------------------------------
    % rotate extracted components from HE/HZ
    % -----------------------------------------------------------
    if scan_information.processing.H_model.rotate == 1

      H_models = [{'ZH'} {'EH'} ];

      tic
      timers.ExtractH.start_time = clock;

      extract_from = get( handles.chk_apply_HZ, 'Value');
      extract_from = [extract_from get( handles.chk_apply_HE, 'Value') ];

      for model_no = 1:size(H_models,2)

        if extract_from(model_no)

          this_model = char(H_models(model_no));
 
          for ( comp_idx = 1:size(scan_information.processing.H_model.process.components, 2) )

            nd = scan_information.processing.H_model.process.components(comp_idx);
            if nd > 0 
              component_directory = fs_path( 'unrotated', 'output', nd, 0, struct( 'model', 'H', 'mode', this_model ) );

              % -----------------------------------------------------------
              % is there a processed .mat file for the non rotated solution
              % -----------------------------------------------------------
              in_file = fs_filename( 'mat', this_model, 'unrotated', [] );
              in_file = [component_directory in_file];
              if ( exist( in_file, 'file' ) )

                str = sprintf( 'Rotating %d components from %s',nd, this_model );
                print_title( str, log_fid );

                if ( isa( handles.progressBar, 'cpca_progress' ) )
                  handles.progressBar.setProcess( str );
                end 
                % ----------------------------------
                % --- multiple rotations ---
                % ----------------------------------
                for idx = 1:size(scan_information.processing.H_model.rotation, 1)

                  this_rotation = scan_information.processing.H_model.rotation(idx);
                  this_rotation.model = 'H';
                  this_rotation.fs = 'rotated';
                  this_rotation.htype = this_model;
                  this_rotation.mode = this_model;
                
                  image_path = fs_path( 'rotated', 'images', nd, 0, this_rotation  );

                  str = [ '--- ' scan_information.processing.H_model.rotation(idx).method ];
                  if ( scan_information.processing.H_model.rotation(idx).defaults.oblique )  str = [ str ' oblique' ];  else str = [ str ' orthogonal' ];   end
                  str = [ str ' iter: ' num2str(scan_information.processing.H_model.rotation(idx).defaults.iterations) ];
                  nm = sprintf( '%.2f', scan_information.processing.H_model.rotation(idx).defaults.power );
                  str = [ str ' power: ' nm ];
                  nm = sprintf( '%.2f', scan_information.processing.H_model.rotation(idx).defaults.gamma );
                  str = [ str ' gamma: ' nm ' ---' ];
                  fnm = fs_filename( 'mat', this_model, this_rotation.method, this_rotation.defaults );
                  str2 = sprintf( '%s\n--- %s ---', str, fnm );
                  print_title( str2, log_fid );

                  ab = rotate_h_components( handles.funcs, in_file, this_rotation, nd, log_fid, 1 );
                  clear rotate_h_components

                  if ( ~isempty( handles.funcs.clear_cache ) )  handles.funcs.clear_cache(); handles.funcs.memory_stats(); end

                  if ( ab == 0 )
                    if ( isa( handles.progressBar, 'cpca_progress' ) )
                      handles.progressBar.hide();
                    end
                    return;
                  end

                  rstyle = '';
                  rs = '';
                  if ( scan_information.processing.H_model.rotation(idx).defaults.oblique )
                    rstyle = '_oblique';
                  else
                    rstyle = '_orthogonal';
                  end
                  rs = rstyle(2:end);

                  dt = date;
                  rot = ['Rotate ' num2str(nd) ' components' ];
                  meth = ['Method: ' scan_information.processing.H_model.rotation(idx).method ' ' rs ];
                  src = [ ' from: ' pwd '/' in_file ];

                  ofn = fs_filename( 'mat', this_rotation.model, this_rotation.method, this_rotation.defaults );
                  out_file = ['Store: ' component_directory ofn '.mat' ];

                  img_dir = '';
                  images_done = '';


                  % -----------------------------------------------------------
                  % Create images for rotated solution
                  % -----------------------------------------------------------
                  component_directory = fs_path( 'rotated', 'output', nd, 0, this_rotation );

                  mat_file = fs_filename( 'mat', this_rotation.htype, this_rotation.method, this_rotation.defaults );
                  mat_file = [component_directory mat_file];

                  if ( exist( mat_file, 'file' ) )

                    if ( isa( handles.progressBar, 'cpca_progress' ) )
                      handles.progressBar.setIterations( nd * max(scan_information.frequencies, 1), handles.progressBar.PRIMARY );
                    end 

                    h_images_rotated( this_rotation, nd, log_fid, 1 );
                    clear h_images_rotated


                    load_file = fs_filename( 'loadings', 'H', scan_information.processing.H_model.rotation(idx).method, scan_information.processing.H_model.rotation(idx).defaults );
                    image_dir = fs_path( 'rotated', 'images', nd, 0, this_rotation  );

                    input_file = [image_dir load_file ];


                    if ~scan_information.isMulFreq	% --- bypass cluster data on meg data for now
                      if ( exist( input_file, 'file' ) )
                        load( Zheader.Model.path, 'Gheader');
                        write_c_betas_clusters( this_rotation, Gheader, nd )
                      end
                    end

                    dt = date;
                    img_dir = [ Zheader.Z_Directory 'Component_Images' ];
                    images_done = 'Images created for rotated components';

                  end

                  write_log( dt, rot, meth, src, out_file, images_done, img_dir );

                end  % --- each rotation index ---

                update_process_buttons( handles );
                drawnow();

              end  % --- non rotated input file exists ---
            end  % --- valid number of components ---

          end  % --- each component index ---

        end  % -- HE/HZ

      end  % -- HE/HZ selection -- 

      timers.ExtractH.end_time = clock;
      timers.ExtractH.duration = toc;
      display_timer( timers.ExtractH, 'H Rotation' );
      
      scan_information.processing.H_model.rotate = 0;
      save_headers();

      update_process_buttons( handles );
      drawnow();
   
    end   % --- rotate components 

    scan_information.processing.H_model.applied.apply_hz = 0;
    scan_information.processing.H_model.applied.apply_he = 0;

    scan_information.processing.H_model.apply = 0;
    scan_information.processing.H_model.extract = 0;
    scan_information.processing.H_model.rotate = 0;

    scan_information.processing.H_model.process.hz = 0;
    scan_information.processing.H_model.process.he = 0;

    update_process_buttons( handles );
    drawnow();

    b = findobj( 'Tag', 'btn_run_h_process' );
    set( b, 'Value', 0 );
    set( b, 'BackgroundColor', constant_define( 'COLOR_GREY' ) );
    drawnow();

  end  % gzh process


  % ----------------------------------------
  % Apply GMH regression(s) 
  % ----------------------------------------
  if scan_information.processing.GMH_model.options.GMH.apply || ...
     scan_information.processing.GMH_model.options.GC.apply || ... 
     scan_information.processing.GMH_model.options.BH.apply;

    scan_information.processing.GMH_model.applied.started = max( 1, scan_information.processing.GMH_model.applied.started );
    scan_information.processing.GMH_model.applied.completed = 0;

    b = findobj( 'Tag', 'btn_run_gmh_process' );
    set( b, 'BackgroundColor', constant_define( 'COLOR_YELLOW' ) );
    drawnow();

    condition = [' No'; 'Yes'];

    tic;
    timers.ApplyGMH.start_time = clock;

    if ( isa( handles.progressBar, 'cpca_progress' ) )
      handles.progressBar.setProcess( 'GMH Processing');
    end

    load( Zheader.Model.path, 'Gheader');

    SoS =  apply_GMH( handles.funcs, Gheader, handles.progressBar );

    if ( SoS == 0 )
      if ( strcmp( class(progress.pb), 'cpca_progress' ) )
        handles.progressBar.hide();
      end
      set( b, 'Value', 0 );
      set( b, 'BackgroundColor', constant_define( 'COLOR_GREY' ) );
      return;
    end

    scan_information.processing.GMH_model.options.GMH.regress = 0;
    scan_information.processing.GMH_model.options.GMH.write = 0;
    scan_information.processing.GMH_model.options.BH.regress = 0;
    scan_information.processing.GMH_model.options.BH.write = 0;
    scan_information.processing.GMH_model.options.GC.regress = 0;
    scan_information.processing.GMH_model.options.GC.write = 0;
    save_headers();

    dt = date;
    write_log( dt, ['Apply GMH (' Zheader.Model.path ')'], [Zheader.Z_Directory 'ZInfo'], Gheader.GZheader.path_to_segs );
  
    h = findobj('Tag', 'chk_apply_gmh');
    set(h, 'Value',scan_information.processing.GMH_model.options.GMH.regress );

    update_process_buttons( handles );
    drawnow();

  end  % --- GMH operation to apply


  if scan_information.processing.GMH_model.extract == 1

    scan_information.processing.GMH_model.applied.started = max( 1, scan_information.processing.GMH_model.applied.started );
    scan_information.processing.GMH_model.applied.completed = 0;

    if scan_information.processing.GMH_model.options.GMH.extract == 1 

      if ( isa( handles.progressBar, 'cpca_progress' ) )
        handles.progressBar.setProcess( 'GMH::GMH Extraction');
      end

      tic;
      timers.Extract_GMH.start_time = clock;

      if ( isa( handles.progressBar, 'cpca_progress' ) )
        handles.progressBar.setIterations( 6 * size(scan_information.processing.GMH_model.options.GMH.components, 2) + ...
          sum( scan_information.processing.GMH_model.options.GMH.components ) * ... 
          max(scan_information.frequencies, 1), handles.progressBar.PRIMARY );
      end

      for ( comp_idx = 1:size(scan_information.processing.GMH_model.options.GMH.components, 2) )

        nd = scan_information.processing.GMH_model.options.GMH.components(comp_idx);
        if nd > 0 
          str = sprintf( 'Extracting %d components', nd );
          print_title( str, log_fid );

          set( handles.NumComp_GMH, 'String', ['GMH: ' num2str(nd)] );

          if ( isa( handles.progressBar, 'cpca_progress' ) )
            handles.progressBar.setMessage( str );
          end

          abort_process = extract_gmh_components(handles.funcs, nd, handles.progressBar );
          clear extract_gmh_components

          if ( abort_process )
            if ( isa( handles.progressBar, 'cpca_progress' ) )
              handles.progressBar.hide();
            end
            set( b, 'Value', 0 );
            set( b, 'BackgroundColor', constant_define( 'COLOR_GREY' ) );
            return;
          end

          scan_information.processing.GMH_model.options.GMH.extract = 0;

          % -----------------------------------------------------------
          % Create images for non rotated solution
          % -----------------------------------------------------------
          load( Zheader.Limits.path );
          
          [H_ID H_Segments] = H_path_spec( Hheader, 'GMH' );
          noParms = struct( 'model', 'H', 'mode', 'GMH', 'hindex',  H_ID );
          component_directory = fs_path( 'unrotated', 'output', nd, 0, noParms );

          in_file = fs_filename( 'mat', 'GMH', 'unrotated', noParms );

          in_file = [component_directory in_file];
          x=exist( in_file );
          if x == 2   % the file exists

            if ( isa( handles.progressBar, 'cpca_progress' ) )
              handles.progressBar.setMessage( 'Creating images' );
            end

            gmh_images_unrotated( nd, log_fid, 'GMH', 1 );
            clear gmh_images_unrotated

          end

          update_process_buttons( handles );
          drawnow();

        end ; % --- valid number of components ---
      end ; % --- each entered component value ---

      timers.Extract_GMH.end_time = clock;
      timers.Extract_GMH.duration = toc;
      display_timer( timers.Extract_GMH, 'Extract GMH');

      save_headers();

      scan_information.processing.GMH_model.options.GMH.extract = 0;
      scan_information.processing.GMH_model.options.BH.extract = 0;
      scan_information.processing.GMH_model.options.GC.extract = 0;

      update_process_buttons( handles );
      drawnow();

    end  % --- GMH extraction

 
    if scan_information.processing.GMH_model.options.BH.extract == 1 

      if ( isa( handles.progressBar, 'cpca_progress' ) )
        handles.progressBar.setProcess( 'GMH::GnotH Process' );
      end

      tic;
      timers.Extract_GMH.start_time = clock;

      for ( comp_idx = 1:size(scan_information.processing.GMH_model.options.BH.components, 2) )

        nd = scan_information.processing.GMH_model.options.BH.components(comp_idx);
        if nd > 0 
          str = sprintf( 'Extracting %d components from GMH:GnotH', nd );
          print_title( str, log_fid );

          set( handles.NumComp_GMH, 'String', ['GnotH: ' num2str(nd)] );

          if ( isa( handles.progressBar, 'cpca_progress' ) )
            handles.progressBar.setMessage( ['Extracting ' num2str(nd) ' components'] );
          end

          abort_process = extract_gmh_bh_components(handles.funcs, nd, handles.progressBar );
          clear extract_gmh_components

          if ( abort_process )
            if ( isa( handles.progressBar, 'cpca_progress' ) )
              handles.progressBar.hide();
            end
            set( b, 'Value', 0 );
            set( b, 'BackgroundColor', constant_define( 'COLOR_GREY' ) );
            return;
          end

          scan_information.processing.GMH_model.options.BH.extract = 0;

          % -----------------------------------------------------------
          % Create images for non rotated solution
          % -----------------------------------------------------------
          load( Zheader.Limits.path );
          
          [H_ID H_Segments] = H_path_spec( Hheader, 'GMH' );
          noParms = struct( 'model', 'H', 'mode', 'GMH', 'htype', 'HnotG', 'hindex',  H_ID );
          component_directory = fs_path( 'unrotated', 'output', nd, 0, noParms );

          in_file = fs_filename( 'mat', 'HnotG', 'unrotated', noParms );
          x=exist( [component_directory in_file] );
          if x == 2   % the file exists

            if ( isa( handles.progressBar, 'cpca_progress' ) )
              handles.progressBar.setMessage( 'Creating  images' );
              handles.progressBar.setIterations( nd * max( scan_information.frequencies, 1), handles.progressBar.PRIMARY );
            end

            gmh_images_unrotated( nd, log_fid, 'HnotG', 1 );
            clear gmh_images_unrotated

          end

          update_process_buttons( handles );
          drawnow();

        end ; % --- valid number of components ---
      end ; % --- each entered component value ---

      timers.Extract_GMH.end_time = clock;
      timers.Extract_GMH.duration = toc;
      display_timer( timers.Extract_GMH, 'Extract GMH');

      save_headers();

      update_process_buttons( handles );
      drawnow();

    end  % --- GMH:BH extraction


    if scan_information.processing.GMH_model.options.GC.extract == 1 || scan_information.processing.GMH_model.subject_specific == 1 

      scan_information.processing.GMH_model.applied.started = max( 1, scan_information.processing.GMH_model.applied.started );
      scan_information.processing.GMH_model.applied.completed = 0;

      tic;
      timers.Extract_GC.start_time = clock;

      for ( comp_idx = 1:size(scan_information.processing.GMH_model.options.GC.components, 2) )

        nd = scan_information.processing.GMH_model.options.GC.components(comp_idx);
        if nd > 0 
          str = sprintf( 'Extracting %d components from GC', nd );
          print_title( str, log_fid );

          set( handles.NumComp_GMH, 'String', ['GC: ' num2str(nd)] );

          if ( isa( handles.progressBar, 'cpca_progress' ) )
            handles.progressBar.setProcess( ['Extracting ' num2str(nd) ' components'] );
            handles.progressBar.setIterations( 100, handles.progressBar.PRIMARY);
          end

          if scan_information.processing.GMH_model.options.GC.extract == 1 
            abort_process = extract_gmh_gc_components(handles.funcs, nd, handles.progressBar );
            clear extract_gmh_gc_components

            if ( abort_process )
              if ( isa( handles.progressBar, 'cpca_progress' ) )
                handles.progressBar.hide();
              end
              set( b, 'Value', 0 );
              set( b, 'BackgroundColor', constant_define( 'COLOR_GREY' ) );
              return;
            end

            scan_information.processing.GMH_model.options.GC.extract = 0;

            % -----------------------------------------------------------
            % Create images for non rotated solution
            % -----------------------------------------------------------
            load( Zheader.Limits.path);
            [H_ID H_Segments] = H_path_spec( Hheader, 'GMH' );
            noParms = struct( 'model', 'H', 'mode', 'GMH', 'hindex',  H_ID );
            component_directory = fs_path( 'unrotated', 'output', nd, 0, noParms );

            in_file = fs_filename( 'mat', 'GnotH', 'unrotated', noParms );
            x=exist( [component_directory in_file] );
            if x == 2   % the file exists

            if ( isa( handles.progressBar, 'cpca_progress' ) )
              handles.progressBar.setMessage( 'Creating  images' );
              handles.progressBar.setIterations( nd * max( scan_information.frequencies, 1), handles.progressBar.PRIMARY );
            end

              gmh_images_unrotated( nd, log_fid, 'GnotH', handles.progressBar );
              clear gmh_images_unrotated

            end

          end

          if ( scan_information.processing.GMH_model.subject_specific == 1 )

            extract_gmh_gc_subject_components( handles.funcs, nd, log_fid, 1 );
            clear extract_gmh_gc_subject_components

            gmh_gc_images_unrotated_alt_vr( nd, log_fid, 1 );

          end  

          update_process_buttons( handles );
          drawnow();

        end ; % --- valid number of components ---
      end ; % --- each entered component value ---

      timers.Extract_GC.end_time = clock;
      timers.Extract_GC.duration = toc;
      display_timer( timers.Extract_GC, 'Extract GMH:GC');

      save_headers();

      update_process_buttons( handles );
      drawnow();

    end  % --- GC extraction


    scan_information.processing.GMH_model.extract = 0;
    scan_information.processing.GMH_model.subject_specific = 0;
    save_headers();

    set( handles.NumComp_GMH, 'String', '' );

    update_process_buttons( handles );
    drawnow();

  end  % --- GMH GC and/or BH extraction

  % -----------------------------------------------------------
  % rotate extracted components from GMH
  % -----------------------------------------------------------
  if scan_information.processing.GMH_model.rotate == 1 || scan_information.processing.GMH_model.subject_specific_rotated == 1

    scan_information.processing.GMH_model.applied.started = max( 1, scan_information.processing.GMH_model.applied.started );
    scan_information.processing.GMH_model.applied.completed = 0;

    tic
    timers.RotateH.start_time = clock;
    this_model = 'GMH';

    b = findobj( 'Tag', 'btn_run_gmh_process' );
    set( b, 'BackgroundColor', constant_define( 'COLOR_YELLOW' ) );
    drawnow();

    if scan_information.processing.GMH_model.options.GMH.rotate == 1 
      rotate_gmh_components( handles.funcs, scan_information.processing.GMH_model.options.GMH, 'GMH', log_fid, handles.progressBar );
      scan_information.processing.GMH_model.options.GMH.rotate = 0;
      save_headers();
    end

    if scan_information.processing.GMH_model.options.BH.rotate == 1 
      rotate_gmh_components( handles.funcs, scan_information.processing.GMH_model.options.BH, 'BH', log_fid, handles.progressBar );
      scan_information.processing.GMH_model.options.BH.rotate = 0;
      save_headers();
    end

    if scan_information.processing.GMH_model.options.GC.rotate == 1 
      rotate_gmh_components( handles.funcs, scan_information.processing.GMH_model.options.GC, 'GnotH', log_fid, handles.progressBar  );
      scan_information.processing.GMH_model.options.GC.rotate = 0;
      save_headers();
    end

    if scan_information.processing.GMH_model.subject_specific_rotated == 1 

      % ----------------------------------
      % --- multiple rotations ---
      % ----------------------------------
      for idx = 1:size(scan_information.processing.GMH_model.options.GC.rotation, 1)

        this_rotation = scan_information.processing.GMH_model.options.GC.rotation(idx);
        this_rotation.model = 'H';
        this_rotation.fs = 'rotated';
        this_rotation.htype = 'GC';
        this_rotation.mode = 'GMH';

        nd = scan_information.processing.GMH_model.options.GC.components;
        rotate_gmh_gc_subject_components( handles.funcs, this_rotation, nd, log_fid, 1);

        gmh_gc_images_rotated_alt_vr( this_rotation, nd, log_fid, 1 );

      end


    end

    timers.RotateH.end_time = clock;
    timers.RotateH.duration = toc;
    display_timer( timers.RotateH, 'GMH Rotation' );
      
    save_headers();
    drawnow();

    scan_information.processing.GMH_model.options.GC.rotate = 0;
    scan_information.processing.GMH_model.subject_specific_rotated = 0;
    save_headers();

    update_process_buttons( handles );
   
  end   % --- rotate components 

  scan_information.processing.GMH_model.options.GMH.apply = 0;
  scan_information.processing.GMH_model.options.BH.apply = 0;
  scan_information.processing.GMH_model.options.GC.apply = 0;
  
  scan_information.processing.GMH_model.applied.started = 0;
  scan_information.processing.GMH_model.apply = 0;
  scan_information.processing.GMH_model.extract = 0;
  scan_information.processing.GMH_model.rotate = 0;
  scan_information.processing.GMH_model.subject_specific = 0;
  scan_information.processing.GMH_model.subject_specific_rotated = 0;
  if ( scan_information.processing.GMH_model.applied.started )
    scan_information.processing.GMH_model.applied.completed = 1;
    scan_information.processing.GMH_model.applied.resume = 0;
  end   
  
  scan_information.processing.GMH_model.options.vars.ZH = 0;
  scan_information.processing.GMH_model.options.vars.Qg = 0;
  scan_information.processing.GMH_model.options.vars.Qh = 0;
  scan_information.processing.GMH_model.options.ow_flag = 0;
  scan_information.processing.GMH_model.options.overwrite = 0;
  
  save_headers();

  b = findobj( 'Tag', 'btn_run_gmh_process' );
  set( b, 'Value', 0 );
  set( b, 'BackgroundColor', constant_define( 'COLOR_GREY' ) );
  drawnow();


  if size(process_information.sudo.user, 2) > 0 && process_information.sudo.confirmed == 1
    cmd = ['!chown -R ' process_information.sudo.user '.' process_information.sudo.group ' *' ];
    eval( cmd );
  end


  handles.processingData == 0;

  if ( isa( handles.progressBar, 'cpca_progress' ) )
    handles.progressBar.hide();
  end

  timers.Overall.end_time = clock;
  timers.Overall.duration = etime(timers.Overall.end_time, timers.Overall.start_time );

  titleMe = 1;
  if ( timers.Normalize.duration > 0 ) display_timer( timers.Normalize, 'Normalization', titleMe );  titleMe = 0; end
  if ( timers.ApplyG.duration > 0 ) display_timer( timers.ApplyG, 'Apply G', titleMe );  titleMe = 0; end
  if ( timers.ExtractG.duration > 0 ) display_timer( timers.ExtractG, 'Extract G' );  titleMe = 0; end
  if ( timers.ApplyGA.duration > 0 ) display_timer( timers.ApplyGA, 'Apply GA', titleMe );  titleMe = 0; end
  if ( timers.ExtractGA.duration > 0 ) display_timer( timers.ExtractGA, 'Extract GA' );  titleMe = 0; end
  if ( timers.ApplyGAA.duration > 0 ) display_timer( timers.ApplyGAA, 'Apply G Not A', titleMe );  titleMe = 0; end
  if ( timers.ApplyH.duration > 0 ) display_timer( timers.ApplyH, 'Apply H', titleMe );  titleMe = 0; end
  if ( timers.ApplyPD.duration > 0 ) display_timer( timers.ApplyPD, 'Apply P/D', titleMe );  titleMe = 0; end

  display_timer( timers.Overall, 'Elapsed', 0, 1, log_fid );

  if ( log_fid)
    fclose( log_fid);
  end

  fclose('all');

  if size(process_information.sudo.user, 2) > 0 && process_information.sudo.confirmed == 1
    cmd = ['!chown -R ' process_information.sudo.user '.' process_information.sudo.group ' *' ];
    eval( cmd );
  end
  

  %% --- process_subject_normalization  ()
  %  --- -----------------------------------
  function process_subject_normalization()

    tic
    timers.Normalize.start_time = clock;

    estimated_time = Zheader.total_scans * scan_information.image_read_average;
    estimated_time = estimated_time + (Zheader.total_scans / scan_information.normalize_average);
    estimated_time = estimated_time + (Zheader.total_scans / scan_information.save_average);
    str = format_toc( estimated_time, 'Estimated Completion Time: ' );
    print_and_log( log_fid, '%s\n', str );

    condition = [' No'; 'Yes'];

    b = findobj( 'Tag', 'btn_run_subject_process' );
    set( b, 'BackgroundColor', constant_define( 'COLOR_YELLOW' ) );
    drawnow();

    if scan_information.processing.subjects.process.create_Z == 1 || scan_information.processing.subjects.process.extract_clusters == 1

      if ( Zheader.cluster_data )
        Txt = 'Extracting Clusters from Voxel Data';
        Sts = 'Extracting Clusters';
      else
        Txt = 'Creating Z matrix from scan images';
      end
      
      if ( isa( handles.progressBar, 'cpca_progress' ) )
        handles.progressBar.setProcess( Txt );
      end

      start_subj = 1;
      if ( scan_information.processing.subjects.process.resume )
        start_subj = start_subj + scan_information.processing.subjects.process.last_subject;
      else
        if ( Zheader.cluster_data == 0 )
          Zheader.tsum = 0;
          Zheader.tsum_with_trends = 0;
          Zheader.tsum_trends = 0;
          Zheader.tsum_linear_trends = 0;
          Zheader.tsum_quadratic_trends = 0;
          Zheader.tsum_hm_trends = 0;
          Zheader.tsum_user_trends = 0;
          Zheader.tsum_E = 0;
        end
        Zheader.tsum_clusters = 0;

      end

      if ( start_subj <= Zheader.num_subjects )     % allow for single subjects

        perform_covariant_regression = ( scan_information.processing.subjects.process.movement_regress + ...
            scan_information.processing.subjects.process.linear_regress + ...
            scan_information.processing.subjects.process.quadratic_regress ) * ... 
            scan_information.processing.subjects.process.apply_regression;


        if ( isa( handles.progressBar, 'cpca_progress' ) )
          iters = iteration_rule( 'Iterations', 'Subject Normalization', {'primary'}, ...
                 struct( 'covar', perform_covariant_regression > 0 ) );

          handles.progressBar.setProcess( 'Normalizing Subject Data' );
          handles.progressBar.setIterations( iters.primary, handles.progressBar.PRIMARY );

        end

        for SubjectNo=start_subj:scan_information.NumSubjects

          SSQ.sd = 0;                                           % --- total Z sum diagonal
          SSQ.Rsd = zeros( 1, 5 );                              % --- total Z sum diagonal by Registered area
          SSQ.Fsd = zeros( 1, max(1, Zheader.num_Z_arrays) );   % --- total Z sum diagonal by frequency
          SSQ.Subject = struct( ...
              'sd', zeros(Zheader.num_runs, 1 ), ...
              'Fsd', zeros( Zheader.num_runs, max(1, Zheader.num_Z_arrays) ) ); 

          for FrequencyNo = 1:Zheader.num_Z_arrays

            if ( Zheader.cluster_data )
              ab = extract_clusters( SubjectNo, log_fid, 1 );
              clear extract_clusters
            else

              SS = normalize_subject( handles.funcs, SubjectNo, FrequencyNo, log_fid, handles.progressBar );
              clear normalize_subject
              update_process_buttons( handles );
              
              if ~isempty( SS )
                ab = 0;
                SSQ.sd = SSQ.sd + SS.sd;
                SSQ.Rsd = SSQ.Rsd + SS.Rsd;
                SSQ.Fsd(FrequencyNo) = SSQ.Fsd(FrequencyNo) + SS.sd;
                SSQ.Subject.sd = SSQ.Subject.sd + SS.Subject.sd;
                SSQ.Subject.Fsd = SSQ.Subject.Fsd + SS.Subject.Fsd; 
              else
                ab = 1;
              end;
            end

            if ( ab )
              if ( isa( handles.progressBar, 'cpca_progress' ) )
                handles.progressBar.hide();
              end
              return;
            end
 
            Zheader.partitions.partitioned = 1;
            update_process_buttons( handles );
            drawnow();

          end  % --- each frequency
          
          Zvars = ['Z' filesep 'Z' num2str(SubjectNo) '_vars.mat'];
          save( Zvars, 'SSQ', '-v7.3', '-append' );

        end % --- each subject

        Z_SD_Report();
        SSQ = accumulate_Z_SSQ();
        Zheader.tsum = SSQ.sd;
        Zheader.rsum = SSQ.Rsd;
        Zheader.rfac = calc_regression_stats();
        Zheader.tsum_linear_trends = Zheader.tsum * ( Zheader.rfac(1) /100 );
        Zheader.tsum_quadratic_trends = Zheader.tsum * ( Zheader.rfac(2) /100 );
        Zheader.tsum_hm_trends = Zheader.tsum * ( Zheader.rfac(3) /100 );
        Zheader.tsum_user_trends = Zheader.tsum * ( Zheader.rfac(4) /100 );
        if( isnan(Zheader.tsum)) 
                disp('WARNING: Z matrix has corrupted values, check masks for proper output');
        end
        if ~isempty( Zheader.Z_Original ) 
          Zheader.Z_Original = ''; 
        end

        % --- preserve an unambiguous copy of the mask
        here = scan_information.mask.file;
        isNII = strfind( lower(here), '.nii') > 0 ;
        if isNII
          there = [pwd filesep 'mask_used.nii'];
          if ~strcmp( here, there )
            copyfile( here, there, 'f' );
          end
        else
          there = [pwd filesep 'mask_used.img'];
          if ~strcmp( here, there )
            copyfile( here, there, 'f' );
            here = strrep( here, '.img', '.hdr' );
            there = [pwd filesep 'mask_used.hdr'];
            copyfile( here, there, 'f' );
          end
        end
        
        update_process_buttons( handles );  

        if ( Zheader.tsum_trends > 0 )
          regressed_out = sum(Zheader.rfac);

          str = sprintf( ' %.2f%% regressed out', regressed_out );
          h = findobj( 'Tag', 'txt_pct_regressed' );
          set( h, 'String', str );
          set( h, 'Visible', 'on' );

        else
          h = findobj( 'Tag', 'txt_pct_regressed' );
          set( h, 'Visible', 'off' );

        end
      end

    end

    dt = date;
    str = sprintf( 'Subjects: %d  Runs: %d ',  Zheader.num_subjects, Zheader.num_runs );
    nrm = sprintf( 'Normalize raw subject data from %s ',  scan_information.BaseDir );
    nrm2 = sprintf( 'Normalized Z matrices stored at %s ',  Zheader.Z_Directory );
    write_log( dt, nrm, nrm2, str );

    if scan_information.processing.subjects.process.create_ZZ == 1 

      Zheader.ZZ = ZZ_segmentation( Zheader.total_scans, Zheader.total_columns );
      create_ZZ( 1 );

    end

    scan_information.processing.subjects.apply = 0;  		% flag no longer needing to scan the subjects
    scan_information.processing.subjects.normalized = date;  	
    scan_information.processing.subjects.process.apply_regression = 0;
    scan_information.processing.subjects.process.linear_regress = 0;
    scan_information.processing.subjects.process.quadratic_regress = 0;
    scan_information.processing.subjects.process.movement_regress = 0;
    scan_information.processing.subjects.process.mean_center = 0;
    scan_information.processing.subjects.process.standardize = 0;
    scan_information.processing.subjects.process.create_ZZ = 0;
    scan_information.processing.subjects.process.extract_clusters = 0;
    scan_information.processing.subjects.process.create_Z = 0;

    save_headers();

    timers.Normalize.end_time = clock;
    timers.Normalize.duration = etime(timers.Normalize.end_time, timers.Normalize.start_time );
    update_process_buttons( handles );  

    set( b, 'Value', 0 );
    set( b, 'BackgroundColor', constant_define( 'COLOR_GREY' ) );
    drawnow();
        
  end  % --- end nested function --- subject normalization


  %% --- regress_G ()
  %  --- -----------------------------------
  function regress_G()
      
      tic;
      timers.ApplyG.start_time = clock;

      if ( isa( handles.progressBar, 'cpca_progress' ) )
        if strcmp( model, 'GAA' )
          handles.progressBar.setMessages( 'Regressing GnotA'' * Z . . .', '', '' );
        else
          handles.progressBar.setMessages( ['Regressing ' model ''' * Z . . .'], '', '' );
        end
        large = constant_define( 'PREFERENCES', 'general.large_variable_creation' );
        
        iters = iteration_rule( 'Iterations', 'G Regression', {'primary'} );
        handles.progressBar.setIterations( iters.primary, handles.progressBar.PRIMARY );

      end

      if isROI
        nvox = str2num(get( handles.txt_GROI_num_voxels, 'String' ));
        SoS =  apply_ROI_to_Z( handles.funcs, nvox, model, log_fid, handles.progressBar );
        clear apply_ROI_to_Z
        
        G_ROI.mask( G_ROI.Rindex).tsum_ZTrim = SoS;

      else
        SoS =  apply_partitioned_to_Z( handles.funcs, Gheader, log_fid, handles.progressBar, large);
        clear apply_partitioned_to_Z
      end;
      

      if ( SoS == 0 )
        if ( isa( handles.progressBar, 'cpca_progress' ) )
          handles.progressBar.hide();
        end
        return;
      end

      if ( isa( handles.progressBar, 'cpca_progress' ) )
        handles.progressBar.setMessage( '' );
        handles.progressBar.setComment( '' );
      end

      if size(process_information.sudo.user, 2) > 0 && process_information.sudo.confirmed == 1
        cmd = ['!chown -R ' process_information.sudo.user '.' process_information.sudo.group ' *' ];
        eval( cmd );
      end;

      timers.ApplyG.end_time = clock;
      timers.ApplyG.duration = toc;
      display_timer( timers.ApplyG, 'Apply G');

  end  % --- end nested function --- G Regression


  %% --- Accumulate_Z_SSQ ()
  %  --- -----------------------------------
  function ts = accumulate_Z_SSQ()
      
    ts = 0;
    A = [];
    SSQ = struct( 'sd', 0, ...                                          % --- total Z sum diagonal
                  'Rsd', zeros( 1, 5 ), ...                             % --- total Z sum diagonal by registration
                  'Fsd', zeros( 1, max(1, Zheader.num_Z_arrays) ), ...   % --- total Z sum diagonal by frequency
                  'Subject', struct( ...
                    'sd', zeros(Zheader.num_runs, 1 ), ...                             
                    'Fsd', zeros( Zheader.num_runs, max(1, Zheader.num_Z_arrays) ) ) );   

    for SubjectNo=1:Zheader.num_subjects
      A = load_subject_Z_var( SubjectNo, 'SSQ');
      
      if ~isempty(A)
        SSQ.sd =  SSQ.sd + A.sd;
        SSQ.Fsd =  SSQ.Fsd + A.Fsd;
        SSQ.Rsd =  SSQ.Rsd + A.Rsd;

        SSQ.Subject.sd =  SSQ.Subject.sd + A.Subject.sd;
        SSQ.Subject.Fsd =  SSQ.Subject.Fsd + A.Subject.Fsd;

      end % -- variable loaded

    end % each subject

    Zvars =  ['Z' filesep 'Z_vars'];
    initialize_non_existing_file( Zvars );
    save( Zvars, 'SSQ', '-v7.3', '-append' );
  
    ts = SSQ;
    
  end  % --- end nested function --- accumulate_Z_SSQ
    

  %% --- extract_components_of_G ()
  %  --- -----------------------------------
  function extract_components_of_G()

    Aheader = [];
   
    pth_add = '';
    
    noParms = struct( 'model', 'G');
    
    if isROI 
      model = 'ROI';

      pth_add = load( 'G_ROI' );
      G_ROI = pth_add.G_ROI;
      noParms.hindex = strrep( [ filesep 'ROI' filesep G_ROI.mask( G_ROI.Rindex).id ], ' ', '_' );
      noParms.model = 'G';
      
      ftext = [ 'ROI: ' G_ROI.mask( G_ROI.Rindex).id ];
        
    else
        
      model = 'G';
      if isChecked( handles.chk_apply_ga )
        model = 'GA';
      end;
      ftext = model;

      if isChecked( handles.chk_apply_gaa )
        model = 'GAA';
        ftext = 'GnotA';
      end;
      
      if ~strcmp( model, 'G' )
        % --- for some odd reason a direct load of Zheader.Contrast.path
        % --- errors on trying to add Aheader to static space even though it
        % --- is defined, but indirect loading works fine - ??????
        pth_add = load( Zheader.Contrast.path );
        Aheader = pth_add.Aheader;
        if Aheader.Aindex > 1
          noParms.hindex = strrep( [ filesep Aheader.model( Aheader.Aindex).id ], ' ', '_' );
        end
      end
    end
    
   
    component_directory = fs_path( 'unrotated', 'output', nd, 0, noParms );
    component_directory = [pwd filesep component_directory];
    image_path = fs_path( 'unrotated', 'images', nd, 0, noParms );
    image_path = [pwd filesep image_path];
       
    msg = sprintf( 'Extract %s: %d components ', ftext, nd);

    nvox = 0;
    if isROI
      nvox = str2num(get( handles.txt_GROI_num_voxels, 'String' ));
    end

    nreg = [1 0 0];  % --- non registered default to whole brain only
    if scan_information.mask.isRegistered
      nreg(1) = constant_define( 'PREFERENCES', 'general.whole_brain' );
      nreg(2) = constant_define( 'PREFERENCES', 'general.gray_matter' );
      nreg(3) = constant_define( 'PREFERENCES', 'general.white_matter' );
    end
       
    for ii = 1:3
           
      WG = ii - 1;
      if nreg(ii)
        
        print_title( msg, log_fid );
        if isa( handles.progressBar, 'cpca_progress' )
          handles.progressBar.setProcess( [msg constant_define( 'REGISTRATION_FULL', WG)] );
        end
       
        if scan_information.processing.model.process.extract_g == 1 
          abort_process = extract_g_components(handles.funcs, nd, log_fid, handles.progressBar, model, nvox, WG );
          clear extract_g_components
    
          if ( abort_process )
            if isa( handles.progressBar, 'cpca_progress' )
              handles.progressBar.hide();
            end
            return;
          end
        
          g_images_unrotated( nd, log_fid, handles.progressBar, model, WG );
          clear g_images_unrotated
        
          if ~isMultiFrequency() && strcmp( model, 'G' )

            rotation_params.method = 'unrotated';
            rotation_params.defaults = struct( 'empty', 1 );
            rotation_params.fs = 'unrotated';
            rotation_params.model = 'G';

            if ( isa( handles.progressBar, 'cpca_progress' ) )
              handles.progressBar.setMessage( 'Writing Cluster Information' );
            end

            if constant_define( 'PREFERENCES', 'cluster.create_masks', 1 )
              write_cluster_masks( [], nd, '', handles.progressBar );
            end
            if constant_define( 'PREFERENCES', 'cluster.calculate_mean' , 0 ) || ...
               constant_define( 'PREFERENCES', 'cluster.calculate_median' , 0 )
                 write_cluster_beta_mean_median( rotation_params, Gheader, nd, handles.progressBar, WG );
            end
          end

        end  
        
        if scan_information.processing.model.process.subject_specific == 1 && ...
          strcmp( model, 'G' )   % --- no subject rotation for GA/GFnotA presently

          extract_g_subject_components( handles.funcs,  nd, log_fid, handles.progressBar, WG );
          clear extract_g_subject_components
        end  
      end          
          
%    end

%       if constant_define( 'PREFERENCES', 'general.calculate_altPR' )
%         if ( isa( handles.progressBar, 'cpca_progress' ) )
%           handles.progressBar.setMessage( 'Calculating Alternate PR . . .' );
%         end
% %        calculate_alternate_PR( nd, struct( 'model', 'G' ), 1 );

    end


    if size(process_information.sudo.user, 2) > 0 && process_information.sudo.confirmed == 1
      cmd = ['!chown -R ' process_information.sudo.user '.' process_information.sudo.group ' *' ];
      eval( cmd );
    end


  end  % --- nested function - G component Extraction

  %% --- rotate_components_of_G ()
  function rotate_components_of_G ()

    Aheader = [];
    pth_add = '';
    
    model = 'G';
    if isChecked( handles.chk_apply_ga ),       model = 'GA';    end;
    ftext = model;

    if isChecked( handles.chk_apply_gaa )
      model = 'GAA';
      ftext = 'GnotA';
    end;
      
    msg = sprintf( 'Rotate: %s %d components', ftext, nd );

    rotation_params.Aindex = 0;
    noParms = struct( 'model', 'G', 'Aindex', 0 );
    if ~strcmp( model, 'G' )
      % --- for some odd reason a direct load of Zheader.Contrast.path
      % --- errors on trying to add Aheader to static space even though it
      % --- is defined, but indirect loading works fine - ??????
      pth_add = load( Zheader.Contrast.path );
      Aheader = pth_add.Aheader;
      rotation_params.Aindex = Aheader.Aindex;
      noParms.Aindex = Aheader.Aindex;
      if Aheader.Aindex > 1
        noParms.hindex = strrep( [ filesep Aheader.model( Aheader.Aindex).id ], ' ', '_' );
      end
    end
      
    component_directory = fs_path( 'unrotated', 'output', nd, 0, noParms );
    component_directory = [pwd filesep component_directory];

    % -----------------------------------------------------------
    % is there a processed .mat file for the non rotated solution
    % -----------------------------------------------------------
    in_file = fs_filename( 'mat', model, 'unrotated', noParms );
    in_file = [component_directory in_file];
    if exist( in_file, 'file' ) 

      % ----------------------------------
      % --- multiple rotations ---
      % ----------------------------------
      for idx = 1:size(scan_information.processing.model.rotation, 1)

        if isa( handles.progressBar, 'cpca_progress' ) 
          handles.progressBar.setProcess( [ scan_information.processing.model.rotation(idx).method ' Rotation ' num2str( nd ) ' components'] );
        end

        this_rotation = scan_information.processing.model.rotation(idx);
        this_rotation.model = 'G';
        this_rotation.fs = 'rotated';
        this_rotation.htype = model;
        this_rotation.mode = '';
        if isfield( noParms, 'hindex' )
          this_rotation.hindex = noParms.hindex ;   
        end
        this_rotation.Aindex = rotation_params.Aindex;
        

        str = [ '--- ' scan_information.processing.model.rotation(idx).method ];
        if ( scan_information.processing.model.rotation(idx).defaults.oblique )
           str = [ str ' oblique' ];  else str = [ str ' orthogonal' ];   
        end
        str = [ str ' iter: ' num2str(scan_information.processing.model.rotation(idx).defaults.iterations) ];
        nm = sprintf( '%.2f', scan_information.processing.model.rotation(idx).defaults.power );
        str = [ str ' power: ' nm ];
        nm = sprintf( '%.2f', scan_information.processing.model.rotation(idx).defaults.gamma );
        str = [ str ' gamma: ' nm ' ---' ];

        fnm = fs_filename( 'mat', model, this_rotation.method, this_rotation.defaults );
        Sub = sprintf( '%s\n--- %s ---', str, fnm );
        print_title( Sub, log_fid );


        nreg = [1 0 0];  % --- non registered default to whole brain only
        if scan_information.mask.isRegistered
          nreg(1) = constant_define( 'PREFERENCES', 'general.whole_brain' );
          nreg(2) = constant_define( 'PREFERENCES', 'general.gray_matter' );
          nreg(3) = constant_define( 'PREFERENCES', 'general.white_matter' );
        end
       
        for ii = 1:3
           
          WG = ii - 1;
          if nreg(ii)
            print_title( msg, log_fid );
            if isa( handles.progressBar, 'cpca_progress' )
              handles.progressBar.setProcess( msg );
            end
                
            if scan_information.processing.model.process.rotate_g == 1 
              ab = rotate_components( handles.funcs, this_rotation, nd, log_fid, handles.progressBar, model, WG );
              clear rotate_components

              if ab == 0 
                if isa( handles.progressBar, 'cpca_progress' ), handles.progressBar.hide();  end
                return;
              end
            
              g_images_rotated( this_rotation, nd, log_fid, handles.progressBar, model, WG );
              clear g_images_rotated

            end

          
            if size(process_information.sudo.user, 2) > 0 && process_information.sudo.confirmed == 1
              cmd = ['!chown -R ' process_information.sudo.user '.' process_information.sudo.group ' *' ];
              eval( cmd );
            end

            if constant_define( 'PREFERENCES', 'general.calculate_altPR' )
              if isa( handles.progressBar, 'cpca_progress' )
                handles.progressBar.setMessage( 'Calculating Alternate PR . . .');
              end
              calculate_alternate_PR( nd, this_rotation, 1 );
            end
          
            if ~isMultiFrequency() && strcmp( model, 'G' )

              if constant_define( 'PREFERENCES', 'cluster.create_masks' , 1 )
                write_cluster_masks( this_rotation, nd, this_rotation.htype, handles.progressBar );
              end
              if constant_define( 'PREFERENCES', 'cluster.calculate_mean' , 0 ) || ...
                constant_define( 'PREFERENCES', 'cluster.calculate_median' , 0 )
                  write_cluster_beta_mean_median( this_rotation, Gheader, nd, handles.progressBar );
              end

            end
          
            % --- rotating for subject MUST be done AFTER rotated image creation
            if scan_information.processing.model.process.subject_specific_rotated == 1 && ...
              strcmp( model, 'G' )   % --- no subject rotation for GA/GFnotA presently
              if ( scan_information.processing.model.process.subject_specific_rotated || this_rotation.defaults.subject_stats )
                rotate_subject_components( handles.funcs, this_rotation, nd, log_fid, handles.progressBar, WG);
                clear rotate_subject_components
              end  
            end

          
          end
        end
        
      end  % --- each rotation index ---

      update_process_buttons( handles );
      drawnow();

    end  % --- non rotated input file exists ---
  
  end  % ---- nested function - rotate_G_components ()

end
  

% ---------------------------------------------
% --- Subject Data Process Selections
% ---------------------------------------------

% --- Executes on button press in btn_run_subject_process.
function btn_run_subject_process_Callback(hObject, eventdata, handles)
% hObject    handle to btn_run_subject_process (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Zheader scan_information 
  scan_information.processing.subjects.apply = get(hObject,'Value');

  if ( scan_information.processing.subjects.apply == 0 )
    scan_information.processing.subjects.apply = scan_information.processing.subjects.process.create_Z || ...
                                               scan_information.processing.subjects.process.create_ZZ || ...
                                               scan_information.processing.subjects.process.extract_clusters;
  end

  if ( scan_information.processing.subjects.apply == 1 )
    state = 'on';
  else
    state = 'off';
  end

  if strcmp(state, 'on' )
    switch (scan_information.processing.subjects.apply)
      case 1  % toggle is down
         set( hObject, 'BackgroundColor', constant_define( 'COLOR_GREEN' ) );

      case 0   % toggle is up
         set( hObject, 'BackgroundColor', constant_define( 'COLOR_GREY' ) );
    end

  else
    set( hObject, 'BackgroundColor', constant_define( 'COLOR_GREY' ) );
  end

  scan_information.processing.subjects.process.create_Z = (Zheader.tsum_with_trends == 0 && Zheader.older_Z == 0 && strcmp(state, 'on' ) == 1) && ...
       Zheader.cluster_data == 0;

  h = findobj( 'Tag', 'chk_create_z' );
  i = findobj( 'Tag', 'btn_run_subject_process' );

  set(h, 'Enable', constant_define( 'STATE', scan_information.processing.subjects.apply ) );
  set(h, 'Value', scan_information.processing.subjects.process.create_Z | ...
                 scan_information.processing.subjects.process.extract_clusters );

  set_Z_process_substates( handles );

  h = findobj( 'Tag', 'chk_create_ZZ' );
  set(h, 'Enable',state);
% OVERRIDE until ready 
%set(h, 'Enable','off');

  if ( scan_information.processing.subjects.apply )
    b = findobj('Tag','btn_PerformCPCA');
    set(b, 'Enable', 'on' );
  end

  drawnow();
end



% --- Executes on button press in chk_create_z.
function chk_create_z_Callback(hObject, eventdata, handles)

global Zheader scan_information

  if ( Zheader.cluster_data )
    scan_information.processing.subjects.process.extract_clusters = get(hObject,'Value');
  else
    scan_information.processing.subjects.process.create_Z = get(hObject,'Value');
  end

  scan_information.processing.subjects.apply = scan_information.processing.subjects.process.create_Z || ...
                                               scan_information.processing.subjects.process.create_ZZ || ...
                                               scan_information.processing.subjects.process.extract_clusters;

  set_Z_process_substates( handles );
  drawnow();
end



% --- Executes on button press in chk_mean_center.
function chk_mean_center_Callback(hObject, eventdata, handles)

global scan_information
  scan_information.processing.subjects.process.mean_center = get(hObject,'Value');
end



% --- Executes on button press in chk_standardize.
function chk_standardize_Callback(hObject, eventdata, handles)

global scan_information
  scan_information.processing.subjects.process.standardize = get(hObject,'Value');
end



% --- Executes on button press in chk_apply_regression.
function chk_apply_regression_Callback(hObject, eventdata, handles)

global scan_information

  scan_information.processing.subjects.process.apply_regression = get(hObject,'Value');

  save_headers();

  set_Z_process_substates( handles );
  drawnow();
end



% --- Executes on button press in chk_movement_regress.
function chk_movement_regress_Callback(hObject, eventdata, handles)
% hObject    handle to chk_movement_regress (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global scan_information Zheader

  scan_information.processing.subjects.process.movement_regress = get(hObject,'Value');

  save_headers();

  set( hObject, 'Value', scan_information.processing.subjects.process.movement_regress );
  drawnow();
end



% --- Executes on button press in chk_linear_regress.
function chk_linear_regress_Callback(hObject, eventdata, handles)
% hObject    handle to chk_linear_regress (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global scan_information
  scan_information.processing.subjects.process.linear_regress = get(hObject,'Value');

  h = findobj( 'Tag', 'chk_quad_regress' );
  if ( scan_information.processing.subjects.process.linear_regress == 1 )
    set(h, 'Enable', 'on');
    set(h, 'Value', 1 );		
    scan_information.processing.subjects.process.quadratic_regress = 1;
  else
    set(h, 'Value', 0 );		
    set(h, 'Enable', 'off');		
    scan_information.processing.subjects.process.quadratic_regress = 0;
  end
end


% --- Executes on button press in chk_quad_regress.
function chk_quad_regress_Callback(hObject, eventdata, handles)
% hObject    handle to chk_quad_regress (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global scan_information
  scan_information.processing.subjects.process.quadratic_regress = get(hObject,'Value');
end



% --- Executes on button press in chk_create_ZZ.
function chk_create_ZZ_Callback(hObject, eventdata, handles)
% hObject    handle to chk_create_ZZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global scan_information
  scan_information.processing.subjects.process.create_ZZ = get(hObject,'Value');
end


% ---------------------------------------------
% --- G Process Selections
% ---------------------------------------------

% --- Executes on button press in btn_run_ga_process.
function btn_run_ga_process_Callback(hObject, eventdata, handles)
% hObject    handle to btn_run_ga_process (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Zheader scan_information 
  scan_information.processing.model.apply = get(hObject,'Value');

  if ( scan_information.processing.model.apply == 1 )
    state = 'on';
  else
    state = 'off';
  end

  if strcmp(state, 'on' )
    switch (scan_information.processing.model.apply)
      case 1  % toggle is down
         set( hObject, 'BackgroundColor', constant_define( 'COLOR_GREEN' ) );

      case 0   % toggle is up
         set( hObject, 'BackgroundColor', constant_define( 'COLOR_GREY' ) );
    end

  else
    set( hObject, 'BackgroundColor', constant_define( 'COLOR_GREY' ) );
  end


  if ( scan_information.processing.model.apply )
    b = findobj('Tag','btn_PerformCPCA');
    set(b, 'Enable', 'on' );
  end
  
  update_process_buttons( handles );
  drawnow();
end




% --- Executes on button press in chk_apply_G.
function chk_apply_G_Callback(hObject, eventdata, handles)
% hObject    handle to chk_apply_G (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global scan_information;
  scan_information.processing.model.process.apply_g = get(hObject,'Value');


  h = findobj('Tag','chk_resume_apply_g');
  i = findobj('Tag','lbl_G_applied');
  j = findobj('Tag','btn_regress_G_settings');

% --- btn_regress_G_settings

  if ( scan_information.processing.model.process.apply_g )
    if ( scan_information.processing.model.applied.resume_g.last_subject > 0 ) && ...
     ( scan_information.processing.model.applied.resume_g.CC == 0 || ...
       scan_information.processing.model.applied.resume_g.Eigs == 0 )
	% initial state will satisfy these conditions ( sbj: 0  calc: 0   created: 0 )

      scan_information.processing.model.applied.resume_g.resume = 1;

      set( h, 'Visible', 'off' ); %'on'
      set( h, 'Value', 0 ); %scan_information.processing.model.applied.resume_g.resume
      set( i, 'Visible', 'off' );
%      set( j, 'Visible', onoff_state( scan_information.processing.model.applied.resume_g.resume ) );
    else
%      set( h, 'Visible', 'off' );
      set( h, 'Visible', 'off' ); %on
      scan_information.processing.model.applied.resume_g.resume = 0;
%      set( j, 'Visible', 'off' );
      if ( scan_information.processing.model.applied.apply_g ) 
        set( i, 'Visible', 'on' );
      end
    end
  else
    set( h, 'Visible', 'off' );
    scan_information.processing.model.applied.resume_g.resume = 0;
%    set( j, 'Visible', 'off' );
    if ( scan_information.processing.model.applied.apply_g ) 
      set( i, 'Visible', 'on' );
    end
  end
  save_headers();
  
  set( j, 'Visible', 'off' );%get(h, 'Visible')
  
end


% --- Executes on button press in chk_apply_ga.
function chk_apply_ga_Callback(hObject, eventdata, handles)
% hObject    handle to chk_apply_ga (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global scan_information;
  scan_information.processing.model.process.apply_ga = get(hObject, 'Value');
  scan_information.processing.model.process.apply_gaa = 0;

  set( handles.chk_apply_ga, 'Value', get(hObject, 'Value') );
  set( handles.chk_apply_gaa, 'Value', 0 );
  set_G_process_substates(handles );
end


% --- Executes on button press in chk_apply_gaa.
function chk_apply_gaa_Callback(hObject, eventdata, handles)
% hObject    handle to chk_apply_gaa (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global scan_information;
  scan_information.processing.model.process.apply_ga = 0;
  scan_information.processing.model.process.apply_gaa = get(hObject, 'Value');

  set( handles.chk_apply_ga, 'Value', 0 );
  set( handles.chk_apply_gaa, 'Value', get(hObject, 'Value') );
  set_G_process_substates(handles);
end


% --- Executes on button press in chk_extract_ga.
function chk_extract_ga_Callback(hObject, eventdata, handles)
% hObject    handle to chk_extract_ga (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

end




% ---------------------------------------------
% --- H Process Selections
% ---------------------------------------------

% --- Executes on button press in btn_run_h_process.
function btn_run_h_process_Callback(hObject, eventdata, handles)
% hObject    handle to btn_run_h_process (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  update_process_buttons( handles );
end



% --- Executes on button press in chk_apply_gh.
function chk_apply_gh_Callback(hObject, eventdata, handles)
% hObject    handle to chk_apply_gh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Zheader scan_information 
  scan_information.processing.H_model.apply = get(hObject,'Value');
  update_process_buttons( handles );
end



% --- Executes on button press in chk_apply_HZ.
function chk_apply_HZ_Callback(hObject, eventdata, handles)
% hObject    handle to chk_apply_HZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global scan_information 
  scan_information.processing.H_model.process.hz = get(hObject,'Value');
  scan_information.processing.H_model.process.he = 0;
  guidata(hObject, handles);

  set( handles.chk_apply_HE, 'Enable', constant_define( 'STATE', 0 ) );
  update_process_buttons( handles );
end



% --- Executes on button press in chk_apply_HE.
function chk_apply_HE_Callback(hObject, eventdata, handles)
% hObject    handle to chk_apply_HE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global scan_information 
  scan_information.processing.H_model.process.he = get(hObject,'Value');
  scan_information.processing.H_model.process.hz = 0;
  guidata(hObject, handles);

  set( handles.chk_apply_HZ, 'Enable', constant_define( 'STATE', 0 ) );
  update_process_buttons( handles );
end


% --- Executes on button press in btn_run_gmh_process.
function btn_run_gmh_process_Callback(hObject, eventdata, handles)
% hObject    handle to btn_run_gmh_process (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Zheader scan_information 

% ---  check which portions of GMH data exist
% --- scan_information.processing.GMH_model.options = struct( ...
% ---     'output', struct( 'GMH', 0, 'BH', 0, 'GC', 1, 'E', 0 ), ...
% ---     'vars', struct( 'M', 0, 'ZH', 0, 'Qg', 0, 'Qh', 1), ...
% ---     'exists', struct( 'M', 0, 'ZH', 0, 'Qg', 0, 'Qh', 0, 'GMH', 0, 'BH', 0, 'GC', 0, 'E', 0 ), ...
% ---     'overwrite', 1  );

  load( Zheader.Model.path, 'Gheader');
  if ~exist( 'Gheader', 'var' )
    set( hObject, 'value', 0 );
    return
  end

  if ~isempty( Zheader.Limits.path)
    load( Zheader.Limits.path);
  end
  
  if ~exist( 'Hheader', 'var' )
    set( hObject, 'value', 0 );
    return
  end

  local_dir = [ 'Hsegs' filesep 'GMH' filesep ];
  scan_information.processing.GMH_model.options.ow_flag = 0;

  [H_ID local_dir] = H_path_spec( Hheader, 'GMH' );

  fil = ['ZH_S' num2str( Zheader.num_subjects) '.mat' ];
  x = who_count( local_dir, fil, 'ZH_R*' );
  scan_information.processing.GMH_model.options.exists.ZH = ( x == Zheader.num_runs );
  scan_information.processing.GMH_model.options.ow_flag = scan_information.processing.GMH_model.options.ow_flag || scan_information.processing.GMH_model.options.exists.ZH;

  fil = ['G_S' num2str( Zheader.num_subjects) '.mat' ];
  x = who_count( Gheader.path_to_segs, fil, 'Qg_S*' );
  scan_information.processing.GMH_model.options.exists.Qg = ( x == Zheader.num_subjects );
  scan_information.processing.GMH_model.options.ow_flag = scan_information.processing.GMH_model.options.ow_flag || scan_information.processing.GMH_model.options.exists.Qg;

  fil = ['Qh_P' num2str( Zheader.num_subjects) '.mat' ];
  x = who_count( local_dir, fil, 'Qh_P*' );
  scan_information.processing.GMH_model.options.exists.Qh = ( x == Hheader.model(Hheader.Hindex).partitions.count );
  scan_information.processing.GMH_model.options.ow_flag = scan_information.processing.GMH_model.options.ow_flag || scan_information.processing.GMH_model.options.exists.Qh;


  fil = ['GMH_S' num2str( Zheader.num_subjects) '.mat' ];
  x = who_count( local_dir, fil, 'GMH_R*' );
  scan_information.processing.GMH_model.options.exists.GMH = ( x == Hheader.model(Hheader.Hindex).partitions.count * Zheader.num_runs * max(scan_information.frequencies, 1) );
  scan_information.processing.GMH_model.options.ow_flag = scan_information.processing.GMH_model.options.ow_flag || scan_information.processing.GMH_model.options.exists.GMH;


  fil = ['BH_S' num2str( Zheader.num_subjects) '.mat' ];
  x = who_count( local_dir, fil, 'BH_R*' );
  scan_information.processing.GMH_model.options.exists.BH = ( x == Hheader.model(Hheader.Hindex).partitions.count * Zheader.num_runs * max(scan_information.frequencies, 1) );
  scan_information.processing.GMH_model.options.ow_flag = scan_information.processing.GMH_model.options.ow_flag || scan_information.processing.GMH_model.options.exists.BH;

  fil = ['GC_S' num2str( Zheader.num_subjects) '.mat' ];
  x = who_count( local_dir, fil, 'GC_R*' );
  scan_information.processing.GMH_model.options.exists.GC = ( x == Hheader.model(Hheader.Hindex).partitions.count * Zheader.num_runs * max(scan_information.frequencies, 1) );
  scan_information.processing.GMH_model.options.ow_flag = scan_information.processing.GMH_model.options.ow_flag || scan_information.processing.GMH_model.options.exists.GC;

  fil = ['E_S' num2str( Zheader.num_subjects) '.mat' ];
  x = who_count( local_dir, fil, 'E_R*' );
  scan_information.processing.GMH_model.options.exists.E = ( x == Hheader.model(Hheader.Hindex).partitions.count * Zheader.num_runs * max(scan_information.frequencies, 1) );
  scan_information.processing.GMH_model.options.ow_flag = scan_information.processing.GMH_model.options.ow_flag || scan_information.processing.GMH_model.options.exists.E;

  update_process_buttons( handles );
end



% --- Executes on button press in chk_apply_gmh.
function chk_apply_gmh_Callback(hObject, eventdata, handles)
% hObject    handle to chk_apply_gmh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scan_information 
  scan_information.processing.GMH_model.apply = get(hObject,'Value');

  update_process_buttons( handles );
end


% --- Executes on button press in chk_prepare_GMH.
function chk_prepare_GMH_Callback(hObject, eventdata, handles)

end




function chk_extract_h_Callback(hObject, eventdata, handles)
% hObject    handle to chk_extract_h (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global scan_information 
  scan_information.processing.H_model.extract = get(hObject,'Value');

  update_process_buttons( handles );
end



% ---------------------------------------------
% --- PD Process Selections
% ---------------------------------------------

function chk_run_pd_process_Callback(hObject, eventdata, handles)
% hObject    handle to chk_run_pd_process (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Zheader scan_information 
  scan_information.processing.PD_model.apply = get(hObject,'Value');
  x = scan_information.processing.model.process.extract_g == 1 || ...
      scan_information.processing.model.process.extract_ga == 1 || ...
      scan_information.processing.H_model.extract == 1 || ...
      scan_information.processing.PD_model.process.extract == 1;

  h = findobj( 'Tag', 'frm_RotationSettings' );
  set( h, 'Visible', constant_define( 'STATE', x) );

  if ( scan_information.processing.PD_model.apply == 1 )
    state = 'on';
  else
    state = 'off';
  end

% OVERRIDE until ready
state = 'off';

  if strcmp(state, 'on' )
    switch (scan_information.processing.PD_model.apply)
      case 1  % toggle is down
         set( hObject, 'BackgroundColor', constant_define( 'COLOR_GREEN' ) );

      case 0   % toggle is up
         set( hObject, 'BackgroundColor', constant_define( 'COLOR_GREY' ) );
    end

  else
    set( hObject, 'BackgroundColor', constant_define( 'COLOR_GREY' ) );
  end

  set_pd_process_substates();
end



function chk_apply_pd_Callback(hObject, eventdata, handles)
% hObject    handle to chk_apply_pd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global scan_information 
  scan_information.processing.PD_model.process.apply_pd = get(hObject,'Value');
end



% --- Executes on button press in chk_extract_pd.
function chk_extract_pd_Callback(hObject, eventdata, handles)

end




% --------------------------------------------------
% toggles the states and conditions of H subtask checkboxes
% --------------------------------------------------
function set_h_process_substates()
global scan_information Zheader 

  g_okay = ( Zheader.Model.mat_exists || Zheader.Model.hdr_exists ) && (Zheader.Model.mat_x == Zheader.total_scans);
  e_okay = g_okay;


  a_okay =  g_okay && Zheader.Contrast.mat_exists && ((Zheader.Contrast.mat_x * Zheader.num_subjects) == Zheader.Model.mat_x );
  h_okay =  ( g_okay && Zheader.Limits.mat_exists && (Zheader.Limits.mat_x == Zheader.total_columns ) ) * scan_information.processing.H_model.apply;

% OVERRIDE until ready
%h_okay = 0;

  g_state = 'off';
  a_state = 'off';
  h_state = 'off';
  hr_state = 'off';

  if ( Zheader.Limits.mat_exists )
    [path fn] = split_path( Zheader.Limits.path, filesep );
  else 
    fn = '     ';
  end

  h = findobj('Tag', 'btn_run_h_process');
  run_h = get( h, 'Value' );

  colr = constant_define( 'COLOR_ACTIVE' );

  if ( run_h )
    h_state = 'on' ;
    hr_state = 'on';
    if ( a_okay )       a_state = 'on';     end
  end


  h = findobj('Tag', 'chk_apply_gh');
  set( h, 'Enable', h_state );
  scan_information.processing.H_model.apply = ( strcmp(h_state, 'on' ) && scan_information.processing.H_model.apply );
  set(h, 'Value',scan_information.processing.H_model.apply );

  h = findobj('Tag', 'chk_extract_h');
  set( h, 'Enable', h_state );
  scan_information.processing.H_model.extract = strcmp(h_state, 'on' ) && scan_information.processing.H_model.extract;
  set(h, 'Value',scan_information.processing.H_model.extract);

  Hheader.isRotatable = 0;

  h = findobj('Tag', 'chk_Rotate_H');
  set( h, 'Enable', constant_define( 'STATE', run_h * Hheader.isRotatable ) );
  scan_information.processing.H_model.rotate = (strcmp(h_state, 'on' ) == 1 && scan_information.processing.H_model.rotate) * Hheader.isRotatable;
  set(h, 'Value',scan_information.processing.H_model.rotate);

  b = findobj('Tag', 'btn_Rotate_H_Settings');
  set( b, 'Enable', constant_define( 'STATE', run_h * Hheader.isRotatable ) );
  set(b, 'Value',scan_information.processing.H_model.rotate * h_okay );
  b = findobj('Tag', 'btn_clr_rotations_h');
  set( b, 'Enable', constant_define( 'STATE', run_h * Hheader.isRotatable ) );

 
  proc_h =  ( scan_information.processing.H_model.apply || scan_information.processing.H_model.extract || scan_information.processing.H_model.rotate);
  if ~proc_h
    h_state = 'off' ;
    hr_state = 'off';
    if ( a_okay )       a_state = 'off';     end
    colr = constant_define( 'COLOR_INACTIVE' );
  end

  h = findobj('Tag', 'lbl_H_applied_to');
  set( h, 'Enable', h_state );

  h = findobj('Tag', 'chk_apply_HZ');
  set( h, 'Enable', constant_define( 'STATE', has_Z() ) );
  scan_information.processing.H_model.process.hz = strcmp(h_state, 'on' ) == 1 && scan_information.processing.H_model.process.hz;
  set(h, 'Value',scan_information.processing.H_model.process.hz );

  h = findobj('Tag', 'chk_apply_HE');
  set( h, 'Enable', constant_define( 'STATE', has_E() ) );
  scan_information.processing.H_model.process.he = strcmp(h_state, 'on' ) == 1 && scan_information.processing.H_model.process.he;
  set(h, 'Value',scan_information.processing.H_model.process.he );

%  h = findobj('Tag', 'chk_apply_GMH');
%  set( h, 'Enable', h_state );
%  set(h, 'Value',scan_information.processing.GMH_model.apply );
  
  h = findobj('Tag', 'NumComp_H');
  set( h, 'Enable', h_state );
  str = [];
  for ii = 1:size(scan_information.processing.H_model.process.components,2)
    str = [str ' ' num2str(scan_information.processing.H_model.process.components(ii) ) ];
  end
  set( h, 'String', str );


  % --------------------------------------------------------
  % GMH process master controls 
  % --------------------------------------------------------

  h = findobj('Tag', 'btn_run_gmh_process');
  run_h = get( h, 'Value' );

  colr = constant_define( 'COLOR_ACTIVE' );

  h_state = 'off' ;
  hr_state = 'off';

  if ( run_h )
    h_state = 'on' ;
    hr_state = 'on';
  end

  scan_information.processing.GMH_model.apply = strcmp(h_state, 'on' ) && ...
    ( scan_information.processing.GMH_model.options.GMH.regress || ...
      scan_information.processing.GMH_model.options.BH.regress || ...
      scan_information.processing.GMH_model.options.GC.regress || ...
      scan_information.processing.GMH_model.options.GC.write ); % -- || ...
%      scan_information.processing.GMH_model.options.GMH.apply || scan_information.processing.GMH_model.options.GC.apply || ...
%      scan_information.processing.GMH_model.options.BH.apply );

  scan_information.processing.GMH_model.extract = strcmp(h_state, 'on' ) && ...
    ( scan_information.processing.GMH_model.options.GMH.extract || scan_information.processing.GMH_model.subject_specific || ...
      scan_information.processing.GMH_model.options.BH.extract || scan_information.processing.GMH_model.options.GC.extract);

  scan_information.processing.GMH_model.rotate = strcmp(h_state, 'on' ) == 1 && ...
    ( scan_information.processing.GMH_model.options.GMH.rotate || scan_information.processing.GMH_model.subject_specific_rotated || ...
      scan_information.processing.GMH_model.options.BH.rotate || scan_information.processing.GMH_model.options.GC.rotate);

%  scan_information.processing.GMH_model.applied.resume = ( scan_information.processing.GMH_model.applied.started == 1 && scan_information.processing.GMH_model.applied.completed == 0 );


  h = findobj( 'Tag', 'chk_GMH_Resume' );
  set( h, 'Enable', h_state );
 % if ( strcmp( h_state, 'on' ) ) set( h, 'Value', scan_information.processing.GMH_model.applied.resume ); else set( h, 'Value', 0 ); end
  set( h, 'Visible', constant_define( 'STATE', scan_information.processing.GMH_model.applied.resume ) );

  h = findobj('Tag', 'chk_apply_gmh');
  set( h, 'Enable', h_state );
  set(h, 'Value',scan_information.processing.GMH_model.apply );

  h = findobj('Tag', 'chk_extract_gmh');
  set( h, 'Enable', h_state );
  set(h, 'Value',scan_information.processing.GMH_model.extract);

  h = findobj('Tag', 'chk_gmh_subject_specific');
  set( h, 'Enable', h_state );
  set(h, 'Value',scan_information.processing.GMH_model.subject_specific);

  h = findobj('Tag', 'chk_rotate_gmh');
  set( h, 'Enable', h_state );
  set(h, 'Value',scan_information.processing.GMH_model.rotate);

  h = findobj('Tag', 'chk_gmh_subject_specific_rotated');
  set( h, 'Enable', h_state );
  set(h, 'Value',scan_information.processing.GMH_model.subject_specific_rotated);


  h = findobj('Tag', 'btn_GMH_options');
  set( h, 'Enable', h_state );


  save_headers();
end
  





% --------------------------------------------------
% toggles the states and conditions of PD subtask checkboxes
% --------------------------------------------------
function set_pd_process_substates()
global scan_information Zheader;

  pd_okay =  ( Zheader.P.mat_exists && (Zheader.P.mat_x == Zheader.total_scans) ) && ...
	     ( Zheader.D.mat_exists && (Zheader.D.mat_x == Zheader.total_scans) ) ;

  p_state = 'off';

  if ( scan_information.processing.PD_model.apply == 1 )
    p_state = 'on' ;
  end

% OVERRIDE until ready
p_state = 'off' ;

  h = findobj('Tag', 'chk_apply_pd');
  set( h, 'Enable', p_state );
  scan_information.processing.PD_model.process.apply_pd = strcmp(p_state, 'on' ) == 1 && scan_information.processing.PD_model.process.apply_pd ;
  set(h, 'Value',scan_information.processing.PD_model.process.apply_pd  );

  h = findobj('Tag', 'chk_extract_pd');
  set( h, 'Enable', p_state );
  scan_information.processing.PD_model.process.extract = strcmp(p_state, 'on' ) == 1 && scan_information.processing.PD_model.process.extract;
  set(h, 'Value',scan_information.processing.PD_model.process.extract);

  h = findobj('Tag', 'NumComp_PD');
  set( h, 'Enable', p_state );
  str = sprintf( '%d', scan_information.processing.PD_model.process.components );
  set( h, 'String', str );
end


% --- Executes on button press in btn_PlotOptions.
function btn_PlotOptions_Callback(hObject, eventdata, handles)
% hObject    handle to btn_PlotOptions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Zheader scan_information;

  parms = parametize_components( scan_information.processing.model );

  p = plotSettings( parms.parameters );
  if ( ~isempty(p) )
    scan_information.processing.model.parameters = p;
    save_headers();
  end
end



% --- Executes on button press in btn_G_Stats.
function btn_G_Stats_Callback(hObject, eventdata, handles)
% hObject    handle to btn_G_Stats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Zheader scan_information;

  parms = parametize_components( scan_information.processing.model );
  scan_information.processing.model = parms;

  prf = 'G';
%   model = 'G';
%   if scan_information.processing.model.process.apply_ga
%     model = 'GA';
%   end;
%   if scan_information.processing.model.process.apply_gaa
%     model = 'GAA';
%   end;

  MvsfMRI( 'prefix', prf );
end




function p = parametize_components( model )
% parametize_components( scan_information.processing.model )
% parametize_components( scan_information.processing.H_model )  etc..
%
% places the model component extraction information into the model parameter list
% used by plotting 

  p = model;

  % ------------------------------------------
  % initialize the components name list if it doesn't exist
  % ------------------------------------------
  if ~isfield( p.process, 'component_name' )
    p.process.component_name = [];
    for ( ii = 1:max(p.process.components) )
      str = ['Component ' num2str(ii)];
      if ( ii == 1 ) 
        p.process.component_name = {str};
      else
        p.process.component_name = [p.process.component_name; {str}];
      end
    end
  else
    x = size(p.process.component_name, 2 ) > 1;		% make sure names are vertical
    if(x)
      p.process.component_name = p.process.component_name';
    end
  end

  [x y] = size(p.process.component_name );

  % ------------------------------------------
  % there are missing component names
  % ------------------------------------------
  if ( x < max(p.process.components))		
    for ( ii = x+1:max(p.process.components) )
      str = ['Component ' num2str(ii)];
      if ( ii == 1 ) 
        p.process.component_name = {str};
      else
        p.process.component_name = [p.process.component_name; {str}];
      end
    end
  end
end




% --- Executes on button press in btn_EditZ0.
function btn_EditZ0_Callback(hObject, eventdata, handles)
% hObject    handle to btn_EditZ0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Zheader scan_information ;

  [x y z] = Z_Editor();


  if ~isempty(x)  
    Zheader = x;
    scan_information = y;
    save_headers();

    if ( z )		% scan list adjusted - re-parse text listing

      scan_information = legacy_define( 'scan_information' );
      process_information = legacy_define( 'process_info' );
      Zheader  = legacy_define( 'ZHeader' );

      x = check_memory();

      process_information.control_text = set_control_text();   
      process_information.done_bar.length = 13;

      if ispc 
        process_information.sys = '_pc'; 
      end
 
      if ismac 
        process_information.sys = '_mac'; 
      end

      [process_information.is64bit process_information.hasCacheDrop process_information.sudoUser process_information.isRoot process_information.HDF5] = ...
          system_settings( process_information.cache_buffer );

      parse_scan_listing( y.FileList );

      scan_information.FileList = y.FileList;

      % confirm the directory pointed to still exists ( may be a removable drive )
      % --------------------------------------------------------
      x = exist( char(scan_information.BaseDir), 'dir' ) == 7;
      h = findobj('Tag','chk_ScanDirExists');
      set(h,'Visible', constant_define( 'STATE', x) );

      % the raw image header is preserved - is it analyse or nifti
      % --- assuming radiological orientation for analyse images (default)
      % --- assuming radiological when vox(1) negative on nifti images
      % --------------------------------------------------------
      if nifti_version( scan_information.raw_data.header )
        if ( scan_information.raw_data.header.srow_x(1) >= 0 ) 
          scan_information.Orientation = 1;
        end
      end    

      % --------------------------------------------------------
      % we need to determine the number of scans for all subjects
      % and calculate how much memory the full Z matrix will require
      % if more than available user memory, determine level of columnar segmentation
      % --------------------------------------------------------
      sum_subject_scans();

    end
    
    update_process_buttons( handles );

  end
end



% --- Executes on button press in btn_UnloadData.
function btn_UnloadData_Callback(hObject, eventdata, handles)
% hObject    handle to btn_UnloadData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Zheader scan_information;

  scan_information = legacy_define( 'scan_information' );
  Zheader  = legacy_define( 'ZHeader' );

  update_process_buttons( handles );  

  h = findobj( 'Tag', 'btn_FileList' );
%  set( h, 'Visible', 'on' );
%  set( hObject, 'Visible', 'off' );

  set( h, 'Enable', 'on' );
  set( hObject, 'Enable', 'off' );

  drawnow();
end



function txt_MaxPartitionmem_Callback(hObject, eventdata, handles)
% hObject    handle to txt_MaxPartitionmem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_MaxPartitionmem as text
%        str2double(get(hObject,'String')) returns contents of txt_MaxPartitionmem as a double
end


% --- Executes during object creation, after setting all properties.
function txt_MaxPartitionmem_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_MaxPartitionmem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on button press in btn_ResizePartitions.
function btn_ResizePartitions_Callback(hObject, eventdata, handles)
% hObject    handle to btn_ResizePartitions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Zheader process_information 

  new_limit = str2double( get( handles.txt_MaxPartitionmem,'String') );
  new_partitions = calc_column_partitions( Zheader.total_scans, Zheader.total_columns, new_limit );
  new_partitions.partitioned = 1;

  if ( new_partitions.count == Zheader.partitions.count )
    
    str = sprintf( 'The memory limit selected (%d Mb), does not result in a change of partition size.\n', new_limit );
    show_message( 'Change has no effect', str );
  else

    %------------------------------------------------
    % confirm they want to repartition
    %------------------------------------------------

    if ( Zheader.partitions.partitioned )
      str = sprintf( 'You have chosen to resize your Z partitions to consume no more than %d Mb of memory.  This will adjust your existing partitions ( %d at %d column width) to ( %d at %d column width).  Do you want to proceed with resizing your existing Z data?', ...
      new_limit, Zheader.partitions.count, Zheader.partitions.columns(1), new_partitions.count, new_partitions.columns(1)  );

    else

      str = sprintf( 'You have chosen to resize your Z partitions to consume no more than %d Mb of memory.  This will adjust your existing data to ( %d at %d column width).  Do you want to proceed with resizing your existing Z data?', ...
      new_limit, new_partitions.count, new_partitions.columns(1)  );

    end

    myAnswer = questdlg(str,'WARNING!','Okay','NO!','NO!');

    if strcmp(myAnswer, 'NO!')	

      str = sprintf( '%d', constant_define( 'PARTITION_MAX' ) );
      set ( handles.txt_MaxPartitionmem, 'String', str );

      set ( handles.btn_ResizePartitions, 'Visible', 'off' );

      return; 
    end

    Txt = 'Resizing Existing Z data';
    Sts = '';
    if ( isa( handles.progressBar, 'cpca_progress' ) )
      handles.progressBar.setMessage( Txt, Sts, '' );
      handles.progressBar.setIterations( Zheader.num_subjects * Zheader.num_runs );
      handles.progressBar.show();
    end

    Normalized_Z_Dir = Z_Directory();
 
    for SubjectNo = 1:Zheader.num_subjects;
      sid = subject_id( SubjectNo );

      for RunNo = 1:Zheader.num_runs;
        
        if ( isa( handles.progressBar, 'cpca_progress' ) )
          handles.progressBar.setParticipant( SubjectNo, Zheader.num_subjects, sid );
          handles.progressBar.setRun( RunNo, Zheader.num_runs );
          handles.progressBar.setMessage( Txt, 'Loading. . .', '' );
          handles.progressBar.increment();
        end

        Z = [];

        %------------------------------------------------
        % retrieve the entire normalized subject run data
        %------------------------------------------------
        if ( Zheader.partitions.partitioned == 0 )
          eval ( [ 'load( ''' Normalized_Z_Dir 'Z' filesep 'Z' num2str(SubjectNo) '.mat''' ', ''Z' num2str(RunNo) ''''] );
          eval ( [ 'Z = [Z; Z' num2str(RunNo) ' ];' ] );
          eval ( ['clear Z' num2str(RunNo) ] );
        else
          Z = load_subject_run( SubjectNo, RunNo );
        end

        if ( isa( handles.progressBar, 'cpca_progress' ) )
          handles.progressBar.setMessage( Txt, 'Resizing. . .', '');
        end
   
        %------------------------------------------------
        % repartition to new size
        %------------------------------------------------
        start_col = 1;
        for column = 1:size( new_partitions.columns,2)
          end_col = start_col + new_partitions.columns(column) - 1;
          eval ( ['Z_R' num2str(RunNo) '_C' num2str(column) ' = Z(:,' num2str(start_col) ':' num2str(end_col) ' );'; ] );
          eval ( [ 'save( ''' Normalized_Z_Dir 'Z' filesep 'Z' num2str(SubjectNo) '.mat'', ''Z_R' num2str(RunNo) '_C' num2str(column) ''', ''-append'', ''-v7.3'')' ] );
          start_col = end_col+1;
          eval ( ['clear Z_R' num2str(RunNo) '_C' num2str(column) ] );
        end
       
      end    % --- each subject run  ---
    end  % --- each subject  ---

    Zheader.partitions = new_partitions;

    if ( isa( handles.progressBar, 'cpca_progress' ) )
      handles.progressBar.hide();
    end
    update_process_buttons( handles );  

  end

  set ( handles.btn_ResizePartitions, 'Visible', 'off' );
  save_headers();
end


% --- Executes on key press with focus on txt_MaxPartitionmem and none of its controls.
function txt_MaxPartitionmem_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to txt_MaxPartitionmem (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

global Zheader 

  k = eventdata.Key;

  if ( strcmp( k, 'return' ) )
    drawnow();				% force text input box update with current value

    x=exist( ['Z' filesep 'Z1.mat'] );
    if x == 2   % the file exists
      set ( handles.btn_ResizePartitions, 'Visible', 'on' );
    else
      max_sz = str2double( get( handles.txt_MaxPartitionmem,'String') );
      Zheader.partitions = calc_column_partitions( Zheader.total_scans, Zheader.total_columns, max_sz );
      Zheader.partitions.partitioned = 0;
      save_headers();
      update_process_buttons( handles );  
    end
  end
end



% --- Executes on button press in chk_Rotate_G.
function chk_Rotate_G_Callback(hObject, eventdata, handles)
% hObject    handle to chk_Rotate_G (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global scan_information 
  scan_information.processing.model.process.rotate_g = get(hObject,'Value');

  % --------------------------------------------------
  % --- check each extraction value and verify a non rotated solution exists --
  % --------------------------------------------------
  if ( scan_information.processing.model.process.rotate_g == 1 )
    gext = get( handles.chk_extract_G, 'Value' );
    if ( gext == 0 )		% if the extraction process is not selected
      for ( comp_idx = 1:size(scan_information.processing.model.process.components, 2) )
        nd = scan_information.processing.model.process.components(comp_idx);
        component_directory = fs_path( 'unrotated', 'output', nd, 0, struct( 'model', 'G' ) );

        x = exist( [ component_directory 'G_unrotated.mat' ], 'file' );
        if ( x == 2 )
          set( handles.chk_extract_G, 'Value', 1 );
        end
      end
    end
  end

  update_process_buttons( handles );
end



% --- Executes on button press in btn_Rotate_G_Settings.
function btn_Rotate_G_Settings_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Rotate_G_Settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scan_information

  sett = scan_information.processing.model.rotation;
  
  x = Rotation_Settings( 'Setting', sett, 'Title', 'G Rotation Settings', 'Model', 'G' );

  if ( isnumeric(x) )
    scan_information.processing.model.rotation = [];
    save_headers();
  else
    if (~ isempty( x ))
      scan_information.processing.model.rotation = x;
      save_headers();
    end
  end
end



% --- Executes on button press in btn_clr_rotations.
function btn_clr_rotations_Callback(hObject, eventdata, handles)
% hObject    handle to btn_clr_rotations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scan_information

  scan_information.processing.model.rotation = [];
  save_headers();
end



% --- Executes on button press in chk_extract_G.
function chk_extract_G_Callback(hObject, eventdata, handles)
% hObject    handle to chk_extract_G (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scan_information

  scan_information.processing.model.process.extract_g = get(hObject,'Value');
  save_headers();
  update_process_buttons( handles );
end



% --- Executes on button press in btn_Gheader_Info.
function btn_Gheader_Info_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Gheader_Info (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Zheader scan_information


  % --------------------------------------------------
  % --- load in the applied G header info
  % --------------------------------------------------
  load( Zheader.Model.path, 'Gheader' );

  % --------------------------------------------------
  % --- create a GZ header structure if required
  % --------------------------------------------------
  if ( ~isfield( Gheader, 'GZheader' ) )
    Gheader.GZheader = structure_define( 'GZHEADER' );
  else
    if ( ~isstruct( Gheader.GZheader ) )   % original data may be set to 0, not structure
      Gheader.GZheader = structure_define( 'GZHEADER' );
    end
  end

  % --------------------------------------------------
  % --- at this point we either have the original GZheader info, or a new blank structure
  % --------------------------------------------------
  gh = Full_G_Parameters( 'Header', Gheader );

  if ( ~isempty( gh ) )   
    % check the G and GZ information

    Gheader = gh;
    eval ( ['save( ''' Zheader.Model.path ''', ''Gheader'', ''-append'');' ] );

%    scan_information.processing.model.parameters = Gheader;
    scan_information.processing.model.parameters.condition_name = Gheader.condition_name;
    scan_information.processing.model.parameters.model_type = Gheader.model_type;
    scan_information.processing.model.parameters.conditions = Gheader.conditions;
    scan_information.processing.model.parameters.bins = Gheader.bins;
    scan_information.processing.model.parameters.TR = Gheader.TR ;
    scan_information.processing.model.parameters.inScans = Gheader.inScans;
    save_headers();

  end

  update_process_buttons( handles );
end



% --- Executes on button press in btn_view_log.
function btn_view_log_Callback(hObject, eventdata, handles)
% hObject    handle to btn_view_log (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%  logname = cpca_log_file();
  [path name] = cpca_log_file();
  if ( isempty( path) )  return;  end		% if permissions errors or environment unaccessible, abort logging

  logname = [path name]
  LFil = fopen( logname, 'a' );		% if the log file does not exist, then this will create an empty one, avoiding edit error
  fclose( LFil );
  eval( ['edit ' logname ] );
end



% --- Executes on button press in btn_GH_Stats.
function btn_GH_Stats_Callback(hObject, eventdata, handles)
  
  xx = regexp( handles.H_screeview, ':', 'split' );
  if ( size(xx,2) > 1 )
    prf = char(xx(1) );
    fil = char(xx(2) );

    MvsfMRI( 'prefix', char(xx(1) ), 'module', char(xx(2) ) );

  else
    MvsfMRI( 'prefix', char(xx(1) ) );
  end
end



% --- Executes on button press in btn_mask_verify.
function btn_mask_verify_Callback(hObject, eventdata, handles)
% hObject    handle to btn_mask_verify (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scan_information Zheader process_information;

  x = mask_verification();
  return;


  MainText = sprintf( '%s\n', 'Verifying Mask:' );
  SubjectText = '';

  if ( isa( handles.progressBar, 'cpca_progress' ) )
    handles.progressBar.setWindowTitle( 'Mask Verification' );
    handles.progressBar.setMessage( MainText, '', '' );
    handles.progressBar.show();
  end

  SubjectText = '';
  Errtext = {'Subjects showing mask errors:'};
  err_count = 0;

  fid = fopen( 'scan_errors.txt', 'w' );  % --- create empty scan errors file
  if (fid) fclose( fid ); end

  fid = fopen( 'scan_summary.txt', 'w' );  % --- create empty scan summary file
  if (fid) fclose( fid ); end

  for FrequencyNo = 1:Zheader.num_Z_arrays

  for SubjectNo=1:scan_information.NumSubjects

    sid = subject_id( SunjectNo );
    handles.progressBar.setParticipant( SubjectNo, Zheader.num_subjects, sid );

    in_err = [0];

    for RunNo = 1:Zheader.num_runs;

      if ( isa( handles.progressBar, 'cpca_progress' ) )
        handles.progressBar.setRun( RunNo, Zheader.num_runs );
      end

      ab = verify_user_mask( SubjectNo, RunNo, FrequencyNo, 1 );
      clear verify_user_mask

      if ~isempty( ab.nans )
        if ( isa( handles.progressBar, 'cpca_progress' ) )
          handles.progressBar.hide();
        end

        str = ['Subject ' char(scan_information.SubjectID(SubjectNo)) ' run ' num2str(RunNo) ' mask returning ' num2str(size(ab.nans,2)) ' NaN''s or Inf''s.'];	% --=
        str = [str ' Full file list contained in file: scan_errors.txt.' ];

        show_message( 'Mask Application Error', str );
        return;

      end

      if ( ab.count > 0 )
        in_err = [in_err 1];

      else
        % negative value returned: some image read error detected
        if ( ab.count < 0 )
          if ( isa( handles.progressBar, 'cpca_progress' ) )
            handles.progressBar.hide();
          end
          show_message( 'File Read Error', ab.error );
          return;
        end
      end

    end

    if sum(in_err) > 0
      err_count = err_count + 1;
      MainText = [MainText SubjectText sid];
      Errtext = [Errtext; {[SubjectText sid]}];
    end

  end
  end

  if ( isa( handles.progressBar, 'cpca_progress' ) )
    handles.progressBar.hide();
  end
  drawnow();

  if err_count > 0
    dt = date;
    txt = ['verifying mask ' scan_information.mask.file ];
    loc = [ 'data: ' Zheader.Z_Directory ];
    write_log( dt, txt, loc, Errtext );

    str = sprintf( 'There are %d subjects/runs that are not properly aligned with the given mask.  A complete list of these has been appended to the log file.', err_count );
    show_message( 'Mask Incompatibilites', str );

  end
end


% --- Executes on button press in chk_resume_apply_g.
function chk_resume_apply_g_Callback(hObject, eventdata, handles)
% hObject    handle to chk_resume_apply_g (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_resume_apply_g
global Zheader scan_information

  x = get( hObject, 'Value' );
  h = findobj('Tag','btn_regress_G_settings');

  scan_information.processing.model.applied.resume_g.resume = x;
  save_headers();
%  set( h, 'Visible', onoff_state( x ) );
  set( i, 'Visible', constant_define( 'STATE', x ) );
  
end


% --- Executes on button press in chk_resume_normalization.
function chk_resume_normalization_Callback(hObject, eventdata, handles)
% hObject    handle to chk_resume_normalization (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scan_information Zheader

  scan_information.processing.subjects.process.resume = get(hObject,'Value');
  save_headers();  
end



% --- Executes on button press in btn_create_mask.
function btn_create_mask_Callback(hObject, eventdata, handles)
% hObject    handle to btn_create_mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scan_information Zheader 

  x = create_mask();
  clear create_mask

  if ( ~isempty(x) )

    r = regexp( x, '~', 'split' );
    x = char(r(1));
      
    msk = cpca_read_vol( x );

    msk.ind = find( msk.image);
    if size( msk.ind, 2 ) > 1 && size( msk.ind, 1 ) == 1
      msk.ind = msk.ind';
    end

    scan_information.mask = msk;
    scan_information.mask.file = x;

    scan_information.mask.x = size( scan_information.mask.ind, 1);
    scan_information.mask.y = size( scan_information.mask.ind, 2);

    scan_information.mask.isRegistered = isRegistered( scan_information.mask ) ;
    scan_information.mask.MNI = MNI_coords( scan_information.mask );
    
    if ( isempty( Zheader.Z_Directory ) ) && prod( size( scan_information.mask.ind ) ) > 1 
      Zheader.Z_Directory = [ pwd filesep ];
      save_headers();
    end

    % resetting the mask may have different resulting dimensions on Z matrices  
    if ( isempty( Zheader.Z_File.name )  && exist(scan_information.BaseDir, 'dir') == 7 )
      sum_subject_scans();
    end

    Zheader.total_columns = scan_information.mask.x;
    Zheader.partitions = calc_column_partitions( Zheader.total_scans, Zheader.total_columns, constant_define( 'PARTITION_MAX' ) );

    save_headers();

    update_process_buttons( handles );  

    drawnow();

  end
end



% --- Executes on button press in chk_resume_apply_h.
function chk_resume_apply_h_Callback(hObject, eventdata, handles)
% hObject    handle to chk_resume_apply_h (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_resume_apply_h
end


% --- Executes on button press in chk_Rotate_H.
function chk_Rotate_H_Callback(hObject, eventdata, handles)
% hObject    handle to chk_Rotate_H (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global scan_information ;
  scan_information.processing.H_model.rotate = get(hObject,'Value');
  save_headers();

  update_process_buttons( handles );
end



% --- Executes on button press in btn_Rotate_H_Settings.
function btn_Rotate_H_Settings_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Rotate_H_Settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scan_information

  sett = scan_information.processing.H_model.rotation;
  
  x = Rotation_Settings( 'Setting', sett, 'Title', 'H Rotation Settings', 'Model', 'H' );

  if ( isnumeric(x) )
    scan_information.processing.H_model.rotation = [];
    save_headers();
  else
    if (~ isempty( x ))
      scan_information.processing.H_model.rotation = x;
      save_headers();
    end
  end
end


% --- Executes on button press in btn_clr_rotations_h.
function btn_clr_rotations_h_Callback(hObject, eventdata, handles)
% hObject    handle to btn_clr_rotations_h (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scan_information

  scan_information.processing.H_model.rotation = [];
  save_headers();
end



% ------------------------------------------------------------------------
% --- New process - locate which VR to use from list of output files for G
% --- place tha5t variable data into model.limits, and process as normal H
% --- only a single H at a time allowed
% --- use G button only appears when G processing done
% --- notify user to fix any component flipping issues before selecting H
% ------------------------------------------------------------------------


% --- Executes on button press in btn_Scree_Plot.
function btn_Scree_Plot_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Scree_Plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Zheader scan_information 

%   if isChecked( handles.lbl_GROI )
%     model = 'ROI';
%     load G_ROI
%   
%     roi_id = strrep( G_ROI.mask( G_ROI.Rindex).id, ' ', '_' );
%     gzpth = [ model filesep roi_id filesep 'GZsegs'];			% eg: GZ_segs, GAZ_segs
%     
%     C_Eigenvalues = load_GC_var( gzpth, 'C_Eigenvalues', model );
%     model = [ 'ROI: ' G_ROI.mask( G_ROI.Rindex).id ];
%       
%   else    
      
    if ( ~isempty( Zheader.Model.path ) && Zheader.Model.hdr_exists == 1 )
      load( Zheader.Model.path, 'Gheader' );
      [gzpth g] = split_path( Gheader.GZheader.path_to_segs, filesep );  
    else
      gzpth = ['./GZsegs' filesep ] ;
    end

    model = 'G';
    if isChecked( handles.chk_apply_ga ),       model = 'GA';    end;
    if isChecked( handles.chk_apply_gaa),       model = 'GAA';   end;

    WG = isRegistered(scan_information.mask) * constant_define( 'PREFERENCES', 'general.gray_white_split' );
    eigvar = ['C' constant_define( 'REGISTRATION_TAG', WG ) '_Eigenvalues'];
   
    C_Eigenvalues = load_GC_var( Gheader, eigvar, model );
%   end;
  
  if ~isempty( C_Eigenvalues )

    ext = min(40, size(C_Eigenvalues,1) );
    Ce = C_Eigenvalues(1:ext,:)./(Zheader.total_scans - 1);
    h = figure;
    plot( Ce, '-O', 'MarkerSize', 5 );

    set( h, 'NumberTitle' , 'off' );
    set( h, 'Name' , ['Scree Plot ' model constant_define( 'REGISTRATION_FULL', WG ) ] );

  end
end



% --- Executes on button press in btn_GROI_Scree.
function btn_GROI_Scree_Callback(hObject, eventdata, handles)

  load G_ROI
  Ce = load_ROI_var( 'GZ', 'C_Eigenvalues' ); 
  if ~isempty( Ce )
    ext = min(40, size(Ce,1) );
    h = figure;
    plot( Ce(1:ext), '-O', 'MarkerSize', 5 );

    set( h, 'NumberTitle' , 'off' );
    set( h, 'Name' , ['Scree Plot - ROI: ' G_ROI.mask( G_ROI.Rindex).id ] );

  end

end


% --- Executes on button press in btn_HScree_Plot.
function btn_HScree_Plot_Callback(hObject, eventdata, handles)

global Zheader scan_information 

  if isempty(handles.H_screeview)  return; end

  xx = regexp( handles.H_screeview, ':', 'split' );
  if ( size(xx,2) > 1 )
    mdl = char(xx(1) );
    fil = char(xx(2) );
  else
    mdl = char(xx );
    fil = char(xx );
  end

  switch fil
      case 'GC'
        fil = 'GnotH';
      case 'BH'
        fil = 'HnotG';
  end
  
  load( Zheader.Limits.path );
  [hid gzpth] = H_path_spec( Hheader, mdl );
  h_id = '';
  if ~isempty( Hheader.model(Hheader.Hindex).id );
    h_id = [' - (' Hheader.model(Hheader.Hindex).id ')' ];
  end

  if strcmp( mdl, 'GMH' )
    C_Eigenvalues = load_GMH_var( Hheader, fil, 'C_Eigenvalues' );
  else
    C_Eigenvalues = load_H_var( Hheader, mdl, fil, 'C_Eigenvalues' );
  end;

  if ~isempty( C_Eigenvalues )
    ext = min(40, size(C_Eigenvalues,1) );
    Ce = C_Eigenvalues(1:ext,:)./(Zheader.total_scans - 1);
    h = figure;
    plot( Ce, '-O', 'MarkerSize', 5 );

    set( h, 'NumberTitle' , 'off' );
    set( h, 'Name' , ['Scree Plot - ' handles.H_screeview h_id] );

  end
end



function has_eigs = check_C_Eigenvalues( module ) 
global Zheader scan_information

  xx = regexp( module, ':', 'split' );
  if ( size(xx,2) > 1 )
    mdl = char(xx(1) );
    fil = char(xx(2) );
  else
    fil = char(xx );
    if size(module, 2) > 1     % -- ZH or EH
      mdl = char(fil(2));
    else
      mdl = char(fil(1));
    end
    if strcmp(mdl, 'H' )  mdl = fil; end
  end

% GMH issue
  has_eigs = 0;

  % --- GMH HZ or HE will be in module subdirectories - all G will be in main
%  if strcmp(fil, 'GMH' )  mdl = fil; else  mdl = char(fil(1)); end
%
%  if strcmp(mdl, 'H' )  mdl = fil; end

  gzpth = get_GZsegs_path( mdl );

  ceig_file = [fil '.mat'];
  xx = who_stats( gzpth, ceig_file, 'C_Eigenvalues' );
  if ( ~xx.mat_exists )  

    ceig_file = [fil '_vars.mat'];
    xx = who_stats( gzpth, ceig_file, 'C_Eigenvalues' );
  end
  
  
  if ( ~xx.mat_exists )  
    % --- trap for hpc GMH:GC eigenvalues container
    if strcmp( mdl, 'GMH' ) && strcmp( fil, 'GC' )
      ceig_file = [fil '_AA_Eigs.mat'];
      xx = who_stats( gzpth, ceig_file, 'C_Eigenvalues' );
    end;    
  end

  if xx.mat_exists
    has_eigs = 1;		% --- variable for eigenvalues exists ---
  end;
  
end



function gzpth = get_GZsegs_path( mdl )
global Zheader scan_information 
  if nargin == 0 mdl = 'G'; end

  gzpth = '';

  switch mdl

      case {'GMH' 'ZH', 'EH'}  

        if ( ~isempty( Zheader.Limits.path ) && Zheader.Limits.hdr_exists == 1 )
          load( Zheader.Limits.path);
          [H_ID gzpth] = H_path_spec( Hheader, mdl );
        end

    otherwise
      if ( ~isempty( Zheader.Model.path ) && Zheader.Model.hdr_exists == 1 )
        load( Zheader.Model.path, 'Gheader');
        if isempty(Gheader.GZheader)   		return; end
        if ~isfield(Gheader.GZheader, 'path_to_segs' )   		return; end
        if isempty(Gheader.GZheader.path_to_segs)	return; end
        [gzpth g] = split_path( Gheader.GZheader.path_to_segs, filesep );  
       else
         gzpth = [ pwd filesep 'GZsegs' filesep ] ;
      end

  end
end



% --- Executes on button press in btn_clear_cache.
function btn_clear_cache_Callback(hObject, eventdata, handles)
% hObject    handle to btn_clear_cache (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global process_information 

  % flush memory cache if applicable
  % --------------------------------------------------------
  if size(process_information.sudoUser, 2) > 0 || process_information.isRoot
    if process_information.isRoot
      eval( '!sync' );
      evalc( ['!echo 3 | tee ' process_information.cache_buffer ] );
    else
      eval( '!sudo sync' );
      evalc( ['!echo 3 | sudo tee ' process_information.cache_buffer ] );
    end

  else

    eval( '!sudo sync' );
    evalc( sprintf( '!echo 3 | sudo tee %s', process_information.cache_buffer ) );

  end

  update_process_buttons( handles );
  drawnow();
end



% --- Executes on button press in btn_Select_ROI
function btn_Select_ROI_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Select_ROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Zheader scan_information

  x = ROI_masks( 'zheader', Zheader, 'scaninfo', scan_information );

  if ~isempty( x )
    msk = cpca_read_vol( x );
    msk.ind = find( msk.image);
   
    scan_information.mask = msk;
    scan_information.mask.file = x;

    sz = size( scan_information.mask.ind );
    scan_information.mask.x = sz(1);
    scan_information.mask.y = sz(2);
    Zheader.total_columns = scan_information.mask.x;

    if ( isempty( Zheader.Z_File.name )  && exist(scan_information.BaseDir, 'dir') == 7 )
      sum_subject_scans();
    end

    save_headers();
    update_process_buttons( handles );  

    drawnow();

  end   
end




% --- Executes on button press in btn_verify_scans.
function btn_verify_scans_Callback(hObject, eventdata, handles)
% hObject    handle to btn_verify_scans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  x = scan_verification();

  update_process_buttons( handles );  
end



% --- Executes on button press in btn_DebugData.
function btn_DebugData_Callback(hObject, eventdata, handles)
% hObject    handle to btn_DebugData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%global Zheader scan_information

  utility_toolkit();
%  x = Utilities( 'zheader', Zheader, 'scaninfo', scan_information );
end



% --- Executes on button press in btn_view_EH.
function btn_view_EH_Callback(hObject, eventdata, handles)

  handles.H_screeview = 'EH';
  guidata(hObject, handles);

  h = findobj( 'Tag', 'bnt_view_EH' );
  i = findobj( 'Tag', 'btn_view_ZH' );
  j = findobj( 'Tag', 'btn_view_GMH' );
  k = findobj( 'Tag', 'btn_view_BH' );
  l = findobj( 'Tag', 'btn_view_GC' );

  set( h, 'Value', 1 );
  set( h, 'BackgroundColor', constant_define( 'COLOR_GREEN' ) );

  set( i, 'Value', 0 );
  set( i, 'BackgroundColor', constant_define( 'COLOR_GREY' ) );

  set( j, 'Value', 0 );
  set( j, 'BackgroundColor', constant_define( 'COLOR_GREY' ) );

  set( k, 'Value', 0 );
  set( k, 'BackgroundColor', constant_define( 'COLOR_GREY' ) );

  set( l, 'Value', 0 );
  set( l, 'BackgroundColor', constant_define( 'COLOR_GREY' ) );

  scree_btn = findobj( 'Tag', 'btn_HScree_Plot' );
  xx = check_C_Eigenvalues( 'EH');
  if ( xx ) set( scree_btn, 'Enable', 'on' ); end

  stats_btn = findobj( 'Tag', 'btn_GH_Stats' );
  has_H = has_component_directory( 'H', 'EH' );
  if ( has_H )
    set( stats_btn, 'Enable', 'on' );
  else
    set( stats_btn, 'Enable', 'off' );
  end
end



% --- Executes on button press in btn_view_ZH.
function btn_view_ZH_Callback(hObject, eventdata, handles)

  handles.H_screeview = 'ZH';
  guidata(hObject, handles);

  h = findobj( 'Tag', 'btn_view_ZH' );
  i = findobj( 'Tag', 'btn_view_EH' );
  j = findobj( 'Tag', 'btn_view_GMH' );
  k = findobj( 'Tag', 'btn_view_BH' );
  l = findobj( 'Tag', 'btn_view_GC' );

  set( h, 'Value', 1 );
  set( h, 'BackgroundColor', constant_define( 'COLOR_GREEN' ) );

  set( i, 'Value', 0 );
  set( i, 'BackgroundColor', constant_define( 'COLOR_GREY' ) );

  set( j, 'Value', 0 );
  set( j, 'BackgroundColor', constant_define( 'COLOR_GREY' ) );

  set( k, 'Value', 0 );
  set( k, 'BackgroundColor', constant_define( 'COLOR_GREY' ) );

  set( l, 'Value', 0 );
  set( l, 'BackgroundColor', constant_define( 'COLOR_GREY' ) );

  scree_btn = findobj( 'Tag', 'btn_HScree_Plot' );
  xx = check_C_Eigenvalues( 'ZH');
  if ( xx ) set( scree_btn, 'Enable', 'on' ); end

  stats_btn = findobj( 'Tag', 'btn_GH_Stats' );
  has_H = has_component_directory( 'H', 'ZH' );
  if ( has_H )
    set( stats_btn, 'Enable', 'on' );
  else
    set( stats_btn, 'Enable', 'off' );
  end
end




% --- Executes on button press in btn_view_GMH.
function btn_view_GMH_Callback(hObject, eventdata, handles)

  handles.H_screeview = 'GMH:GMH';
  guidata(hObject, handles);

  h = findobj( 'Tag', 'btn_view_GMH' );
  i = findobj( 'Tag', 'bnt_view_EH' );
  j = findobj( 'Tag', 'btn_view_ZH' );
  k = findobj( 'Tag', 'btn_view_BH' );
  l = findobj( 'Tag', 'btn_view_GC' );

  set( h, 'Value', 1 );
  set( h, 'BackgroundColor', constant_define( 'COLOR_GREEN' ) );

  set( i, 'Value', 0 );
  set( i, 'BackgroundColor', constant_define( 'COLOR_GREY' ) );

  set( j, 'Value', 0 );
  set( j, 'BackgroundColor', constant_define( 'COLOR_GREY' ) );

  set( k, 'Value', 0 );
  set( k, 'BackgroundColor', constant_define( 'COLOR_GREY' ) );

  set( l, 'Value', 0 );
  set( l, 'BackgroundColor', constant_define( 'COLOR_GREY' ) );

  scree_btn = findobj( 'Tag', 'btn_HScree_Plot' );
  xx = check_C_Eigenvalues( 'GMH:GMH');
  if ( xx ) set( scree_btn, 'Enable', 'on' ); end
%  set( scree_btn, 'Enable', 'off' ); 

  stats_btn = findobj( 'Tag', 'btn_GH_Stats' );
  has_H = has_component_directory( 'H', 'GMH' );
  if ( has_H )
    set( stats_btn, 'Enable', 'on' );
  else
    set( stats_btn, 'Enable', 'off' );
  end
end



% --- Executes on button press in btn_view_BH.
function btn_view_BH_Callback(hObject, eventdata, handles)

  handles.H_screeview = 'GMH:BH';
  guidata(hObject, handles);

  h = findobj( 'Tag', 'btn_view_BH' );
  i = findobj( 'Tag', 'bnt_view_EH' );
  j = findobj( 'Tag', 'btn_view_ZH' );
  k = findobj( 'Tag', 'btn_view_GMH' );
  l = findobj( 'Tag', 'btn_view_GC' );

  set( h, 'Value', 1 );
  set( h, 'BackgroundColor', constant_define( 'COLOR_GREEN' ) );

  set( i, 'Value', 0 );
  set( i, 'BackgroundColor', constant_define( 'COLOR_GREY' ) );

  set( j, 'Value', 0 );
  set( j, 'BackgroundColor', constant_define( 'COLOR_GREY' ) );

  set( k, 'Value', 0 );
  set( k, 'BackgroundColor', constant_define( 'COLOR_GREY' ) );

  set( l, 'Value', 0 );
  set( l, 'BackgroundColor', constant_define( 'COLOR_GREY' ) );

  scree_btn = findobj( 'Tag', 'btn_HScree_Plot' );
  xx = check_C_Eigenvalues( 'GMH:BH');
  if ( xx ) set( scree_btn, 'Enable', 'on' ); end
%  set( scree_btn, 'Enable', 'off' ); 

  stats_btn = findobj( 'Tag', 'btn_GH_Stats' );
  has_H = has_component_directory( 'H', 'GMH', 'BH' );
  if ( has_H )
    set( stats_btn, 'Enable', 'on' );
  else
    set( stats_btn, 'Enable', 'off' );
  end
end



% --- Executes on button press in btn_view_GC.
function btn_view_GC_Callback(hObject, eventdata, handles)
global Zheader

  handles.H_screeview = 'GMH:GC';
  guidata(hObject, handles);

  h = findobj( 'Tag', 'btn_view_GC' );
  i = findobj( 'Tag', 'bnt_view_EH' );
  j = findobj( 'Tag', 'btn_view_ZH' );
  k = findobj( 'Tag', 'btn_view_BH' );
  l = findobj( 'Tag', 'btn_view_GMH' );

  set( h, 'Value', 1 );
  set( h, 'BackgroundColor', constant_define( 'COLOR_GREEN' ) );

  set( i, 'Value', 0 );
  set( i, 'BackgroundColor', constant_define( 'COLOR_GREY' ) );

  set( j, 'Value', 0 );
  set( j, 'BackgroundColor', constant_define( 'COLOR_GREY' ) );

  set( k, 'Value', 0 );
  set( k, 'BackgroundColor', constant_define( 'COLOR_GREY' ) );

  set( l, 'Value', 0 );
  set( l, 'BackgroundColor', constant_define( 'COLOR_GREY' ) );

%   scree_btn = findobj( 'Tag', 'btn_HScree_Plot' );
%   xx = check_C_Eigenvalues( 'GMH:GC');
  xx = 0;
  if ~isempty( Zheader.Limits )
    if isfield( Zheader.Limits, 'path' )
      load( Zheader.Limits.path);
      if exist( 'Hheader', 'var' )
        xx = has_GMH_var( Hheader, 'GnotH', 'C_Eigenvalues')
        set( handles.btn_HScree_Plot, 'Enable', constant_define( 'STATE', has_GMH_var( Hheader, 'GnotH', 'C_Eigenvalues') ) );
        set( handles.btn_GH_Stats, 'Enable', constant_define( 'STATE', has_GMH_var( Hheader, 'GnotH', 'SSQ') ) );
      end
    end
  end
%   set( handles.btn_HScree_Plot, 'Enable', constant_define( 'STATE', xx ) );
% 
%   stats_btn = findobj( 'Tag', 'btn_GH_Stats' );
%   has_H = has_component_directory( 'H', 'GMH', 'GC' );
%   if ( has_H )
%     set( stats_btn, 'Enable', 'on' );
%   else
%     set( stats_btn, 'Enable', 'off' );
%   end
end





% --- Executes on button press in chk_subject_specific.
function chk_subject_specific_Callback(hObject, eventdata, handles)
% hObject    handle to chk_subject_specific (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Zheader scan_information

  scan_information.processing.model.process.subject_specific = get(hObject,'Value');
  save_headers();
  update_process_buttons( handles );
end




% --- Executes on button press in chk_user_covariants.
function chk_user_covariants_Callback(hObject, eventdata, handles)
% hObject    handle to chk_user_covariants (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Zheader scan_information

  scan_information.processing.subjects.process.user_covariants = get(hObject,'Value');

  if (   scan_information.processing.subjects.process.user_covariants )
    [fn, path] = uigetfile('*.txt', 'Select your covariant text file' );

    if ~isequal(fn,0) && ~isequal(path,0)
 
      fil = [path fn];     
      try
        x = load( fil, '-ASCII' );

        [r c] = size(x);
        if ( r ~= Zheader.total_scans )

          str = ['The number of lines loaded from the file ' fn ' do not match the scan count ( ' num2str(Zheader.total_scans) ').'];
          show_message( 'Scan Dimension Mismatch', str );

          scan_information.processing.subjects.process.user_covariants = 0;
          set( hObject, 'Value', 0 );
        else

          scan_information.processing.subjects.process.user_covariants_file = fil;
        end

      catch
        e=lasterror;
        show_message( 'File Read Error', e.message );

        scan_information.processing.subjects.process.user_covariants = 0;
        set( hObject, 'Value', 0 );
      end

%      scan_information.processing.subjects.process.user_covariants_file = [path fn];

    else
      scan_information.processing.subjects.process.user_covariants = 0;
      scan_information.processing.subjects.process.user_covariants_file = '';
      set( hObject, 'Value', 0 );
    end

  end

  save_headers();
end


function G_to_Gsegs( Gheader )
global Zheader 
  % -----------------------------------
  % --- did user select an existing G
  % -----------------------------------

  if Zheader.Model.mat_exists == 1 && ~strcmp( Zheader.Model.mat, 'Gheader' )

    if isempty( Gheader.path_to_segs ) 		% new G creation
      Gheader.path_to_segs = [ pwd filesep 'Gsegs' filesep];
    end

    x = exist( Gheader.path_to_segs, 'dir' );
    if ( x ~= 7 )  % --- the directory does not exist
      mkdir Gsegs;
    end

    if ( size(Zheader.conditions.encoded, 1) == Zheader.num_subjects  )	
      Gheader.subject_encoded = [];
      for  SubjectNo = 1:Zheader.num_subjects;
        Gheader.subject_encoded = [Gheader.subject_encoded sum( Zheader.conditions.encoded(SubjectNo).condition ) ];
      end
    end

    gsWidth = Gheader.bins * Gheader.conditions;
    G_SoS = zeros( 1, gsWidth );

    load( Zheader.Model.path, Zheader.Model.mat );

    startAt = 0;
    endAt = 0;
    startCol = 0;
    endCol = 0;

    GG = [];

    for SubjectNo = 1:Zheader.num_subjects

      for RunNo = 1:Zheader.num_runs

        % ----------------------------------
        % --- output filename will be [path]/Gsegs/G_S{subject number}_{run number}
        % ----------------------------------

        outfile = [ Gheader.path_to_segs 'G_S' num2str(SubjectNo) ];

        % ----------------------------------
        % --- Calculate the strating row/column ending row/columns of the subject/run in the current G
        % --- this is our raw G segemnt for this subject/run  
        % --- ( Graw - where n represents subject number without being an actual number to maintain consistancy
        % ----------------------------------

        startAt = endAt + 1;
%        endAt = startAt + sum(Zheader.timeseries.subject(SubjectNo).run(:,1) ) - 1;
        endAt = startAt + Zheader.timeseries.subject(SubjectNo).run(RunNo,1) - 1;
 
        startCol = endCol + 1;
        endCol = startCol + gsWidth - 1;

        eval( [ 'Graw = ' Zheader.Model.mat '( startAt:endAt, startCol:endCol );' ] );

        mn = mean(Graw);
   
        Gnorm = Graw;
        for jj = 1:size(Gnorm,2)
          Gnorm(:,jj) = Gnorm(:,jj)-mn(1,jj);
        end

        st = samp_dev( Gnorm );
        for jj = 1:size(Gnorm,2)
          Gnorm(:,jj) = Gnorm(:,jj) ./ st(1,jj);
        end

        % --- Calculate overall G sum of squares
        for ii = 1:size(Gnorm,2) 
          G_SoS(1,ii) = G_SoS(1,ii) + (Gnorm(:,ii)'*Gnorm(:,ii)); 
        end

        eval ( [ 'G_R' num2str(RunNo) ' = Gnorm;' ] );	% --=
        eval ( [ 'Gr' num2str(RunNo) ' = Graw;' ] );	% --=
        eval( [ 'save( ''' outfile '.mat'', ''Graw'', ''Gnorm'', ''Gr*'', ''G_R*'' )'] );

        % -------------------------------
        % --- per liang Wang Jan 2010
        % -------------------------------
        % --- Jun 1, 10  - G segment 1 contains the gg for full subject run
        % --- the full GG also in run 1 as GGs (GG for (s)ubject)
        % -------------------------------
        GG = Gnorm'*Gnorm;
        gg = sqrtm(pinv(GG));
        eval( [ 'save( ''Gsegs' filesep 'G_S' num2str(SubjectNo) '.mat'', ''GG'', ''gg'', ''-append'' )'] );
%      eval( [ 'save( ''' outfile '.mat'', ''GG'', ''gg'', ''-append'' )'] );

      end   % --- each Run  ---

    end   % --- each Subject  ---

    GGn = [];

    for  SubjectNo = 1:Zheader.num_subjects
      G = load_subject_G( Gheader, SubjectNo );
      GG = G' * G;
      if isempty(GGn) GGn = GG; else GGn = GGn + GG; end
     save( [ 'Gsegs' filesep 'G_S' num2str(SubjectNo) '.mat'], 'GG', '-append' );
    end
    GG = GGn;
    gg = sqrtm(pinv(GG));	% --= 
    save( ['Gsegs' filesep 'GG.mat'], 'GG', 'gg' );

  end  % --- G matrix in G file ---
end



% --- Executes on button press in chk_auto_cache.
function chk_auto_cache_Callback(hObject, eventdata, handles)

global process_information

  if ~process_information.sudo.confirmed
    process_information.sudo.confirmed = confirm_sudo_user_and_group( handles );
  end

  handles.auto_cache = get(hObject, 'Value' );
  set(hObject, 'Value', handles.auto_cache );

  guidata(hObject, handles);

  if handles.auto_cache

    handles.funcs.clear_cache = @clear_cache_memory;
    clear_cache_memory(1);
    update_process_buttons( handles );

  else

    handles.funcs.clear_cache = [];

  end

  guidata(hObject, handles);
  update_process_buttons( handles );
end



function conf = confirm_sudo_user_and_group( handles );
global process_information

  conf = 0;

  if size(process_information.sudo.user, 2) == 0 
    process_information.sudo.user = process_information.sudoUser;
    guidata(handles.MainDialog, handles);
  end

  if size(process_information.sudo.group, 2) == 0 
    process_information.sudo.group = process_information.sudoUser;
    guidata(handles.MainDialog, handles);
  end

  prompt = {'username:','group:'};
  def = {process_information.sudo.user, process_information.sudo.group};

  res = inputdlg(prompt,'Confirm User Name',1,def);
  if ~isempty( res )
    process_information.sudo.user = char(res{1});
    process_information.sudo.group = char(res{2});
    conf = 1;
    guidata(handles.MainDialog, handles);
  end
end



function clear_cache_memory( pop )
global process_information 

  if nargin < 1
    pop = [];  
  end
  if ~strcmp( class(pop), 'cpca_progress' )
    pop = []; 
  end

  % --- only clear the cache if above a certain percentage to avoid race conditions on FS
  x = check_memory();
  pct_cached = (x.user.cache/x.user.total ) * 100;

  if ( pct_cached > constant_define( 'PREFERENCES', 'general.cache_percent' ) )  % | isempty(pop) )
    if ~isempty(pop)
      comment = pop.getComment();
      pop.setComment( 'Clearing Cache' );
    end

    eval( '!sync' );
    evalc( ['!echo 3 | tee ' process_information.cache_buffer ] );

    if ~isempty(pop)
      pop.setComment( comment );
    end

  end
end


% --- Executes on button press in chk_subject_specific_rotated.
function chk_subject_specific_rotated_Callback(hObject, eventdata, handles)
% hObject    handle to chk_subject_specific_rotated (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Zheader scan_information

  scan_information.processing.model.process.subject_specific_rotated = get(hObject,'Value');
  save_headers();
  update_process_buttons( handles );
end


% --- Executes on button press in btn_create_resulting_imagery.
function btn_create_resulting_imagery_Callback(hObject, eventdata, handles)
% hObject    handle to btn_create_resulting_imagery (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Zheader scan_information;

  res = Images_From_Results( 'Zheader', Zheader );

  if ~isempty(res);
    y = find( res.selected_matrix );
    if ~isempty(y)
      vars = res.selected_variable(y);
      if ~isempty( vars)


              for ii = 1:size(vars,1)
                n = regexp( char( vars(ii) ), '\|', 'split' );
                var_prefix = char( n(3) );
                path_prefix = char( n(2) );
                path = char(n(1));

                perform_scan_image_output(path, var_prefix, path_prefix, res.base_directory );

              end  % --- for each defined variable

      end  % ---  variable names determined
    end  % ---  we have selected output
  end  % -- user pressed okay
end



function res = check_GZsegs_output( path )
global Zheader 

  d = dir( [path 'GE_S*'] );
  numGE = size(d,1);

  d = dir( [path 'GC_S*'] );
  numGC = size(d,1);

  res = ( numGE == Zheader.num_subjects ) || ( numGC == Zheader.num_subjects );
end



function perform_scan_image_output(path, file_prefix, path_prefix, dest )
global Zheader scan_information process_information 

  var_prefix = file_prefix;

% ---  handles.output.selected_variable = [ {'GE'} {'HEZ'} {'HEE'} {'GMHE'}; {'GC'} {'HBZ'} {'HBE'} {'GMH'} ];
% ---                                          E      E       E        ?       GC      HB     HB       ??
  if strcmp( var_prefix, 'GE' )  var_prefix = 'E';  end		% -- loading GC_R.. or E_R ...
%  if strcmp( file_prefix(1:2), 'HB' ) var_prefix = [ file_prefix(1:2)];  end

 
  if ( isa( handles.progressBar, 'cpca_progress' ) )
    handles.progressBar.setWindowTitle( 'Images from results' );
    handles.progressBar.setMessages( 'Creating scan images from:', [path_prefix ':' file_prefix ], '' );
    handles.progressBar.show();
  end

  for subjectNo = 1:Zheader.num_subjects

    grp = '';
    run = '';
    sbj = subject_id( subjectNo );
    ftag = '';

    handles.progressBar.setParticipant( subjectNo, Zheader.num_subjects, sbj );

    for FrequencyNo = 1:max(scan_information.frequencies, 1)
      ftag = frequency_tag(FrequencyNo) ;
      fdir = strrep( ftag, '_', '' );

      if scan_information.isMulFreq
        handles.progressBar.setFrequency( FrequencyNo, scan_information.frequencies, fdir );
      end
      
      for RunNo = 1:size( Zheader.timeseries.subject(subjectNo).run, 1 )

        handles.progressBar.setRun( RunNo, size( Zheader.timeseries.subject(subjectNo).run, 1 ) );


        % --- load in the variable for the subject / run
%        if strcmp( file_prefix, 'GE' ) || strcmp( file_prefix, 'GC' )

          r = Zheader.timeseries.subject(subjectNo).run(RunNo,1);

          eval( [ var_prefix '_R' num2str(RunNo) ftag '= zeros(r, Zheader.total_columns);' ] );

          start_col = 1;
          end_col = 1;
          for column = 1:size( Zheader.partitions.columns,2) 

            eval ( [ 'load( ''' path file_prefix '_S' num2str(subjectNo) '.mat'', ''' var_prefix '_R' num2str(RunNo) '_C' num2str(column) ftag ''');'] );
            eval( ['end_col = start_col + size( ' var_prefix '_R' num2str(RunNo) '_C' num2str(column) ftag ', 2 ) - 1;' ] );
            eval ( [ var_prefix '_R' num2str(RunNo) ftag '(1:' num2str(r) ',' num2str(start_col) ':' num2str(end_col) ') = ' var_prefix '_R' num2str(RunNo) '_C' num2str(column) ftag ';' ] );

            start_col = end_col + 1;
            eval( ['clear ' var_prefix '_R' num2str(RunNo) '_C' num2str(column) ftag ] );

          end 

%        else
%          eval ( [ 'load( ''' path file_prefix '_S' num2str(subjectNo) '.mat'', ''' var_prefix '_R' num2str(RunNo) ftag ''');'] );
%        end
        scans = 0;
        eval ( [ 'scans = size(' var_prefix '_R' num2str(RunNo) ftag ', 1);'] );

        if ( Zheader.num_runs > 1 )  run = ['run' num2str(RunNo)];  end

        str = scan_information.scandir_format;
        str = strrep( str, '{run_dir}', run );
        str = strrep( str, '{group_dir}', grp );
        str = strrep( str, '{frequency_dir}', fdir );
        str = strrep( str, '{subject_dir}', sbj );

        output_path = [ dest filesep 'images_from_' path_prefix filesep file_prefix filesep str filesep ];
        eval( ['mkdir ' output_path ] );

        handles.progressBar.setIterations( scans );
        for scanidx = 1:scans

          handles.progressBar.increment();

          scanno = sprintf( '_%04d', scanidx );
          filename = [var_prefix '_' char(scan_information.SubjectID(subjectNo)) run ftag scanno '.img' ] ;

          img = scan_information.mask; 
          img.image = zeros( prod( img.vol.dim ), 1);	% --- storage area for finale written image --
          eval( [ 'img.image( img.ind ) = ' var_prefix '_R' num2str(RunNo) ftag '(scanidx,:);' ] );	% --- placing data vector into proper positions of mask ---
          img.image = reshape( img.image ,img.vol.dim);	% --- and reshaping the result to the mask volume dimensions ---

          dtyp = cpca_data_type( 'double' ); 
          src_prec = dtyp.analyse; 
          if isempty( src_prec ) 
            src_prec = dtyp.nifti; 
          end % --= 
          if isBigendian()  en = 'LE'; else en = 'BE'; end 
          dtype = [src_prec '-' en]; 

          img.vol.dt = [dtyp.conversion isBigendian()];		% --- we default data type to signed double (float 64 )
          img.header.datatype = dtyp.conversion; 
          img.header.bitpix = dtyp.bits; 
          img.vol.fname = [output_path filesep filename]; 

          if isfield( img.header, 'scl_slope') 
            img.header.scl_slope = 1; 
          end 

          img.vol.pinfo(1) = 1; 
          img.vol.private.dat.dtype = dtype; 

          err = cpca_write_vols( img ); 
          if ( ~isempty( err ) )
            str = [ 'Image: ' img.vol.fname '<br>Error: ' err ];
            show_message( 'Error Writing Image', str );
            return;
          end

        end

      end  % --- each frequency

    end  % --- each run

  end % -- each subject

  handles.progressBar.hide();

  if size(process_information.sudo.user, 2) > 0 && process_information.sudo.confirmed == 1
    cmd = ['!chown -R ' process_information.sudo.user '.' process_information.sudo.group ' *' ];
    eval( cmd );
  end
end





% --- Executes on button press in chk_extract_gmh.
function chk_extract_gmh_Callback(hObject, eventdata, handles)
% hObject    handle to chk_extract_gmh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scan_information
  scan_information.processing.GMH_model.extract = get(hObject,'Value');
  save_headers();
end


% --- Executes on button press in chk_rotate_gmh.
function chk_rotate_gmh_Callback(hObject, eventdata, handles)
% hObject    handle to chk_rotate_gmh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scan_information 
  scan_information.processing.GMH_model.rotate = get(hObject,'Value');
  save_headers();
end


% --- Executes on button press in btn_Rotate_GMH_Settings.
function btn_Rotate_GMH_Settings_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Rotate_GMH_Settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scan_information

  sett = scan_information.processing.GMH_model.rotation;
  
  x = Rotation_Settings( 'Setting', sett, 'Title', 'GMH Rotation Settings', 'Model', 'H' );

  if ( isnumeric(x) )
    scan_information.processing.GMH_model.rotation = [];
    save_headers();
  else
    if (~ isempty( x ))
      scan_information.processing.GMH_model.rotation = x;
      save_headers();
    end
  end
end



% --- Executes on button press in btn_clr_rotations_gmh.
function btn_clr_rotations_gmh_Callback(hObject, eventdata, handles)
% hObject    handle to btn_clr_rotations_gmh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end


% --- Executes on button press in btn_GMH_options.
function btn_GMH_options_Callback(hObject, eventdata, handles)
% hObject    handle to btn_GMH_options (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Zheader scan_information 

  load( Zheader.Model.path, 'Gheader');
  if ~exist( 'Gheader', 'var' )
    return
  end

  load( Zheader.Limits.path);
  if ~exist( 'Hheader', 'var' )
    return
  end

  pthAdd = '';
  if Hheader.Hindex > 1   % --- the first level H is always on main directory
    if ~isempty( Hheader.model(Hheader.Hindex).id )
      pthAdd = [ Hheader.model(Hheader.Hindex).id filesep ];
      pthAdd = strrep( pthAdd, ' ', '_' );
    else
      pthAdd = ['H_' num2str(Hheader.Hindex, '%02d') filesep ];
    end
  end

  local_dir = [ 'Hsegs' filesep 'GMH' filesep pthAdd ];
  scan_information.processing.GMH_model.options.ow_flag = 0;


  fil = ['ZH_S' num2str( Zheader.num_subjects) '.mat' ];
  x = who_count( local_dir, fil, 'ZH_R*' );
  scan_information.processing.GMH_model.options.exists.ZH = ( x == (Zheader.num_runs + scan_information.frequencies ) );
  scan_information.processing.GMH_model.options.ow_flag = scan_information.processing.GMH_model.options.ow_flag || scan_information.processing.GMH_model.options.exists.ZH;

  fil = ['Qg_S' num2str( Zheader.num_subjects) '.mat' ];
  x = who_count( local_dir, fil, 'Qg_S*' );
  scan_information.processing.GMH_model.options.exists.Qg = ( x == Zheader.num_subjects );
  scan_information.processing.GMH_model.options.ow_flag = scan_information.processing.GMH_model.options.ow_flag || scan_information.processing.GMH_model.options.exists.Qg;

  FrequencyNo = max( 1, scan_information.frequencies);
  ftag = frequency_tag(FrequencyNo) ;

  fil = ['Qh_S' num2str( Hheader.model(Hheader.Hindex).partitions.count ) ftag '.mat' ];
  x = who_count( local_dir, fil, 'Qh_S*' );
  ex = Hheader.model(Hheader.Hindex).partitions.count * max(1, max( 1, scan_information.frequencies)) ;
  scan_information.processing.GMH_model.options.exists.Qh = ( x == ex );
  scan_information.processing.GMH_model.options.ow_flag = scan_information.processing.GMH_model.options.ow_flag || scan_information.processing.GMH_model.options.exists.Qh;

%   fil = ['Qg_S' num2str( Hheader.model(Hheader.Hindex).partitions.count ) ftag '.mat' ];
%   x = who_count( local_dir, fil, 'Qg_S*' );
%   ex = Hheader.model(Hheader.Hindex).partitions.count * max(1, max( 1, scan_information.frequencies)) ;
%   scan_information.processing.GMH_model.options.exists.Qg = ( x == ex );
%   scan_information.processing.GMH_model.options.ow_flag = scan_information.processing.GMH_model.options.ow_flag || scan_information.processing.GMH_model.options.exists.Qg;

  
  fil = ['GMH_S' num2str( Zheader.num_subjects) '.mat' ];
  x = who_count( local_dir, fil, 'GMH_R*' );
  scan_information.processing.GMH_model.options.exists.GMH = ( x == Hheader.model(Hheader.Hindex).partitions.count * Zheader.num_runs * max(scan_information.frequencies, 1) );
  scan_information.processing.GMH_model.options.ow_flag = scan_information.processing.GMH_model.options.ow_flag || scan_information.processing.GMH_model.options.exists.GMH;


  fil = ['BH_S' num2str( Zheader.num_subjects) '.mat' ];
  x = who_count( local_dir, fil, 'BH_R*' );
  scan_information.processing.GMH_model.options.exists.BH = ( x == Hheader.model(Hheader.Hindex).partitions.count * Zheader.num_runs * max(scan_information.frequencies, 1) );
  scan_information.processing.GMH_model.options.ow_flag = scan_information.processing.GMH_model.options.ow_flag || scan_information.processing.GMH_model.options.exists.BH;

  fil = ['GC_S' num2str( Zheader.num_subjects) '.mat' ];
  x = who_count( local_dir, fil, 'GC_R*' );
  scan_information.processing.GMH_model.options.exists.GC = ( x == Hheader.model(Hheader.Hindex).partitions.count * Zheader.num_runs * max(scan_information.frequencies, 1) );
  scan_information.processing.GMH_model.options.ow_flag = scan_information.processing.GMH_model.options.ow_flag || scan_information.processing.GMH_model.options.exists.GC;

  fil = ['E_S' num2str( Zheader.num_subjects) '.mat' ];
  x = who_count( local_dir, fil, 'E_R*' );
  scan_information.processing.GMH_model.options.exists.E = ( x == Hheader.model(Hheader.Hindex).partitions.count * Zheader.num_runs * max(scan_information.frequencies, 1) );
  scan_information.processing.GMH_model.options.ow_flag = scan_information.processing.GMH_model.options.ow_flag || scan_information.processing.GMH_model.options.exists.E;

  x = GMH_options( 'Vals', scan_information.processing.GMH_model.options );
  if ~isempty(x)
    scan_information.processing.GMH_model.options = x;
    
  scan_information.processing.GMH_model.apply = ...
    ( scan_information.processing.GMH_model.options.GMH.regress || ...
      scan_information.processing.GMH_model.options.BH.regress || ...
      scan_information.processing.GMH_model.options.GC.regress || ...
      scan_information.processing.GMH_model.options.GC.write ); 

  scan_information.processing.GMH_model.extract = ...
    ( scan_information.processing.GMH_model.options.GMH.extract || scan_information.processing.GMH_model.subject_specific || ...
      scan_information.processing.GMH_model.options.BH.extract || scan_information.processing.GMH_model.options.GC.extract);

  scan_information.processing.GMH_model.rotate =  ...
    ( scan_information.processing.GMH_model.options.GMH.rotate || scan_information.processing.GMH_model.subject_specific_rotated || ...
      scan_information.processing.GMH_model.options.BH.rotate || scan_information.processing.GMH_model.options.GC.rotate);
    
    save_headers();
  update_process_buttons( handles );
  end
end


% --- Executes on button press in btn_clearG.
function btn_clearG_Callback(hObject, eventdata, handles)
% hObject    handle to btn_clearG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Zheader scan_information 

  handles.funcs.clear_model();
  scan_information.processing.model.process.apply_g = 0;

  save_headers();
  update_process_buttons( handles );
end

function clear_model()
global Zheader
	Zheader.Model.file_exists = 0;
	Zheader.Model.path = '';
	Zheader.Model.mat_exists = 0;
	Zheader.Model.mat= '';
	Zheader.Model.mat_x = 0;
	Zheader.Model.mat_y = 0;
	Zheader.Model.hdr_exists = 0;

end
% --- Executes on button press in button_reset_fs_permission.
function button_reset_fs_permission_Callback(hObject, eventdata, handles)
% hObject    handle to button_reset_fs_permission (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global process_information

  if size(process_information.sudo.user, 2) > 0 && process_information.sudo.confirmed == 1
    cmd = ['!chown -R ' process_information.sudo.user '.' process_information.sudo.group ' *' ];
    eval( cmd );
  end
end


% --- Executes on button press in btn_user_settings.
function btn_user_settings_Callback(hObject, eventdata, handles)
% hObject    handle to btn_user_settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global  process_information

x = user_settings();
if ~isempty(x)
  user_options = x;

  optmat = [ constant_define( 'CONFIG_PATH' ) constant_define( 'CONFIG_FILE' ) ];
  eval( ['v_' constant_define( 'VERSION_NUMBER' ) ' = 1;' ] );          
  
  eval( [ 'save( ''' optmat ''', ''v_*'', ''user_options'' ); '] );
  if size(process_information.sudo.user, 2) > 0 && process_information.sudo.confirmed == 1
    cmd = ['!chown -R ' process_information.sudo.user '.' process_information.sudo.group ' ' optmat ];
    eval( cmd );
  end

  update_process_buttons( handles );

end
end

  


% --- Executes on button press in chk_GMH_Resume.
function chk_GMH_Resume_Callback(hObject, eventdata, handles)
% hObject    handle to chk_GMH_Resume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scan_information

% Hint: get(hObject,'Value') returns toggle state of chk_GMH_Resume
  scan_information.processing.GMH_model.applied.resume = get( hObject, 'Value' );
  save_headers();
end


% --- Executes on button press in chk_gmh_subject_specific.
function chk_gmh_subject_specific_Callback(hObject, eventdata, handles)
% hObject    handle to chk_gmh_subject_specific (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Zheader scan_information

  scan_information.processing.GMH_model.subject_specific = get(hObject,'Value');
  save_headers();
  update_process_buttons( handles );
end


% --- Executes on button press in chk_gmh_subject_specific_rotated.
function chk_gmh_subject_specific_rotated_Callback(hObject, eventdata, handles)
% hObject    handle to chk_gmh_subject_specific_rotated (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Zheader scan_information

  scan_information.processing.GMH_model.subject_specific_rotated = get(hObject,'Value');
  save_headers();
  update_process_buttons( handles );
end


% ---  Active when selected mask has calulated MNI/Talairach values
% ---  Allows user selectioon of brain regions by Talairach description
% ---  into a final H matrix, each column of H a singular Talairach Atlas
% ---  brain region
% ---
% --- Executes on button press in Btn_createH.
function Btn_createH_Callback(hObject, eventdata, handles)
% hObject    handle to Btn_createH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Zheader scan_information 

  H_var = '';
  h_okay =  0;
  Hindex = 1;  
 
  Hm = create_h();
  if ~isempty( Hm )
      
    Hheader = structure_define( 'HHEADER' );
    Hheader.model(Hheader.Hindex) = Hm;
    
    % H will need to be partitioned by frequency if beamformed data 
    Hheader.model(Hheader.Hindex).partitions = calc_Qh_Blocksize( Zheader.total_columns, constant_define( 'PARTITION_MAX' ) );

    x = who_stats( Hheader.model(Hheader.Hindex).path, Hheader.model(Hheader.Hindex).file, 'HRegions');

    Zheader.Limits.path = [pwd filesep 'Hheader.mat' ];
    Zheader.Limits.hdr_exists = 1;
    Zheader.Limits.mat_exists = 1;                % --- dialog would not return if it did not
    if Hheader.model(Hheader.Hindex).size(1) == Zheader.total_columns
      A = Hheader.model(Hheader.Hindex).size;
    else
      A = sort( Hheader.model(Hheader.Hindex).size, 'descend' );
    end
      
    Zheader.Limits.mat_x = A(1);                  % --- note: x,y diplay may be swapped from actual orientation
    Zheader.Limits.mat_y = A(2);		  % --- always reorient from actual orientation from Hheader.size
    Zheader.Limits.mat = Hheader.model(Hheader.Hindex).var;

    if isempty( Hheader.model( Hheader.Hindex ).id )
      Hheader.model( Hheader.Hindex ).id = Hheader.model( Hheader.Hindex ).var;
    end
    
    save( Zheader.Limits.path, 'Hheader');
    
    lst = [];

    if ~isempty( Hheader.model(Hheader.Hindex).id )
      lst = [lst; {Hheader.model(Hheader.Hindex).id}];
    else
      lst = [lst; {['H ' num2str(Hheader.Hindex)]}];
    end
                 
    set( handles.lst_H, 'String', lst, 'Value', Hheader.Hindex );
    
  end

  calc_gaz_extents();  
  save_headers();
  update_process_buttons( handles );

  
  % Update handles structure  
  guidata(hObject, handles);
  
end



% --- function to calculate MNI positions for all voxels
% --- in mask, as well as Talairach label index for H creation process
% --- 
% --- Executes on button press in btn_MNI.
function btn_MNI_Callback(hObject, eventdata, handles)
% --- formerly, this activate a talairach MNI coordinate calculation
% --- which has been abandoned.  A revised Harvard Oxford Atlas is now
% --- used.
% ---  
% --- Included is a mask which separates white and gray matter, ventricles, 
% --- Brain stem and cerebellum.  ( the latter is incorporated from an 
% --- FSL Atlas, and is somewhat fuzzy
% --- 
% --- If the current mask does not contain this separation, this button
% --- will display, and allow a re-creation of the present mask that has the
% --- bits set to the appropriate labels for separation if required.

global Zheader scan_information 


  msk = scan_information.mask;
%  msk.MNI = MNI_coords( msk );

  handles.progressBar.setMessages(  'Registering Mask',sprintf('%d voxels', numel( msk.ind ) ), '' );
  handles.progressBar.clearParticipant();
  handles.progressBar.clearRun();
  handles.progressBar.clearFrequency();
  handles.progressBar.setIterations( numel( msk.ind ) );
  handles.progressBar.show();
  
  load( constant_define( 'MNI_1MM_MASK_REV' ) );

  Yval = msk.MNI(2, msk.ind(1) );
  Yaxis = find( HO_template.MNI(2,:) == Yval );

  for voxel = 1:numel( msk.ind )

    if msk.MNI(2, msk.ind(voxel)) ~= Yval 
      Yval = msk.MNI(2, msk.ind( voxel ) );
      Yaxis = find( HO_template.MNI(2,:) == Yval );
    end

    x = find( HO_template.MNI(1,Yaxis) == msk.MNI(1, msk.ind( voxel )) );
    z = find( HO_template.MNI(3, Yaxis(x)) == msk.MNI(3,msk.ind( voxel )) );
        
    if numel(z) == 1
      msk.image(msk.ind( voxel ) ) = HO_template.image( Yaxis(x(z)) );
    end
 
    handles.progressBar.increment();    
  
  end

  msk.ind = find( msk.image );
  VR = msk.image( msk.ind(:) );
  write_cpca_image( '', 'registered_mask.img', VR, msk );

  handles.progressBar.hide();  
  show_message( 'Registered Mask Create', ...
      ['The registered mask has been created in the current working directory: ' ...
      '  <b>registered_mask.img</b><br>You will need to reselect your mask to activate it.' ]);

end



function load_talairach_from_anlysis()
% --- load in the mask.tal_info data from an existing analysis
global scan_information

% --- todo: turn this into a dialog select showing mask info

  btn_MNI_Callback(0, 0, handles)
  return
end

  


% --- Executes on selection change in lst_H.
function lst_H_Callback(hObject, eventdata, handles)
% hObject    handle to lst_H (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Zheader

%   mdl = [{'ZH'}; {'EH'}; {'GMH'}; {'BH'}; {'GC'}];
  
  load( Zheader.Limits.path );
  Hheader.Hindex = get( hObject, 'Value' );
  
  x = array_sizes( Hheader.model(Hheader.Hindex).size );
  strsz = sprintf( '%d x %d', Hheader.model(Hheader.Hindex).size(1), Hheader.model(Hheader.Hindex).size(2) );
  strsz = [ strsz ' [' strtrim( x.mem_display ) '] ' ];
      
  strsz = [ strsz ' (' Hheader.model(Hheader.Hindex).file ') ' ];
  h = findobj('Tag','lbl_HExtents');
  set( h, 'String', strsz );
  
  save( Zheader.Limits.path, 'Hheader' );
  update_process_buttons( handles );
end
  
  

% --- Executes during object creation, after setting all properties.
function lst_H_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_H (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function set_H_scree_stat_buttons( mode, Hheader )

  xx = regexp( mode, ':', 'split' );
  if ( size(xx,2) > 1 )
    mdl = char(xx(1) );
    fil = char(xx(2) );
  else
    fil = char(xx );
    if size(mode, 2) > 1     % -- ZH or EH
      mdl = char(fil(2));
    else
      mdl = char(fil(1));
    end
  end

  scree_btn = findobj( 'Tag', 'btn_HScree_Plot' );
  state = 'off';
  set( scree_btn, 'Enable', 'off' );

  stats_btn = findobj( 'Tag', 'btn_GH_Stats' );
  x = 0;
  set( stats_btn, 'Enable', 'off' );
  
%  xx = check_C_Eigenvalues( mode );
  if strcmp( mdl, 'GMH' )
    xx =  has_GMH_var( Hheader, fil, 'C_Eigenvalues' );
  else
   xx =  has_H_var( Hheader, fil, 'C_Eigenvalues' );
  end;  

  if ( xx ) state = 'on'; end

  h = findobj( 'Tag', ['btn_view_' fil] );
  set( h, 'Enable', state );
  x = get( h, 'Value');
  switch (x)
    case 0   % toggle is up
       set( h, 'BackgroundColor', constant_define( 'COLOR_GREY' ) );
    case 1  % toggle is down
       set( h, 'BackgroundColor', constant_define( 'COLOR_GREEN' ) );

%       xx = check_C_Eigenvalues( 'ZH');
       if ( xx ) 
         set( scree_btn, 'Enable', state );  
       end

       has_H = has_component_directory( 'H', mdl, fil );
       if ( has_H )
         set( stats_btn, 'Enable', 'on' );
       end


  end

end
  


% --- Executes on button press in btn_regress_G_settings.
function btn_regress_G_settings_Callback(hObject, eventdata, handles)
% hObject    handle to btn_regress_G_settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scan_information Zheader

  x = G_Regression_Resumption('settings', scan_information.processing.model.applied.resume_g, 'subjects', Zheader.num_subjects );
  if ~isempty( x )
    scan_information.processing.model.applied.resume_g = x;
    save_headers();
  end;
  
end


% --- Executes on button press in btn_extraction_svd_bypass.
function btn_extraction_svd_bypass_Callback(hObject, eventdata, handles)
% hObject    handle to btn_extraction_svd_bypass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scan_information

 x = G_SVD_Process_Settings( 'ext', scan_information.processing.model.process.components, ...
                             'svd', scan_information.processing.model.process.svd);

 if ~isempty(x)
   scan_information.processing.model.process.components = x.ext;
   scan_information.processing.model.process.svd = x.svd;
   save_headers();
   update_process_buttons( handles );
end
end


% --- Executes on button press in btn_Residual.
function btn_Residual_Callback(hObject, eventdata, handles)
% --- calculate E matrix and preserve in subdirectoy 'Residual' as
% --- a complete Z matrix, with current mask and Z directory for
% --- application of a new G matrix
global Zheader 

  load( Zheader.Model.path, 'Gheader' );
      
  model = 'G';
  if isChecked( handles.chk_apply_ga )
    model = 'GA';
  end;

  if isChecked( handles.chk_apply_gaa )
    model = 'GAA';
  end;
  
  create_residual_as_Z( model, handles.progressBar );
  update_process_buttons( handles );

end


% --- Executes on button press in btn_Residual_Images.
function btn_Residual_Images_Callback(hObject, eventdata, handles)
% --- calculate E matrix and preserve in subdirectoy 'Residual_Images' as
% --- a complete scanner image collection
global Zheader scan_information

  load( Zheader.Model.path, 'Gheader' );
      
  model = 'G';
  if isChecked( handles.chk_apply_ga )
    model = 'GA';
  end;

  if isChecked( handles.chk_apply_gaa )
    model = 'GAA';
  end;

  create_residual_as_Images(model, handles.progressBar);
  update_process_buttons( handles );

end


% --- Executes on selection change in lst_GROI.
function lst_GROI_Callback(hObject, eventdata, handles)

  x = get( hObject, 'Value' );
  if x
    load G_ROI
    G_ROI.Rindex = x;
    save G_ROI G_ROI
  end;

  update_process_buttons( handles );
  
end


% --- Executes during object creation, after setting all properties.
function lst_GROI_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_GROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


% --- Executes on button press in btn_GROI_Select.
function btn_GROI_Select_Callback(hObject, eventdata, handles, addme)
global Zheader scan_information

  if nargin < 4
    addme = 0;
  end

  newmask = G_ROI_Selection();
  if isempty( newmask )
    return;
  end
  
  if ~exist( 'ROI', 'dir' )
    mkdir ROI
  end;
  
  if ~exist( ['ROI' filesep 'data' ], 'dir' )
    mkdir( ['ROI' filesep 'data' ] );
  end;
 
  if addme
    load G_ROI
    if exist( 'G_ROI', 'var' );
      G_ROI.mask = [ G_ROI.mask; newmask.mask];
    else
      G_ROI = newmask;
    end
    
  else
    G_ROI = newmask;
  end;
  G_ROI.Rindex = size( G_ROI.mask, 1 );
  
  [p fn] = split_path( G_ROI.mask(G_ROI.Rindex).image, filesep );
  G_ROI.mask(G_ROI.Rindex).path = ['ROI' filesep 'data' filesep ] ;
  G_ROI.mask(G_ROI.Rindex).file = [ 'ROI_' num2str( G_ROI.Rindex, '%02d' ), '_' G_ROI.mask(G_ROI.Rindex).id ];
  G_ROI.mask(G_ROI.Rindex).file = strrep( G_ROI.mask(G_ROI.Rindex).file, ' ', '_' );
  
  here = strrep( G_ROI.mask(G_ROI.Rindex).image, '.img', '.*' );
  copyfile( here, G_ROI.mask(G_ROI.Rindex).path, 'f' );

  % --- create and save indexes for mask
  msk = cpca_read_vol( G_ROI.mask(G_ROI.Rindex).image );

  Gindex = zeros(size(msk.ind,1), 1 );
  Tindex = zeros(size(msk.ind,1), 1 );
  Zindex = [1:size(scan_information.mask.ind,1)];
  
  NEW.mask = scan_information.mask;
  
  for ii = 1:size(msk.ind,1)
    mi = find( scan_information.mask.ind == msk.ind(ii) );
    if size(mi,1) == 1
      Gindex(ii) = mi; 
      if ~isempty(scan_information.mask.tal_index) 
        Tindex(ii) =  scan_information.mask.tal_index(mi,1); 
      end;
      Zindex(mi) = 0;
      NEW.mask.image( msk.ind(ii) ) = 0;
    end;
  end;
  
  x = find( Zindex );
  y = Zindex( x(:) );
  Zindex = y';

  NEW.mask.ind = find( NEW.mask.image );
  NEW.mask.file = [ G_ROI.mask(G_ROI.Rindex).path G_ROI.mask(G_ROI.Rindex).file ];
  NEW.mask.x = size( NEW.mask.ind, 1 );


  VR = ones( size(NEW.mask.ind) );
  write_cpca_image( G_ROI.mask(G_ROI.Rindex).path, [G_ROI.mask(G_ROI.Rindex).file '.img'] , VR, NEW.mask )

  save( [G_ROI.mask(G_ROI.Rindex).path G_ROI.mask(G_ROI.Rindex).file],  'Gindex', 'Tindex', 'Zindex', '-v7.3' );
  
  save G_ROI G_ROI

  if exist('G_ROI.mat', 'file' )
    load G_ROI
  end;
  
  lst = [];
  if exist( 'G_ROI', 'var' )

    if isfield( G_ROI, 'mask' )
      for ii = 1:size( G_ROI.mask, 1)
        if ~isempty( G_ROI.mask(ii).id )
          lst = [lst; {G_ROI.mask(ii).id}];
        else
          lst = [lst; {['G ROI ' num2str(ii)]}];
        end
                 
      end
    else
      lst = {['G ROI ' num2str(ii)]};
    end

    set( handles.lst_GROI, 'String', lst, 'Value', G_ROI.Rindex );
    
  end

  update_process_buttons( handles );
  
end

% --- Executes on button press in btn_GROI_Add.
function btn_GROI_Add_Callback(hObject, eventdata, handles)
global Zheader scan_information 
  
  % Update handles structure  
  guidata(hObject, handles);
  btn_GROI_Select_Callback(hObject, eventdata, handles, 1);
 

end


% --- Executes on button press in lbl_GROI.
function lbl_GROI_Callback(hObject, eventdata, handles)
  n = get( hObject, 'Value' );
  if n
    set( hObject, 'BackgroundColor', constant_define( 'COLOR_GREEN' ) );
  else
    set( hObject, 'BackgroundColor', constant_define( 'COLOR_GREY' ) );
  end
  update_process_buttons( handles );

end


% --- Executes on button press in btn_GROI_Estimate.
function btn_GROI_Estimate_Callback(hObject, eventdata, handles)
% hObject    handle to btn_GROI_Estimate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Zheader

  load( Zheader.Model.path, 'Gheader' );
  SoS =  regress_ROI( handles.funcs, Gheader, handles.progressBar );

  update_process_buttons( handles );

end



function txt_GROI_num_voxels_Callback(hObject, eventdata, handles)
end


% --- Executes during object creation, after setting all properties.
function txt_GROI_num_voxels_CreateFcn(hObject, eventdata, handles)

  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end
end


% --- Executes on button press in btn_GROI_Finalize.
function btn_GROI_Finalize_Callback(hObject, eventdata, handles)

  nd = get( handles.txt_GROI_num_voxels, 'String' );
  n = finalize_ROI( handles.funcs, str2num(nd), handles.progressBar );

end



% --- Executes on selection change in lst_A.
function lst_A_Callback(hObject, eventdata, handles)
global Zheader

  load( Zheader.Contrast.path );
  Aheader.Aindex = get( hObject, 'Value' );
  
  save( Zheader.Contrast.path, 'Aheader' );
  update_process_buttons( handles );

end


% --- Executes during object creation, after setting all properties.
function lst_A_CreateFcn(hObject, eventdata, handles)

  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end
  
end



function update_process_buttons( handles )

   update_system_buttons( handles );
   update_subject_buttons( handles );
   update_mask_buttons( handles );
   update_model_buttons( handles );
   update_process_panel( handles );
   
end

function update_system_buttons( handles )
   x = defined_rule( 'Activations', 'Main GUI: System Panel', {} );
   
   set( handles.btn_view_log,               'Enable', constant_define( 'STATE', x.vars.viewLog ) );
   set( handles.btn_user_settings,          'Enable', constant_define( 'STATE', x.vars.options ) );
   set( handles.btn_clear_cache,            'Enable', constant_define( 'STATE', x.vars.cache ) );
   set( handles.chk_auto_cache,             'Enable', constant_define( 'STATE', x.vars.autocache ) );
   set( handles.btn_DebugData,              'Enable', constant_define( 'STATE', x.vars.utils ) );
   set( handles.button_reset_fs_permission, 'Enable', constant_define( 'STATE', x.vars.fixFS ) );
   set( handles.btn_FileList,               'Enable', constant_define( 'STATE', x.vars.createList ) );
   set( handles.btn_ChangeDirectory,        'Enable', constant_define( 'STATE', x.vars.cd ) );
   set( handles.btn_UnloadData,             'Enable', constant_define( 'STATE', x.vars.unload ) );
   set( handles.btn_PerformCPCA,            'Enable', constant_define( 'STATE', x.vars.run ) );
   
   update_system_panel_data( handles );
end


function update_subject_buttons( handles )

   x = defined_rule( 'Activations', 'Main GUI: Subject Panel', {} );

   set( handles.SubjectSelect,              'Enable', constant_define( 'STATE', x.vars.select ) );
   set( handles.btn_EditZ0,                 'Enable', constant_define( 'STATE', x.vars.info ) );
   set( handles.btn_verify_scans,           'Enable', constant_define( 'STATE', x.vars.verify ) );

   update_subject_panel_data( handles );
   
end

function update_mask_buttons( handles )

  x = defined_rule( 'Activations', 'Main GUI: Mask Panel', {} );

  set( handles.btn_SelectMask,             'Enable', constant_define( 'STATE', x.vars.select ) );
  set( handles.btn_Select_ROI,             'Enable', constant_define( 'STATE', x.vars.roi ) );
  set( handles.btn_create_mask,            'Enable', constant_define( 'STATE', x.vars.create ) );
  set( handles.btn_mask_verify,            'Enable', constant_define( 'STATE', x.vars.verify ) );
   
  set( handles.btn_MNI,                    'Enable', constant_define( 'STATE', x.vars.register ) );
  set( handles.btn_MNI,                    'Visible', constant_define( 'STATE', x.vars.register ) );
   
  set( handles.txt_MaskDimensions,         'Visible', constant_define( 'STATE', x.vars.verify ) );

  update_mask_panel_data( handles );
   
   
end

function update_model_buttons( handles )
global Zheader scan_information

   s = get( handles.NumComp_GA, 'String' );
   x = str2num(s);
   nd = num2str(x(1));
   
   x = defined_rule( 'Activations', 'Main GUI: Model Panel', {}, 0 );
   GROI_Active = isChecked( handles.lbl_GROI );
   
   set( handles.btn_clearG,                 'Visible', constant_define( 'STATE', x.vars.clr ) );
   set( handles.btn_clearG,                 'Enable', constant_define( 'STATE', x.vars.clr ) );
   set( handles.btn_createG,                'Enable', constant_define( 'STATE', x.vars.gcreate ) );
   set( handles.btn_SelectG,                'Enable', constant_define( 'STATE', x.vars.gselect ) );
   set( handles.btn_Gheader_Info,           'Enable', constant_define( 'STATE', x.vars.edit ) );
   set( handles.btn_Scree_Plot,             'Enable', constant_define( 'STATE', x.vars.scree ) );
   set( handles.btn_G_Stats,                'Enable', constant_define( 'STATE', x.vars.stats) );

   set( handles.Btn_SelectA,                'Enable', constant_define( 'STATE', x.vars.aselect * ~GROI_Active) );
   set( handles.btn_addA,                   'Enable', constant_define( 'STATE', x.vars.aadd * ~GROI_Active) );
   set( handles.lst_A,                      'Enable', constant_define( 'STATE', x.vars.aselect * ~GROI_Active ) );

   %GROI Toggle: currently, set visibilty off if GROI not enabled

   if isfield( x.vars, 'r_state' )
     set( handles.lbl_GROI,                   'Visible', constant_define( 'STATE', x.vars.r_state ) );
     set( handles.btn_GROI_Select,            'Visible', constant_define( 'STATE', x.vars.r_state ) );
     set( handles.btn_GROI_Add,               'Visible', constant_define( 'STATE', x.vars.r_state ) );
     set( handles.lst_GROI,                   'Visible', constant_define( 'STATE', x.vars.r_state ) );
     set( handles.lbl_GROI_num_voxels,        'Visible', constant_define( 'STATE', x.vars.rscree * GROI_Active) );
     set( handles.txt_GROI_num_voxels,        'Visible', constant_define( 'STATE', x.vars.rscree * GROI_Active) );
     set( handles.btn_GROI_Scree,             'Visible', constant_define( 'STATE', x.vars.rscree * GROI_Active ) );
     set( handles.btn_GROI_images,            'Visible', constant_define( 'STATE', x.vars.rimages * GROI_Active ) );
   end
   
   set( handles.lbl_GROI,                   'Enable', constant_define( 'STATE', x.vars.groi ) );
   set( handles.btn_GROI_Select,            'Enable', constant_define( 'STATE', x.vars.rselect ) );
   set( handles.btn_GROI_Add,               'Enable', constant_define( 'STATE', x.vars.radd ) );
   set( handles.lst_GROI,                   'Enable', constant_define( 'STATE', x.vars.rselect ) );
   set( handles.lbl_GROI_num_voxels,        'Enable', constant_define( 'STATE', x.vars.radd * GROI_Active) );
   set( handles.txt_GROI_num_voxels,        'Enable', constant_define( 'STATE', x.vars.radd * GROI_Active) );
   set( handles.btn_GROI_Scree,             'Enable', constant_define( 'STATE', x.vars.rscree * GROI_Active ) );
   set( handles.btn_GROI_images,            'Enable', constant_define( 'STATE', x.vars.rimages * GROI_Active ) );
               
   set( handles.Btn_SelectH,                'Enable', constant_define( 'STATE', x.vars.hselect * ~GROI_Active ) );
   set( handles.btn_addH,                   'Enable', constant_define( 'STATE', x.vars.hadd * ~GROI_Active ) );
   set( handles.Btn_createH,                'Enable', constant_define( 'STATE', x.vars.hcreate * ~GROI_Active ) );
   set( handles.lst_H,                      'Enable', constant_define( 'STATE', x.vars.hselect * ~GROI_Active ) );
 

%    set( handles.Btn_createH,                'Enable', constant_define( 'STATE', 0 ) );
%    set( handles.Btn_createH,                'Visible', constant_define( 'STATE', 0 ) );

   set( handles.btn_view_ZH,                'Enable', constant_define( 'STATE', x.vars.ZH * ~GROI_Active ) );
   set( handles.btn_view_EH,                'Enable', constant_define( 'STATE', x.vars.EH * ~GROI_Active ) );
   set( handles.btn_view_GMH,               'Enable', constant_define( 'STATE', x.vars.GMH * ~GROI_Active ) );
   set( handles.btn_view_BH,                'Enable', constant_define( 'STATE', x.vars.HnotG * ~GROI_Active ) );
   set( handles.btn_view_GC,                'Enable', constant_define( 'STATE', x.vars.GnotH * ~GROI_Active ) );
 
   set( handles.lbl_GExtents,               'Enable', constant_define( 'STATE', x.vars.gselect ) );
   update_model_panel_data( handles );


end


function update_process_panel( handles )

  x = defined_rule( 'Activations', 'Main GUI: Process Panel', {} );

  roi = isChecked( handles.lbl_GROI );
  
  set( handles.btn_run_subject_process,      'Enable', constant_define( 'STATE', x.vars.Z ) );
  set( handles.btn_run_ga_process,           'Enable', constant_define( 'STATE', x.vars.GA ) );
  set( handles.btn_run_h_process,            'Enable', constant_define( 'STATE', x.vars.BH * ~roi ) );
  set( handles.btn_run_gmh_process,          'Enable', constant_define( 'STATE', x.vars.GMH * ~roi ) );
  
  set_Z_process_substates( handles );
  set_G_process_substates( handles );
  set_H_process_substates( handles );
   
  set( handles.btn_Residual,                 'Enable', constant_define( 'STATE', x.vars.ResZ ) );
  set( handles.btn_Residual,                 'Visible', constant_define( 'STATE', x.vars.ResZ ) );
  set( handles.btn_Residual_Images,          'Enable', constant_define( 'STATE', x.vars.ResZ ) );
  set( handles.btn_Residual_Images,          'Visible', constant_define( 'STATE', x.vars.ResZ ) );
  
end



function update_system_panel_data( handles )
global Zheader scan_information process_information

  memory = check_memory();
  
  % --- cache
  pct_cached = (memory.user.cache/memory.user.total ) * 100;

  bgcolor = constant_define( 'COLOR_GREY' );		% normal background
  if ( isunix() && ~ismac() ) 
    if ( memory.user.cache < 100 )
      str = sprintf( 'Cache: %.02f MB', memory.user.cache );
    else
      str = sprintf( 'Cache: %.02f GB', memory.user.cache/1000 );
    end

    if pct_cached > 40
      bgcolor = constant_define( 'COLOR_YELLOW' );			% yellow background ( caution )
      if ( pct_cached > 80 )
        bgcolor = constant_define( 'COLOR_ORANGE' );		% orange background ( critical )
      else
        if ( pct_cached > 90 )
          bgcolor = constant_define( 'COLOR_RED' );         % red background ( your screwed )
        end
      end

    end

    set( handles.btn_clear_cache, 'String', str );

  end

  set(handles.btn_clear_cache,'BackgroundColor',bgcolor);

  % --- available memory
  mem_max = memory.user.free;
  if ( Zheader.memory_limit > 0 )
    mem_max = Zheader.memory_limit*1000;
  end

  if ( mem_max < 500 )
    str = sprintf( '%.02f MB', mem_max );
  else
    str = sprintf( '%.02f GB', mem_max/1000 );
  end

  set(handles.txt_AvailMem,'String',str);

  err_tip = '';			% text to be placed as tool tip defining what memory issues are

  if exist( 'Zheader', 'var' )

    max_reqd = 0;

    if ( ~isempty( Zheader.ts_vector ) )
      user_mem = array_sizes( [ max(Zheader.ts_vector) Zheader.partitions.width ] );
      err_tip = 'Amount of required memory to normalize data';			

      if ( ~isempty( Zheader.Model.path ) )
        B_mem = array_sizes( [ Zheader.Model.mat_y Zheader.total_columns] );
        max_reqd = max( user_mem.megabytes, B_mem.megabytes );
        str = strtrim( B_mem.mem_display );
        err_tip = 'Amount of required memory to apply model to data';			
      else
        max_reqd = user_mem.megabytes;
        str = strtrim( user_mem.mem_display );
      end

    else
      str = 'N/A';
    end

  else
    str = 'N/A';
  end

  fwgt = 'normal';			% normal font
  bgcolor = constant_define( 'COLOR_GREY' );		% normal background
  if exist( 'Zheader', 'var' )

    dp = max_reqd / mem_max * 100;
    if ( dp >= 80 )
      bgcolor = constant_define( 'COLOR_YELLOW' );			% yellow background ( caution )
      fwgt = 'bold';			% bold font

      if ( dp > 90 )
        bgcolor = constant_define( 'COLOR_ORANGE' );		% orange background ( critical )
      end

      if ( dp > 98 )
        bgcolor = constant_define( 'COLOR_RED' ) ;		% red background ( your screwed )
      end
    end

  end

  set(handles.txt_CachedMem,'String',str);
  set(handles.txt_CachedMem,'BackgroundColor',bgcolor);
  set(handles.txt_CachedMem,'FontWeight',fwgt);
  set(handles.txt_CachedMem,'TooltipString',err_tip);

  str = sprintf( '%d', constant_define( 'PARTITION_MAX' ) );
  set(handles.txt_MaxPartitionmem,'String',str);


  set_estimated_run_time( handles );

  
 % --- devices 

  sys = [ {'_pc'} {'_mac'} {'_nix'} ];
  idx = find( [ispc() ismac() isunix() ] );
  command = sprintf( 'drive_specs = drive_space%s();', char(sys(idx(1))));
  eval( command );

  if ( drive_specs.free > 0 )
    str = sprintf( '%.1f GB', drive_specs.free/1000 );
  else
    str = 'N/A';
  end

  set(handles.txt_DriveFree,'String',str);


  fwgt = 'normal';			% normal font
  bgcolor = constant_define( 'COLOR_GREY' );		% normal background
  str = '';

  if ( ~isempty( Zheader.Model.path ) )
    load( Zheader.Model.path, 'Gheader');
    ds = estimate_drive_space( Zheader, Gheader );
  else
    ds = estimate_drive_space( Zheader );
  end

  if ( drive_specs.free <= 0 );	% make sure the drive space container did not get corrupted
    command = sprintf( 'drive_specs = drive_space%s();',  char(sys(idx(1))));  %Wayne: was char(sys(idx))
    eval( command );
  end

  if ( drive_specs.free > 0 && ds.Total.megabytes > 0 )   
    str = sprintf( '%.1f GB', ds.Total.gigabytes );

    dp = ds.Total.megabytes / drive_specs.free * 100;
    if ( dp >= 80 )
      bgcolor = constant_define( 'COLOR_YELLOW' );			% yellow background ( caution )
      fwgt = 'bold';			% bold font

      if ( dp > 90 )
        bgcolor = constant_define( 'COLOR_ORANGE' );		% orange background ( critical )
      end

      if ( dp > 98 )
        bgcolor = constant_define( 'COLOR_RED' );		% red background ( your screwed )
      end
    end
  else
    str = 'N/A';
  end

  set(handles.txt_DriveEst,'String',str);
  set(handles.txt_DriveEst,'BackgroundColor',bgcolor);
  set(handles.txt_DriveEst,'FontWeight',fwgt);  
end


function update_subject_panel_data( handles )
global scan_information Zheader 

  % --- path to Z
  if ( Zheader.older_Z || ~isempty( Zheader.Z_File.directory ) )
    str = sprintf( 'Orig Loc: %s%s', Zheader.Z_File.directory, Zheader.Z_File.name );
  else
    str = sprintf( 'Orig Loc: %s', scan_information.BaseDir );
  end
  sz = 8;
  txt = short_path( str, sz );
  while ( length(txt) > 100 )
    sz = sz - 1;
    txt = short_path( str, sz );
  end
  set(handles.lbl_SubjectLocation,'String',txt);

  % --- number of subjects
  str = sprintf( 'Subjects: %d', Zheader.num_subjects );
  set(handles.lbl_Subjects,'String',['Subjects: ', num2str(Zheader.num_subjects)]);

  % --- number of sessions
  if Zheader.num_runs ~= scan_information.MinRuns
    str = sprintf( 'Runs: %d (%d)', Zheader.num_runs, scan_information.MinRuns );
  else
    str = sprintf( 'Runs: %d', Zheader.num_runs );
  end
  set(handles.lbl_Runs,'String',str);

  % --- multiple Freq
  if scan_information.isMulFreq  txt = 'Yes'; numFreq = num2str(Zheader.num_Z_arrays); else txt = 'No';  numFreq = ''; end
  h = findobj('Tag','lbl_isMulFreq');
  set(handles.lbl_isMulFreq,'String',['Multiple Hz: ' txt] );

  % --- Freq Ranges
  set(handles.lbl_Ranges,'String',['Ranges: ' num2str(numFreq)]);

  % --- Total scans
  set(handles.lbl_NumScans,'String',[ 'Total Scans: ' num2str(Zheader.total_scans)]);

  % --- minimum/maximun scan count (runs)
  set(handles.lbl_MinScans,'String',[ 'Mn: ' num2str(Zheader.min_scans)]);
  set(handles.lbl_MaxScans,'String',[ 'Mx: ' num2str(Zheader.max_scans)]);
  
  c = constant_define( 'COLOR_GREY' );
  if ( Zheader.min_scans ~= Zheader.max_scans )
    c = constant_define( 'COLOR_WARN' );
  end
  set(handles.lbl_MinScans,'BackgroundColor',c);
  set(handles.lbl_MaxScans,'BackgroundColor',c);

  % --- total voxels
  set(handles.lbl_NumVoxels,'String',['Voxels: ' num2str(Zheader.total_columns)]);

  % --- percent regressed out
  h = findobj( 'Tag', 'txt_pct_regressed' );
  if ( Zheader.tsum_trends > 0 && Zheader.tsum_with_trends > 0 )
    set( handles.txt_pct_regressed, 'String', [ num2str(sum(Zheader.rfac), '%.2f%%') ' regressed out'] );
    set( handles.txt_pct_regressed, 'Visible', 'on' );
  else
    set( handles.txt_pct_regressed, 'Visible', 'off' );
  end

  % --- segment extents
  if isstruct( Zheader.partitions.mem )
%   if ~isempty( Zheader.partitions )
    p_count = 1;
    p_mem = '';
    p_count = Zheader.partitions.count;
    p_mem = strrep(Zheader.partitions.mem.mem_display, '  ', ' ' );
    str = sprintf( '%d:%s', p_count, p_mem );
  else
    str = '';
  end;
  set(handles.lbl_SegExtents,'String',str);
  
% TODO: set overwrite check on subject load etc...

end

function update_mask_panel_data( handles )
global Zheader scan_information

  % --- mask file
  str = sprintf( '%s', scan_information.mask.file );
  sz = 8;
  txt = short_path( str, sz );
  while ( length(txt) > 100 )
    sz = sz - 1;
    txt = short_path( str, sz );
  end
  set(handles.lbl_MaskName,'String',txt);


  % --- mask dimensions
  str = 'Dimensions: ';
  if ~isempty( scan_information.mask )
    if ~isempty( scan_information.mask.header )
      sz = size(scan_information.mask.header.dim);
      if ( sz(2) > 2 )
        str=sprintf( 'Dimensions: %d x %d x %d (%dx%dx%d)\n', ...
	  scan_information.mask.header.dim(2), scan_information.mask.header.dim(3), scan_information.mask.header.dim(4), ...
  	  scan_information.mask.header.pixdim(2), scan_information.mask.header.pixdim(3), scan_information.mask.header.pixdim(4) );
      end
    end
  end
  set(handles.txt_MaskDimensions,'String',str);


  % confirm the directory pointed to still exists ( may be a removable drive )
  % --------------------------------------------------------
  z = [Zheader.Z_File.directory Zheader.Z_File.name];
  x = ( exist( scan_information.BaseDir, 'dir' ) == 7 || exist( z, 'file' ) == 2 );
  set(handles.chk_ScanDirExists,'Visible', constant_define( 'STATE', x) );

  x = Zheader.MeanCentered == 1 && Zheader.total_columns > 0 ;
  set(handles.chk_MeanCentered,'Visible', constant_define( 'STATE', x) );

  x = Zheader.Normalized == 1 && Zheader.total_columns > 0 ;
  set(handles.chk_Normalized,'Visible', constant_define( 'STATE', x) );
  
end


function update_model_panel_data( handles )
global scan_information Zheader 

  % ---------------------------------------------------------
  % display G matrix dimensions and location
  % ---------------------------------------------------------
  strsz= '';
  strcond = '';
  strbins = '';
  
  if ( Zheader.Model.mat_exists || Zheader.Model.hdr_exists )
    strcond = sprintf( ' %d', scan_information.processing.model.parameters.conditions );
    strbins = sprintf( ' %d', scan_information.processing.model.parameters.bins );

    strsz = sprintf( '%d x %d', Zheader.Model.mat_x, Zheader.Model.mat_y );
    G_mem = array_sizes( [Zheader.Model.mat_x Zheader.Model.mat_y ] );
    strsz = [ strsz ' [' strtrim(G_mem.mem_display) ']' ];

  end
  
  set(handles.lbl_GExtents,'String',strsz);
%   txt = get( handles.lbl_GConditions, 'String' );
  set(handles.lbl_GConditions,'String',['Conditions: ' strcond]);

%   txt = get( handles.lbl_GTimeBins, 'String' );
  set(handles.lbl_GTimeBins,'String',['Time Bins: ' strbins]);
  
% todo: 
% btn_view_ZH 
% btn_view_EH
% btn_view_GMH
% btn_view_BH
% btn_view_GC
% btn_HScree_Plot
% btn_GH_Stats
end


function set_Z_process_substates( handles )
% --------------------------------------------------
% toggles the states and conditions of Z creation subtask checkboxes
% --------------------------------------------------
global scan_information Zheader;

% Z:btn_run_subject_process  [ isLoaded hasMask ]
% chk_create_z               [  pressed ]
%   chk_apply_regression	   [ pressed checked]
%     chk_linear_regress         [ pressed checked]
%     chk_quad_regress           [  pressed checked]
%     chk_movement_regress       [ pressed checked]
%     chk_user_covariants        [ pressed checked]
%   chk_mean_center          [  pressed ]
%   chk_standardize          [  pressed ]

  if ~strcmp( get( handles.btn_run_subject_process, 'Enable' ), 'on' )
    set( handles.chk_create_z, 'Value', 0 );
    set( handles.chk_create_z, 'Enable', 'off' );
    set( handles.chk_apply_regression, 'Value', 0 );
    set( handles.chk_apply_regression, 'Enable', 'off' );
    set( handles.chk_linear_regress, 'Value', 0 );
    set( handles.chk_linear_regress, 'Enable', 'off' );
    set( handles.chk_quad_regress, 'Value', 0 );
    set( handles.chk_quad_regress, 'Enable', 'off' );
    set( handles.chk_movement_regress, 'Value', 0 );
    set( handles.chk_movement_regress, 'Enable', 'off' );
    set( handles.chk_user_covariants, 'Value', 0 );
    set( handles.chk_user_covariants, 'Enable', 'off' );
    set( handles.chk_mean_center, 'Value', 0 );
    set( handles.chk_mean_center, 'Enable', 'off' );
    set( handles.chk_standardize, 'Value', 0 );
    set( handles.chk_standardize, 'Enable', 'off' );
    return
  end
  
  if ( scan_information.processing.subjects.apply == 0 )
    scan_information.processing.subjects.apply = scan_information.processing.subjects.process.create_Z | ...
                                               scan_information.processing.subjects.process.create_ZZ | ...
                                               scan_information.processing.subjects.process.extract_clusters;
  end

  set( handles.chk_create_z, 'Enable', 'on' );
  set(handles.chk_create_z, 'Value',scan_information.processing.subjects.process.create_Z | ...
                                    scan_information.processing.subjects.process.extract_clusters );
  apply = scan_information.processing.subjects.process.create_Z;
  resume = scan_information.processing.subjects.process.last_subject > 0  * ...
             scan_information.processing.subjects.process.last_subject < Zheader.num_subjects ;
  set( handles.chk_resume_normalization, 'Visible', constant_define( 'STATE', apply * resume) );
  set( handles.chk_resume_normalization, 'Value', scan_information.processing.subjects.process.resume * resume );

         
  set(handles.chk_apply_regression, 'Enable', constant_define( 'STATE', apply ) );
  set(handles.chk_apply_regression, 'Value', scan_information.processing.subjects.process.apply_regression * apply );
  regress = scan_information.processing.subjects.process.apply_regression * apply;

  set(handles.chk_linear_regress, 'Enable', constant_define( 'STATE', regress ));
  set(handles.chk_linear_regress, 'Value', scan_information.processing.subjects.process.linear_regress * regress );

  set(handles.chk_quad_regress, 'Enable', constant_define( 'STATE', regress ));
  set(handles.chk_quad_regress, 'Value', scan_information.processing.subjects.process.quadratic_regress * regress );

  set(handles.chk_user_covariants, 'Enable', constant_define( 'STATE', regress ));
  set(handles.chk_user_covariants, 'Value', scan_information.processing.subjects.process.user_covariants * regress );

  hasRP = scan_information.processing.subjects.rp_count == scan_information.processing.subjects.run_count;
  set(handles.chk_movement_regress, 'Enable', constant_define( 'STATE', regress * hasRP ));
  set(handles.chk_movement_regress, 'Value', scan_information.processing.subjects.process.movement_regress * regress * hasRP );

  
  set(handles.chk_mean_center, 'Enable',  constant_define( 'STATE', apply ) );
  set(handles.chk_mean_center, 'Value', scan_information.processing.subjects.process.mean_center * apply);

  set(handles.chk_standardize, 'Enable',  constant_define( 'STATE', apply ) );
  set(handles.chk_standardize, 'Value', scan_information.processing.subjects.process.standardize * apply);
  
end


function set_G_process_substates( handles )
global scan_information Zheader 

  if ~strcmp( get( handles.btn_run_ga_process, 'Enable' ), 'on' )
    set( handles.chk_apply_G, 'Enable', 'off' );
    set( handles.chk_apply_G, 'Value', 0 );

    set( handles.chk_resume_apply_g, 'Visible', 'off' );
    set( handles.chk_resume_apply_g, 'Value', 0 );
  
    set( handles.btn_regress_G_settings, 'Visible', 'off' );

    set( handles.lbl_G_applied, 'Visible', 'off' );
    set( handles.lbl_G_applied, 'Enable', 'off' );
    set( handles.chk_extract_G, 'Enable', 'off');
    set( handles.chk_extract_G, 'Value', 0 );

    set( handles.btn_extraction_svd_bypass, 'Visible', 'off' );
    set( handles.chk_subject_specific, 'Enable', 'off' );
    set( handles.chk_subject_specific, 'Value', 0 );

    set( handles.chk_Rotate_G, 'Enable', 'off');
    set( handles.chk_Rotate_G, 'Value', 0 );
    set( handles.btn_Rotate_G_Settings, 'Enable',  'off' );
    set( handles.btn_clr_rotations, 'Enable',  'off' );
  
    set( handles.chk_subject_specific_rotated, 'Enable', 'off' );
    set( handles.chk_subject_specific_rotated, 'Value', 0 );
 
    set( handles.chk_apply_ga, 'Enable', 'off');
    set( handles.chk_apply_ga, 'Value', 0 );
    set( handles.chk_apply_gaa, 'Enable', 'off' );
    set( handles.chk_apply_gaa, 'Value', 0 );

    set( handles.NumComp_GA, 'Enable', 'off' );
    return;
  end
  
  if ~isempty( Zheader.Model.path ) 
    load( Zheader.Model.path, 'Gheader' );
  end

  apply = 1;
  regress = 0;
  extract = 0;
  if exist( 'Gheader', 'var' )
    regress = exist( Gheader.path_to_segs, 'dir' ) > 0;
    if isfield( Gheader.GZheader, 'path_to_segs' ) 
      extract = apply * ( exist( Gheader.GZheader.path_to_segs, 'dir' ) > 0 );
    end
  end
  resume = scan_information.processing.model.applied.resume_g.last_subject > 0 * ...
             scan_information.processing.model.applied.resume_g.CC == 0 * ...
             scan_information.processing.model.applied.resume_g.Eigs == 0 ;
  
  set( handles.chk_apply_G, 'Enable', constant_define( 'STATE', apply * regress ) );
  set( handles.chk_apply_G, 'Value',scan_information.processing.model.process.apply_g * apply * regress );

  set( handles.chk_resume_apply_g, 'Visible', 'off' ); %constant_define( 'STATE', apply * regress * resume )
  set( handles.chk_resume_apply_g, 'Value', 0); % scan_information.processing.model.applied.resume_g.resume * apply * regress * resume )
  
  set( handles.btn_regress_G_settings, 'Visible', 'off'); %constant_define( 'STATE', scan_information.processing.model.applied.resume_g.resume * apply * regress * resume)

  set( handles.lbl_G_applied, 'Visible', constant_define( 'STATE', scan_information.processing.model.applied.apply_g * apply ) );
  set( handles.lbl_G_applied, 'Enable', constant_define( 'STATE', scan_information.processing.model.applied.apply_g * apply ) );
  


  set( handles.chk_extract_G, 'Enable', constant_define( 'STATE', apply * extract ) );
  set( handles.chk_extract_G, 'Value', scan_information.processing.model.process.extract_g * apply * extract  );

  set( handles.btn_extraction_svd_bypass, 'Visible', constant_define( 'STATE', get( handles.chk_extract_G, 'Value' ) * scan_information.isMulFreq ) );

  apply_a = Zheader.Contrast.mat_exists;
  hasGA = scan_information.processing.model.process.apply_ga | scan_information.processing.model.process.apply_gaa * apply_a;
  
  set( handles.chk_subject_specific, 'Enable', constant_define( 'STATE', apply * extract * ~hasGA ) );
  set( handles.chk_subject_specific, 'Value', scan_information.processing.model.process.subject_specific * apply * extract );

  set( handles.chk_Rotate_G, 'Enable', constant_define( 'STATE', apply * extract ) );
  set( handles.chk_Rotate_G, 'Value', scan_information.processing.model.process.rotate_g * apply * extract );
  set( handles.btn_Rotate_G_Settings, 'Enable',  constant_define( 'STATE', apply * extract ) );
  set( handles.btn_clr_rotations, 'Enable',  constant_define( 'STATE', apply * extract ) );
  
  set( handles.chk_subject_specific_rotated, 'Enable', constant_define( 'STATE', apply * extract * ~hasGA) );
  set( handles.chk_subject_specific_rotated, 'Value', scan_information.processing.model.process.subject_specific_rotated * apply * extract * ~hasGA );

 
  set( handles.chk_apply_ga, 'Enable', constant_define( 'STATE', apply_a ) );
  set( handles.chk_apply_ga, 'Value',scan_information.processing.model.process.apply_ga * apply_a );
  set( handles.chk_apply_gaa, 'Enable', constant_define( 'STATE', apply_a ) );
  set( handles.chk_apply_gaa, 'Value',scan_information.processing.model.process.apply_gaa * apply_a );


  set( handles.NumComp_GA, 'Enable', constant_define( 'STATE', apply) );
  str = [];
  for ii = 1:size(scan_information.processing.model.process.components,2)
    str = [str ' ' num2str(scan_information.processing.model.process.components(ii) ) ];
  end
  set( handles.NumComp_GA, 'String', str );

end




function set_H_process_substates( handles )
global Zheader scan_information

  if isfield( Zheader.Limits, 'path' )
    if ~isempty( Zheader.Limits.path ) 
      load( Zheader.Limits.path );
    end
  end
  
  roi = isChecked( handles.lbl_GROI );
  
  x = defined_rule( 'Activations', 'Main GUI: Process Panel', {} );
  apply = x.vars.BH * ~roi;
  
  regressed = 0;
  extracted = 0;
  hasE = 0;
  
  if exist( 'Hheader', 'var' )
    regressed = exist( Hheader.model(Hheader.Hindex).path_to_segs.ZH, 'dir' ) > 0;
    extracted = apply * exist( Hheader.model(Hheader.Hindex).path_to_segs.ZH, 'dir' ) > 0;
    hasE =  x.vars.EH * ~roi;
  end

  set( handles.chk_apply_gh, 'Enable', constant_define( 'STATE', apply)  );
  set( handles.chk_apply_gh, 'Value',  scan_information.processing.H_model.apply );

  set( handles.chk_extract_h, 'Enable', constant_define( 'STATE', regressed)  );
  set( handles.chk_extract_h, 'Value', scan_information.processing.H_model.extract);
  set( handles.NumComp_H, 'Enable', constant_define( 'STATE', regressed)  );
  
  Hheader.isRotatable = 0;

  set( handles.chk_Rotate_H, 'Enable', constant_define( 'STATE', 0 ) );
  set( handles.chk_Rotate_H, 'Value', 0);

  set( handles.btn_Rotate_H_Settings, 'Enable', constant_define( 'STATE', 0 )  );
  set( handles.btn_Rotate_H_Settings, 'Value',0);
  scan_information.processing.H_model.rotate = 0;
  
  set( handles.btn_clr_rotations_h, 'Enable', constant_define( 'STATE', 0 ) );

  set( handles.chk_apply_HZ, 'Enable', constant_define( 'STATE', apply ) );
  if ~hasE
    scan_information.processing.H_model.process.hz = 1;
    scan_information.processing.H_model.process.he = 0;
    guidata(handles.output, handles);

  end
  set( handles.chk_apply_HZ, 'Value', scan_information.processing.H_model.process.hz );
  set( handles.chk_apply_HE, 'Enable', constant_define( 'STATE', apply * hasE ) );
  set( handles.chk_apply_HE, 'Value', scan_information.processing.H_model.process.he );
  
  apply = x.vars.GMH * ~roi;
  set( handles.btn_GMH_options, 'Enable', constant_define( 'STATE', apply ) );

  
end


% --- Executes on button press in btn_GROI_images.
function btn_GROI_images_Callback(hObject, eventdata, handles)

global Zheader scan_information

  create_ROIGC_as_Images( handles);
  update_process_buttons( handles );

end
