#!/usr/bin/env Rscript

# `match-diagnosis2mrn` should be run after converting XML to WFDB format
# It will create a list of MUSE ECGs based on an input file name.
# The input file must be a TSV with a column of MRNs included
# MRNs will then be sought out in the WFDB files.
#
# Outputs a directory file with... (similar to directory structure)
# 	FOLDER
# 	NAME (MUSE_ID)
# 	MRN
# 	DATE + TIME

# Libraries
library(readr)
library(stringr)
library(dplyr)
library(fs)
library(tibble)
library(collapse)

# General paths
home <- fs::path_expand("~")
main <- fs::path("projects", "cbcd")

# Input file = MRNs of interest to abstract
inputFile <- fs::path(home, main, "output", "ECG-AFibDiagnosis", ext = "tsv")
mrnFile <- readr::read_tsv(inputFile)
mrnData <- collapse::funique(mrnFile$MRN)

# Output file = Directory-like file of FOLDER, NAME, MRN, DATE, TIME
outputFile <- fs::path(home, main, "output", "ECG-PatientList", ext = "tsv")
readr::write_lines("FOLDER\tNAME\tMRN\tDATE\tTIME", file = outputFile)

# WFDB specific paths
wfdbDir <- fs::path(home, main, "data", "wfdb")
wfdbFolders <- fs::dir_ls(wfdbDir, type = "directory")
cat("Identified", length(wfdbFolders), "folders to search through\n")

# Now need to search through each folder for WFDB information
# Each MRN will be in a header file
# Have to see if it matches our subset list

# Go through all the folders one-by-one
for (i in seq_along(wfdbFolders)) {

	folderPath <- wfdbFolders[i]
	folderName <- fs::path_file(folderPath)

	cat("\tReading header files in", folderName, "\n")
	headerFiles <- fs::dir_ls(folderPath, glob = "*.hea")

	for (j in seq_along(headerFiles)) {

		header <- readr::read_lines(headerFiles[j])

		# Find MRN in header file
		mrn <-
			grep("\\bmrn\\b", header, ignore.case = TRUE, value = TRUE) |>
			gsub("\\D", "", x = _)

		if (length(mrn) > 1) {
			mrn <- mrn[1]
		} else if (length(mrn) == 0) {
			mrn <- "MISSING_MRN" # Unlikely to be present
		}

		if (mrn %in% mrnData) {

			# Name of file
			nm <-
				fs::path_file(headerFiles[j]) |>
				fs::path_ext_remove()

			# Date and time
			dt <- str_sub(header[1], start = -10)
			tm <- str_sub(header[1], start = -19, end = -12)

			row <- tibble::tibble(
				FOLDER = folderName,
				NAME = nm,
				MRN = mrn,
				DATE = dt,
				TIME = tm
			)

			readr::write_tsv(row, file = outputFile, append = TRUE)
			cat("\t\tFound appropriate MRN ... ", nm, "\n")

		}

	}

	cat("\tCompleted all the header files in", folderName, "\n\n")
}

