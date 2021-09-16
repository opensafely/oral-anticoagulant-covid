/*==============================================================================
DO FILE NAME:			SA2_02a_cr_create_population
PROJECT:				Anticoauglant in COVID-19 
DATE: 					7 Dec 2020 
AUTHOR:					A Wong 						
DESCRIPTION OF FILE:	program 02a, AF population (Objective 1)
						comparing oral anticoagulant use vs non-use
						Sensitivity analysis - limit the study cohort to people who aged 55 or above
						
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
log using $logdir/SA2_02a_cr_create_population_`outcome', replace t

/*  Exclude people aged <55==================================================*/ 

use $tempdir_main_analysis/analysis_dataset_`outcome' , clear

noi di "DROP AGE <55:" 
drop if age < 55

datacheck age >= 55, nol

/* SAVE DATA==================================================================*/		
save $tempdir/analysis_dataset_`outcome', replace

* Save a version set on outcomes
stset stime_`outcome', fail(`outcome') id(patient_id) enter(enter_date) origin(enter_date)	
save $tempdir/analysis_dataset_STSET_`outcome', replace

* Close log file 
log close