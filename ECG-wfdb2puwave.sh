#!/bin/sh

#SBATCH --partition=cpu-t3
#SBATCH --job-name=ecgpuwave
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2							# Number of cores per task
#SBATCH --array=1-22									# Number of current folders in the WFDB
#SBATCH --error=slurm-%A-%a.err
#SBATCH --output=slurm-%A-%a.out
#SBATCH --mail-user=ashah282@uic.edu
#SBATCH --mail-type=END

printf 'Load modules\n'
module load R/4.2.1-foss-2022a

# There needs to be a job for each folder in WFDB
# Slurm IDs for each task to help tell us what is going on
config=/shared/home/ashah282/projects/cbcd/config-wfdb.txt
year=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $2}' $config)
echo "This is array task ${SLURM_ARRAY_TASK_ID}, processing ECG from the ${year} folder"

# Past to R script with variable for years
# Remember to update partition if using large files (e.g. notes)
printf "Create ECGPUWAVE annotations for the following time: $year"
Rscript R/annotate-wfdb2puwave.R $year
