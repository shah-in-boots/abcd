#!/usr/bin/env Rscript

# Take each file and split by years
args <- commandArgs(trailingOnly = TRUE)
year <- as.numeric(args[1])

# year <- 2010

# Libraries
library(fs)
library(dplyr)
library(data.table)
library(vroom)

# Input paths
home <- fs::path_expand("~")
main <- fs::path("projects", "cbcd")
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
	dplyr::mutate(date = as.Date(note_date)) |>
	dplyr::filter(year == lubridate::year(date))

# Output paths
outputFolder <- fs::path(home, main, "data", "ccts", year)
if (!fs::dir_exists(outputFolder)) {
	fs::dir_create(outputFolder)
}
outputFile <- fs::path(outputFolder, fileName, ext = "tsv")
vroom::vroom_write(x = dat, file = outputFile)
