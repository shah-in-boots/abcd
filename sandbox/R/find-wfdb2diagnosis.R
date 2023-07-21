#!/usr/bin/env Rscript

# `find-wfdb2diagnosis` should be run after converting XML to WFDB format
# It will create a list of MUSE ECGs that have a certain diagnosis or parameter
# Outputs a file with a list of these MUSE files in a CSV format
# 	MUSE_ID
# 	MRN
# 	DATE + TIME


# Libraries
library(readr)
library(stringr)
library(dplyr)
library(fs)
library(tibble)

# Paths
home <- fs::path_expand("~")
main <- fs::path("projects", "cbcd", "sandbox")

# WFDB specific
wfdbDir <- fs::path(home, main, "data", "wfdb")
wfdbFolders <- fs::dir_ls(wfdbDir, type = "directory")
cat("Identified", length(wfdbFolders), "folders to search through\n")

# Get AF regex options via sourcing script from project directory
source(fs::path(home, "projects", "cbcd", "regex.R"))
af_regex <- paste0(af_regex, collapse = "|")
afibDiagnosis <- fs::path(home, main, "output", "ECG-AFDiagnosis", ext = "tsv")
readr::write_lines("NAME\tMRN\tDATE\tTIME", file = afibDiagnosis)

# Go through all the folders one-by-one
for (i in seq_along(wfdbFolders)) {

	folderPath <- wfdbFolders[i]
	folderName <- fs::path_file(folderPath)

	cat("\tReading header files in", folderName, "\n")
	headerFiles <- fs::dir_ls(folderPath, glob = "*.hea")

	for (j in seq_along(headerFiles)) {

		header <- readr::read_lines(headerFiles[j])
		af <- grepl(af_regex, header, ignore.case = TRUE)

		# Save a file with the key information
		if (any(af)) {



			# File name
			fn <-
				fs::path_file(headerFiles[j]) |>
				fs::path_ext_remove()

			# MRN
			mrn <-
				grep("\\bmrn\\b", header, ignore.case = TRUE, value = TRUE) |>
				gsub("\\D", "", x = _)

			# Date/Time
			dt <- str_sub(header[1], start = -10)
			tm <- str_sub(header[1], start = -19, end = -12)

			row <- tibble::tibble(fn, mrn, dt, tm)

			write_tsv(row, file = afibDiagnosis, append = TRUE)
			cat("\t\tFound AF diagnosis ... ", fn, "\n")

		}

	}
	cat("\tCompleted all the header files in", folderName, "\n\n")
}

