function [txt onsetsfile] = import_subject_run_onsets( handles, numconds, SubjectNo )
% will return the file name on successful import
% handles    handles from internal dialogs

  txt = '';
  onsetsfile = '';
  sfmt = full_dec_format(handles.Zheader.num_subjects );
  sid = subject_id( SubjectNo );
  ln = separator_line( 40, '-' );

  import_file = 'timing_onsets_imported.txt';

  if  prod( SubjectNo ) == 1
    fid = fopen( import_file, 'w' );
  
%    fprintf( fid, ln, handles.hdr, ln ); 
  
    fprintf( fid, '%% %s\n',  ln );
    fprintf( fid, '%% auto-created source onsets import file \n' );
    fprintf( fid, '%% %s\n', ln );
    fclose( fid );
  
  end;

  fid = fopen( import_file, 'a' );
  fprintf( fid, '\n%% %s\n%% --- timing onsets for subject %d (%s)\n', ln, SubjectNo, sid );

     
  for RunNo = 1:handles.Zheader.num_runs
    if iscellstr( handles.scan_information.SubjDir( SubjectNo, RunNo ) ) 
  
      fullpath =  [char(handles.scan_information.BaseDir) filesep char(handles.scan_information.SubjDir( SubjectNo, RunNo )) filesep ];
      d = dir( [ fullpath constant_define( 'SOURCE_TIMING_SPEC' ) ] );
      if size( d, 1 ) == 1
      
        onsetsfile = [ fullpath d(1).name ];

        if ( fid )

          fidr = fopen ( onsetsfile, 'r' );
     
          run_id = determine_runID( SubjectNo, RunNo, handles );

          for cond = 1:size( handles.conditions.subject(SubjectNo).Run(RunNo).conditions, 2) ;
            cond_id = char( handles.conditions.Names( handles.conditions.subject(SubjectNo).Run(RunNo).conditions( cond )  ) );
            cond_id = strrep( cond_id, ' ', '_' );   % --- replace any spaces with underscore characters
            
            var_id = [sid '_' run_id '_' cond_id ];
            var_id = strrep( var_id, '__', '_' );
            var_id = strrep( var_id, ' ', '_' );

            [timings f] = find_entry( fidr, cond_id );
            if ( fid ) fprintf( fid, '%s = [%s];\n', char(var_id), timings );  end;

            if ( handles.output.gh.model_type == constant_define( 'HRF_MODEL' ) )
              timings = next_entry( fidr );
              if ( fid ) fprintf( fid, '%s_dur = [%s];\n', char(var_id), timings );  end;
            end;

          end;  % --- each condition ---

          if ( size(handles.conditions.subject,1) > 2 ) fprintf( fid, '\n' );  end;

          fclose( fidr );

        end;  % --- template file opened ---

      else  % --- trial_timings not found or ambiguous
        if size( d, 1 ) > 0
          display( [ fullpath ' contains more than 1 trial onsets file.'] );        
        else
          display( [ fullpath ' does not contain a trial onsets file.'] );        
        end
    
      end;  % --- onsets file discovered

    end; % --- run encoded
  end; % --- each run
  

  fclose( fid );
  txt = import_file;
  
