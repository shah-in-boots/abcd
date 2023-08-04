#!/usr/bin/env Rscript

# `write-wfdb2mrn` writes a table of MRNs and WFDB IDs
# It works as a batch script and takes an external argument
# Arguments
# 	1st = SLURM_ARRAY_JOB_ID
#		2nd = SLURM_ARRAY_TASK_COUNT

# Setup ----

cat("Plan for Writing MRNs from WFDB Files:\n\n")

# Libraries
library(shiva)
library(fs)
library(dplyr)
library(vroom)
library(readr)
library(foreach)

# Arguments
# 	1st = SLURM_ARRAY_JOB_ID
#		2nd = SLURM_ARRAY_TASK_COUNT
args <- commandArgs(trailingOnly = TRUE)
taskNumber <- as.character(args[1]) # Example... 3rd job
taskCount <- as.integer(args[2]) # Total array jobs will be the number of nodes
cat("\tBatch array job number", taskNumber, "out of", taskCount, "array jobs total\n")

# Paths
home <- fs::path_expand("~")
main <- fs::path("projects", "cbcd")
wfdb <- fs::path(home, main, "data", "wfdb")

# Batch Preparation ----

# Number of files to be split into ~ equivalent parts
inputData <- fs::dir_ls(wfdb, recurse = TRUE, type = 'file', ext = 'hea')

# Create splits for batching
splitData <-
	split(inputData, cut(seq_along(inputData), taskCount, labels = FALSE))
chunkData <- splitData[[taskNumber]]
cat("\tWill consider", length(chunkData), "WFDB files in this batch\n")

# Create MRN list in WFDB folder
mrnFile <- fs::path(wfdb, 'mrn', ext = 'log')
if (!fs::file_exists(mrnFile)) {
	fs::file_create(mrnFile)
	readr::write_lines("MRN\tMUSE_ID", file = mrnFile)
}

n <- length(chunkData)
for (i in 1:n) {

	header <- vroom::vroom_lines(chunkData[i])

	mrn <-
		grep("\\bmrn\\b", header, ignore.case = TRUE, value = TRUE) |>
		gsub("\\D", "", x = _) |>
		as.integer()

	fn <- 
		fs::path_file(chunkData[i]) |>
		fs::path_ext_remove()

	readr::write_lines(x = paste0(mrn, "\t", fn), 
										 file = mrnFile, 
										 append = TRUE)

}

cat("\tCompleted writing", n, "MRN and MUSE_IDs to file\n")
