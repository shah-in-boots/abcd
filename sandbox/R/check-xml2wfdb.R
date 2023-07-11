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
main <- fs::path("projects", "cbcd", "sandbox")

# MUSE ----

museDir <- fs::path(home, main, "data", "muse")
museFolders <- fs::dir_ls(museDir, type = "directory")
museLog <- fs::path(museDir, "contents.tsv")

# Read in if pre-existing data exists
log <- readr::read_tsv(museLog)

# Check / make a list of all MUSE files
museList <- list()

for (i in seq_along(museFolders)) {

	folderPath <- museFolders[i]
	folderName <- fs::path_file(folderPath)

	xmlFiles <-
		fs::dir_ls(folderPath, glob = "*.xml") |>
		fs::path_file() |>
		fs::path_ext_remove()

	museList[[i]] <-
		tibble::tibble(
			FOLDER = folderName,
			NAME = xmlFiles
		)
}

museTable <- dplyr::bind_rows(museList)

# Compare to log file to create/append as needed
# Will compare based on museTable as being most "recent"
# Will use the new folder location

# Number of duplicate or updating values
n <- nrow(dplyr::setdiff(museTable, log))
cat("When updating the MUSE directories, there are", n, "additions")

updatedLog <-
	dplyr::bind_rows(museTable, log) |>
	dplyr::distinct(NAME, .keep_all = TRUE)

readr::write_tsv(updatedLog, file = museLog)

# WFDB ----

wfdbDir <- fs::path(home, main, "data", "wfdb")
wfdbFolders <- fs::dir_ls(wfdbDir, type = "directory")
wfdbLog <- fs::path(wfdbDir, "contents.tsv")

# Read-in pre-existing contents that were "already ran"
# Will then add/update with individual logs created within directories
log <- readr::read_tsv(wfdbLog)

# Needs to be updated for what XML files were converted
wfdbList <- list()
for (i in seq_along(wfdbFolders)) {

	folderPath <- wfdbFolders[i]
	folderName <- fs::path_file(folderPath)

	logData <-
		fs::path(folderPath, "log.txt") |>
		readr::read_lines()

	wfdbList[[i]] <-
		tibble::tibble(
			FOLDER = folderName,
			NAME = logData
		)
}

wfdbTable <- dplyr::bind_rows(wfdbList)

# Number of duplicate or updating values
n <- nrow(dplyr::setdiff(wfdbTable, log))
cat("When updating the WFDB file conversion list, there are", n, "new additions")

# Update WFDB log here
# These are files that have already been processed
# This script runs AFTER the conversion script is run
# Allows for updates for errors and decreases speed issues)
updatedLog <-
	dplyr::bind_rows(wfdbTable, log) |>
	dplyr::distinct(NAME, .keep_all = TRUE)

readr::write_tsv(updatedLog, file = wfdbLog)
