#!/usr/bin/env Rscript

library(tidyverse)

pwd <- getwd()
readr::write_lines(pwd, file = "notes.txt")
