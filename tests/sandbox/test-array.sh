#!/bin/bash

#SBATCH --partition=cpu-t2
#SBATCH --qos=short
#SBATCH --nodes=4
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=1 		# Number of cores per task
#SBATCH --array=1-2

printf 'No loading modules\n'
#module load R/4.1.2-foss-2021b 

# Rscript that shouldn't fail...
Rscript --vanilla /shared/home/ashah282/projects/cbcd/tests/sandbox/test-array.R --args $SLURM_ARRAY_TASK_ID

