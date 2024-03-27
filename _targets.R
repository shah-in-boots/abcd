library(targets)
library(tarchetypes)

# Cluster computing
library(crew)
library(crew.cluster)
controller <- crew_controller_slurm(
  workers = 2L,
  host = "ashah282@aws.acer.uic.edu",
  tasks_max = 2,
  seconds_idle = 30,
  script_lines = "module load R/4.2.1-foss-2022a"
)

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
    "knitr", "gt", "gtsummary", "glue", "rmarkdown",
    # Personal
    "vlndr", "shiva", "card"
  ),
  controller = controller
)

# Scripts

# Targets
list(
  tar_target(cbcd_data_loc, "~/data/cbcd"),
  tar_target(aflubber_data_loc, "~/data/aflubber"),
  tar_target(genetics_data_loc, "~/data/genetics")

)
