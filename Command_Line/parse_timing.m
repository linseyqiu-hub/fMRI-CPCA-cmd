function timing = parse_timing(base_dir, num_subjects, num_runs, num_conditions, subject_conditions, condition_names, scan_information)
    cd(base_dir);
    timing = cell(num_subjects, num_runs, num_conditions);

    fid = fopen('timing_onsets.txt', 'r');
    if fid == -1
        error('Could not open timing_onsets.txt');
    end
    lines = {};
    while ~feof(fid)
        line = fgetl(fid);
        if ischar(line)
            lines{end+1} = line;
        end
    end
    fclose(fid);

    for s = 1:num_subjects
        subj_id = subject_id_cmd(s, scan_information);
        for r = 1:num_runs
            if ~iscellstr(scan_information.SubjDir(s, r))
                continue;
            end
            run_id = determine_runID_cmd(s, r, scan_information);
            cond_indices = subject_conditions{s}{r};  % e.g. [1 2 3 4] or [5 6]
            for c = 1:length(cond_indices)
                condno = cond_indices(c);
                cond_name = condition_names{condno};
                pattern1 = [subj_id '_' run_id '_' cond_name];
                pattern2 = [subj_id '_' cond_name];
                for l = 1:length(lines)
                    line = lines{l};
                    if isempty(line) || line(1) == '%'
                        continue;
                    end
                    if isempty(strfind(line, pattern1)) && isempty(strfind(line, pattern2))
                        continue;
                    end
                    start_bracket = find(line == '[', 1);
                    end_bracket   = find(line == ']', 1);
                    if isempty(start_bracket) || isempty(end_bracket)
                        continue;
                    end
                    timing{s, r, condno} = strtrim(line(start_bracket+1:end_bracket-1));
                    break;
                end
            end
        end
    end
end