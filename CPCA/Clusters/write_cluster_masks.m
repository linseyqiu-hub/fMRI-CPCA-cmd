function write_cluster_masks( rotation_params, nd, Hmodel, pop )
%global scan_information 
% --- Primary Iterations
% --- N/A

  if nargin < 4,  pop = [];  end;
  if ~isa( pop, 'cpca_progress' ),     pop = [];   end

  if nargin < 3  
    if isfield( rotation_params, 'htype' ) 
      Hmodel = rotation_params.htype; 
    else
      Hmodel = 'G';
    end; 
  end;

  Txt = 'Creating cluster masks';
  iters = nd * num_active_thresholds();
  if ~isempty(pop)
    pop.setIterations( iters,  pop.SECONDARY  );
    pop.setMessages( Txt, '', '' );
  end;


  if isempty( rotation_params )
    rotation_params.method = 'unrotated';
    rotation_params.defaults = struct( 'empty', 1 );
    rotation_params.fs = 'unrotated';
  end;

  rotation_params.nd = nd;

  if ~isfield( rotation_params, 'model' )
    rotation_params.model = 'G';
  else
    if isempty(rotation_params.model)
      rotation_params.model = 'G';
    end;
  end;

  if ~isfield( rotation_params, 'component_vector' )
    rotation_params.component_vector = 1:nd;
  end;

  if isempty( Hmodel )
    Hmodel = rotation_params.model;
  end
  
%  p = fs_path( rotation_params.fs, 'output', nd, 0, rotation_params );
%  v = fs_filename( 'mat', Hmodel, rotation_params.method, rotation_params.defaults );

  i = fs_path( rotation_params.fs, 'images', nd, 0, rotation_params );
  m = fs_filename( 'loadings', Hmodel, rotation_params.method, rotation_params.defaults );

  evalc( ['load( ''' i m ''', ''MNI'' )'] );


%  for comp = 1:nd
  for cmp = 1:size(rotation_params.component_vector,2);

    comp = rotation_params.component_vector(cmp);
    rotation_params.defaults.component = comp;

    if isfield( MNI, 'component' )		

      for thr = 1:num_global_thresholds()

        if is_active_threshold(thr)
          cluster_no = 0; % --- used for an absolute cluster nunmbering
          rotation_params.threshold = global_threshold_value( thr );
 
          Sts = ['Component ' num2str(comp) ' [' num2str(rotation_params.threshold) '%] - Positive Clusters'];
          if ~isempty(pop)
            pop.setMessages( Txt, Sts, 'Calculating . . .' );
            pop.increment( pop.SECONDARY );
          end;
          
          [~, cp] = fs_create_path( rotation_params.fs, 'cluster_mask', nd, 0, rotation_params );
          eval( ['delete ' cp '*;'] );
        
          if ~isempty( MNI.component( comp ).threshold(thr).pos)
            write_these_cluster_masks(  MNI.component( comp ).threshold(thr).pos, cp, cluster_no, 'Positive' );
          end;

          cluster_no = 0; % --- used for an absolute cluster nunmbering

          Sts = ['Component ' num2str(comp) ' [' num2str(rotation_params.threshold) '%] - Negative Clusters'];
          if ~isempty(pop)
            pop.setMessages( Txt, Sts, 'Calculating . . .' );
            pop.increment( pop.SECONDARY );
          end;
          if ~isempty( MNI.component( comp ).threshold(thr).neg)
            write_these_cluster_masks( MNI.component( comp ).threshold(thr).neg, cp, cluster_no, 'Negative' );
          end;
        end;
      end;
      
    else

%      if is_active_threshold(thr)

        [~, cp] = fs_create_path( rotation_params.fs, 'cluster_mask', nd, 0, rotation_params );
        eval( ['delete ' cp '*;'] );

        if ~isempty(thisMNI.pos)
          cluster_no = 0; % --- used for an absolute cluster numbering
          write_these_cluster_masks( MNI( comp ).pos, cp, cluster_no, 'Positive' );
        end;

        if ~isempty(thisMNI.neg)
          cluster_no = 0; % --- used for an absolute cluster numbering
          write_these_cluster_masks( MNI( comp ).neg, cp, cluster_no, 'Negative' );
        end;

%      end;
      
    end;

  end;


function cluster_no = write_these_cluster_masks( MNI_COORDS, pth, cluster_no, Hmodel )
global  scan_information

  if nargin < 4,  cluster_no = 0; end;
  if nargin < 5,  Hmodel = 'G'; end;
  Hmodel = [Hmodel '_'];

  for clno = 1:size(MNI_COORDS, 1)

    if ( MNI_COORDS(clno).mm3 >= constant_define( 'PREFERENCES', 'cluster.minimum_mm3' ) )

      cluster_no = cluster_no + 1;
      mni_coord = MNI_COORDS(clno).peak.mni;
      filename = sprintf( '%s%03d_MNI_%d_x_%d_x%d_MM3_%d.img', Hmodel, cluster_no, mni_coord(1), mni_coord(2), mni_coord(3), MNI_COORDS(clno).mm3 );

      cluster_mask = scan_information.mask;
      cluster_mask.image = zeros(prod(cluster_mask.vol.dim), 1 );
      cluster_mask.image(MNI_COORDS(clno).Masks.Mindex(:))=1;	
      cluster_mask.ind = find( cluster_mask.image );
      VR = ones( size( MNI_COORDS(clno).Masks.Mindex ) );
      write_cpca_image( pth, filename, VR, cluster_mask );
      
%       if isfield( MNI_COORDS(clno).Masks, 'GMindex' )
%         cluster_mask.image = zeros(prod(cluster_mask.vol.dim), 1 );
%         cluster_mask.image(MNI_COORDS(clno).Masks.GMindex(:))=1;	
%         cluster_mask.ind = find( cluster_mask.image );
%         VR = ones( size( MNI_COORDS(clno).Masks.GMindex ) );
%         filename = sprintf( '%s%03d_MNI_%d_x_%d_x%d_MM3_%d_GrayMatter.img', Hmodel, cluster_no, mni_coord(1), mni_coord(2), mni_coord(3), MNI_COORDS(clno).mm3 );
%         write_cpca_image( pth, filename, VR, cluster_mask );
%       end
      
    end;

  end;


