# Take each file and split by years
args <- commandArgs(trailingOnly = TRUE)
year <- as.numeric(args[1])

# year <- 2010

# Libraries
# Libraries
library(dplyr)
library(vroom)
library(clock)
library(fs)

# Input paths
home <- fs::path_expand('~')
main <- fs::path('projects', 'cbcd')
fileName <- 'diagnosis-proc'

dataFile <- fs::path(home, main, 'data', 'ccts', 'raw', fileName, ext = 'csv')

dat <-
	dataFile |>
	vroom::vroom(
		col_select = c(
			record_id = 'RECORD_ID',
			encounter_id = 'ENCOUNTER_ID',
			date = 'START_DATE',
			icd_code = 'ICD10_CODE'
		)
	) |>
	dplyr::filter(year == clock::get_year(date))

# Output paths
outputFolder <- fs::path(home, main, 'data', 'ccts', year)

if (!fs::dir_exists(outputFolder)) {
	fs::dir_create(outputFolder)
}

outputFile <- fs::path(outputFolder, fileName, ext = 'csv')

vroom::vroom_write(x = dat, file = outputFile, delim = ',')
