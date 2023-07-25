#!/usr/bin/env Rscript

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
fileName <- "visits"

dataFile <- fs::path(home, main, "data", "ccts", "raw", fileName, ext = "csv")

dat <-
	dataFile |>
	vroom::vroom(
		col_select = c(
			record_id = "RECORD_ID",
			encounter_id = "ENCOUNTER_ID",
			visit_location = "ENCOUNTER_TYPE",
			visit_type = "VISIT_TYPE",
			visit_discharge = "DISCHARGE_DISPOSITION",
			start_date = "VISIT_START_DATE",
			end_date = "VISIT_END_DATE"
		),
		col_types = "nncccTT"
	)
	dplyr::mutate(date = as.Date(start_date)) |>
	dplyr::filter(year == lubridate::year(date))

# Output paths
outputFolder <- fs::path(home, main, "data", "ccts", year)
if (!fs::dir_exists(outputFolder)) {
	fs::dir_create(outputFolder)
}
outputFile <- fs::path(outputFolder, fileName, ext = "tsv")
vroom::vroom_write(x = dat, file = outputFile)
