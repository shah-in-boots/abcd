#!/bin/bash

#SBATCH --partition=cpu-t2
#SBATCH --qos=short
#SBATCH --nodes=4
#SBATCH --tasks-per-node=2
#SBATCH --cpus-per-task=8 		# Number of cores per task

printf 'Loading modules\n'
#module load R/4.1.2-foss-2021b Anaconda3/2022.05
#module list

printf 'Make sure in correct home directory to access clinical data\n'
cd /shared/home/ashah282/data/ccts
echo $PWD

