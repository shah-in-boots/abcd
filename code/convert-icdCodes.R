#!/usr/bin/env Rscript

# `convert-icdCodes.R` converts between ICD-9 to ICD-10
#
# ICD codes are contained in a file called 'diagnosis.csv'. These files
# are all contained within directories by YEAR to help reduce file size. Will
# parse through each of these directories 1x1 and then apply batch splits to
# each to help process them.
#
# Arguments [2]:
# 	SLURM_ARRAY_JOB_ID <integer>
# 		Task Number to pass forward for batching
#		SLURM_ARRAY_TASK_COUNT <integer>
#			Total number of tasks to help with batching
#			Needed to help divide number of jobs
#
# Output [1]: Re-writes 'diagnosis.csv' for analysis in all ICD10 codes
# 	CSV <file>

# Setup ----
cat('Convert ICD9 to ICD10 codes!\n\n')

# Libraries
library(readr)
library(dplyr)
library(fs)
library(tibble)
library(vroom)
library(parallel)
library(foreach)
library(touch)

# Paths
home <- fs::path_expand("/", "shared", "projects", "cardio_darbar", "common")
project <- fs::path("software", "abcd")
uic <- fs::path(home, "data", "uic", "cdw")

# Handle arguments
args <- commandArgs(trailingOnly = TRUE)
taskNumber <- as.integer(args[1])
taskCount <- as.integer(args[2])
cat('\tBatch array job number:', taskNumber, '\n')
cat('\tTotal number of array jobs:', taskCount, '\n')

# Parallel...
nCPU <- parallel::detectCores()
doParallel::registerDoParallel(cores = nCPU)
cat('Attempt parallelization with', nCPU, 'cores\n')

# Handle I/O
cat('\nHandling the inputs & outputs:\n')
inputFile <- fs::path(uic, 'raw', 'diagnosis-raw', ext = 'csv')
cat('\tWill split up the file named...', inputFile, '\n')
outputFile <- fs::path(uic, 'raw', 'diagnosis', ext = 'csv')
cat('\tWill then write to...', outputFile, '\n')

# Get lines and line numbers to help with batching
l <-
	system2(command = 'wc',
					args = paste('-l', inputFile),
					stdout = TRUE) |>
	readr::parse_number() |>
	{\(.x) .x - 1 }() # Subtract off header
lineNumbers <- 1:l
cat('\tNumber of lines to read in this file is', l, '\n')

# Now only read in a portion based on batching
lineSplits <-
	split(lineNumbers, cut(seq_along(lineNumbers), taskCount, labels = FALSE))
chunk <- lineSplits[[taskNumber]]
cat("\tNumber of lines to read in in this batch is", length(chunk), "\n")

# Now handle updating ICD9 to 10 codes
cat("\nWill now change ICD9 to ICD10 codes.\n")

# Read in diagnostic codes in this batch
outputData <-
	vroom::vroom(
		file = inputFile,
		col_names = c('RECORD_ID', 'redcap_repeat_instrument', 'redcap_repeat_instance', 'ENCOUNTER_ID', 'START_DATE', 'ICD_CODE', 'CODING_SYSTEM'),
		col_select = c('RECORD_ID', 'ENCOUNTER_ID', 'START_DATE', 'ICD_CODE', 'CODING_SYSTEM'),
		skip = min(chunk, na.rm = TRUE),
		n_max = length(chunk)
	) |>
	# Convert to ICD10 code if is in ICD9
	dplyr::mutate(ICD_CODE = if_else(CODING_SYSTEM == 'ICD9CM', touch::icd_map(ICD_CODE, from = 9, to = 10, decimal = TRUE, nomatch = NA), ICD_CODE))
cat('Number of rows in file is', nrow(outputData), '\n')

# Generate output file
if (!fs::file_exists(outputFile)) {
	col_names <-
		c('RECORD_ID', 'ENCOUNTER_ID', 'START_DATE', 'ICD_CODE') |>
		paste0(collapse = ',')
	readr::write_lines(col_names, file = outputFile)
}

# Write out file
vroom::vroom_write(outputData, file = outputFile, delim = ',', append = TRUE)
cat("\nFinished writing out the file!")
