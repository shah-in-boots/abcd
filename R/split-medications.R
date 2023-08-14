#!/usr/bin/env Rscript

# Take each file and split by years
args <- commandArgs(trailingOnly = TRUE)
year <- as.numeric(args[1])

# year <- 2010

# Libraries
library(clock)
library(dplyr)
library(fs)
library(vroom)

# Input paths
home <- fs::path_expand('~')
main <- fs::path('projects', 'cbcd')
fileName <- 'medications'

dataFile <- fs::path(home, main, 'data', 'ccts', 'raw', fileName, ext = 'csv')

earliest <- as.Date('2010-01-01')

dat <-
	dataFile |>
	vroom::vroom(
		col_select = c(
			record_id = 'RECORD_ID',
			medication = 'MEDICATION_NAME',
			start_date = 'START_DATE',
			end_date = 'END_DATE'
		)
	) |>
	dplyr::mutate(dateYear = clock::get_year(as.Date(start_date))) |>
	dplyr::mutate(dateYear = if_else(dateYear <= 2010, 2010, dateYear)) |>
	dplyr::filter(year == dateYear) |>
	dplyr::select(-dateYear)

# Output paths
outputFolder <- fs::path(home, main, 'data', 'ccts', year)
if (!fs::dir_exists(outputFolder)) {
	fs::dir_create(outputFolder)
}
outputFile <- fs::path(outputFolder, fileName, ext = 'csv')
vroom::vroom_write(x = dat, file = outputFile, delim = ',')
