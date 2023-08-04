#!/bin/sh

#SBATCH --partition=cpu-c5
#SBATCH --job-name=writeWFDBmrns
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=18 		# Number of cores per task
#SBATCH --error=slurm-%J.err
#SBATCH --output=slurm-%J.out
#SBATCH --mail-user=ashah282@uic.edu
#SBATCH --mail-type=END

module load R/4.2.1-foss-2022a
Rscript R/write-wfdb2mrn.R 

