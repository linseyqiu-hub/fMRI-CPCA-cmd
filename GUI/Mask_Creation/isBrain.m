function vox = isBrain( msk, MNI )

  vox = 0;

  x = find( msk.MNI(1,:) == MNI(1) );

  y = find( msk.MNI(2,x(:) ) == MNI(2) );
  y1 = x(y(:));

  z = find( msk.MNI(3,y1(:)) == MNI(3) );
  
  if size(z,2) == 1
    if msk.image(y1(z) )
      vox = y1(z);
    end
  end;

  
