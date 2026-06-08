# CPCA Analysis Script for fMRI

This repository contains a MATLAB script for performing Constrained Principal Component Analysis (CPCA) on fMRI data. The script is designed to streamline the CPCA workflow by using a configurable approach.

## Requirements

* MATLAB (tested with version R2019b or newer)
* fMRI-CPCA library (typically included in `Z:\People\[Your Name]` subfolder)

## Files

### Legacy Pipeline

* `run_cpca_cmd.m` - Main script that performs the CPCA analysis
* `configs.m` - Configuration file containing all analysis parameters

### Refactored Staged Pipeline

* `stage1.m` - Scan list generation, mask creation, and mask verification
* `stage2.m` - Z-normalization, G matrix construction, and regression
* `stage3.m` - Component extraction and rotation
* `stage4.m` - Component flipping
* `unlock.m` - Utility for resetting locked stages after interrupted runs
* `mask_report.m` - Standalone utility for generating a mask reduction report

## Quick Start

### Legacy Pipeline

1. Clone the repository into your machine.
2. Place your study data somewhere inside the folder. (IMPORTANT: Make sure to only have ONE folder/study and NO other folders containing pre-existing processed data. This is due to parts of the script recursively searching through your directories for files and having duplicate file/folder names will cause unexpected behaviours)
3. IMPORTANT: Open the GUI version of fMRI CPCA by running cpca.m from MATLAB. This is create necessary default files that will be used by the command-line code.
4. Edit `configs.m` with your specific parameters (see Configuration section below)
5. Run the following command in MATLAB terminal: `run_cpca_cmd`
6. Review the displayed parameters and confirm to begin analysis

### Refactored Staged Pipeline

The pipeline has also been refactored into four modular stages:

```matlab
>> stage1    % scan list + mask creation + mask verification
>> stage2    % Z normalization + G matrix + regression
>> stage3    % component extraction + rotation
>> stage4    % flip components
```

Each stage must be completed successfully before the next can run. This dependency is enforced automatically by the system.

## Rerunning Stages

### Rerunning Stage 1
Simply run:
```matlab
>> stage1
```
Stage 1 always starts fresh and automatically resets the entire pipeline state, since stages 2–4 depend on its outputs.

### Rerunning Stage 2 or Stage 3
Simply rerun the stage directly — it will automatically delete its own newly created outputs before starting fresh. Files that it overwrites (rather than creates fresh) are left as-is.

```matlab
>> stage2
```
or
```matlab
>> stage3
```

> **Note:** Only files exclusively created by the stage are removed. Any files that were pre-existing and simply overwritten by the stage will not be deleted, as those belong to an earlier stage.

#### Files automatically cleaned by Stage 2
* `Z/`
* `log/`
* `Gsegs/`
* `GZsegs/`
* `Residual_G/`
* `Gheader.mat`
* `timing_onsets_template.txt`
* `timing_onsets_imported.txt`
* `Singular Values.png`
* `mask_used.img`
* `mask_used.hdr`

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

```matlab
config.num_subjects   = 7;    % 3 VISION + 4 PAIN
config.num_runs       = 9;    % max across both datasets
config.num_conditions = 10;   % total unique conditions across both datasets

config.condition_names = {
    '4Letters_NoDelay',   % index 1
    '4Letters_2Delay',    % index 2
    '6Letters_NoDelay',   % index 3
    '6Letters_2Delay',    % index 4
    'pain_standard_high', % index 5
    'pain_standard_low',  % index 6
    'pain_reg-up_high',   % index 7
    'pain_reg-up_low',    % index 8
    'pain_reg-down_high', % index 9
    'pain_reg-down_low'   % index 10
};

% VISION subjects: 1 run, conditions 1-4
config.subject_conditions{1} = {[1 2 3 4]};
config.subject_conditions{2} = {[1 2 3 4]};
config.subject_conditions{3} = {[1 2 3 4]};

% PAIN subjects: 9 runs, 2 conditions per run (varies by run)
config.subject_conditions{4} = {[5 6],[5 6],[7 8],[5 6],[5 6],[5 6],[9 10],[5 6],[5 6]};
config.subject_conditions{5} = {[5 6],[5 6],[9 10],[5 6],[5 6],[5 6],[7 8],[5 6],[5 6]};
config.subject_conditions{6} = {[5 6],[5 6],[9 10],[5 6],[5 6],[5 6],[7 8],[5 6],[5 6]};
config.subject_conditions{7} = {[5 6],[5 6],[9 10],[5 6],[5 6],[5 6],[7 8],[5 6],[5 6]};
```

