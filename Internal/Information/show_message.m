function show_message( title, message )
% --- syntax:  show_message( title, message )
% ---
% --- creates a message window screen with a title bar and content panel
% --- message text is selectable for copy and paste operation if needed
% --- 
% --- message is placed within an html block for display on jave JTextField
% --- so additional html element may be embedded in the message text.

import javax.swing.*;
import java.awt.*;
 
  min_title_width = 35;
  if length(title) < min_title_width 
    title = center_text( title, min_title_width );
  end

  if iscell( message )
      
    adjMessage = [];
    for ii = 1:size(message, 1 )
      adjMessage = [adjMessage char(message(ii)) '<br>'];
    end
    
  else
    adjMessage = message;
  end
      
  xdim = (length(title) * 12.5) + 60;

  lines = max( 3, uint16( length(adjMessage)/(xdim/7) + 1 ) );

  % --- is the message preformatted?
  n = strfind( adjMessage, '<br>' );
  lines = max(lines, size(n,2) );  
  msg_depth = (lines + 1) * 20;

  ydim = lines * 20 + 35;  % --- include window title and message title depths

% % --- debug sizing issues
% fprintf('\nMain Window: %.2f x %d\n' , xdim, ydim );
% fprintf('Title Window: %.2f x %d\n' , xdim, 20 ) ;
% fprintf('Message Window: %.2f x %d\n' , xdim, msg_depth - 22 );
% fprintf('Accumulated: %.2f x %d\n' , xdim, msg_depth - 22 + 20 + 35 );
% fprintf('Message: \n' );
% fprintf( '    length: %d\n',length(adjMessage) );
% fprintf( '     lines: %d\n',lines );
% fprintf( '  per line: %.2f\n',uint16( xdim/7 ) );
% fprintf( '  estimate: %.2f\n',length(adjMessage)/(xdim/7) );

  jMsg = JDialog([], 'msgWindow', 0);

  jMsg.setAlwaysOnTop(1);
  jMsg.setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
  jMsg.setPreferredSize( Dimension( xdim, ydim ) );
  jMsg.getContentPane().setBackground( Color( rgbvalue(236),  rgbvalue(236),  rgbvalue(223) ) );

  jMsg.setTitle( 'System Message' );
  
  % Main panel
  mainPanel = JPanel(BorderLayout());
  mainPanel.setBackground( Color( rgbvalue(236),  rgbvalue(236),  rgbvalue(223) ) );
%  mainPanel.setBackground( Color( rgbvalue(204),  rgbvalue(204),  rgbvalue(204) ) );
%  mainPanel.setBackground( Color( 0, 0, 1)  );
  
  jMsg.getContentPane.add(mainPanel);
 
  
  html = '<html><body><div style="text-align:center;  font-weight:bold; font-size: 14; font-family: sans-serif;">';
  jMsgTitle = JTextPane();
  jMsgTitle.setPreferredSize( Dimension( xdim, 22 ) );
  jMsgTitle.setContentType('text/html');
  jMsgTitle.setText( [html title '<br></div></body></html>'] );
  jMsgTitle.setEditable( false );
  jMsgTitle.setBackground( Color(  rgbvalue(208),  rgbvalue(220),  rgbvalue(255) ) );
  jMsgTitle.setBorder( BorderFactory.createLineBorder( Color.BLACK ) );
  mainPanel.add(jMsgTitle, BorderLayout.NORTH);
 
  % non editable text field - allows for cut and paste operation on text
  html = '<html><body><div style="text-align:center; font-weight:bold; font-size: 12; font-family: sans-serif; line_height: 1.2; padding: 2 5 0 5"><br>';
  jMsgText = JTextPane();
  jMsgText.setPreferredSize( Dimension( xdim, msg_depth - 20) );
  jMsgText.setContentType('text/html');
  jMsgText.setText( [html adjMessage '</div></body></html>'] );
  jMsgText.setEditable( false );
  jMsgText.setBackground( Color( rgbvalue(236),  rgbvalue(236),  rgbvalue(223) ) );
  jMsgText.setBorder( [] );
  
  mainPanel.add(jMsgText, BorderLayout.SOUTH);

  % Display figure
  jMsg.pack();
  jMsg.setLocationRelativeTo(jMsg.getParent());
  jMsg.setVisible(1);

end
