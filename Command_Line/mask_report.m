function mask_report()
% mask_report.m
% Standalone script — reads mask_stats.mat and generates:
%   mask_report.csv  (SPSS importable)
%   mask_report.txt  (human readable)
%
% Usage:
%   cd to the directory containing mask_stats.mat
%   run mask_report
%
% No legacy code is touched or modified.
% ── Load config ───────────────────────────────────────────
config_file = 'configs.m';
try
    run(config_file);
    fprintf('Configuration loaded from: %s\n', config_file);
catch ME
    error('Error loading configuration file: %s\n%s', config_file, ME.message);
end
% ── Load data ────────────────────────────────────────────────────────────────
output_dir = config.outputDIR;

mat_file = fullfile(output_dir, 'mask_stats.mat');
if ~exist(mat_file, 'file')
    error('mask_stats.mat not found in outputDIR: %s', output_dir);
end

load(mat_file, 'adjustments', 'flag_threshold', 'mask_id', 'max_mask');

% ── Column mapping from adjustments matrix ───────────────────────────────────
% Col 1  = SubjectNo
% Col 2  = RunNo
% Col 3  = Total voxels in volume
% Col 4  = This subject/run mask size
% Col 5  = Removed from reference mask
% Col 6  = Removed from self
% Col 7  = Step reduction (removed from running final mask)
% Col 8  = Running final mask size after this subject/run
% Col 9  = RSA (Right Superior Anterior) removed
% Col 10 = LSA (Left Superior Anterior) removed
% Col 11 = RSP (Right Superior Posterior) removed
% Col 12 = LSP (Left Superior Posterior) removed
% Col 13 = RIA (Right Inferior Anterior) removed
% Col 14 = LIA (Left Inferior Anterior) removed
% Col 15 = RIP (Right Inferior Posterior) removed
% Col 16 = LIP (Left Inferior Posterior) removed
% Col 17 = Cumulative mask size check

n = size(adjustments, 1);

% ── Identify reference mask ──────────────────────────────────────────────────
% Stage 1 saves max_mask = [SubjectNo RunNo] of the reference (largest) mask.
% Prefer it over deriving the reference from adjustments(:,5)==0, which fails
% when column 5 is never exactly zero. Fallback: largest individual mask,
% which is the definition of the reference anyway.
ref_idx = [];
if exist('max_mask', 'var') && ~isempty(max_mask) && numel(max_mask) >= 2
    ref_idx = find(adjustments(:,1) == max_mask(1) & ...
                   adjustments(:,2) == max_mask(2), 1);
end
if isempty(ref_idx)
    [~, ref_idx] = max(adjustments(:, 4));
end
ref_size = adjustments(ref_idx, 4);   % reference mask size (max)

% ── Compute per-row values ────────────────────────────────────────────────────
subject_no        = adjustments(:, 1);
run_no            = adjustments(:, 2);
mask_size         = adjustments(:, 4);   % this subject/run mask size
step_reduction    = adjustments(:, 7);   % voxels removed at each accumulation step
final_mask_size   = adjustments(:, 8);   % running final mask size

% Step reduction % = step_reduction / previous final mask size * 100
% Previous final mask size: reference size for first row, fmsk.x of previous row otherwise
prev_size = [ref_size; final_mask_size(1:end-1)];
step_pct  = step_reduction ./ prev_size * 100;

% Cumulative reduction = ref_size - current final mask size
cumul_reduction = ref_size - final_mask_size;
cumul_pct       = cumul_reduction ./ ref_size * 100;

% Subject/run label
labels = cell(n, 1);
for i = 1:n
    labels{i} = sprintf('S%d_R%d', subject_no(i), run_no(i));
end

% ── Column totals ─────────────────────────────────────────────────────────────
total_step_reduction  = sum(step_reduction);
total_step_pct        = total_step_reduction / ref_size * 100;
final_cumul_reduction = cumul_reduction(end);
final_cumul_pct       = cumul_pct(end);

% ── Print human readable table ───────────────────────────────────────────────
fprintf('\n');
fprintf('%-12s  %18s  %20s  %14s  %22s  %16s\n', ...
    'Subject_Run', 'Mask_Size (voxels)', ...
    'Step_Reduction (voxels)', 'Step_Reduction%', ...
    'Cumul_Reduction (voxels)', 'Cumul_Reduction%');
