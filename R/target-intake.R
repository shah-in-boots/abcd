read_clinical_afib_data <- function(folderName = fs::path()) {

	# Read in individual data files and then combine them
	ids <- vroom::vroom(fs::path(folderName, 'redcap-ids', ext = 'csv'))
	diagnosis <- vroom::vroom(fs::path(folderName, 'diagnosis', ext = 'csv'))
	labs <- vroom::vroom(fs::path(folderName, 'labs', ext = 'csv'))
	vitals <- vroom::vroom(fs::path(folderName, 'vitals', ext = 'csv'))
	visits <- vroom::vroom(fs::path(folderName, 'visits', ext = 'csv'))
	medications <- vroom::vroom(fs::path(folderName, 'medications', ext = 'sv'))
	procedures <- vroom::vroom(fs::path(folderName, 'procedures', ext = 'csv'))

	procedures |>
		filter(procedure_report == '93656')

}