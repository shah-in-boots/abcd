#!/usr/bin/env Rscript

library(fs)
library(tidyverse)
library(data.table)

# File path
data_dir <- fs::fs_path("/shared/home/ashah282/data/ccts/")
raw_data <- fs::path(data_dir, 'raw', 'notes.csv')

# Read in data (subset)
dt <- fread(raw_data, nrows = 500)

fwrite(dt, fs::path(data_dir, "proc", "notes.csv"))
