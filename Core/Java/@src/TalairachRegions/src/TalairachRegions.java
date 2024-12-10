/*
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
 * details.
 * 
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 */

/* Edit history
  +---------------------------------------------------------
  |  ver  | date    | Notes
  +-------+---------+---------------------------------------
  |  1.0  | 12 2012 | John Paiement (CNOS)
  |       |         | Initial design and implementation for selection of Talairach  
  |       |         | regions within masked whole brain scan images to create 
  |       |         | multiple column H matrix Region of Interest models
  +-------+---------+------------------------------------
  |  1.1  | 01 2013 | John Paiement (CNOS)
  |       |         | added functionality to load and save selections 
  |       |         | added flag to allow matlab to profuce anh H mask from current selection 
  |       |         | modified table layout and created static constants for access to fields 
  +-------+---------+------------------------------------
  |       |         | 
*/

/* TODO:
  ---  Redesign search controls to include:
       * select all discovered regions
       * deselect all discovered regions
       * clear all selections
         clear unmasked selections
       display number of selected columns 
       display total voxel count 
              
  ---    set user flag for state recognition in matlab 
           0 = undefined  (in progress)
          -1 = cancelled
           1 = defined  
         
  ---  * create setRegions( double[][] maskInfo )
           n x 5 columns containing mask talairach index, # voxels, MNI
                  
  ---  create double[] getSelectedRegions( )
          list of selected talairach index values
          
*/ 

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Component;
import java.awt.ComponentOrientation;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.Insets;
import java.awt.Point;
import java.awt.Rectangle;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.awt.event.WindowEvent;
import java.awt.event.WindowListener;
import java.beans.PropertyChangeEvent;
import java.beans.PropertyChangeListener;

import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTable;
import javax.swing.JTextField;
import javax.swing.SwingConstants;
import javax.swing.Box.Filler;
import javax.swing.table.DefaultTableCellRenderer;
import javax.swing.table.DefaultTableModel;
import javax.swing.table.TableCellRenderer;


public class TalairachRegions extends JFrame implements KeyListener,ActionListener,WindowListener {

    private static final long serialVersionUID = 1L;
    private static int releaseVersion[] = new int[] { 1, 1 };
    
    private JTable table;
    private JScrollPane tableScrollPane;
    private JLabel searchTitle;
    private JTextField seekText;
    private JButton seekNext, seekPrev, btnOkay, btnCancel;
    private JButton btnSelectAll, btnDeselectAll, btnClearList, btnClearUnmasked;
    private JButton btnSave, btnLoad, btnMask;
    private Filler gap, bigGap;
    
    private DefaultTableModel model;
    private Object[] columnNames = {"Sel", "Index", "Talaraich Atlas Descriptor", "Voxels", "MNI"};
    private Object[][] data;
    public static int TAL_SELECTED = 0;
    public static int TAL_INDEX    = 1;
    public static int TAL_LABEL    = 2;
    public static int TAL_VOXELS   = 3;
    public static int TAL_MNI      = 4;
    
    private JPanel MainPanel, tablePanel, searchPanel, searchControls, logicControls, fileControls;
    
    private int searchPanelDepth = 90;
    public String waitstatus;
    public int exitStatus;
    
    Color grey = new Color(212, 212, 212 );
    
	@Override
	public void windowActivated(WindowEvent arg0) {
		  setWaitStatus( "active");
//	      System.out.println( "set waitstatus: " + getWaitStatus());
	}

	@Override
	public void windowClosed(WindowEvent arg0) { 
	  setWaitStatus( "inactive");
//      System.out.println( "set waitstatus: " + getWaitStatus());
	}

	@Override
	public void windowClosing(WindowEvent arg0) {
		  setWaitStatus( "inactive");
//	      System.out.println( "set waitstatus: " + getWaitStatus());
	}

	@Override
	public void windowDeactivated(WindowEvent arg0) {
		  setWaitStatus( "idle");
//	      System.out.println( "set waitstatus: " + getWaitStatus());
	}

	@Override
	public void windowDeiconified(WindowEvent arg0) {
		  setWaitStatus( "active");
//	      System.out.println( "set waitstatus: " + getWaitStatus());
	}

	@Override
	public void windowIconified(WindowEvent arg0) {
		  setWaitStatus( "idle");
//	      System.out.println( "set waitstatus: " + getWaitStatus());
		
	}

