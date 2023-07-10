#!/usr/bin/env Rscript

# Expect argument that is string variable
args <- commandArgs(trailingOnly = TRUE)
folderName <- as.character(args[1])

# Libraries
library(shiva)
library(readr)
library(fs)
library(foreach)
library(doParallel)

# Paths
home <- fs::path_expand("~")
main <- fs::path("projects", "cbcd")
inputFolder <- fs::path(home, main, "data", "muse", folderName)
outputFolder <- fs::path(home, main, "data", "wfdb", folderName)

# Create log file within folder
readr::write_lines(paste("LOG", folderName), file = fs::path(outputFolder, "log.txt"), append = FALSE)

# TODO temporarily shorten the number of files
filePaths <- fs::dir_ls(path = inputFolder, glob = "*.xml")
filePaths <- head(filePaths, n = 100) # TEMPORARY
fileNames <- fs::path_file(filePaths) |> fs::path_ext_remove()
n <- length(filePaths)

# Setup parallelization
nCPU <- parallel::detectCores()
doParallel::registerDoParallel(cores = nCPU)

foreach (i = 1:n) %dopar% {

	ecg <- shiva::read_muse(filePaths[i])
	sig <- vec_data(ecg)
	hea <- attr(ecg, "header")

	readr::write_lines(fileNames[i], file = fs::path(outputFolder, "log.txt"), append = TRUE)

	shiva::write_wfdb(
		data = sig,
		type = "muse",
		record = fileNames[i],
		record_dir = outputFolder,
		header = hea
	)

}


