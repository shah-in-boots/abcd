# Computational Biorepository for Cardiovascular Disease


## Clinical data

Number of CSV files...

-   diagnosis.csv
-   labs.csv
-   medications.csv
-   notes.csv
-   procedure-reports.csv
-   procedures.csv
-   visits.csv
-   vitals.csv
## AWS access

AWS ID = CARDIO_DARBAR

```         
Sys.setenv(
    AWS_REGION = "us-east-2"
)
```

Code examples stored on Evernote


# Phenotype AF

In the main folder, "sh" files will exist that are essentially set-up / calls to run a batch command using SLURM.
These will generally call either a bash/CL type series of commands or more likely call an R script that is held within the "./R/*" folder. 
The R scripts will have more definitions on them about how to old. 

## Clinical data

### Medications

*What does medication intensification look like?*

It requires a patient to have been placed or started on an agent that helps slow AF rates, and involves escalating to increased dosing or addition of antiarrhythmics.
This also includes adding anticoagulants as indicated.

The steps required are...

1. Identify if on primary AV nodal blocking agent (e.g. BB or cardioselective CCB)
1. Check to see if additional medications were added
1. Add in anticoagulants

## ECG analyses

Current data that has been uploaded to cluster includes:

2010
2011
2012
2013
2014
2015
2016
2017
2018
2019
2020
2021
2022
2023 (January to end of June)


Pipeline for feature extraction:

1.  Convert ECG full disclosure data into XML (can be done through MUSE)
1.  Subsequently convert XML format to WFDB format for signal analysis and annotation
1.  QRS annotation files can be created
1. 	Identification of rhythm using human-labeling + machine learning
1.  Segmentation can be performed if in sinus rhythm (may or may not be accurate) using PhysioNet toolbox

Specific parameters
1.  Can generate GEH data from 12-lead ECG with orthogonal points
1.  Generate HRV indices off of 10-second ECG lead
1.  Generate short-PRD values (periodic repolarization dynamics) from 10-second strip
1.  Generate median beats

These will rely primarily on WFDB-based scripts, utilizing the XML files from MUSE which are converted to DAT and HEA files and other annotation files.

### Conversion of XML to WFDB

convert-xml2wfdb.R

### Identification of ECG diagnoses

Identifying ECGs based on a diagnosis (e.g. AF), which creates and manipulates a file called "ECG-AFDiagnosis.tsv". This files contains a table of MUSE file names, MRNs, and dates and times. 

find-wfdb2diagnosis.R
match-diagnosis2mrn.R

