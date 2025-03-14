function timing = parse_timing(base_dir, num_subjects, num_runs, num_conds)
    cd(base_dir);
    % Initialize the cell array with the specified dimensions
    timing = cell(num_subjects, num_runs, num_conds);
    
    % Keep track of position in the timing array
    cur_subject = 1;
    cur_run = 1;
    cur_cond = 1;
    
    % Read input file
    fid = fopen('timing_onsets.txt', 'r');
    if fid == -1
        error('Could not open input file');
    end
    
    while ~feof(fid)
        line = fgetl(fid);
        if isempty(line) || line(1) == '%'
            continue;
        end
        
        % Find the numbers between brackets
        start_bracket = find(line == '[', 1);
        end_bracket = find(line == ']', 1);
        if ~isempty(start_bracket) && ~isempty(end_bracket)
            numbers_str = line(start_bracket+1:end_bracket-1);
            
            % Store the numbers string in the timing cell array
            timing{cur_subject, cur_run, cur_cond} = numbers_str;
            
            % Update indices
            cur_cond = cur_cond + 1;
            if cur_cond > num_conds
                cur_cond = 1;
                cur_run = cur_run + 1;
                if cur_run > num_runs
                    cur_run = 1;
                    cur_subject = cur_subject + 1;
                end
            end
        end
    end
    fclose(fid);
end