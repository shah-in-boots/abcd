#!/usr/bin/env Rscript

# Take each file and split by years
args <- commandArgs(trailingOnly = TRUE)
year <- as.numeric(args[1])

# year <- 2010

# Libraries
library(dplyr)
library(vroom)
library(clock)

# Input paths
home <- fs::path_expand('~')
main <- fs::path('projects', 'cbcd')
fileName <- 'visits'

dataFile <- fs::path(home, main, 'data', 'ccts', 'raw', fileName, ext = 'csv')

dat <-
	dataFile |>
	vroom::vroom(
		col_select = c(
			record_id = 'RECORD_ID',
			encounter_id = 'ENCOUNTER_ID',
			visit_location = 'ENCOUNTER_TYPE',
			visit_type = 'VISIT_TYPE',
			visit_discharge = 'DISCHARGE_DISPOSITION',
			start_date = 'VISIT_START_DATE',
			end_date = 'VISIT_END_DATE'
		)
	) |>
	dplyr::filter(year == clock::get_year(start_date))

# Output paths
outputFolder <- fs::path(home, main, 'data', 'ccts', year)
if (!fs::dir_exists(outputFolder)) {
	fs::dir_create(outputFolder)
}
outputFile <- fs::path(outputFolder, fileName, ext = 'csv')
vroom::vroom_write(x = dat, file = outputFile, delim = ',')
