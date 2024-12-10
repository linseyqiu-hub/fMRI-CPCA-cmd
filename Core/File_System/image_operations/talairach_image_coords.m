function img = talairach_image_coords( img, pop, lancaster )
% --- returns the full str descriptor for image MNI coordinates 
% --- performs a lancaster transformation on the image MNI coords
% --- where lancaster fails to find a valid talairach coordinate
% --  it will perform a brett transform on these locations and use that
% --- result if discovered
% --- 
% --- Nov 27, 2013
% --- No longer using Lancaster transform - too many non relevant regions included 

  if nargin < 3
    lancaster = 0;
  end;

  if nargin < 2
    pop = 0;
  end;

  xform_method = 'Brett';
  if lancaster == 1
    xform_method = 'Lancaster';
  end;
  
  tal_labels = [];     % -- return empty on errors
  
  ph = [cpca_path() 'utils' filesep 'image_operations' filesep 'talairach.mat'];             	% -- base path of GUI application
  if exist(ph, 'file')
    tal = load( ph, 'label', 'image', 'Talairach_MNI_str' );
  end;

  % --- verify talairach data loaded sucessfully
  if ~exist( 'tal', 'var' )
    return;
  end;

  if ~isfield( tal, 'label' ) || ~isfield( tal, 'image' ) || ~isfield( tal, 'Talairach_MNI_str' )
    return;
  end;
  
  x = size(img.image);
  if size(x,2 ) < 3
    D = reshape( img.image, img.vol.dim);
  else
    D = img.image;
  end;

  ind = [1:prod(img.vol.dim)];

  [I J K] = ind2sub(size(D), ind);
  img.IJK = [I; J; K];
  if isempty(img.IJK)
    return
  end

  img.MNI = img.vol.mat(1:3,:)*[img.IJK; ones(1,size(img.IJK,2))];
  
  if ~lancaster
    tal_xform = mni2tal( img.MNI );    % --- Brett xaform
  else
    tal_xform = icbm2tal( img.MNI );   % --- Lancaster xform
  end;

  img.tal_MNI = zeros( prod(img.vol.dim), 3 );
  
  x = find( tal_xform > 0);
  tal_xform(x) = floor(tal_xform(x));
  x = find( tal_xform < 0);
  tal_xform(x) = ceil(tal_xform(x));

  tal_xform = tal_xform';

  img.tal_MNI = tal_xform;   

  img.tal_index = zeros( prod(img.vol.dim), 5 );
% ---  [ talairach label index,  Talairach MNI coordinates 1, 2, 3,   mask voxel index ]
  n_vox = size(img.tal_MNI, 1 );

  n = find( tal.image );            % --- all non zero talairach label indices

  if ( strcmp( class(pop), 'cpca_progress' ) )
    pop.setMessages( ' Creating Talairach Whole Brain mask', [ 'Using ' xform_method ' transform.' ], ['Processing ' num2str( n_vox ) ' voxels . . .' ] );
    pop.setIterations( n_vox, pop.SECONDARY );
  end;

  
  for this_voxel = 1:n_vox

    xform_str = [num2str(tal_xform(this_voxel,1), '%04d') num2str(tal_xform(this_voxel,2), '%04d') num2str(tal_xform(this_voxel,3), '%04d') ];
    invalid_str = strcmp( xform_str, '000000000000' );

    if ~invalid_str
      x = strfind( tal.Talairach_MNI_str, xform_str );
      idx = floor((x-1)/13)+1;

      img.tal_index(this_voxel,:)  = [ double(tal.image(idx))  tal_xform(this_voxel,:)   this_voxel ];
%      img.tal_index(this_voxel,:)  = [ double(tal.image(idx))  str2num(xform_str(1:4) )  str2num(xform_str(5:8) )  str2num(xform_str(9:12) )  this_voxel ];

    end;
    
    if ( strcmp( class(pop), 'cpca_progress' ) )
      pop.increment(pop.SECONDARY);
    end;
    
  end;


