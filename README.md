# CPCA Analysis Script for fMRI

This repository contains a MATLAB script for performing Constrained Principal Component Analysis (CPCA) on fMRI data. The script is designed to streamline the CPCA workflow by using a configurable approach.

## Requirements

- MATLAB (tested with version R2019b or newer)
- fMRI-CPCA library (typically included in `Z:\People\[Your Name]` subfolder)

## Files

- `run_cpca_cmd.m` - Main script that performs the CPCA analysis
- `configs.m` - Configuration file containing all analysis parameters

## Quick Start

1. Clone the repository into your machine.
2. Place your study data somewhere inside the folder. (IMPORTANT: Make sure to only have ONE folder/study and NO other folders containing pre-existing processed data. This is due to parts of the script recursively searching through your directories for files and having duplicate file/folder names will cause unexpected behaviours)
3. IMPORTANT: Open the GUI version of fMRI CPCA by running cpca.m from MATLAB. This is create necessary default files that will be used by the command-line code. 
4. Edit `configs.m` with your specific parameters (see Configuration section below)
5. Run the following command in MATLAB terminal: `run_cpca_cmd`
6. Review the displayed parameters and confirm to begin analysis

## Configuration

Edit `configs.m` to set parameters for your analysis. Below is an explanation of key parameters:

### Basic Parameters

- `config.cpcaDIR` - Directory of fMRI-CPCA library (typically `Z:\People\[Your Name]\cpca_1.2.2.23`)
- `config.baseDIR` - Directory containing your data (typically `Z:\People\[Your Name]\cpca_1.2.2.23\TestData\[Your Data]`)
- `config.filewildcard` - Pattern to select scan files (e.g., 'swa*nii', 'fsn*img')

### Mask Parameters

- `config.maskName` - Name of the mask file (default: 'mask.img')
- `config.createMask` - Whether to create a new mask (1) or use existing (0)
- `config.maskMethod` - Mask creation method:
  - 1: Global mean threshold
  - 2: Harvard Oxford MNI coordinates

### Normalization Parameters

- `config.linearRegress` - Apply linear regression (1-On, 0-Off)
- `config.quadraticRegress` - Apply quadratic regression (1-On, 0-Off)
- `config.movementRegress` - Regress out movement parameters (1-On, 0-Off)
- `config.meanCenter` - Apply mean centering (1-On, 0-Off)
- `config.standardize` - Apply standardization (1-On, 0-Off)

### G-Matrix Parameters

- `config.condition_names` - Array of condition names (e.g., `{'HIGH', 'LOW'}`)
- `config.bins` - Number of time bins
- `config.TR` - Timing rate
- `config.inScans` - Timing in Scans (1) or seconds (0)
- `config.normalize_G` - Normalize G matrix (1-Yes, 0-No)

### Timing Parameters

- `config.num_subjects` - Number of subjects
- `config.num_runs` - Number of runs per subject
- `config.num_conditions` - Number of conditions

### Component Extraction Parameters

- `config.num_components` - Number of components to extract
- `config.rotation_method` - Rotation method (e.g., 'varimax', 'promax')
- `config.components_to_flip` - Array of component indices to flip (e.g., `[2]`)

## Analysis Steps

The script performs the following steps:

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

- **Error loading configuration**: Ensure `configs.m` is in the same directory as `run_cpca_cmd.m`
- **CPCA library not found**: The script will display all parameters before running the analysis. Please look through them to see if there are any discrepancies.
- **Missing parameters**: If required parameters are missing, the script will display an error message
- **Base directory not found**: Ensure the path in `config.baseDIR` exists

## Example Configuration

```matlab
% Example configuration
config = struct();
config.baseDIR = 'Z:\Data\semantic_association_data';
config.filewildcard = 'swa*nii';
config.maskName = 'mask.img';
config.createMask = 1;
config.maskMethod = 1;
config.linearRegress = 1;
config.quadraticRegress = 1;
config.meanCenter = 1;
config.standardize = 1;
config.condition_names = {'HIGH', 'LOW'};
config.bins = 10;
config.TR = 2;
config.inScans = 1;
config.normalize_G = 1;
config.num_subjects = 6;
config.num_runs = 1;
config.num_conditions = 2;
config.num_components = 3;
config.rotation_method = 'varimax';
```
