function retrieve_subject_GMH_C( Hheader, SubjectNo, ftag, varname  )
global Zheader

  if nargin < 4
    varname = 'C';
  end;
  if nargin < 3
    ftag = '';
  end;

  
  evalin( 'caller', [ varname ' = [];' ] );
  fn = [ 'C_S' num2str(SubjectNo) ftag '.mat'];

  if ~isempty( ftag )
    n = matfile_vars( Hheader.model(Hheader.Hindex).path_to_segs.GMH, fn, 'C_C*' );
    if isempty(n)
      fn = [ 'C_S' num2str(SubjectNo) '.mat'];
    end;
  end;

  n = matfile_vars( Hheader.model(Hheader.Hindex).path_to_segs.GMH, fn, 'C_C*' );
  if ~isempty( n)  % --- horizontal segments of C discovered

    fn = [Hheader.model(Hheader.Hindex).path_to_segs.GMH fn];
    
    x = n(1).sz_x;
    y = 0;
    for ii = 1:size(n,1)    
      y = y + n(ii).sz_y;
    end;
        
    evalin( 'caller', [ varname ' = zeros(' num2str(x) ',' num2str(y) ');' ] );
    
    ec = 0;
    for ii = 1:size(n,1)
      sc = ec + 1;
      evalin( 'caller', [ 'load( ''' fn ''', ''C_C' num2str(ii) ''');' ] );

      % --- results from matfile_vars alphabetical, not necessarily sorted properly
      x = evalin( 'caller', [ 'size( C_C' num2str(ii) ');' ] );
%      ec = sc + n(ii).sz_y - 1;
      ec = sc + x(2) - 1;

      evalin( 'caller', [ varname '(:,' num2str(sc) ':' num2str(ec) ') = C_C' num2str(ii) ';' ] );
      evalin( 'caller', [ ' clear C_C' num2str(ii) ';' ] );
    end
    
  else
      
    fn = [ 'GMH_S' num2str(SubjectNo) ftag '.mat'];
    n = matfile_vars( Hheader.model(Hheader.Hindex).path_to_segs.GMH, fn, 'C' );
    if ~isempty( n)  % --- horizontal segments of C discovered
      fn = [Hheader.model(Hheader.Hindex).path_to_segs.GMH fn];
      evalin( 'caller', [ 'load( ''' fn ''', ''C'');' ] );
    end;
    
  end;
  
end


