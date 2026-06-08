function singular_values_report()
% singular_values_report - Generate a text report of singular values
%
% Usage: >> singular_values_report
%
% Reads existing pipeline output from disk and writes:
%   singular_values_report.txt  →  outputDIR

original_dir = pwd;

% ── Load state ────────────────────────────────────────────
STATE_FILE = fullfile(pwd, 'pipeline_state.mat');
if ~exist(STATE_FILE, 'file')
    fprintf('\nNo pipeline state found. Run >> stage1 first.\n\n');
    return;
end
state = load_state(STATE_FILE);

% ── Load config ───────────────────────────────────────────
config_file = 'configs.m';
try
    run(config_file);
catch ME
    error('Error loading configuration file: %s\n%s', config_file, ME.message);
end

% ── Prerequisite check ────────────────────────────────────
if ~strcmp(state.status.stage2, 'done')
    fprintf('\nStage 2 must be completed before running singular_values_report.\n');
    fprintf('Current status: stage2 = %s\n\n', state.status.stage2);
    return;
end

% ── Resolve paths ─────────────────────────────────────────
addpath(genpath(config.cpcaDIR));

if isfield(config, 'outputDIR') && ~isempty(config.outputDIR)
    outputDIR = config.outputDIR;
else
    outputDIR = config.baseDIR;
end

% ── Load Zheader and scan_information ─────────────────────
zinfo_path = fullfile(outputDIR, 'ZInfo.mat');
if ~exist(zinfo_path, 'file')
    error('ZInfo.mat not found in outputDIR: %s', outputDIR);
end
load(zinfo_path, 'Zheader', 'scan_information');

% ── Load Gheader ──────────────────────────────────────────
gheader_path = fullfile(outputDIR, 'Gheader.mat');
if ~exist(gheader_path, 'file')
    error('Gheader.mat not found in outputDIR: %s', outputDIR);
end
load(gheader_path, 'Gheader');

% ── Load eigenvalues ──────────────────────────────────────
model = 'G';
WG = isRegistered(scan_information.mask) * constant_define('PREFERENCES', 'general.gray_white_split');
eigvar = ['C' constant_define('REGISTRATION_TAG', WG) '_Eigenvalues'];

C_Eigenvalues = load_GC_var_cmd(Gheader, Zheader, eigvar, model);

if isempty(C_Eigenvalues)
    fprintf('No eigenvalues found. Ensure Stage 2 completed successfully.\n');
    return;
end

% ── Compute normalized eigenvalues ────────────────────────
ext = min(40, size(C_Eigenvalues, 1));
Ce = C_Eigenvalues(1:ext, :) ./ (Zheader.total_scans - 1);

% ── Write report ──────────────────────────────────────────
output_path = fullfile(outputDIR, 'singular_values_report.txt');
fid = fopen(output_path, 'w');
if fid == -1
    error('Could not write to: %s', output_path);
end

fprintf(fid, 'Singular Values Report\n');
fprintf(fid, 'Generated: %s\n', datestr(now));
fprintf(fid, 'Total scans: %d\n', Zheader.total_scans);
fprintf(fid, 'Values normalized by (total_scans - 1) = %d\n', Zheader.total_scans - 1);
fprintf(fid, '--------------------------------------\n');
fprintf(fid, '%-10s  %s\n', 'Component', 'Eigenvalue');
fprintf(fid, '--------------------------------------\n');

for i = 1:size(Ce, 1)
    fprintf(fid, '%-10d  %.6f\n', i, Ce(i, 1));
end

fprintf(fid, '--------------------------------------\n');
fclose(fid);

fprintf('Singular values report written to:\n  %s\n', output_path);
cd(original_dir);
end

