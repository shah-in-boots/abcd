find_ecg_files <- function(file) {
	fs::dir_ls(file, regexp = "*.xml")
}

# May need to batch this due to overall number being about 500k
convert_ecg_to_wfdb <- function(files) {

	folder <- fs::path_common(files)

	# Read in XML file
	lapply(files, function(.x) {

		nm <-
			fs::path_file(.x) |>
			fs::path_ext_remove()

		ecg <- shiva::read_muse(.x)

		shiva::write_wfdb(
			data = ecg,
			type = "muse",
			record = nm,
			record_dir = folder,
			wfdb_path = "/usr/local/bin",
			header = attr(ecg, "header")
		)

	})
}
