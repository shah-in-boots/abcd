#!/bin/bash

#SBATCH --partition=cpu-t2
#SBATCH --qos=short
#SBATCH --nodes=8
#SBATCH --tasks-per-node=2
#SBATCH --cpus-per-task=1 		# Number of cores per task
#SBATCH --job-name=Notes
#SBATCH --error=Notes.%J.stderr
#SBATCH --output=Notes.%J.stdout

printf 'Loading modules\n'
module load R/4.1.2-foss-2021b Anaconda3/2022.05

printf 'Using R\n'
R CMD BATCH intake-notes.R notes.out

printf 'Completed notes task\n'
