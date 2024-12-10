function fs = study_filesys_arch()
% ---
% --- configuration of study output file names and locations
% ---

fs_struct = struct( 'root',       '', ...
                    'components', '', ...
                    'images', '', ...
                    'copies', '');

fs = struct ( ...
  'dir_char',    '{sep}', ...
  'root',        '{model}{sep}_#__components{sep}{mode}{sep}', ...
  'betas',       '{model}{sep}', ...
  'threshold',   '{thr}{sep}', ...
  'unrotated',   fs_struct, ...
  'rotated',     fs_struct, ...
  'subject',     fs_struct );

  fs_names.images     = [ 'Images'          filesep ];
  fs_names.copies     = [ 'Duplicates'      filesep ];
  fs_names.components = [ 'Component__n_'   filesep ];
  fs_names.subjects   = [ 'Subject__s_'     filesep ];
  fs_names.plots      = [ 'Plots'           filesep ];
  fs_names.clusters   = [ 'Cluster_Info'    filesep ];
  fs_names.mean       = [ 'mean_beta'       filesep ];
  fs_names.median     = [ 'median_beta'     filesep ];
  fs_names.masks      = [ 'Masks'           filesep ];
  fs_names.betas      = [ 'Betas'           filesep ];
  fs_names.fliplog    = [ 'FlipLogs'        filesep ];

  fs_names.unrotated  = [ 'unrotated'       filesep ];
  fs_names.rotated    = [ '{method}'        filesep ];
  fs_names.h_indexed  = [ '{hindex}'        filesep ];

  fs.path.root       =   fs.root;
  fs.path.output     = [ fs.root    fs_names.rotated ];
  fs_path.subject    = [ fs.root    fs_names.rotated      fs_names.h_indexed   'Subject_Specific'  filesep ];

  fs.path.unrotated.output         = [ fs.root                     fs_names.unrotated   fs_names.h_indexed];
  fs.path.unrotated.images         = [ fs.path.unrotated.output    fs_names.images ];
  fs.path.unrotated.plots          = [ fs.path.unrotated.output    fs_names.plots ];
  fs.path.unrotated.fliplog        = [ fs.path.unrotated.output    fs_names.fliplog ];

  fs.path.unrotated.clusters       = [ fs.path.unrotated.output    fs_names.clusters ];
  fs.path.unrotated.cluster_txt    = [ fs.path.unrotated.clusters  fs_names.components  fs.threshold];
  fs.path.unrotated.cluster_mean   = [ fs.path.unrotated.clusters  fs_names.components  fs_names.mean    fs.threshold ];
  fs.path.unrotated.cluster_median = [ fs.path.unrotated.clusters  fs_names.components  fs_names.median  fs.threshold ];
  fs.path.unrotated.cluster_mask   = [ fs.path.unrotated.clusters  fs_names.components  fs_names.masks   fs.threshold ];
  fs.path.unrotated.cluster_plots  = [ fs.path.unrotated.clusters  fs_names.components  fs_names.plots   fs.threshold ];

  fs.path.unrotated.gmhoutput      = [ fs.path.unrotated.output ];

  % ----                                    eg:  H       /    HZ    /   2_components   /   hrfmax /
  fs.path.rotated.output           = [ fs.root                     fs_names.rotated     fs_names.h_indexed];
  fs.path.rotated.images           = [ fs.path.rotated.output      fs_names.images ];
  fs.path.rotated.plots            = [ fs.path.rotated.output      fs_names.plots ];
  fs.path.rotated.clusters         = [ fs.path.rotated.output      fs_names.clusters ];
  fs.path.rotated.fliplog          = [ fs.path.rotated.output      fs_names.fliplog ];
  fs.path.rotated.cluster_txt      = [ fs.path.rotated.clusters    fs_names.components ];
  fs.path.rotated.cluster_mean     = [ fs.path.rotated.clusters    fs_names.components  fs_names.mean    fs.threshold ];
  fs.path.rotated.cluster_median   = [ fs.path.rotated.clusters    fs_names.components  fs_names.median  fs.threshold ];
  fs.path.rotated.cluster_mask     = [ fs.path.rotated.clusters    fs_names.components  fs_names.masks   fs.threshold ];
  fs.path.rotated.cluster_plots    = [ fs.path.rotated.clusters    fs_names.components  fs_names.plots   fs.threshold ];


  fs.path.subject.root             = [ fs_path.subject ];
  fs.path.subject.output           = [ fs_path.subject ];
  fs.path.subject.subject          = [ fs.path.subject.output      fs_names.subjects ];
  fs.path.subject.component        = [ fs.path.subject.subject     fs_names.components ];
  fs.path.subject.clusters         = [ fs.path.subject.output      fs_names.clusters ];
  fs.path.subject.cluster_txt      = [ fs.path.subject.clusters    fs_names.components  fs.threshold];
  fs.path.subject.cluster_mean     = [ fs.path.subject.clusters    fs_names.components  fs_names.mean    fs.threshold ];
  fs.path.subject.cluster_median   = [ fs.path.subject.clusters    fs_names.components  fs_names.median  fs.threshold ];
  fs.path.subject.images           = [ fs.path.subject.subject     fs_names.images ];

  fs.path.beta.root                = [ fs.betas                    fs_names.betas ];
  fs.path.beta.subjects            = [ fs.path.beta.root           fs_names.subjects ];

