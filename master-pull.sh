#!/bin/sh

#SBATCH --partition=cpu-t3
#SBATCH --job-name=pullAFEQT
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2		# Number of cores per task
#SBATCH --array=1-14
#SBATCH --error=slurm-%A-%a.err
#SBATCH --output=slurm-%A-%a.out
#SBATCH --mail-user=ashah282@uic.edu
#SBATCH --mail-type=END

# Script -- master-pull.sh
#
# This script is designed to extract all clinical data for a set of MRNs.
# 	Includes all the data from the EMR from 2010 to 2023
# 	All of the ECG data from 2010 to 2023 (+ WFDB format if available)

printf 'Load modules\n'
module load R/4.2.1-foss-2022a

# Years setup (2010 to 2023 is 14...)
years=($(seq 2010 2023))
year=${years[$SLURM_ARRAY_TASK_ID - 1]}
printf "Filtering out data from: $year\n"

# Subcript -- copy-mrn2clinical.R
#
# THis script is desgined to work with the clinical data from CCTS
# Uses several arguments:
# 	MRN
# 	YEAR (works as a batching variable)
# 	OUTPUT (folder for where data should be placed)
# 	FORMAT (format of saving files, e.g parquet, CSV)
Rscript R/pull-mrn2clinical.R mrn-afeqt.txt $year ~/data/cbcd/afeqt/emr/ parquet

# Will repeat for ECG data
