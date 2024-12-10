function V = cpca_create_vol( V, h )

  N = struct ( ...
    'dat', [], ...			% --- shaped file array   ---
    'mat', [], ...			% --* transform matrix    ---
    'mat_intent', '', ...
    'mat0', [], ...			% --* transform matrix    ---
    'mat0_intent', '', ...
    'descrip', '', ...			% --- text description    ---
    'aux_file', 'none' );

  if ~isfield(V,'n'),
    V.n       = [1 1];
  else
    V.n       = [V.n(:)' 1 1];
    V.n       =  V.n(1:2);
  end;


  if ~isfield(V,'dt')
    V.dt = [2 isBigendian() ];
  end;

  dtyp = cpca_data_type( V.dt(1) );
  dt{1} = dtyp.analyse;
  if length( dt{1} ) == 0
    dt{1} = dtyp.nifti;
  end;
  
  if strcmp(dt{1},'UNKNOWN')
    error(['"' dt{1} '" is an unrecognised datatype (' num2str(V.dt(1)) ').']);
  end;
  if V.dt(2), dt{2} = 'BE'; else dt{2} = 'LE'; end;

  if ( ispc() ) ds = '\'; else ds = '/'; end;
  [path fname] = split_path(V.fname, ds );
  [fname ext] = split_filename( fname );

  minoff = 0;
  if strcmp( lower( ext ), 'nii' )     minoff = 352;   end;
  minoff = minoff + ceil(prod(V.dim(1:2))*dtyp.bits/8)*V.dim(3)*(V.n(1)-1+V.n(2)-1);
  V.pinfo(3,1) = max(V.pinfo(3,:),minoff);

  dim    = [V.dim(1:3) V.n];
  dat    = file_array(V.fname,dim,[dt{1} '-' dt{2}],0,V.pinfo(1),V.pinfo(2));

  N.dat  = dat;
  N.mat  = V.mat;
  N.mat0 = V.mat;
  N.mat_intent  = 'Aligned';
  N.mat0_intent = 'Aligned';
  N.descrip = V.descrip;

  S = niistruct();

  V.fname = [fname '.' ext];		% --- only the filename is written to file ---

  if ( ~ nifti_single_file( h ) )	% not flagged as a nifti combined file?
    hdrfile = [path fname '.hdr'];	% --- open the full path filename --- 
  else
    hdrfile = [path fname '.' ext];	% --- open the full path filename --- 
  end;
  
%  if exist(hdrfile,'file')
%    fid = fopen(hdrfile,'r+');
%  else
    fid = fopen(hdrfile,'w');
%  end

  if ( fid )

    for ( ii = 1:size(S,1) )
      if isfield(h,char(S(ii,1)))
        eval( [ 'dat = h.' char(S(ii,1)) '; '] );
       
        dlen = cell2mat(S(ii,2));
        if length(dat) ~= dlen
          if length(dat)< dlen
            dat = [dat(:); zeros( dlen-length(dat),1) ];
          else
            dat = dat(1:dlen);
          end;
        end;
        len = fwrite( fid, dat, char(S(ii,3)) );

      end;		% --- header data element exists ---
    end;		% --- each data elemenet in header ---

  fclose( fid );
  end;

%  V.fname = [path fname '.' ext];	
  V.private = N;

