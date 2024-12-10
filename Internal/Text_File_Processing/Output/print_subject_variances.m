function print_subject_variances( fid, mask_registry)
global Zheader

  if nargin < 1,  fid = 1;  end
  if nargin < 2,  mask_registry = 0;  end
  if fid < 3,     fid = 1;  end;   % --- make sure stderr goes to stdout
  
  load( Zheader.Model.path, 'Gheader' );
  
  fprintf( fid, '\n\nVariance accounted for in subject GC\n------------------------------------------\n' );

  for SubjectNo = 1:Zheader.num_subjects

    GCsd = load_subject_GC_var( Gheader, SubjectNo, 'SSQ' );
    Zsd  = load_subject_Z_var( SubjectNo, 'SSQ' );

    tsum = [];
    sumDiag = [];
    
    switch mask_registry
      case 0
        sumDiag = GCsd.sd;
        tsum = Zsd.sd;
      case 1
        sumDiag = GCsd.Rsd(1) + sum(GCsd.Rsd(4:5));
        tsum = Zsd.Rsd(1) + sum(Zsd.Rsd(4:5));
      case 2
        sumDiag = GCsd.Rsd(2);
        tsum = Zsd.Rsd(2);
    end
    
    if ~isempty( tsum ) && ~isempty( GCsd )
      fprintf( fid,  '%s', subject_id(SubjectNo) ); 
      fprintf( fid, ['\t' constant_define( 'PREFERENCES', 'precision.log', '%.2f' ) '%%\n'] , (sumDiag / tsum * 100) ); 
    end;
  
  end

end

