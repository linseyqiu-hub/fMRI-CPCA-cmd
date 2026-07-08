function config = generate_config(config, files_txt_path)
% generate_config - Auto-derive subject/run/condition fields from disk + onsets file
%
% Usage:
%   config = generate_config(config, files_txt_path)
%
% Called in stage1 AFTER Create_File_List and AFTER validate_config.
% Enriches the manually-filled config struct with fields that can be
% deterministically derived from the folder structure and timing onsets file.
%
% Inputs:
%   config         - partially filled config struct (manual fields already set)
%   files_txt_path - full path to files.txt produced by Create_File_List
%
% Outputs:
%   config - same struct enriched with:
%              config.num_subjects
%              config.num_runs
%              config.num_conditions
%              config.condition_names
%              config.subject_conditions
%
% Also appends the auto-derived fields back to configs.m in the current
% working directory so that stage2 onwards can reuse them via run(configs.m).
%
% --------------------------------------------------------------------------
% ASSUMPTIONS (document any changes here if data format changes)
% --------------------------------------------------------------------------
%
% files.txt assumptions:
%   A1. Every scandir: line contains both sdir: and runs: tokens.
%   A2. runs: is either tilde-delimited (e.g. runs:run-1~run-2, even for a
%       single named run folder, e.g. runs:run-1), OR the literal value
%       runs:<na>, meaning the subject has NO run subfolder at all (scan
%       files sit directly in the subject directory). Both are valid and
%       supported.
%   A3. Subjects appear in files.txt in the same order as they appear
%       on disk (insertion order from Create_File_List).
%
% Timing onsets file assumptions:
%   A4. The onsets file is always named 'timing_onsets.txt' and lives
%       in config.baseDIR.
%   A5. Variable assignment lines have the form:
%           varname=[ values ];   or   varname=[ values];
%       The '=' character is the reliable delimiter between the
%       prefix+condition portion and the numeric values.
%   A6. Lines starting with '%' are comments and are skipped.
%   A7. Blank lines are skipped.
%   A8. Variable names contain no spaces.
%   A9. The onsets file is ordered: subjects appear in the same order
%       as files.txt. All variable lines for one subject-run block are
%       grouped together before the next subject-run block begins.
%       (If this ever breaks, swap to brute-force prefix search — the
%        output is identical, only the algorithm changes.)
%
% Prefix and condition name assumptions:
%   A10. For a subject with >1 run folder, the variable name prefix is:
%            <sdir>_<run_folder_name>
%        e.g. sub-01_run-1
%        (exact match only — no fallback, since with multiple run
%        folders the run name is required to disambiguate).
%   A11. For a subject with exactly ONE run folder (runs:run-1, a real
%        folder exists on disk), BOTH of the following are accepted as
%        valid prefixes:
%            <sdir>                    (e.g. PreSingle_VISION_V01)
%            <sdir>_<run_folder_name>  (e.g. PreSingle_VISION_V01_run-1)
%        The condition name is everything after the matched prefix + '_'.
%   A11b. For a subject with NO run subfolder at all (runs:<na>), there is
%        no run folder name to optionally include, so there is exactly ONE
%        valid prefix:
%            <sdir>
%        This subject is treated as having a single virtual run (run_idx=1)
%        with no folder name. Underscore-delimited, same as A11 — no new
%        delimiter convention.
%   A12. Condition name = the substring after stripping prefix + '_'
%        from the left-hand side of '=' in the variable assignment line.
%   A13. Condition names are collected in order of first appearance in
%        the onsets file. This order determines their indices in
%        config.condition_names.
%
% Error policy:
%   A14. If zero onsets lines are found for a known subject-run prefix,
%        an error is thrown — the onsets file is missing timing data for
%        a subject-run that exists on disk.
%   A15. Variable names that match no known prefix are logged as warnings
%        (unexpected entries in the onsets file) but do not halt execution.
% --------------------------------------------------------------------------

fprintf('\n-- generate_config: deriving subject/run/condition fields --\n');

