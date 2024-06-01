#!/usr/bin/env Rscript

# `copy-mrn2wfdb` takes a list of MRNs and copies WFDB files that match. Will use an array system to help with job batching.
#
# Output:
# 	Creates a folder named by the ARG of WFDB files
# 	Will obtain all WFDB data, header, and annotations files
# Arguments:
# 	FILE PATH <character>
# 		Relative path name (e.g. sandbox/mrnList.csv) from ROOT folder
# 		This will be read in as a CSV file preferentially
# 		Requires there be a column named "mrn" (lower case) to select from
# 	FOLDER NAME <character>
# 		Folder to place findings in
# 		Will be created if needed
# 		Assumed to be in the WFDB folder
# 	SLURM_ARRAY_JOB_ID <integer>
# 		Task Number to pass forward for batching
#		SLURM_ARRAY_TASK_COUNT <integer>
#			Total number of tasks to help with batching
#			Needed to help divide number of jobs

# Setup ----

cat("Setup for MRN Search Amongst the WFDB Files!")

# Libraries
library(vroom)
library(fs)
library(dplyr)
library(parallel)
library(foreach)

# Arguments
# 	1st = FILE of MRNs as FULL PATH
#		2nd = NAME of FOLDER
args <- commandArgs(trailingOnly = TRUE)
mrnFile <- as.character(args[1]) # File holding Mrns
folderName <- as.character(args[2]) # output folder
taskNumber <- as.character(args[3]) # Task number or ID from slurm
taskCount <- as.integer(args[4]) # Total array jobs will be the number of nodes
cat("\tFile name is:", mrnFile, "\n")
cat("\tWill write to folder:", folderName, "\n")
cat("\tBatch array job number:", taskNumber, "\n")
cat("\tTotal number of array jobs:", taskCount, "\n")

# Paths
home <- fs::path_expand('~')
main <- fs::path('projects', 'cbcd')
wfdb <- fs::path(home, main, 'data', 'wfdb')

# Setup parallelization
nCPU <- parallel::detectCores()
doParallel::registerDoParallel(cores = nCPU)
cat("Attempt parallelization with", nCPU, "cores\n")

# I/O ----

# MRN data
cat("\nPreparing input and output data:\n\n")
mrnData <-
	fs::path(home, main, mrnFile) |>
	vroom::vroom(delim = ",") |>
	dplyr::select(mrn) |>
	dplyr::distinct() |>
	janitor::clean_names() |>
	dplyr::mutate(mrn = as.numeric(mrn)) # Make MRN numeric
cat("\tThere are", nrow(mrnData), "MRNs to evaluate\n")

# Output folder
outputFolder <- fs::path(wfdb, folderName)
if (!fs::dir_exists(outputFolder)) {
	fs::dir_create(outputFolder)
}
cat("\tOutput location:", outputFolder, "\n")

# Batch Preparation ----

cat("\nBatch preparation:\n\n")
# Number of files to be split into ~ equivalent parts
logFile <- fs::path(wfdb, 'wfdb', ext = 'log')
l <-
	system2(command = 'wc',
					args = paste('-l', logFile),
					stdout = TRUE) |>
	readr::parse_number() |>
	{\(.x) .x - 1 }() # Subtract off header
lineNumbers <- 1:l
cat("\tNumber of lines in log:", l, "\n")

# Create splits of the line numbers
lineSplits <-
	split(lineNumbers, cut(seq_along(lineNumbers), taskCount, labels = FALSE))
chunk <- lineSplits[[taskNumber]]
cat("\tNumber of lines to read in in this batch:", length(chunk), "\n")

# Reading in the data
# This is just a subset to reduce file size
logData <-
	vroom::vroom(
		file = logFile,
		col_names = c("MRN", "MUSE_ID", "PATH"),
		skip = min(chunk, na.rm = TRUE),
		n_max = length(chunk)
	) |>
	janitor::clean_names() |>
	mutate(mrn = as.numeric(mrn))

cat("\tJust read in", nrow(logData), "lines of data from the log\n")

# Match WFDB Files ----

cat("\nCopy files over to new folder:\n\n")

# Filter down log table to relevant MRNs
batchData <- inner_join(mrnData, logData, by = "mrn")
n <- nrow(batchData)
cat("\tExpect to move over", n, "files\n")

foreach(i = 1:n, .combine = 'c', .errorhandling = 'remove') %dopar% {

	fn <- as.character(batchData[i, 3])

	fp <-
		fs::path(home, main, batchData[i, 3]) |>
		fs::path_dir()

	files <- fs::dir_ls(fp, regexp = fn)

	fs::file_copy(path = files, new_path = outputFolder, overwrite = TRUE)

	if (length(files) >= 1) {
		cat("\tCopying:", fn, "\n")
	}

}

