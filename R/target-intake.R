read_in_afib_medications <- function(folderName = fs::path(),
																		 regexFile = fs::path()) {

	med_tbl <- fread(fs::path(folderName, 'medications', ext = 'csv'))
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

read_in_afib_diagnoses <- function(folderName = fs::path()) {

	# Will need to make this "longer"
	# Each ICD code should be on its own line
	dx_tbl <-
		fread(fs::path(folderName, 'diagnosis', ext = 'csv'))[
		][, codeList := strsplit(icd_code, '\\|')
		][, .(icd_code = as.character(unlist(codeList))), by = .(record_id, encounter_id, date)
		][!is.na(icd_code), ]

	x <- dx_tbl[1:10000, ]

	icd::icd10_comorbid_ahrq(x, visit_name = 'encounter_id') |>
		colSums()

}