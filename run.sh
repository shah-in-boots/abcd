#!/bin/sh
#
#SBATCH --partition=cpu-t3
#SBATCH --job-name=setupWFDB
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2 		# Number of cores per task
#SBATCH --error=slurm-%J.err
#SBATCH --output=slurm-%J.out
#SBATCH --mail-user=ashah282@uic.edu
#SBATCh --mail-type=END

printf 'Loading modules\n'
module load R/4.1.2-foss-2021b

printf 'R script to be run'
Rscript R/setup-xml2wfdb.R
Rscript R/check-xml2wfdb.R

