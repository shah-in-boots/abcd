#!/usr/bin/env Rscript

library(tidyverse)
library(data.table)
library(fs)
library(doMC)
library(foreach)
write_lines("Loaded libraries\n", file = "notes.txt")

# Which folder will be used
user <- Sys.info()['user']
if (user == "ashah282") {
	main <- "data"
} else if (user == "asshah4") {
	main <- "tests"
}
write_lines(paste("'", user, "'", "account utilized\n"), file = "notes.txt", append = TRUE)

# Get number of computer cores available (essentially CPUs)
numCPU <-
	Sys.getenv("SLURM_CPUS_PER_TASK") |>
	as.numeric()
if (is.na(numCPU)) {
	numCPU <- parallel::detectCores()
}
write_lines(paste(numCPU, "CPUs available\n"), file = "notes.txt", append = TRUE)

# From PWD, data should be in data folder
filePaths <- fs::dir_ls(fs::path(main, "ccts", "raw"), glob = "*.csv")
fileNames <- fs::path_file(filePaths) 
numFiles <- length(fileNames)
write_lines(paste(numFiles, "files to analyze:\n"), file = "notes.txt", append = TRUE)
write_lines(paste("\tFile = ", filePaths, "\n"), file = "notes.txt", append = TRUE)

# Register cores
doMC::registerDoMC(cores = numCPU)
write_lines("Registering cores...\n", file = "notes.txt", append = TRUE)

# Foreach loop which will run on the different cores
foreach (i = 1:numFiles) %dopar% {
	# Reconstruct new path
	x <- fread(filePaths[i], nrows = 1000)
	fp <- fs::path(main, "ccts", "proc", fileNames[i])
	fwrite(x, file = fp)
	write_lines(paste(fileNames[i], " is being written\n"), file = "notes.txt", append = TRUE)
}

write_lines("Files are now written in main folder", file = "notes.txt", append = TRUE)
