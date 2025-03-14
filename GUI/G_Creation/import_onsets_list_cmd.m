function [txt, onsetsfile, Zheader] = import_onsets_list_cmd(base_dir, filename, model_type, Zheader, scan_information)
% will return the file name on successful import


  %base_dir = './example_data_Multiple_Groups_Subjects_Runs';
  %filename = 'timing_onsets.txt';
  %Zheader.conditions.Names = {'2_letters',	'4_letters', '6_letters','8_letters'};
  %model_type = 0;  %1 for HRF, 0 for FIR

  txt = '';
  onsetsfile = '';

  import_file = constant_define( 'G_IMPORT_NAME' );

  fullpath = [base_dir filesep filename];

  %text = fileread(fullpath);
  fid = fopen(fullpath);
  TextAsCells = textscan(fid, '%s','Delimiter','\n', 'CommentStyle','%');
  TextAsCells = TextAsCells{1};
  fclose(fid);

  % -- reset the list of encoded conditions per subject
  Zheader.conditions.encoded = [];
  Zheader.conditions.allEncoded = 0;
  Zheader.conditions.nonEncoded = 0;
  numconds = size(Zheader.conditions.Names,2);

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
    
    for SubjectNo = 1:Zheader.num_subjects 
      %s = struct( 'Runs', zeros(1, Zheader.num_runs ) ) ;
      z.condition = zeros( 1, size( Zheader.conditions.Names,2) );
      for RunNo = 1:Zheader.num_runs 
        if iscellstr( scan_information.SubjDir( SubjectNo, RunNo ) ) 
          vec=[];  
          for condno = 1:numconds
              
                subj_id = subject_id_cmd( SubjectNo, scan_information);
                run_id = determine_runID_cmd( SubjectNo, RunNo, scan_information );
                
                % Try with both patterns: subj_id_run_id_condition and subj_id_condition
                pattern1 = append(subj_id, '_', run_id, '_', Zheader.conditions.Names{condno});
                pattern2 = append(subj_id, '_', Zheader.conditions.Names{condno});
                
                % Check for either pattern in the file
                index1 = find(~cellfun(@isempty, strfind(TextAsCells, pattern1)));
                index2 = find(~cellfun(@isempty, strfind(TextAsCells, pattern2)));
                
                % Combine the results - if either pattern is found
                if (isempty(index1) && isempty(index2))
                    Zheader.conditions.nonEncoded = Zheader.conditions.nonEncoded + 1;
                else
                    vec = [vec, condno]; %[1,2,3,4]
                    z.condition(condno) = 1;
                    Zheader.conditions.allEncoded = Zheader.conditions.allEncoded + 1;
                    required_onsets = required_onsets + 1;  
                end
          end
            Zheader.conditions.subject(SubjectNo).Run(RunNo).conditions = vec; %[1,2,3,4]
            Zheader.conditions.encoded(SubjectNo,1).condition = z.condition;
        end
      end
      
      %subject_onsets.Subject = [ subject_onsets.Subject; s ];
      
    end
    if ( model_type == constant_define( 'HRF_MODEL' ) )
      required_onsets = required_onsets * 2;	% -- onsets and durations
    end

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

      fprintf( 'Expected Trial count: %d \n',  required_onsets );
      fprintf( '   Found Trial count: %d \n',  found_onsets );
      fprintf( '<br>Input File: %s \n',  fullpath) ;
      
      fprintf( 'We expected to find %d entries in the timing onset file, but instead encountered %d \n', required_onsets, found_onsets );
      % fprintf(  'Mismatched Trial Onsets Count %s', str );
      return

    end

    % --------------------------------------------------
    % --- recreate the template with the onsets values inserted
    % --------------------------------------------------
    handles.lin = '% ------------------------------------------------------';
    handles.hdr = '%s\n%% --- NOTE: The sequence of timing onset definitions is critical.\n%% --- All timing onsets must be prepared in the order displayed in this this file.\n%% --- Timing onsets may be inserted directly into this file, or imported from a separate text file\n%% --- All timing onsets imported from a separate text file must be prepared in the order displayed below\n%% --- Any onset condition names in an imported text file WILL BE IGNORED and those listed below will be used, in the order listed below\n%s\n\n';


    fid = fopen( import_file, 'w' );
    fidr = fopen ( fullpath, 'r' );

    if ( fid )

      fprintf( fid, handles.lin, handles.hdr, handles.lin ); 

      for  SubjectNo = 1:Zheader.num_subjects
        s_id = char(scan_information.SubjectID( SubjectNo ) );

        fprintf( fid, '%s\n%% --- timing onsets for subject %d (%s)\n%s\n', handles.lin, SubjectNo, char(s_id), handles.lin );

%        for RunNo = 1:size( handles.conditions.subject(SubjectNo).Run,1 )
        for RunNo = 1:Zheader.num_runs 

          if iscellstr( scan_information.SubjDir( SubjectNo, RunNo ) )

            run_id = determine_runID_cmd( SubjectNo, RunNo, scan_information );

            for cond = 1:size( Zheader.conditions.subject(SubjectNo).Run(RunNo).conditions, 2) 
              cond_id = char( Zheader.conditions.Names( Zheader.conditions.subject(SubjectNo).Run(RunNo).conditions( cond )  ) );

              var_id = [s_id '_' run_id '_' cond_id ];
              var_id = strrep( var_id, '__', '_' );
              var_id = strrep( var_id, ' ', '_' );

              timings = next_entry( fidr );
              if ( fid ) fprintf( fid, '%s = [%s];\n', char(var_id), timings );  end

              if ( model_type == constant_define( 'HRF_MODEL' ) )
                timings = next_entry( fidr );
                if ( fid ) fprintf( fid, '%s_dur = [%s];\n', char(var_id), timings );  end
              end

            end  % --- each condition ---

            if ( size(Zheader.conditions.subject,1) > 2 ) fprintf( fid, '\n' );  end

          end  % --- subject contains run ---

        end  % --- each subject run ---

        fprintf( fid, '\n' ); 

      end  % --- each subject ---

      fclose( fid );
      fclose( fidr );
      txt = import_file;
      onsetsfile = 'source';
      
    end  % --- template file opened ---


  end

