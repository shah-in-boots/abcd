#!/bin/bash

#SBATCH --partition=cpu-t2
#SBATCH --qos=short
#SBATCH --nodes=4
#SBATCH --tasks-per-node=2
#SBATCH --cpus-per-task=1 		# Number of cores per task

printf 'Loading modules\n'
#module load R/4.1.2-foss-2021b Anaconda3/2022.05
module list

printf 'Make sure in home directory to access data'
cd /shared/home/ashah282
echo $PWD