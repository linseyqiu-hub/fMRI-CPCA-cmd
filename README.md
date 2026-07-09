Then run `>> stage1` as normal. The block will be recreated from scratch.

---

## Rerunning Stages

### Rerunning Stage 1

Delete the auto-generated block from `configs.m` (see above), then run:

```matlab
>> stage1
```

Stage 1 always starts fresh and automatically resets the entire pipeline state, since stages 2–4 depend on its outputs.

### Rerunning Stage 2 or Stage 3

Simply rerun the stage directly — it will automatically delete its own newly created outputs before starting fresh.

```matlab
>> stage2
```
or
```matlab
>> stage3
```

> **Note:** Only files exclusively created by the stage are removed. Any files that were pre-existing and simply overwritten by the stage will not be deleted, as those belong to an earlier stage.

#### Files automatically cleaned by Stage 2
* `GZsegs/` (including nested `Betas/` subfolder)
* `Singular Values.png`
#### Files automatically cleaned by Stage 3
* `G/`
## Recovering From MATLAB Crashes

The staged pipeline uses a lock mechanism to detect incomplete runs.

If MATLAB crashes mid-stage and the stage remains locked, run:

```matlab
>> unlock
```

This utility will display which stages are currently locked and allow them to be reset before rerunning.

## Mask Report

After Stage 1 completes, you can generate a mask reduction report to inspect how the common mask shrinks as each subject-run mask is intersected:

```matlab
>> mask_report
```

`mask_report.m` is a standalone command that lives in the Command_Line. It reads `mask_stats.mat` from `config.outputDIR` and produces two output files in that directory:

* `mask_report.csv` — SPSS-importable table
* `mask_report.txt` — human-readable version
The report table has the following columns:

| Column | Description |
| --- | --- |
| Subject_Run | Subject/run label |
| Mask_Size | Number of valid voxels for this subject-run |
| Step_Reduction (voxels) | Voxels lost at this step of accumulation |
| Step_Reduction% | Percentage lost at this step |
| Cumul_Reduction (voxels) | Total voxels lost since the reference mask |
| Cumul_Reduction% | Total percentage lost since the reference mask |

Row and column totals are included.

## Merged Analysis

The pipeline supports analysing two datasets together (e.g. VISION + PAIN) by treating them as a single set of subjects with different run counts and condition structures. No code changes are required — only config and timing file preparation.

### How it works

* Subjects with fewer runs than `num_runs` simply have their missing run slots skipped automatically
* `subject_conditions` tells the pipeline exactly which conditions belong to each subject per run — VISION subjects list only their 4 conditions, PAIN subjects list only their pain conditions
* `Create_GMatrix` builds per-subject G blocks sized to that subject's actual encoded condition count
* `compile_CC_array_cmd` assembles CC with variable-width blocks per subject
The only hard requirement is that all scans across both datasets must be registered to the **same MNI voxel grid** (same dimensions, same voxel size) before running the pipeline. The mask accumulation step performs element-wise intersection — this is only valid if all mask vectors have identical length.

### Config setup for merged analysis

Fill in only the manual fields — the timing-derived fields are handled automatically by stage1. See the **configs.m Lifecycle** section above and the merged dataset example under **Example Configuration**.

### Timing onsets file

Prepare a single `timing_onsets.txt` in `config.baseDIR` containing entries for all subjects from both datasets. Variable names must follow one of these formats:

* Multi-run subjects: `<subject_folder>_<run_folder>_<condition_name>`
* Single-run subjects (with or without a run subfolder on disk): `<subject_folder>_<condition_name>` or `<subject_folder>_<run_folder>_<condition_name>`
where `subject_folder` and `run_folder` match the folder names on disk exactly. Subjects and their runs must appear in the same order as on disk. Only list entries for conditions that actually occurred in that run.

**Note:** a subject with no run subfolder on disk at all (single scan directory, no per-run subdirectory) is treated as a single-run subject with no `run_folder` component — only the `<subject_folder>_<condition_name>` form applies in that case.

## Configuration

Edit `configs.m` to set your manual parameters. See the **configs.m Lifecycle** section for what to fill in and what stage1 handles automatically.

### Basic Parameters

* `config.cpcaDIR` - Directory of fMRI-CPCA library
* `config.baseDIR` - Directory containing your data
* `config.outputDIR` - Directory where all pipeline output will be written. If empty or absent, output goes to `baseDIR` (legacy behaviour)
* `config.filewildcard` - Pattern to select scan files (e.g., `'swa*nii'`, `'fsn*img'`)
### Mask Parameters

