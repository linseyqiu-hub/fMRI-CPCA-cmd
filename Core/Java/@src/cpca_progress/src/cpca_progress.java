
import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.Point;
import java.awt.Rectangle;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.beans.PropertyChangeEvent;
import java.beans.PropertyChangeListener;
import java.text.DecimalFormat;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JProgressBar;
import javax.swing.SwingConstants;
import javax.swing.border.BevelBorder;
import javax.swing.border.LineBorder;
import javax.swing.plaf.basic.BasicProgressBarUI;


public class cpca_progress extends JFrame implements ActionListener {

  private static final long serialVersionUID = 1L;

  // event     		component	p1  p2	Description
  //
  // EVT_SET_MESSAGE  	  msg	0,  1   set main text
  //							1,	0	set sub text
  //							1,  1   set minor text
  //							0, 	0	clear text from msg
  //
  // EVT_SET_TITLE			-	1, 	0	set frame title
  //
  // EVT_SET_PARTICIPANT	P	1	2	set Participant text 
  //						P	0, 	2	clear Participant text
  //						R	1, 	3	set secondary Participant text in Run
  //						R	0, 	3	clear secondary Participant text ( or clear Run )
  //
  // EVT_SET_RUN 			R	1	0	set Run text
  //						R	0, 	1	clear Run text
  //
  // EVT_SET_FREQUENCY		F	1	0	set Frequency text
  //						F	0, 	1	clear Frequency text
  //
  // EVT_STATE_CHANGED	 	-	1,	0	raised state change flag
  //
  // EVT_UPDATE		 		-	1,	0	set current iteration count and update 			( setPercent()    )
  //  				 			1,	2,	increment current iteration count and update	( increment()     )
  //  				 			0,	1,	set max count, reset iteration and update		( setIterations() )
  //  				 			0,	2,	reset counters and update                       ( unused          )
	

  private JPanel MainPanel;						// container for text update controls
  private JLabel MainText;       				// label to show main process title
  private JLabel SubText;       				// label to show messages
  private JLabel Comment;       				// label to show comments
  private JLabel Participant;  					// label to show participant text
  private JLabel lblRun;         				// label to show participant run text
  private JLabel lblFreq;         				// label to show participant frequency text
  
  private JPanel ProgressPanel;					// container for progress bars
  private JProgressBar Overall;  				// the overall progress bar
  private JProgressBar Process;  				// the individual process progress bar
  private JLabel TimeEst;      					// label to show estimated completion time

  private JPanel hrfFrm;    					// Frame to contain HRFMAX dependent stats
  private JLabel nChanges;     					// label to show number of accepted T changes
  private JButton SaveState;   					// button to flag hrfmax state preservation

  private Font fontProgressBar  = new Font("Monospaced", Font.BOLD, 11);
  private Font fontSectionTitle = new Font("Serif", Font.BOLD, 14);
  private Font fontSubTitle     = new Font("Serif", Font.BOLD, 12);
  private Font fontComment      = new Font("Serif", Font.BOLD | Font.ITALIC, 11);
  
  private long initTime = 0l;  					// the time the process was initiated
  
  private String winTitle = "CPCA Analysis in progress";
  private String msgText = "CPCA Process";					// displayed bold
  private String msgSubText = "";   			// displayed normal
  private String msgComment = "";   			// displayed italic
  private String subjectText = "";
  private String runText = "";
  private String freqText = "";
  private String percentage = "0.00%";
  private String completion = "<html>Est: <font color=\"#813414\"><b>--:--:--</b></font></html>";

  private String Tstats = "<html>T Changes: 0<br>Changed At: 0<br>Prev Change: 0</html>";
  
  public int PRIMARY = 0;						// flag setting and initializing overall stats
  public int SECONDARY = 1;						// flag setting and initializing indvidual process stats
  
  private double maxIters[] = new double [2];
  private double currentIter[] = new double [2];
  
//  private double currentIter = 0;
  private double saveCurrentState = 0;