### Timing onsets file

Prepare a single `timing_onsets.txt` containing entries for all subjects from both datasets. Variable names must follow the format `subjectID_runID_conditionName` where `subjectID` and `runID` match the folder names on disk exactly. Only list entries for conditions that actually occurred — missing conditions do not need to be listed.


## Configuration

Edit `configs.m` to set parameters for your analysis. Below is an explanation of key parameters:

### Basic Parameters

* `config.cpcaDIR` - Directory of fMRI-CPCA library (typically `Z:\People\[Your Name]\cpca_1.2.2.23`)
* `config.baseDIR` - Directory containing your data (typically `Z:\People\[Your Name]\cpca_1.2.2.23\TestData\[Your Data]`)
* `config.outputDIR` - Directory where all pipeline output will be written. If empty or absent, output goes to `baseDIR` (legacy behaviour)
* `config.filewildcard` - Pattern to select scan files (e.g., `'swa*nii'`, `'fsn*img'`)

### Mask Parameters

* `config.maskName` - Name of the mask file (default: `'mask.img'`)
* `config.createMask` - Whether to create a new mask (1) or use existing (0)
* `config.maskMethod` - Mask creation method:
  * 1: Global mean threshold
  * 2: Harvard Oxford MNI coordinates

### Normalization Parameters

* `config.linearRegress` - Apply linear regression (1-On, 0-Off)
* `config.quadraticRegress` - Apply quadratic regression (1-On, 0-Off)
* `config.movementRegress` - Regress out movement parameters (1-On, 0-Off)
* `config.meanCenter` - Apply mean centering (1-On, 0-Off)
* `config.standardize` - Apply standardization (1-On, 0-Off)

### G-Matrix Parameters

* `config.condition_names` - Cell array of all unique condition names across all subjects. Order determines the index used in `subject_conditions`.
* `config.bins` - Number of time bins
* `config.TR` - Timing rate
* `config.inScans` - Timing in Scans (1) or seconds (0)
* `config.normalize_G` - Normalize G matrix (1-Yes, 0-No)

### Timing Parameters

* `config.num_subjects` - Total number of subjects
* `config.num_runs` - Maximum number of runs across all subjects
* `config.num_conditions` - Total number of unique conditions across all subjects

### Subject Conditions

* `config.subject_conditions` - Required. A cell array with one entry per subject. Each entry is a cell array with one entry per run that subject actually has. Each run entry is a numeric array of condition indices — referencing the position in `config.condition_names` — that occurred in that run.

```matlab
% Subject with 1 run, conditions 1-4:
config.subject_conditions{1} = {[1 2 3 4]};

% Subject with 9 runs, variable conditions per run:
config.subject_conditions{4} = {[5 6],[5 6],[7 8],[5 6],[5 6],[5 6],[9 10],[5 6],[5 6]};
```

Rules:
* Every subject must have at least 1 run entry and at most `num_runs` entries
* Condition indices must be within `1:num_conditions`
* Duplicate indices within the same run are an error
* Subjects with fewer runs than `num_runs` simply list only the runs they have — missing runs are skipped automatically
### Component Extraction Parameters

Multiple solutions are supported. Each solution specifies an independent extraction:

```matlab
config.solutions(1).num_components = 2;
config.solutions(1).rotation_method = 'varimax';       % optional — omit for no rotation
config.solutions(1).components_to_flip.unrotated = [1];
config.solutions(1).components_to_flip.rotated   = [1 2];

config.solutions(2).num_components = 3;
config.solutions(2).rotation_method = 'varimax';
config.solutions(2).components_to_flip.unrotated = [];
config.solutions(2).components_to_flip.rotated   = [2];
```

Rules:
* `rotation_method` is optional. If omitted, no rotation is applied. If present, must be a non-empty valid string.
* `components_to_flip` has two keys only: `unrotated` and `rotated`.
* Specifying `components_to_flip.rotated` without a `rotation_method` is an error.
* Duplicate flip indices within the same key are an error.

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

* **Error loading configuration**: Ensure `configs.m` is in the same directory as `run_cpca_cmd.m`
* **CPCA library not found**: The script will display all parameters before running the analysis. Please look through them to see if there are any discrepancies.
* **Missing parameters**: If required parameters are missing, the script will display an error message
* **Base directory not found**: Ensure the path in `config.baseDIR` exists

