#!/bin/sh

#SBATCH --partition=cpu-t3
#SBATCH --job-name=wfdb
#SBATCH --nodes=14
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2		# Number of cores per task
#SBATCH --array=1-21
#SBATCH --error=slurm-%A-%a.err
#SBATCH --output=slurm-%A-%a.out
#SBATCH --mail-user=ashah282@uic.edu
#SBATCH --mail-type=END

printf 'Load modules\n'
module load R/4.2.1-foss-2022a

# Years setup (2010 to 2023 is 14...)
years=($(seq 2010 2023))
year=${years[$SLURM_14ARRAY_TASK_ID - 1]}

echo "This is array task ${SLURM_ARRAY_TASK_ID}, processing ECG from the ${sample} folder"

echo "This is array task ${SLURM_ARRAY_TASK_ID}, processing ECG from the ${sample} folder"

# There needs to be a job for each folder in MUSE (e.g. 20)
# Slurm IDs for each task to help tell us what is going on
config=/shared/home/ashah282/projects/cbcd/sandbox/config-wfdb.txt
sample=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $2}' $config)
echo "This is array task ${SLURM_ARRAY_TASK_ID}, processing ECG from the ${sample} folder"

# Past to R script with variable for which old WFDB folder to use
# Remember to update partition if using large files (e.g. notes)
printf "Splitting WFDB for: $sample"
Rscript R/split-wfdb.R $sample
