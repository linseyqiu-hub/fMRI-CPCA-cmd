function Z_SD_Report( sd)
global Zheader

  % --- produce report file on all SSQ 
  if nargin < 1
    sd = '';
  end
  
  Zrpt =  [ sd 'Z' filesep 'Z_SSQ_report.txt'];
  
  data.header = [];
  data.model = 'Z';
  data.txt = 'Z';
  data.tsum = Zheader.tsum;
  data.GCSum = Zheader.tsum;
  data.rsum = Zheader.rsum;
  data.GCrpt = Zrpt;
  
  produce_SD_Report( data );

