/*==============================================================================
DO FILE NAME:			05a_an_models
PROJECT:				Anticoagulant in COVID-19 
AUTHOR:					A Wong (modified from ICS study by A Schultze)
DATE: 					2 Nov 2020 					
DESCRIPTION OF FILE:	program 05a
						Objective 1: comparing treated and untreated people 
						with atrial fibrillation
						univariable regression
						DAG adjusted regression
						Fully adjusted regression 
						model checks are in: 
							08_an_model_checks
DATASETS USED:			data in memory ($tempdir/analysis_dataset_STSET_outcome)

DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
						table2_`outcome', printed to analysis/$outdir
							
==============================================================================*/

local outcome `1'

local global_option `2'

do `c(pwd)'/analysis/global_`global_option'.do

* Open a log file

cap log close
log using $logdir/05a_an_models_`outcome', replace t

* Open Stata dataset
use $tempdir/analysis_dataset_STSET_`outcome', clear

/* Sense check outcomes=======================================================*/ 

safetab exposure `outcome', missing row

/* Main Model=================================================================*/

/* Univariable model */ 

stcox i.exposure 
estimates save $tempdir/`outcome'_univar, replace 

/* Multivariable models */ 

* Age and Gender 
* Age fit as spline in first instance, categorical below 

stcox i.exposure i.male age1 age2 age3 
estimates save $tempdir/`outcome'_multivar1, replace 

* DAG adjusted model
stcox i.exposure i.male age1 age2 age3 $dagvarlist
estimates save $tempdir/`outcome'_multivar2, replace 	

* Fully adjusted model
stcox i.exposure i.male age1 age2 age3 $fullvarlist, strata(practice_id)
estimates save $tempdir/`outcome'_multivar3, replace

/* Print table================================================================*/ 
*  Print the results for the main model 

cap file close tablecontent
file open tablecontent using $tabfigdir/table2_`outcome'.txt, write text replace

* Column headings 
file write tablecontent ("Table 2: Association between current anticoagulant use and `outcome' - $population Population") _n
file write tablecontent _tab ("Number of events") _tab ("Total person-weeks") _tab ("Rate per 1,000") _tab ("Univariable") _tab _tab ("Age/Sex Adjusted") _tab _tab ///
						("DAG Adjusted") _tab _tab ///
						("Fully adjusted") _tab _tab _n
file write tablecontent _tab _tab _tab _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ///
						("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _n
file write tablecontent ("Main Analysis") _n 					

* Row headings 
local lab0: label exposure 0
local lab1: label exposure 1
 
/* Counts */
 
* First row, exposure = 0 (reference)

	qui safecount if exposure == 0 & `outcome' == 1
	local event = r(N)
    bysort exposure: egen total_follow_up = total(_t)
	qui su total_follow_up if exposure == 0
	local person_week = r(mean)/7
	local rate = 1000*(`event'/`person_week')
	
	file write tablecontent ("`lab0'") _tab
	file write tablecontent (`event') _tab %10.0f (`person_week') _tab %3.2f (`rate') _tab
	file write tablecontent ("1.00 (ref)") _tab _tab ("1.00 (ref)") ///
	_tab _tab ("1.00 (ref)") _tab _tab ("1.00 (ref)") _n
	
* Second row, exposure = 1 
file write tablecontent ("`lab1'") _tab  

	qui safecount if exposure == 1 & `outcome' == 1
	local event = r(N)
	qui su total_follow_up if exposure == 1
	local person_week = r(mean)/7
	local rate = 1000*(`event'/`person_week')
	file write tablecontent (`event') _tab %10.0f (`person_week') _tab %3.2f (`rate') _tab

/* Main Model */ 
estimates use $tempdir/`outcome'_univar 
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 

estimates use $tempdir/`outcome'_multivar1 
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 

estimates use $tempdir/`outcome'_multivar2  
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 

estimates use $tempdir/`outcome'_multivar3
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _n 

file write tablecontent _n
file close tablecontent


* Close log file 
log close












