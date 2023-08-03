#!/usr/bin/env Rscript

# `convert-xml2wfdb.R` converts MUSE XML files to WFDB compatibile binaries
# This is written as *.dat and *.hea files
# This will be written, for organizational purposes into a folder by YEAR
# Allows for batch processing with SLURM

# Setup ----

cat("Setup for processing of XML into WFDB files:\n\n")

# Libraries
library(shiva)
library(vroom)
library(fs)
library(foreach)
library(parallel)
library(doParallel)

# Arguments
# 	1st = SLURM_ARRAY_JOB_ID
#		2nd = SLURM_ARRAY_TASK_COUNT
args <- commandArgs(trailingOnly = TRUE)
taskNumber <- as.character(args[1]) # Example... 3rd job
taskCount <- as.integer(args[2]) # Total array jobs will be the number of nodes
cat("\tBatch array job number", taskNumber, "out of", taskTotal, "array jobs total\n")

# Setup parallelization
nCPU <- parallel::detectCores()
doParallel::registerDoParallel(cores = nCPU)
cat("\tAttempting parallelization with", nCPU, "cores\n")

# Paths
home <- fs::path_expand('~')
main <- fs::path('projects', 'cbcd')
muse <- fs::path(home, main, 'data', 'muse')
wfdb <- fs::path(home, main, 'data', 'wfdb')

# Batch Preparation ----

# Number of files to be split into ~ equivalent parts
inputData <- vroom::vroom_lines(fs::path(muse, 'muse', ext = 'log'))
inputConfig <-
	vroom::vroom(
		fs::path(home, main, 'config-muse', ext = 'txt'),
		delim = '\t'
	)

# Create splits for batching
splitData <-
	split(inputData, cut(seq_along(inputData), taskCount, labels = FALSE))
chunkData <- splitData[[taskNumber]]
cat("\tWill consider", length(chunkData), "XML files in this batch\n")

# WFDB preparation ----

cat("\nPreparing WFDB data:\n\n")

# Need to know which files have already been processed
logFile <- fs::path(wfdb, 'wfdb', ext = 'log')
if (!fs::file_exists(logFile)) {
	fs::file_create(logFile)
}
logData <- vroom::vroom_lines(logFile)
cat("\tCurrently there are", length(logData), "files in the overall WFDB log\n")

# Only need to add files that are new from MUSE
newData <- setdiff(chunkData, logData)

cat("\tThere are", length(newData), "new files that can be converted to WFDB format\n")

# Conversion from XML to WFDB ----

# Need a list of all paths to evaluate
xmlPaths <-
	fs::dir_ls(muse, recurse = TRUE, type = "file", glob = "*.xml")

filePaths <-
	vapply(newData,
				 function(.x) {
				 	fs::path_filter(xmlPaths, regexp = .x)
				 },
				 USE.NAMES = FALSE,
				 FUN.VALUE = character(1)) |>
	fs::as_fs_path()

fileNames <- fs::path_file(filePaths) |> fs::path_ext_remove()
n <- length(fileNames)

# Make sure parallel is set up earlier
# Also place everything into correct "folder" by YEAR
convertedFiles <-
	foreach(i = 1:n, .combine = 'c', .errorhandling = "remove") %dopar% {

		# Read in individual files
		fn <- fileNames[i]
		fp <- filePaths[i]

		ecg <- shiva::read_muse(fp)
		sig <- vec_data(ecg)
		hea <- attr(ecg, "header")

		# Get year
		year <-
			hea$start_time |>
			clock::get_year()

		yearFolder <- fs::path(wfdb, year)

		# Create folder if needed
		if (!fs::dir_exists(yearFolder)) {
			fs::dir_create(yearFolder)
		}

		shiva::write_wfdb(
			data = sig,
			type = "muse",
			record = fn,
			record_dir = yearFolder,
			header = hea
		)

		vroom::vroom_write_lines(fn, file = logFile, append = TRUE)
		cat("\tWrote the file", fn, "into the", year, "folder\n")

		# Return foreach to combine into vector
		fn
	}

cat("\tA total of", length(convertedFiles), "were added to the WFDB log\n")

