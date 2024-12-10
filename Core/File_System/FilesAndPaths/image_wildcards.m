function wc = image_wildcards( from_dir )
% syntax: wc = image_file_count( from_dir )
% returns wild card specifications for image file contents
global scan_information 

  lst = [];

  d = dir( [from_dir filesep '*.img']  );
  if ( size(d,1) > 0 )
    for idx = 1:size(d,1)
      yy = char(d(idx).name);
      zz = regexprep( yy, '([0-9]{3,6})(\.)', '*');
      xx = regexprep( zz, 'img(.)|img\n|img$', '.img\n');
      xx = regexprep( xx, '\.\.', '\.');

      lst = [lst [char(xx) char(10)] ];
    end;
  end;

  d = dir( [from_dir filesep '*.nii']  );
  if ( size(d,1) > 0 )
    for idx = 1:size(d,1)
      yy = char(d(idx).name);
      zz = regexprep( yy, '([0-9]{3,6})(\.)', '*');
      xx = regexprep( zz, 'nii(.)|nii\n|nii$', '.nii\n');
      xx = regexprep( xx, '\.\.', '\.');

      lst = [lst [char(xx) char(10)] ];
    end;
  end;


  xn = strfind( lst, '**' );
  while xn  lst = strrep(lst, '**', '*' ); xn = strfind( lst, '**' );  end;

  aa = [];
  nn = unique(regexp( lst, '\n', 'split' )); 
  for ii = 1:size(nn,2)
    if size( char(nn(ii)), 2 ) > 0 
      aa = [aa  nn(ii) ];
    end;
  end;

  
  elems = [];
  for ii = 1:size(aa,2)
    if size( char(aa(ii)), 2 ) > 0 
      elems = [elems  size(regexp( char(aa(ii)), '*', 'split' ),2) ];
    end;
  end

  nelems = max( elems );

  node_elements = [];
  for ii = 1:size(aa,2)
    st = regexp( char(aa(ii)), '*', 'split' );
    if ( elems(ii) < nelems )
      for jj = 1:nelems-elems(ii)
        st = [st {''}];
      end;
    end;

    node_elements = [node_elements; st];
  end;


  for ii = 2:size(node_elements, 2) - 1
    if all( strcmp( char(node_elements(1,ii)) , node_elements(:,ii) ) )
      node_elements(:,ii) = {''};
    end;
  end;

  x = strcmp( '', node_elements );
  y = find(x);
  node_elements( y(:) ) = {''} ;


  rslt = [];

  for ii = 1:size(node_elements, 1 )
    str = [];
    for jj = 1:size(node_elements, 2 )
      if size( char( node_elements(ii,jj) ), 2 ) > 0 
        if jj > 1  bf = '*'; else bf = '';  end;
        str = [str bf char( node_elements(ii,jj) )];
      end;
    end;

    strsz = sprintf( '%s\n', str ); 
    rslt = [rslt strsz];

  end;

  xn = strfind( rslt, '**' );
  while xn  rslt = strrep(rslt, '**', '*' ); xn = strfind( rslt, '**' );  end;

  rslt = strrep(rslt, '.img*', '.img' );

  xx = regexp( rslt, '\n', 'split' );

  wc = '';
  for x = 1:size(xx,2)
    if ( size(char(xx(x)),2) > 1 )
      if ( size(wc,2) > 0 )
        wc = [wc; xx(x)];
      else
        wc = xx(x);
      end;
    end;
  end;
