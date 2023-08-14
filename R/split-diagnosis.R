cat('\nGet command line arguments.\n')
# Take each file and split by years
args <- commandArgs(trailingOnly = TRUE)
year <- as.numeric(args[1])
cat('Will filter to year =', year, '\n')


# Libraries
library(dplyr)
library(vroom)
library(clock)
library(fs)

# Input paths
home <- fs::path_expand('~')
main <- fs::path('projects', 'cbcd')
fileName <- 'diagnosis-proc'
cat('Processing the file named', fileName, '\n')
dataFile <- fs::path(home, main, 'data', 'ccts', 'raw', fileName, ext = 'csv')


dat <-
	dataFile |>
	vroom::vroom(
		col_select = c(
			record_id = 'record_id',
			encounter_id = 'encounter_id',
			date = 'date',
			icd_code = 'icd_code'
		)
	) |>
	dplyr::filter(year == clock::get_year(date))
cat('Read in', dataFile, 'and filtered down by year\n')

# Output paths
outputFolder <- fs::path(home, main, 'data', 'ccts', year)
cat('Will write this to the folder', outputFolder, '\n')

if (!fs::dir_exists(outputFolder)) {
	fs::dir_create(outputFolder)
}

outputFile <- fs::path(outputFolder, fileName, ext = 'csv')
cat('Name of file is...', outputFile, '\n')

vroom::vroom_write(x = dat, file = outputFile, delim = ',')
cat('Done writing\n')
