#!/usr/bin/env Rscript
cat("Loading libraries")
library(fs)
library(tidyverse)

# File path
cat("Identifying file paths")
#data_dir <- fs::fs_path("/shared/home/ashah282/projects/cbcd/data/ccts/")
#raw_data <- fs::path(data_dir, 'raw', 'notes.csv')
getwd()


# Read in data (subset)
cat("Reading in data")
#df <- readr::read_csv(raw_data, n_max = 100)

#write_csv(df, fs::path(data_dir, "proc", "notes.csv"))
