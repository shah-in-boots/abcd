#!/usr/bin/env Rscript

# `copy-mrn2clinical.R` uses MRNs to subset the clinical data
#
# Arguments [4]:
# 	MRN <file>
# 		Path to list of MRNs file and name of it
# 		Assumes that path is from project home (e.g. ~/projects/cbcd/.)
# 		Expects file to be a list with an MRN on each line
# 	OUTPUT <folder>
# 		Name of path and folder name to put findings
#			Makes a subset of data from the giant initial datasestm
# 	SLURM_ARRAY_JOB_ID <integer>
# 		Task Number to pass forward for batching
#		SLURM_ARRAY_TASK_COUNT <integer>
#			Total number of tasks to help with batching
#			Needed to help divide number of jobs
#
# Output [1]:
# 	DATA <csv>
# 		Creates a subset of data from the clinical datasets
#

# Setup ----

cat('Find clinical data by MRN!\n\n')

# Libraries
library(readr)
library(dplyr)
library(fs)
library(tibble)
library(vroom)
library(parallel)
library(foreach)

# Paths
home <- fs::path_expand('~')
main <- fs::path('projects', 'cbcd')
ccts <- fs::path(home, main, 'data', 'ccts')

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
icdCodes <- readr::read_lines(fs::path(home, main, icdArg))
cat('\tHave', length(icdCodes), 'ICD codes to evaluate\n')

# Input file is the diagnosis file of interest
inputFile <- fs::path(ccts, 'raw', 'diagnosis-proc', ext = 'csv')

# Output file
outputFile <- fs::path(home, main, outputArg)
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
		delim = ',',
		col_names = c('record_id', 'encounter_id', 'date', 'icd_code'),
		skip = min(chunk, na.rm = TRUE),
		n_max = length(chunk)
	)

n <- length(outputData)
cat("\tFound out will be analyzing", n, "rows\n")
ids <- foreach(i = 1:n, .combine = 'c', .errorhandling = 'remove') %dopar% {

	# Flip through ICD diagnoses
	outputData |>
		dplyr::filter(stringr::str_detect(icdCodes[i], icd_code)) |>
		dplyr::pull(record_id)

}
cat("\tDiscovered", length(ids), "possible MRNs\n")

# Get MRNs from IDS
redcap <-
	fs::path(ccts, 'raw', 'redcap-ids.csv') |>
	vroom::vroom()

# Filter to relevant data
mrn <-
	redcap[which(ids %in% redcap$record_id), ] |>
	dplyr::pull(mrn) |>
	as.character()

vroom::vroom_write_lines(mrn, file = outputFile, append = TRUE)
cat("Total number of MRNs =", length(mrn), "!")