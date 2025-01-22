function create_onsets_template_cmd(base_dir,GH,timing)
% create timing onsets template, 'timing_onsets_template.txt'

%
cd(base_dir);

% check the exiting of Z matrix
if exist([base_dir filesep 'ZInfo.mat'], 'file') ~= 2
    disp('List or Zinfo file does not exist');
    return
end
fullpath = [base_dir filesep 'ZInfo.mat'];
eval( [ 'load( ''' fullpath ''', ''Zheader'' ,''scan_information''); '] );


% --------------------------------------------------
% --- create the template with the onsets values inserted
% --------------------------------------------------
comment = '% ------------------------------------------------------';

fullpath = [base_dir filesep 'timing_onsets_template.txt'];
GH.conditions = size(GH.condition_name, 2 ); %Number of conditions
fid = fopen( fullpath, 'w' );

if ( fid )

    fprintf( fid,'%% ------------------------------------------------------\n');
    fprintf( fid,'%% --- NOTE: The sequence of timing onset definitions is critical.\n');
    fprintf( fid,'%% --- All timing onsets must be prepared in the order displayed in this this file.\n');
    fprintf( fid,'%% --- Timing onsets may be inserted directly into this file, or imported from a separate text file\n');
    fprintf( fid,'%% --- All timing onsets imported from a separate text file must be prepared in the order displayed below\n');
    fprintf( fid,'%% --- Any onset condition names in an imported text file WILL BE IGNORED and those listed below will be used, in the order listed below\n');
    fprintf( fid, '%% ------------------------------------------------------\n\n');

    for  SubjectNo = 1:Zheader.num_subjects
        s_id = char(scan_information.SubjectID( SubjectNo ) );

        fprintf( fid, '%s\n%% --- timing onsets for subject %d (%s)\n%s\n', comment, SubjectNo, char(s_id), comment );

        for RunNo = 1:Zheader.num_runs

            if iscellstr( scan_information.SubjDir( SubjectNo, RunNo ) )

                run_id = determine_runID_cmd( SubjectNo, RunNo, scan_information );

                for cond = 1:GH.conditions
                    cond_id = char( GH.condition_name{cond});

                    var_id = [s_id '_' run_id '_' cond_id ];
                    var_id = strrep( var_id, '__', '_' );
                    var_id = strrep( var_id, ' ', '_' );

                    timings = timing{SubjectNo}{RunNo}{cond};
                    fprintf( fid, '%s = [%s];\n', char(var_id), timings );  

                end  % --- each condition ---

                if ( size(Zheader.conditions.subject,1) > 2 ) 
                    fprintf( fid, '\n' );  
                end

            end  % --- subject contains run ---

        end  % --- each subject run ---

        fprintf( fid, '\n' );

    end  % --- each subject ---



end  % --- template file opened ---

fclose( fid );
