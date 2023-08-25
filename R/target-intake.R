read_in_afib_medications <- function(dataFolder = fs::path(),
																		 regexFile = fs::path()) {

	med_tbl <-
		fread(
			fs::path(dataFolder, 'medications', ext = 'csv'),
			fill = TRUE
		)

	x <- vroom::vroom(
			fs::path(dataFolder, 'medications', ext = 'csv'),
			delim = ','
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