#!/usr/bin/env Rscript

# `annotate-wfdb2qrs` can be run on a folder full of WFDB formatted ECGs
# The command requires a folder to process the QRS data for
# It routes through the ECGPUWAVE algorithm (Pan Tompkins)
# It works as a batch script and takes an external argument

# Setup ----

cat("Setup for annotation of WFDB files:\n\n")

# Libraries
library(EGM)
library(fs)
library(dplyr)
library(vroom)
library(foreach)
library(parallelly)
library(doParallel)
options(wfdb_path = '/mmfs1/home/dseaney2/wfdb/bin') # can also add 'source $HOME/.bashrc' to .sh file before R script 

# Arguments
# 	1st = SLURM_ARRAY_JOB_ID
#		2nd = SLURM_ARRAY_TASK_COUNT
args <- commandArgs(trailingOnly = TRUE)
taskNumber <- as.character(args[1]) # Example... 3rd job
taskCount <- as.integer(args[2]) # Total array jobs will be the number of nodes
cat("\tBatch array job number", taskNumber, "out of", taskCount, "array jobs total\n")

# Setup parallelization
nCPU <- parallelly::availableCores()
doParallel::registerDoParallel(cores = nCPU)
cat("\tAttempting parallelization with", nCPU, "cores\n")

# Paths
home <- fs::path('/mmfs1/projects/cardio_darbar_chi/common/data')
# main <- fs::path("data")
wfdb <- fs::path(home, "wfdb")

# Batch Preparation ----

# Number of files to be split into ~ equivalent parts
inputData <- read.csv(fs::path(wfdb, 'wfdb', ext = 'log'))

# Create splits for batching
splitData <-
	split(inputData, cut(seq_along(inputData), taskCount, labels = FALSE))
chunkData <- splitData[[taskNumber]]
cat("\tWill consider", nrow(chunkData), "WFDB files in this batch\n")

# Clean up potentially large vectors
rm(inputData, splitData)
gc()

# WFDB Preparation ----

cat("\nPreparing WFDB data for annotation:\n\n")

# Log file information
logFile <- fs::path(wfdb, 'ecgpuwave', ext = 'log')
if (!fs::file_exists(logFile)) {
	fs::file_create(logFile)
}
logData <- vroom::vroom_lines(logFile)
cat("\tCurrently there are", length(logData), "files in the ECGPUWAVE log\n")

# Only need to annotate those that have not yet been done
newData <- setdiff(chunkData, logData)
cat("\tThere are", length(newData), "WFDB files that can be annotated\n")


# Annotation ----

fs::file_delete(fs::dir_ls(wfdb, recurse = TRUE, glob = "*.ecgpuwave"))

# Need a list of all paths to evaluate
wfdbPaths <-
	fs::dir_ls(wfdb, recurse = TRUE, type = "file", glob = "*.dat")

filePaths <-
	sapply(newData,
				 function(.x) {
				 	fs::path_filter(wfdbPaths, regexp = .x)
				 },
				 USE.NAMES = FALSE) |>
	fs::as_fs_path()

fileNames <- fs::path_file(filePaths) |> fs::path_ext_remove()
n <- length(fileNames)

# Make sure parallel is set up earlier
# Also place everything into correct "folder" by YEAR
annotatedFiles <-
	foreach(i = 1:n, .combine = 'c', .errorhandling = "remove") %do% {

		if (n > 0) {
			# Read in individual files and locations
			fn <- fileNames[i]
			fp <- filePaths[i]
			fd <- fs::path_dir(fp)
			year <- fs::path_split(fd)[[1]] |> dplyr::last()

			EGM::read_annotation(
				record = fn,
				record_dir = fd,
				detector = "ecgpuwave"
			)

			vroom::vroom_write_lines(fn, logFile, append = TRUE)
			cat("\tWrote the file", fn, "into the", year, "folder\n")

			# "Return value"
			fn
		}
	}

cat("\tA total of", length(annotatedFiles), "were added to the ECGPUWAVE log\n")
