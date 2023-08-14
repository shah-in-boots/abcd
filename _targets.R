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
    # Wrangling
    'tibble', 'tidyverse', 'here', 'fs', 'vroom',
    # Modeling,
    'tidymodels'
    ), # packages that your targets need to run
  format = 'rds' # default storage format
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

  # SDOH ----
  tar_target(
    clinical_afib_data,
    read_clinical_afib_data(folderName = fs::path(data_loc, 'ccts', 'sdoh'))
  )

  # WES ----
)
