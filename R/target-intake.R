read_in_afib_medications <- function(folderName = fs::path()) {

	medications <- vroom::vroom(fs::path(folderName, 'medications', ext = 'csv'))

	# This is a long list of medications, that are likely not okay for us
	meds <-
		medications$medication |>
		tolower() |>
		unique()

	meds |>
		tolower() |>
		grep('nacl', x = _, invert = TRUE, value = TRUE) |>
		grep('d5', x = _, invert = TRUE, value = TRUE) |>
		grep('%', x = _, invert = TRUE, value = TRUE) |>
		grep('sterile', x = _, invert = TRUE, value = TRUE) |>
		grep('\ ml', x = _, invert = TRUE, value = TRUE) |>
		grep('vaccine', x = _, invert = TRUE, value = TRUE) |>
		grep('topical', x = _, invert = TRUE, value = TRUE) |>
		grep('supp', x = _, invert = TRUE, value = TRUE) |>
		grep('dev', x = _, invert = TRUE, value = TRUE)






}