
library(readr)
string <-
	read_lines(
		"# diagnosis Sinus rhythm, with occasional, Premature ventricular complexes, Nonspecific T wave abnormality, Abnormal ECG
rhythm is Atrial fibrillation noted
afib
Atrial fibrillation
rhythm is Afib
but could it be some a fib
AF rhythm
Atrial Flutter or afib
AF
Afib"
	)

af_regex <- c(
	"afib",
	"\\baf\\b",
	"atrial\ flutter",
	"atrial\ fibrillation",
	"\\ba\\b\ fib",
	"\\ba\\b\ flutter"
)


grep(af_regex[5], string, ignore.case = TRUE, value = TRUE)
