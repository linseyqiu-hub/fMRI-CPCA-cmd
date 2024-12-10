function tal_index = seek_mask_region_index( seekMNI )
global scan_information 

  tal_index = 0;

  x = find( scan_information.mask.MNI(1,:) == seekMNI(1) ...
   &  scan_information.mask.MNI(2,:) == seekMNI(2) ...
   &  scan_information.mask.MNI(3,:) == seekMNI(3));

  if prod(size(x)) == 1

    y = find(  scan_information.mask.tal_index(:,5) == x );

    if prod(size(y)) == 1
      tal_index = scan_information.mask.tal_index(y,1);
    end;

  end;

  
