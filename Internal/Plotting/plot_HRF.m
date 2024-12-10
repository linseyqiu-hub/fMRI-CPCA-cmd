function plot_HRF( out_dir, PR, Gheader, params )
global Zheader scan_information 


  nconds = scan_information.processing.model.parameters.conditions;
  nbins = scan_information.processing.model.parameters.bins;

  if ~isfield( params, 'method' )
    params.method = 'unrotated';
  end;

  if ~isfield( params, 'htype' )
    params.htype = '';
  end
  if ~isempty( params.htype )
    params.htype = [ '_' params.htype];
  end
  
  for comp = 1:size(PR,2)

    pr_comp = [];
    pr_graphdata = [];

    for cond = 1:nconds
      pr_cond = [];

      for SubjectNo = 1:Zheader.num_subjects

        [encoded sr er] = PR_condition_position( SubjectNo, cond, Gheader );
        if encoded
          temp = PR(sr:er,comp);
          pr_cond(:,SubjectNo) = temp;
        else   % --- condition non encoded pad out the array 
          pr_cond = [pr_cond zeros(nbins, 1) ];
        end;
          
      end;  % each subject

      pr_cond = pr_cond';
      pr_comp = [pr_comp  pr_cond];

      if ( Zheader.num_subjects > 1 )
         pr_graphdata = [pr_graphdata transpose(mean(pr_cond))];
      else
        pr_graphdata = [pr_graphdata transpose(pr_cond)];
      end;

    end;  % --- each condition ---

    minmax = min_max_limits( pr_graphdata );

    h = figure; 
    set(h,'Visible', 'off' ); 
    plot( pr_graphdata, '-' );

    fh = get(h, 'CurrentAxes' );
    set(fh,'YLim',minmax);
    set(fh,'XGrid','on'); 

    xtl = [0];
    for ii = 0:nbins
      xtl = [xtl ii*scan_information.processing.model.parameters.TR];   
    end;
    set( fh, 'XtickLabel', xtl )
    set( fh, 'Xtick', 0:nbins );	

    legend( Zheader.conditions.Names, 'Location', 'Best' );

    txt = '';
    if isfield( params, 'text' )
      txt = strrep( params.text, '_', ' ');
    end;

    ttle = ['Estimated HDR ' params.method ' Component ' num2str( comp ) ' ' txt ];
    title( ttle );
    set( h, 'NumberTitle' , 'off' );
    set( h, 'Name' , ttle );

    params.defaults.component = comp;
    params.defaults.var = '';    % --- we need to force this off 
    filename = fs_filename( 'png', ['Estimated_HDR' params.htype], params.method, params.defaults );
    saveas( h, [out_dir filename] );
    clear h

  end;

