/*==============================================================================
DO FILE NAME:			posthoc3_02a_cr_create_population
PROJECT:				Anticoauglant in COVID-19 
DATE: 					26 July 2021
AUTHOR:					A Wong	
DESCRIPTION OF FILE:	AF population (Objective 1)
						comparing oral anticoagulant use vs non-use
						Post hoc analysis - restrict the study cohort to people with positive COVID tests
DEPENDENCIES: 
DATASETS USED:			data in memory (from analysis_dataset_`outcome')

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
log using $logdir/posthoc3_02a_cr_create_population_`outcome', replace t

/* Use the dataset we derived from the 02a program===========================*/ 

use $tempdir_main_analysis/analysis_dataset_`outcome' , clear

noi di "PEOPLE WITH POSITIVE COVID TESTS"
keep if positivecovidtest == 1

/* SAVE DATA==================================================================*/		

save $tempdir/analysis_dataset_`outcome', replace

* Save a version set on outcomes
stset stime_`outcome', fail(`outcome') id(patient_id) enter(first_positive_test_date) origin(first_positive_test_date)	
save $tempdir/analysis_dataset_STSET_`outcome', replace

* Close log file 
log close






