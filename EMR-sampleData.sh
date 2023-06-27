#!/bin/sh
#
#SBATCH --partition=cpu-c5
#SBATCH --job-name=makeSampleNotes
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=8 		# Number of cores per task
#SBATCH --error=slurm-%J.err
#SBATCH --output=slurm-%J.out
#SBATCH --mail-user=ashah282@uic.edu
#SBATCh --mail-type=END

printf 'Loading modules\n'
module purge
module load R/4.1.2-foss-2021b

printf 'Using R\n'
echo $PWD
Rscript --vanilla ./R/createTestNotes.R

printf 'Completed notes task\n'
module purge
