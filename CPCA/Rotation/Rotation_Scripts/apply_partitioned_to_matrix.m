function rtn = apply_partitioned_to_matrix( Gheader, mtx, GAtyp, pop )
% apply_partitioned_to_matrix( modelHeader, matrix_applied_to );
%
% applies a partitioned model such as G or GA to the given matrix
% matrix should be transposed in call if required
%    Gheader: required: the header from your process Model ( Gheader, GAheader etc... )
%
% usage:
%   apply_partitioned_to_matrix( Gheader, U );
%   apply_partitioned_to_matrix( Gheader, U );

global Zheader scan_information;
  if ( nargin < 3 )  GAtyp = 'G';  end;
  if ( nargin < 4 )  pop = struct( 'pb', 0 );  end;

  rtn = [];

  %------------------------------------------------
  %   struct Gheader
  %    'model_type',  0, ...		% FIR
  %    'conditions', 0, ...		% number of conditions
  %    'bins', 0, ...			% number of time bins
  %    'TR', 1, ...			% Timing Rate
  %    'inScans', 1, ...		% Timing Rate in seconds (0) or scans(1)
  %    'path_to_segs', '', ...		% path to the segmented ouptut
  %    'prefix', 'G', ...		% struct may be used for GA, H etc...
  %    'raw', 'Gn', ...			% name of raw segment var
  %    'norm', 'Gm', ...		% name of normalized segment var
  %    'condition_name', []   	 	% condition names
  %------------------------------------------------


  subject_display = 'Subject: %3d  Run: %2d';
  subject_clear = '\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b';

  %------------------------------------------------
  % multiply Gheader/Secondary against each segment of the Z matrix
  %------------------------------------------------
%  fprintf( '   - loading:     ');
%  fprintf( subject_display, 0, 0 );

  if ( strcmp( class(pop.pb), 'cpca_progress' ) )
    pop.pb.setIterations(Zheader.num_subjects * Zheader.num_runs);
  end;

  iterations = Zheader.num_subjects * Zheader.num_runs;
  start_pos = 1;

  for SubjectNo=1:Zheader.num_subjects

    sid = subject_id( SubjectNo );
    
%     G = [];
    if ( strcmp( class(pop.pb), 'cpca_progress' ) )
      pop.pb.setParticipant( SubjectNo, Zheader.num_subjects, sid );
    end;
   
    [G ~] = load_run_G( Gheader, SubjectNo, 0, ~strcmp( GAtyp, 'G' ) );
%     for RunNo=1:Zheader.num_runs
% 
%       if ( strcmp( class(pop.pb), 'cpca_progress' ) )
%         pop.pb.increment();
%       end;
% 
%       %------------------------------------------------
%       % load in the normalized Model segment
%       %------------------------------------------------
%       eval( [ 'load( ''' Gheader.path_to_segs  Gheader.prefix '_S' num2str(SubjectNo) '.mat'', ''' Gheader.norm ''' )' ] );
%       eval( [' G = [G; ' Gheader.norm '];' ] );
%       
%     end;  % each Run

    %------------------------------------------------
    % Apply G matrix 
    %------------------------------------------------

    end_pos = start_pos + size(G,2) - 1;
    extents = sprintf( '%d:%d', start_pos, end_pos );
    eval ( [ 'rtn = [rtn; G * mtx(' extents ',: ) ];' ] );

    start_pos = end_pos + 1;

  end;  % each Subject


  if ( strcmp( class(pop.pb), 'cpca_progress' ) )
    pop.pb.clearParticipant();
    pop.pb.clearRun();
  end;


