function print_subject_cov_cmd(Zheader,scan_information, fid, ss, variance, Gheader, style)

    if nargin < 7
      style = 'cov';
    end
    
    Normalized_Z_Dir = Z_Directory_cmd(Zheader);

    fprintf( fid, '\nSum of Values Squared - %s( [UR GC] )\n------------------------------------------\n', style );
    for SubjectNo = 1:Zheader.num_subjects
      sid = subject_id_cmd ( SubjectNo,scan_information );
      fprintf( fid,  '%s', sid ); 

      z=[]; 
      for comp = 1:size(ss,2)
        y = sprintf( '\t%.4f', ss(SubjectNo,comp) ); 
        z = [z y];
      end 
      fprintf( fid, '%s\n', z );

    end    

    fprintf( fid, '\nVariance - %s( [UR GC] )\n------------------------------------------\n', style );
    for SubjectNo = 1:Zheader.num_subjects
      sid = subject_id_cmd( SubjectNo,scan_information );
      fprintf( fid,  '%s', sid ); 

      z=[]; 
      for comp = 1:size(variance,2)
        y = sprintf( '\t%.4f', variance(SubjectNo,comp) ); 
        z = [z y];
      end 
      fprintf( fid, '%s\n', z );

    end    


    fprintf( fid, '\n\nVariance accounted for in subject GC\n------------------------------------------\n' );
    for SubjectNo = 1:Zheader.num_subjects
      sid = subject_id_cmd( SubjectNo,scan_information );

      gcsd = load_subject_GC_var_cmd( Gheader, Zheader, SubjectNo, 'subject_GCsd' );
      tsum = load_subject_Z_var_cmd(Zheader, SubjectNo, 'tsum_subject' );
        
      if ~isempty( gcsd ) && ~isempty( tsum )
        fprintf( fid,  '%s', sid); 
        fprintf( fid, '\t%.4f\n', (gcsd / tsum * 100) ); 
      end

    end

    fprintf( fid, '\n');

