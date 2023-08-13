#!/bin/sh

#SBATCH --partition=cpu-c5
#SBATCH --job-name=findWFDBdx
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --error=slurm-%J.err
#SBATCH --output=slurm-%J.out

module load R/4.2.1-foss-2022a
Rscript R/copy-mrn2wfdb.R sandbox/wes.csv wes 20 30

