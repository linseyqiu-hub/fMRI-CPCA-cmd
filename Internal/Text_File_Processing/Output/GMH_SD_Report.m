function GMH_SD_Report( Hheader, module )
% --- gather the necessary information for sum of squares report
% --- and pass to report processor
global Zheader
  GMHsd = [];

  if isfield( Hheader.model(Hheader.Hindex).sum_diagonal, module )
    eval( ['GMHsd = Hheader.model(Hheader.Hindex).sum_diagonal.' module ';' ] );  
  end;
  switch module
    case 'GMH'
      GMHsd = Hheader.model(Hheader.Hindex).sum_diagonal.GMH;
    case 'GnotH'
      GMHsd = Hheader.model(Hheader.Hindex).sum_diagonal.GC;
    case 'HnotG'
      GMHsd = Hheader.model(Hheader.Hindex).sum_diagonal.BH;
  end
  
  GMHrpt =  [ Hheader.model( Hheader.Hindex).path_to_segs.GMH module '_SSQ_report.txt'];
  
  data.header = Hheader;
  data.model = module;
  data.txt = module;
  data.tsum = Zheader.tsum;
  data.GCSum = GMHsd;
  data.GCrpt = GMHrpt;
  data.GCtag = 'GC';
  
