function cleanup_stage2(base_dir)
   
    cd(base_dir)
    disp(base_dir);
    rmdir_if_exists(fullfile(base_dir, 'GZsegs'));
    
    % Singular values scree plot — created by RegressG
    delete_if_exists(fullfile(base_dir, 'Singular Values.png'));
    
    
end
function delete_if_exists(filepath)
    if exist(filepath, 'file')
        delete(filepath);
        fprintf('   Deleted: %s\n', filepath);
    end
end

function rmdir_if_exists(dirpath)
    if exist(dirpath, 'dir')
        try
            rmdir(dirpath, 's');
            fprintf('   Deleted folder: %s\n', dirpath);
        catch ME
            warning('Could not delete folder: %s\nReason: %s\nCheck if any files inside are open or locked.', dirpath, ME.message);
        end
    end
end


