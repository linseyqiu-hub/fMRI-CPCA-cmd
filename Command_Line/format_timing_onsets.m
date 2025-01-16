% Script to format timing data from input to output format
function formatTimingData(base_dir)
    cd(base_dir)

    % Read the input file
    fid = fopen('input.txt', 'r');
    content = fscanf(fid, '%c');
    fclose(fid);
    
    % Get user inputs
    num_runs = input('Enter the number of runs: ');
    
    % Get run names
    run_names = cell(1, num_runs);
    for i = 1:num_runs
        run_names{i} = input(['Enter name for run ' num2str(i) ': '], 's');
    end
    
    % Get condition names
    disp('Enter the condition names (e.g., English, Mandarin, Reversed_English):');
    num_conditions = input('Enter the number of conditions: ');
    condition_names = cell(1, num_conditions);
    for i = 1:num_conditions
        condition_names{i} = input(['Enter name for condition ' num2str(i) ': '], 's');
    end
    
    % Process the content
    lines = strsplit(content, '\n');
    
    % Open output file
    fid_out = fopen('output.txt', 'w');
    
    % Initialize variables for tracking current subject
    current_subject = '';
    
    % Process each line
    for i = 1:length(lines)
        line = strtrim(lines{i});
        if isempty(line)
            continue;
        end
        
        % Extract subject number from variable name
        matches = regexp(line, '^c(\d+)_', 'tokens');
        if ~isempty(matches)
            subject_num = matches{1}{1};
            
            % If new subject encountered, write header
            if ~strcmp(current_subject, subject_num)
                current_subject = subject_num;
                fprintf(fid_out, '\n%% ------------------------------------------------------\n');
                fprintf(fid_out, '%% --- timing onsets for subject %d (c%s)\n', str2double(subject_num), subject_num);
                fprintf(fid_out, '%% ------------------------------------------------------\n');
            end
            
            % Format the line
            parts = strsplit(line, '=');
            if length(parts) == 2
                var_name = strtrim(parts{1});
                values = strtrim(parts{2});
                
                % Extract run number and condition type
                name_parts = regexp(var_name, 'c\d+_(\w+)(\d+)', 'tokens');
                if ~isempty(name_parts)
                    condition_type = name_parts{1}{1};
                    run_number = str2double(name_parts{1}{2});
                    
                    % Map condition types to full names
                    switch condition_type
                        case 'eng'
                            condition = condition_names{1};
                        case 'man'
                            condition = condition_names{2};
                        case 'rev'
                            condition = condition_names{3};
                    end
                    
                    % Format the output line
                    fprintf(fid_out, 'c%s_ctd_%d_%s = %s;\n', ...
                        subject_num, ...
                        run_number, ...
                        condition, ...
                        values);
                end
            end
        end
    end
    
    fclose(fid_out);
    disp('Formatting complete! Check output.txt for results.');
end