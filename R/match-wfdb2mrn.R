#!/usr/bin/env Rscript

# `match-wfdb2mrn` takes a list of MRNs and finds WFDB files that match
# Arguments:
# 	FILE PATH <character>
# 		Relative path name (e.g. sandbox/mrnList.txt) from ROOT folder
# 		List of MRNs -> will convert to integer 
#   	One MRN per row of text as how it will be read in
#   	No header or column names in this file
# 	FOLDER NAME <character> 
# 		Folder to place findings in
# 		Will be created if needed

# Setup ----

cat("Setup for MRN Search Amongst the WFDB Files:\n\n")

# Libraries
library(vroom)
library(fs)
library(dplyr)

# Arguments
# 	1st = FILE of MRNs as FULL PATH
#		2nd = NAME of FOLDER
args <- commandArgs(trailingOnly = TRUE)
mrnFile <- as.character(args[1]) 
folderName <- as.character(args[2]) 
cat("\tFile name is:" mrnFile, "\n")
cat("\tWill write to folder:", folderName, "\n")

# Paths
home <- fs::path_expand('~')
main <- fs::path('projects', 'cbcd')
wfdb <- fs::path(home, main, 'data', 'wfdb')

# MRN preparation ----

cat("\nReading in MRNs:\n\n")
mrnPath <- fs::path(home, main, mrnFile)
mrnData <- vroom::read_lines(mrnPath, col_types = "i")

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
	sapply(newData,
				 function(.x) {
				 	fs::path_filter(xmlPaths, regexp = .x)
				 },
				 USE.NAMES = FALSE) |>
	fs::as_fs_path()

fileNames <- fs::path_file(filePaths) |> fs::path_ext_remove()
n <- length(fileNames)

# Make sure parallel is set up earlier
# Also place everything into correct "folder" by YEAR
convertedFiles <-
	foreach(i = 1:n, .combine = 'c', .errorhandling = "remove") %do% {

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

