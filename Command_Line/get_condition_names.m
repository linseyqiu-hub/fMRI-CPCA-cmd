function conditions = extractConditions(filename)
    % Read the entire file into a cell array, line by line
    fid = fopen(filename, 'r');
    if fid == -1
        error('Could not open file');
    end
    
    % Initialize empty cell array for conditions
    conditions = {};
    
    % Read each line
    tline = fgetl(fid);
    while ischar(tline)
        % Find the position of the last underscore and equals sign
        underscorePositions = find(tline == '_');
        equalsPos = find(tline == '=', 1);
        
        if ~isempty(underscorePositions) && ~isempty(equalsPos)
            % Get the last underscore position
            lastUnderscorePos = underscorePositions(end);
            
            % Extract the text between the last underscore and equals sign
            conditionName = tline(lastUnderscorePos+1:equalsPos-1);
            
            % Only add if we got a non-empty condition name
            if ~isempty(conditionName)
                conditions{end+1} = conditionName;
            end
        end
        tline = fgetl(fid);
    end
    
    % Close the file
    fclose(fid);
    
    % Remove any duplicate conditions
    conditions = unique(conditions);
end

