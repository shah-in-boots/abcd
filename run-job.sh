#!/bin/sh

#SBATCH --partition=cpu-c5
#SBATCH --job-name=copyWFDBbyMRN
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=18 		# Number of cores per task
#SBATCH --error=slurm-%J.err
#SBATCH --output=slurm-%J.out

module load R/4.2.1-foss-2022a
Rscript R/match-wfdb2mrn.R sandbox/wes.csv wes 1 30

