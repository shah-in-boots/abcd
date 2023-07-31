#!/usr/bin/env Rscript

# `filter-demo2mrn` requires a list of MRNs to extra demographics factors from
# Can use a list of MRNs externally, or import our own from the REDCap ID file
# Will create a smaller CSV file that can be put into the "output" folder

# Libraries
library(readr)
library(stringr)
library(dplyr)
library(fs)
library(tibble)
library(vroom)
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

# Create subset of data
out <-
	demo |>
	dplyr::filter(mrn %in% mrnList)


# Output file
outputFile <-
	fs::path(home,
					 main,
					 "output",
					 paste0("AfibByLanguage-", Sys.Date()),
					 ext = "csv")

vroom::vroom_write(out, file = outputFile, delim = ",")

