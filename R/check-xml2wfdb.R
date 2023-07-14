#!/usr/bin/env Rscript

# `check-xml2wfdb.R` should be run after converting XML to WFDB format
# It will update a log file named 'contents.tsv' that has:
# 	FOLDER = name of folder or directory that was analyzed
#		NAME = name of file itself
# This updated contents will be used by the conversion formula iteratively
# This way, only NEW files need to be run as things are updated


# Libraries
library(readr)
library(dplyr)
library(fs)
library(tibble)

# Paths
home <- fs::path_expand("~")
main <- fs::path("projects", "cbcd")

# MUSE ----

museDir <- fs::path(home, main, "data", "muse")
museFolders <- fs::dir_ls(museDir, type = "directory")
museLog <- fs::path(museDir, "contents.tsv")

# Read in if pre-existing data exists
cat("Reading in the MUSE directory of files located at...\n", museLog, "\n\n")
museDataOld <- readr::read_tsv(museLog)

# Check / make a list of all MUSE files
museDataList <- list()

cat("Will now loop through", length(museFolders), "located at...\n", museDir, "\n\n")
for (i in seq_along(museFolders)) {

	folderPath <- museFolders[i]
	folderName <- fs::path_file(folderPath)

	cat("Retrieving names of all XML files in", folderName, "\n")
	xmlFiles <-
		fs::dir_ls(folderPath, glob = "*.xml") |>
		fs::path_file() |>
		fs::path_ext_remove()
	cat("There are", length(xmlFiles), "in", folderName, "\n\n")

	museDataList[[i]] <-
		tibble::tibble(
			FOLDER = folderName,
			NAME = xmlFiles
		)
}

museDataNew <- dplyr::bind_rows(museDataList)

# Compare to log file to create/append as needed
# Will compare based on museTable as being most "recent"
# Will use the new folder location

# Number of duplicate or updating values
n <- nrow(dplyr::setdiff(museDataNew, museDataOld))

museDataUpdated <-
	dplyr::bind_rows(museDataNew, museDataOld) |>
	dplyr::distinct(NAME, .keep_all = TRUE)

cat("When updating the MUSE directory, there were", n, "additions\n")
cat("These will be written back to...\n", museLog, "\n\n")
readr::write_tsv(museDataUpdated, file = museLog)

# WFDB ----

wfdbDir <- fs::path(home, main, "data", "wfdb")
wfdbFolders <- fs::dir_ls(wfdbDir, type = "directory")
wfdbLog <- fs::path(wfdbDir, "contents.tsv")

# Read-in pre-existing contents that were "already ran"
# Will then add/update with individual logs created within directories
cat("Reading in the WFDB directory of files located at...\n", wfdbLog, "\n\n")
wfdbDataOld <- readr::read_tsv(wfdbLog)

# Needs to be updated for what XML files were converted
wfdbDataList <- list()
cat("Will now loop through", length(wfdbFolders), "located at...\n", wfdbDir, "\n\n")
for (i in seq_along(wfdbFolders)) {

	folderPath <- wfdbFolders[i]
	folderName <- fs::path_file(folderPath)

	cat("Retrieving the log of WFDB files in", folderName, "\n")
	logData <-
		fs::path(folderPath, "log.txt") |>
		readr::read_lines()
	cat("There are", length(logData), "WFDB-formated files in", folderName, "\n\n")

	wfdbDataList[[i]] <-
		tibble::tibble(
			FOLDER = folderName,
			NAME = logData
		)
}

wfdbDataNew <- dplyr::bind_rows(wfdbDataList)

# Number of duplicate or updating values
n <- length(setdiff(wfdbDataNew$NAME, wfdbDataOld$NAME))

# Update WFDB log here
# These are files that have already been processed
# This script runs AFTER the conversion script is run
# Allows for updates for errors and decreases speed issues)
wfdbDataUpdated <-
	dplyr::bind_rows(wfdbDataNew, wfdbDataOld) |>
	dplyr::distinct(NAME, .keep_all = TRUE)

cat("When updating the WFDB file conversion list, there were", n, "new additions\n")
cat("These will be written back to...\n", wfdbLog, "\n\n")
readr::write_tsv(wfdbDataUpdated, file = wfdbLog)
