# `split-ccts.R` is used by SLURM to partition the clinical data This file
# contains customizable parameters for end-users. Each section can be ran or
# ignored. The parent command is currently called `partition-ccts.sh` in the
# project root.
#
# `if (<LOGICAL>) { split_csv() }`
#
# Change to `TRUE` or `FALSE` on each chunk as needed. Generally, this is for if
# there are single updates that need to be made, or if wanting to run the code
# on different cluster configurations. For example, [cpu-t3] with 2 vCPUs is
# sufficient for most of the files that are read in, however for a enormous file
# like the notes, will error. Thus, recommend [cpu-c5] with 4-8 vCPUs.


# Take each file and split by years
args <- commandArgs(trailingOnly = TRUE)
year <- as.numeric(args[1])
cat('Will filter to year =', year, '\n')

# Libraries
library(tidyverse)
library(vroom)
library(fs)

# Paths
home <- fs::path_expand('~')
main <- fs::path('projects', 'cbcd')
csv_path <- fs::path(home, main, 'data', 'ccts', 'csv')

# Demographics
# 	Do not need to split these actually
# 	Will remain in the "raw" folder

# Diagnosis
if (FALSE) {
	fileName <- 'diagnosis'
	cat('Processing the file named', fileName, '\n')
	dataFile <- fs::path(home, main, 'data', 'ccts', 'raw', fileName, ext = 'csv')

	dat <-
		dataFile |>
		vroom::vroom(
			col_select = c(
				record_id = 'RECORD_ID',
				encounter_id = 'ENCOUNTER_ID',
				date = 'START_DATE',
				icd_code = 'ICD_CODE'
			)
		) |>
		dplyr::mutate(date = as.Date(date)) |>
		dplyr::filter(year == lubridate::year(date))
	cat('Read in', dataFile, 'and filtered down by year\n')

	# Output paths (to CSV folder > Diagnosis > Year)
	outputFolder <- fs::path(csv_path, fileName, year)
	cat('Will write this to the folder', outputFolder, '\n')

	if (!fs::dir_exists(outputFolder)) {
		fs::dir_create(outputFolder)
	}

	outputFile <- fs::path(outputFolder, fileName, ext = 'csv')
	cat('Name of file is...', outputFile, '\n')

	vroom::vroom_write(x = dat, file = outputFile, delim = ',')
	cat('Done writing\n')

}

# Labs
if (FALSE) {
	fileName <- 'labs'
	cat('Processing the file named', fileName, '\n')
	dataFile <- fs::path(home, main, 'data', 'ccts', 'raw', fileName, ext = 'csv')

	dat <-
		dataFile |>
		vroom::vroom(
			col_select = c(
				record_id = 'RECORD_ID',
				encounter_id = 'ENCOUNTER_ID',
				date = 'RESULT_DATE',
				lab_name = 'LABTEST_NAME',
				lab_value = 'VALUE',
				lab_units = 'UNIT'
			),
			col_types = 'nnDccc'
		) |>
		dplyr::mutate(date = as.Date(date)) |>
		dplyr::filter(year == lubridate::year(date))
	cat('Read in', dataFile, 'and filtered down by year\n')

	# Output paths
	outputFolder <- fs::path(csv_path, fileName, year)
	cat('Will write this to the folder', outputFolder, '\n')

	if (!fs::dir_exists(outputFolder)) {
		fs::dir_create(outputFolder)
	}

	outputFile <- fs::path(outputFolder, fileName, ext = 'csv')
	cat('Name of file is...', outputFile, '\n')

	vroom::vroom_write(x = dat, file = outputFile, delim = ',')
	cat('Done writing\n')
}

# Medications
if (FALSE) {
	fileName <- 'medications'
	dataFile <- fs::path(home, main, 'data', 'ccts', 'raw', fileName, ext = 'csv')

	earliest <- as.Date('2010-01-01')

	dat <-
		dataFile |>
		vroom::vroom(
			col_select = c(
				record_id = 'RECORD_ID',
				order = 'MED_ORDER_NAME',
				medication = 'GENERIC_NAME',
				dose_amount = 'DOSE',
				dose_units = 'DOSE_UNIT',
				dose_route = 'ROUTE',
				dose_frequency = 'FREQUENCY',
				start_date = 'START_DATE',
				end_date = 'END_DATE'
			)
		) |>
		dplyr::mutate(start_date = as.Date(start_date)) |>
		dplyr::mutate(start_date = if_else(start_date <= earliest, earliest, start_date)) |>
		dplyr::filter(year == lubridate::year(start_date))
	cat('Read in', dataFile, 'and filtered down by year\n')

	# Output paths
	outputFolder <- fs::path(csv_path, fileName, year)
	cat('Will write this to the folder', outputFolder, '\n')

	if (!fs::dir_exists(outputFolder)) {
		fs::dir_create(outputFolder)
	}

	outputFile <- fs::path(outputFolder, fileName, ext = 'csv')
	cat('Name of file is...', outputFile, '\n')

	vroom::vroom_write(x = dat, file = outputFile, delim = ',')
	cat('Done writing\n')
}

