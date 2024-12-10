function GC_SD_Report( Gheader, model, txt)
% --- gather the necessary information for sum of squares report
% --- and pass to report processor
global Zheader

  if nargin < 2
    model = 'G';
  end;
  if nargin < 3
    txt = 'GC';
  end;

  pth_add = '';
  
  % --- due to inline functions we need variable declarations to avoid
  % --- exception errors if they are required
  G_ROI   = [];
  Aheader = [];
  Grsum = zeros( 1, 5 );
  
  if strcmp( model, 'ROI' )

    GCrpt =  [ Gheader 'SSQ_report.txt'];
    
    load G_ROI
    GCSum = G_ROI.mask( G_ROI.Rindex).sum_diagonal;
    tsum = G_ROI.mask( G_ROI.Rindex).tsum_ZTrim;
  else
      
    tsum = Zheader.tsum;
    
    if ~strcmp( model, 'G' )
      load( Zheader.Contrast.path );
      idx = 1 + strcmp( model, 'GAA' );
      GCSum = Aheader.model( Aheader.Aindex).sd(idx);

      if Aheader.Aindex > 1
        pth_add = strrep( [ filesep Aheader.model( Aheader.Aindex).id ], ' ', '_' );
      end
    
    else
      GCSum = 0;
      eval( [ 'GCSum = Gheader.' model 'Zheader.sum_diagonal;' ] );
      Grsum = Gheader.GZheader.rsum;
    end
    
    GCrpt =  [ model 'Zsegs' pth_add filesep 'SSQ_report.txt'];
    
  end
  
  data.header = Gheader;
  data.model = model;
  data.txt = txt;
  data.tsum = tsum;
  data.GCSum = GCSum;
  data.rsum = [Grsum(1)+Grsum(4)+Grsum(5) Grsum(2) ];  % --- ( gray + stem + cerebellum, white )
  data.GCrpt = GCrpt;
  data.GCtag = 'GC';

  produce_SD_Report( data );
  
  