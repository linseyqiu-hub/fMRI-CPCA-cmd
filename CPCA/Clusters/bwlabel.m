function [l nl] = bwlabel( bw, dconn )
% --- TODO: see if using inline instead of global makes a diiference
global dim il tt l;

  l = [];
  nl = 0.0;

  ndim = sum(size(bw)>0);	% number of dimensions
  dim = size(bw);
  if (ndim == 2) 
    dim = [dim 1];
    ndim = 3; 
  end;

  n = 1;
  for (ii = 1:ndim ) n = n * dim(ii); end;

  l = zeros( dim );
  il = zeros( n, 1 );

  conn = dconn + 0.1;

  tt = [];

  ttn = do_initial_labelling (bw, conn );

  nl = translate_labels( ttn );


function ttn = do_initial_labelling( bw, conn )
% --- bw,    Binary map 
% --- dim,   Dimensions of bw 
% --- conn,  Connectivity criterion 
% --- il,    Initially labelled map
% --- tt     Translation table 

global dim tt il;

  label = 1;
  nabo = zeros(9,1);

  ttn = 1000;
  tt = zeros( ttn, 1 );

  for (sl = 1:dim(3) )			% --- each slice ---
    for (c = 1:dim(2) )			% --- each column of slice --
      for (r = 1:dim(1) )		% --- each element of column ---

        nr_set = 0;
        if ( bw(index_value(r,c,sl,dim)) )

          nabo(1) = check_previous_slice( r, c, sl, conn, ttn);
          if (nabo(1)) nr_set = nr_set + 1; end;

          % -------------------------------------------
          % --- For six(surface)-connectivity
          % -------------------------------------------
          if (conn >= 6)
            if (r)
              x = index_value( r-1, c, sl, dim ); 
              if (x) if ( il(x) ) nabo(nr_set+1) = il(x); nr_set = nr_set + 1; end; end;
            end;
            if (c)
              x = index_value( r, c-1, sl, dim ); 
              if (x) if ( il(x) ) nabo(nr_set+1) = il(x); nr_set = nr_set + 1; end; end;
            end;
          end;

          % -------------------------------------------
          % --- For 18(edge)-connectivity
          % --- N.B. In current slice no difference to 26.
          % -------------------------------------------
          if (conn >= 18)
            if (c && r)
              x = index_value( r-1, c-1, sl, dim ); 
              if (x) if ( il(x) ) nabo(nr_set+1) = il(x); nr_set = nr_set + 1; end; end;
            end;
            if (c && (r < dim(1)-1))
              x = index_value( r+1, c-1, sl, dim ); 
              if (x) if ( il(x) ) nabo(nr_set+1) = il(x); nr_set = nr_set + 1; end; end;
            end;
          end;
          if (nr_set)
             il(index_value(r,c,sl,dim)) = nabo(1);
             nabo = fill_translation_table( ttn, nabo, nr_set );
          else
             il(index_value(r,c,sl,dim)) = label;
             if (label >= ttn) ttn = ttn + 1000;  tt = resize_matrix( tt,ttn );  end;
             tt(label) = label;
             label = label + 1;
          end;

        end;


      end;	% --- each element ---
    end;	% --- each column ---
  end;  	% --- each slice ---

  % ---------------------------
  % --- Finalise translation table
  % ---------------------------

  for (ii = 1:label-1)
    jj = ii;
    while ( tt(jj) ~= jj )
       jj = tt(jj);
    end;
    tt(ii) = jj;
  end;
 
  ttn = label-1; 


function rtn = check_previous_slice( r, c, sl, conn, ttn )
% --- *il,     Initial labelling map 
% --- r,      row 
% --- c,      column 
% --- sl,     slice 
% --- dim,    dimensions of il 
% --- conn,   Connectivity criterion 
% --- tt,     Translation table 
% --- ttn)    Size of translation table 