% ── Step 1: parse files.txt ───────────────────────────────────────────────
% Extract ordered list of subjects and their run folder names.
% runs_list{s} is a cell array of run folder names for subject s, OR an
% empty cell {} if the subject has no run subfolder (runs:<na>, A2/A11b).

if ~exist(files_txt_path, 'file')
    error('generate_config: files.txt not found at: %s', files_txt_path);
end

fid = fopen(files_txt_path, 'r');
if fid == -1
    error('generate_config: could not open files.txt at: %s', files_txt_path);
end

raw_lines = {};
while ~feof(fid)
    line = fgetl(fid);
    if ischar(line)
        raw_lines{end+1} = strtrim(line);
    end
end
fclose(fid);

% Parse scandir lines → (sdir, runs[])
subjects  = {};   % ordered cell array of sdir strings
runs_list = {};   % cell array of run name cell arrays, one per subject
                  % (empty cell {} means "no run subfolder", A11b)

for i = 1:numel(raw_lines)
    line = raw_lines{i};
    if ~strncmp(line, 'scandir:', 8)
        continue;
    end

    % Extract sdir:
    sdir_tok = regexp(line, 'sdir:(\S+)', 'tokens', 'once');
    if isempty(sdir_tok)
        error('generate_config: malformed scandir line (no sdir:): %s', line);
    end
    sdir = sdir_tok{1};

    % Extract runs: (tilde-delimited, or <na>)
    runs_tok = regexp(line, 'runs:(\S+)', 'tokens', 'once');
    if isempty(runs_tok)
        error('generate_config: malformed scandir line (no runs:): %s', line);
    end
    runs_str = runs_tok{1};

    if strcmp(runs_str, '<na>')
        % A11b: subject has no run subfolder at all. Not an error —
        % treated as a single virtual run with no folder name.
        run_names = {};
    else
        run_names = strsplit(runs_str, '~');  % e.g. {'run-1','run-2',...}
    end

    subjects{end+1}  = sdir;
    runs_list{end+1} = run_names;
end

num_subjects = numel(subjects);
if num_subjects == 0
    error('generate_config: no scandir lines found in files.txt.');
end

% Compute max runs across all subjects. A subject with no run subfolder
% still counts as 1 run (the virtual run), so it can never drag num_runs
% below what any real subject has, and a study of only no-subfolder
% subjects still correctly reports num_runs = 1.
num_runs = 0;
for s = 1:num_subjects
    num_runs = max(num_runs, max(numel(runs_list{s}), 1));
end

fprintf('   Parsed files.txt: %d subjects, max %d runs.\n', num_subjects, num_runs);

% ── Step 2: build ordered prefix list ────────────────────────────────────
% Each entry: struct with fields subject_idx, run_idx, prefix, sdir, run_name
%
% Two independent, single-responsibility builders — no shared branching:
%   - build_prefix_entry_no_subfolder:     subject has NO run subfolder (A11b)
%   - build_prefix_entries_with_subfolder: subject has >=1 run subfolder (A10/A11)
% Subjects are routed to exactly one builder based on files.txt content
% (isempty(run_names)), decided once in Step 1 — never re-decided here.
% Looping s = 1:num_subjects preserves original files.txt order (A9),
% so no separate re-sort/merge step is needed.

prefix_list = struct('subject_idx', {}, 'run_idx', {}, ...
                     'sdir', {}, 'run_name', {}, 'prefix', {}, 'alt_prefix', {});

for s = 1:num_subjects
    sdir      = subjects{s};
    run_names = runs_list{s};

    if isempty(run_names)
        % A11b: no run subfolder — one virtual run, one valid prefix.
        entry = build_prefix_entry_no_subfolder(s, sdir);
        prefix_list(end+1) = entry;
    else
        % A10/A11: one or more real run subfolders.
        entries = build_prefix_entries_with_subfolder(s, sdir, run_names);
        for k = 1:numel(entries)
            prefix_list(end+1) = entries(k);
        end
    end
end

