function Create_ZData_Matrix(base_dir,varargin)
% ---
% --- create Z data matrix
% ---
% --- input:
% ---     base_dir: specify work folder,
% ---     fileName: 
% ---               if fileName is a text file, i.e. File list , then the function will create Zinfo.mat   
% ---               only version 5 list file supported
% ---     maskName: mask file name, default 'mask.img' 
% ---         if maskMethod is provided, it will create a new mask
% ---         or else, assume mask is existing
% ---     maskMethod: mask creation method, 1-Global mean threshold; 2-Harvard Oxford MNI coordinates           
%---      
%---
% --- output:
% ---   Zinfo.mat:
% ---     scan_information             
% ---     Zheader
%---- example
%----- Create_ZData_Matrix('./example_data_Multiple_Groups_Subjects_Runs',...
% ---                       'fileName','files.txt',...
% ---                       'maskName','mask.img',..
% ---                       'maskMethod',2)

defaultFileListName = 'ZInfo.mat';
defaultMaskName = 'mask.img';

p = inputParser;
addRequired(p,'baseDir',@(x)validateattributes(x,{'char'},{'nonempty'}));
addParameter(p,'fileName',defaultFileListName,@(x)validateattributes(x,{'char'},{'nonempty'}));
addParameter(p,'maskName',defaultMaskName,@(x)validateattributes(x,{'char'},{'nonempty'}));
addParameter(p,'maskMethod',[], @(x)validateattributes(x,{'numeric'},{'nonempty','integer','positive'}))

parse(p,base_dir,varargin{:});

% ----check inputs--------------------------
base_dir = p.Results.baseDir;
cd(base_dir);

if exist([base_dir filesep p.Results.fileName], 'file') ~= 2
    disp('List or Zinfo file does not exist');
    return
end

if isempty(p.Results.maskMethod)
    if exist([base_dir filesep p.Results.maskName], 'file') ~= 2
        disp('Mask file does not exist');
        return
    end
end

% initialize data structure
scan_information = legacy_define( 'scan_information' );
% process_information = legacy_define( 'process_info' );
Zheader  = legacy_define( 'ZHeader' );

scan_information.mask.file = p.Results.maskName;
filename = p.Results.fileName;

% Zheader.older_Z = 0;
% Zheader.max_scans = 0;
% Zheader.Z_Directory = [];
% Zheader.Z_File.name =[];

% if ispc
%     process_information.sys = '_pc';
% end
% 
% if ismac
%     process_information.sys = '_mac';
% end


