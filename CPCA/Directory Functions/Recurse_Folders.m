function Recurse_Folders( args, func_name  )

%REMOVE_SPACES
%Removes the spaces in the names of all subdirectories in dirname

dirname = args{1};

sub_dir = dir(dirname);
sub_dir(~[sub_dir.isdir]) = [];

if~isempty(sub_dir)
        evaluation = [func_name '(args, sub_dir)'];
        eval(evaluation);
end
sub_dir = dir(dirname);
sub_dir(~[sub_dir.isdir]) = [];
for i = 1:size(sub_dir)
	if ~(isequal(sub_dir(i).name, '.') || isequal(sub_dir(i).name, '..'))
        args{1} = [dirname filesep sub_dir(i).name];
		Recurse_Folders(args, func_name);
	end
end
end
