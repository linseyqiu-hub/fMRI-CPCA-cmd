function S = splash_screen( action , S)
% --- splash_screen:  Display/hide the CPCA splash screen.
% --- 
% --- USAGE: splash_screen('show')
% ---     splash_screen('hide')
% --- 
% --- derived from Brainstorm softwares BST_SPLASH script

% @=============================================================================
% This software is part of the Brainstorm software:
% http://neuroimage.usc.edu/brainstorm
% 
% Copyright (c)2000-2013 Brainstorm by the University of Southern California
% This software is distributed under the terms of the GNU General Public License
% as published by the Free Software Foundation. Further details on the GPL
% license can be found at http://www.gnu.org/copyleft/gpl.html.
% 
% FOR RESEARCH PURPOSES ONLY. THE SOFTWARE IS PROVIDED "AS IS," AND THE
% UNIVERSITY OF SOUTHERN CALIFORNIA AND ITS COLLABORATORS DO NOT MAKE ANY
% WARRANTY, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO WARRANTIES OF
% MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, NOR DO THEY ASSUME ANY
% LIABILITY OR RESPONSIBILITY FOR THE USE OF THIS SOFTWARE.
%
% For more information type "brainstorm license" at command prompt.
% =============================================================================@
%
% Authors: Francois Tadel, 2008-2010
% 
% Slight revision to avoid collisions with installed brainStorm software

import javax.swing.*;
import java.awt.*;

if nargin < 2
  S = structure_define( 'splash');
end


switch lower(action)
    case 'show'

        % If panel exist: show it
        if ~isempty(S.object)
            awtinvoke(S.object, 'setVisible(Z)', 1);
            
        % Else: create it
        else
            % Main JFrame
            jSplash = JDialog([], 'cpcaSplash', 0);
            jSplash.setUndecorated(1);
            jSplash.setAlwaysOnTop(1);
            jSplash.setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
            jSplash.setPreferredSize(Dimension(S.size(1), S.size(2)));

            % Main panel
            jPanel = JPanel(BorderLayout());
            jPanel.setBorder(javax.swing.BorderFactory.createBevelBorder(javax.swing.border.BevelBorder.RAISED, java.awt.Color.lightGray, java.awt.Color.black, [], []));
            set_callback(jPanel, 'MouseClickedCallback', @(h,ev)splash_screen('hide'));
            jSplash.getContentPane.add(jPanel);

            % Get logo path
%            logo_file = [  cpca_path() 'utils' filesep 'tools' filesep 'GUI' filesep S.logofile ];
            % Image in label
            jLabel = JLabel();
            jLabel.setIcon(ImageIcon(S.logofile));
            jPanel.add(jLabel, BorderLayout.NORTH);

            % add the status pane
            jStatus = JLabel();
            jStatus.setPreferredSize(Dimension(S.size(1), S.depth - 4));
            jStatus.setBorder(javax.swing.BorderFactory.createBevelBorder(javax.swing.border.BevelBorder.LOWERED, java.awt.Color.lightGray, java.awt.Color.black, [], []));
	    
            jPanel.add(jStatus, BorderLayout.SOUTH);

            % Display figure
            jSplash.pack();
            jSplash.setLocationRelativeTo(jSplash.getParent());
            jSplash.setVisible(1);
            S.object = jSplash;
            S.status = jStatus;

        end
        % Update last call time
        S.lastCall = clock();
        
    case 'hide'
        if ~isempty(S.object)
            duration = etime(clock(), S.lastCall);
            if (duration < 3)
                pause(3 - duration);
            end
            awtinvoke(S.object, 'setVisible(Z)', 0);
        end
end

end