  private double Tchanges = 0;
  private double thisChangeIter = 0;
  private double prevChangeIter = 0;
  
  Dimension normal   = new Dimension (395, 180);
  Dimension expanded = new Dimension (395, 290);
  
  Rectangle MainPanelSz = new Rectangle (0, 0, 340, 150);
  Rectangle ProgressPanelSz = new Rectangle (340, 0, 38, 150);
  
  Color grey = new Color(212, 212, 212 );
  Color darkgrey = new Color(172, 172, 172 );
  Color undone = new Color(154, 232, 97 ) ;
  Color done =  new Color(17, 107, 38 );

  Color undoneS = new Color(243, 234, 71 ) ;
  Color doneS =  new Color(168, 150, 31 );

  int hrfIterNo = 0;           // number of hrfmax iterations since last update
  int hrfIterAlter = 100;      // maximum iterations to bypass before update
  
  // manual layout debugging - set true to show borders on controls
  private boolean showBounds = false;
  private LineBorder ln = new LineBorder( Color.BLACK);
  
//  private int numSubs, numRuns, numFreqs  = 0;
  
  PropertyChangeListener propertyChangeListener = new PropertyChangeListener() {

    @Override
    public void propertyChange(PropertyChangeEvent evt) {

	  String property = evt.getPropertyName();
      int p1, p2;	
      if ("EVT_SET_TITLE".equals(property)) {
  	    setTitle( winTitle );
  	    validate();
        return;
      }
	
      
	  if ("EVT_UPDATE".equals(property)) {

	    if ( initTime <= 0l )   {										// process is just starting - set time of first iteration
		  initTime = System.nanoTime();
		  return;
	    }

        p1 = Integer.parseInt(String.format("%d",evt.getOldValue()) );
	    p2 = Integer.parseInt(String.format("%d",evt.getNewValue()) );
	  
        if ( p1 >= 1 ) {    											// set or increment current iteration count

    	  long now = System.nanoTime();									// current time
			  
		  double newPct = (currentIter[p2]/maxIters[p2] * 100);					// percentage complete
		  if ( newPct > 100 ) { newPct = 100; }
		  String txt = String.format("%.2f%%", newPct );
		  if ( p2 == PRIMARY ) {
  		    Overall.setValue( (int) newPct );
		    Overall.setString(txt);
		  } else {
 		    Process.setValue( (int) newPct );
 		    Process.setString(txt);
		  }
	      float duration = (now - initTime) / 1000000000;				// elapsed time in seconds
	      duration = duration/(float)currentIter[p2]; 						// average time per iteration so far
	      duration = duration * (float)( maxIters[p2] - currentIter[p2] );		// times number of iterations to go
	      if ( duration > 0.0 ) {
	        long h = (long)(duration/3600);								// estimated remaining time (hours)
	        long m = (long)((duration -(h*3600)) / 60);					// estimated remaining time (minutes)
	        long s = (long)(duration - ( (h*3600)+(m*60) ));			// estimated remaining time (seconds)
	          
	        txt = String.format("<html>Est: <font color=\"#813414\"><b>%02d:%02d:%02d</b></font></html>", h, m, s );
	        TimeEst.setText(txt);
	      }
	          
        } else {														// p1 == 0 - reset conditions
    	  
    	  if ( p2 == 1 ) {												// new maximum count issued - reset all other conditions
            currentIter[0] = 0;
            currentIter[0] = 0;
            initTime = 0l;
            Overall.setValue( 0 );
            Overall.setString(percentage);
            Process.setValue( 0 );
            Process.setString(percentage);
            TimeEst.setText(completion);
          }
    	  
        }
        validate();
	  }
    
	  if ("EVT_SET_MESSAGE".equals(property)) {
        p1 = Integer.parseInt(String.format("%d",evt.getOldValue()) );
        switch (p1) {
          case 0:
        	MainText.setText( msgText );
           	SubText.setText( msgSubText );
           	Comment.setText( msgComment );
          break;
          case 1:
          	MainText.setText( msgText );
          break;
          case 2:
           	SubText.setText( msgSubText );
          break;
          case 3:
           	Comment.setText( msgComment );
          break;
          case 4:
        	MainText.setText( msgText );
           	SubText.setText( msgSubText );
           	Comment.setText( msgComment );
          break;
        }
 	    validate();
        return;
	  }

	  
      if ("EVT_SET_PARTICIPANT".equals(property)) {
        p1 = Integer.parseInt(String.format("%d",evt.getOldValue()) );
  	    p2 = Integer.parseInt(String.format("%d",evt.getNewValue()) );
        String txt = "";
	    if (p1 == 1) { txt = subjectText;  }
	    if (p2 == 3) { lblRun.setText( txt );	 } else { Participant.setText( txt ); }
	    return;
      }
      
      if ("EVT_SET_RUN".equals(property)) {
        String txt = "";
        p1 = Integer.parseInt(String.format("%d",evt.getOldValue()) );
          
  	    if (p1 == 1) {  txt = runText; }
  	    lblRun.setText( txt );
  	    return;
      }

      if ("EVT_SET_FREQUENCY".equals(property)) {
        String txt = "";
        p1 = Integer.parseInt(String.format("%d",evt.getOldValue()) );
        if (p1 == 1) { txt = freqText; }
        lblFreq.setText( txt );
        return;
      }

      
      if ("EVT_STATE_CHANGED".equals(property)) {
        String txt = "";
        p1 = Integer.parseInt(String.format("%d",evt.getOldValue()) );
        if (p1 == 1) { txt = Tstats;  }
        nChanges.setText( txt );
        return;
      }

    };
  
  };
  
  
  public void actionPerformed(ActionEvent evt) {				// called on button press
	String cmd = evt.getActionCommand();
	if ("SaveState".equals(cmd)) {  saveCurrentState = 1; }
  };
  
  
  public static void main (String[] arg)
  {
    new cpca_progress ();
  };

  
  public cpca_progress ()
  {
	  
//	setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
	maxIters[0] = 100;
	maxIters[1] = 100;
	currentIter[0] = 0;
	currentIter[1] = 0;

    this.getContentPane ().setLayout (null);
    this.setSize ( normal );
//    this.setSize ( expanded );
    this.setLocation( new Point( 200, 200 ) );
    this.setVisible (true);
    this.setResizable( false );
    this.setTitle( winTitle );
    this.getContentPane().setBackground( grey );
    this.addPropertyChangeListener( propertyChangeListener );

    MainPanel = new JPanel ( new BorderLayout() );
    MainPanel.setBounds (MainPanelSz);
    MainPanel.setBackground( grey );
   
    Dimension ControlSz = new Dimension( MainPanelSz.width - 20, 20 );

    ProgressPanel = new JPanel ( new BorderLayout() );
    ProgressPanel.setBounds (ProgressPanelSz);
    ProgressPanel.setBackground( grey );
    if ( showBounds ) {
      ProgressPanel.setBorder(ln);
    }
    
    int offset = 0;
    
    MainText = new JLabel ();
    MainText.setPreferredSize(ControlSz);
    MainText.setBounds (new Rectangle (0, offset, MainPanelSz.width, ControlSz.height));
    MainText.setBackground( darkgrey );
    MainText.setOpaque(true);
    MainText.setFont( fontSectionTitle );
    MainText.setHorizontalAlignment(SwingConstants.CENTER);
    MainText.setText(msgText);
    MainText.validate();
    if ( showBounds ) {
    	MainText.setBorder(ln);
    }
    
    MainPanel.add (MainText, BorderLayout.NORTH);
    offset += ControlSz.height;

    SubText = new JLabel ();
    SubText.setPreferredSize(ControlSz);
    SubText.setBounds (new Rectangle (10, offset, ControlSz.width, ControlSz.height));
    SubText.setFont( fontSubTitle );
    SubText.setHorizontalAlignment(SwingConstants.LEFT);
    SubText.setText(msgSubText);
    SubText.validate();
    if ( showBounds ) {
    	SubText.setBorder(ln);
    }
    
    MainPanel.add (SubText, BorderLayout.NORTH);
    offset += ControlSz.height;
    
    Comment = new JLabel ();
    Comment.setPreferredSize(ControlSz);
    Comment.setBounds (new Rectangle (10, offset, ControlSz.width, ControlSz.height));
    Comment.setFont( fontComment );
    Comment.setHorizontalAlignment(SwingConstants.LEFT);
    Comment.setText(msgComment);
    Comment.validate();
    if ( showBounds ) {
    	Comment.setBorder(ln);
    }
    
    MainPanel.add (Comment, BorderLayout.NORTH);
    offset += ControlSz.height + 15;
    
    Participant = new JLabel ();
    Participant.setPreferredSize(ControlSz);
    Participant.setBounds (new Rectangle (10, offset, ControlSz.width, ControlSz.height));
    Participant.setFont( fontSubTitle );
    Participant.setHorizontalAlignment(SwingConstants.LEFT);
    Participant.setText(subjectText);
    Participant.validate();
    if ( showBounds ) {
    	Participant.setBorder(ln);
    }

    MainPanel.add (Participant, BorderLayout.NORTH);
    offset += ControlSz.height;

    lblRun = new JLabel ();
    lblRun.setPreferredSize(ControlSz);
    lblRun.setBounds (new Rectangle (10, offset, ControlSz.width, ControlSz.height));
    lblRun.setFont( fontSubTitle );
    lblRun.setHorizontalAlignment(SwingConstants.LEFT);
    lblRun.setText(runText);
    lblRun.validate();
    if ( showBounds ) {
    	lblRun.setBorder(ln);
    }

    MainPanel.add (lblRun, BorderLayout.NORTH);
    offset += ControlSz.height;

    lblFreq = new JLabel ();
    lblFreq.setPreferredSize(ControlSz);
    lblFreq.setBounds (new Rectangle (10, offset, ControlSz.width, ControlSz.height));
    lblFreq.setFont( fontSubTitle );
    lblFreq.setHorizontalAlignment(SwingConstants.LEFT);
    lblFreq.setText(freqText);
    lblFreq.validate();
    if ( showBounds ) {
    	lblFreq.setBorder(ln);
    }

    MainPanel.add (lblFreq, BorderLayout.NORTH);
    offset += ControlSz.height;

    JLabel dummy = new JLabel ();
    dummy.setPreferredSize(ControlSz);
    dummy.setBounds (new Rectangle (10, offset, ControlSz.width, ControlSz.height));

    MainPanel.add (dummy, BorderLayout.NORTH);

    this.getContentPane ().add (MainPanel, BorderLayout.NORTH);
//    offset += ControlSz.height;

    
    Overall = new JProgressBar ();
    Overall.setOrientation(SwingConstants.VERTICAL);
    Overall.setPreferredSize( new Dimension( 15, 90 ));
    Overall.setBounds (new Rectangle (0, 5, 15, 90));
    Overall.setBorder(new BevelBorder(BevelBorder.RAISED ));
    Overall.setFont( fontProgressBar );
    Overall.setBackground( undone );
    Overall.setForeground( done );
    Overall.setStringPainted(true);
    Overall.setUI(
        new BasicProgressBarUI() {
        protected Color getSelectionBackground() { return Color.black; }
        protected Color getSelectionForeground() { return Color.white; }
      });

    Overall.setValue( 0 );
    Overall.setString(percentage);
    Overall.validate();
    
    ProgressPanel.add (Overall, BorderLayout.WEST);

/*    dummy.setPreferredSize( new Dimension( 10, 90 ));
    dummy.setBounds (new Rectangle (15, 0, 5, 90));
    ProgressPanel.add (dummy, BorderLayout.WEST);
*/    
    Process = new JProgressBar ();
    Process.setOrientation(SwingConstants.VERTICAL);
    Process.setPreferredSize( new Dimension( 15, 90 ));
    Process.setBounds (new Rectangle (15, 5, 15, 90));
    Process.setBorder(new BevelBorder(BevelBorder.RAISED ));
    Process.setFont( fontProgressBar );
    Process.setBackground( undoneS );
    Process.setForeground( doneS );
    Process.setStringPainted(true);
    Process.setUI(
        new BasicProgressBarUI() {
        protected Color getSelectionBackground() { return Color.black; }
        protected Color getSelectionForeground() { return Color.white; }
      });

    Process.setValue( 0 );
    Process.setString(percentage);
    Process.validate();
    
    ProgressPanel.add (Process, BorderLayout.EAST);
    this.getContentPane ().add (ProgressPanel, BorderLayout.NORTH);
    
    TimeEst = new JLabel ();
    TimeEst.setBounds (new Rectangle (5, 150, 358, 16));
    TimeEst.setHorizontalAlignment(SwingConstants.CENTER);
    TimeEst.setText(completion);
    this.getContentPane ().add (TimeEst);
    if ( showBounds ) {
    	TimeEst.setBorder(ln);
    }

    
    hrfFrm = new JPanel ( new BorderLayout() );
    hrfFrm.setBounds (new Rectangle (5, 170, 368, 60));
    hrfFrm.setBorder(new BevelBorder(BevelBorder.LOWERED ));
    hrfFrm.setBackground( grey );

    nChanges = new JLabel ();
    nChanges.setBounds (new Rectangle (0, 0, 368, 60));
    nChanges.setHorizontalAlignment(SwingConstants.CENTER);
    nChanges.setText(Tstats);
    nChanges.setBackground( grey );
    hrfFrm.add( nChanges );
   
    this.getContentPane ().add (hrfFrm, BorderLayout.CENTER);

    SaveState = new JButton ("Save State and Exit");
    SaveState.setBounds (new Rectangle (5, 235, 368, 20));
    SaveState.setBackground( grey );

    SaveState.setActionCommand("SaveState");
    SaveState.addActionListener((ActionListener) this);
    SaveState.setBorder( new BevelBorder(BevelBorder.RAISED) );
    
    this.getContentPane ().add (SaveState);
    
    validate();
    
 //   test();
  };
  
