function timing = parse_timing(base_dir, num_subjects, num_runs, num_conds)
    cd(base_dir);
    % Initialize the cell array with the specified dimensions
    timing = cell(num_subjects, num_runs, num_conds);
    
    % Read all lines from the input file
    fid = fopen('timing_onsets.txt', 'r');
    if fid == -1
        error('Could not open input file');
    end
    content = textscan(fid, '%s', 'Delimiter', '\n');
    fclose(fid);
    content = content{1};
    
    % Counter for keeping track of which numbers we're reading
    line_idx = 1;
    
    % Process each set of numbers
    for subject = 1:num_subjects
        for run = 1:num_runs
            for cond = 1:num_conds
                % Get current line
                line = content{line_idx};
                
                % Extract numbers between brackets
                start_bracket = find(line == '[', 1);
                end_bracket = find(line == ']', 1);
                numbers_str = line(start_bracket+1:end_bracket-1);
                
                % Convert space-separated numbers to array
                timing{subject, run, cond} = str2num(numbers_str);
                
                % Move to next line
                line_idx = line_idx + 1;
            end
        end
    end
end