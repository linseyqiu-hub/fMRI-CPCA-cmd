function timing = get_timing(filename)
    % Read the entire file into a cell array, line by line
    fid = fopen(filename, 'r');
    if fid == -1
        error('Could not open file');
    end
    
    % Initialize empty cell array for timings
    timing = {};
    
    % Read each line
    tline = fgetl(fid);
    while ischar(tline)
        % Find the position of the equals sign and the brackets
        equalsPos = find(tline == '=', 1);
        openBracketPos = find(tline == '[', 1);
        closeBracketPos = find(tline == ']', 1);
        
        if ~isempty(equalsPos) && ~isempty(openBracketPos) && ~isempty(closeBracketPos)
            % Extract the numbers between brackets
            numberStr = tline(openBracketPos+1:closeBracketPos-1);
            
            % Remove any extra spaces at the beginning or end
            numberStr = strtrim(numberStr);
            
            % Add to timings cell array
            timing{end+1} = numberStr;
        end
        tline = fgetl(fid);
    end
    
    % Close the file
    fclose(fid);
end