#!/usr/bin/env Rscript

# This file is referenced in the README
# 	Its purpose is to convert files imported
# 	Converts from CSV to PARQUET format
# Adjust the following variables as needed
# 	Assumes that the names of all variables are lower case
# 	Will lowercase everything as being renamed

# VARIABLES
raw_path <- 'data/ccts/new'
pq_path <- 'data/ccts/pq'
file_name <- 'visits'
date_col <- 'visit_start_date'

library(tidyverse)
library(arrow)
library(fs)

# Get file as an `arrow` ready file
ds <-
	open_dataset(fs::path(raw_path, file_name, ext = 'csv'),
							 format = 'csv')

# Write out as parquet, partioning as we go
ds |>
	rename_with(tolower) |>
	mutate(year = format(date_col, '%Y'),
				 month = format(date_col, '%m')) |>
	group_by(year, month) |>
	write_dataset(
		path = pq_path,
		format = 'parquet',
		basename_template = paste0(file_name, '-{i}.parquet')
	)
