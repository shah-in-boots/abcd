#!/usr/bin/env Rscript

library(tidyverse)

# Muse files
main <-
	fs::path("~", "projects", "cbcd", "sandbox") |>
	fs::path_expand()

muse <- fs::path(main, "data", "muse")

folders <-
	fs::dir_ls(muse, type = "directory") |>
	fs::path_file()

# Write a TSV file
n <- seq_along(folders)
df <- dplyr::bind_cols(TaskArrayID = n, FolderName = folders)
readr::write_tsv(df, file = fs::path(main, "config-muse.txt"))
