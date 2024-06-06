#!/bin/sh

#SBATCH --partition=cpu-t3
#SBATCH --job-name=wesWFDBfiles
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2     # Number of cores per task
#SBATCH --array=1-20
#SBATCH --error=slurm-%A-%a.err
#SBATCH --output=slurm-%A-%a.out
#SBATCH --mail-user=ashah282@uic.edu
#SBATCH --mail-type=END

# This is the batch processing script for variant annotation
# Specific changes for annotation options should be made in the main script
#
# `code/annotate-vcf2vep.sh`
#
# PITFALLS:
# 	VCF files cannot have spaces in their name (WILL FAIL)

# Relevant modules for the VCF program to run
module load R/4.2.1-foss-2022a
module load SAMtools/1.15.1-GCC-11.2.0
module load ensembl-vep/v111

# Name the directory variables of interest (input and output)
dirVCF="~/data/uic/genetics/vcf"
dirOutput="~/data/uic/genetics/vcf/vep/no_lof"

# Create the output directory if it doesn't exist
mkdir -p "$dirOutput"

# Total number of batches and batch IDs from SLURM
n=$SLURM_ARRAY_TASK_COUNT
i=$SLURM_ARRAY_TASK_ID

# Now for utilizing the batch system
# First, read in the total number of VCF files
# Get the count of files in total
allVCF=($(find "$dirVCF" -name "*.vcf"))
totalFiles=${#allVCF[@]}

# Calculate number of files per batch
filesPerBatch=$(( (totalFiles + n - 1) / n ))

# Get the start and end indices for the current batch
startIndex=$(( i * filesPerBatch ))
endIndex=$(( startIndex + filesPerBatch ))

# Ensure we don't go out of bounds 
if (( endIndex > totalFiles )); then
	endIndex=$totalFiles
fi

# Get the current batch of files
batchFiles=("${allVCF[@]:startIndex:endIndex-startIndex}")

# Save teh batch files as an environment variable to pass along
VCF_files="${batchFiles[@]}"

# Run the annotation batch command here
./code/annotate-vcf2vep.sh --vcf-files "$VCF_files" --output-dir "$dirOutput"

echo "Batch $(($i + 1)) of $n is completed."
