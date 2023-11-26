# `csv2parquet.R` is the code set required to both open and write <CSV> to <PARQUET> format, which both saves on file size and allows for more efficiently partitioned data. The pre-requisite is that the datasets have been organized and prepared by the `split-ccts.R` code (which breaks the files down by year). Both of these are incorporated into the SLURM command instructed by `partition-ccts.sh`. 
# 
# Currently, the partitioning strategy is to place files by their topic (e.g. medications) in a folder and then subdivide by year. This could change as modifications to the data are made.

# Libraries
library(tidyverse)
library(arrow)
library(fs)

# Variables & paths for root data storage
csv_path <- 'data/ccts/csv'
pq_path <- 'data/ccts/pq'

# Demographics
if (TRUE) {
	file_name <- 'demographics'
	open_dataset(fs::path(csv_path, file_name, ext = 'csv'),
							 col_types = schema(MRN = string()),
							 format = 'csv') |>
		rename_with(tolower) |>
		write_dataset(
			path = pq_path,
			format = 'parquet',
			basename_template = paste0(file_name, '-{i}.parquet'),
			max_rows_per_file = 1e8,
			existing_data_behavior = 'delete_matching'
		)
}

# Diagnosis
if (TRUE) {
	file_name <- 'diagnosis'
	open_dataset(fs::path(csv_path, file_name),
							 partitioning = 'year', 
							 format = 'csv') |>
		group_by(year) |>
		write_dataset(
			path = fs::path(pq_path, file_name),
			format = 'parquet',
			basename_template = paste0(file_name, '-{i}.parquet'),
			max_rows_per_file = 1e8,
			existing_data_behavior = 'delete_matching'
		)
}

# Labs
if (TRUE) {
	file_name <- 'labs'
	open_dataset(fs::path(csv_path, file_name),
							 partitioning = 'year', 
							 format = 'csv') |>
		group_by(year) |>
		write_dataset(
			path = fs::path(pq_path, file_name),
			format = 'parquet',
			basename_template = paste0(file_name, '-{i}.parquet'),
			max_rows_per_file = 1e8,
			existing_data_behavior = 'delete_matching'
		)
}

# Medications
if (TRUE) {
	file_name <- 'medications'
	open_dataset(fs::path(csv_path, file_name),
							 partitioning = 'year', 
							 format = 'csv') |>
		group_by(year) |>
		write_dataset(
			path = fs::path(pq_path, file_name),
			format = 'parquet',
			basename_template = paste0(file_name, '-{i}.parquet'),
			max_rows_per_file = 1e8,
			existing_data_behavior = 'delete_matching'
		)
}

# Notes
if (TRUE) {
	file_name <- 'notes'
	open_dataset(fs::path(csv_path, file_name),
							 partitioning = 'year', 
							 format = 'csv') |>
		group_by(year) |>
		write_dataset(
			path = fs::path(pq_path, file_name),
			format = 'parquet',
			basename_template = paste0(file_name, '-{i}.parquet'),
			max_rows_per_file = 1e8,
			existing_data_behavior = 'delete_matching'
		)
}

# Procedure Dates
if (TRUE) {
	file_name <- 'procedure-dates'
	open_dataset(fs::path(csv_path, file_name),
							 partitioning = 'year', 
							 format = 'csv') |>
		group_by(year) |>
		write_dataset(
			path = fs::path(pq_path, file_name),
			format = 'parquet',
			basename_template = paste0(file_name, '-{i}.parquet'),
			max_rows_per_file = 1e8,
			existing_data_behavior = 'delete_matching'
		)
}

# Procedure Reports
if (TRUE) {
	file_name <- 'procedure-reports'
	open_dataset(fs::path(csv_path, file_name),
							 partitioning = 'year', 
							 format = 'csv') |>
		group_by(year) |>
		write_dataset(
			path = fs::path(pq_path, file_name),
			format = 'parquet',
			basename_template = paste0(file_name, '-{i}.parquet'),
			max_rows_per_file = 1e8,
			existing_data_behavior = 'delete_matching'
		)
}

# Visits
if (TRUE) {
	file_name <- 'visits'
	open_dataset(fs::path(csv_path, file_name),
							 partitioning = 'year', 
							 format = 'csv') |>
		group_by(year) |>
		write_dataset(
			path = fs::path(pq_path, file_name),
			format = 'parquet',
			basename_template = paste0(file_name, '-{i}.parquet'),
			max_rows_per_file = 1e8,
			existing_data_behavior = 'delete_matching'
		)
}

# Vitals
if (TRUE) {
	file_name <- 'vitals'
	open_dataset(fs::path(csv_path, file_name),
							 partitioning = 'year', 
							 format = 'csv') |>
		group_by(year) |>
		write_dataset(
			path = fs::path(pq_path, file_name),
			format = 'parquet',
			basename_template = paste0(file_name, '-{i}.parquet'),
			max_rows_per_file = 1e8,
			existing_data_behavior = 'delete_matching'
		)
}