	@Override
	public void windowOpened(WindowEvent arg0) {
		  setWaitStatus( "active");
//	      System.out.println( "set waitstatus: " + getWaitStatus());
	}
    
    PropertyChangeListener propertyChangeListener = new PropertyChangeListener() {

        @Override
        public void propertyChange(PropertyChangeEvent evt) {

        };
        
    };
    
    public void actionPerformed(ActionEvent evt) {				// called on button press
    	String cmd = evt.getActionCommand();
//  	    System.out.println( "ActionEvent: "+cmd );
   	    if ( "seekNext".equals(cmd) ) { seekNext();  }
   	    if ( "seekPrevious".equals(cmd) ) { seekPrevious();  }
   	    if ( "selectAll".equals(cmd) ) { selectAll();  model.fireTableDataChanged(); }
   	    if ( "deSelectAll".equals(cmd) ) { deSelectAll();  model.fireTableDataChanged(); }
   	    if ( "clearSelected".equals(cmd) ) { clearSelected();  model.fireTableDataChanged(); }
   	    if ( "clearUnmasked".equals(cmd) ) { clearUnmasked();  model.fireTableDataChanged(); }

   	    if ( "userOkay".equals(cmd) ) {  exitStatus = 1;  setWaitStatus( "inactive"); }
   	    if ( "userMask".equals(cmd) ) {  setWaitStatus( "userMask"); }

      };
    
      
    public void keyTyped(KeyEvent e) {
    }

      /** Handle the key-pressed event from the text field. */
    public void keyPressed(KeyEvent e) {
    	String comp = e.getComponent().getClass().getName();
        int x = e.getKeyCode();
        if ( x == 114 ) {
       	  seekNext();  
        }

        if ( x == 113 ) {
         	  seekPrevious();  
          }
        
        if ("TalairachRegions$3".equals(comp)) {
          if ( x == 32 ) {
        	  int r = table.getSelectedRow();
        	  boolean b = (Boolean) model.getValueAt(r, TAL_SELECTED);
        	  model.setValueAt(!b, r, TAL_SELECTED);
        	  model.fireTableDataChanged();
        	  table.setRowSelectionInterval(r, r);
          }
    	}
      }

      /** Handle the key-released event from the text field. */
    public void keyReleased(KeyEvent e) {
      }
         

    public void addTableRow( int lblID, int vox, int M[]) {
      String MNI = M[0]+" "+M[1]+" "+M[2];
      int r = model.getRowCount();
      Object[] d = { false, r+1, talairach.getLabel(lblID), vox, MNI} ;
      model.addRow(d);
    }

    public void addTableRow( int lblID) {
        int r = model.getRowCount();
        Object[] d = { false, r+1, talairach.getLabel(lblID), 0, ""} ;
        model.addRow(d);
      }
    
    public void setRegions( double[][] regions ) {
      // regions is a n x 5 double array containing rows of	
      // [ talairach_index, voxels in region,  MNI position [0], [1], [2] ]
      String MNI;
      
      for ( int row = 0; row < regions.length; row++  ) {
    	  
    	  MNI = String.format("%d ", (int)regions[row][2] ) + 
			String.format("%d ", (int)regions[row][3] ) +
			String.format("%d", (int)regions[row][4] );
    	  
    	  model.setValueAt( (int) regions[row][1], (int) (regions[row][0])-1, TAL_VOXELS);  
    	  model.setValueAt( MNI, (int) (regions[row][0])-1, TAL_MNI);  
    	 
      }
      table.setRowSelectionInterval(0, 0);
      model.fireTableDataChanged();
      
    }
    
    
    public void clearRegions( ) {

      int v;
      if ( model.getRowCount() > 0 ) {
    	  
        for ( int row = 0; row < model.getRowCount(); row++  ) {
           v = (Integer) model.getValueAt( row, TAL_VOXELS);
           if (v > 0) {
             model.setValueAt( 0, row, TAL_VOXELS);
             model.setValueAt( "", row, TAL_MNI);  
           }
         
        }

        table.setRowSelectionInterval(0, 0);
        model.fireTableDataChanged();
        
      }
    }

    
    public TalairachLabels talairach = new TalairachLabels();
    
    public String version() {
      return releaseVersion[0] + "." + releaseVersion[1];
    }

