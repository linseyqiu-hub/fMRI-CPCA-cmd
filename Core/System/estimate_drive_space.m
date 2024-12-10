function estimated_drive_space = estimate_drive_space( Zheader, Gheader ) 
  % ----------------------------------------------------------------
  % --- drive space requirements estimation
  % ----------------------------------------------------------------

global scan_information

  estimated_drive_space = struct ( ...
    'Zmat', 0, ...
    'Gmat', 0, ...
    'GZmat', 0, ...
    'Extra', 0, ...
    'Total', 0 );

  sz = struct ( ...
    'bytes'    , 0, ...
    'kilobytes', 0, ...
    'megabytes', 0, ...
    'gigabytes', 0, ...
    'sz_display', 'N/A', ...
    'mem_display', 'N/A');

  total_bytes = 0;

  if ( Zheader.MeanCentered | Zheader.Normalized )	% no need for Z extents as they are already applied
    estimated_drive_space.Zmat = sz;
  else

    % ----------------------------------------------------------------
    % --- even though the Z matrix is broken into segments, it still consumes the full size in drive space
    % ----------------------------------------------------------------

    array_extents =   [Zheader.total_scans (Zheader.total_columns * max(1, scan_information.frequencies))];
    estimated_drive_space.Zmat = array_sizes( array_extents );
    total_bytes = estimated_drive_space.Zmat.bytes * 2;   % we save full Z and E
  end;


  if ( nargin > 1 )	% we have a supplied G header

    % ----------------------------------------------------------------
    % --- G matrix is saved in several calculated parts
    % ---   Gn  - the raw G data  ( all 1's and 0's )  		( # scans, conditions * bins * subjects )
    % ---   Gm  - the normalized G data  		  	( # scans, conditions * bins * subjects )
    % ---   GG  - calculated G' * G  		  		( conditions * bins * subjects, conditions * bins * subjects )
    % ---   gg  - sqrtm(inv(GG))	  		  	( conditions * bins * subjects, conditions * bins * subjects )
    % ---   Ggg  - Gm * gg	 		  		( # scans, conditions * bins * subjects )
    % ----------------------------------------------------------------

    GWidth = Gheader.conditions * Gheader.bins * Zheader.num_subjects;

    if ( scan_information.processing.model.applied.apply_g )
      estimated_drive_space.Gmat = sz;

    else 
      array_extents =   [(Zheader.total_scans * 3 * max(1, scan_information.frequencies)) + (GWidth * 2), GWidth * 5];
      estimated_drive_space.Gmat = array_sizes( array_extents );
      total_bytes = total_bytes + estimated_drive_space.Gmat.bytes;

      % ----------------------------------------------------------------
      % --- GZ matrix contains several precalculated extraction elements in several files
      % ---   GZ_S{n}
      % ---     GZ_{n} - each subject run G'*Z segment 		( conditions * bins * subjects, Zheader.total_columns )
      % ---   GC_S{n}
      % ---     GC_R{n}_C{m}  - each subject run GC Columns	( Zheader.total_scans, Zheader.total_columns)
      % ---   GE_S{n}
      % ---     E_R{n}_C{m}  - each subject run E Columns	( Zheader.total_scans, Zheader.total_columns)
      % ---   GB_S{n}
      % ---     B{n}   - each subject run B matrix segment	( conditions * bins * subjects, Zheader.total_columns )
      % ---   BG       - the fully created B matrix		( conditions * bins * subjects, Zheader.total_columns )
      % ---   BBG      - the fully created BB matrix		( conditions * bins * subjects, conditions * bins * subjects )
      % ----------------------------------------------------------------

      array_extents =   [(Zheader.total_scans * 2) + (GWidth * 4), (GWidth * 5) + (Zheader.total_columns * 3 * max(1, scan_information.frequencies))];
      estimated_drive_space.GZmat = array_sizes( array_extents );
      total_bytes = total_bytes + estimated_drive_space.GZmat.bytes;

    end;

    % ----------------------------------------------------------------
    % --- Extraction output 	each contains several large arrays
    % ---  U 		( Zheader.total_scan, # components )
    % ---  UR		( Zheader.total_scan, # components )
    % ---  V 		( Zheader.total_columns, # components )
    % ---  VR 		( Zheader.total_columns, # components )
    % ---  U etc (4)	( conditions * bins * subjects, # components )
    % ----------------------------------------------------------------

  		        % base on each component requirement
    array_extents =   [( Zheader.total_scans * 2 ) + (Zheader.total_columns * 2 ) + GWidth, 1 ];
    estimated_drive_space.Extra = array_sizes( array_extents );
    total_bytes = total_bytes + estimated_drive_space.Extra.bytes;

  else

    estimated_drive_space.Gmat = sz;
    estimated_drive_space.GZmat = sz;
    estimated_drive_space.Extra = sz;

  end;

  estimated_drive_space.Total = array_sizes( [1, 1] );
  estimated_drive_space.Total.bytes = total_bytes;

  estimated_drive_space.Total.kilobytes = estimated_drive_space.Total.bytes / 1024;
  estimated_drive_space.Total.megabytes = estimated_drive_space.Total.kilobytes / 1000;
  estimated_drive_space.Total.gigabytes = estimated_drive_space.Total.megabytes / 1000;

  estimated_drive_space.Total.sz_display = ''; 
  estimated_drive_space.Total.mem_display = ''; 
  if ( floor( estimated_drive_space.Total.gigabytes ) > 0 ) 
    estimated_drive_space.Total.mem_display = sprintf( '%9.02f Gb', estimated_drive_space.Total.gigabytes ); 
    return; 
  end;

  if ( floor( estimated_drive_space.Total.megabytes ) > 0 ) 
    estimated_drive_space.Total.mem_display = sprintf( '%9.02f Mb', estimated_drive_space.Total.megabytes ); 
    return; 
  end;

  if ( floor( estimated_drive_space.Total.kilobytes ) > 0 ) 
    estimated_drive_space.Total.mem_display = sprintf( '%9.02f Kb', estimated_drive_space.Total.kilobytes ); 
    return; 
  end;

  sz.mem_display = sprintf( '%10d bytes', estimated_drive_space.Total.bytes );






