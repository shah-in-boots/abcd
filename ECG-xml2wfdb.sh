#!/bin/sh

#SBATCH --partition=cpu-t3
#SBATCH --job-name=convertXMLtoWFDB
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2		# Number of cores per task
#SBATCH --array=1-25
#SBATCH --error=slurm-%A-%a.err
#SBATCH --output=slurm-%A-%a.out
#SBATCH --mail-user=ashah282@uic.edu
#SBATCH --mail-type=END

printf 'Load modules\n'
module load R/4.2.1-foss-2022a


# Divide the number of tasks based on number of array jobs available
# These are passed on to the R script
echo "This is array task ${SLURM_ARRAY_TASK_ID} out of ${SLURM_ARRAY_TASK_COUNT}"

# Convert XML to WFDB
# First argument = task number or job ID
# Second argument = total number of tasks
# Internal to file will split apart the chunks to process
Rscript R/convert-xml2wfdb.R $SLURM_ARRAY_TASK_ID $SLURM_ARRAY_TASK_COUNT
