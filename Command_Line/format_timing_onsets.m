% Script to format timing data from input to output format
function formatTimingData()
    % Read the input file
    fid = fopen('input1.txt', 'r');
    content = fscanf(fid, '%c');
    fclose(fid);
    
    % Get user inputs for formatting
    run_prefix = input('Enter the prefix for runs (e.g., ctd): ', 's');
    num_runs = input('Enter the number of runs: ');
    num_conditions = input('Enter the number of conditions: ');
    
    % Get condition names and their corresponding patterns in input file
    condition_names = cell(1, num_conditions);
    condition_patterns = cell(1, num_conditions);
    for i = 1:num_conditions
        condition_names{i} = input(['Enter name for condition ' num2str(i) ': '], 's');
        condition_patterns{i} = input(['Enter the pattern to match this condition in input file (e.g., eng, man, rev): '], 's');
    end
    
    % Process the content
    lines = strsplit(content, '\n');
    
    % Open output file
    fid_out = fopen('output1.txt', 'w');
    
    % Initialize variables for tracking current subject
    current_subject = '';
    
    % Process each line
    for i = 1:length(lines)
        line = strtrim(lines{i});
        if isempty(line)
            continue;
        end
        
        % Extract subject number and values
        matches = regexp(line, '^c(\d+)_(\w+)(\d+)=(\[[\d\s]+\])', 'tokens');
        if ~isempty(matches)
            tokens = matches{1};
            subject_num = tokens{1};
            pattern = tokens{2};
            run_number = tokens{3};
            values = tokens{4};
            
            % If new subject encountered, write header
            if ~strcmp(current_subject, subject_num)
                current_subject = subject_num;
                fprintf(fid_out, '\n%% ------------------------------------------------------\n');
                fprintf(fid_out, '%% --- timing onsets for subject %d (c%s)\n', str2double(subject_num), subject_num);
                fprintf(fid_out, '%% ------------------------------------------------------\n');
            end
            
            % Find matching condition
            condition_idx = find(strcmp(pattern, condition_patterns));
            if ~isempty(condition_idx)
                % Format the output line
                fprintf(fid_out, 'c%s_%s_%s_%s = %s;\n', ...
                    subject_num, ...
                    run_prefix, ...
                    run_number, ...
                    condition_names{condition_idx}, ...
                    values);
            end
        end
    end
    
    fclose(fid_out);
    disp('Formatting complete! Check output1.txt for results.');
end