# Notes
# This is usually a very LARGE file and thus partitioning is difficult
# May need to run partionining on a different cluster set-up
if (TRUE) {

	fileName <- "notes"

	dataFile <- fs::path(home, main, "data", "ccts", "raw", fileName, ext = "csv")

	dat <-
		dataFile |>
		vroom::vroom(
			col_types = "ncnnTTfffc",
			col_select = c(
				record_id = "RECORD_ID",
				encounter_id = "ENCOUNTER_ID",
				author_type = "AUTHOR_TYPE",
				author_service = "SERVICE",
				note_date = "NOTE_DATE",
				note_type = "NOTE_TYPE",
				note_text = "NOTE_TEXT"
			)
		) |>
		dplyr::mutate(note_date = as.Date(note_date)) |>
		dplyr::filter(year == lubridate::year(note_date))
	cat('Read in', dataFile, 'and filtered down by year\n')

	# Output paths
	outputFolder <- fs::path(csv_path, fileName, year)
	cat('Will write this to the folder', outputFolder, '\n')

	if (!fs::dir_exists(outputFolder)) {
		fs::dir_create(outputFolder)
	}

	outputFile <- fs::path(outputFolder, fileName, ext = 'csv')
	cat('Name of file is...', outputFile, '\n')

	vroom::vroom_write(x = dat, file = outputFile, delim = ',')
	cat('Done writing\n')
}

# Procedure Dates
if (FALSE) {
	fileName <- 'procedure-dates'
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
	cat('Read in', dataFile, 'and filtered down by year\n')

	# Output paths
	outputFolder <- fs::path(csv_path, fileName, year)
	cat('Will write this to the folder', outputFolder, '\n')

	if (!fs::dir_exists(outputFolder)) {
		fs::dir_create(outputFolder)
	}

	outputFile <- fs::path(outputFolder, fileName, ext = 'csv')
	cat('Name of file is...', outputFile, '\n')

	vroom::vroom_write(x = dat, file = outputFile, delim = ',')
	cat('Done writing\n')
}

# Procedure Reports
if (FALSE) {

	fileName <- 'procedure-reports'
	dataFile <- fs::path(home, main, 'data', 'ccts', 'raw', fileName, ext = 'csv')

	dat <-
		dataFile |>
		vroom::vroom(
			col_select = c(
				record_id = 'RECORD_ID',
				encounter_id = 'ENCOUNTER_ID',
				procedure_date = 'PROCEDURE_DATE',
				procedure_name = 'PROCEDURE_NAME',
				procedure_report = 'PROCEDURE_REPORT'
			)
		) |>
		dplyr::mutate(date = as.Date(procedure_date)) |>
		dplyr::filter(year == lubridate::year(date))
	cat('Read in', dataFile, 'and filtered down by year\n')

	# Output paths
	outputFolder <- fs::path(csv_path, fileName, year)
	cat('Will write this to the folder', outputFolder, '\n')

	if (!fs::dir_exists(outputFolder)) {
		fs::dir_create(outputFolder)
	}

	outputFile <- fs::path(outputFolder, fileName, ext = 'csv')
	cat('Name of file is...', outputFile, '\n')

	vroom::vroom_write(x = dat, file = outputFile, delim = ',')
	cat('Done writing\n')
}

# Visits
if (FALSE) {
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
	cat('Read in', dataFile, 'and filtered down by year\n')

	# Output paths
	outputFolder <- fs::path(csv_path, fileName, year)
	cat('Will write this to the folder', outputFolder, '\n')

	if (!fs::dir_exists(outputFolder)) {
		fs::dir_create(outputFolder)
	}

	outputFile <- fs::path(outputFolder, fileName, ext = 'csv')
	cat('Name of file is...', outputFile, '\n')

	vroom::vroom_write(x = dat, file = outputFile, delim = ',')
	cat('Done writing\n')
}

# Vitals
if (FALSE) {
	fileName <- 'vitals'
	dataFile <- fs::path(home, main, 'data', 'ccts', 'raw', fileName, ext = 'csv')

	dat <-
		dataFile |>
		vroom::vroom(
			col_select = c(
				record_id = 'RECORD_ID',
				vital_name = 'VITAL_NAME',
				vital_value = 'VALUE',
				vital_units = 'UNIT',
				date_time = 'MEASUREMENT_DATE'
			),
			col_types = 'ncncT'
		) |>
		dplyr::mutate(date = as.Date(date_time)) |>
		dplyr::filter(year == lubridate::year(date))
	cat('Read in', dataFile, 'and filtered down by year\n')

	# Output paths
	outputFolder <- fs::path(csv_path, fileName, year)
	cat('Will write this to the folder', outputFolder, '\n')

	if (!fs::dir_exists(outputFolder)) {
		fs::dir_create(outputFolder)
	}

	outputFile <- fs::path(outputFolder, fileName, ext = 'csv')
	cat('Name of file is...', outputFile, '\n')

	vroom::vroom_write(x = dat, file = outputFile, delim = ',')
	cat('Done writing\n')
}
