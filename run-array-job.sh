#!/bin/sh

#SBATCH --partition=cpu-t3
#SBATCH --job-name=wesWFDBfiles
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2 		# Number of cores per task
#SBATCH --array=1-10
#SBATCH --error=slurm-%A-%a.err
#SBATCH --output=slurm-%A-%a.out
#SBATCH --mail-user=ashah282@uic.edu
#SBATCH --mail-type=END

module load R/4.2.1-foss-2022a

# Example script for finding MRNs by ICD codes
Rscript code/find-mrnByIcdDx.R icd-dm.txt mrn-dm.txt $SLURM_ARRAY_TASK_ID $SLURM_ARRAY_TASK_COUNT

# Cleaning script to get ICD codes cleaned after new bulk-upload
# Rscript code/convert-icdCodes.R $SLURM_ARRAY_TASK_ID $SLURM_ARRAY_TASK_COUNT

#Rscript R/copy-mrn2wfdb.R mrn-wes.csv wes $SLURM_ARRAY_TASK_ID $SLURM_ARRAY_TASK_COUNT

#Rscript code/find-mrn2wfdb.R miles-crossover-patients.csv $SLURM_ARRAY_TASK_ID $SLURM_ARRAY_TASK_COUNT

