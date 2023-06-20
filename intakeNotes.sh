#!/bin/sh
#
#SBATCH --partition=cpu-t3
#SBATCH --job-name=intakeNotes
#SBATCH --nodes=1
#SBATCH --tasks-per-node=2
#SBATCH --cpus-per-task=1 		# Number of cores per task
#SBATCH --error=slurm-%J.err
#SBATCH --output=slurm-%J.out
#SBATCH --mail-user=$USER@uic.edu
#SBATCh --mail-type=END

printf 'Loading modules\n'
module purge
module load R/4.1.2-foss-2021b

printf 'Using R\n'  
echo $PWD
Rscript --vanilla ./intakeNotes.R

printf 'Completed notes task\n'
module purge