% ── Step 3: parse onsets file ─────────────────────────────────────────────
% Sequential pointer over prefix_list (A9).
% For each prefix, collect all variable lines whose LHS matches the prefix.
% Extract condition name = LHS after stripping prefix + '_'.

onsets_file = fullfile(config.baseDIR, 'timing_onsets.txt');
if ~exist(onsets_file, 'file')
    error('generate_config: timing_onsets.txt not found in baseDIR: %s', config.baseDIR);
end

fid = fopen(onsets_file, 'r');
if fid == -1
    error('generate_config: could not open timing_onsets.txt');
end

onset_lines = {};
while ~feof(fid)
    line = fgetl(fid);
    if ~ischar(line), continue; end
    line = strtrim(line);
    if isempty(line) || line(1) == '%', continue; end   % A6, A7
    if isempty(strfind(line, '=')),     continue; end   % must be assignment line
    onset_lines{end+1} = line;
end
fclose(fid);

% Walk onset_lines with sequential pointer over prefix_list
% tuples: cell array of {subject_idx, run_idx, condition_name}
tuples        = {};
condition_names = {};   % ordered unique list (A13)
ptr           = 1;      % pointer into prefix_list
n_prefixes    = numel(prefix_list);
matched_counts = zeros(1, n_prefixes);  % how many lines matched each prefix

for li = 1:numel(onset_lines)
    line = onset_lines{li};

    % LHS = everything before '='
    eq_pos = find(line == '=', 1);
    lhs    = strtrim(line(1:eq_pos-1));

    % Try to match against current prefix (and advance if needed)
    matched = false;
    while ptr <= n_prefixes && ~matched
        p        = prefix_list(ptr);
        cond_name = try_extract_condition(lhs, p.prefix, p.alt_prefix);

        if ~isempty(cond_name)
            % Record tuple
            tuples{end+1} = {p.subject_idx, p.run_idx, cond_name};
            matched_counts(ptr) = matched_counts(ptr) + 1;

            % Add to condition_names if first appearance (A13)
            if ~any(strcmp(condition_names, cond_name))
                condition_names{end+1} = cond_name;
            end
            matched = true;

        else
            % Current line doesn't match current prefix.
            % Check if it matches the NEXT prefix — if so, advance pointer.
            % (Current prefix block is exhausted.)
            if ptr < n_prefixes
                next_p     = prefix_list(ptr+1);
                next_cond  = try_extract_condition(lhs, next_p.prefix, next_p.alt_prefix);
                if ~isempty(next_cond)
                    % Validate: current prefix must have had at least one match (A14)
                    if matched_counts(ptr) == 0
                        error(['generate_config: no onsets found for subject "%s" run "%s" ' ...
                               '(prefix: "%s"). Check timing_onsets.txt.'], ...
                               p.sdir, p.run_name, p.prefix);
                    end
                    ptr = ptr + 1;
                    % Don't consume the line yet — re-evaluate at top of while loop
                else
                    % Doesn't match current or next — warn and skip (A15)
                    fprintf('   WARNING: unrecognized variable in onsets file (no prefix match): %s\n', lhs);
                    matched = true;  % break inner while, move to next line
                end
            else
                % No more prefixes — warn and skip (A15)
                fprintf('   WARNING: unrecognized variable in onsets file (no prefix match): %s\n', lhs);
                matched = true;
            end
        end
    end
end

% Final check: last prefix must have had at least one match (A14)
if ptr <= n_prefixes && matched_counts(ptr) == 0
    p = prefix_list(ptr);
    error(['generate_config: no onsets found for subject "%s" run "%s" ' ...
           '(prefix: "%s"). Check timing_onsets.txt.'], ...
           p.sdir, p.run_name, p.prefix);
end

% Also validate any remaining unvisited prefixes
for k = ptr+1:n_prefixes
    if matched_counts(k) == 0
        p = prefix_list(k);
        error(['generate_config: no onsets found for subject "%s" run "%s" ' ...
               '(prefix: "%s"). Check timing_onsets.txt.'], ...
               p.sdir, p.run_name, p.prefix);
    end
