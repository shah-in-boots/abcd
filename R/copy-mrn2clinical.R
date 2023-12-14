#!/usr/bin/env Rscript

# `copy-mrn2clinical.R` uses MRNs to subset the clinical data
#
# Arguments [4]:
# 	MRN <file>
# 		Path to list of MRNs file and name of it
# 		Assumes that path is from project home (e.g. ~/projects/cbcd/.)
# 		Expects file to be a list with an MRN on each line
# 	OUTPUT <folder>
# 		Name of path and folder name to put findings
#			Makes a subset of data from the master dataset
# 	SUBFOLDER <character>
# 		Folder name to evaluate
# 		In this case, all the CCTS is split into folders by year
# 		Expected to be within ~/ccts/emr/*
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

# Paths
home <- fs::path_expand('~')
main <- fs::path('projects', 'cbcd')
ccts <- fs::path(home, main, 'data', 'ccts')

# Handle arguments
args <- commandArgs(trailingOnly = TRUE)
mrnArg <- as.character(args[1])
outputArg <- as.character(args[2])
folderName <- as.character(args[3])
cat('\tName of MRN file:', mrnArg, '\n')
cat('\tWill write to folder:', outputArg, '\n')
cat('\tReading in from folder:', folderName, '\n')

# Parallel...
nCPU <- parallel::detectCores()
doParallel::registerDoParallel(cores = nCPU)
cat('Attempt parallelization with', nCPU, 'cores\n')

# I/O ----

cat('\nHandling the inputs & outputs:\n')

# MRNs
mrnFile <- fs::path(home, main, mrnArg)
mrnData <- vroom::vroom_lines(mrnFile)
cat('\tThere are', length(mrnData), 'MRNs to be evaluated\n')

# Input file is in the batch folder
inputDiagnosis <- fs::path(ccts, folderName, 'diagnosis', ext = 'csv')
inputMedications <- fs::path(ccts, folderName, 'medications', ext = 'csv')
inputNotes <- fs::path(ccts, folderName, 'notes', ext = 'csv')
inputVitals <- fs::path(ccts, folderName, 'vitals', ext = 'csv')
inputVisits <- fs::path(ccts, folderName, 'visits', ext = 'csv')
inputLabs <- fs::path(ccts, folderName, 'labs', ext = 'csv')
inputProcedures <- fs::path(ccts, folderName, 'procedure-records', ext = 'csv')

# Get record IDs to help match on key
redcap <-
	fs::path(ccts, 'raw', 'redcap-ids', ext = 'csv') |>
	vroom::vroom() |>
	dplyr::mutate(mrn = stringr::str_pad(mrn, width = 9, pad = '0'))

key <- redcap$record_id[which(redcap$mrn %in% mrnData)]
cat('\tThere are a total of', length(key), 'MRNs in the CCTS data\n')

# Output file
outputFolder <- fs::path(home, main, outputArg)
cat('\tWill copy filtered data to folder...', outputFolder, '\n')

# Move to next component
cat('\nNow will go through individual data types by individual files\n\n')

# Write Out Files ----

cat('\tAnalyzing diagnosis\n')

vroom::vroom(inputDiagnosis) |>
	dplyr::filter(record_id %in% key) |>
	vroom::vroom_write(
		file = fs::path(outputFolder, 'diagnosis.csv'),
		delim = ',',
		append = TRUE
	)

cat('\tAnalyzing labs\n')

vroom::vroom(inputLabs) |>
	dplyr::filter(record_id %in% key) |>
	vroom::vroom_write(
		file = fs::path(outputFolder, 'labs.csv'),
		delim = ',',
		append = TRUE
	)

cat('\tAnalyzing visits\n')

vroom::vroom(inputVisits) |>
	dplyr::filter(record_id %in% key) |>
	vroom::vroom_write(
		file = fs::path(outputFolder, 'visits.csv'),
		delim = ',',
		append = TRUE
	)

cat('\tAnalyzing vitals\n')

vroom::vroom(inputVitals) |>
	dplyr::filter(record_id %in% key) |>
	vroom::vroom_write(
		file = fs::path(outputFolder, 'vitals.csv'),
		delim = ',',
		append = TRUE
	)

cat('\tAnalyzing procedures\n')

vroom::vroom(inputProcedures) |>
	dplyr::filter(record_id %in% key) |>
	vroom::vroom_write(
		file = fs::path(outputFolder, 'procedures.csv'),
		delim = ',',
		append = TRUE
	)

cat('\tAnalyzing medications\n')

vroom::vroom(inputMedications) |>
	dplyr::filter(record_id %in% key) |>
	vroom::vroom_write(
		file = fs::path(outputFolder, 'medications.csv'),
		delim = ',',
		append = TRUE
	)


cat('\nDone with writing out files!')
