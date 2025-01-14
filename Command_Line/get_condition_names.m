function conditions = get_condition_names(filename)
    fid = fopen(filename, 'r');
    if fid == -1
        error('Could not open file');
    end
    
    % Initialize empty cell array for conditions
    conditions = {};
    
    % Read each line
    tline = fgetl(fid);
    while ischar(tline)
        % Check if line starts with "sub-" (assuming all relevant lines follow this pattern)
        if startsWith(tline, 'sub-')
            % Extract the condition name
            % Find the position of underscore and equals sign
            underscorePos = find(tline == '_', 1);
            equalsPos = find(tline == '=', 1);
            
            if ~isempty(underscorePos) && ~isempty(equalsPos)
                % Extract the text between underscore and equals sign
                conditionName = tline(underscorePos+1:equalsPos-1);
                conditions{end+1} = conditionName;
            end
        end
        tline = fgetl(fid);
    end
    
    % Close the file
    fclose(fid);

    conditions = unique(conditions)