end

fprintf('   Parsed onsets file: %d unique conditions found.\n', numel(condition_names));

% ── Step 4: derive subject_conditions ────────────────────────────────────
% For each subject, for each run: find which conditions appeared,
% map to indices in condition_names.
% A subject with no run subfolder (A11b) gets exactly one slot, matching
% the single virtual run assigned to it in Step 2.

subject_conditions = cell(1, num_subjects);
for s = 1:num_subjects
    n_slots = max(numel(runs_list{s}), 1);
    subject_conditions{s} = cell(1, n_slots);
    for r = 1:n_slots
        subject_conditions{s}{r} = [];
    end
end

for t = 1:numel(tuples)
    s         = tuples{t}{1};
    r         = tuples{t}{2};
    cond_name = tuples{t}{3};
    cond_idx  = find(strcmp(condition_names, cond_name), 1);
    subject_conditions{s}{r}(end+1) = cond_idx;
end

num_conditions = numel(condition_names);

% ── Step 5: enrich config struct ─────────────────────────────────────────
config.num_subjects       = num_subjects;
config.num_runs           = num_runs;
config.num_conditions     = num_conditions;
config.condition_names    = condition_names;
config.subject_conditions = subject_conditions;

fprintf('   Config enriched: %d subjects, %d runs, %d conditions.\n', ...
        num_subjects, num_runs, num_conditions);

% ── Step 6: write auto-derived fields back to configs.m ──────────────────
% So that stage2 onwards can just run(configs.m) without re-running generate_config.

append_config_to_file(config, num_subjects, num_runs, num_conditions, ...
                      condition_names, subject_conditions, subjects, runs_list);

fprintf('-- generate_config: done --\n\n');
end


% ── Helper: build prefix_list entry for a subject with NO run subfolder ───
% A11b. Exactly one virtual run, exactly one valid prefix (bare sdir).
% No fallback needed — there is no run folder name to optionally include.
function entry = build_prefix_entry_no_subfolder(subject_idx, sdir)
    entry.subject_idx = subject_idx;
    entry.run_idx     = 1;
    entry.sdir        = sdir;
    entry.run_name    = '';
    entry.prefix      = sdir;
    entry.alt_prefix  = '';
end


% ── Helper: build prefix_list entries for a subject with >=1 run subfolder ─
% A10 (multi-run: exact match only) / A11 (single run: prefix + bare-sdir fallback).
function entries = build_prefix_entries_with_subfolder(subject_idx, sdir, run_names)
    is_single = numel(run_names) == 1;
    entries = struct('subject_idx', {}, 'run_idx', {}, ...
                     'sdir', {}, 'run_name', {}, 'prefix', {}, 'alt_prefix', {});

    for r = 1:numel(run_names)
        run_name = run_names{r};
        entry.subject_idx = subject_idx;
        entry.run_idx     = r;
        entry.sdir        = sdir;
        entry.run_name    = run_name;
        entry.prefix      = [sdir '_' run_name];

        if is_single
            entry.alt_prefix = sdir;   % A11 fallback
        else
            entry.alt_prefix = '';     % A10: no fallback with multiple runs
        end

        entries(end+1) = entry;
    end
end


% ── Helper: try to extract condition name from LHS given a prefix ─────────
function cond_name = try_extract_condition(lhs, prefix, alt_prefix)
    cond_name = '';
    expected  = [prefix '_'];
    if strncmp(lhs, expected, numel(expected))
        cond_name = lhs(numel(expected)+1:end);
        return;
    end
    if ~isempty(alt_prefix)
        expected2 = [alt_prefix '_'];
        if strncmp(lhs, expected2, numel(expected2))
            cond_name = lhs(numel(expected2)+1:end);
            return;
        end
    end
end


