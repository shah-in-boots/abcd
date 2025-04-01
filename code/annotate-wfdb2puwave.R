#!/usr/bin/env Rscript

# `annotate-wfdb2qrs` can be run on a folder full of WFDB formatted ECGs
# The command requires a folder to process the QRS data for
# It routes through the ECGPUWAVE algorithm (Pan Tompkins)
# It works as a batch script and takes an external argument

# Setup ----
start_time <- Sys.time()

cat("Setup for annotation of WFDB files:\n\n")

# Libraries
library(EGM)
library(fs)
library(dplyr)
library(vroom)
library(foreach)
library(parallelly)
library(doParallel)
library(tools)
# options(wfdb_path = '/mmfs1/home/dseaney2/wfdb/bin') # can also add 'source $HOME/.bashrc' to .sh file before R script
source("/mmfs1/projects/cardio_darbar_chi/common/data/custom_install_code/wfdb-annotation-temp.R") # temp corrected code

# Arguments
#       1st = SLURM_ARRAY_JOB_ID
#               2nd = SLURM_ARRAY_TASK_COUNT
args <- commandArgs(trailingOnly = TRUE)
taskNumber <- as.integer(args[1]) # Example... 3rd job
taskCount <- as.integer(args[2]) # Total array jobs will be the number of nodes
cat("\tBatch array job number", taskNumber, "out of", taskCount, "array jobs total\n")

jobSize <- 1000 # total number of files (across all tasks). If you would like to read all files, simply comment this line

# Setup parallelization
nCPU <- parallelly::availableCores()
doParallel::registerDoParallel(cores = nCPU)
cat("\tAttempting parallelization with", nCPU, "cores\n")  

# Paths
home <- fs::path('/mmfs1/projects/cardio_darbar_chi/common/')
wfdb <- fs::path(home, "data", "wfdb")
muse <- fs::path(home, "data", "muse")
ecgpuwave <- fs::path(home, "data", "ecgpuwave")
scratch <- fs::path(Sys.getenv("SCRATCH_LOCAL")) # added path for scratch space

# wfdb Log file information
inputData <- read.csv(fs::path(wfdb, 'wfdb', ext = 'log'))
# Need to swap old file name contained with in $PATH to the new file name
inputData$PATH <- fs::path(dirname(inputData$PATH),inputData$FILE_NAME)

# ecgpuwave Log file information
logFile <- fs::path(wfdb, 'ecgpuwave', ext = 'log')
if (!fs::file_exists(logFile)) { # create new file if needed
        fs::file_create(logFile)
        logData <- data.frame(MUSE_ID = character(),
                              PATH = character(),
                              FILE_NAME = character(),
                              stringsAsFactors = FALSE)  # Avoid converting character columns to factors
} else {logData <- read.csv(logFile)}

cat("\tCurrently there are", nrow(logData), "files in the ECGPUWAVE log\n")

# Batch Preparation ----

# Only need to annotate those that have not yet been done
newData <- inputData |> dplyr::filter(!FILE_NAME %in% logData$FILE_NAME)
rm(inputData, logData)

# Limit file count as needed
if (exists("jobSize")) {
        if (jobSize > nrow(newData)) {
                    jobSize <- nrow(newData)
        }
        newData <- newData[1:jobSize,]
}

# Create folders
years <- unique(sapply(strsplit(newData$PATH, "/"), function(x) x[3]))
for (year in years) {
	folder_path <- fs::path(scratch, year)
	if (!fs::dir_exists(folder_path)) {
		fs::dir_create(folder_path)
		cat("Created folder:", folder_path, "\n")
	} else {
		cat("Folder already exists:", folder_path, "\n")
	}
}
		       
# Copy files to scratch space
cat("Copying files to scratch...","\n")
for (i in 1:nrow(newData)) {
	# Extract the file path
	file_path_hea <- fs::path(home, newData$PATH[i],ext='hea')
	file_path_dat <- fs::path(home, newData$PATH[i],ext='dat')
  
	# Extract the 2nd to last term from the file path (the containing folder)
	components <- strsplit(newData$PATH[i], "/")[[1]]
	folder_name <- components[length(components) - 1]
  
	# Construct target paths
	file_name <- newData$FILE_NAME[i]
	target_path_hea <- fs::path(scratch, folder_name, paste0(file_name, ".hea"))
	target_path_dat <- fs::path(scratch, folder_name, paste0(file_name, ".dat"))
	  
	# Copy files to the target paths
	fs::file_copy(file_path_hea, target_path_hea, overwrite = TRUE)
	fs::file_copy(file_path_dat, target_path_dat, overwrite = TRUE)
  
 	# cat("Copied file", file_path, "to", target_path_hea, "and", target_path_dat, "\n")
	if (!i %% 2000) {
		cat(i,"of",nrow(newData),"\n")
		}
}

