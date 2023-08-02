#!/usr/bin/env Rscript

# The `config-wfdb.R` script is to evaluate the contents of the WFDB datasets
# The purpose is to help with batch scripting in SLURM
# It will create and/or update a file that identifies the number of WFDB folders
# Probably appropriate to run at end of conversion script

library(fs)
library(dplyr)
library(readr)

# WFDB paths
home <- fs::path_expand("~")
main <- fs::path("projects", "cbcd")
wfdb <- fs::path(home, main, "data", "wfdb")
folders <-
	fs::dir_ls(wfdb, type = "directory") |>
	fs::path_file()
config <- fs::path(home, main, "config-wfdb", ext = "txt")

# Write a TSV file for future slurm arrays
n <- seq_along(folders)
df <- dplyr::bind_cols(TaskArrayID = n, FolderName = folders)
readr::write_tsv(df, file = fs::path(config))
