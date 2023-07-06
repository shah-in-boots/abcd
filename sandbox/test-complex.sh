#!/bin/bash

#SBATCH --job-name=parsapply
#SBATCH --partition=cpu-t3
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2 		# Number of cores per task
#SBATCH --error=slurm-%J.err
#SBATCH --output=slurm-%J.out

printf 'Load modules with R > 4.0\n'
module load R/4.1.2-foss-2021b 
echo $PWD

printf 'Working on R'
# Rscript that shouldn't fail...
Rscript --vanilla /shared/home/ashah282/projects/cbcd/tests/sandbox/test-complex.R

Rversion=$(R --version)
echo $Rversion

# SLURM information to print out
echo $SLURM_SUBMIT_DIR
echo $SLURM_JOB_NODELIST
