function [SCALE,DCOFF] = scaling_values( hdr )

  SCALE		= 1;
  DCOFF 	= 0;

  if ( nifti_version( hdr) == 0 )		% analyse 7.x version

    if isfinite(hdr.funused1) & hdr.funused1,

      SCALE = hdr.funused1;
      if isfinite(hdr.funused2),
        DCOFF = hdr.funused2; 	%DCoffset
      else,
        DCOFF = 0;
      end;

    else,

      if hdr.glmax-hdr.glmin & hdr.cal_max-hdr.cal_min,
        SCALE = (hdr.cal_max-hdr.cal_min)/(hdr.glmax-hdr.glmin);
        DCOFF = hdr.cal_min - SCALE *hdr.glmin;

        %if hdr.dime.funused1,
          %warning(['Taking scalefactor etc from glmax/glmin & cal_max/cal_min of "' fname '".']);
        %end;

      else,
        SCALE= 1;
        DCOFF = 0;
        warning('Assuming a scalefactor of 1');
      end;

    end;

  else

    SCALE = hdr.scl_slope;
    DCOFF = hdr.scl_inter;

  end;
