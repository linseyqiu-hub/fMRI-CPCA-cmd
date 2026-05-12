function cleanup_stage3(base_dir)
    cd(base_dir)
    % component extraction outputs
    % fs_path builds paths under base_dir — common pattern is G/ folder
    rmdir_if_exists(fullfile(base_dir, 'G'));
    
    % log files added by Extract_Rotate_Components
    % log/ already exists from stage2 — only delete new entries
    % BUT we can't selectively delete log entries
    % so we leave log/ alone — stage2 already owns it
    
    % ZInfo.mat gets overwritten by save_headers_cmd — skip
end

function rmdir_if_exists(dirpath)
    if exist(dirpath, 'dir')
        rmdir(dirpath, 's');
        fprintf('   Deleted folder: %s\n', dirpath);
    end
end