* `config.maskName` - Name of the mask file (default: `'mask.img'`)
* `config.createMask` - Whether to create a new mask (1) or use existing (0)
* `config.maskMethod` - Mask creation method:
  * 1: Global mean threshold
  * 2: Harvard Oxford MNI coordinates
* `config.removeVentricles` - Whether to exclude ventricles from the mask (1) or include them (0). Default: `1` (exclude).
### Normalization Parameters

* `config.linearRegress` - Apply linear regression (1-On, 0-Off)
* `config.quadraticRegress` - Apply quadratic regression (1-On, 0-Off)
* `config.movementRegress` - Regress out movement parameters (1-On, 0-Off)
* `config.meanCenter` - Apply mean centering (1-On, 0-Off)
* `config.standardize` - Apply standardization (1-On, 0-Off)
### G-Matrix Parameters

* `config.bins` - Number of time bins
* `config.TR` - Timing rate
* `config.inScans` - Timing in Scans (1) or seconds (0)
* `config.normalize_G` - Normalize G matrix (1-Yes, 0-No)
### Component Extraction Parameters

Multiple solutions are supported. Each solution specifies an independent extraction:

```matlab
config.solutions(1).num_components = 2;
config.solutions(1).rotation_method = 'varimax';       % optional — omit or leave empty for varimax (default)
config.solutions(1).components_to_flip.unrotated = [1];
config.solutions(1).components_to_flip.rotated   = [1 2];

config.solutions(2).num_components = 3;
config.solutions(2).rotation_method = 'varimax';
config.solutions(2).components_to_flip.unrotated = [];
config.solutions(2).components_to_flip.rotated   = [2];

% hrfmax — path A: generate shapes from cognitive events
config.solutions(3).num_components    = 2;
config.solutions(3).rotation_method   = 'hrfmax';
config.solutions(3).hrfmax_iterations = 500000;        % optional — default 500000
config.solutions(3).hrfmax_events(1).onset       = 0;       % ms
config.solutions(3).hrfmax_events(1).duration    = 500;     % ms
config.solutions(3).hrfmax_events(1).description = 'visual onset';    % optional label
config.solutions(3).hrfmax_events(2).onset       = 500;
config.solutions(3).hrfmax_events(2).duration    = 1000;
config.solutions(3).hrfmax_events(2).description = 'visual display';
config.solutions(3).hrfmax_events(3).onset       = 1500;
config.solutions(3).hrfmax_events(3).duration    = 1000;
config.solutions(3).hrfmax_events(3).description = 'response process';
% omit event 4 to exclude evaluation process
config.solutions(3).components_to_flip.unrotated = [];
config.solutions(3).components_to_flip.rotated   = [];

% hrfmax — path B: use pre-built shapes file
config.solutions(4).num_components       = 2;
config.solutions(4).rotation_method      = 'hrfmax';
config.solutions(4).hrfmax_iterations    = 5000000;     % optional — default 5000000
config.solutions(4).hrfmax_shapes_path   = '/path/to/shapes.mat';
config.solutions(4).hrfmax_shapes_var    = 'shapes';
config.solutions(4).components_to_flip.unrotated = [];
config.solutions(4).components_to_flip.rotated   = [];
```

Rules:
* `rotation_method` is optional. **If omitted or left empty, `varimax` is applied by default.** If present and non-empty, must be a valid method name.
* `components_to_flip` has two keys only: `unrotated` and `rotated`.
* `components_to_flip.rotated` can be used whether or not `rotation_method` is explicitly set — if `rotation_method` is omitted/empty, the flip is applied against the default varimax rotation. An error is only raised if `rotation_method` is explicitly set to an invalid method name.
* Duplicate flip indices within the same key are an error.
* For `rotation_method = 'hrfmax'`, shapes must be provided via one of two mutually exclusive paths:
  * **Path A — event generation:** define `hrfmax_events` as a struct array with `onset` and `duration` fields (milliseconds). Shapes are generated automatically and saved to `outputDIR`. `description` is optional and does not affect computation.
  * **Path B — pre-built file:** define `hrfmax_shapes_path` (path to `.mat` file) and `hrfmax_shapes_var` (variable name inside the file, typically `'shapes'`). The shapes matrix must be `[n_shapes × bins]` where `bins` matches `config.bins`.
  * If both are defined, Path A takes priority.
  * If neither is defined, Stage 3 will error.
