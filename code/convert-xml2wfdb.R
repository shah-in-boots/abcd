#!/usr/bin/env Rscript

# `convert-xml2wfdb.R` converts MUSE XML files to WFDB compatibile binaries
# This is written as *.dat and *.hea files
# This will be written, for organizational purposes into a folder by YEAR
# Allows for batch processing with SLURM

# Setup ----

cat("Setup for processing of XML into WFDB files:\n\n")

# Libraries
library(EGM)
library(vroom)
library(fs)
library(foreach)
library(doParallel)
library(parallelly)
library(clock)
library(dplyr)
library(stringr)

# Arguments
# 	1st = SLURM_ARRAY_JOB_ID
#		2nd = SLURM_ARRAY_TASK_COUNT
args <- commandArgs(trailingOnly = TRUE)
taskNumber <- as.integer(args[1]) # Example... 3rd job
taskCount <- as.integer(args[2]) # Total array jobs will be the number of nodes
cat("\tBatch array job number", taskNumber, "out of", taskCount, "array jobs total\n")

# Setup parallelization
nCPU <- parallelly::availableCores() # DO NOT use detectCores(), will crash the cluster
doParallel::registerDoParallel(cores = nCPU)
cat("\tAttempting parallelization with", nCPU, "cores\n")

# Paths
home <- fs::path('/mmfs1','projects','cardio_darbar_chi') # correcting path
main <- fs::path("common") # correcting path
muse <- fs::path(home, main, "data", "muse")
wfdb <- fs::path(home, main, 'data', 'wfdb')

# Batch Preparation ----

# Number of files to be split into ~ equivalent parts
inputData <- vroom::vroom(fs::path(muse, 'muse', ext = 'log')) # issue with loading header as line 1 using vroom_lines

# Need to know which files have already been processed
logFile <- fs::path(wfdb, 'wfdb', ext = 'log') # changing to 'wfdb_raw' from 'wfdb' so it does not clash with full wfdb.log file created via write-wfdb2log.R
if (!fs::file_exists(logFile)) {
	fs::file_create(logFile)
}
logData <- vroom::vroom(logFile) # issue with loading header as line 1 using vroom_lines
cat("\tCurrently there are", nrow(logData), "files in the overall WFDB log\n")

# Only need to add files that are new from MUSE. # new: moving prior to split to distribute ECGs evenly across cores
if (nrow(logData) > 0) { # adding if statement due to issue with setdiff for empty variable
        newData <- inputData |> dplyr::filter(!MUSE_ID %in% logData$MUSE_ID)
} else {newData <- inputData}

cat("\tThere are", nrow(newData), "new files that can be converted to WFDB format\n")

# Create splits for batching
splitData <-
	split(newData, cut(seq_len(nrow(newData)), taskCount, labels = FALSE))
chunkData <- splitData[[taskNumber]]
cat("\tWill consider", nrow(chunkData), "XML files in this batch\n")

# Clear data and save room
rm(splitData, inputData)
gc()

# WFDB preparation ----
cat("\nPreparing WFDB data:\n\n")

# Conversion from XML to WFDB ----

# Need a list of all paths to evaluate # simplified file paths and names code 
#xmlPaths <-
#	fs::dir_ls(muse, recurse = TRUE, type = "file", glob = "*.xml")

filePaths <- fs::path(home,main,chunkData$PATH, ext = 'xml')
fileNames <- chunkData$MUSE_ID

n <- length(fileNames)

# Make sure parallel is set up earlier
# Also place everything into correct "folder" by YEAR
convertedFiles <-
	foreach(i = 1:n, .combine = 'c', .errorhandling = "remove") %do% {

		# Read in individual files
		fn <- fileNames[i]
		fp <- filePaths[i]

		ecg <- EGM::read_muse(fp)
		sig <- vec_data(ecg)
		hea <- ecg$header # attr(ecg, "header")

		# Get year
		year <-
			attributes(hea)$record_line$start_time |>
			clock::get_year()

		yearFolder <- fs::path(wfdb, year)

		# Create folder if needed
		if (!fs::dir_exists(yearFolder)) {
			fs::dir_create(yearFolder)
		}

		# Write wfdb files:
		EGM::write_wfdb(
			data = ecg,
			type = "muse",
			record = fn,
			record_dir = yearFolder,
		)

		# Write the file name and path to the WFDB log -----

		# Remove the starting terms in the absolute path:
		relative_path <- str_replace(fp, "^/mmfs1/projects/cardio_darbar_chi/common/", "")
		# Remove the file extension and preceeding path:
		final_path <- str_remove(relative_path, "\\.xml$")

		data_to_write <- data.frame(MUSE_ID = fn, PATH = final_path)

		vroom::vroom_write(data_to_write, 
					 file = logFile, 
					 delim = ",",
					 append = TRUE)
		
		#cat("\tWrote the file", fn, "into the", year, "folder\n")
		if (!i %% 500) {
			print(i)
			}

		# Return foreach to combine into vector
		fn
	}

cat("\tA total of", length(convertedFiles), "were added to the WFDB log\n")

