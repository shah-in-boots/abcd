# `csv2parquet.R` is the code set required to both open and write <CSV> to
# <PARQUET> format, which both saves on file size and allows for more
# efficiently partitioned data. The pre-requisite is that the datasets have been
# organized and prepared by the `split-ccts.R` code (which breaks the files down
# by year). Both of these are incorporated into the SLURM command instructed by
# `partition-ccts.sh`.
#
# Currently, the partitioning strategy is to place files by their topic (e.g.
# medications) in a folder and then subdivide by year. This could change as
# modifications to the data are made.
#
# Note: this file should likely only be run on a cluster based on file sizes

# Get the trailing argument, which tells which element to evaluate
args <- commandArgs(trailingOnly = TRUE)
type <- as.character(args[1])
cat('Will work on ', type, 'file \n')

# Libraries
library(tidyverse)
library(arrow)
library(fs)

# Variables & paths for root data storage
csv_path <- '~/ccts/emr/csv'
pq_path <- '~/ccts/emr/pq'

# Demographics
if (type == 'demographics') {
	file_name <- type
	open_dataset(fs::path(csv_path, file_name, ext = 'csv'),
							 col_types = schema(MRN = string()),
							 format = 'csv') |>
		rename_with(tolower) |>
		write_dataset(
			path = pq_path,
			format = 'parquet',
			basename_template = paste0(file_name, '-{i}.parquet'),
			max_rows_per_file = 1e8,
			existing_data_behavior = 'overwrite'
		)
}

# Diagnosis
if (type == 'diagnosis') {
	file_name <- type
	open_dataset(fs::path(csv_path, file_name),
							 partitioning = 'year',
							 format = 'csv') |>
		group_by(year) |>
		write_dataset(
			path = fs::path(pq_path, file_name),
			format = 'parquet',
			basename_template = paste0(file_name, '-{i}.parquet'),
			max_rows_per_file = 1e8,
			existing_data_behavior = 'overwrite'
		)
}

# Labs
if (type == 'labs') {
	file_name <- type
	open_dataset(fs::path(csv_path, file_name),
							 partitioning = 'year',
							 format = 'csv') |>
		group_by(year) |>
		write_dataset(
			path = fs::path(pq_path, file_name),
			format = 'parquet',
			basename_template = paste0(file_name, '-{i}.parquet'),
			max_rows_per_file = 1e8,
			existing_data_behavior = 'overwrite'
		)
}

# Medications
if (type == 'medications') {
	file_name <- type
	open_dataset(fs::path(csv_path, file_name),
							 partitioning = 'year',
							 format = 'csv') |>
		group_by(year) |>
		write_dataset(
			path = fs::path(pq_path, file_name),
			format = 'parquet',
			basename_template = paste0(file_name, '-{i}.parquet'),
			max_rows_per_file = 1e8,
			existing_data_behavior = 'overwrite'
		)
}

# Notes
if (type == 'notes') {
	file_name <- type
	open_dataset(fs::path(csv_path, file_name),
							 partitioning = 'year',
							 format = 'csv') |>
		group_by(year) |>
		write_dataset(
			path = fs::path(pq_path, file_name),
			format = 'parquet',
			basename_template = paste0(file_name, '-{i}.parquet'),
			max_rows_per_file = 1e8,
			existing_data_behavior = 'overwrite'
		)
}

# Procedure Dates
if (type == 'procedure-dates') {
	file_name <- type
	open_dataset(fs::path(csv_path, file_name),
							 partitioning = 'year',
							 format = 'csv') |>
		group_by(year) |>
		write_dataset(
			path = fs::path(pq_path, file_name),
			format = 'parquet',
			basename_template = paste0(file_name, '-{i}.parquet'),
			max_rows_per_file = 1e8,
			existing_data_behavior = 'overwrite'
		)
}

# Procedure Reports
if (type == 'procedure-reports') {
	file_name <- type
	open_dataset(fs::path(csv_path, file_name),
							 partitioning = 'year',
							 format = 'csv') |>
		group_by(year) |>
		write_dataset(
			path = fs::path(pq_path, file_name),
			format = 'parquet',
			basename_template = paste0(file_name, '-{i}.parquet'),
			max_rows_per_file = 1e8,
			existing_data_behavior = 'overwrite'
		)
}

# Visits
if (type == 'visits') {
	file_name <- type
	open_dataset(fs::path(csv_path, file_name),
							 partitioning = 'year',
							 format = 'csv',
							 schema = Schema(
							 	record_id = int32(),
							 	encounter_id = int32(),
							 	visit_location = utf8(),
							 	visit_type = utf8(),
							 	visit_discharge = utf8(),
							 	start_date = timestamp(),
							 	end_date = timestamp()
							 )) |>
		group_by(year) |>
		write_dataset(
			path = fs::path(pq_path, file_name),
			format = 'parquet',
			basename_template = paste0(file_name, '-{i}.parquet'),
			max_rows_per_file = 1e8,
			existing_data_behavior = 'overwrite'
		)
}

# Vitals
if (type == 'vitals') {
	file_name <- type
	open_dataset(fs::path(csv_path, file_name),
							 partitioning = 'year',
							 format = 'csv') |>
		group_by(year) |>
		write_dataset(
			path = fs::path(pq_path, file_name),
			format = 'parquet',
			basename_template = paste0(file_name, '-{i}.parquet'),
			max_rows_per_file = 1e8,
			existing_data_behavior = 'overwrite'
		)
}