% ---  filetype text replacement variables
% ---     * all unused tags repaced by blank string
% ---     * underscore character placement in replacement text
% ---     * double underscores replaced by single
% ---
% ---     tag        under   replacement
% ---   -----------------------------------------------------------
% ---   {model}      after  G H GMH
% ---   {method}     after  unrotated or rotation method ( varimax etc ... )
% ---   {rotation}   after  redundant tag for rotation method
% ---   {style}      after  oblique/orthogonal
% ---   {matter}     both   Gray, White
% ---   {shape}      after  Procrustes HRF Specific - single shape usage
% ---   {var}        after  Variable name file specific to  ( HRF, T etc ... )
% ---   {iterations} after  Rotation parameter # of iterations in T calculation
% ---   {power}      after  Rotation parameter  exponential power
% ---   {gamma}      after  Rotation parameter  gamma
% ---   {posneg}     none   Beta specific - indicate positive/negative output
% ---   {component}  after  'C#'
% ---   {subject}    after  'Subject_#'
% ---   {cluster}    after  'Cluster_#'

  fs.filetype.mat             = '{model}{method}{matter}{shape}{var}{iterations}.mat';
  fs.filetype.txt             = '{component}{var}{subject}{model}{method}{matter}{shape}{iterations}{posneg}.txt';
  fs.filetype.png             = '{component}{var}{model}{method}{matter}{shape}{iterations}{posneg}.png';
  fs.filetype.img             = '{component}{rotation}{model}{matter}{shape}{iterations}.img';
  fs.filetype.subject_img     = '{component}{rotation}{subject}{matter}{shape}{iterations}.img';
  fs.filetype.loadings        = 'image-loadings_{model}{method}{matter}{shape}{iterations}.mat';
  fs.filetype.alt_vr          = '{rotation}{matter}{shape}{iterations}_alt_vr.mat';
  fs.filetype.alt_vr_img      = '{rotation}{subject}{matter}{shape}{iterations}.img';
  fs.filetype.alt_vr_loadings = 'image-loadings_{subject}{model}{method}{matter}{shape}{iterations}.mat';
  fs.filetype.alt_vr_txt      = '{component}{var}{model}{method}{matter}{shape}{iterations}{subject}.txt';
  fs.filetype.alt_vr_summary  = '{component}{var}{model}{method}{matter}{shape}{iterations}.txt';
  fs.filetype.alt_vr_beta     = '{component}{var}{model}{method}{matter}{shape}{iterations}.txt';
  fs.filetype.cluster_txt     = '{component}{model}{method}{matter}{shape}{var}{iterations}{posneg}{cluster}.txt';
  fs.filetype.subject_txt     = '{component}{model}{subject}{method}{matter}{iterations}.txt';
