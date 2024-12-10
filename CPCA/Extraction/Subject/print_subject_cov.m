function print_subject_cov( fid, ss, variance, Gheader, style)
global Zheader 

    if nargin < 5
      style = 'cov';
    end;
    
    Normalized_Z_Dir = Z_Directory();

    fprintf( fid, '\nSum of Values Squared - %s( [UR GC] )\n------------------------------------------\n', style );
    for SubjectNo = 1:Zheader.num_subjects
      sid = subject_id( SubjectNo );
      fprintf( fid,  '%s', sid ); 

      z=[]; 
      for comp = 1:size(ss,2)
        y = sprintf( '\t%.4f', ss(SubjectNo,comp) ); 
        z = [z y];
      end; 
      fprintf( fid, '%s\n', z );

    end;    

    fprintf( fid, '\nVariance - %s( [UR GC] )\n------------------------------------------\n', style );
    for SubjectNo = 1:Zheader.num_subjects
      sid = subject_id( SubjectNo );
      fprintf( fid,  '%s', sid ); 

      z=[]; 
      for comp = 1:size(variance,2)
        y = sprintf( '\t%.4f', variance(SubjectNo,comp) ); 
        z = [z y];
      end; 
      fprintf( fid, '%s\n', z );

    end;    


    fprintf( fid, '\n\nVariance accounted for in subject GC\n------------------------------------------\n' );
    for SubjectNo = 1:Zheader.num_subjects
      sid = subject_id( SubjectNo );

      gcsd = load_subject_GC_var( Gheader, SubjectNo, 'subject_GCsd' );
      tsum = load_subject_Z_var( SubjectNo, 'tsum_subject' );
        
      if ~isempty( gcsd ) && ~isempty( tsum )
        fprintf( fid,  '%s', sid); 
        fprintf( fid, '\t%.4f\n', (gcsd / tsum * 100) ); 
      end;

    end;

    fprintf( fid, '\n');

