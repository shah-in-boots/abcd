#!/usr/bin/env Rscript

# Expect argument that is string variable
library(readr)
readr::write_lines("Hello World!\n", file = "test.txt")
