function idx = encodedIndex( subject )
  global Zheader scan_information

%  spBinMask = ones( 1, Zheader.conditions.sp(1,2) );
  spBinMask = ones( 1, scan_information.processing.model.parameters.bins );
  Msk = zeros( 1, size(spBinMask,2) * size( Zheader.conditions.sp, 2 ) );
  idx = [];

  for cond = 1:size(Zheader.conditions.sp,2)
    if isEncoded( subject, cond )
      Msk( (cond-1)*size(spBinMask,2)+1:(cond-1)*size(spBinMask,2)+size(spBinMask,2) ) = spBinMask;
    end;
  end;
  idx = find( Msk );


