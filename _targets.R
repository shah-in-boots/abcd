library(targets)
library(tarchetypes)
library(crew)

# Options
tar_option_set(
  packages = c(
    # Infrastructure
    "targets", "tarchetypes", "crew", "crew.cluster",
    "here", "fs",
    "arrow", "qs", "fst",
    # Data intake and cleaning
    "REDCapR",
    "tidyverse", "lubridate", "clock",
    "janitor", "tidytext",
    "data.table", "xlsx", "readxl",
    # Epidemiology
    "survival",
    # Clinical
    "comorbidity",
    # Machine learning
    "tidymodels",
    "reticulate", "tensorflow", "tfdatasets", "keras",
    # Presenting
    "knitr", "gt", "gtsummary", "glue",
    "ggdag", "ggsurvfit", "ggsci",
    # Validating
    "labelled", "pointblank", "naniar",
    # Personal
    "vlndr", "shiva", "card"
  )
)

# tar_make_clustermq() configuration (okay to leave alone):
options(clustermq.scheduler = "multicore")

# tar_make_future() configuration (okay to leave alone):
future::plan(future.callr::callr)

# Scripts
source("R/target-options.R")
source("R/target-intake.R")
source("R/target-tidy.R")

# Targets
list(

  # General ----
  tar_target(data_loc, fs::path(here::here(), "data")),
  tar_target(afib_data_loc, fs::path(data_loc, "ccts", "afib")),

  tar_target(
    cardiac_medications, # Simplified CV meds
    read_in_cardiac_medications(dataFolder = afib_data_loc,
                           regexFile = "regex-meds.txt")
  ),

  # AFIB ----

  tar_target(afib_ids, read_in_redcap_ids(dataFolder = afib_data_loc)),

  tar_target(afib_medications, tidy_afib_medications(meds = cardiac_medications)),

  tar_target(
    afib_diagnoses, # Diagnoses converted to comorbidities at time point
    read_in_afib_diagnoses(dataFolder = afib_data_loc)
  ),

  tar_quarto(sdoh_slides, "output/slides-sdoh.qmd")

  # WES ----
)
