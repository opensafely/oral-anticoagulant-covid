/*==============================================================================
DO FILE NAME:			02aii_cr_create_population
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

local outcome `1'

local global_option `2'

do `c(pwd)'/analysis/global_`global_option'.do

* Open a log file

cap log close
log using $logdir/02aii_cr_create_population_`outcome', replace t

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

noi di "DROP IF END OF STUDY PERIOD BEFORE INDEX"
drop if stime_`outcome' < date("$indexdate", "DMY")

/* CHECK INCLUSION AND EXCLUSION CRITERIA=====================================*/ 

* DATA STRUCTURE: Confirm one row per patient 
duplicates tag patient_id, generate(dup_check)
assert dup_check == 0 
drop dup_check

* INCLUSION 1: atrial fibrillation diagnosis before 1 March 2020 (everyone should have a date for this variable)
datacheck af_date != . , nol

* INCLUSION 2: >=18 and <=110 at 1 March 2020 
assert age < .
datacheck age >= 18, nol
datacheck age <= 110, nol
 
* INCLUSION 3: M or F gender at 1 March 2020 
assert inlist(sex, "M", "F")

* INCLUSION 4: CHA2DS2_VASc_score = 2
datacheck CHA2DS2_VASc_score == 2 , nol

* EXCLUSION 1: 12 months or baseline time 
* [VARIABLE NOT EXPORTED, CANNOT QUANTIFY]

* EXCLUSION 2: MISSING IMD
assert inlist(imd, 1, 2, 3, 4, 5)

* EXCLUSION 3: EXCLUDE PEOPLE WITH INJECTABLE ANTICOAGULANT
datacheck lmwh_last_four_months_date == ., nol

/* SAVE DATA==================================================================*/		
save $tempdir/analysis_dataset_`outcome', replace

* Save a version set on outcomes
stset stime_`outcome', fail(`outcome') id(patient_id) enter(enter_date) origin(enter_date)	
save $tempdir/analysis_dataset_STSET_`outcome', replace

* Close log file 
log close