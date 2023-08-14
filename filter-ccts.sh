#!/bin/sh

#SBATCH --partition=cpu-t3
#SBATCH --job-name=filterByMrn
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2		# Number of cores per task
#SBATCH --array=1
#SBATCH --error=slurm-%A-%a.err
#SBATCH --output=slurm-%A-%a.out
#SBATCH --mail-user=ashah282@uic.edu
#SBATCH --mail-type=END

printf 'Load modules\n'
module load R/4.2.1-foss-2022a

# Years setup (2010 to 2023 is 14...)
years=($(seq 2010 2023))
year=${years[$SLURM_ARRAY_TASK_ID - 1]}

# Past to R script with variable for years
# Remember to update partition if using large files (e.g. procedure-records)
printf "Filtering out data from: $year"
Rscript R/copy-mrn2clinical.R afib-mrn.txt data/ccts/sdoh $year
