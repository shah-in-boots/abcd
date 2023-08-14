#!/bin/sh

#SBATCH --partition=cpu-t3
#SBATCH --job-name=duplicates
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --error=slurm-%J.err
#SBATCH --output=slurm-%J.out

module load R/4.2.1-foss-2022a
Rscript R/tidy-duplicateCSV.R data/ccts/sdoh

