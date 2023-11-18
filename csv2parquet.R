#!/usr/bin/env Rscript

# This file is referenced in the README
# Its purpose is to convert files imported
# Converts from CSV to PARQUET format

# VARIABLES
raw_path <- 'data/ccts/new'
pq_path <- 'data/ccts/pq'

# Get file as an `arrow` ready file
library(tidyverse)
library(arrow)
library(fs)

# Demographics
if (TRUE) {
	file_name <- 'demographics'
	open_dataset(fs::path(raw_path, file_name, ext = 'csv'),
							 col_types = schema(MRN = string()),
							 format = 'csv') |>
		rename_with(tolower) |>
		write_dataset(
			path = pq_path,
			format = 'parquet',
			basename_template = paste0(file_name, '-{i}.parquet')
		)
}

# Diagnosis
if (TRUE) {
	file_name <- 'diagnosis'
	open_dataset(fs::path(raw_path, file_name, ext = 'csv'),
							 format = 'csv') |>
		rename_with(tolower) |>
		mutate(year = format(start_date, '%Y'),
					 month = format(start_date, '%m')) |>
		group_by(year, month) |>
		write_dataset(
			path = pq_path,
			format = 'parquet',
			basename_template = paste0(file_name, '-{i}.parquet')
		)
}

# Labs
if (TRUE) {
	file_name <- 'labs'
	open_dataset(fs::path(raw_path, file_name, ext = 'csv'),
							 format = 'csv') |>
		rename_with(tolower) |>
		mutate(year = format(result_date, '%Y'),
					 month = format(result_date, '%m')) |>
		group_by(year, month) |>
		write_dataset(
			path = pq_path,
			format = 'parquet',
			basename_template = paste0(file_name, '-{i}.parquet')
		)
}

# Medications
if (TRUE) {
	file_name <- 'medications'
	open_dataset(fs::path(raw_path, file_name, ext = 'csv'),
							 format = 'csv') |>
		rename_with(tolower) |>
		mutate(year = format(start_date, '%Y'),
					 month = format(start_date, '%m')) |>
		group_by(year, month) |>
		write_dataset(
			path = pq_path,
			format = 'parquet',
			basename_template = paste0(file_name, '-{i}.parquet')
		)
}

# Notes
if (FALSE) {
	file_name <- 'notes'
	open_dataset(fs::path(raw_path, file_name, ext = 'csv'),
							 format = 'csv') |>
		rename_with(tolower) |>
		mutate(year = format(note_date, '%Y'),
					 month = format(note_date, '%m')) |>
		group_by(year, month) |>
		write_dataset(
			path = pq_path,
			format = 'parquet',
			basename_template = paste0(file_name, '-{i}.parquet')
		)
}

# Procedure Dates
if (TRUE) {
	file_name <- 'procedure-dates'
	open_dataset(fs::path(raw_path, file_name, ext = 'csv'),
							 format = 'csv') |>
		rename_with(tolower) |>
		mutate(year = format(start_date, '%Y'),
					 month = format(start_date, '%m')) |>
		group_by(year, month) |>
		write_dataset(
			path = pq_path,
			format = 'parquet',
			basename_template = paste0(file_name, '-{i}.parquet')
		)
}

# Procedure Reports
if (TRUE) {
	file_name <- 'procedure-reports'
	open_dataset(fs::path(raw_path, file_name, ext = 'csv'),
							 format = 'csv') |>
		rename_with(tolower) |>
		mutate(year = format(procedure_date, '%Y'),
					 month = format(procedure_date, '%m')) |>
		group_by(year, month) |>
		write_dataset(
			path = pq_path,
			format = 'parquet',
			basename_template = paste0(file_name, '-{i}.parquet')
		)
}

# Visits
if (TRUE) {
	file_name <- 'visits'
	open_dataset(fs::path(raw_path, file_name, ext = 'csv'),
							 format = 'csv') |>
		rename_with(tolower) |>
		mutate(year = format(visit_start_date, '%Y'),
					 month = format(visit_start_date, '%m')) |>
		group_by(year, month) |>
		write_dataset(
			path = pq_path,
			format = 'parquet',
			basename_template = paste0(file_name, '-{i}.parquet')
		)
}

# Vitals
if (FALSE) {
	file_name <- 'vitals'
	open_dataset(fs::path(raw_path, file_name, ext = 'csv'),
							 format = 'csv') |>
		rename_with(tolower) |>
		mutate(year = format(measurement_date, '%Y'),
					 month = format(measurement_date, '%m')) |>
		group_by(year, month) |>
		write_dataset(
			path = pq_path,
			format = 'parquet',
			basename_template = paste0(file_name, '-{i}.parquet')
		)
}
