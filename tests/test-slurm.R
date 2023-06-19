#!/usr/bin/env Rscript

# Grab the array ID from environment variables from `sbatch`
slurm_array_id <- Sys.getenv('SLURM_ARRAY_TASK_ID')
n <- as.numeric(slurm_array_id)
