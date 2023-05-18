find_data_folder <- function() {
	x <- sessionInfo()$running

	if (grepl("mac", x)) {
		file.path("/Users", "asshah4", "OneDrive - University of Illinois at Chicago", "data")
	} else if (grepl("Windows", x)) {
		file.path("C:/Users", "asshah4", "OneDrive - University of Illinois Chicago", "data")
	}

}
