# Computational Biorepository for Cardiovascular Disease

## Clinical data

Number of CSV files... 

-	diagnosis.csv
-	labs.csv
-	medications.csv
-	notes.csv
-	procedure-reports.csv
-	procedures.csv
-	visits.csv
-	vitals.csv

## ECG Data

musexmlex.py : The Python script used to read the MUSE XML files and export a '.csv' file, suitable for import into other programs.

PREPARATION:

The 'musexmlex.py' script is a Python script; hence, the Python engine must be installed before using the script. This script was verified using version 3.7.2.

See www.python.org for information about installing Python on your target machine.

After installation, make sure 'python3.exe' is in your system path before continuing.

USE:

Copy the Python script to a location easily referened by your command-line window.

Run the Python script, at the command-line, to export the ECG rhythm to a comma-separated value ('.csv') file. The script writes the output in microvolts.

For example:

`python musexmlex.py MUSE_FILE.xml`

Exports the ECG rhythm stored in the XML file to a file named 'MUSE_FILE.csv', assuming the following:

a. The Python script 'musexmlex.py' is in the current-working directory.
b. The file 'MUSE_FILE.xml' is in the current-working directory.
c. Python is installed on the machine, and it is in the system path.

## AWS access

AWS ID = CARDIO_DARBAR

```
Sys.setenv(
	AWS_REGION = "us-east-2"
)
```

Code examples stored on Evernote

# ECG Analysis

Pipeline for feature extraction:

1. Convert ECG full disclosure data into XML (can be done through MUSE)
1. Subsequently convert XML format to WFDB format for signal analysis and annotation
1. QRS annotation files can be created
1. Segmentation can be performed if in sinus rhythm (may or may not be accurate)
1. Can generate GEH data from 12-lead ECG with orthogonal points
1. Generate HRV indices off of 10-second ECG lead
1. Generate short-PRD values (periodic repolarization dynamics) from 10-second strip
1. Generate median beats

