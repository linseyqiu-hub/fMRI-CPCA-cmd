function utility_toolkit( toolkit )
% --- syntax:  utility_toolkit( toolmenu )
% ---
% --- creates a dynamic toolbar window with created buttone for tools
% --- tools list created form definition file
% --- 
% --- toolmenu can be any definition file stu up for a specific purpose
% --- default will be the included generic toolbox

import javax.swing.*;
import java.awt.*;
 
  min_title_width = 20;
  xdimpad = 30;
  controlpad = 3;
  
  titledepth = 18;
  buttondepth = 16;

  
  if nargin < 1
    toolkit = 'toolkit.def';
  end
  tools = [constant_define( 'TOOLS_PATH' ) toolkit ];
  
  layout  = read_definition_data( tools, [], 'Tools' );
  layout.cat = [];
  layout.tools = [];
  
  for ii = 1:size( layout.vars.category, 1 )
    n = read_definition_data( tools, [], char( layout.vars.category(ii) ) );
    cat = struct( 'tool', [] );
    if str2double(n.vars.num_tools)
      for cattool = 1:str2double(n.vars.num_tools)
        tool = read_definition_data( tools, [], [ char( layout.vars.category(ii) ) ' : Tool ' num2str(cattool) ] ); 
        cat.tool = [cat.tool; tool.vars ];
      end
    end
    layout.cat = [layout.cat; cat ];  
    layout.tools = [layout.tools size( cat.tool, 1 )];
    
  end
  
  
  if length(layout.vars.title) < min_title_width 
    title = center_text( layout.vars.title, min_title_width );
  end
 
  
  xdim = (length(title) * 12.5) + xdimpad;
  ydim = zeros(1, size( layout.vars.category, 1 ) );

  for ii = 1:size( layout.vars.category, 1 )
    ydim(ii) = titledepth + (ii-1)*controlpad;
    ydim(ii) = ydim(ii) + size(layout.cat,1) * buttondepth + controlpad;
  end
  pydim = sum(ydim) + 35;
  pydim = pydim + ( (size( layout.cat,1) + sum( layout.tools ) - 1) * controlpad ) ;
  
%  % --- debug sizing issues
%  fprintf('\nMain Window: %.2f x %d\n' , xdim, pydim );
%  fprintf('  Section 1: %.2f x %d\n' , xdim, ydim(1) ) ;

 
  jMsg = JDialog([], 'msgWindow', 0);

  jMsg.setAlwaysOnTop(1);
  jMsg.setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
  jMsg.setPreferredSize( Dimension( xdim, pydim ) );
  jMsg.getContentPane().setBackground( Color( rgbvalue(236),  rgbvalue(236),  rgbvalue(223) ) );

  jMsg.setTitle( title );
  
  % Main panel
  mainPanel = JPanel(BorderLayout());
  mainPanel.setLayout( BoxLayout(mainPanel, BoxLayout.PAGE_AXIS));
  mainPanel.setBackground( Color( rgbvalue(236),  rgbvalue(236),  rgbvalue(223) ) );
%   mainPanel.setHorizontalAlignment( 0.5 );
  
  jMsg.getContentPane.add(mainPanel);
 
  for ii = 1:size( layout.vars.category, 1 )

    if ii > 1
      mainPanel.add(Box.createRigidArea( Dimension(0,controlpad)));
    end;        

    html = '<html><body><div style="text-align:center;  font-weight:bold; font-size: 14; font-family: sans-serif;">';
    jMsgTitle = JTextPane();
    jMsgTitle.setPreferredSize( Dimension( xdim, titledepth ) );
    jMsgTitle.setContentType('text/html');
    jMsgTitle.setText( [html char(layout.vars.category(ii)) '<br></div></body></html>'] );
    jMsgTitle.setEditable( false );
    jMsgTitle.setBackground( Color(  rgbvalue(208),  rgbvalue(220),  rgbvalue(255) ) );
%    jMsgTitle.setBackground( Color(  rgbvalue(100),  rgbvalue(100),  rgbvalue(100) ) );

    mainPanel.add( jMsgTitle );
%     catPanel.add( jMsgTitle );
    
    for jj = 1:size(layout.cat(ii).tool,1)
      mainPanel.add(Box.createRigidArea( Dimension(0,controlpad)));
      
      jButton = JButton( center_text( char(layout.cat(ii).tool(jj).label), min_title_width - 5) );
      jButton.setBounds (  Rectangle ( ((jj-1)*titledepth), xdim, xdim - 2, buttondepth) );
      jButton.setBackground( Color(  rgbvalue(204),  rgbvalue(204),  rgbvalue(204) ) );
      jButton.setPreferredSize( Dimension( xdim - 2, buttondepth) );

      parmstr = [];
      if isfield( layout.cat(ii).tool(jj), 'parameters' )
        if size( layout.cat(ii).tool(jj).parameters,1) > 0
          for p = 1:size( layout.cat(ii).tool(jj).parameters,1)
            parmstr = [parmstr '"' char(layout.cat(ii).tool(jj).parameters(p) ) '"' ];
          end
        end
      end
      set_callback(jButton, 'ActionPerformedCallback', @buttonPress_Callback );  
      set_callback(jButton, 'ToolTipText', [char(layout.cat(ii).tool(jj).action) '(' parmstr ');' ] );  
   
      mainPanel.add( jButton );

    end

  end

  % Display figure
  jMsg.pack();
  jMsg.setLocationRelativeTo(jMsg.getParent());
  jMsg.setVisible(1);

end


function set_callback( javaObject, varargin )

  hObj = handle(javaObject, 'callbackProperties');
  for i = 1:2:length(varargin)
    set(hObj, varargin{i}, varargin{i+1});
  end

end

function buttonPress_Callback(varargin)

%   disp( 'A button was pressed' );
  h = get( varargin{1} );
  cmd = h.ToolTipText;
  cmd = strrep( cmd, '""', ''',''' );
  cmd = strrep( cmd, '"', '''' );
  
  eval( cmd );
  
end
