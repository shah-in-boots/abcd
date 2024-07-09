# This is non-cluster dependent series of functions
# Can be run on local computer as well
# Data is located in ~/data/cohorts/*
# This is a file_directory of 'parquet' files
# Need to read in individual file types and clean them
# Each file will be specific in how we want to "clean" the data

read_cbcd_demographics <- function(file_dir) {
	
	# Read in data for demographics
	# The MRN will clash unless they are all numeric
	demo <-
		arrow::open_dataset(
			fs::path(file_dir, 'demographics-0.parquet'),
			format = 'parquet',
			partitioning = 'year',
			unify_schemas = TRUE
		) |>
		mutate(hospital = 'uic') |>
		select(-first_name, -last_name, -ssn) |>
		mutate(cause_of_death = tolower(if_else(cause_of_death == '', NA_character_, cause_of_death))) |>
		mutate(geoid = if_else(census_tract == '', NA_character_, census_tract)) |>
		mutate(mrn = as.numeric(mrn)) |>
		collect()
	
	# Return
	demo
}

read_cbcd_diagnosis <- function(file_dir) {
	
	# Read in data for diagnosis
	dx <-
		arrow::open_dataset(
			fs::path(file_dir, "diagnosis"),
			format = "parquet",
			partitioning = "year",
			unify_schemas = TRUE
		) |>
		mutate(id_date = paste(record_id, date, sep = "_")) |>
		collect()
	
	# Map out comorbidities
	dc <-
		comorbidity::comorbidity(
			dx,
			id = "id_date",
			code = "icd_code",
			assign0 = FALSE,
			map = "charlson_icd10_quan"
		) 
	
	# Now combine dataset `dx` and `dc` to get the comorbidity scores
	# Will merge on the column `id_date`
	dat <- 
		left_join(dx, dc, by = "id_date") |>
		select(-id_date, -icd_code) |>
		distinct()
	
	# Return
	dat
}

read_cbcd_labs <- function(file_dir) {
	
	# Read in data for lab results using arrow package
	
	# Roughly ~150 labs values are possible
	# Need to select the most useful labs to pare down list
	# Will place these in a string and search for them in the dataset
	# Key labs are:
	# 	Albumin
	# 	Calcium
	# 	Creatinine, BUN
	# 	Sodium
	# 	Potassium
	# 	Prothrombin time, PT/INR, INR
	# 	HGB, Hemoglobin
	# 	HGB A1c, Hemoglobin A1c
	# 	LDL, HDL, Cholesterol
	#		BNP, Natriuretic peptide B
	# 	C reactive protein, CRP
	# 	Troponin I
	labs <-
		arrow::open_dataset(
			fs::path(file_dir, 'labs'),
			format = 'parquet',
			partitioning = 'year',
			unify_schemas = TRUE
		) |>
		# Lower case before string matching
		mutate(lowercase_lab = tolower(lab_name),
									lab_units = tolower(lab_units)) |>
		filter(str_detect(lowercase_lab, 'creatinine|sodium|potassium|prothrombin|pt/inr|inr|hgb|hemoglobin|hgb a1c|hemoglobin a1c|ldl|hdl|cholesterol|bnp|natriuretic peptide b|c reactive protein|crp|troponin|troponin i')) |>
		# Remove unwanted lab results using negating str_detect
		filter(str_detect(lowercase_lab, 'urine| ur|ur |,ur|-ur |ratio|24hr|24|gfr|glomerular|poor', negate = TRUE)) |>
		# Now, combine all the similar sounding labs to a single value
		# Start with troponin, and change high-sensitivity to the correct values
		mutate(lab_name = case_when(
			str_detect(lowercase_lab, 'troponin') ~ 'TROPONIN_LS',
			str_detect(lowercase_lab, 'high sensitivity') ~ 'TROPONIN_HS',
			TRUE ~ lab_name
		)) |>
		# Cholesterol values
		mutate(lab_name = case_when(
			str_detect(lowercase_lab, 'hdl') ~ 'HDL',
			str_detect(lowercase_lab, 'ldl') ~ 'LDL',
			str_detect(lowercase_lab, 'cholesterol') ~ 'TOTAL_CHOLESTEROL',
			TRUE ~ lab_name
		)) |>
		# Creatinine
		mutate(lab_name = case_when(
			str_detect(lowercase_lab, 'creatinine') ~ 'CREATININE',
			str_detect(lowercase_lab, 'bun') ~ 'BUN',
			TRUE ~ lab_name
		)) |>
		# INR
		mutate(lab_name = case_when(
			str_detect(lowercase_lab, 'prothrombin') ~ 'PROTHROMBIN_TIME',
			str_detect(lowercase_lab, 'inr') ~ 'INR',
			TRUE ~ lab_name
		)) |>
		filter(str_detect(lowercase_lab, 'pt-inr', negate = TRUE)) |>
		# Potassium
		mutate(lab_name = case_when(
			str_detect(lowercase_lab, 'potassium') ~ 'POTASSIUM',
			TRUE ~ lab_name
		)) |>
		# Sodium
		mutate(lab_name = case_when(
			str_detect(lowercase_lab, 'sodium') ~ 'SODIUM',
			TRUE ~ lab_name
		)) |>
		# Hemoglobin A1c need to be evaluated at same time as hemoglobin
		mutate(lab_name = case_when(
			str_detect(lowercase_lab, 'a1c') ~ 'HEMOGLOBIN_A1C',
			str_detect(lowercase_lab, 'hemoglobin|hgb') ~ 'HEMOGLOBIN',
			TRUE ~ lab_name
		)) |>
		# CRP
		mutate(lab_name = case_when(
			str_detect(lowercase_lab, 'c reactive') ~ 'CRP',
			TRUE ~ lab_name
		)) |>
		# BNP
		mutate(lab_name = case_when(
			str_detect(lowercase_lab, 'bnp') ~ 'BNP',
			str_detect(lowercase_lab, 'natriuretic') ~ 'BNP',
			TRUE ~ lab_name
		)) |>	
		select(-lowercase_lab) |>
		collect()
		
	# Labs are cleaned and simplified now
	labs
	
}

