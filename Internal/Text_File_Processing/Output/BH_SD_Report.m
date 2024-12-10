function BH_SD_Report( Hheader, mode)
global Zheader 

  % --- produce report file on all SSQ 
  H_Segments = [];
  BHsd = [];
  
  eval( [ 'H_Segments = Hheader.model(Hheader.Hindex).path_to_segs.' mode ';'] );
  eval( [ 'BHsd = Hheader.model(Hheader.Hindex).sum_diagonal.' mode ';' ] );
  
  BHrpt =  [ H_Segments 'SSQ_report.txt'];
  
  data.header = Hheader;
  data.model = [mode(1) 'H' ];
  data.txt = mode;
  if strcmp( mode, 'HE' )
    data.tsum = Zheader.tsum_E;
  else
    data.tsum = Zheader.tsum;
  end
  data.GCSum = BHsd;
  data.GCrpt = BHrpt;
  data.GCtag = 'BH';
  
  produce_SD_Report( data );

