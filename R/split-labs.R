# Take each file and split by years
args <- commandArgs(trailingOnly = TRUE)
year <- as.numeric(args[1])

# year <- 2010

# Libraries
library(tidyverse)
library(data.table)
library(vroom)

# Input paths
home <- fs::path_expand("~")
main <- fs::path("projects", "cbcd")
fileName <- "labs"

dataFile <- fs::path(home, main, "data", "ccts", "raw", fileName, ext = "csv")

dat <-
	dataFile |>
	vroom::vroom(
		col_select = c(
			record_id = "RECORD_ID",
			encounter_id = "ENCOUNTER_ID",
			date = "RESULT_DATE",
			lab_name = "LABTEST_NAME",
			lab_value = "VALUE",
			lab_units = "UNIT"
		),
		col_types = "nnDccc"
	) |>
	dplyr::mutate(date = as.Date(date)) |>
	dplyr::filter(year == lubridate::year(date))

# Output paths
outputFolder <- fs::path(home, main, "data", "ccts", year)
if (!fs::dir_exists(outputFolder)) {
	fs::dir_create(outputFolder)
}
outputFile <- fs::path(outputFolder, fileName, ext = "tsv")
vroom::vroom_write(x = dat, file = outputFile)
