function Rename_File(args, files)
%RENAME_FILE Summary of this function goes here
%   Detailed explanation goes here
directory = args{1};
original_name = args{2};
new_name = args{3};
for i = 1:size(files)
	if strfind(files(i).name, original_name)
		movefile([directory filesep files(i).name], [directory filesep strrep(files(i).name, original_name, new_name)]); 
	end
end
end


