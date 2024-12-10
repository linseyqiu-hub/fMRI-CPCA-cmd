function [TimeSeries Voxels] = get_subject_scan_count( SubjectNo, RunNo, FrequencyNo )
% determine number of scans and column count for a subject
%
% return the row/column values only
global scan_information Zheader 

  if nargin < 2		% our subject run number defaults to 1
    RunNo = 1;
    FrequencyNo = 1;
  end;

  if nargin < 3		% our subject run number defaults to 1
    FrequencyNo = 1;
  end;

  sdir = subject_scan_directory( SubjectNo, RunNo, FrequencyNo);

  filespec = [sdir filesep char(scan_information.ListSpec)];
  D = dir(filespec);

  if isfield( scan_information.mask, 'ind' )
    mask_sz = size( scan_information.mask.ind );
  else
    mask_sz = [0 0];
  end;

  % --------------------------------------------------------
  % read directory and process individual files
  [TimeSeries Voxels] = size(D);

  if ( TimeSeries > 0 )

    filespec = [sdir filesep D(1).name];
    img = cpca_read_vol( filespec );

    if ( ~isfield( img.header, 'error' ) )
      if ( SubjectNo == 1 & RunNo == 1 )
        scan_information.raw_data.header = img.header;
        scan_information.raw_data.img = img;
      end;

      if ( mask_sz(1) > 0 )
        Z(1,:) = img.image( scan_information.mask.ind );
        sz = size(Z);
        Voxels = sz(2);
      else
        dim = img.vol.dim;
        Voxels= prod(dim);
      end;
 
    else
      Voxels= 0;
    end;
    
  else
    Voxels = -1;
  end;
  
  

