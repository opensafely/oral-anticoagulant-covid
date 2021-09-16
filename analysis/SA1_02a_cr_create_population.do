/*==============================================================================
DO FILE NAME:			SA1_02a_cr_create_population
PROJECT:				Anticoauglant in COVID-19 
DATE: 					2 Dec 2020 
AUTHOR:					A Wong (modified from ICS study by A Schultze)							
DESCRIPTION OF FILE:	AF population (Objective 1)
						comparing oral anticoagulant use vs non-use
						Sensitivity analysis - remove people with antiplatelets
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
log using $logdir/SA1_02a_cr_create_population_`outcome', replace t

/* Use the dataset we derived from the 02a program===========================*/ 

use $tempdir_main_analysis/analysis_dataset_`outcome' , clear

noi di "PEOPLE PRESCRIBED ANTIPLATELET IN THE PAST FOUR MONTHS"
drop if antiplatelet_date != .

/* SAVE DATA==================================================================*/		
save $tempdir/analysis_dataset_`outcome', replace

* Save a version set on outcomes
stset stime_`outcome', fail(`outcome') id(patient_id) enter(enter_date) origin(enter_date)	
save $tempdir/analysis_dataset_STSET_`outcome', replace

* Close log file 
log close






