#!/bin/bash
# ---------------------------------------------------------------------------
# hpc_env.sh -- shared environment defaults for the fMRI-CPCA HPC wrapper.
#
# Lives in PROJECT storage, versioned alongside the code. One shared copy for
# the whole lab -- NOT per user. Every value is either a constant or a formula
# in $USER, so each person sourcing this file resolves their own paths.
#
# Sourced by cpca-submit. Never executed directly. No side effects -- pure
# assignments only (no mkdir, no module load, no echo).
# ---------------------------------------------------------------------------

# --- Allocation ------------------------------------------------------------
ALLOC=st-toddwood-1

# --- Code root (= config.cpcaDIR) ------------------------------------------
# TODO: replace <shared-or-user> once the project folder exists on Sockeye.
#       The same path (with /HPC appended) goes in each user's ~/.bash_profile.
CPCA_ROOT=/arc/project/st-toddwood-1/fMRI-CPCA-cmd

# --- Derived paths ---------------------------------------------------------
# cpca-submit runs with pwd = the run folder, so it must refer to the job
# script by ABSOLUTE path.
HPC_DIR=$CPCA_ROOT/HPC
SBATCH_SCRIPT=$HPC_DIR/submit_job.sbatch

# --- Per-user scratch ------------------------------------------------------
# Not used by the wrapper (Model A: the run folder is wherever pwd is).
# Provided for convenience: `cd $SCRATCH_PATH/<run folder>`.
# ${USER:-$(id -un)} rather than bare $USER: cpca-submit runs under
# `set -u`, and USER is not always exported in non-login shells.
SCRATCH_PATH=/scratch/$ALLOC/${USER:-$(id -un)}

# --- Job defaults (overridable per invocation) -----------------------------
DEFAULT_TIME=01:00:00      # cpca-submit <stage> --time HH:MM:SS
DEFAULT_MEM=8G             # cpca-submit <stage> --mem 16G
DEFAULT_CPUS=8             # cpca-submit <stage> --cpus 4

# --- Modules ---------------------------------------------------------------
# gcc is loaded before matlab on this cluster -- keep the order.
MODULE_GCC=gcc/9.4.0
MODULE_MATLAB=matlab/R2023b

# --- MATLAB scratch home ---------------------------------------------------
# Compute-node $HOME is small and shared; MATLAB is redirected here for prefs,
# userpath, java prefs and crash dumps. Per user, created by the job on first
# use. Safe to delete at any time -- it holds no results.
MATLAB_HOME=$SCRATCH_PATH/.matlab_home

# --- Optional per-user overrides -------------------------------------------
# cpca-submit sources ~/.cpca_env after this file, if it exists. Put personal
# settings there -- e.g. email notifications:
#     MAIL_USER=lqiu07@student.ubc.ca
#     MAIL_TYPE=END,FAIL
# Do NOT put them in this file: it is shared by the whole lab.
MAIL_USER=""
MAIL_TYPE="END,FAIL"