  public void test() {
    setWindowTitle( "Window Title");

    setMessages( "Main Text", "Sub Text", "Whatever" );

    clearMessages();

    
    setProcess( "Processing . . ." );
    setMessage( "This is what we're doing . . ." );
    setComment( "and how we're doing it . . ." );

//  clearMessage();
    
    setParticipant( 1, 2, "Me" );
    setSecondaryParticipant( 1, 2, "Me" );
    
    setRun( 2, 2 );
//    clearRun( );

    setFrequency( 1, 2, "22Hz" );
//    clearFrequency();
    
    setIterations( 320000, SECONDARY );
    setPercent( 160000, SECONDARY );
    setIterations( 320, PRIMARY );
    setPercent( 8, PRIMARY );
/*    setForHRFMAX();
    increment();
    increment();
    flagTChange();
    increment();
    increment();
//    setPercent( 10 );
//    setPercent( 20 );
    flagTChange();
    increment();
*/
//    setPong(true);
  };


  public void setIterations( double iters, int which ) {
    maxIters[which] = iters;
	currentIter[which] = 0;
    initTime = 0l;
    this.firePropertyChange( "EVT_UPDATE", 2, which  );  
    this.firePropertyChange( "EVT_UPDATE", 4, which );  
  };

  // add an iteration count to existing value
  public void addIterations( double iters, int which ) {
	    maxIters[which] += iters;
//		currentIter[which] = 0;
//	    initTime = 0l;
	    this.firePropertyChange( "EVT_UPDATE", 2, which  );  
	    this.firePropertyChange( "EVT_UPDATE", 4, which );  
	  };

  
  // backward compatibility - default to SECONDARY
  public void setIterations( double iters ) {
    setIterations( iters, SECONDARY );
   };