fprintf('%s\n', repmat('-', 1, 110));

% Reference row
fprintf('%-12s  %18d  %20s  %14s  %22d  %15.2f%%\n', ...
    labels{ref_idx}, ref_size, '—', '—', 0, 0.00);

for i = 1:n
    if i == ref_idx
        continue  % already printed reference row
    end
    fprintf('%-12s  %18d  %20d  %13.2f%%  %22d  %15.2f%%\n', ...
        labels{i}, mask_size(i), step_reduction(i), step_pct(i), ...
        cumul_reduction(i), cumul_pct(i));
end

fprintf('%s\n', repmat('-', 1, 110));
fprintf('%-12s  %18s  %20d  %13.2f%%  %22d  %15.2f%%\n', ...
    'TOTAL', '—', total_step_reduction, total_step_pct, ...
    final_cumul_reduction, final_cumul_pct);
fprintf('\n');
fprintf('Reference mask : %s (largest individual mask, %d voxels)\n', ...
    labels{ref_idx}, ref_size);
fprintf('Flag threshold : %.1f%%\n', flag_threshold);

% ── Write CSV (SPSS importable) ───────────────────────────────────────────────
csv_file = fullfile(output_dir, 'mask_report.csv');
fid = fopen(csv_file, 'w');
if fid == -1
    error('Could not open %s for writing', csv_file);
end

% Header
fprintf(fid, 'Subject_Run,Mask_Size_voxels,Step_Reduction_voxels,Step_Reduction_pct,Cumul_Reduction_voxels,Cumul_Reduction_pct\n');

% Reference row
fprintf(fid, '%s,%d,0,0.00,0,0.00\n', labels{ref_idx}, ref_size);

% Data rows
for i = 1:n
    if i == ref_idx
        continue
    end
    fprintf(fid, '%s,%d,%d,%.2f,%d,%.2f\n', ...
        labels{i}, mask_size(i), step_reduction(i), step_pct(i), ...
        cumul_reduction(i), cumul_pct(i));
end

% Total row
fprintf(fid, 'TOTAL,,%d,%.2f,%d,%.2f\n', ...
    total_step_reduction, total_step_pct, ...
    final_cumul_reduction, final_cumul_pct);

fclose(fid);
fprintf('CSV saved to: %s\n', csv_file);

% ── Write TXT ────────────────────────────────────────────────────────────────
txt_file = fullfile(output_dir, 'mask_report.txt');
fid = fopen(txt_file, 'w');
if fid == -1
    error('Could not open %s for writing', txt_file);
end

fprintf(fid, 'CPCA Mask Reduction Report\n');
fprintf(fid, 'Generated: %s\n\n', datestr(now));
fprintf(fid, '%-12s  %18s  %20s  %14s  %22s  %16s\n', ...
    'Subject_Run', 'Mask_Size (voxels)', ...
    'Step_Reduction (voxels)', 'Step_Reduction%', ...
    'Cumul_Reduction (voxels)', 'Cumul_Reduction%');
fprintf(fid, '%s\n', repmat('-', 1, 110));

fprintf(fid, '%-12s  %18d  %20s  %14s  %22d  %15.2f%%\n', ...
    labels{ref_idx}, ref_size, '—', '—', 0, 0.00);

for i = 1:n
    if i == ref_idx
        continue
    end
    fprintf(fid, '%-12s  %18d  %20d  %13.2f%%  %22d  %15.2f%%\n', ...
        labels{i}, mask_size(i), step_reduction(i), step_pct(i), ...
        cumul_reduction(i), cumul_pct(i));
end

fprintf(fid, '%s\n', repmat('-', 1, 110));
fprintf(fid, '%-12s  %18s  %20d  %13.2f%%  %22d  %15.2f%%\n', ...
    'TOTAL', '—', total_step_reduction, total_step_pct, ...
    final_cumul_reduction, final_cumul_pct);
fprintf(fid, '\nReference mask : %s (largest individual mask, %d voxels)\n', ...
    labels{ref_idx}, ref_size);
fprintf(fid, 'Flag threshold : %.1f%%\n', flag_threshold);

fclose(fid);
fprintf('TXT saved to: %s\n\n', txt_file);

end

