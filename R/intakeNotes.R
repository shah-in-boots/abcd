#!/usr/bin/env Rscript

library(tidyverse)
library(data.table)
library(fs)
library(doMC)
library(foreach)
readr::write_lines("Loaded libraries\n", file = "notes.txt")

# Which folder will be used
user <- Sys.info()['user']
if (user == "ashah282") {
	folder <- "data"
} else if (user == "asshah4") {
	folder <- "tests"
}
readr::write_lines(paste("'", user, "'", "account utilized\n"), file = "notes.txt", append = TRUE)

# Get number of computer cores available (essentially CPUs)
numCPU <-
	Sys.getenv("SLURM_CPUS_PER_TASK") |>
	as.numeric()
if (is.na(numCPU)) {
	numCPU <- parallel::detectCores()
}
readr::write_lines(paste(numCPU, "CPUs available\n"), file = "notes.txt", append = TRUE)

# From PWD, data should be in data folder
fileNames <- fs::dir_ls(fs::path(folder, "ccts", "raw"), glob = "*.csv")
numFiles <- length(fileNames)
readr::write_lines(paste(numFiles, "files to analyze\n"), file = "notes.txt", append = TRUE)

# Register cores
doMC::registerDoMC(cores = numCPU)
readr::write_lines("Registering cores...\n", file = "notes.txt", append = TRUE)

# Foreach loop which will run on the different cores
foreach (i = 1:numFiles) %dopar% {
	x <- fread(fileNames[i])

	# Reconstruct new path
	fp <- fs::path(folder, "ccts", "proc", fs::path_file(fileNames[i]))
	fwrite(x, file = fp)
	readr::write_lines(paste(fileNames[i], " is being written\n"), file = "notes.txt", append = TRUE)
}

readr::write_lines("Files are now written in main folder", file = "notes.txt", append = TRUE)
