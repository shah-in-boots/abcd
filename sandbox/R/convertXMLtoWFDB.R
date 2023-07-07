#!/usr/bin/env Rscript

# Expect argument that is string variable
args <- commandArgs(trailingOnly = TRUE)
folderName <- as.character(args[1])

# Libraries
library(shiva)
library(fs)

home <- fs::path_expand("~")
main <- fs::path("projects", "cbcd", "sandbox")
inputFolder <- fs::path(home, main, "data", "muse", folderName)
outputFolder <- fs::path(home, main, "data", "wfdb")

filePaths <- fs::dir_ls(path = inputFolder, glob = "*.xml")
fileNames <- fs::path_file(filePaths) |> fs::path_ext_remove()

for (i in seq_along(filePaths)) {

	ecg <- shiva::read_muse(filePaths[i])
	sig <- vec_data(ecg)
	hea <- attr(ecg, "header")

	print(paste("Will write", fileNames[i], "to", outputFolder))

	shiva::write_wfdb(
		data = sig,
		type = "muse",
		record = fileNames[i],
		record_dir = outputFolder,
		wfdb_path = "/shared/home/ashah282/bin",
		header = hea
	)

}


