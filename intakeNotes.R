#!/usr/bin/env Rscript

library(tidyverse)
library(data.table)
library(foreach)
library(fs)
library(doMC)
readr::write_lines("Loaded libraries\n", file = "notes.txt")

# Get SLURM variable
numCPU <-
	Sys.getenv("SLURM_CPUS_PER_TASK") |>
	as.numeric()
readr::write_lines(paste(numCPU, "CPUs available\n"), file = "notes.txt", append = TRUE)

# Register number of CPUs available
registerDoMC(cores = numCPU)

# From PWD, data should be in data folder
fileNames <- fs::dir_ls("data/ccts/raw", glob = "*.csv")
numFiles <- length(fileNames)
readr::write_lines(paste(numFiles, "files to analyze\n"), file = "notes.txt", append = TRUE)

foreach(i = 1:numFiles) %dopar% {
	x <- fread(fileNames[i], nrows = 100)
	fwrite(x, file = fileNames[i])
}

readr::write_lines("Files are now written in main folder", file = "notes.txt", append = TRUE)