library(tidyverse)
dx <- read_csv("./sandbox/data/ccts/raw/diagnosis.csv")
labs <- read_csv("./sandbox/data/ccts/raw/labs.csv")
meds <- read_csv("./sandbox/data/ccts/raw/medications.csv")
notes <- read_csv("./sandbox/data/ccts/raw/notes.csv")
proc <- read_csv("./sandbox/data/ccts/raw/procedure-records.csv")
visits <- read_csv("./sandbox/data/ccts/raw/visits.csv")
vitals <- read_csv("./sandbox/data/ccts/raw/vitals.csv")

# MRNs from REDCAP with DEMO information
# 	Record ID,	MRN, First / Last Name, Last 4 SSN, Birth date
# 	If alive or not (patient status), death date, "cause"
#		Sex, race, ethnicity, zipcode, census_tract, smoking status, insurance
# 	Language, marital status, sexual orientation
demo <- read_csv("./sandbox/data/ccts/raw/redcap-ids.csv")

# Visualize surface ECG ----

library(shiva)
library(tidyverse)
sig <-
	read_wfdb("MUSE_20230515_104804_37000", record_dir = "./sandbox/data/wfdb/051523/") |>
	pivot_longer(cols = I:V6, names_to = "lead", values_to = "voltage") |>
	ggplot(data = _, aes(x = sample, y = voltage, color = lead)) +
	geom_line() +
	facet_wrap(~lead, ncol = 1, scales = "free") +
	theme_minimal()

# Angela needs help on code ----

dx <- read_csv("./sandbox/data/ccts/raw/diagnosis.csv")

dx |>
	select(-starts_with("redcap"), -ENCOUNTER_ID) |>
	filter(str_detect(ICD10_CODE, "I48*"))


# Get the diagnosis data set
# Figure out which column is ICD codes
# Identify if its an ICD9 or 10 code
# If its an ICD9 code, convert it to ICD10
tmp <-
	dx |>
	select(-starts_with("redcap"), -ENCOUNTER_ID) |> # ICD10_CODE
	rename(ICD = ICD10_CODE) |>
	mutate(ICD9_CODE = grepl("^ICD9CM", ICD)) |>
	mutate(ICD10_CODE = !ICD9_CODE)

tmp$ICD <- tmp$ICD10_CODE

