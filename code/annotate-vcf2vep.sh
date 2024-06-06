#!/bin/bash

# This file handles the annotation of individual VCF files
# Usage is inside a SLURM batch script (or can be run alone)
# Arguments:
# 	VCF_files = an environmental variable of VCF files that are processed

# Initialize the variables we want to have from the passed arguments
VCF_files=""
dirOutput=""

# Parse the named arguments
while [[ "$#" -gt 0 ]]; do
	case $1 in 
		--vcf-files) VCF_files="$2"; shift ;;
		--output-dir) dirOutput="$2"; shift ;;
		*) echo "Unknown parameter passed; $1"; exit 1 ;;
	esac
	shift
done

# Check to see if variable is available
# Error out if need be
if [ -z "$VCF_files" ] || [ -z "$dirOutput" ]; then
	echo "Error: VCF_files variables was not set."
	echo "Usage: $0 --vcf-files \"file1.vcf file2.vcf ...\" --output-dir output_directory"
	exit 1
fi

# Convert the VCF files into an array 
# Uses internal field separator for strings
IFS=' ' read -r -a VCF_array <<< "$VCF_files"

# Iterate over each VCF file given in this array
for file in "${VCF_array[@]}"; do

	# Get the directory and file name without the extension
	dirName=$(dirname "$file")
	fileName=$(basename "$file" .vcf)

	# Define the output file path
	# Can change -suffix name of file if wanted
	suffix="annotated"
	outputFile="${dirOutput}/${fileName}-${suffix}.txt"

	# Run VEP pipeline
	# Uses just 2 CPUs to allow for lower SLURM costs and more efficient batching
	# Convert with LOFTEE in this example
	apptainer exec /shared/software/EasyBuild/modules/all/ensembl-vep/ensembl-vep_latest.sif vep -i "$file" -o "$outputFile" --verbose --fork 2 --offline --no_stats --polyphen s --sift s --symbol --show_ref_allele --plugin Lof,loftee_path:/shared/home/ashah282/tools/loftee/,human_ancestor_fa:false --dir_plugin /shared/home/ashah282/tools/loftee/

	echo "Annotation of $file completed, and output written to $outputFile."

done
