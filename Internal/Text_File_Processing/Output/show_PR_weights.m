function show_PR_weights(PR, VR, Hheader, sort_it, fid )
% --- only callable when H is created within GUI

  if nargin < 4
    return;         % --- this function only outputs to an open file
  end;
  
  if fid <= 0
    return;
  end;

%  if nargin < 3
%    sort_it = 0;
%  end;

  sort_it = 0;
  
  if sort_it
    [n idx] = sort( PR );
  else
    idx = 1:size(PR,1);
  end;
  
  load( [Hheader.model(Hheader.Hindex).path Hheader.model(Hheader.Hindex).file], 'RegionLabels' );
  if ~isfield( Hheader, 'thisH' )
    H = load_H_matrix( Hheader, 1 );
  else
    H = Hheader.thisH;
  end;
  
  fprintf( fid, '\nH matrix predictor weights\n\nColumn     Weight   Region\n' );

  for ii = 1:size(PR,1)

    str = num2str(idx(ii));
    lbl = '';
    if exist( 'RegionLabels', 'var' );
       lbl = char(RegionLabels(ii));
    end;

    %x = find( H(:,ii) > 0 );    % --- normalized H will have all negative values for 0
    %if isempty(x)
    %  x = find( H(:,ii) < 0 );    % --- normalized H will have all negative values for 0
    %end;
    
    %y = VR(x(:));
    %if isempty(y)
    %  y = [0];
    %end
    %fprintf( fid,  '%6s   %8.4f   %s\n', str, y(1), lbl );

    fprintf( fid,  '%6s   %8.4f   %s\n', str, PR(idx(ii)), lbl );

  end;
  
  fprintf( fid, '\n' );


