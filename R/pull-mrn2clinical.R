#!/usr/bin/env Rscript

# `copy-mrn2clinical.R` uses MRNs to subset the clinical data
#
# Arguments [4]:
# 	MRN <file>
# 		Path to list of MRNs file and name of it
# 		Assumes that path is from project home (e.g. ~/projects/cbcd/.)
# 		Expects file to be a list with an MRN on each line
# 	YEAR <character>
# 		Folder name to evaluate
# 		In this case, all the CCTS is split into folders by year
# 		Expected to be within ~/ccts/emr/pq/*
# 	OUTPUT <folder>
# 		Name of path and folder name to put findings
#			Makes a subset of data from the master dataset
#			Example: ~/data/afeqt/emr/*
#		FORMAT <character>
#			Name of type of format to output
#			Likely will be placed within "years" of the data being obtained
#			Keeps datafile size "smaller", and can be in the following formats
#			- parquet
#			- feather
#			- arrow
#			- cs
#
# Output [1]:
# 	DATA <csv>
# 		Creates a subset of data from the clinical datasets
# 		This will ONLY APPEND to files by name in that folder
# 		This ensure happy for loops and no data erasures

# Setup ----

cat('Find clinical data by MRN!\n\n')

# Libraries
library(readr)
library(dplyr)
library(fs)
library(tibble)
library(vroom)
library(parallel)
library(foreach)
library(stringr)
library(arrow)

# Paths
home <- fs::path_expand('~')
project <- fs::path(home, 'projects', 'cbcd')
ccts <- fs::path(home, 'ccts', 'emr')

# Handle arguments
args <- commandArgs(trailingOnly = TRUE)
mrnArg <- as.character(args[1])
yearName <- as.numeric(args[2])
outputArg <- as.character(args[3])
formatArg <- as.character(args[4])
cat('\tName of MRN file:', mrnArg, '\n')
cat('\tReading in from data from year:', yearName, '\n')
cat('\tWill write to folder:', outputArg, '\n')
cat('\tSaving in format:', formatArg, '\n')

# Parallel...
nCPU <- parallel::detectCores()
doParallel::registerDoParallel(cores = nCPU)
cat('Attempt parallelization with', nCPU, 'cores\n')

# I/O ----

cat('\nHandling the inputs & outputs:\n')

# MRNs
mrnFile <- fs::path(project, mrnArg)
mrnData <-
	vroom::vroom_lines(mrnFile) |>
	as.numeric()
cat('\tThere are', length(mrnData), 'MRNs to be evaluated\n')

# Get record IDs to help match on key
redcap <-
	fs::path(ccts, 'pq', 'demographics-0.parquet') |>
	arrow::read_parquet() |>
	#dplyr::mutate(mrn = stringr::str_pad(mrn, width = 9, pad = '0'))
	dplyr::mutate(mrn = as.numeric(mrn))

key <- redcap$record_id[which(redcap$mrn %in% mrnData)]
cat('\tThere are a total of', length(key), 'MRNs in the CCTS data\n')

# Output file
outputFolder <-
	fs::path(outputArg) |>
	fs::path_expand()
cat('\tWill copy filtered data to folder...', outputFolder, '\n')

# Move to next component
cat('\nNow will go through individual data types by individual files\n\n')

# Write Out Files ----

fileType <- 'diagnosis'
cat('\tAnalyzing ', fileType, '\n')
arrow::open_dataset(fs::path(ccts, 'pq', fileType), format = 'parquet') |>
	dplyr::filter(year == yearName) |>
	dplyr::filter(record_id %in% key) |>
	arrow::write_dataset(fs::path(outputFolder, fileType), format = formatArg)

fileType <- 'labs'
cat('\tAnalyzing ', fileType, '\n')
arrow::open_dataset(fs::path(ccts, 'pq', fileType), format = 'parquet') |>
	dplyr::filter(year == yearName) |>
	dplyr::filter(record_id %in% key) |>
	arrow::write_dataset(fs::path(outputFolder, fileType), format = formatArg)

fileType <- 'medications'
cat('\tAnalyzing ', fileType, '\n')
arrow::open_dataset(fs::path(ccts, 'pq', fileType), format = 'parquet') |>
	dplyr::filter(year == yearName) |>
	dplyr::filter(record_id %in% key) |>
	arrow::write_dataset(fs::path(outputFolder, fileType), format = formatArg)

fileType <- 'notes'
cat('\tAnalyzing ', fileType, '\n')
arrow::open_dataset(fs::path(ccts, 'pq', fileType), format = 'parquet') |>
	dplyr::filter(year == yearName) |>
	dplyr::filter(record_id %in% key) |>
	arrow::write_dataset(fs::path(outputFolder, fileType), format = formatArg)

fileType <- 'procedure-dates'
cat('\tAnalyzing ', fileType, '\n')
arrow::open_dataset(fs::path(ccts, 'pq', fileType), format = 'parquet') |>
	dplyr::filter(year == yearName) |>
	dplyr::filter(record_id %in% key) |>
	arrow::write_dataset(fs::path(outputFolder, fileType), format = formatArg)

fileType <- 'procedure-reports'
cat('\tAnalyzing ', fileType, '\n')
arrow::open_dataset(fs::path(ccts, 'pq', fileType), format = 'parquet') |>
	dplyr::filter(year == yearName) |>
	dplyr::filter(record_id %in% key) |>
	arrow::write_dataset(fs::path(outputFolder, fileType), format = formatArg)

fileType <- 'visits'
cat('\tAnalyzing ', fileType, '\n')
arrow::open_dataset(fs::path(ccts, 'pq', fileType), format = 'parquet') |>
	dplyr::filter(year == yearName) |>
	dplyr::filter(record_id %in% key) |>
	arrow::write_dataset(fs::path(outputFolder, fileType), format = formatArg)

fileType <- 'vitals'
cat('\tAnalyzing ', fileType, '\n')
arrow::open_dataset(fs::path(ccts, 'pq', fileType), format = 'parquet') |>
	dplyr::filter(year == yearName) |>
	dplyr::filter(record_id %in% key) |>
	arrow::write_dataset(fs::path(outputFolder, fileType), format = formatArg)

cat('\nDone with writing out files!')
