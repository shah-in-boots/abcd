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
library(parallel)

# Setup parallelization
cat("Setup for processing of XML into WFDB files:\n\n")
nCPU <- parallel::detectCores()
cat("\tAttempting paralellization with", nCPU, "cores\n")

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
museLogFile <- fs::path(home, main, "data", "muse", "log.txt")

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
wfdbLogFile <- fs::path(home, main, "data", "wfdb", "log.txt")

if (!fs::file_exists(wfdbLogFile)) {
	fs::file_create(wfdbLogFile)
}

# Update log as needed
wfdbLogData <- readr::read_lines(wfdbLogFile)
cat("\tCurrently there are", length(wfdbLogData), "files in the WFDB log\n")

# Only need to add files that are new from MUSE
newMuseData <- setdiff(currentMuseData, wfdbLogData)

cat("\tThere are", length(newMuseData), "new files that can be converted to WFDB format\n")

# Conversion from XML to WFDB ----

fileNames <- na.omit(newMuseData)

# Make sure parallel is set up earlier
# Also place everything into correct "folder" by YEAR
convertedFiles <- parallel::mclapply(
	X = fileNames,
	FUN = function(.x) {

		fp <- fs::path(inputFolder, .x, ext = "xml")

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
			record = .x,
			record_dir = yearFolder,
			header = hea
		)

		readr::write_lines(.x, wfdbLogFile, append = TRUE)
		cat("\tWrote the file", .x, "into the", year, "folder\n")

		# "Return value"
		.x
	}
)

cat("\tA total of", length(convertedFiles), "were added to the WFDB log\n")