read_cbcd_medications <- function(file_dir, med_file) {
	
	# Select all the cardiac medications only
	regMeds <- 
		vroom::vroom_lines(med_file) |>
		# Get rid of empty spaces
		gsub('^$', NA_character_, x = _) |>
		# Add anchors
		gsub('^\\*', '^*', x = _) |>
		na.omit() |>
		paste0(collapse = '|')
	
	# Read in data for medications
	# Apply initial regex filter
	meds <-
		arrow::open_dataset(
			fs::path(file_dir, 'medications'),
			format = 'parquet',
			partitioning = 'year',
			unify_schemas = TRUE
		) |>
		mutate(
			medication = tolower(medication),
			dose_route = tolower(dose_route)
		) |>
		filter(str_detect(medication, regex(regMeds))) |>
		filter(str_detect(medication, 'prami|^glycerin|dialysis|azole|tpn|tadine|ophthalmic|topical|flush|^potassium|^sod|nasal|heparin|silver|magnesium', negate = TRUE)) |>
		filter(str_detect(dose_route, 'ear|eye|swish|neb|topical|nostril|lock|infiltration|intramuscular|sublingual|arterial|catheter|intra|irrigation|vaginal|misc|iv|intravenous|intra', negate = TRUE)) |>
		collect()
	
}

read_cbcd_notes <- function(file_dir) {
	
	# Read in data for notes
	notes <-
		arrow::open_dataset(
			fs::path(file_dir, 'notes'),
			format = 'parquet',
			partitioning = 'year',
			unify_schemas = TRUE
		) |>
		mutate(
			author_type = tolower(author_type),
			note_type = tolower(note_type)
		) |>
		filter(author_type %in% c('physician', 'resident')) |>
		filter(str_detect(note_type, 'cardiology|cardio|cardiac||history|consult|general|medicine|emergency|endocrinology|surgery|pulmonary|transfer|eps')) |>
		collect()
	
}

