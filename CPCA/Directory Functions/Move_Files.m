function Move_Files( args, files )
%MOVE_FILES Summary of this function goes here
%   Detailed explanation goes here
directory = args{1};
move_files_to = args{2};
move_files_pattern = args{3};
for i = 1:size(files)
	if (~isempty(strfind(files(i).name, move_files_pattern)) && isdir(move_files_to))
		movefile([directory filesep files(i).name], move_files_to); 
	end
end
end


