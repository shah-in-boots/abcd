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
# options(wfdb_path = '/mmfs1/home/dseaney2/wfdb/bin') # can also add 'source $HOME/.bashrc' to .sh file before R script 
source("/mmfs1/projects/cardio_darbar_chi/common/data/custom_install_code/wfdb-annotation-temp.R") # temp corrected code

# Arguments
# 	1st = SLURM_ARRAY_JOB_ID
#		2nd = SLURM_ARRAY_TASK_COUNT
args <- commandArgs(trailingOnly = TRUE)
taskNumber <- as.integer(args[1]) # Example... 3rd job
taskCount <- as.integer(args[2]) # Total array jobs will be the number of nodes
cat("\tBatch array job number", taskNumber, "out of", taskCount, "array jobs total\n")

# Setup parallelization
nCPU <- parallelly::availableCores()
doParallel::registerDoParallel(cores = nCPU)
cat("\tAttempting parallelization with", nCPU, "cores\n")

# Paths
home <- fs::path('/mmfs1/projects/cardio_darbar_chi/common/')
wfdb <- fs::path(home, "data", "wfdb")
muse <- fs::path(home, "data", "muse")

# Batch Preparation ----

# Number of files to be split into ~ equivalent parts
inputData <- read.csv(fs::path(wfdb, 'wfdb', ext = 'log'))
# Need to swap old file name contained with in $PATH to the new file name
inputData$PATH <- fs::path(dirname(inputData$PATH),inputData$FILE_NAME)

# Create splits for batching
splitData <- split(inputData, cut(1:nrow(inputData), taskCount, labels = FALSE))
chunkData <- splitData[[taskNumber]]
cat("\tWill consider", nrow(chunkData), "WFDB files in this batch\n")

# Clean up potentially large vectors
rm(inputData, splitData)
gc()

# WFDB Preparation ----

cat("\nPreparing WFDB data for annotation:\n\n")

# Log file information
logFile <- fs::path(wfdb, 'ecgpuwave', ext = 'log')
if (!fs::file_exists(logFile)) { # create new file if needed
	fs::file_create(logFile)
	logData <- data.frame(MUSE_ID = character(),
			      PATH = character(),
			      FILE_NAME = character(),
			      stringsAsFactors = FALSE)  # Avoid converting character columns to factors
} else {logData <- read.csv(logFile)}

cat("\tCurrently there are", nrow(logData), "files in the ECGPUWAVE log\n")

# Only need to annotate those that have not yet been done
newData <- chunkData |> dplyr::filter(!FILE_NAME %in% logData$FILE_NAME)
cat("\tThere are", nrow(newData), "WFDB files that can be annotated\n")

start <- 1
# end <- nrow(newData)
end <- 10

# Make sure parallel is set up earlier
# Also place everything into correct "folder" by YEAR
out <-
	foreach(i = start:end, .combine = 'rbind', .errorhandling = "remove") %do% {

		if (end > 0) {
			# Read in individual files and locations
			fn <- newData$FILE_NAME[i]
			fp <- fs::path(home,newData$PATH[i])
			fd <- fs::path_dir(fp)
			year <- fs::path_split(fd)[[1]] |> dplyr::last()

			annotate_wfdb(
				record = fn,
				record_dir = fd,
				annotator = "ecgpuwave"
			)


			# Move file to correct folder
			old_path <- newData$PATH[i]
			new_path <- gsub("wfdb", "ecgpuwave", old_path)
			file.rename(from=fs::path(home,old_path,ext='ecgpuwave'),
				    to=fs::path(home,new_path,ext='ecgpuwave'))
			
			# vroom::vroom_write_lines(fn, logFile, append = TRUE)
			cat("\tWrote the file", fn, "into the", year, "folder\n")

			# "Return new row"
			
			if (file.exists(fs::path(home,new_path,ext='ecgpuwave'))) {
			data.frame(
				MUSE_ID = newData$MUSE_ID[i],
				PATH = new_path,
				FILE_NAME = fn,
				stringsAsFactors = FALSE
				)
				}
		}
	}

out |>
#  as.data.frame() |>
  dplyr::distinct() |>
  vroom::vroom_write(
    file = logFile,
    delim = ",",
    col_names = FALSE,
    append = TRUE
  )

cat("\tA total of", nrow(out), "were added to the ECGPUWAVE log\n")


