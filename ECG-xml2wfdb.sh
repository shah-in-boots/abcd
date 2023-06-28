#!/bin/sh

#SBATCH --partition=cpu-t2
#SBATCH --job-name=convertECGtoWFDB
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=1 		# Number of cores per task
#SBATCH --array=1-18
#SBATCH --error=slurm-%A_%a.err
#SBATCH --output=slurm-%A_%a.out
#SBATCH --mail-user=ashah282@uic.edu
#SBATCH --mail-type=END

printf 'Load modules\n'
module load R/4.1.2-foss-2021b

# There needs to be a job for each folder in MUSE (e.g. 20)
# Slurm IDs for each task to help tell us what is going on
config=/shared/home/ashah282/projects/cbcd/data/muse/config.txt
sample=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $2}' $config)
echo "This is array task ${SLURM_ARRAY_TASK_ID}, processing ECG from the ${sample} folder"

# R script will need name of folder before it "goes ham"
Rscript --vanilla ./R/convertXMLtoWFDB.R --args $sample
#Rscript --vanilla ./R/createTestNotes.R
