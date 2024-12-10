function [txt, onsetsfile] = import_onsets_list( handles, numconds )
% will return the file name on successful import
% handles    handles from internal dialogs

  txt = '';
  onsetsfile = '';

  import_file = constant_define( 'G_IMPORT_NAME' );

  fullpath = select_file( {'*.m;*.txt', 'mat script or text file'}, ...
                                   'Select your condition onsets source');
  if ~isempty( fullpath )

    onsetsfile = fullpath;

    % --------------------------------------------------
    % --- first check that we have the correct number of defined onset variables
    % --------------------------------------------------

    % --------------------------------------------------
    % --- how many onset entries are we expecting
    % --------------------------------------------------
    required_onsets = 0;
    subject_onsets = struct( 'Subject', []);
    
    for SubjectNo = 1:handles.Zheader.num_subjects 
      s = struct( 'Runs', zeros(1, handles.Zheader.num_runs ) ) ;
      
      for RunNo = 1:handles.Zheader.num_runs 
        if iscellstr( handles.scan_information.SubjDir( SubjectNo, RunNo ) ) 
          for condno = 1:numconds
            if any(handles.Zheader.conditions.subject(SubjectNo).Run(RunNo).conditions == condno )   
              required_onsets = required_onsets + 1;  
              s.Runs( RunNo ) = s.Runs( RunNo ) + 1;
            end;
          end;
        end;
      end;
      
      subject_onsets.Subject = [ subject_onsets.Subject; s ];
      
    end;
    if ( handles.output.gh.model_type == constant_define( 'HRF_MODEL' ) )
      required_onsets = required_onsets * 2;	% -- onsets and durations
    end;

    % --------------------------------------------------
    % --- how many onset entries are in the file
    % --------------------------------------------------
    found_onsets = 0;
    fid = fopen ( fullpath, 'r' );

    while ~feof(fid)
      [timings good] = next_entry( fid );
      if good
        found_onsets = found_onsets + 1;
      end  % --- line text good ---

    end  % --- while ~feof() ---

    fclose(fid);

    if ( found_onsets ~= required_onsets )

      str = sprintf( 'Expected Trial count: %d <br>',  required_onsets );
      str = [str sprintf( '   Found Trial count: %d <br>',  found_onsets ) ];
      str = [str sprintf( '<br>Input File: %s <br>',  fullpath ) ];
      
%      str = sprintf( 'We expected to find %d entries in the timing onset file, but instead encountered %d', required_onsets, found_onsets );
      show_message(  'Mismatched Trial Onsets Count', str );
      return

    end;

    % --------------------------------------------------
    % --- recreate the template with the onsets values inserted
    % --------------------------------------------------

    fid = fopen( import_file, 'w' );
    fidr = fopen ( fullpath, 'r' );

    if ( fid )

      fprintf( fid, handles.lin, handles.hdr, handles.lin ); 

      for  SubjectNo = 1:handles.Zheader.num_subjects;
        s_id = char(handles.scan_information.SubjectID( SubjectNo ) );

        fprintf( fid, '%s\n%% --- timing onsets for subject %d (%s)\n%s\n', handles.lin, SubjectNo, char(s_id), handles.lin );

%        for RunNo = 1:size( handles.conditions.subject(SubjectNo).Run,1 )
        for RunNo = 1:handles.Zheader.num_runs 

          if iscellstr( handles.scan_information.SubjDir( SubjectNo, RunNo ) )

            run_id = determine_runID( SubjectNo, RunNo, handles );

            for cond = 1:size( handles.conditions.subject(SubjectNo).Run(RunNo).conditions, 2) ;
              cond_id = char( handles.conditions.Names( handles.conditions.subject(SubjectNo).Run(RunNo).conditions( cond )  ) );

              var_id = [s_id '_' run_id '_' cond_id ];
              var_id = strrep( var_id, '__', '_' );
              var_id = strrep( var_id, ' ', '_' );

              timings = next_entry( fidr );
              if ( fid ) fprintf( fid, '%s = [%s];\n', char(var_id), timings );  end;

              if ( handles.output.gh.model_type == constant_define( 'HRF_MODEL' ) )
                timings = next_entry( fidr );
                if ( fid ) fprintf( fid, '%s_dur = [%s];\n', char(var_id), timings );  end;
              end;

            end;  % --- each condition ---

            if ( size(handles.conditions.subject,1) > 2 ) fprintf( fid, '\n' );  end;

          end;  % --- subject contains run ---

        end;  % --- each subject run ---

        fprintf( fid, '\n' ); 

      end;  % --- each subject ---

      fclose( fid );
      fclose( fidr );
      txt = import_file;
      onsetsfile = 'source';
      
    end;  % --- template file opened ---


  end;

