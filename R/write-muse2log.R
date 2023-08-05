#!/usr/bin/env Rscript

# `write-muse2log` writes a table log of the MUSE data with paths 
# Creates a table with two columns
# 	MUSE_ID <character>
# 	PATH <character> - defined by cluster location

cat("Plan for Writing MRN and Paths from MUSE Files!\n")

# Libraries
library(fs)
library(dplyr)
library(vroom)
library(readr)
library(foreach)

# Paths
home <- fs::path_expand("~")
main <- fs::path("projects", "cbcd")
muse <- fs::path(home, main, "data", "muse")

# Setup parallelization
nCPU <- parallel::detectCores()
doParallel::registerDoParallel(cores = nCPU)
cat("Attempt parallelization with", nCPU, "cores\n")

# Create log file
logFile <- fs::path(muse, 'muse', ext = 'log')

# All files in each folder
museList <-
	fs::dir_ls(muse, recurse = 1, type = "file", glob = "*.xml") |>
	na.omit() |>
	unique()
n <- length(museList)

cat("Expect to write out", n, "files\n")
out <-
	foreach(i = 1:n,
					.combine = 'rbind',
					.errorhandling = "remove") %dopar% {
						xml <- fs::as_fs_path(museList[i])

						fn <-
							fs::path_file(xml) |>
							fs::path_ext_remove()

						fp <-
							fs::path_ext_remove(xml) |>
							fs::path_rel(path = _, start = fs::path(home, main))


						cat("\tWill write MUSE_ID =", fn, "\n")

						# Return for binding
						cbind(MUSE_ID = fn, PATH = fp)
					}

# Write out the file
out |>
	as.data.frame() |>
	dplyr::distinct() |>
	vroom::vroom_write(
		file = logFile,
		delim = ",",
		col_names = TRUE,
		append = FALSE
	)

cat("\tCompleted writing", n, "MUSE_IDs and paths to log file\n")
