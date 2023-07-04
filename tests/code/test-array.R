#!/usr/bin/env Rscript

# Expect argument that is string variable
args <- commandArgs(trailingOnly = TRUE)
n <- as.integer(args[1])
msg <- paste0("The SLURM is running a batch job. This is on the n=`", n, "` array job ID.")

library(readr)
readr::write_lines(msg, con = "test.txt")
