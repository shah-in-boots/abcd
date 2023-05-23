library(targets)
library(tarchetypes)

# Options
tar_option_set(
  packages = c(
    # Systems and cluster computing
    "reticulate", "Microsoft365R",
    # Personal libraries,
    "shiva",
    # Specific data type handling
    "data.table", "xml2",
    # Wrangling
    "tibble", "tidyverse", "here", "fs"
    ), # packages that your targets need to run
  format = "rds" # default storage format
  # Set other options as needed.
)

# tar_make_clustermq() configuration (okay to leave alone):
options(clustermq.scheduler = "multicore")

# tar_make_future() configuration (okay to leave alone):
future::plan(future.callr::callr)

# Scripts
tar_source()

# Targets
list(
  # Setup
  tar_target(data_loc, find_data_folder()),

  # ECG pipeline
  tar_files(ecg_xml_files, find_ecg_files(file.path(data_loc, "cbcd/muse"))),
  tar_target(ecg_wfdb_format, convert_ecg_to_wfdb(ecg_xml_files))
)
