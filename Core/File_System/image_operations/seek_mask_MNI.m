function mask_offset = seek_mask_MNI( seekMNI )
global scan_information 

  mask_offset = 0;

  x = find( scan_information.mask.MNI(1,:) == seekMNI(1) ...
   &  scan_information.mask.MNI(2,:) == seekMNI(2) ...
   &  scan_information.mask.MNI(3,:) == seekMNI(3));

  if prod(size(x)) == 1
    mask_offset = x;
  end;

  
