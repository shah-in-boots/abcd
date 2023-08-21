library(targets)
library(tarchetypes)

# Options
tar_option_set(
  packages = c(
    # Systems and cluster computing
    'reticulate',
    # Personal libraries,
    'shiva', 'volundr',
    # Specific data type handling
    'data.table', 'xml2',
    # Content specific (e.g. clinical)
    'icd',
    # Wrangling
    'tibble', 'tidyverse', 'here', 'fs', 'vroom',
    # Modeling,
    'tidymodels'
    ), # packages that your targets need to run
  format = 'qs' # default storage format
  # Set other options as needed.
)

# tar_make_clustermq() configuration (okay to leave alone):
options(clustermq.scheduler = 'multicore')

# tar_make_future() configuration (okay to leave alone):
future::plan(future.callr::callr)

# Scripts
source('R/target-options.R')
source('R/target-intake.R')

# Targets
list(
  # Setup
  tar_target(data_loc, fs::path(here::here(), 'data')),
  tar_target(afib_data_loc, fs::path(data_loc, 'ccts', 'afib')),

  # AFIB ----
  tar_target(
    afib_medications,
    read_in_afib_medications(folderName = afib_data_loc)
  ),

  tar_target(

  )

  # WES ----
)
