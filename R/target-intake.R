read_in_redcap_ids <- function(dataFolder = fs::path()) {

	ids <-
		fread(fs::path(dataFolder, 'redcap-ids', ext = 'csv'))[
		][, .(record_id, mrn, birth_date, patient_status, death_date, gender, race, ethnicity, zipcode, census_tract, smoking_status, insurance_type, language, marital_status, sexual_orientation)]

	# Race
	ids[, race_desc := NA_character_
	][, race_desc := fifelse(race == 1, 'native_american', race_desc)
	][, race_desc := fifelse(race == 2, 'asian', race_desc)
	][, race_desc := fifelse(race == 3, 'pacific_islander', race_desc)
	][, race_desc := fifelse(race == 4, 'black', race_desc)
	][, race_desc := fifelse(race == 5, 'white', race_desc)
	][, race_desc := fifelse(race == 6, 'other', race_desc)
	][, race_desc := fifelse(race == 7, NA_character_, race_desc)
	][, race_desc := fifelse(race == 8, NA_character_, race_desc)]

	# Ethnicity
	ids[, ethnicity_desc := NA_character_
	][, ethnicity_desc := fifelse(ethnicity == 1, 'non_hispanic_latino', ethnicity_desc)
	][, ethnicity_desc := fifelse(ethnicity == 2, 'hispanic_latino', ethnicity_desc)
	][, ethnicity_desc := fifelse(ethnicity == 3, NA_character_, ethnicity_desc)
	][, ethnicity_desc := fifelse(ethnicity == 4, NA_character_, ethnicity_desc)]

	# Sex
	ids[, sex := NA_character_
	][, sex := fifelse(gender == 1, 'male', sex)
	][, sex := fifelse(gender == 2, 'female', sex)
	][, sex := fifelse(gender == 0, NA_character_, sex)]

	# Language
	ids[, language := tolower(language)
	][, language := fifelse(!(language %in% c('english', 'spanish')), 'other', language)]

	# Insurance type
	ids[, insurance_desc := NA_character_
	][, insurance_desc := fifelse(insurance_type == 1, 'private', insurance_desc)
	][, insurance_desc := fifelse(insurance_type == 2, 'government', insurance_desc)
	][, insurance_desc := fifelse(insurance_type == 3, 'government', insurance_desc)
	][, insurance_desc := fifelse(insurance_type == 4, 'self_pay', insurance_desc)
	][, insurance_desc := fifelse(insurance_type == 5, 'other', insurance_desc)
	][, insurance_desc := fifelse(insurance_type == 6, NA_character_, insurance_desc)]

	# Smoking
	ids[, smoking_status := tolower(smoking_status)
	][, smoking_status := fifelse(grepl('unknown', smoking_status), NA_character_, smoking_status)
	][, smoking_status := fifelse(grepl('assessed', smoking_status), NA_character_, smoking_status)
	][, smoking_status := fifelse(grepl('smoker|some|every', smoking_status), 'current', smoking_status)]

	# Return
	ids

}

read_in_cardiac_medications <- function(dataFolder = fs::path(),
																				regexFile = fs::path()) {

	# Requires that file has been limited to same number of columns
	# Make require some level of cleaning (e.g. removing false end lines)
	med_tbl <-
		fread(
			fs::path(dataFolder, 'medications', ext = 'csv'),
			fill = TRUE
		)

	med_tbl[, medication := tolower(medication)]

	# This is a long list of medications, need to be filtered
	meds <-
		med_tbl[, medication] |>
		unique()

	# Get regex and clean up before applying
	regexData <-
		readr::read_lines(regexFile) |>
		tolower() |>
		unique() |>
		{\(.x) .x[.x != ""]}() |>
		paste0(collapse = "|")

	cv_meds <-
		grep(regexData, meds, ignore.case = TRUE, value = TRUE) |>
		grep('nacl', x = _, invert = TRUE, value = TRUE) |>
		grep('d5', x = _, invert = TRUE, value = TRUE) |>
		grep('%', x = _, invert = TRUE, value = TRUE) |>
		grep('sterile', x = _, invert = TRUE, value = TRUE) |>
		grep('\ ml', x = _, invert = TRUE, value = TRUE) |>
		grep('vaccine', x = _, invert = TRUE, value = TRUE) |>
		grep('topical', x = _, invert = TRUE, value = TRUE) |>
		grep('supp', x = _, invert = TRUE, value = TRUE) |>
		grep('dev', x = _, invert = TRUE, value = TRUE) |>
		grep('anti', x = _, invert = TRUE, value = TRUE) |>
		grep('ophth', x = _, invert = TRUE, value = TRUE) |>
		grep('otic', x = _, invert = TRUE, value = TRUE) |>
		grep('azole', x = _, invert = TRUE, value = TRUE) |>
		grep('caffeine', x = _, invert = TRUE, value = TRUE) |>
		grep('cefa', x = _, invert = TRUE, value = TRUE) |>
		grep('cetamide', x = _, invert = TRUE, value = TRUE) |>
		grep('silver', x = _, invert = TRUE, value = TRUE) |>
		grep('fiber', x = _, invert = TRUE, value = TRUE) |>
		grep('lutamide', x = _, invert = TRUE, value = TRUE) |>
		grep('resp', x = _, invert = TRUE, value = TRUE) |>
		grep('^glycerin', x = _, invert = TRUE, value = TRUE) |>
		grep('potassium', x = _, invert = TRUE, value = TRUE) |>
		grep('sodium', x = _, invert = TRUE, value = TRUE)

	# Medication filtered down to regex
	med_tbl[medication %in% cv_meds, ]

}

read_in_afib_diagnoses <- function(dataFolder = fs::path()) {

	# Will need to make this "longer"
	# Each ICD code should be on its own line
	dx_tbl <-
		fread(fs::path(dataFolder, 'diagnosis', ext = 'csv'), fill = TRUE)[
		][, codeList := strsplit(icd_code, '\\|')
		][, .(icd_code = as.character(unlist(codeList))), by = .(record_id, encounter_id, date)
		][!is.na(icd_code), ][
		][, date := as.Date(date)]

	cc_tbl <-
		icd::icd10_comorbid_elix(
			dx_tbl,
			visit_name = 'encounter_id',
			icd_name = 'icd_code',
			return_df = TRUE,
			return_binary = TRUE
		) |>
		as.data.table()

	cc_tbl[, encounter_id := as.integer(encounter_id)]

	# Create new data set with "comorbidities" at time points
	id_tbl <- unique(dx_tbl[, .(record_id, encounter_id, date)])
	comorbid_tbl <-
		id_tbl[, .(record_id, encounter_id, date)][
			cc_tbl, on = 'encounter_id'
		]

	# Return comorbid diagnosis by time of diagnosis
	comorbid_tbl

}