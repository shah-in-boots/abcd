library(targets)
library(tarchetypes)

# Cluster computing
library(crew)
library(crew.cluster)
controller <- crew_controller_slurm(
  workers = 2L,
  host = "ashah282@aws.acer.uic.edu",
  seconds_idle = 30,
  script_directory = "~/projects/cbcd/jobs",
  script_lines = "module load R/4.2.1-foss-2022a",
  verbose = TRUE,
  slurm_log_output = "crew_log_%A.txt",
  slurm_log_error = "crew_log_%A.txt",
  slurm_cpus_per_task = 2,
  slurm_partition = "cpu-t3"
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
  tar_target(genetics_data_loc, "~/data/genetics"),

  tar_target(datasetA, sum(1:10)),
  tar_target(outputA, writeLines(dataset, con = "output-a.txt")),

  tar_target(datasetB, sum(11:20)),
  tar_target(outputB, writeLines(dataset, con = "output-b.txt")),
)