    public void setWaitStatus (String state) {
    	waitstatus = state;
    }
    
    public String getWaitStatus () {
    	return waitstatus;
    }
    
    public void seekNext() {
  	  String look4 = seekText.getText();
  	  if ( look4.length() > 0 ) {
  		String nxt;
  		int r = table.getSelectedRow();
  		for ( int ii = r+1; ii < model.getRowCount(); ii++ ) {
  		   nxt = (String) model.getValueAt( ii, TAL_LABEL);
  		
  		   if ( nxt.toLowerCase().contains(look4.toLowerCase()) ) {
  			   table.setRowSelectionInterval(ii, ii);
  			   table.scrollRectToVisible(new Rectangle(table.getCellRect(ii, 0, true)));
  			   return;
  		   }
  		}
  		  
  	  }
  		  
        return;
    }
      
    public void seekPrevious() {
  	  String look4 = seekText.getText();
  	  if ( look4.length() > 0 ) {
  		String nxt;
  		int r = table.getSelectedRow();
  		for ( int ii = r-1; ii > 0; ii-- ) {
  		   nxt = (String) model.getValueAt( ii, TAL_LABEL);
  		   if ( nxt.toLowerCase().contains(look4.toLowerCase()) ) {
  			   table.setRowSelectionInterval(ii, ii);
  			   table.scrollRectToVisible(new Rectangle(table.getCellRect(ii, 0, true)));
  			   return;
  		   }
  		}
  		  
  	  }
  		  
        return;
    }

    
    public void selectAll() {
    	  String look4 = seekText.getText();
    	  if ( look4.length() > 0 ) {
    		String nxt;
    		for ( int ii = 0; ii <  model.getRowCount(); ii++ ) {
    		   nxt = (String) model.getValueAt( ii, TAL_LABEL);
    		   if ( nxt.toLowerCase().contains(look4.toLowerCase()) ) {
    	         model.setValueAt(true, ii, TAL_SELECTED);
    		   }
    		}
    		  
    	  }
    		  
          return;
      }
    
    
    public void deSelectAll() {
  	  String look4 = seekText.getText();
  	  if ( look4.length() > 0 ) {
  		String nxt;
  		for ( int ii = 0; ii <  model.getRowCount(); ii++ ) {
  		   nxt = (String) model.getValueAt( ii, TAL_LABEL);
  		   if ( nxt.toLowerCase().contains(look4.toLowerCase()) ) {
  	         model.setValueAt(false, ii, TAL_SELECTED);
  		   }
  		}
  		  
  	  }
  		  
        return;
    }
    
   
    public void clearSelected() {
       	for ( int ii = 0; ii <  model.getRowCount(); ii++ ) {
    	    model.setValueAt(false, ii, TAL_SELECTED);
    	}
    		  
        return;
    }

    
    public void clearUnmasked() {
    	
 		int vox;
		boolean isSelected;
    	for ( int ii = 0; ii <  model.getRowCount(); ii++ ) {
    		isSelected = (Boolean)model.getValueAt( ii, TAL_SELECTED);
    		vox = (Integer)model.getValueAt( ii, TAL_VOXELS);
    		if ( isSelected & vox == 0 ) {
    	      model.setValueAt(false, ii, TAL_SELECTED);
    		}
    	}
    		  
        return;
        
    }
    

    public void populate_table() {
        for ( int ii = 1; ii < talairach.getCount(); ii++ ) {
          	/* as we will be interfacing from within Matlab, all indexing will be
          	 * based on Matlab n+1 index values ( there is no 0 );
          	 */
          	addTableRow( ii );		
          }
 
//       	  System.out.println( "model row count " + (int) model.getRowCount() );
        
    }
 
    
    
    public int[] getSelected() {
    	
      int[] r = null;
      boolean isSelected;
      int count = 0;
      
      // we need a proper count of how many have been marked as selelected
      for ( int ii = 0; ii < model.getRowCount(); ii++ ) {
    	  isSelected = (Boolean)model.getValueAt( ii, TAL_SELECTED);
    	  if ( isSelected ) {
    	    count++;
    	  }
      }
      
      if ( count > 0) {
        r = new int[count];
        int x = 0;
        for ( int ii = 0; ii < model.getRowCount(); ii++ ) {
      	  isSelected = (Boolean)model.getValueAt( ii, TAL_SELECTED);
      	  if ( isSelected ) {
    	    r[x++] = ii+1;
          }
        }
      }
      
      return r;
    }
    
