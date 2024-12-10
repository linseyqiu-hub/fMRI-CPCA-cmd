function  [pthAdd segDir ] = A_path_spec( Hheader, model )

  pthAdd = '';
  if Hheader.Hindex > 1   % --- the first level H is always on main directory
    if ~isempty( Hheader.model(Hheader.Hindex).id )
      pthAdd = [ Hheader.model(Hheader.Hindex).id filesep ];
      pthAdd = strrep( pthAdd, ' ', '_' );
    else
      pthAdd = ['H_' num2str(Hheader.Hindex, '%02d') filesep ];
    end;
  end;

  segDir = os_path( [pwd filesep 'Hsegs' filesep model filesep pthAdd ] );

