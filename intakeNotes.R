#!/usr/bin/env Rscript

library(tidyverse)
library(data.table)

pwd <- getwd()
readr::write_lines(pwd, file = "notes.txt", append = TRUE)