  public void setPercent( double count, int which ) {
	if ( count < 0 ) {  count = 0; }
	currentIter[which] = count;
    this.firePropertyChange( "EVT_UPDATE", 3, which  );  
  };

  
  public double getPercent( int which ) {
	return currentIter[which];
  };

  
  public void addPercent( double count, int which ) {
	if ( count < 0 ) {  count = 0; }
	currentIter[which] += count;
    this.firePropertyChange( "EVT_UPDATE", 3, which  );  
  };
  
  // backward compatibility - default to SECONDARY
  public void setPercent( double count ) {
	setPercent( count, SECONDARY );
  };
  
  
  public void increment( int which) {
	currentIter[which] += 1;
    this.firePropertyChange( "EVT_UPDATE", 4, which );  
  };


  // backward compatibility - increment with no parameters sets BOTH 
  public void increment() {
	increment(SECONDARY);
	increment(PRIMARY);
  };

  // special operations for hrfmax incrementing
  // standard EVT_UPDATEW Call for SECONDARY
  // revise Message 'iterations n/# update every 100 iterations
  public void incrementHrfmax() {
	currentIter[SECONDARY] += 1;
    this.firePropertyChange( "EVT_UPDATE", 4, SECONDARY );  

    hrfIterNo++;
    if ( hrfIterNo >= hrfIterAlter ) {
      hrfIterNo = 0;
  	  msgSubText = String.format("Iterations: %d / %d", (int)currentIter[SECONDARY]-1, (int)maxIters[SECONDARY]);
	  this.firePropertyChange( "EVT_SET_MESSAGE", 2, 0  );  
    }

  };
 

