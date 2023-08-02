#!/usr/bin/env Rscript

# `convert-xml2wfdb.R` converts MUSE XML files to WFDB compatibile binaries
# This is written as *.dat and *.hea files
# This will be written, for organizational purposes into a folder by YEAR
# Allows for bathc processing with SLURM
# The logging files for both MUSE and WFDB are similar, and have 2 columns
# 	FOLDER
# 	MUSE_ID

# Setup ----

# Libraries
library(shiva)
library(readr)
library(fs)
library(foreach)
library(parallel)
library(doParallel)

# Setup parallelization
cat("Setup for processing of XML into WFDB files:\n\n")
nCPU <- parallel::detectCores()
doParallel::registerDoParallel(cores = nCPU)
cat("\tAttempting parallelization with", nCPU, "cores\n")

# Arguments
args <- commandArgs(trailingOnly = TRUE)
folderName <- as.character(args[1])
cat("\tWorking in the", folderName, "folder\n")

# Paths
home <- fs::path_expand("~")
main <- fs::path("projects", "cbcd")
inputFolder <- fs::path(home, main, "data", "muse", folderName)

# MUSE preparation ----
cat("Preparing MUSE data:\n\n")

# Check MUSE contents first
museLogFile <- fs::path(home, main, "data", "muse", "muse.log")

if (!fs::file_exists(museLogFile)) {
	fs::file_create(museLogFile)
}

# Update log as needed
museLogData <- readr::read_lines(museLogFile)
cat("\tCurrently there are", length(museLogData), "files in the MUSE log\n")

# Get names of XML files
xmlFiles <- fs::dir_ls(inputFolder, glob = "*.xml")
xmlNames <-
	xmlFiles |>
	fs::path_file() |>
	fs::path_ext_remove()

# Current MUSE data in path
currentMuseData <- xmlNames

# Update if needed
updatedMuseData <- setdiff(currentMuseData, museLogData)
readr::write_lines(updatedMuseData, file = museLogFile, append = TRUE)
cat("\tAdding", length(updatedMuseData), "files to MUSE log\n")

# WFDB preparation ----

cat("\nPreparing WFDB data:\n\n")
wfdbLogFile <- fs::path(home, main, "data", "wfdb", "wfdb.log")

if (!fs::file_exists(wfdbLogFile)) {
	fs::file_create(wfdbLogFile)
}

# Read overall log file
wfdbLogData <- readr::read_lines(wfdbLogFile)
cat("\tCurrently there are",
		length(wfdbLogData),
		"files in the overall WFDB log\n")

# Only need to add files that are new from MUSE
newMuseData <- setdiff(currentMuseData, wfdbLogData)

cat("\tThere are", length(newMuseData), "new files that can be converted to WFDB format\n")

# Conversion from XML to WFDB ----

# Create mini log for this run of parallel function
fileNames <- na.omit(newMuseData)
n <- length(fileNames)

# Make sure parallel is set up earlier
# Also place everything into correct "folder" by YEAR
convertedFiles <-
	foreach(i=1:n, .combine = 'c') %dopar% {
		fp <- fs::path(inputFolder, fileNames[i], ext = "xml")

		ecg <- shiva::read_muse(fp)
		sig <- vec_data(ecg)
		hea <- attr(ecg, "header")

		# Get year
		year <-
			hea$start_time |>
			clock::get_year()

		yearFolder <- fs::path(home, main, "data", "wfdb", year)

		# Create folder if needed
		if (!fs::dir_exists(yearFolder)) {
			fs::dir_create(yearFolder)
		}

		shiva::write_wfdb(
			data = sig,
			type = "muse",
			record = fileNames[i],
			record_dir = yearFolder,
			header = hea
		)

		vroom::vroom_write_lines(fileNames[i], wfdbLogFile, append = TRUE)
		cat("\tWrote the file", fileNames[i], "into the", year, "folder\n")

		# "Return value"
		fileNames[i]
	}

cat("\tA total of", length(convertedFiles), "were added to the WFDB log\n")

