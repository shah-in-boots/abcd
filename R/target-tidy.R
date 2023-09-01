tidy_afib_medications <- function(meds = cardiac_medications) {

	# Relevant medications are...
	# 	Antiarrhythmic drugs
	# 		Beta blockers
	# 		Selective calcium channel blockers
	#			Class 1 and Class 3 agents (VW class)
	# 	Anticoagulants
	# 		Warfarin
	# 		DOAC

	# Filter to relevant medicines and identify class type
	medList <- list(
		bb = c(
			'metoprolol',
			'carvedilol',
			'atenolol',
			'propranolol',
			'nebivolol'
		),
		ccb = c('diltiazem', 'verapamil'),
		aad = c(
			'flecainide',
			'propafenone',
			'mexiletine',
			'quinidine',
			'procainamide',
			'disopyramide',
			'sotalol',
			'ibutilide',
			'dronedarone'
		),
		amio = c(
			'amiodarone'
		),
		other = c(
			'ivabradine',
			'digoxin'
		),
		vka = c(
			'warfarin',
			'coumadin'
		),
		doac = c(
			'apixaban',
			'rivaroxaban',
			'edoxaban',
			'argatroban',
			'dabigatran'
		)
	)

	# Create smaller data frame and add type labels
	dat_meds <-
		meds[medication %in% unlist(medList),
		][, type := NA_character_]

	for (i in names(medList)) {
		dat_meds[, type := fifelse(medication %in% medList[[i]], i, type)]
	}

	# Get earliest and latest by individual medications
	dat_type <-
		dat_meds[, start_date := as.Date(start_date)
		][, end_date := as.Date(end_date)
		][, earliest := min(start_date, na.rm = TRUE), by = .(record_id, type)
		][, latest := max(end_date, na.rm = TRUE), by = .(record_id, type)
		][, .(record_id, earliest, latest, type)] |>
		unique()

}