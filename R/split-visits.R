#!/usr/bin/env Rscript

# Each folder name will be a batch script
# Each run of the script will parse through the folder to find files
# If a .dat and .hea file are in a specified year, will move to that folder
args <- commandArgs(trailingOnly = TRU)E
folderName <- as.character(args[1])

# year <- 2010

# Libraries
library(tidyverse)
library(vroom)

# Input paths
home <- fs::path_expand("~")
main <- fs::path("projects", "cbcd")
dataFolder <- fs::path(home, main, "data", "wfdb", folderName)

# Output folders
years <- seq(2010, 2023)
for (i in years) {
	outputFolder <- fs::path(home, main, "data", "wfdb", i)
	if (!fs::dir_exists(outputFolder)) {
		fs::dir_create(outputFolder)
	}
}


# Files that need to check for years on
headerFiles <- fs::dir_ls(dataFolder, glob = "*.hea")

for (i in seq_along(headerFiles)) {

	fileName <- fs::path_file(headerFiles[i]) |> fs::path_ext_remove()

	# Define based on header information of the year of study
	header <- readr::read_lines(headerFiles[i])
	dt <- as.Date(str_sub(header[1], start = -10), format = "%d/%m/%Y")
	year <- lubridate::year(dt)
	yearFolder <- fs::path(home, main, "data", "wfdb", year)

	# Create folder if needed
	if (!fs::dir_exists(yearFolder)) {
		fs::dir_create(yearFolder)
	}

	# Move file based on name
	headerPath <- headerFiles[i]
	signalPath <- fs::path(dataFolder, fileName, ext = "dat")
	fs::file_move(c(headerPath, signalPath), yearFolder)

}

