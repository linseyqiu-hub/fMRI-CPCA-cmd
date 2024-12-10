function SplitAll(args, files)
%SPLITALL Summary of this function goes here
%   Detailed explanation goes here
directory = args{1};
    for i = 1:size(files)
        run_name = [args{2}, strrep(files(i).name, '.nii', '')];
        if strfind(files(i).name, '.nii')
            if ~exist([directory filesep run_name], 'dir') %make sure there are no directories called run_name
                mkdir(directory, run_name);
            end
            spm_file_split([directory filesep files(i).name], [directory filesep run_name]);
        end
    end

end

