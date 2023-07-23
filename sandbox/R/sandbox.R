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