  public void setWindowTitle( String title ) {
	winTitle = title;
    this.firePropertyChange( "EVT_SET_TITLE", 1, 0  );  
  };

  
  public void setMessages( String title, String text, String comment ) {
	msgText = title;
	msgSubText = text;
	msgComment = comment;
	this.firePropertyChange( "EVT_SET_MESSAGE", 4, 1  );  
  };

  
  public void clearMessages() {
	msgText = "";
	msgSubText = "";
	msgComment = "";
    this.firePropertyChange( "EVT_SET_MESSAGE", 4, 0  );  
  };
	   

	  
  public void setProcess( String text ) {
	msgText = text;
    this.firePropertyChange( "EVT_SET_MESSAGE", 1, 0  );  
  };

  public String getProcess( ) {
		return msgText;
	  };
  
  public void clearProcess() {
	msgText = "";
	this.firePropertyChange( "EVT_SET_MESSAGE", 1, 0 );  
  };

  public void setMessage( String text ) {
	msgSubText = text;
    this.firePropertyChange( "EVT_SET_MESSAGE", 2, 0  );  
  };
  
  
  public String getMessage( ) {
	return msgSubText;
  };

  public void clearMessage() {
	msgSubText = "";
    this.firePropertyChange( "EVT_SET_MESSAGE", 2, 0  );  
  };
  
  
  public void setComment( String text ) {
	msgComment = text;
    this.firePropertyChange( "EVT_SET_MESSAGE", 3, 0  );  
  };

