library(fs)
library(here)
library(vroom)
library(readr)
library(dplyr)
library(tibble)

setwd(here::here())
wes <- vroom("sandbox/wes-af-fork.csv")

key <- 
	wes |>
	select(mrn, study_id) |>
	na.omit() |>
	unique()

genes <-
	wes |>
	select(study_id, gene_name, gene_sequence, gene_acmg) |>
	filter(!is.na(gene_name))
