#!/usr/bin/env Rscript

# `find-mrnByWfdbDx` extracts MRNs from WFDB files based on a diagnosis
#
# Create a list of MRNs and corresponding ECG (MUSE_ID) of that diagnosis. Takes
# four arguments as described below
#
# Arguments [4]:
# 	REGEX <file>
# 		Path to file with each line containing appropriate regex options
# 		Assumes that path is from project home (e.g. ~/projects/cbcd/.)
# 		Each line is a regex option that would return potential diagnoses
# 		Will add appropriate escapes when reading in (don't need double escapes)
# 		These are considered in L1 OR L2 OR L3 fashion (for each line)
# 	OUTPUT <file>
# 		Path to output file and name of it
# 		Assumes that path is from project home (e.g. ~/projects/cbcd/.)
# 	SLURM_ARRAY_JOB_ID <integer>
# 		Task Number to pass forward for batching
#		SLURM_ARRAY_TASK_COUNT <integer>
#			Total number of tasks to help with batching
#			Needed to help divide number of jobs
#
# Output [1]:
# 	TXT <file>
# 		Creates a TEXT file with 1 MRN per LINE

# Setup ----

cat('Will find MRN by a WFDB diagnosis!\n\n')

# Libraries
library(readr)
library(stringr)
library(dplyr)
library(fs)
library(tibble)
library(vroom)
library(parallel)
library(foreach)

# Paths
home <- fs::path_expand('~')
main <- fs::path('projects', 'cbcd')
wfdb <- fs::path(home, main, 'data', 'wfdb')

# Handle arguments
args <- commandArgs(trailingOnly = TRUE)
regexArg <- as.character(args[1])
outputArg <- as.character(args[2])
taskNumber <- as.integer(args[3]) # Task number or ID from slurm
taskCount <- as.integer(args[4]) # Total array jobs will be the number of nodes
cat('\tRegex file name is:', regexArg, '\n')
cat('\tWill write to file:', outputArg, '\n')
cat('\tBatch array job number:', taskNumber, '\n')
cat('\tTotal number of array jobs:', taskCount, '\n')

# Parallel...
nCPU <- parallel::detectCores()
doParallel::registerDoParallel(cores = nCPU)
cat("Attempt parallelization with", nCPU, "cores\n")

# I/O ----

cat('\nHandling the inputs & outputs:\n')

# REGEX options
regexData <-
	readr::read_lines(fs::path(home, main, regexArg)) |>
	paste0(collapse = '|')
cat('\tCreating regex parsing options\n')

# Output file
outputFile <- fs::path(home, main, outputArg)
if (!fs::file_exists(outputFile)) {
	readr::write_lines('MRN,MUSE_ID,DATE,TIME',
										 file = outputFile)
	cat('\tCreating output file at...', outputFile, '\n')
} else {
	cat('\tWill append to...', outputFile, '\n')
}

# Batch Prep ----

cat('\nBatch preparation:\n')

# Input files from WFDB log
cat('\tReading in the WFDB files from the `wfdb.log`\n')
log <-
	fs::path(wfdb, 'wfdb', ext = 'log') |>
	vroom::vroom(delim = ',')
l <- nrow(log)
cat('\tThere are', l, 'WFDB paths to process\n')

# Setup batching splits
lineNumbers <- 1:l
lineSplits <-
	split(lineNumbers, cut(seq_along(lineNumbers), taskCount, labels = FALSE))
chunk <- lineSplits[[taskNumber]]
chunkData <-
	log[chunk, ] |>
	dplyr::mutate(HEADER = fs::path(home, main, PATH, ext = 'hea')) |>
	dplyr::pull(HEADER) |>
	as.character() |>
	na.omit()
cat('\tThere are', length(chunkData), 'paths to process in this batch\n')

# Diagnosis ----

n <- length(chunkData)
out <- foreach(i = 1:n, .combine = 'c', .errorhandling = 'remove') %dopar% {

	# Header
	header <- readr::read_lines(chunkData[i])

	# Diagnosis to search for
	dx <- grepl(regexData, header[grep('diagnosis', header)], ignore.case = TRUE)

	# If found, than get the MRN and write to file
	if (dx) {

		fn <-
			fs::path_file(chunkData[i]) |>
			fs::path_ext_remove()

		mrn <-
			grep('\\bmrn\\b',
					 header,
					 ignore.case = TRUE,
					 value = TRUE) |>
			gsub('\\D', '', x = _)

		readr::write_lines(mrn, file = outputFile, append = TRUE)

		cat('\tFound diagnosis in', fn, '\n')

		# Return
		fn
	}
}

# Final count
cat('\nTotal number of MRNs found =', length(out), '!')