  public String getComment( ) {
		return msgComment;
  };

  public void clearComment() {
	msgComment = "";
    this.firePropertyChange( "EVT_SET_MESSAGE", 3, 0  );  
  };
  
  
  public void setParticipant( int sno, int nsub, String sid ) {
	subjectText = String.format("Participant: %s ( %d of %d )", sid, sno, nsub  );
    this.firePropertyChange( "EVT_SET_PARTICIPANT", 1, 2  );  
  };

  
  public void clearParticipant() {
    this.firePropertyChange( "EVT_SET_PARTICIPANT", 0, 2  );  
  };
  
  
  // some operations use primary and secondary subject segment calculations
  // this setRun override allows the use of the RUN display for this purpose
  public void setSecondaryParticipant( int sno, int nsub, String sid ) {
	subjectText = String.format("Secondary: %s ( %d of %d )", sid, sno, nsub  );
    this.firePropertyChange( "EVT_SET_PARTICIPANT", 1, 3  );  
  };

  
  public void clearSecondaryParticipant() {
	    this.firePropertyChange( "EVT_SET_PARTICIPANT", 0, 3  );  
	  };
  
  
  public void setRun( int rno, int nrun ) {
	runText = String.format("Run: %d of %d", rno, nrun );
    this.firePropertyChange( "EVT_SET_RUN", 1, 0  );  
  };


