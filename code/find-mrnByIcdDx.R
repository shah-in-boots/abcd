#!/usr/bin/env Rscript

# `find-mrnByIcdDx.R` identifies MRN from CCTS data pull
#
# Evaluates the diagnoses listed in the ICD codes. Requires a list of ICD codes
# to evaluate for, in ICD10 format. It then searches for the matching files, and
# will eventually tie these back to the MRNs. Finally, the MRNs will be written
# to a file. If the file exists, will instead append to it.
#
# Arguments [4]:
# 	ICD CODES <file>
# 		Path to file with each line containing ICD10 codes
# 		Assumes that path is from project home (e.g. */common/software/abcd/.)
# 		Each line is an ICD10 code that is being searched for
# 	OUTPUT <file>
# 		Path to output file and name of it
# 		Assumes that path is from project home (e.g. */common/software/abcd/.)
# 		If already exists, will append to it
# 	SLURM_ARRAY_JOB_ID <integer>
# 		Task Number to pass forward for batching
#		SLURM_ARRAY_TASK_COUNT <integer>
#			Total number of tasks to help with batching
#			Needed to help divide number of jobs
#
# Output [1]:
# 	TXT <file>
# 		Creates a TEXT file with 1 MRN per LINE
# 
# Last Updated: 07/22/24 @ Anish S. Shah

# Setup ----

cat('Will find MRN by ICD code diagnosis!\n\n')

# Libraries
library(readr)
library(dplyr)
library(fs)
library(tibble)
library(vroom)
library(parallel)
library(foreach)
library(icd)

# Paths
# 	home = common project folder for software and data
# 	project = where the MRN list is held
# 	uic = where clinical data is held from the CDW/CCTS
home <- fs::path("/", "shared", "projects", "cardio_darbar", "common")
project <- fs::path(home, "software", "abcd")
uic <- fs::path(home, "data", "uic", "cdw")

# Edits were made using latest versions of required libraries installed in local server library

#**May need to change inputFile path / file name (line 80)

# Handle arguments
args <- commandArgs(trailingOnly = TRUE)
icdArg <- as.character(args[1])
outputArg <- as.character(args[2])
taskNumber <- as.integer(args[3]) # Task number or ID from slurm
taskCount <- as.integer(args[4]) # Total array jobs will be the number of nodes
cat('\tICD code file name is:', icdArg, '\n')
cat('\tWill write to file:', outputArg, '\n')
cat('\tBatch array job number:', taskNumber, '\n')
cat('\tTotal number of array jobs:', taskCount, '\n')

# Parallel...
nCPU <- parallel::detectCores()
doParallel::registerDoParallel(cores = nCPU)
cat('Attempt parallelization with', nCPU, 'cores\n')

# I/O ----

cat('\nHandling the inputs & outputs:\n')

# ICD codes
icdCodes <- readr::read_lines(fs::path(project, icdArg))
cat('\tHave', length(icdCodes), 'ICD codes to evaluate\n')

# Input file is the diagnosis file of interest
inputFile <- fs::path(uic, 'raw', 'diagnosis', ext = 'csv')

# Output file
outputFile <- fs::path(project, outputArg)
if (!fs::file_exists(outputFile)) {
	fs::file_create(outputFile)
	cat('\tCreating output file at...', outputFile, '\n')
} else {
	cat('\tWill append to output file at...', outputFile, '\n')
}

# Batch Prep ----

cat('\nBatch preparation:\n')

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

# Diagnosis ----

cat("\nNow time to search through data chunks:\n")
outputData <-
	vroom::vroom(
		file = inputFile,
		# Removed delim option to avoid error
		col_names = c('record_id', 'encounter_id', 'date', 'icd_code'),
		skip = min(chunk, na.rm = TRUE),
		n_max = length(chunk)
	)

n <- nrow(outputData)
cat("\tFound out will be analyzing", n, "rows\n")

# Changed iteration range to be thru icdCodes
# Previous version was through range of outputData
numCodes <- length(icdCodes)

ids <- foreach(i = 1:numCodes, .combine = 'c', .errorhandling = 'remove') %dopar% {

	# Flip through ICD diagnoses
	outputData |>
		dplyr::filter(stringr::str_detect(icdCodes[i], icd_code)) |>
		dplyr::pull(record_id)

}
cat("\tDiscovered", length(ids), "possible MRNs\n")

# Get MRNs from IDS
# This is in the demographics file
# 	Previously this was hte "redcap-ids.csv" file

redcap <-
	fs::path(uic, 'raw', 'demographics.csv') |>
	vroom::vroom() |>
	janitor::clean_names()

# Filter to relevant data
mrn <-
	#Flipped %in% arguments to find indices of redcap$record_id:
	redcap[which(redcap$record_id %in% ids), ] |>
	dplyr::pull(mrn) |>
	as.character()

vroom::vroom_write_lines(mrn, file = outputFile, append = TRUE)
cat("Total number of MRNs =", length(mrn), "!")