    public static void main(String[] args) {
      	TalairachRegions frame = new TalairachRegions();
          frame.pack();
          frame.setLocation( new Point( 200, 200 ) );
          frame.setSize(600, 450);
          frame.setVisible(true);
// ---- development block - remove comment within Eclipse for testings
//      remember to comment out before exporting jar file for testing in Matlab
//        frame.setDefaultCloseOperation(EXIT_ON_CLOSE);
//        frame.populate_table();
// ---- 

      }
    
    public TalairachRegions() {

    	waitstatus = new String("idle");
    	exitStatus = 0;
    	
    	this.setTitle("Talairach Region Selection (Ver " + version() + ")");
    	
        MainPanel = new JPanel ( new BorderLayout() );
        MainPanel.setVisible( true );

        searchPanel = new JPanel ( new BorderLayout() );
        searchPanel.setBounds (new Rectangle (10, 0, 600, searchPanelDepth));
        searchPanel.setPreferredSize(new Dimension(600, searchPanelDepth));
        searchPanel.setMinimumSize(new Dimension (500, searchPanelDepth));
        searchPanel.setLayout(new BoxLayout(searchPanel, BoxLayout.Y_AXIS));
        
        searchTitle = new JLabel ();
        searchTitle.setBounds (new Rectangle (10, 0, 60, 20));
        searchTitle.setFont( new Font("Serif", Font.BOLD, 14));
        searchTitle.setHorizontalAlignment(SwingConstants.LEFT);
        searchTitle.setText("Search");
        searchTitle.setPreferredSize(new Dimension(60, 20));
//        searchTitle.validate();
        
        searchControls  = new JPanel ( new BorderLayout() );
        searchControls.setBounds (new Rectangle (2, 20, 500, 20));
        searchControls.setPreferredSize(new Dimension(600, 20));
        searchControls.setMinimumSize(new Dimension (200, 20));
        searchControls.setLayout(new BoxLayout(searchControls, BoxLayout.X_AXIS));
//        searchControls.setBorder(new LineBorder( Color.BLUE));
      
        seekText = new JTextField("", 50);
        seekText.setBounds (new Rectangle (200, 0, 200, 20));
        seekText.setMargin( new Insets( 0, 5, 0, 0) );
        seekText.setFont(  new Font("Sans", Font.BOLD, 12) );
        seekText.setHorizontalAlignment(SwingConstants.LEFT);
        seekText.setMaximumSize(new Dimension(500, 20));
//        seekText.setBackground(grey);
//        seekText.validate();
        seekText.addKeyListener(this);

        seekNext = new JButton( "Next");
        seekNext.setToolTipText("move to next row containing text (F3)");
        seekNext.setBounds (new Rectangle (160, 0, 80, 20));
        seekNext.setMaximumSize(new Dimension(80, 20));
        seekNext.setMinimumSize(new Dimension(80, 20));
        seekNext.addKeyListener(this);
        seekNext.setActionCommand("seekNext");
        seekNext.addActionListener((ActionListener) this);
        
        seekPrev = new JButton( "Prev");
        seekPrev.setToolTipText("move to previous row containing text (F2)");
        seekPrev.setBounds (new Rectangle (210, 0, 80, 20));
        seekPrev.setMaximumSize(new Dimension(80, 20));
        seekPrev.setMinimumSize(new Dimension(80, 20));
        seekPrev.addKeyListener(this);
        seekPrev.setActionCommand("seekPrevious");
        seekPrev.addActionListener((ActionListener) this);
        
//        searchControls.add( spacer );
        searchControls.add( seekText );
        searchControls.add( seekNext );
        searchControls.add( seekPrev );
//        searchControls.revalidate();
 
        logicControls  = new JPanel ( new BorderLayout() );
        logicControls.setBounds (new Rectangle (30, 70, 500, 20));
        logicControls.setPreferredSize(new Dimension(600, 20));
        logicControls.setMinimumSize(new Dimension (200, 20));
        logicControls.setComponentOrientation(ComponentOrientation.RIGHT_TO_LEFT);
        logicControls.setLayout(new BoxLayout(logicControls, BoxLayout.X_AXIS));
        
        btnOkay = new JButton( "Okay");
        btnOkay.setBounds (new Rectangle (160, 0, 100, 20));
        btnOkay.setMaximumSize(new Dimension(100, 20));
        btnOkay.setActionCommand("userOkay");
        btnOkay.addActionListener((ActionListener) this);

        btnCancel = new JButton( "Cancel");
        btnCancel.setBounds (new Rectangle (220, 0, 100, 20));
        btnCancel.setMaximumSize(new Dimension(100, 20));

        btnSelectAll = new JButton( "Select All");
        btnSelectAll.setToolTipText("Select all rows where text is found");
        btnSelectAll.setBounds (new Rectangle (220, 0, 100, 20));
        btnSelectAll.setMaximumSize(new Dimension(100, 20));
        btnSelectAll.setActionCommand("selectAll");
        btnSelectAll.addActionListener((ActionListener) this);

        btnDeselectAll = new JButton( "Unselect All");
        btnDeselectAll.setToolTipText("Remove all rows selected where text is found");
        btnDeselectAll.setBounds (new Rectangle (220, 0, 130, 20));
        btnDeselectAll.setMaximumSize(new Dimension(130, 20));
        btnDeselectAll.setActionCommand("deSelectAll");
        btnDeselectAll.addActionListener((ActionListener) this);

        btnClearUnmasked = new JButton( "Clean");
        btnClearUnmasked.setToolTipText("Remove all rows selected where not found in brain mask");
        btnClearUnmasked.setBounds (new Rectangle (280, 0, 100, 20));
        btnClearUnmasked.setMaximumSize(new Dimension(100, 20));
        btnClearUnmasked.setActionCommand("clearUnmasked");
        btnClearUnmasked.addActionListener((ActionListener) this);
        
        btnClearList = new JButton( "Clear");
        btnClearList.setToolTipText("Clear all selected rows in list");
        btnClearList.setBounds (new Rectangle (280, 0, 100, 20));
        btnClearList.setMaximumSize(new Dimension(100, 20));
        btnClearList.setActionCommand("clearSelected");
        btnClearList.addActionListener((ActionListener) this);

        gap = new Filler(new Dimension(10,20), new Dimension(10,20), new Dimension(10,20));
        bigGap = new Filler(new Dimension(30,20), new Dimension(30,20), new Dimension(30,20));
               
        logicControls.add( btnSelectAll );
        logicControls.add( gap );
        logicControls.add( btnDeselectAll );
        logicControls.add( gap );
        logicControls.add( btnClearUnmasked );
//        logicControls.add( gap );
        logicControls.add( bigGap );
        logicControls.add( btnClearList );
        logicControls.add( btnOkay );

        
        fileControls  = new JPanel ( new BorderLayout() );
        fileControls.setBounds (new Rectangle (30, 70, 500, 20));
        fileControls.setPreferredSize(new Dimension(600, 20));
        fileControls.setMinimumSize(new Dimension (200, 20));
        fileControls.setComponentOrientation(ComponentOrientation.RIGHT_TO_LEFT);
        fileControls.setLayout(new BoxLayout(fileControls, BoxLayout.X_AXIS));
        
        btnSave = new JButton( "Save");
        btnSave.setBounds (new Rectangle (160, 0, 100, 20));
        btnSave.setMaximumSize(new Dimension(100, 20));
        btnSave.setActionCommand("userSave");
        btnSave.addActionListener((ActionListener) this);

        btnSave.setEnabled(false);
        
        btnLoad = new JButton( "Load");
        btnLoad.setBounds (new Rectangle (160, 0, 100, 20));
        btnLoad.setMaximumSize(new Dimension(100, 20));
        btnLoad.setActionCommand("userLoad");
        btnLoad.addActionListener((ActionListener) this);

        btnLoad.setEnabled(false);

        btnMask = new JButton( "Create Mask");
        btnMask.setBounds (new Rectangle (160, 0, 100, 20));
        btnMask.setMaximumSize(new Dimension(140, 20));
        btnMask.setActionCommand("userMask");
        btnMask.addActionListener((ActionListener) this);
        
        fileControls.add( btnSave );
        fileControls.add( gap );
        fileControls.add( btnLoad );
        fileControls.add( gap );
        fileControls.add( btnMask );
        
        searchPanel.add( searchTitle );
        searchPanel.add( searchControls );
        searchPanel.add( logicControls );
        searchPanel.add( fileControls, BorderLayout.SOUTH );
        
        model = new DefaultTableModel(data, columnNames)  {
        	private static final long serialVersionUID = 1L;
            @Override
            public boolean isCellEditable(int row, int column) {
            	// allow user to select check box in column 0
               if ( column > 0 ) {
                 return false;
               }  else {
            	 return true;
               }
            }
            
        };
        
        table = new JTable(model) {

            private static final long serialVersionUID = 1L;

            /*@Override
            public Class getColumnClass(int column) {
            return getValueAt(0, column).getClass();
            }*/
            @Override
            public Class<?> getColumnClass(int column) {
                switch (column) {
             
                  case 1:		// TAL_INDEX
                    return Integer.class;
                  case 2:		// TAL_LABEL
                    return String.class;
                  case 3:		// TAL_VOXELS
                      return Integer.class;
                  case 4:		// TAL_MNI
                    return String.class;
                  default:		// TAL_SELECTED
                    return Boolean.class;
                }
            }
            
            @Override
            public Component prepareRenderer(TableCellRenderer renderer, int row, int column){
                Component returnComp = super.prepareRenderer(renderer, row, column);
                Color altColor = new Color(252,242,206);
                Color maskedColor = new Color(229, 252, 229);
                Color altMaskedColor = new Color(191, 252, 191);
                Color bg = Color.WHITE;
                if (!returnComp.getBackground().equals(getSelectionBackground())){
                	boolean b = (Boolean) model.getValueAt(row, TalairachRegions.TAL_SELECTED);
                	int v = (Integer) model.getValueAt(row, TalairachRegions.TAL_VOXELS);
                	if ( v > 0 ) {
                	  bg = (b ? altMaskedColor : maskedColor);
                	} else {
                      bg = (b ? altColor : bg);
                    }
                    returnComp .setBackground(bg);
                    bg = null;
                }
                return returnComp;
            }
        };
  
       
        table.setPreferredScrollableViewportSize(table.getPreferredSize());
        table.getColumnModel().getColumn(TalairachRegions.TAL_SELECTED).setMaxWidth(40);
        table.getColumnModel().getColumn(TalairachRegions.TAL_INDEX).setMaxWidth(50);
        table.getColumnModel().getColumn(TalairachRegions.TAL_INDEX).setCellRenderer(new LeftTableCellRenderer());
        table.getColumnModel().getColumn(TalairachRegions.TAL_LABEL).setPreferredWidth(400);
        table.getColumnModel().getColumn(TalairachRegions.TAL_LABEL).setMaxWidth(1000);
        table.getColumnModel().getColumn(TalairachRegions.TAL_VOXELS).setMaxWidth(50);
        table.getColumnModel().getColumn(TalairachRegions.TAL_VOXELS).setCellRenderer(new CenterTableCellRenderer());
        table.getColumnModel().getColumn(TalairachRegions.TAL_MNI).setPreferredWidth(100);
        table.getColumnModel().getColumn(TalairachRegions.TAL_MNI).setMaxWidth(100);
        table.getColumnModel().getColumn(TalairachRegions.TAL_MNI).setCellRenderer(new CenterTableCellRenderer());
        
        table.setCellSelectionEnabled(false);
        table.setColumnSelectionAllowed(false);
        table.setRowSelectionAllowed(true);
        table.addKeyListener(this);
       
        tablePanel = new JPanel ( new BorderLayout() );
        tablePanel.setVisible( true );
        tablePanel.add(table);
        tablePanel.setBounds (new Rectangle (0, searchPanelDepth));

        MainPanel.add(tablePanel);
        
        tableScrollPane = new JScrollPane(MainPanel);
        tableScrollPane.revalidate();
        
        getContentPane().add(searchPanel, BorderLayout.NORTH );
        getContentPane().add(tableScrollPane);

        addWindowListener( this );

    }
 
}

class CenterTableCellRenderer extends DefaultTableCellRenderer {   
	private static final long serialVersionUID = 1L;
	protected  CenterTableCellRenderer() {  
      setHorizontalAlignment(JLabel.CENTER);  
    }
  } ;

  class LeftTableCellRenderer extends DefaultTableCellRenderer {   
		private static final long serialVersionUID = 1L;
		protected  LeftTableCellRenderer() {  
	      setHorizontalAlignment(JLabel.LEFT);  
	    }
	  } ;

