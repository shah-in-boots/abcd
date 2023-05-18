# Computational Biorepository for Cardiovascular Disease

## Clinical data

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