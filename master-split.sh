#!/bin/sh

#SBATCH --partition=cpu-t3
#SBATCH --job-name=visits2parquet
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2		# Number of cores per task
#SBATCH --array=1-10
#SBATCH --error=slurm-%A-%a.err
#SBATCH --output=slurm-%A-%a.out
#SBATCH --mail-user=ashah282@uic.edu
#SBATCH --mail-type=END

# Setup and loading of modules
printf 'Load modules\n'
module load R/4.2.1-foss-2022a

# This script is complex in order to keep documentation in one place. There are
# three parts to thw script:
#
# 	1. Prepare/clean <CSV> (raw) files prior to chunking
# 	2. Split <CSV> files into more manageable chunks
# 	3. Convert <CSV> files to <PARQUET> format
#
# Currently the splitting is done by year, as the data refreshes annually
# The conversion to <PARQUET> is done by a grouping variable.
# This could be a year or an alternative approach based on the data
# Both of these tasks are placed into separate R files to be called
#
# The script below is setup in as an IF/THEN/ELSE series
# The first section can be used by SLURM by splitting tasks into batches
# The second section can be used by SLURM by splitting by year
# The third section can be used by SLURM by splitting on topic


# 1 = PREPARE RAW
if true
then

	# Slurm settings above will be used to help chunk the data
	# These mini-batches help with processing speed
	
	# Diagnoses
	# These need to be converted from ICD-9 to ICD-10
	# The raw file with mixed ICD codes should be called 'diagnosis-raw.csv'
	# The output file will then be 'diagnosis.csv'
	Rscript R/convert-icdCodes.R $SLURM_ARRAY_JOB_ID $SLURM_ARRAY_TASK_COUNT
fi

# 2 = SPLIT CSV
if false
then 

	# Years setup (2010 to 2023 is 14...)
	years=($(seq 2010 2023))
	year=${years[$SLURM_ARRAY_TASK_ID - 1]}

	# Past to R script with variable for years
	# Remember to update partition if using large files (e.g. procedure-records)
	# Can also select which variables are to be evaluated in Rscript
	printf "Splitting data for: $year\n"
	Rscript R/split-ccts2csv.R $year
fi

# 3 = CSV TO PARQUET
if false 
then

	# Data types below = 9 overall
	types=(
		'demographics'
		'diagnosis'
		'labs'
		'medications'
		'notes'
		'procedure-dates'
		'procedure-reports'
		'visits'
		'vitals'
	)

	# Type is the part of the script that will be analyzed
	type=${types[$SLURM_ARRAY_TASK_ID - 1])}

	# Rscript to run
	Rscript R/split-csv2parquet.R $type

fi

