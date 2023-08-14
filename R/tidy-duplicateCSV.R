#!/usr/bin/env Rscript

# 'tidy-duplicateCSV.R' ensures UNIQUE CSV files in folder
#
# Arguments [1]:
# 	FOLDER <path> 
# 		Give the relative path from project home
# 		Will clean up every CSV file in that folder

# Libraries
library(vroom)
library(dplyr)
library(fs)
library(tibble)

# Handle arguments
args <- commandArgs(trailingOnly = TRUE)
folderArg <- as.character(args[1])
cat('Cleaning up duplicates in...', folderArg, '\n')

# Paths
home <- fs::path_expand('~')
main <- fs::path('projects', 'cbcd')
folderPath <- fs::path(home, main, folderArg)

# Get all CSV files
files <- fs::dir_ls(folderPath, glob = '*.csv')

for (i in seq_along(files)) {

	fp <- files[i]
	cat('\nFile...', fp, '\n')
	old <- vroom::vroom(fp, delim = ',') 
	cat('\tOld files had', nrow(old), 'lines\n')
	new <- dplyr::distinct(old)
	cat('\tNew file has', nrow(new), 'lines\n')
	
	# Write out
	vroom::vroom_write(x = new, file = fp)

}

