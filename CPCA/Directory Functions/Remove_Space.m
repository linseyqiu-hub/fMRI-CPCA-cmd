function Remove_Space(args, files )
%REMOVE_SPACES
%Removes the spaces in the names of all subdirectories in dirname

dirname = args{1};
replacement_character = args{2};


    for i = 1:size(files)
        new_name = strrep(files(i).name, ' ', replacement_character);
            if ~isequal(new_name, files(i).name) 
                movefile([dirname filesep files(i).name], [dirname filesep new_name]); 
            end
    end
end

