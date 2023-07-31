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

dx <-
	read_csv("./output/AfibByLanguage-2023-07-31.csv") |>
	select(birth_date, patient_status, death_date, gender, race, ethnicity, zipcode, census_tract, smoking_status, insurance_type, language) |>
	filter(language %in% c("English", "Spanish"))

dx |>
	select(-zipcode, -census_tract, -death_date) |>
	tbl_summary(by = language) |>
	add_p() |>
	add_overall()

write_csv(dx, "./output/SpanishAfib-2023-07-31.csv")
