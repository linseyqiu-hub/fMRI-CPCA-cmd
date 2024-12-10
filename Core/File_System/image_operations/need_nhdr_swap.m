function needs_swap = need_nhdr_swap( dim0, hdrsize )
% --- ----------------------------------------------------------------------
% ---  check whether byte swapping is needed
% ---  
% ---  dim[0] should be in [0,7], and sizeof_hdr should be accurate
% --- 
% --- returns  > 0 : needs swap
% ---            0 : does not need swap
% ---          < 0 : error condition
% --- ----------------------------------------------------------------------

  needs_swap = 0;

  if( dim0 ~= 0 )	     		% --- then use it for the check
       
    if( dim0 > 0 && dim0 <= 7 ) return; end;

    dim0 = cpca_swap16(1, dim0 ); 	% ---  swap? 
    if( dim0 > 0 && dim0 <= 7 ) needs_swap = 1; return;  end;

    needs_swap = -1;			% --- bad, naughty d0 
    return;
  end; 

  % --- dim[0] == 0 should not happen, but could, so try hdrsize
  % --- NOTE: header size set for analyze and NIFT1 - adjust later for NIFTI2
  if( hdrsize == 348 ) return;  end;

  hdrsize = cpca_swap16(1, hdrsize );     % --- swap? 
  if( hsize == 348 ) needs_swap = 1; return;  end;

  needs_swap = -2;     % --- bad, naughty hsize


