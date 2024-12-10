function produce_SD_Report( data )
% --- single point of control for writing of sum diagonal regression summaries 
global Zheader

  SSQ = [];

  rfid = fopen( data.GCrpt, 'w' );
  ln = '------------------------------------------------------';
  
  if rfid
      
     write_totals();

     for SubjectNo = 1:Zheader.num_subjects
       if strcmp( data.model, 'Z' )
         SSQ = load_subject_Z_var( SubjectNo, 'SSQ' );
       else       
         eval( [ 'SSQ = load_subject_' data.GCtag '_var( data.header, SubjectNo, ''SSQ'', data.model );' ] );
       end
     
      sid = subject_id( SubjectNo );
      
      write_subject_total();
      if Zheader.num_runs > 1
        write_subject_run_total();
      end
      
    end  % --- each subject

  end
 
  if rfid
     fclose( rfid );
  end;
 

  % --- inline functions to write individual sections to file
  function write_totals()  
    % --- write the sum of squres data for total study data      

    fprintf( '%s\n%s\n\n', 'Sum of squares report ', ln );
    fprintf( rfid, '%s\n%s\n\n', 'Sum of squares report ', ln );

    
    if strcmp( data.model, 'Z' )
      fprintf( '%36s   %13.2f\n', ['Total Sum of Squares: ' data.txt], data.GCSum );
      fprintf( rfid, '%36s   %13.2f\n', 'Total Sum of Squares', data.GCSum );
      
      
%       if sum(data.rsum(1:2)) > 0
%         fprintf( '%36s   %13.2f (%6.2f%%)\n', ' Gray Matter', data.rsum(1), data.rsum(1) / data.tsum * 100 );
%         fprintf( '%36s   %13.2f (%6.2f%%)\n', 'White Matter', data.rsum(2), data.rsum(2) / data.tsum * 100 );
%         
%         fprintf( rfid, '%36s   %13.2f (%6.2f%%)\n', ' Gray Matter', data.rsum(1), data.rsum(1) / data.tsum * 100 );
%         fprintf( rfid, '%36s   %13.2f (%6.2f%%)\n', 'White Matter', data.rsum(2), data.rsum(2) / data.tsum * 100 );
%         
%       end      
      
    else     
      fprintf( '%36s   %13.2f             (%6.2f%%)\n', ['Total Sum of Squares: ' data.txt], data.GCSum, data.GCSum / data.tsum * 100 );
      fprintf( rfid, '%36s   %13.2f            (%6.2f%%)\n', ['Total Sum of Squares: ' data.txt], data.GCSum, data.GCSum / data.tsum * 100 );

%       if sum(data.rsum(1:2)) > 0
%          fprintf( rfid, '%36s   %13.2f  (%6.2f%%)  (%6.2f%%)\n', ' Gray Matter', ...
%            data.rsum(1), data.rsum(1) / data.GCSum * 100, data.rsum(1) / data.tsum * 100 );
%          fprintf( rfid, '%36s   %13.2f  (%6.2f%%)  (%6.2f%%)\n', 'White Matter', ...
%            data.rsum(2), data.rsum(2) / data.GCSum * 100, data.rsum(2) / data.tsum * 100 );
%          
%       end
            
      
    end
      
  end   % --- end nested function ---

  function write_subject_total()
     
    sb = sprintf( 'Subject %d (%s)', SubjectNo, sid );
    fprintf( rfid, '\n%22s %s%s\n%s\n', sb, blanks(5), '', ln );
    
    if strcmp( data.model, 'Z' )
      fprintf( rfid, '%36s   %13.2f (%6.2f%%)\n', 'Sum of Squares', SSQ.sd, SSQ.sd / data.GCSum * 100 );
        
      
%       if sum(data.rsum(1:2)) > 0
%         fprintf( rfid, '%36s   %13.2f (%6.2f%%)\n', ' Gray Matter', SSQ.Rsd(1), SSQ.Rsd(1) / data.GCSum * 100 );
%         fprintf( rfid, '%36s   %13.2f (%6.2f%%)\n', 'White Matter', SSQ.Rsd(2), SSQ.Rsd(2) / data.GCSum * 100 );
%       end
      
    else
      fprintf( rfid, '%36s   %13.2f (%6.2f%%)  (%6.2f%%)\n', 'Sum of Squares', ...
          SSQ.sd, SSQ.sd / data.GCSum * 100, SSQ.sd / data.tsum * 100 );

%       if sum(data.rsum(1:2)) > 0
%         fprintf( rfid, '%36s   %13.2f (%6.2f%%)  (%6.2f%%)\n', ' Gray Matter', ...
%             SSQ.Rsd(1), SSQ.Rsd(1) / data.GCSum * 100, SSQ.Rsd(1) / data.tsum * 100 );
%         fprintf( rfid, '%36s   %13.2f (%6.2f%%)  (%6.2f%%)\n', 'White Matter', ...
%             SSQ.Rsd(2), SSQ.Rsd(2) / data.GCSum * 100, SSQ.Rsd(2) / data.tsum * 100 );
%       end
      
    end
    
  end   % --- end nested function ---


  function write_subject_run_total()

      fprintf( rfid, '\n' );
      for runno = 1:size(SSQ.Subject.sd, 1 )
        if isEncodedRun( SubjectNo, runno ) 
          sr = sprintf( 'Run %d', runno );
          fprintf( rfid, '%22s %13.2f   %13.2f%%\n', sr,    SSQ.Subject.sd(runno), SSQ.Subject.sd(runno) / data.GCSum * 100 );
          if isMultiFrequency()
            for freq = 1:size(SSQ.Subject.Fsd, 2 )
              ftag = frequency_tag( freq );
              fdsp = strrep( ftag, '_', '' );
              sr = sprintf( ' %d: %s', freq, fdsp );
              fprintf( rfid, '%22s %13.2f   %13.2f%%\n', fdsp,   SSQ.Subject.Fsd(runno,freq),  SSQ.Subject.Fsd(runno,freq)/ SSQ.Subject.sd(runno) * 100  );
            end
          end
          fprintf( rfid, '\n' );
        end
      end

      
  end   % --- end nested function ---
      
end  % --- main function ---
