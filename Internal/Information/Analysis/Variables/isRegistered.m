function yn = isRegistered( msk )
% --- masks registered to the Harvard Oxfor atlas will have
% --- numeric separation between types
% ---
% --- 0 for out of range,   1 for gray matter
% --- 2 for white matter,   3 for ventricles
% --- 4 for brain stem,     5 for cerebellum
% ---
% ---  some registered masks will now have the venticles and white matter
% ---  removed from the final mask ( may 28 2014 ).
% ---  determining if the mask has been registered to the HArvard Oxfrod
% ---  atlas will require the number of unique element in the mask to be 
% ---     6 < unique elements > 1
% ---
% --- NOTE:  this may cause false negative on mask with only gray matter
% ---         indicated, but I doubt that cfan be helped )

  yn = numel(unique( msk.image(msk.ind) )') > 1 && ...
       numel(unique( msk.image(msk.ind) )') < 6;
  
end

