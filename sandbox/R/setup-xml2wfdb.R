#!/usr/bin/env Rscript

# Libraries
library(readr)
library(fs)

# Paths
home <- fs::path_expand("~")
main <- fs::path("projects", "cbcd", "sandbox")

# MUSE ----

museDir <- fs::path(home, main, "data", "muse")
museFolders <- fs::dir_ls(museDir, type = "directory")

# Read in if pre-existing data exists
# If directory files / contents file is, make empty placeholder
museContents <- fs::path(museDir, "contents.tsv")
if (!fs::file_exists(museContents)) {
	fs::file_create(museContents)
	readr::write_lines("FOLDER\tNAME", file = museContents)
	cat("Creating MUSE directory file at...\n\n", museContents)
} else {
	cat("MUSE directory already exists.\n\n")
}

# WFDB ----

wfdbDir <- fs::path(home, main, "data", "wfdb")
wfdbFolders <- fs::dir_ls(wfdbDir, type = "directory")

wfdbContents <- fs::path(wfdbDir, "contents.tsv")
if (!fs::file_exists(wfdbContents)) {
	fs::file_create(wfdbContents)
	readr::write_lines("FOLDER\tNAME", file = wfdbContents)
	cat("Creating WFDB directory file at...\n", wfdbContents, "\n\n")
} else {
	cat("WFDB directory already exists.\n\n")
}

# Check if each folder has a logging file or not
# Log files are single columns of file names
# Log files are .txt format
for (i in seq_along(wfdbFolders)) {

	folderPath <- wfdbFolders[i]
	logFile <- fs::path(folderPath, "log.txt")
	if (!fs::file_exists(logFile)) {
		fs::file_create(logFile)
		cat("Creating WFDB log file at...\n", logFile, "\n")
	} else {
		cat("Log file for", fs::path_file(folderPath), "already exists.\n\n")
	}

}

