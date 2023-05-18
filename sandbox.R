library(xml2)

read_muse_xml_ecg <- function(file, file_out = NA, numpyformat=TRUE) {
	# Read XML
	doc <- xml2::read_xml(file)

	# Rhythm is the second Wavefrom (Median first)
	rhythm <- xml2::xml_contents(xml2::xml_child(doc, "Waveform[2]"))

	# Index of lead data
	rhythm_names <- xml2::xml_name(rhythm)
	leads <- which(rhythm_names == "LeadData")

	# Get sample count.  All leads should be the same.
	first <- xml2::xml_child(rhythm, "LeadSampleCountTotal")[leads[1]]
	samples <- xml2::xml_integer(first)

	# Matrix to hold results
	lead_names <- c("I", "II", "III", "aVR", "aVL", "aVF", "V1", "V2", "V3", "V4", "V5", "V6")
	lead_data <- matrix(nrow = samples, ncol = length(lead_names))
	colnames(lead_data) <- lead_names

	# Loop through each leads and extract data
	for (l in leads) {
		lead <- xml2::as_list(rhythm[l][[1]])
		id <- lead$LeadID[[1]]
		amp_per_byte <- as.numeric(lead$LeadAmplitudeUnitsPerBit[[1]])
		waveform <- lead$WaveFormData[[1]]
		bin <- base64enc::base64decode(waveform)
		data <- readBin(bin, integer(), samples, size = 2) * amp_per_byte
		lead_data[,id] <- data
	}

	# III = II - I
	lead_data[, "III"] <- lead_data[, "II"] - lead_data[, "I"]

	# aVR = -(I + II)/2
	lead_data[, "aVR"] <- -(lead_data[, "I"] + lead_data[, "II"]) / 2

	# aVL = I - II/2
	lead_data[, "aVL"] <- lead_data[, "I"] - lead_data[, "II"] / 2

	# aVF = II - I/2
	lead_data[, "aVF"] <- lead_data[, "II"] - lead_data[, "I"] / 2

	# Do we really want integer? Matches python script.  Would round() be better? Or no rounding?
	lead_data <- apply(lead_data, 2, as.integer)

	# export a file if the 5000x12 array is the target output.  If numpyformat (4 dimensional array), this is skipped.
	if (!is.na(file_out) & !numpyformat) {
		utils::write.table(lead_data, file = file_out, row.names = FALSE)
	}

	## Add flag to reshape the array to match standard ECG AI inputs
	if (numpyformat){
		dim(lead_data) <- c(1, 5000, 12, 1)
	}
	lead_data
}


# One drive file

nm <- "MUSE_20230501_130904_49000.xml"
fp <- fs::path("data", nm)

x <- read_muse_xml_ecg(fp)

muse_ecg_xml_header <- function(file) {

	doc <- xml2::read_xml(file)

}