* `hrfmax_iterations` is optional for both paths. Omit to use the default of 5000000.
## Analysis Steps

The legacy script performs the following steps:

1. Creating scan list
2. Creating Z-data matrix
3. Normalizing Z-data matrix
4. Initializing G matrix
5. Creating G matrix
6. Regressing G matrix
7. Extracting components
8. Rotating components (if specified)
9. Flipping components (if specified)
## Troubleshooting

* **Error loading configuration**: Ensure `configs.m` is in the same directory as the stage scripts
* **CPCA library not found**: Check `config.cpcaDIR` points to the correct toolbox path
* **Missing parameters**: The script will display an error message identifying the missing field
* **Base directory not found**: Ensure the path in `config.baseDIR` exists
* **stage1 fails after rerun**: Check that the auto-generated block was deleted from `configs.m` before rerunning
* **Condition names wrong or missing**: Check that variable names in `timing_onsets.txt` match your disk folder names exactly
* **hrfmax rotation fails with missing shapes error**: Ensure `hrfmax_shapes_path` and `hrfmax_shapes_var` are set in the solution config, and that the file exists on disk
* **hrfmax shapes dimension mismatch**: The `shapes` matrix must have exactly `config.bins` columns. Check that the shapes file was generated from the same CPCA toolbox run that produced your G matrix
## Example Configuration

### Single Dataset

```matlab
config = struct();
config.cpcaDIR          = 'Z:\People\MyName\cpca_1.2.2.23';
config.baseDIR          = 'Z:\Data\my_study';
config.outputDIR        = 'Z:\Data\my_study_output';
config.filewildcard     = 'swa*nii';
config.maskName         = 'mask.img';
config.createMask       = 1;
config.maskMethod       = 1;
config.removeVentricles = 1;
config.linearRegress    = 1;
config.quadraticRegress = 1;
config.movementRegress  = 0;
config.userCovariants   = '';
config.meanCenter       = 1;
config.standardize      = 1;
config.bins             = 8;
config.TR               = 2;
config.inScans          = 1;
config.normalize_G      = 1;
config.solutions(1).num_components = 3;
config.solutions(1).rotation_method = 'varimax';
config.solutions(1).components_to_flip.unrotated = [];
config.solutions(1).components_to_flip.rotated   = [2];
```

### Merged Dataset (VISION + PAIN)

```matlab
config = struct();
config.cpcaDIR          = 'D:\fMRI-CPCA\fMRI-CPCA-cmd';
config.baseDIR          = 'D:\fMRI-CPCA\Example_Data_2MergedTasks';
config.outputDIR        = 'D:\fMRI-CPCA\mergedOutPut';
config.filewildcard     = '*nii';
config.maskName         = 'mask.img';
config.createMask       = 1;
config.maskMethod       = 1;
config.removeVentricles = 1;
config.linearRegress    = 1;
config.quadraticRegress = 1;
config.movementRegress  = 0;
config.userCovariants   = '';
config.meanCenter       = 1;
config.standardize      = 1;
config.bins             = 8;
config.TR               = 3;
config.inScans          = 1;
config.normalize_G      = 1;
config.solutions(1).num_components = 2;
config.solutions(1).rotation_method = 'varimax';
config.solutions(1).components_to_flip.unrotated = [1];
config.solutions(1).components_to_flip.rotated   = [1 2];
config.solutions(2).num_components = 3;
config.solutions(2).rotation_method = 'varimax';
config.solutions(2).components_to_flip.unrotated = [];
config.solutions(2).components_to_flip.rotated   = [2];
```

---

## Preprocessing Assumptions

* The file is named exactly `timing_onsets.txt` and placed in `config.baseDIR`
* Variable names follow the format `<subject_folder>_<run_folder>_<condition_name>` for multi-run subjects, or `<subject_folder>_<condition_name>` (or `<subject_folder>_<run_folder>_<condition_name>`) for single-run subjects — including single-run subjects with no run subfolder on disk at all, which use only the `<subject_folder>_<condition_name>` form
* Subject folder names and run folder names in the variable names match the disk folder names **exactly** (case-sensitive)
* Subjects appear in the file in the same order as they appear on disk
* All variable lines for a given subject-run block are grouped together before the next subject-run block begins
* Only conditions that actually occurred in a given run are listed — missing conditions are simply absent, not listed with empty values
* Lines starting with `%` are treated as comments and ignored
* Each timing assignment is on a single line in the form `varname = [ values ];`