## Example Configuration

### Single Dataset

```matlab
config = struct();
config.cpcaDIR        = 'Z:\People\MyName\cpca_1.2.2.23';
config.baseDIR        = 'Z:\Data\my_study';
config.outputDIR      = 'Z:\Data\my_study_output';
config.filewildcard   = 'swa*nii';
config.maskName       = 'mask.img';
config.createMask     = 1;
config.maskMethod     = 1;
config.linearRegress  = 1;
config.quadraticRegress = 1;
config.movementRegress = 0;
config.userCovariants = '';
config.meanCenter     = 1;
config.standardize    = 1;
config.num_subjects   = 6;
config.num_runs       = 2;
config.num_conditions = 2;
config.condition_names = {'HIGH', 'LOW'};
config.bins           = 8;
config.TR             = 2;
config.inScans        = 1;
config.normalize_G    = 1;

% All subjects: 2 runs, both conditions in every run
config.subject_conditions{1} = {[1 2], [1 2]};
config.subject_conditions{2} = {[1 2], [1 2]};
config.subject_conditions{3} = {[1 2], [1 2]};
config.subject_conditions{4} = {[1 2], [1 2]};
config.subject_conditions{5} = {[1 2], [1 2]};
config.subject_conditions{6} = {[1 2], [1 2]};

config.solutions(1).num_components = 3;
config.solutions(1).rotation_method = 'varimax';
config.solutions(1).components_to_flip.unrotated = [];
config.solutions(1).components_to_flip.rotated   = [2];
```

### Merged Dataset (VISION + PAIN)

```matlab
config = struct();
config.cpcaDIR        = 'D:\fMRI-CPCA\fMRI-CPCA-cmd';
config.baseDIR        = 'D:\fMRI-CPCA\Example_Data_2MergedTasks';
config.outputDIR      = 'D:\fMRI-CPCA\mergedOutPut';
config.filewildcard   = '*nii';
config.maskName       = 'mask.img';
config.createMask     = 1;
config.maskMethod     = 1;
config.linearRegress  = 1;
config.quadraticRegress = 1;
config.movementRegress = 0;
config.userCovariants = '';
config.meanCenter     = 1;
config.standardize    = 1;
config.num_subjects   = 7;
config.num_runs       = 9;
config.num_conditions = 10;
config.condition_names = {
    '4Letters_NoDelay',   % index 1
    '4Letters_2Delay',    % index 2
    '6Letters_NoDelay',   % index 3
    '6Letters_2Delay',    % index 4
    'pain_standard_high', % index 5
    'pain_standard_low',  % index 6
    'pain_reg-up_high',   % index 7
    'pain_reg-up_low',    % index 8
    'pain_reg-down_high', % index 9
    'pain_reg-down_low'   % index 10
};
config.bins           = 8;
config.TR             = 3;
config.inScans        = 1;
config.normalize_G    = 1;

% VISION subjects: 1 run, conditions 1-4
config.subject_conditions{1} = {[1 2 3 4]};
config.subject_conditions{2} = {[1 2 3 4]};
config.subject_conditions{3} = {[1 2 3 4]};

% PAIN subjects: 9 runs, 2 conditions per run (varies by run)
config.subject_conditions{4} = {[5 6],[5 6],[7 8],[5 6],[5 6],[5 6],[9 10],[5 6],[5 6]};
config.subject_conditions{5} = {[5 6],[5 6],[9 10],[5 6],[5 6],[5 6],[7 8],[5 6],[5 6]};
config.subject_conditions{6} = {[5 6],[5 6],[9 10],[5 6],[5 6],[5 6],[7 8],[5 6],[5 6]};
config.subject_conditions{7} = {[5 6],[5 6],[9 10],[5 6],[5 6],[5 6],[7 8],[5 6],[5 6]};

config.solutions(1).num_components = 2;
config.solutions(1).rotation_method = 'varimax';
config.solutions(1).components_to_flip.unrotated = [1];
config.solutions(1).components_to_flip.rotated   = [1 2];

config.solutions(2).num_components = 3;
config.solutions(2).rotation_method = 'varimax';
config.solutions(2).components_to_flip.unrotated = [];
config.solutions(2).components_to_flip.rotated   = [2];
```
