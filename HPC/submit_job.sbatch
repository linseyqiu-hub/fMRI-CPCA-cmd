#!/bin/bash
# ---------------------------------------------------------------------------
# submit_job.sbatch -- THE universal job script. One copy, in project storage,
# version controlled. Never rendered or copied per run.
#
# Everything that varies per invocation arrives from outside:
#   - which stage        -> positional arg $1
#   - run folder         -> $SLURM_SUBMIT_DIR (set by Slurm at sbatch time)
#   - time/mem/cpus/logs -> --time/--mem/--cpus-per-task/--output/--error,
#                           supplied on the sbatch command line by cpca-submit
#   - CPCA_ROOT, MODULE_MATLAB -> exported by cpca-submit, inherited via
#                                 Slurm's default --export=ALL
#
# Do not invoke directly with bare `sbatch`; go through cpca-submit.
# ---------------------------------------------------------------------------

#SBATCH --nodes=1
#SBATCH --ntasks=1

set -euo pipefail

# --- 1. Stage argument -----------------------------------------------------
STAGE="${1:-}"
VALID_STAGES=(stage1 stage2 stage3 stage4 mask_report)

if [[ -z "$STAGE" ]]; then
    echo "ERROR: no stage given. Expected: sbatch submit_job.sbatch <stage>" >&2
    exit 2
fi

if [[ ! " ${VALID_STAGES[*]} " == *" $STAGE "* ]]; then
    echo "ERROR: unknown stage '$STAGE'. Valid: ${VALID_STAGES[*]}" >&2
    exit 2
fi

# --- 2. Inherited environment ----------------------------------------------
# If these are empty, the job was launched bare or the site forces
# SBATCH_EXPORT=NONE. Fail loudly rather than running against a wrong path.
: "${CPCA_ROOT:?not set -- submit via cpca-submit, not bare sbatch}"
: "${MODULE_MATLAB:?not set -- submit via cpca-submit, not bare sbatch}"
: "${MODULE_GCC:?not set -- submit via cpca-submit, not bare sbatch}"
: "${MATLAB_HOME:?not set -- submit via cpca-submit, not bare sbatch}"

# --- 3. Land in the run folder ---------------------------------------------
# LOAD-BEARING, not tidiness. The compute node's job process does not inherit
# the submitting shell's pwd. Everything downstream (run('configs.m'),
# pipeline_state.mat, all stage outputs) resolves through pwd.
cd "$SLURM_SUBMIT_DIR"

# --- 4. Diagnostics (these land in logs/<stage>_<jobid>.out) ---------------
echo "=================================================================="
echo " job id     : ${SLURM_JOB_ID:-<none>}"
echo " job name   : ${SLURM_JOB_NAME:-<none>}"
echo " node       : $(hostname)"
echo " stage      : $STAGE"
echo " run folder : $PWD"
echo " cpca root  : $CPCA_ROOT"
echo " started    : $(date '+%Y-%m-%d %H:%M:%S')"
echo "=================================================================="

if [[ ! -f configs.m ]]; then
    echo "ERROR: no configs.m in $PWD -- wrong run folder?" >&2
    exit 3
fi

# --- 5. Modules ------------------------------------------------------------
# gcc BEFORE matlab, and both loaded even though the stage is pure .m code:
# the MATLAB module links against the toolchain's runtime libs, and MEX'd
# code in External/ resolves against them too. Order matches the convergence
# test script that is known to work on this cluster.
module load "$MODULE_GCC"
module load "$MODULE_MATLAB"

# --- 6. Redirect MATLAB's writes away from $HOME ---------------------------
# MATLAB writes prefs, java prefs, the userpath and crash dumps under $HOME.
# On compute nodes home is small, quota'd, and shared across every concurrent
# job -- so MATLAB either fails to start or two jobs corrupt each other's
# prefs. Point HOME at scratch instead.
#
# AFTER module load, not before: the module system caches under the real
# $HOME, and moving the target out from under it mid-load causes odd misses.
export HOME="$MATLAB_HOME"
mkdir -p "$HOME"

# Prefdir is per-JOB, not per-user: two stages submitted at the same time
# (different run folders, same person) would otherwise race on one prefs
# directory. Cheap to recreate -- MATLAB just regenerates defaults.
export MATLAB_PREFDIR="$HOME/prefs_${SLURM_JOB_ID:-$$}"
mkdir -p "$MATLAB_PREFDIR"
trap 'rm -rf "$MATLAB_PREFDIR"' EXIT

echo " HOME       : $HOME"
echo " prefdir    : $MATLAB_PREFDIR"
echo "------------------------------------------------------------------"

# --- 7. MATLAB -------------------------------------------------------------

# -batch (R2019a+) is deliberate over -r:
#   * never enters interactive mode, no need for a trailing exit()
#   * propagates a NONZERO exit code on an uncaught error, so Slurm records
#     FAILED in sacct -- which the recovery workflow reads
# The single addpath(genpath(...)) here supersedes the one inside each stage.
# `|| STATUS=$?` is required: under `set -e` a nonzero matlab exit would
# otherwise abort the script before the exit code could be captured/logged.
STATUS=0
matlab -nodisplay -nosplash -batch "addpath(genpath('$CPCA_ROOT')); $STAGE" || STATUS=$?

echo "=================================================================="
echo " finished   : $(date '+%Y-%m-%d %H:%M:%S')"
echo " exit code  : $STATUS"
echo "=================================================================="

exit $STATUS
