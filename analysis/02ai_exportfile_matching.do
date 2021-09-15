/*==============================================================================
DO FILE NAME:			02aii_exportfile_matching
PROJECT:				Anticoauglant in COVID-19 
DATE: 					29 Oct 2020 
AUTHOR:					A Wong (modified from ICS study by A Schultze)							
DESCRIPTION OF FILE:	program 02a, AF population (Objective 1)
						comparing oral anticoagulant use vs non-use
						check inclusion/exclusion citeria
						drop patients if not relevant 
						export a csv file (which identified people with AF and oral anticoagulants)
						for matching
DEPENDENCIES: 
DATASETS USED:			data in memory (from analysis/input_af.csv)

DATASETS CREATED: 		analysis_dataset.dta
						lives in folder analysis/$tempdir 
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
						input_af_oac in output folder
							
==============================================================================*/

local global_option `1'

do `c(pwd)'/analysis/global_`global_option'.do

* Open a log file

cap log close
log using $logdir/02ai_exportfile_matching, replace t

/* APPLY INCLUSION/EXCLUIONS==================================================*/ 

use $tempdir/cr_dataset_af , clear

noi di "DROP MISSING ATRIAL FIBRILLATION:"
*DONE BY PYTHON

noi di "DROP MISSING GENDER:"
drop if inlist(sex,"I", "U")

noi di "DROP AGE <18:" 
*DONE BY PYTHON

noi di "DROP AGE >110:"
*DONE BY PYTHON

noi di "DROP AGE MISSING:"
*DONE BY PYTHON

noi di "DROP IMD MISSING"
*DONE BY PYTHON

noi di "KEEP PATIENTS WITH CHA2DS2_VASc_score==2"
datacheck CHA2DS2_VASc_score !=., nol

keep if CHA2DS2_VASc_score == 2

noi di "PEOPLE PRESCRIBED INJECTABLE ANTICOAGULANT"
drop if lmwh_last_four_months_date != .

noi di "People PRESCIRBED ORAL ANTICOAUGLANT"
keep if exposure == 1

* Need a string variable for cohort entry (for matching)
gen indexdate = "2020-03-01"

* drop unnecessary variable
drop exposure

/* save dataset & export a csv file for matching=====================================*/ 

save $outdir/input_af_oac.dta, replace

export delimited using $outdir/input_af_oac.csv, replace

* Close log file 
log close






