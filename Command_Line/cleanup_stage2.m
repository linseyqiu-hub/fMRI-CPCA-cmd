function cleanup_stage2(base_dir)
    % Z matrix and normalization outputs
    cd(base_dir)
    rmdir_if_exists(fullfile(base_dir, 'Z'));
    rmdir_if_exists(fullfile(base_dir, 'log'));
    
    % G matrix outputs
    rmdir_if_exists(fullfile(base_dir, 'Gsegs'));
    rmdir_if_exists(fullfile(base_dir, 'GZsegs'));
    rmdir_if_exists(fullfile(base_dir, 'Residual_G'));
    
    % G header and timing template
    delete_if_exists(fullfile(base_dir, 'Gheader.mat'));
    delete_if_exists(fullfile(base_dir, 'timing_onsets_template.txt'));
    delete_if_exists(fullfile(base_dir, 'timing_onsets_imported.txt'));
    
    % Singular values scree plot — created by RegressG
    delete_if_exists(fullfile(base_dir, 'Singular Values.png'));
    
    % mask_used — created by process_subject_normalization_cmd
    delete_if_exists(fullfile(base_dir, 'mask_used.img'));
    delete_if_exists(fullfile(base_dir, 'mask_used.hdr'));
    delete_if_exists(fullfile(base_dir, 'mask_used.nii'));
end
function delete_if_exists(filepath)
    if exist(filepath, 'file')
        delete(filepath);
        fprintf('   Deleted: %s\n', filepath);
    end
end

function rmdir_if_exists(dirpath)
    if exist(dirpath, 'dir')
        rmdir(dirpath, 's');
        fprintf('   Deleted folder: %s\n', dirpath);
    end
end

