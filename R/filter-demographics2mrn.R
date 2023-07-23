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
library(dplyr)
library(fs)
library(tibble)
library(collapse)

# General paths
home <- fs::path_expand("~")
main <- fs::path("projects", "cbcd")

# Need all of the "AF MRNs" available
mrnFile <-
	fs::path(home, main, "output", "ECG-AFibDiagnosis", ext = "tsv") |>
	vroom::vroom(col_types = "cicc")
mrnList <- collapse::funique(mrnFile$MRN)

# Input file is the CCTS dataset of interest
demo <-
	fs::path(home, main, "data", "ccts", "raw", "redcap-ids", ext = "csv") |>
	vroom::vroom(
		col_select = c(record_id, mrn:sexual_orientation)
	)

# Output file
out <- fs::path(home, main, "data", "ccts", "proc", "redcap-ids", ext = "csv")

# Simple filter of demographic files based on MRN
demo |>
	dplyr::filter(mrn %in% mrnList) |>
	vroom::vroom_write(file = out)

