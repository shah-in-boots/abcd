find_ecg_files <- function(file) {
	fs::dir_ls(file, regexp = "*.xml")
}

# May need to batch this due to overall number being about 500k
convert_ecg_to_cvs <- function(files) {

	# Original OneDrive folder that files are contained in
	# Assumes all files have same directory
	folder <- fs::path_common(files)

	# Individual file names

	# Python script to convert to ECG
	pyScript <- fs::path(here::here(), "R", "muse_ecg_xml_to_csv.py")

	# Will create a CSV file locally
	# This needs to move back to the original directory in OneDrive
	lapply(files, function(.x) {

		fp <- paste0("'", .x, "'")
		system2(command = "python",
						args = c(pyScript, fp),
						stdout = FALSE)

	})

	# Now all the files are CSV, and will have different names
	csv_files <-
		fs::path_file(files) |>
		fs::path_ext_remove() |>
		fs::path_ext_set("csv")

	# Move them into the OneDrive folder
	fs::file_move(csv_files, new_path = folder)

}