#!/usr/bin/env Rscript

# Setup ----

library(fs)
library(vroom)
library(dplyr)

# WFDB files
main <-
	fs::path("~", "projects", "cbcd") |>
	fs::path_expand()

wfdb <- fs::path(main, "data", "wfdb")

folders <-
	fs::dir_ls(wfdb, type = "directory") |>
	fs::path_file()

# WFDB Log Updates ----

cat("Preparing WFDB data:\n\n")

# Log files
logFile <- fs::path(wfdb, 'wfdb', ext = 'log')
if (!fs::file_exists(logFile)) {
	fs::file_create(logFile)
}
logData <- vroom::vroom_lines(logFile)
cat("Currently there are", length(logData), "files in the overall WFDB log\n")

# See difference between current folder data and what has been logged
wfdbData <-
	fs::dir_ls(wfdb, recurse = TRUE, type = "file", glob = "*.dat") |>
	fs::path_file() |>
	fs::path_ext_remove() |>
	na.omit() |>
	unique()
newData <- setdiff(wfdbData, logData)
cat("There are", length(newData), "WFDB files that have not yet been logged\n")

# Rewrite a new log file
masterList <- unique(c(logData, newData))
vroom::vroom_write_lines(masterList, file = logFile)

# ECGPUWAVE annotations ----

# Log files
logFile <- fs::path(wfdb, 'ecgpuwave', ext = 'log')
if (!fs::file_exists(logFile)) {
	fs::file_create(logFile)
}
logData <- vroom::vroom_lines(logFile)
cat("Currently there are", length(logData), "files in the overall ECGPUWAVE log\n")

# See difference between current folder data and what has been logged
ecgpuwaveData <-
	fs::dir_ls(wfdb, recurse = TRUE, type = "file", glob = "*.ecgpuwave") |>
	fs::path_file() |>
	fs::path_ext_remove() |>
	na.omit() |>
	unique()
newData <- setdiff(ecgpuwaveData, logData)
cat("There are", length(newData), "ECGPUWAVE annotation files that have not yet been logged\n")

# Rewrite a new log file
masterList <- unique(c(logData, newData))
vroom::vroom_write_lines(masterList, file = logFile)
cat("The final count in the ECPUWAVE log is now", length(masterList), "\n")

# Folder Status ----

n <- seq_along(folders)

wfdbCounts <- sapply(folders, function(.x) {
	fs::path(wfdb, .x) |>
		fs::dir_ls(type = "file", glob = "*.dat") |>
		length()
})

ecgpuwaveCounts <- sapply(folders, function(.x) {
	fs::path(wfdb, .x) |>
		fs::dir_ls(type = "file", glob = "*.ecgpuwave") |>
		length()
})

df <-
	dplyr::bind_cols(
		Number = n,
		FolderName = folders,
		WFDB = wfdbCounts,
		ECGPUWAVE = ecgpuwaveCounts
	)

# Write out findings
vroom::vroom_write(
	df,
	file = fs::path(main, 'config-wfdb', ext = 'txt'),
	delim = '\t',
	eol = '\n',
	col_names = TRUE
)
