function img = MNI_mask_calculation( img, pop )
% --- returns the full str descriptor for image MNI coordinates 
% --- performs a lancaster transformation on the image MNI coords
% --- where lancaster fails to find a valid talairach coordinate
% --  it will perform a brett transform on these locations and use that
% --- result if discovered
% --- 
% --- Nov 27, 2013
% --- No longer using Lancaster transform - too many non relevant regions included 
%   tmp = [];
  
  if nargin < 2
    pop = 0;
  end;

  MNI_1mm = constant_define( 'MNI_1MM_MASK_REV' ) ;
  if exist(MNI_1mm, 'file')
    load( MNI_1mm );
  end;

  % --- verify talairach data loaded sucessfully
  if ~exist( 'HO_template', 'var' )
    return;
  end;


  if ~isfield( HO_template, 'vol' ) || ~isfield( HO_template, 'image' ) || ~isfield( HO_template, 'MNI' ) || ~isfield( HO_template, 'ind' )
    return;
  end;
  
%   tmp = img;
%   tmp.ind = [];
%   tmp.image = zeros( 1, prod(tmp.vol.dim) );
%   
%   A.last_vox = 0;
%   A.last_slice = 1;
%   A.last_slice_vox = 1;
%   A.image = tmp.image;
  
%   if reset_resume
%     if exist( 'mask_logs/HO_MNI_data.mat', 'file' )
%       load( 'mask_logs/HO_MNI_data.mat', 'A' );
%       tmp.image = A.image;
%     end
%   end;
  
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

%   slices = img.vol.dim(3);
%   slice_vol = prod( img.vol.dim(1:2) );
  
  if strcmp( class(pop), 'cpca_progress' )
    pop.setIterations( numel( img.ind ), pop.PRIMARY );
    pop.setIterations( 1, pop.SECONDARY );
    pop.setMessages( 'Creating MNI template mask', [ 'Processing ' num2str(size(img.image,1)) ' Voxels. . .'], '');
%     pop.addPercent(A.last_vox, pop.PRIMARY );
  end
  
%   ii = A.last_vox;
  
  Yval = img.MNI(2, img.ind( 1 ) );
  Yaxis = find( HO_template.MNI(2,:) == Yval );
  
  for voxel = 1:numel( img.ind )

    if img.MNI(2, img.ind(voxel)) ~= Yval 
      Yval = img.MNI(2, img.ind( voxel ) );
      Yaxis = find( HO_template.MNI(2,:) == Yval );
    end

    x = find( HO_template.MNI(1,Yaxis) == img.MNI(1, img.ind( voxel )) );
    z = find( HO_template.MNI(3, Yaxis(x)) == img.MNI(3,img.ind( voxel )) );
        
    if numel(z) == 1
      img.image(img.ind( voxel ) ) = HO_template.image( Yaxis(x(z)) );
    end
 
    %pop.increment();    
  
  end

  % --- -------------------------------------
  % --- -------------------------------------
  
%   for slc = A.last_slice:slices
%       
%     if strcmp( class(pop), 'cpca_progress' )
%       pop.setIterations( slice_vol, pop.SECONDARY );
%       pop.setComment( [ 'Slice ' num2str(slc) ' of ' num2str(slices) ] );
%       pop.addPercent(A.last_slice_vox - 1, pop.SECONDARY );
%     end;
%     
%     for jj = A.last_slice_vox:slice_vol
%       ii = ii + 1;
%       x = isBrain( HO_template, img.MNI(:,ii) );  
% 
%       if x 
%         tmp.image(ii) = 1;
%       end
%       
%       if strcmp( class(pop), 'cpca_progress' )
%         pop.increment();
%       end
%       
%       A.last_vox = ii;
%       A.last_slice_vox = jj;
%     
%     end
%     
%     A.last_slice_vox = 1;
%     A.last_slice = A.last_slice + 1;
%     A.image = tmp.image;
%     last_slice = A.last_slice;
%     save( 'mask_logs/HO_MNI_data.mat', 'A', 'last_slice' );
%     
%   end

  img.ind = find( img.image );

  VR = img.image( img.ind);
 
  fn = ['subject_masks' filesep 'whole_brain_template_mask.img' ];
  write_cpca_image( '', fn, VR, img );
  
  eval( [ 'delete mask_logs' filesep 'HO_MNI_data.mat' ] );
  

