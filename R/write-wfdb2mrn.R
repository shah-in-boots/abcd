#!/usr/bin/env Rscript

# `write-wfdb2mrn` writes a table of MRNs and WFDB IDs

cat("Plan for Writing MRNs from WFDB Files!\n")

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
cat("Attempt parallelization with", nCPU, "cores\n")

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

cat("Expect to write out", n, "files\n")
out <- foreach(i = 1:n, .combine = 'rbind', .errorhandling = 'remove') %dopar% {

	header <- vroom::vroom_lines(mrnList[i])
	mrn <-
		grep("\\bmrn\\b", header, ignore.case = TRUE, value = TRUE) |>
		gsub("\\D", "", x = _) |>
		as.integer()

	fn <-
		fs::path_file(mrnList[i]) |>
		fs::path_ext_remove()

	cat("\tWill write... MRN =", mrn, "and MUSE_ID =", fn, "\n")

	# Return for binding)
	cbind(MRN = mrn, MUSE_ID = fn)
}

# Write out files
out |>
	as.data.frame() |>
	dplyr::distinct() |>
	vroom::vroom_write(file = mrnFile, append = TRUE)

cat("\tCompleted writing", n, "MRN and MUSE_IDs to file\n")
