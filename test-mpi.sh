#!/bin/bash

#SBATCH --ntasks=5               # number of MPI processes
#SBATCH --mem-per-cpu=2048M      # memory; default unit is megabytes
#SBATCH --time=0-00:15           # time (DD-HH:MM)

modue load R/4.1.2-foss-2021b
mpirun -np 1 R CMD BATCH test-mpi.R test-mpi.txt