# Create splits for batching
if (taskCount > 1) {
	splitData <- split(newData, cut(1:nrow(newData), taskCount, labels = FALSE))
	chunkData <- splitData[[taskNumber]]
	rm(splitData)
} else {chunkData <- newData}
cat("\tWill consider", nrow(chunkData), "WFDB files in this batch\n")

# Clean up potentially large dataframes
rm(newData)
gc()

# WFDB Preparation ----

cat("\nPreparing WFDB data for annotation:\n\n")

cat("\tThere are", nrow(chunkData), "WFDB files that can be annotated\n")

start <- 1
end <- nrow(chunkData)

# Make sure parallel is set up earlier
# Also place everything into correct "folder" by YEAR

# Write files to scratch space
out <-
        foreach(i = start:end, .combine = 'rbind', .errorhandling = "remove") %do% {

                if (end > 0) {
                        # Read in individual files and locations
                        fn <- chunkData$FILE_NAME[i]
                        fp <- fs::path(home,chunkData$PATH[i])
                        fd <- fs::path_dir(fp)
                        year <- fs::path_split(fd)[[1]] |> dplyr::last()

                        annotate_wfdb(
                                record = fn,
                                record_dir = fs::path(scratch,year),
                                annotator = "ecgpuwave"
                        )


                        # Move file to correct folder
                        old_path <- chunkData$PATH[i]
                        new_path <- gsub("wfdb", "ecgpuwave", old_path)
                        # file.rename(from=fs::path(home,old_path,ext='ecgpuwave'),
                        #             to=fs::path(home,new_path,ext='ecgpuwave'))

                        # vroom::vroom_write_lines(fn, logFile, append = TRUE)
                        cat("\tWrote the file", fn, "into the", year, "scratch folder\n")

                        # Return new row

			scratch_file_path <- fs::path(fs::path(scratch,year),fn,ext='ecgpuwave')

                        if (file.exists(scratch_file_path)) {
                        data.frame(
                                MUSE_ID = chunkData$MUSE_ID[i],
                                PATH = new_path,
                                FILE_NAME = fn,
                                stringsAsFactors = FALSE
                                )
                                }
                }
        }

cat("Files written to scratch. Moving files to project space...","\n")
		       
# Copy files from scratch space to project space ---
# Get list of subfolders in scratch
subfolders <- fs::dir_ls(scratch, type = "directory")

# Loop through each subfolder
for (subfolder in subfolders) {
	  folder_name <- fs::path_file(subfolder)
	  
	  # Get list of .ecgpuwave files in the current subfolder
	  ecgpuwave_files <- fs::dir_ls(subfolder, glob = "*.ecgpuwave")
	  
	  # Define corresponding 'ecgpuwave' folder path
	  ecgpuwave_subfolder <- fs::path(ecgpuwave, folder_name)
	  
	  # Create the 'ecgpuwave' subfolder if it doesn't exist
	  if (!fs::dir_exists(ecgpuwave_subfolder)) {
	    fs::dir_create(ecgpuwave_subfolder)
	    cat("Created folder:", ecgpuwave_subfolder, "\n")
	  }
	  
	  # Move each .ecgpuwave file to the corresponding 'ecgpuwave' subfolder
	  for (file in ecgpuwave_files) {
	    target_path <- fs::path(ecgpuwave_subfolder, fs::path_file(file))
	    fs::file_copy(file, target_path, overwrite = TRUE)
	    # cat("Moved file:", file, "to", target_path, "\n")
	  }

	scratch_files <- list.files(path(subfolder),pattern='ecgpuwave')
	folder_files <- list.files(ecgpuwave_subfolder,pattern='ecgpuwave')
		       
	if (sum(scratch_files %in% folder_files) == length(scratch_files)) {
		cat("All files are moved to project space in folder","subfolder","\n")
	} else {
		cat("WARNING: not all files were transferred. Removing them from out log","\n")
		missing_files <- scratch_files %in% folder_files
		out <- out |> filter(!FILE_NAME %in% file_path_sans_ext(missing_files))
		}
	    }



out |>
#  as.data.frame() |>
  dplyr::distinct() |>
  vroom::vroom_write(
    file = logFile,
    delim = ",",
    col_names = FALSE,
    append = TRUE
  )

cat("\tA total of", nrow(out), "were added to the ECGPUWAVE log\n")

end_time <- Sys.time()
elapsed_time <- end_time - start_time
cat("The script took:", elapsed_time, "seconds\n")

