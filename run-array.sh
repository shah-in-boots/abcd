#!/bin/sh

#SBATCH --partition=cpu-t3
#SBATCH --job-name=copyWFDBbyMRN
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2 		# Number of cores per task
#SBATCH --array=28 # out of 30
#SBATCH --error=slurm-%A-%a.err
#SBATCH --output=slurm-%A-%a.out
#SBATCH --mail-user=ashah282@uic.edu
#SBATCH --mail-type=END

module load R/4.2.1-foss-2022a
Rscript R/match-wfdb2mrn.R sandbox/wes.csv wes $SLURM_ARRAY_TASK_ID 30
#Rscript R/match-wfdb2mrn.R sandbox/wes.csv wes $SLURM_ARRAY_TASK_ID $SLURM_ARRAY_TASK_COUNT

