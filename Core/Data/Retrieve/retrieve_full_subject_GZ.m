function retrieve_full_subject_GZ( Gheader, SubjectNo, varname )
global Zheader scan_information
% --- collect all frequencies for subject

  if nargin < 3
    varname = 'GZ';
  end;

  nfreq = max(scan_information.frequencies, 1);
  assignin( 'caller', varname, zeros( sum( sum( Zheader.conditions.encoded(1).condition ) ) * Gheader.bins, Zheader.total_columns * nfreq ) );

  ec = 0;
  for freq = 1:max(scan_information.frequencies, 1)
    ftag = frequency_tag( freq );
    sc = ec + 1;
    ec = sc + Zheader.total_columns - 1;
    portion = [ '(:,' num2str(sc) ':' num2str(ec) ')' ];

    GZname = [ Gheader.GZheader.path_to_segs 'GZ_S' num2str(SubjectNo) ftag '.mat'];

    n = matfile_vars( Gheader.GZheader.path_to_segs, ['GZ_S' num2str(SubjectNo) ftag '.mat'], 'GZ_R*' );
    if isempty(n)
      GZname = [ Gheader.GZheader.path_to_segs 'GZ_S' num2str(SubjectNo) '.mat'];
      n = matfile_vars( Gheader.GZheader.path_to_segs, ['GZ_S' num2str(SubjectNo) ftag '.mat'], 'GZ_R*' );
    end;
    
    for RunNo = 1:Zheader.num_runs
      if isEncodedRun( SubjectNo, RunNo ) 
        evalin( 'caller', [ 'load( ''' GZname ''', ''GZ_R' num2str(RunNo) ftag ''');'] );  
        evalin( 'caller', [ varname portion ' = ' varname portion ' + GZ_R' num2str(RunNo) ftag ';'] );
        evalin( 'caller', [ 'clear GZ_R' num2str(RunNo) ftag ] );  
      end;
    end;

    
  end;
  
end


