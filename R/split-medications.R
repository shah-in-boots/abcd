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
fileName <- "medications"

dataFile <- fs::path(home, main, "data", "ccts", "raw", fileName, ext = "csv")

dat <-
	dataFile |>
	vroom::vroom(
		col_select = c(
			record_id = "RECORD_ID",
			medication = "MEDICATION_NAME",
			start_date = "START_DATE",
			end_date = "END_DATE"
		),
		col_types = "ncDD"
	) |>
	dplyr::mutate(start_date = lubridate::ymd_hms(start_date)) |>
	dplyr::mutate(end_date = lubridate::ymd_hms(end_date)) |>
	dplyr::mutate(date = as.Date(start_date)) |>
	dplyr::mutate(date = dplyr::case_when(
		2010 >= lubridate::year(date) ~ as.Date("2010-01-01"),
		TRUE ~ date
	)) |>
	dplyr::filter(year == lubridate::year(date))

# Output paths
outputFolder <- fs::path(home, main, "data", "ccts", year)
if (!fs::dir_exists(outputFolder)) {
	fs::dir_create(outputFolder)
}
outputFile <- fs::path(outputFolder, fileName, ext = "tsv")
vroom::vroom_write(x = dat, file = outputFile)
