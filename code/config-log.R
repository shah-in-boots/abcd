#!/usr/bin/env Rscript

# The `config-log.R` updates the log files throughout the ECG datasets

library(fs)
library(dplyr)
library(readr)
library(vroom)

# Paths
home <- fs::path_expand("~")
main <- fs::path("projects", "cbcd")
wfdb <- fs::path(home, main, "data", "wfdb")
muse <- fs::path(home, main, "data", "muse")

# Log files
wfdbLog <- fs::path(wfdb, "wfdb", ext = "log") 
museLog <- fs::path(muse, "muse", ext = "log") 
ecgpuwaveLog <- fs::path(wfdb, "ecgpuwave", ext = "log")

# WFDB
wfdbLog |>
	readr::read_lines() |>
	unique() |>
	readr::write_lines(file = wfdbLog)

# WFDB
ecgpuwaveLog |>
	readr::read_lines() |>
	unique() |>
	readr::write_lines(file = ecgpuwaveLog)

# MUSE
museLog |>
	readr::read_lines() |>
	unique() |>
	readr::write_lines(file = museLog)
