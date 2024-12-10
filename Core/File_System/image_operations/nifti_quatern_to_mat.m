function R = nifti_quatern_to_mat( h )
% --- Given the quaternion parameters (etc.), compute a transformation matrix.
% --- 
% --- file nifti1_io.c
% ---     brief main collection of nifti1 i/o routines
% ---            - written by Bob Cox, SSCC NIMH
% ---            - revised by Mark Jenkinson, FMRIB
% ---            - revised by Rick Reynolds, SSCC, NIMH
% ---            - revised by Kate Fissell, University of Pittsburgh
% --- 
% ---    See comments in nifti1.h for details.
% ---      - qb,qc,qd = quaternion parameters
% ---      - qx,qy,qz = offset parameters
% ---      - dx,dy,dz = grid stepsizes (non-negative inputs are set to 1.0)
% ---      - qfac     = sign of dz step (< 0 is negative; >= 0 is positive)
% --- 
% ---    If qx=qy=qz=0, dx=dy=dz=1, then the output is a rotation matrix.
% ---    For qfac >= 0, the rotation is proper.
% ---    For qfac <  0, the rotation is improper.
% --- 
% ---    see "QUATERNION REPRESENTATION OF ROTATION MATRIX" in nifti1.h
% ---    see nifti_mat44_to_quatern, nifti_make_orthog_mat44,
% ---        nifti_mat44_to_orientation
% --- 
% --- Adapted for matlab Constrained Principle Component Analysis GUI
% ---  Apr 2012 - John Paiement  BCMHARI
% ---

  b = h.quatern_b;
  c = h.quatern_c;
  d = h.quatern_d;

  qfac = 1;
  if h.pixdim(1) < 0.0
    qfac = -1;
  end;

  R = zeros( 4 );
  R(4,:) = [ 0 0 0 1];			% --- last row is always [ 0 0 0 1 ] 

  a = 1.0 - (b*b + c*c + d*d) ;		% --- compute a parameter from quaterns b,c,d 
  if ( a < 1.e-7 )                	% --- special case 
    a = 1.0 / sqrt(b*b+c*c+d*d) ;
    b = b * a ; 			% --- normalize (b,c,d) vector
    c = c * a ; 
    d = d * a ; 
    a = 0.0 ;                       	% --- a = 0 ==> 180 degree rotation 
  else
    a = sqrt(a) ;                    	% ---  angle = 2*arccos(a)
  end;

  % --- load rotation matrix, including scaling factors for voxel sizes 
  xd = 1.0;        
  yd = 1.0;        
  zd = 1.0;        			% --- make sure are positive 
  if (h.pixdim(2) > 0.0)  xd = h.pixdim(2);  end;
  if (h.pixdim(3) > 0.0)  yd = h.pixdim(3);  end;
  if (h.pixdim(4) > 0.0)  zd = h.pixdim(4);  end;

  if ( qfac < 0.0 ) zd = zd * -1 ; end;	% --- left handedness? 

  R(1,1) =        (a*a+b*b-c*c-d*d) * xd ;
  R(1,2) = 2.0  * (b*c-a*d        ) * yd ;
  R(1,3) = 2.0  * (b*d+a*c        ) * zd ;
  R(2,1) = 2.0  * (b*c+a*d        ) * xd ;
  R(2,2) =        (a*a+c*c-b*b-d*d) * yd ;
  R(2,3) = 2.0  * (c*d-a*b        ) * zd ;
  R(3,1) = 2.0  * (b*d-a*c        ) * xd ;
  R(3,2) = 2.0  * (c*d+a*b        ) * yd ;
  R(3,3) =        (a*a+d*d-c*c-b*b) * zd ;

  R(1,4) = h.qoffset_x ;		% --- load offsets
  R(2,4) = h.qoffset_y ;
  R(3,4) = h.qoffset_z ;

