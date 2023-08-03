#!/bin/bash

#SBATCH --partition=cpu-t2
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=2
#SBATCH --time=00:30:00
#SBATCH --mem-per-cpu=1024
#SBATCH --job-name=TestJob
#SBATCH --error=TestJob.%j.err
#SBATCH --output=TestJob%J.out

module load R/4.2.1-foss-2022a
export OMPI_MCA_mtl=^psm
mpirun -n 1 R CMD BATCH Rmpi.R
