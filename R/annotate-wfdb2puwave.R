#!/usr/bin/env Rscript

# `annotate-wfdb2qrs` can be run on a folder full of WFDB formatted ECGs
# The command requires a folder to process the QRS data for
# It routes through the ECGPUWAVE algorithm (Pan Tompkins)
args <- commandArgs(trailingOnly = TRUE)
folderName <- as.character(args[1])

# Libraries
library(shiva)
library(fs)
library(dplyr)

# Paths
home <- fs::path_expand("~")
main <- fs::path("projects", "cbcd")

# WFDB specific
wfdb <- fs::path(home, main, "data", "wfdb", folderName)
cat("Will evaluate ECG parameters in the", folderName, "folder\n")

# Convert to QRS using ECGPUWAVE
fileNames <-
	fs::dir_ls(wfdb, glob = "*.dat") |>
	fs::path_file() |>
	fs::path_ext_remove()

for (i in seq_along(fileNames)) {

	shiva::detect_surface_beats(
		record = fileNames[i],
		record_dir = wfdb,
		detector = "ecgpuwave"
	)
}
