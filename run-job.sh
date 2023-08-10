#!/bin/sh

#SBATCH --partition=cpu-t3
#SBATCH --job-name=findWFDBdx
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2 		# Number of cores per task
#SBATCH --error=slurm-%J.err
#SBATCH --output=slurm-%J.out

module load R/4.2.1-foss-2022a
Rscript R/find-mrnByWfdbDx.R afib-regex.txt afib-mrn.txt 1 100

