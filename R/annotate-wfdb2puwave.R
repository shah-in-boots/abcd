#!/usr/bin/env Rscript

# `annotate-wfdb2qrs` can be run on a folder full of WFDB formatted ECGs
# The command requires a folder to process the QRS data for
# It routes through the ECGPUWAVE algorithm (Pan Tompkins)
# It works as a batch script and takes an external argument

# Setup ----

# Libraries
library(shiva)
library(fs)
library(dplyr)
library(parallel)

# External argument (e.g. the year folder)
args <- commandArgs(trailingOnly = TRUE)
folderName <- as.character(args[1])

# Setup parallelization
cat("Setup for rhythm annotation:\n\n")
nCPU <- parallel::detectCores()
cat("\tAttempting paralellization with", nCPU, "cores\n")

# Paths
home <- fs::path_expand("~")
main <- fs::path("projects", "cbcd")
wfdb <- fs::path(home, main, "data", "wfdb", folderName)
cat("Will evaluate ECG parameters in the", folderName, "folder\n")

# Logging ----

cat("\nPreparing WFDB data for annotation:\n\n")
annLogFile <- fs::path(home, main, "data", "wfdb", "ecgpuwave", ext = "log")

if (!fs::file_exists(annLogFile)) {
	fs::file_create(annLogFile)
}

annLogData <- readr::read_lines(annLogFile)
cat("\tThere are", length(annLogData), "annotations using ECGPUWAVE in total\n")

# What is available
wfdbFiles <-
	fs::dir_ls(wfdb, glob = "*.dat") |>
	fs::path_file() |>
	fs::path_ext_remove()
annFiles <-
	fs::dir_ls(wfdb, glob = "*.ecgpuwave") |>
	fs::path_file() |>
	fs::path_ext_remove()
cat("\tThe", folderName, "folder has", length(wfdbFiles), "WFDB files &", length(annFiles), "ECGPUWAVE annotations present\n")

# What is novel
toBeAnnotated <- setdiff(wfdbFiles, annLogData)
cat("\tThere are", length(toBeAnnotated), "new WFDB-files that can be annotated using ECGPUWAVE\n")

# Annotation ----

# Convert to QRS using ECGPUWAVE
fileNames <-
	toBeAnnotated |>
	na.omit()

# Make sure parallel is set up earlier
# Also place everything into correct "folder" by YEAR
annotations <- parallel::mclapply(
	X = fileNames,
	FUN = function(.x) {

		fp <- fs::path(wfdb, .x, ext = ".dat")

		shiva::detect_surface_beats(
			record = .x,
			record_dir = wfdb,
			detector = "ecgpuwave"
		)

		cat("\tWrote the file", .x, "into the", folderName, "folder\n")

		# "Return value"
		.x
	}
)

# Repeat eval of successful file conversions
annFiles <-
	fs::dir_ls(wfdb, glob = "*.ecgpuwave") |>
	fs::path_file() |>
	fs::path_ext_remove()
vroom::vroom_write_lines(annFiles, annLogFile, append = TRUE)
cat("\tA total of", length(annFiles), "were added to the ECGPUWAVE log\n")

