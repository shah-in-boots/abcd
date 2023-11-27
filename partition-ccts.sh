#!/bin/sh

#SBATCH --partition=cpu-t3
#SBATCH --job-name=notes2year
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2		# Number of cores per task
#SBATCH --array=1-14
#SBATCH --error=slurm-%A-%a.err
#SBATCH --output=slurm-%A-%a.out
#SBATCH --mail-user=ashah282@uic.edu
#SBATCH --mail-type=END

printf 'Load modules\n'
module load R/4.2.1-foss-2022a

# This script is complex in order to keep documentation in one place. There are
# two parts to thw script:
#
# 	1. Split <CSV> files into more manageable chunks
# 	2. Convert <CSV> files to <PARQUET> format
#
# Currently the splitting is done by year, as the data refreshes annually
# The conversion to <PARQUET> is done by a grouping variable.
# This could be a year or an alternative approach based on the data
# Both of these tasks are placed into separate R files to be called
#
# The script below is setup in as an IF/THEN/ELSE series
# The first section can be used by SLURM by splitting by year
# The second section can be used by SLURM by splitting on topic

if true
then # 1 = SPLIT CSV

	# Years setup (2010 to 2023 is 14...)
	years=($(seq 2010 2023))
	year=${years[$SLURM_ARRAY_TASK_ID - 1]}

	# Past to R script with variable for years
	# Remember to update partition if using large files (e.g. procedure-records)
	printf "Splitting data for: $year\n"
	Rscript R/split-ccts.R $year


else # 2 = CONVERT CSV TO PARQUET

	# Data types below
	types=(
		'demographics',
		'diagnosis',
		'labs',
		'medications',
		'notes',
		'procedure-dates',
		'procedure-reports',
		'visits',
		'vitals'
	)

	# Type is the part of the script that will be analyzed
	type=${types[$SLURM_ARRAY_TASK_ID - 1])}

fi

# After splitting the data, can think about partitioning
# Use Apache Arrow system for `parquet` format
