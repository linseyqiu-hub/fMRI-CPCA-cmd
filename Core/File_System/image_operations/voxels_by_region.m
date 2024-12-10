function n = voxels_by_region ( img )

  n = [];   % --- [ RSA LSA RSP LSP RIA LIA RIP LIP ]

  x = size(img.image);
  if size(x,2 ) < 3
    D = reshape( img.image, img.vol.dim);
  else
    D = img.image;
  end;

  ind = [1:prod(img.vol.dim)];

  [I J K] = ind2sub(size(D), ind);
  IJK = [I; J; K];
  if isempty(IJK)
    return
  end

  mni = img.vol.mat(1:3,:)*[IJK; ones(1,size(IJK,2))];
  mni = mni(:,img.ind);
  
  % --- right superior anterior     % --- [ X+  Y+  Z+ ]
  X = find(mni(1,:)>=0);            % --- [ X+ ]
  Y = find(mni(2,X)>=0);            % --- [ Y+ ]
  Z = find(mni(3,X(Y))>=0);         % --- [ Z+ ] 
  n = [n size(Z,2)];

  % --- left superior anterior      % --- [ X-  Y+  Z+ ]
  X = find(mni(1,:)< 0);            % --- [ X- ]
  Y = find(mni(2,X)>=0);            % --- [ Y+ ]
  Z = find(mni(3,X(Y))>=0);         % --- [ Z+ ]
  n = [n size(Z,2)];

  % --- right superior posterior    % --- [ X+  Y+  Z- ]
  X = find(mni(1,:)>=0);            % --- [ X+ ]
  Y = find(mni(2,X)>=0);            % --- [ Y+ ]
  Z = find(mni(3,X(Y))< 0);         % --- [ Z- ] 
  n = [n size(Z,2)];

  % --- left superior posterior     % --- [ X-  Y+  Z- ]
  X = find(mni(1,:)<0);             % --- [ X- ]
  Y = find(mni(2,X)>=0);            % --- [ Y+ ]
  Z = find(mni(3,X(Y))< 0);         % --- [ Z ]
  n = [n size(Z,2)];


  % --- right inferior anterior     % --- [ X+  Y-  Z+ ]
  X = find(mni(1,:)>=0);            % --- [ X+ ]
  Y = find(mni(2,X)< 0);            % --- [ Y- ]
  Z = find(mni(3,X(Y))>=0);         % --- [ Z+ ] 
  n = [n size(Z,2)];

  % --- left inferior anterior      % --- [ X-  Y-  Z+ ]
  X = find(mni(1,:)< 0);            % --- [ X- ]
  Y = find(mni(2,X)< 0);            % --- [ Y- ]
  Z = find(mni(3,X(Y))>=0);         % --- [ Z+ ]
  n = [n size(Z,2)];

  % --- right inferior posterior    % --- [ X+  Y-  Z- ]
  X = find(mni(1,:)>=0);            % --- [ X+ ]
  Y = find(mni(2,X)< 0);            % --- [ Y- ]
  Z = find(mni(3,X(Y))< 0);         % --- [ Z- ] 
  n = [n size(Z,2)];

  % --- left inferior posterior     % --- [ X-  Y-  Z- ]
  X = find(mni(1,:)< 0);            % --- [ X- ]
  Y = find(mni(2,X)< 0);            % --- [ Y- ]
  Z = find(mni(3,X(Y))< 0);         % --- [ Z- ]
  n = [n size(Z,2)];


 