% ── Helper: write auto-derived fields to configs.m ───────────────────────
% Strips any existing auto-generated block first, then appends a fresh one.
% Safe to call on every stage1 run including reruns.
function append_config_to_file(config, num_subjects, num_runs, num_conditions, ...
                                condition_names, subject_conditions, subjects, runs_list)

    BLOCK_START = '%% ── Auto-generated by generate_config (do not edit manually) ──';
    BLOCK_END   = '%% ── End auto-generated ──';

    configs_path = fullfile(config.cpcaDIR, 'Command_Line', 'configs.m');
    if ~exist(configs_path, 'file')
        error('generate_config: configs.m not found in working directory: %s', pwd);
    end

    % ── Step A: read existing configs.m ──────────────────────────────────
    fid = fopen(configs_path, 'r');
    if fid == -1
        error('generate_config: could not open configs.m for reading.');
    end
    existing_lines = {};
    while ~feof(fid)
        line = fgetl(fid);
        if ischar(line)
            existing_lines{end+1} = line;
        end
    end
    fclose(fid);

    % ── Step B: strip existing auto-generated block if present ───────────
    start_idx = -1;
    end_idx   = -1;
    for i = 1:numel(existing_lines)
        if strcmp(strtrim(existing_lines{i}), BLOCK_START)
            start_idx = i;
        end
        if strcmp(strtrim(existing_lines{i}), BLOCK_END)
            end_idx = i;
        end
    end

    if start_idx ~= -1 && end_idx ~= -1 && end_idx >= start_idx
        % Remove block and any blank line immediately before it
        remove_from = start_idx;
        if start_idx > 1 && strtrim(existing_lines{start_idx - 1}) == ""
            remove_from = start_idx - 1;
        end
        existing_lines = [existing_lines(1:remove_from-1), existing_lines(end_idx+1:end)];
        fprintf('   Removed existing auto-generated block from configs.m.\n');
    elseif start_idx ~= -1 || end_idx ~= -1
        % Partial block — something is malformed, warn but proceed
        fprintf('   WARNING: partial auto-generated block found in configs.m — overwriting anyway.\n');
        % Remove from start_idx to end of file as a safe fallback
        cut = max(start_idx, 1);
        existing_lines = existing_lines(1:cut-1);
    end

    % ── Step C: write cleaned manual content back ────────────────────────
    fid = fopen(configs_path, 'w');
    if fid == -1
        error('generate_config: could not open configs.m for writing.');
    end
    for i = 1:numel(existing_lines)
        fprintf(fid, '%s\n', existing_lines{i});
    end

    % ── Step D: append fresh auto-generated block ─────────────────────────
    fprintf(fid, '\n');
    fprintf(fid, '%s\n', BLOCK_START);
    fprintf(fid, 'config.num_subjects   = %d;\n', num_subjects);
    fprintf(fid, 'config.num_runs       = %d;\n', num_runs);
    fprintf(fid, 'config.num_conditions = %d;\n', num_conditions);

    % condition_names cell array
    fprintf(fid, 'config.condition_names = { ...\n');
    for i = 1:numel(condition_names)
        if i < numel(condition_names)
            fprintf(fid, "    '%s', ...\n", condition_names{i});
        else
            fprintf(fid, "    '%s'  ...\n", condition_names{i});
        end
    end
    fprintf(fid, '};\n');

    % subject_conditions
    for s = 1:num_subjects
        run_names = runs_list{s};
        if isempty(run_names)
            run_label = '(no run subfolder)';   % A11b: cosmetic label only
        else
            run_label = strjoin(run_names, ', ');
        end
        fprintf(fid, 'config.subject_conditions{%d} = { ', s);
        for r = 1:numel(subject_conditions{s})
            indices = subject_conditions{s}{r};
            idx_str = num2str(indices);
            if r < numel(subject_conditions{s})
                fprintf(fid, '[%s], ', idx_str);
            else
                fprintf(fid, '[%s]', idx_str);
            end
        end
        fprintf(fid, ' };  %% %s: %s\n', subjects{s}, run_label);
    end

    fprintf(fid, '%s\n', BLOCK_END);
    fclose(fid);

    fprintf('   Auto-derived fields written to configs.m.\n');
end