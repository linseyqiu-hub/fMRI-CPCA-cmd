function retrieve_GM( Hheader )
global Zheader

  ep = 0;
  for SubjectNo = 1:Zheader.num_subjects

    GMName = [ Hheader.model(Hheader.Hindex).path_to_segs.GMH 'GMH_S' num2str(SubjectNo) '.mat'];
    evalin( 'caller', [ 'A = load( ''' GMName ''', ''GM'' );' ] );

    if SubjectNo == 1
      evalin( 'caller', ['GM = zeros( Zheader.total_scans, size(A.GM, 2 ) );' ] );
    end;
    
    sp = ep + 1;
    ep = sp + sum( Zheader.timeseries.subject(SubjectNo).run(:,1) ) - 1;
    evalin( 'caller', [ 'GM( ' num2str(sp) ':' num2str(ep) ', :) = A.GM;' ] ) ;

  end;