global dim tt il;

  rtn = 0;

  l=0;
  nabo = zeros(9,1);
  nr_set = 0;

  if (~sl) rtn = 0; return; end;
  
  if (conn >= 6)
    l = index_value( r, c, sl-1, dim);
    if (l) if ( il(l) ) nabo(nr_set+1) = il(l); nr_set = nr_set + 1; end; end;
  end;

  if (conn >= 18)
    if (r) 
      l = index_value( r-1, c, sl-1, dim ); 
      if (l) if ( il(l) ) nabo(nr_set+1) = il(l); nr_set = nr_set + 1; end; end;
    end;
    if (c) 
      l = index_value( r, c-1, sl-1, dim); 
      if (l) if ( il(l) ) nabo(nr_set+1) = il(l); nr_set = nr_set + 1; end; end;
    end;
    if (r < dim(1)-1) 
      l = index_value( r+1, c, sl-1, dim); 
      if (l) if ( il(l) ) nabo(nr_set+1) = il(l); nr_set = nr_set + 1; end; end;
    end;
    if (c < dim(2)-1) 
      l = index_value( r, c+1, sl-1, dim); 
      if (l) if ( il(l) ) nabo(nr_set+1) = il(l); nr_set = nr_set + 1; end; end;
    end;
  end;

  if (conn == 26)
    if (r && c) 
      l = index_value( r-1, c-1, sl-1, dim);
      if (l) if ( il(l) ) nabo(nr_set+1) = il(l); nr_set = nr_set + 1; end; end;
    end;
    if (r < dim(1)-1) && c
      l = index_value( r+1, c-1, sl-1, dim ); 
      if (l) if ( il(l) ) nabo(nr_set+1) = il(l); nr_set = nr_set + 1; end; end;
    end;
    if (r && (c < dim(2)-1) ) 
      l = index_value( r-1, c+1, sl-1, dim); 
      if (l) if ( il(l) )  nabo(nr_set) = il(l); nr_set = nr_set + 1; end; end;
    end;
    if (r < dim(1)-1) && (c < dim(2)-1) 
      l = index_value( r+1, c+1, sl-1, dim); 
      if (l) if ( il(l) )  nabo(nr_set+1) = il(l); nr_set = nr_set + 1; end; end;
    end;
  end;

  if (nr_set) 
    nabo = fill_translation_table( ttn, nabo, nr_set );
    rtn = nabo(1);
  else 
    rtn = 0;
  end;


function nabo = fill_translation_table(  atn, nabo, nr_set )
% --- *tt,       Translation table 
% --- ttn,       Size of translation table
% --- *nabo,     Set of neighbours 
% --- nr_set)    Number of neighbours in nabo
global dim tt il;

  cntr = 0;
  tn = [0 0 0 0 0 0 0 0 0];
% UINT_MAX	4294967295
  ltn = 4294967295;

  % ---
  % --- Find smallest terminal number in neighbourhood
  % ---

  for (ii = 1:nr_set)
    jj = nabo(ii);
    cntr=0;
    while ( tt(jj) ~= jj )
      jj = tt(jj);
      cntr = cntr + 1;
      if ( cntr > 100) fprintf('\nOoh no!!\n'); break; end;
    end;

    tn(ii) = jj;
    ltn = min(ltn,jj);
  end;

  % ---
  % --- Replace all terminal numbers in neighbourhood by the smallest one
  % ---

  for ( ii = 1:nr_set)
    tt(tn(ii)) = ltn;
  end;


function cl = translate_labels( ttn )
% --- il      Map of initial labels. 
% --- dim     Dimensions of il. 
% --- tt      Translation table. 
% --- ttn     Size of translation table. 
% --- l       Final map of labels. 
global dim tt il l;

  ml=0;
  cl = 0.0;

  n = prod(dim);

  for (ii = 1:ttn) ml = max( ml,tt(ii)); end;

  fl = zeros( ml, 1 );

  for (ii = 1:n)
    if (il(ii))
      if (~fl(tt(il(ii)))) 
        cl = cl + 1.0; 
        fl( tt(il(ii))) = cl;
      end;

      l(ii) = fl(tt(il(ii)));
    end;
  end;




function idx = index_value(R,C,S,DIM) 
  % --- original macro based on zero indexing ---
  idx = max( ( (S-1) * prod( DIM(1:2) ) ) + ( (C-1) * DIM(1) ) + R, 0 );
  

function mtx = resize_matrix( omtx, nsz )

  mtx = zeros( nsz ,1);
  sz = prod(size(omtx));
  mtx(1:sz) = omtx;


