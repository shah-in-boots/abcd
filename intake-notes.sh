#!/bin/bash
#
#SBATCH --partition=cpu-t2
#SBATCH --job-name=notes
#SBATCH --qos=short
#SBATCH --nodes=4
#SBATCH --tasks-per-node=2
#SBATCH --cpus-per-task=1 		# Number of cores per task
#SBATCH --output=notes_%J.log
#SBATCH --output=slurm.out
#SBATCH --error=slurm.err

printf 'Loading modules\n'
module load R/4.1.2-foss-2021b Anaconda3/2022.05

printf 'Using R\n'
Rscript ./intake-notes.R 

printf 'Completed notes task\n'
