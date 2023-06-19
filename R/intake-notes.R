library(fs)
library(tidyverse)

# File path
data_dir <- fs::fs_path("/shared/home/ashah282/data/ccts/")
raw_data <- fs::path(data_dir, 'raw', 'notes.csv')

# Read in data (subset)
df <- read_csv(raw_data, n_max = 100)

write_csv(df, fs::path(data_dir, "proc", "notes.csv"))