read_cbcd_procedure_dates <- function(file_dir) {
	
	icd9 <- card::procedure_codes('icd9', 2014)
	icd10 <- card::procedure_codes('icd10', 2023)
	hcpcs <- card::procedure_codes('hcpcs', 2023)
	cpt <- card::procedure_codes('cpt', 2023)
	
	# Read in data for procedures-dates
	proc <- 
		arrow::open_dataset(
			fs::path(file_dir, 'procedure-dates'),
			format = 'parquet',
			partitioning = 'year',
			unify_schemas = TRUE
		) |>
		mutate(coding_system = if_else(
			coding_system == 'ICD10PCS' &
				str_detect(procedure_code, 'ICD9PROC'),
			'ICD9PROC',
			coding_system
		)) |>
		mutate(procedure_code = if_else(
			coding_system == 'ICD9PROC',
			gsub("ICD9PROC:", "", procedure_code),
			procedure_code
		)) |>
		mutate(procedure_code = if_else(
			coding_system == 'ICD9PROC',
			gsub("\\.", "", procedure_code),
			procedure_code
		)) |>
		collect() 
	
	# Combine icd9, icd10, hcpcs, and cpt descriptions with proc data
	# Need to merge by procedure_code depending on the coding_system
	#proc$procedure_description <- NA_character_
	proc_icd9 <- 
		proc[proc$coding_system == 'ICD9PROC', ] |>
		mutate(procedure_description = icd9[match(.data$procedure_code, icd9$code), 'description'][[1]])
	proc_icd10 <- 
		proc[proc$coding_system == 'ICD10PCS', ] |>
		mutate(procedure_description = icd10[match(.data$procedure_code, icd10$code), 'description'][[1]])
	proc_hcpcs <- 
		proc[proc$coding_system == 'HCPCS', ] |>
		mutate(procedure_description = hcpcs[match(.data$procedure_code, hcpcs$code), 'description'][[1]])
	proc_cpt <-
		proc[proc$coding_system == 'CPT', ] |>
		mutate(procedure_description = cpt[match(.data$procedure_code, cpt$code), 'description'][[1]])
	
	# Bind them together
	dat <-
		bind_rows(
			proc_icd9,
			proc_icd10,
			proc_hcpcs,
			proc_cpt
		) |>
		select(
			-procedure_code,
			-coding_system
		) |>
		distinct()
	
	# Return the data
	return(dat)
	
}

read_cbcd_procedure_reports <- function(file_dir) {
	
	# Read in data for procedure-reports
	procedure_reports <-
		arrow::open_dataset(
			fs::path(file_dir, 'procedure-reports'),
			format = 'parquet',
			partitioning = 'year',
			unify_schemas = TRUE
		) |>
		collect()
	
}

read_cbcd_visits <- function(file_dir) {
	
	# Issue in this visits data
	# Has both "start date" and "visit start date" as names for columns
	visits <-
		arrow::open_dataset(
			fs::path(file_dir, 'visits'),
			format = 'parquet',
			partitioning = 'year',
			unify_schemas = TRUE
		) |>
		collect()
	
}

read_cbcd_vitals <- function(file_dir) {
	
	# Read in data for vitals
	vitals <-
		arrow::open_dataset(
			fs::path(file_dir, 'vitals'),
			format = 'parquet',
			partitioning = 'year',
			unify_schemas = TRUE
		) |>
		mutate(vital_name = tolower(vital_name)) |>
		filter(vital_value != 0) |> # Would be a sign of death...
		filter(str_detect(vital_name,
																			'lbs|inches',
																			negate = TRUE)) |>
		mutate(vital_name = case_when(
			str_detect(vital_name, 'weight') ~ 'weight',
			str_detect(vital_name, 'height') ~ 'weight',
			str_detect(vital_name, 'systolic') ~ 'sbp',
			str_detect(vital_name, 'diastolic') ~ 'dbp',
			str_detect(vital_name, 'mean') ~ 'map',
			str_detect(vital_name, 'fio2') ~ 'fio2',
			str_detect(vital_name, 'pulse') ~ 'bpm',
			TRUE ~ vital_name
		)) |>
		collect()
	
}
