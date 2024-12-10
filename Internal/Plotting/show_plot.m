function show_plot( mtx, p, ttle, new_fig )

  if ( nargin < 4 ) new_fig = 1; end;		% default to plot in new figure

  plotstyles = struct ( 'linestyles', []', 'markers', [], 'colors', [], 'keys', [] );
  plotstyles.linestyles = struct ( 'symbol', '', 'text', '<none>' ) ;
  plotstyles.linestyles = vertcat(plotstyles.linestyles , struct ( 'symbol', '-', 'text', 'solid' ) ) ;
  plotstyles.linestyles = vertcat(plotstyles.linestyles , struct ( 'symbol', '--', 'text', 'dashed' ) ) ;
  plotstyles.linestyles = vertcat(plotstyles.linestyles , struct ( 'symbol', ':', 'text', 'dotted' ) ) ;
  plotstyles.linestyles = vertcat(plotstyles.linestyles , struct ( 'symbol', '-.', 'text', 'dash dot' ) ) ;

  plotstyles.markers = struct ( 'symbol', '', 'text', '<none>' ) ;
  plotstyles.markers = vertcat(plotstyles.markers , struct ( 'symbol', '+', 'text', 'plus sign' ) ) ;
  plotstyles.markers = vertcat(plotstyles.markers , struct ( 'symbol', 'O', 'text', 'circle' ) ) ;
  plotstyles.markers = vertcat(plotstyles.markers , struct ( 'symbol', '*', 'text', 'asterisk' ) ) ;
  plotstyles.markers = vertcat(plotstyles.markers , struct ( 'symbol', '.', 'text', 'point' ) ) ;
  plotstyles.markers = vertcat(plotstyles.markers , struct ( 'symbol', 'x', 'text', 'cross' ) ) ;
  plotstyles.markers = vertcat(plotstyles.markers , struct ( 'symbol', 's', 'text', 'square' ) ) ;
  plotstyles.markers = vertcat(plotstyles.markers , struct ( 'symbol', 'd', 'text', 'diamond' ) ) ;
  plotstyles.markers = vertcat(plotstyles.markers , struct ( 'symbol', '^', 'text', 'triangle up' ) ) ;
  plotstyles.markers = vertcat(plotstyles.markers , struct ( 'symbol', 'v', 'text', 'triangle down' ) ) ;
  plotstyles.markers = vertcat(plotstyles.markers , struct ( 'symbol', '>', 'text', 'triangle right' ) ) ;
  plotstyles.markers = vertcat(plotstyles.markers , struct ( 'symbol', '<', 'text', 'triangle left' ) ) ;
  plotstyles.markers = vertcat(plotstyles.markers , struct ( 'symbol', 'p', 'text', 'pentagram' ) ) ;
  plotstyles.markers = vertcat(plotstyles.markers , struct ( 'symbol', 'h', 'text', 'hexagram' ) ) ;



  % ------------------------------------------
  % initialize the components name list if it doesn't exist
  % ------------------------------------------
  if isfield( p, 'component_name' )
    % x is our component count
    [x y] = size(p.component_name );
  else
    x = 0;
  end;

  if ( x == 0 )
    for ( ii = 1:p.conditions )
      str = ['Component ' num2str(ii)];
      if ( ii == 1 ) 
        p.component_name = {str};
      else
        p.component_name = [p.component_name; {str}];
      end;
    end;
  end;


    if ( new_fig == 1 )
      ph = figure;
    end;

    use_selected = 0;
    use_this = 1;

    if ( p.plotting.use_extended ==  1 )

      % individual line styling plots
    
      for ( ii = 1: p.conditions )

        p2 = '';
        if ( p.plotting.extended.plotting(ii).settings.markerstyle > 1 )
          p2 = plotstyles.markers(p.plotting.extended.plotting(ii).settings.markerstyle).symbol;
        end;

        if ( p.plotting.extended.plotting(ii).settings.linestyle > 1 )
          p2 = [p2 plotstyles.linestyles(p.plotting.extended.plotting(ii).settings.linestyle).symbol ];
        end;

        p3 = '';
      
        clrtext = color2text( p.plotting.extended.plotting(ii).settings.linecolor);
        if ( ~isempty( clrtext ) )
          p3 = [p3 ', ''Color'', ' clrtext ];
        end;

        if ( p.plotting.global.line.size > 1 )
          p3 = [p3 ', ''LineWidth'', ', num2str(p.plotting.global.line.size) ];
        end;

        p3 = [p3 ', ''MarkerSize'', ' num2str(p.plotting.extended.plotting(ii).settings.markersize) ];
      
        clrtext = color2text( p.plotting.extended.plotting(ii).settings.markercolor);
        if ( ~isempty( clrtext ) )
          p3 = [p3 ', ''MarkerFaceColor'', ' clrtext ];
        end;

        if ( p.plotting.extended.plotting(ii).settings.markeredge == 1 ) 
          clrtext = color2text( p.plotting.extended.plotting(ii).settings.edgecolor);
          if ( ~isempty( clrtext ) )
            p3 = [p3 ', ''MarkerEdgeColor'', ' clrtext ];
          end;
        end;

        parms = ['''' p2 '''' p3];
        eval ( ['plot( mtx(:,' num2str(ii) '), ' parms ' );'] );
        hold on;

      end;
      hold off;
    
    else

      if ( isfield( p.plotting, 'use_selected_conditions' ) )
        use_selected = p.plotting.use_selected_conditions ;
      end;
      
      if ( use_selected )
        use_this = 0;
        new_mtx = [];
        for ii = 1:size(p.plotting.selected_conditions,1)
          for ( jj = 1: p.conditions )
             if (strcmp( p.plotting.selected_conditions(ii), p.condition_name(jj)) ) new_mtx = [new_mtx mtx(:,jj)]; end;
          end;
        end;
      end;
  
      % global options plotting only
      p2 = '';
      if ( p.plotting.global.marker.style > 1 )
        p2 = plotstyles.markers(p.plotting.global.marker.style).symbol;
      end;

      if ( p.plotting.global.line.style > 1 )
        p2 = [p2 plotstyles.linestyles(p.plotting.global.line.style).symbol];
      end;

      p3 = '';

      if ( p.plotting.global.line.size > 1 )
        p3 = [p3 ', ''LineWidth'', ', num2str(p.plotting.global.line.size) ];
      end;

      if ( p.plotting.global.marker.size > 1 )
        p3 = [p3 ', ''MarkerSize'', ', num2str(p.plotting.global.marker.size) ];
      end;

      clrtext = color2text( p.plotting.global.marker.color );
      if ( ~isempty( clrtext ) )
        p3 = [p3 ', ''MarkerFaceColor'', ' clrtext ];
      end;

      if ( p.plotting.global.marker.edge == 1 ) 
        clrtext = color2text( p.plotting.global.marker.edgecolor );
        if ( ~isempty( clrtext ) )
          p3 = [p3 ', ''MarkerEdgeColor'', ' clrtext ];
        end;
      end;

      parms = ['''' p2 '''' p3];
      if ( use_selected )
        eval ( ['plot( new_mtx, ' parms ' );'] );
      else
        eval ( ['plot( mtx, ' parms ' );'] );
      end;
    end;
  

    if ( length(p.plotting.global.label.x_axis) > 0 )
      xlabel( p.plotting.global.label.x_axis );
    end;

    if ( length(p.plotting.global.label.y_axis) > 0 )
      ylabel( p.plotting.global.label.y_axis );
    end;


    if ( new_fig == 1 )

      if length ( p.plotting.global.label.title ) > 0 
        plot_title = p.plotting.global.label.title;
      else 
        plot_title = ttle;
      end;

      if ( length( ttle) > 0 )
        set( ph, 'NumberTitle' , 'off' );
        set( ph, 'Name' , ttle );
      end;

      if ( length( plot_title) > 0 )
        title( plot_title );
      end;

    end;

    if ( p.plotting.global.label.legend > 0 )
      if ( use_selected )
        legend( p.plotting.selected_conditions, 'Location', 'Best' );
      else
        legend( p.condition_name, 'Location', 'Best' );
      end;
    end;
  

  if ( new_fig == 1 )
    ax = get( ph, 'CurrentAxes' );
  else
    if ( isfield( p.plotting.global, 'axes' ) )
      ax = p.plotting.global.axes;
    end
  end;

  if ~isempty(ax)
    if ( p.TR > 1 )
      xtl = [0];
      for ii = 1:p.bins
        xtl = [xtl ii*p.TR];
      end;
      set( ax, 'XtickLabel', xtl )
    end;

    if ( isfield( p.plotting.global.label, 'xgrid' ) )       set(ax,'XGrid',p.plotting.global.label.xgrid);   end;
    if ( isfield( p.plotting.global.label, 'ygrid' ) )       set(ax,'YGrid',p.plotting.global.label.ygrid);   end;
    if ( isfield( p.plotting.global.label, 'ylim' ) )        set(ax,'YLim',p.plotting.global.label.ylim);   end;

  end;


