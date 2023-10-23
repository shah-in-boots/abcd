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

# CCTS data for TTE ----

library(gtsummary)
ids <- vroom::vroom_lines('output/mrn-hf.txt')
dat <-
	vroom::vroom('data/ccts/raw/redcap-ids.csv',
							 col_types = list(mrn = 'c')) |>
	filter(mrn %in% ids) |>
	select(age, gender, race, insurance_type)

dat |>
	mutate(race = case_when(
		race == 1 ~ 'American Indian or Alaskan',
		race == 2 ~ 'Asian',
		race == 3 ~ 'Native Hawaiian or Pacific Islander',
		race == 4 ~ 'Black or African American',
		race == 5 ~ 'White',
		race == 6 ~ 'Other race',
		race == 7 ~ 'Patient declined',
		race == 8 ~ 'No information'
	)) |>
	mutate(insurance_type = case_when(
		insurance_type == 1 ~ 'Private insurance',
		insurance_type == 2 ~ 'Medicaid',
		insurance_type == 3 ~ 'Medicare',
		insurance_type == 4 ~ 'Self-pay',
		insurance_type == 5 ~ 'Other',
		insurance_type == 6 ~ 'No information'
	)) |>
	mutate(gender = case_when(
		gender == 0 ~ 'Unknown',
		gender == 1 ~ 'Male',
		gender == 2 ~ 'Female'
	)) |>
	tbl_summary(by = race)




