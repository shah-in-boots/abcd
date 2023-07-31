#!/usr/bin/env Rscript

# `filter-*2id` should be run after converting XML to WFDB format
# It will create a list of MUSE ECGs based on an input file name.
# The input file must be a TSV with a column of MRNs included
# MRNs will then be sought out in the WFDB files.
#
# Outputs a directory file with... (similar to directory structure)
# 	FOLDER
# 	NAME (MUSE_ID)
# 	MRN
# 	DATE + TIME

# Libraries
library(readr)
library(stringr)
library(fs)
library(tibble)
library(data.table)
library(dplyr)
library(collapse)
library(vroom)

# General paths
home <- fs::path_expand("~")
main <- fs::path("projects", "cbcd")

# Need all of the "AF MRNs" available, and get the record ids
key <-
	fs::path(home, main, "data", "ccts", "proc", "redcap-ids", ext = "csv") |>
	vroom::vroom(col_types = "ii", col_select = c(record_id, mrn)) |>
	janitor::clean_names() |>
	data.table::as.data.table()

# This would be the medications list (raw) that needs to be processed
# Roughly 2-3 Gb
meds <-
	fs::path(home, main, "data", "ccts", "raw", "medications", ext = "csv") |>
	vroom::vroom() |>
	janitor::clean_names() |>
	dplyr::select(record_id, encounter_id, medication_name, start_date, end_date) |>
	data.table::as.data.table()

# Simple filter of demographic files based on MRN
newMeds <- meds[key, on = "record_id"]

# Output file
out <- fs::path(home, main, "data", "ccts", "proc", "medications", ext = "csv")
vroom::vroom_write(newMeds, file = out)