fullpath = [base_dir filesep filename];


    % parse the contents of a text file of subject scans
    % --------------------------------------------------------
    disp('Creating the mask based on List file...')
    fullpath = [base_dir filesep filename];
    scan_information.NumSubjects = 0;
    scan_information.BaseDir= '';
    scan_information.ListSpec = '';
    scan_information.SubjDir = '';
    scan_information.SubjectDirs = '';
    scan_information.SubjectID = '';
    scan_information.run_dirs = '';
    scan_information.freq_dirs = '';
    scan_information.FileList = fullpath;

    % --- is this the new style of scan listing ( listver:# )
    fid = fopen( fullpath, 'r' );
    x = fgets( fid );		  % x = listver:n
    fclose(fid);
    if ( size(x,2) > 7 )
        if strcmp(x(1:7),'listver')
            xx = regexp(x,':','split');
            ver = str2num(char(xx(2)));
            if ver==5
                scan_information = parse_scan_listing_cmd_v5( fullpath, scan_information);
            else
                disp('This function supports version 5 only, please re-run Create_File_List command.')
                return
            end
        else
            disp('Wrong format of File List!')
            return
        end
    else
        disp('Wrong format of File List!')
        return
    end


    % confirm the directory pointed to still exists ( may be a removable drive )
    % --------------------------------------------------------
    x = exist( char(scan_information.BaseDir), 'dir' ) == 7;
    if (x~=1)
        disp('scan folder is not existing!')
        return
    end
    % h = findobj('Tag','chk_ScanDirExists');
    % set(h,'Visible', constant_define( 'STATE', x) );

    % --------------------------------------------------------
    % we need to determine the number of scans for all subjects
    % and calculate how much memory the full Z matrix will require
    % if more than available user memory, determine level of columnar segmentation
    % --------------------------------------------------------
    [scan_information, Zheader] = sum_subject_scans_cmd(scan_information,Zheader);

    % confirm the directory pointed to contains scan images
    % --------------------------------------------------------
    if Zheader.total_scans == 0
        fprintf( 'There appears to be no scan images found in %s\n', scan_information.BaseDir );
        return
    end

    % processing a subject scan list where a current set exists
    % will destroy the normalized subject data
    % --------------------------------------------------------
    % p = pwd;
    fn = [base_dir filesep 'ZInfo.mat'];

    % exist will return 0 if the file does not exist
    % it will return 1 if the file exists in the current workspace
    % it will return 2 if the file exists in the current path
    % avoid condition 2, only check if it exists in the current workspace
    % --------------------------------------------------------
    if ( exist( fn, 'file' ) )
        disp('Study Conflict!');
        disp('There appears to be an existing subject set in your present directory.  It is suggested you change directory before continuing, otherwise your existing data headers will be overwritten, and the normalized data set rendered useless!');

    end



% % ---
% % --- SelectA - select A Contrast
% % ---
% % function Btn_SelectA_Callback(hObject, eventdata, handles)
% % TODO
% Zheader.Contrast.path = [];
% lst = [];
% idx = 0;
%
% if ~isempty( Zheader.Contrast.path )  % model contrast
%
%     load( Zheader.Contrast.path );
%
%     if exist( 'Aheader', 'var' )
%
%         idx = Aheader.Aindex;
%
%         if isfield( Aheader, 'model' )
%             for ii = 1:size( Aheader.model, 1)
%                 if ~isempty( Aheader.model(ii).id )
%                     lst = [lst; {Aheader.model(ii).id}];
%                 else
%                     lst = [lst; {['A ' num2str(ii)]}];
%                 end
%
%             end
%         else
%             lst = {['A ' num2str(ii)]};
%         end
%
%     end
% end
%
% % set( handles.lst_A, 'String', lst, 'Value', idx );
% % ---
% % --- SelectH - select H Limits
% % ---
% % function Btn_SelectH_Callback(hObject, eventdata, handles, from_add)
% % TODO
%
% Zheader.Limits.path = [];
%
% lst = [];
% idx = 0;
%
% if ~isempty( Zheader.Limits.path )
%
%     load( Zheader.Limits.path );
%
%     if exist( 'Hheader', 'var' )
%
%         Hheader = adjust_hheader( Hheader );
%         save( Zheader.Limits.path, 'Hheader' );
%
%         idx = Hheader.Hindex;
%
%         if isfield( Hheader, 'model' )
%             for ii = 1:size( Hheader.model, 1)
%                 if ~isempty( Hheader.model(ii).id )
%                     lst = [lst; {Hheader.model(ii).id}];
%                 else
%                     lst = [lst; {['H ' num2str(ii)]}];
%                 end
%
%             end
%         else
%             lst = {['H ' num2str(ii)]};
%         end
%
%     end
% end
%
% % set( handles.lst_H, 'String', lst, 'Value', idx );
% % save_headers();
%
% if exist('G_ROI.mat', 'file' )
%     load G_ROI
% end
%
% lst = [];
% if exist( 'G_ROI', 'var' )
%
%     if isfield( G_ROI, 'mask' )
%         for ii = 1:size( G_ROI.mask, 1)
%             if ~isempty( G_ROI.mask(ii).id )
%                 lst = [lst; {G_ROI.mask(ii).id}];
%             else
%                 lst = [lst; {['G ROI ' num2str(ii)]}];
%             end
%
%         end
%     else
%         lst = {['G ROI ' num2str(ii)]};
%     end
%
%     % set( handles.lst_GROI, 'String', lst, 'Value', G_ROI.Rindex );
%
% end

if ~isempty(p.Results.maskMethod)
    create_mask_cmd(scan_information,Zheader,scan_information.mask.file, p.Results.maskMethod );
end


% % -- set the do not recreate flag if all subject already masked
% x = who_stats( '', 'mask_stats.mat', 'subjects_masked' );
% if x.mat_exists
%   handles.chk_recreate_masks.Value = 1;
% end
%
% x = who_stats( '', 'mask_stats.mat', 'flag_threshold' );
% if x.mat_exists
%   load( 'mask_stats.mat', 'flag_threshold' );
%   handles.txt_flag_reduction_value.String= num2str( flag_threshold );
% end

% --- save Zinfo
% ------------------------------------------

% check existing of mask
disp('checking the mask...')
scan_information.mask.file = p.Results.maskName;
x = [ base_dir filesep scan_information.mask.file ];

if ( spm_existfile(x)>0 )

    % r = regexp( x, '~', 'split' );
    % x = char(r(1));

    msk = cpca_read_vol( x );

    msk.ind = find( msk.image);
    if size( msk.ind, 2 ) > 1 && size( msk.ind, 1 ) == 1
        msk.ind = msk.ind';
    end

    scan_information.mask = msk;
    scan_information.mask.file = p.Results.maskName;
    if ~ isRegistered( scan_information.mask )
        % register the mask to MNI
        mask_reg2_MNI(scan_information);

        msk = cpca_read_vol( [ base_dir filesep 'registered_mask.img' ] );

        msk.ind = find( msk.image);
        if size( msk.ind, 2 ) > 1 && size( msk.ind, 1 ) == 1
            msk.ind = msk.ind';
        end
        scan_information.mask = msk;
        scan_information.mask.file = 'registered_mask.img';
        
    end
    % scan_information.mask.isRegistered =1;
    if isempty(scan_information.mask.header)
        str = ['There is no header file associated with this image<br>' scan_information.mask.file ];
        show_message( 'Image Data corrupted', str);
        scan_information.mask.file = '';
    end

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
      disp('Mask Dimension Mismatch');
      disp('The mask image dimensions or voxel sizes do not match the dimensions or voxel sizes of the raw data images.');
      scan_information.mask.file = '';
      return;
    end



    scan_information.mask.x = size( scan_information.mask.ind, 1);
    scan_information.mask.y = size( scan_information.mask.ind, 2);

    scan_information.mask.isRegistered = isRegistered( scan_information.mask ) ;
    scan_information.mask.MNI = MNI_coords( scan_information.mask );

    if ( isempty( Zheader.Z_Directory ) ) && prod( size( scan_information.mask.ind ) ) > 1
        Zheader.Z_Directory = [ pwd filesep ];
        % save_Zinfo( Zheader, scan_information )
    end

    % resetting the mask may have different resulting dimensions on Z matrices
    if ( isempty( Zheader.Z_File.name )  && exist(scan_information.BaseDir, 'dir') == 7 )
        [scan_information, Zheader] = sum_subject_scans_cmd(scan_information,Zheader);
    end

    Zheader.total_columns = scan_information.mask.x;
    Zheader.partitions = calc_column_partitions( Zheader.total_scans, Zheader.total_columns, constant_define( 'PARTITION_MAX' ) );

    save_Zinfo( Zheader, scan_information )

end

% verify mask
disp('Verifying the mask...')
mask_verification_cmd(Zheader, scan_information)

disp('Done!')

end


function mask_reg2_MNI(scan_information)
% --- Included is a mask which separates white and gray matter, ventricles, 
% --- Brain stem and cerebellum.  ( the latter is incorporated from an 
% --- FSL Atlas, and is somewhat fuzzy
% --- 


  msk = scan_information.mask;
  msk.MNI = MNI_coords( msk );

  fprintf('Registering Mask %d voxels \n', numel( msk.ind ) );

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
  
  end

  msk.ind = find( msk.image );
  VR = msk.image( msk.ind(:) );
  write_cpca_image( '', 'registered_mask.img', VR, msk );

  disp('The registered mask has been created in the current working directory: ');

end
