% Script to  go from MNI coordinates to atlas labels

% Steps:
% For each line in atlases.txt:
%       - use load_nii to get the atlas nii
%       - use readtable to get the atlas labels
%       - save the centerpoint of each nii using status.viewpoint (or find
%       another way) --> Other way: nii.hdr.hist.originator[1:3]
%       - for each atlas, save the offset for the table (0 or 1)
% For each line in coordinates.txt:
%   - print the coordinate to file
%   For each atlas:
%       - convert MNI to X,Y,Z by adding centerpoint to MNI coordinate
%       - use nii.img(x,y,z) to get the label number
%       - get the label using table2array(table(labelnumber+offset,:))(2)
%       - print atlasname:label to file

function mni_to_labels(peaks, folder, comp_no_posneg, sort_order )

% % Load the .nii files for each of the
mypath = which('cpca');
mypath = strrep(mypath,'cpca.m',['External',filesep,'atlases',filesep]);

% mypath = [fileparts(mfilename('fullpath')) filesep 'atlases' filesep];

atlasfile = [mypath 'atlases' '.txt'];
atlases = readtable(atlasfile);
nii_list = [];
for i = 1:height(atlases)
    f = [mypath filesep char(atlases{i,2})];
    if exist([f,'.nii.gz'], 'file') == 2
        nii = load_nii([f,'.nii.gz']);
    elseif exist([f,'.nii'], 'file') == 2
        nii = load_nii([f,'.nii']);
    else
        fprintf([f '.nii and ' f '.nii.gz do not exist']);
        return;
    end
    nii.offset = nii.hdr.hist.originator(1:3);
    if exist([f,'.txt'], 'file') == 2
        nii.has_txt = 1;
        nii.table = readtable([f,'.txt']);
    elseif exist([f,'.nii.txt'], 'file') == 2
        nii.has_txt = 1;
        nii.table = readtable([f,'.nii.txt']);
    else
        nii.has_txt = 0;
        nii.table = NaN;
    end
    nii_list = [nii_list, nii];
end

c = peaks;

% wood_path = [mypath 'woodward' filesep];
% wood_atlas = readtable([wood_path 'woodward.txt']);
% [~,wood_sheets] = xlsfinfo([wood_path 'coordinates.xlsx']);
% for i = 1:numel(wood_sheets)
%     a = xlsread([wood_path 'coordinates.xlsx'], wood_sheets{i});
%     b = a(1:end-1,1:end);
%     wood_coords{i} = b(:,2:end-2);
%     wood_weights{i} = b(:,end);
%     wood_labels{i} = char(wood_atlas{i,2});
% end


% sort the c, peaks and wood_coords here, and throw the same sorting to
if ~(sort_order == 1)
    c = sortrows(c,sort_order-1);
    peaks = sortrows(peaks,sort_order-1);
%     for i = 1:size(wood_coords,2)
%        [wood_coords{i}, inds] = sortrows(wood_coords{i},sort_order-1);
%        wood_weights{i} = wood_weights{i}(inds,:);
%     end
end


mid_cols = 0; % size(wood_labels,2);

% var_names = cellstr(char('Coordinate', 'x', 'y', 'z', 'Loading', char(wood_labels), char(atlases{:,1})));
% var_names = [var_names(1:mid_cols+5,:); {'Havard_Oxford'}; var_names(mid_cols+8:mid_cols+9,:);var_names(mid_cols+11:end,:)];
% var_names = cellfun(@(var) strrep(var, ' ', '_'), var_names, 'UniformOutput', false);
% var_names = cellfun(@(var) strrep(var, '-', '_'), var_names, 'UniformOutput', false);

var_names = cellstr(char('Coordinate', 'x', 'y', 'z', 'Loading', char(atlases{:,1})));
var_names = [var_names(1:mid_cols+5,:); {'Havard_Oxford'}; var_names(mid_cols+8:mid_cols+9,:);var_names(mid_cols+11:end,:)];
var_names = cellfun(@(var) strrep(var, ' ', '_'), var_names, 'UniformOutput', false);
var_names = cellfun(@(var) strrep(var, '-', '_'), var_names, 'UniformOutput', false);

label_table = cell2table(cell(size(peaks,1), mid_cols+9), 'VariableNames',var_names);

for j = 1:size(c,1)
    label_table{j,1} = {['(' num2str(c(j,1)) ', ' num2str(c(j,2)) ', ' num2str(c(j,3)) ')']};
    label_table{j,2} = {num2str(c(j,1))};
    label_table{j,3} = {num2str(c(j,2))};
    label_table{j,4} = {num2str(c(j,3))};
    label_table{j,5} = {num2str(c(j,4))};

    ho = 0;
    ba = 0;
    for k = 1:length(nii_list)
        nii = nii_list(k);
        new = c(j,1:3)+nii.offset;
        val = nii.img(new(1),new(2),new(3));

        if (k == 2 && ho == 1) || (k == 5 && ba == 1)
            continue
        else
            if k == 1 || k == 2
                idx = mid_cols+6;
            elseif k == 3
                idx = mid_cols+7;
            elseif k == 4 || k == 5
                idx = mid_cols+8;
            elseif k == 6
                idx = mid_cols+9;
            end

            if val > 0
                if k == 1
                    ho = 1;
                elseif k == 4
                    ba = 1;
                end

                if nii.has_txt
                    label = nii.table(val,:);
                    if k == 6
                        label_table{j,idx} = {['\t' char(label.(2)) ' (' num2str(val) ')']};
                    else
                        label_table{j,idx} = {['\t' char(label.(2))]};
                    end
                else
                    if k == 5
                        label_table{j,idx} = {['\tRegion ' num2str(val)]};
                    else
                        label_table{j,idx} = {['\t' num2str(val)]};
                    end
                end
            else
                if (k == 2 && ho == 0) || (k == 5 && ba == 0) || (k ~= 1 && k ~= 4)
                    label_table{j,idx} = {'\tNo Match'};
                end
            end
        end
    end
end

% label_table = woodward_label_coord(label_table, c, wood_coords);

if ~exist(fullfile(folder,'Labels'),'dir')
   mkdir(fullfile(folder,'Labels'));
end

str = [folder filesep 'Labels' filesep 'MNI_C' comp_no_posneg '_peaks_labelled.txt'];
f = fopen(str,'w');

fprintf(f, 'Distances from the component to each exemplar\n\n');

for k = 1:size(var_names,1)
    if k == 1
        area = var_names{k,1};
        fprintf(f, area);
    else
        area = var_names{k,1};
        fprintf(f, ['\t' area]);
    end
end

fprintf(f,'\n');

for i=1:height(label_table)
   for j=1:width(label_table)
       if j == 1 || j > mid_cols+5
           fprintf(f, char(label_table{i,j}));
       else
           fprintf(f, ['\t' char(label_table{i,j})]);
       end
   end
   fprintf(f, '\n');
end

% for each component, get the woodward label; NOT per coordinate for this one!!
% for starters, just stick it on to the end of the file

% woodward_label(f, c, wood_coords, wood_weights, wood_labels);

% fprintf(f,'\n\n');

% print distances from each of the networks' coordinates to the nearest component coordinate
% exemplar_to_component(f, c(:,1:3), wood_labels, wood_coords);

fclose(f);
end
