#!/usr/bin/env Rscript

# `write-wfdb2mrn` writes a table of MRNs and WFDB IDs

# Setup ----

cat("Plan for Writing MRNs from WFDB Files:\n\n")

# Libraries
library(fs)
library(dplyr)
library(vroom)
library(readr)
library(foreach)

# Paths
home <- fs::path_expand("~")
main <- fs::path("projects", "cbcd")
wfdb <- fs::path(home, main, "data", "wfdb")

# Setup parallelization
nCPU <- parallel::detectCores()
doParallel::registerDoParallel(cores = nCPU)
cat("\tAttempt parallelization with", nCPU, "cores\n")

# Create MRN list in WFDB folder
mrnFile <- fs::path(wfdb, 'mrn', ext = 'log')
if (!fs::file_exists(mrnFile)) {
	fs::file_create(mrnFile)
	readr::write_lines("MRN\tMUSE_ID", file = mrnFile)
}

# All files in each folder
mrnList <-
	fs::dir_ls(wfdb, recurse = 1, type = "file", glob = "*.hea") |>
	na.omit() |>
	unique()
n <- length(mrnList)

out <- foreach(i = 1:n, .combine = 'rbind', .errorhandling = 'remove') %dopar% {

	header <- vroom::vroom_lines(mrnList[i])
	mrn <-
		grep("\\bmrn\\b", header, ignore.case = TRUE, value = TRUE) |>
		gsub("\\D", "", x = _) |>
		as.integer()

	fn <-
		fs::path_file(mrnList[i]) |>
		fs::path_ext_remove()

	# Return for binding)
	cbind(MRN = mrn, MUSE_ID = fn)
}

cat("\tCompleted writing", n, "MRN and MUSE_IDs to file\n")
