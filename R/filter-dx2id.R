#!/usr/bin/env Rscript

# `match-diagnosis2mrn` should be run after converting XML to WFDB format
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

# This would be the labs obtained (where and when)
# Roughly 1-2 Gb
diagnosis <-
	fs::path(home, main, "data", "ccts", "raw", "diagnosis", ext = "csv") |>
	vroom::vroom() |>
	janitor::clean_names() |>
	dplyr::select(record_id, encounter_id, start_date, icd10_code) |>
	data.table::as.data.table()

# Simple filter of demographic files based on MRN
newDiagnosis <- diagnosis[key, on = "record_id"]

# Output file
out <- fs::path(home, main, "data", "ccts", "proc", "diagnosis", ext = "csv")
vroom::vroom_write(newDiagnosis, file = out)
