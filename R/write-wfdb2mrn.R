#!/usr/bin/env Rscript

# `write-wfdb2mrn` writes a table of MRNs and WFDB IDs

# Setup ----

cat("Plan for Writing MRNs from WFDB Files:\n\n")

# Libraries
library(shiva)
library(fs)
library(dplyr)
library(vroom)
library(readr)
library(foreach)

# Paths
home <- fs::path_expand("~")
main <- fs::path("projects", "cbcd")
wfdb <- fs::path(home, main, "data", "wfdb")


# Create MRN list in WFDB folder
mrnFile <- fs::path(wfdb, 'mrn', ext = 'log')
if (!fs::file_exists(mrnFile)) {
	fs::file_create(mrnFile)
	readr::write_lines("MRN\tMUSE_ID", file = mrnFile)
}

n <- length(chunkData)
foreach (i = 1:n, .combine = 'c', .errorhandling = 'remove') {

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

	fn

}

cat("\tCompleted writing", n, "MRN and MUSE_IDs to file\n")
