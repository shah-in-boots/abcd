#!/usr/bin/env Rscript

# `write-wfdb2log` writes a table log of the WFDB dataset
# Creates a table with three columns
# 	MRN <integer>
# 	MUSE_ID <character>
# 	PATH <character> - defined by cluster location

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

# All files in each folder
mrnList <-
	fs::dir_ls(wfdb, recurse = 1, type = "file", glob = "*.hea") |>
	na.omit() |>
	unique()
n <- length(mrnList)

cat("Expect to write out", n, "files\n")
out <-
	foreach(i = 1:n,
					.combine = 'rbind',
					.errorhandling = "remove") %dopar% {
						header <- vroom::vroom_lines(mrnList[i])
						mrn <-
							grep("\\bmrn\\b",
									 header,
									 ignore.case = TRUE,
									 value = TRUE) |>
							gsub("\\D", "", x = _) |>
							as.integer()

						fn <-
							fs::path_file(mrnList[i]) |>
							fs::path_ext_remove()

						fp <-
							fs::path_ext_remove(mrnList[i]) |>
							fs::path_rel(path = _, start = fs::path(home, main))

						cat("\tWill write... MRN =", mrn, "and MUSE_ID =", fn, "\n")

						# Return for binding
						cbind(MRN = mrn, MUSE_ID = fn, PATH = fp)
					}

# Write out the file
out |>
	as.data.frame() |>
	dplyr::distinct() |>
	vroom::vroom_write(
		file = mrnFile,
		delim = ",",
		col_names = TRUE,
		append = FALSE
	)

cat("\tCompleted writing", n, "MRN and MUSE_IDs to file\n")
