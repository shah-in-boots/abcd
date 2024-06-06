#!/usr/bin/env Rscript

# Setup ----

library(fs)
library(vroom)
library(dplyr)

# Muse files
main <-
	fs::path("~", "projects", "cbcd") |>
	fs::path_expand()

muse <- fs::path(main, "data", "muse")

folders <-
	fs::dir_ls(muse, type = "directory") |>
	fs::path_file()

# Log Updates ----

cat("Preparing MUSE data:\n\n")

# Log files
logFile <- fs::path(muse, 'muse', ext = 'log')
if (!fs::file_exists(logFile)) {
	fs::file_create(logFile)
}
logData <- vroom::vroom_lines(logFile)
cat("Currently there are", length(logData), "files in the MUSE log\n")

# See difference between XML count and log data
xmlData <-
	fs::dir_ls(muse, recurse = TRUE, type = "file", glob = "*.xml") |>
	fs::path_file() |>
	fs::path_ext_remove() |>
	na.omit() |>
	unique()
newData <- setdiff(xmlData, logData)
cat("There are", length(newData), "XML files that have not yet been logged\n")

# Rewrite a new log file
masterList <- unique(c(logData, xmlData))
vroom::vroom_write_lines(masterList, file = logFile)

# Folder Status ----

n <- seq_along(folders)
counts <- sapply(folders, function(.x) {
	fs::path(muse, .x) |>
		fs::dir_ls(type = "file", glob = "*.xml") |>
		length()
})
df <- dplyr::bind_cols(Number = n, FolderName = folders, XML = counts)

# Write out findings
vroom::vroom_write(
	df,
	file = fs::path(main, 'config-muse', ext = 'txt'),
	delim = '\t',
	eol = '\n',
	col_names = TRUE
)
