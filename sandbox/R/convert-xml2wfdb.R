#!/usr/bin/env Rscript

# `convert-xml2wfdb.R` works within a single folder containing XML files
# It then writes it out to a folder with .DAT and .HEA files
# Requires an external argument from the shell script that decides which folder
# This is for batch processing with SLURM
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
main <- fs::path("projects", "cbcd", "sandbox")
inputFolder <- fs::path(home, main, "data", "muse", folderName)
outputFolder <- fs::path(home, main, "data", "wfdb", folderName)

# Only convert XML files that have not yet been logged
museLog <-
	readr::read_tsv(fs::path(home, main, "data", "muse", "contents.tsv")) |>
	dplyr::filter(FOLDER == folderName)

wfdbLog <-
	readr::read_tsv(fs::path(home, main, "data", "wfdb", "contents.tsv")) |>
	dplyr::filter(FOLDER == folderName)

# Files that need to be converted
filePaths <-
	dplyr::setdiff(museLog, wfdbLog) |>
	{\(.x) fs::path(inputFolder, .x$NAME, ext = 'xml')}()
fileNames <- fs::path_file(filePaths) |> fs::path_ext_remove()
n <- length(filePaths)

# Setup parallelization
nCPU <- parallel::detectCores()
doParallel::registerDoParallel(cores = nCPU)

writtenFiles <- foreach(i = 1:n, .combine = c) %dopar% {

	ecg <- shiva::read_muse(filePaths[i])
	sig <- vec_data(ecg)
	hea <- attr(ecg, "header")

	shiva::write_wfdb(
		data = sig,
		type = "muse",
		record = fileNames[i],
		record_dir = outputFolder,
		header = hea
	)

	# "Return value"
	fileNames[i]

}

# Log that data was written
readr::write_lines(writtenFiles,
									 file = fs::path(outputFolder, "log.txt"),
									 append = TRUE)