  public void clearRun() {
    this.firePropertyChange( "EVT_SET_RUN", 0, 1  );  
  };
  
  
  public void setFrequency( int fno, int nfrq, String fid ) {
    freqText = String.format("Frequency: %s ( %d of %d )", fid, fno, nfrq  );
    this.firePropertyChange( "EVT_SET_FREQUENCY", 1, 0  );  
  };

  
  public void clearFrequency() {
	this.firePropertyChange( "EVT_SET_FREQUENCY", 0, 1  );  
  };
  
  
  public void setPong( boolean state) {
		this.Process.setIndeterminate(state); 
		this.Process.setStringPainted(!state); 
	  };
  
  public void setForHRFMAX() {
    this.setSize ( expanded );
  };
  

  public void unsetHRFMAX() {
    this.setSize ( normal );
  };
  
   
  public void flagTChange(int which) {
	  Tchanges += 1;
	  prevChangeIter = thisChangeIter;
	  thisChangeIter = currentIter[which];
	  
	  String s1 = formatDisplay( Tchanges );
	  String s2 = formatDisplay( thisChangeIter );
	  String s3 = formatDisplay( prevChangeIter );
	  
	  Tstats = String.format("<html><b>T Changes: %s<br>Changed At: %s<br>Prev Change: %s</html>", s1, s2, s3 );
      this.firePropertyChange( "EVT_STATE_CHANGED", 1, 0  );  
  };
  

  public void flagTChange() {
	flagTChange( SECONDARY );
  }

	  
  public String formatDisplay( double value) {
    DecimalFormat tsep = new DecimalFormat("###,###,###,###");
    String output = tsep.format(value);	  
    return output;
  };
  
  
  public double getSaveState() {
	return saveCurrentState;
  };
 
  
  public double[] getStateInfo() {
	double si[] = {0, 0, 0 };
	si[0] = Tchanges;
	si[1] = thisChangeIter;
	si[2] = prevChangeIter;
	return si;
  };
  
  
  public void setStateInfo( double tc, double ci, double pi )  {
	Tchanges = tc;
	thisChangeIter = ci;
	prevChangeIter = pi;

	String s1 = formatDisplay( Tchanges );
	String s2 = formatDisplay( thisChangeIter );
	String s3 = formatDisplay( prevChangeIter );
	  
    Tstats = String.format("<html><b>T Changes: %s<br>Changed At: %s<br>Prev Change: %s</html>", s1, s2, s3 );
    this.firePropertyChange( "EVT_STATE_CHANGED", 1, 0  );  
  };
  
  public void activateSaveState()   {
	  SaveState.setEnabled(true);
	  saveCurrentState = 0;
  };

  
  public void deactivateSaveState()  {
	SaveState.setEnabled(false);
	saveCurrentState = 0;
  };
  
  
};


