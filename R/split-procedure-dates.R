#!/usr/bin/env Rscript

# Take each file and split by years
args <- commandArgs(trailingOnly = TRUE)
year <- as.numeric(args[1])

# year <- 2010

# Libraries
library(tidyverse)
library(vroom)

# Input paths
home <- fs::path_expand('~')
main <- fs::path('projects', 'cbcd')
fileName <- 'procedure-records'

dataFile <- fs::path(home, main, 'data', 'ccts', 'raw', fileName, ext = 'csv')

dat <-
	dataFile |>
	vroom::vroom(
		col_select = c(
			record_id = 'RECORD_ID',
			encounter_id = 'ENCOUNTER_ID',
			procedure_date = 'START_DATE',
			procedure_code = 'PROCEDURE_CODE',
			coding_system = 'CODING_SYSTEM'
		)
	) |>
	dplyr::mutate(date = as.Date(procedure_date)) |>
	dplyr::filter(year == lubridate::year(date))

# Output paths
outputFolder <- fs::path(home, main, 'data', 'ccts', year)
if (!fs::dir_exists(outputFolder)) {
	fs::dir_create(outputFolder)
}
outputFile <- fs::path(outputFolder, fileName, ext = 'csv')
vroom::vroom_write(x = dat, file = outputFile, delim = ',')
