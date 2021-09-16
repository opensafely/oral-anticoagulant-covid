/*==============================================================================
DO FILE NAME:			06a_an_models_ethnicity
PROJECT:				Anticoagulant in COVID-19 
DATE: 					2 Nov 2020 
AUTHOR:					A Wong 		
DESCRIPTION OF FILE:	program 6a, restrict to known ethnicity (complete case analysis)
						Objective 1: comparing treated and untreated people 
						with atrial fibrillation 
DATASETS USED:			data in memory ($tempdir/analysis_dataset_STSET_outcome)

DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
						table3_`outcome', printed to analysis/$outdir
							
==============================================================================*/

local outcome `1'

local global_option `2'

do `c(pwd)'/analysis/global_`global_option'.do

* Open a log file

cap log close
log using $logdir/06a_an_models_ethnicity_`outcome', replace t

* Open Stata dataset
use $tempdir/analysis_dataset_STSET_`outcome', clear

/* Restrict population========================================================*/ 

preserve 
drop if ethnicity == .u

/* Sense check outcomes=======================================================*/ 

safetab exposure `outcome', missing row

/* Main Model=================================================================*/

/* Univariable model */ 

stcox i.exposure 
estimates save $tempdir/`outcome'_univar_ethn, replace 

/* Multivariable models */ 

* Age and Gender 
* Age fit as spline in first instance, categorical below 

stcox i.exposure i.male age1 age2 age3 
estimates save $tempdir/`outcome'_multivar1_ethn, replace 

* DAG adjusted WITH ETHNICITY
stcox i.exposure i.male age1 age2 age3  $dagvarlist   ///
										i.ethnicity	
										
estimates save $tempdir/`outcome'_multivar2_ethn, replace 

* DAG adjusted WITHOUT ETHNICITY
stcox i.exposure i.male age1 age2 age3 $dagvarlist  	
										
estimates save $tempdir/`outcome'_multivar2_withoutethn, replace 

* Fully adjusted WITH ETHNICITY
stcox i.exposure i.male age1 age2 age3 $fullvarlist   ///
									   i.ethnicity, strata(practice_id)		
										
estimates save $tempdir/`outcome'_multivar3_ethn, replace 

* Fully adjusted WITHOUT ETHNICITY
stcox i.exposure i.male age1 age2 age3 $fullvarlist , strata(practice_id)		
										
estimates save $tempdir/`outcome'_multivar3_withoutethn, replace 

/* Print table================================================================*/ 
*  Print the results for the main model 

cap file close tablecontent
file open tablecontent using $tabfigdir/table3_`outcome'.txt, write text replace

* Column headings 
file write tablecontent ("Table 3: Association between current anticoagulant use and `outcome' - $population Population, restrict to known ethnicity") _n
file write tablecontent _tab ("Number of events") _tab ("Total person-weeks") _tab ("Rate per 1,000") _tab ("Univariable") _tab _tab ("Age/Sex Adjusted") _tab _tab ///
						("DAG Adjusted with ethnicity") _tab _tab ///
						("DAG Adjusted without ethnicity") _tab _tab ///
						("Fully Adjusted with ethnicity") _tab _tab ///
						("Fully Adjusted without ethnicity") _tab _tab ///
						_n
file write tablecontent _tab _tab _tab _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ///
						("95% CI") _tab ("HR") _tab ("95% CI") _tab ///
						("HR") _tab ("95% CI") _tab ///
						("HR") _tab ("95% CI") _tab ///
						("HR") _tab ("95% CI") _n
file write tablecontent ("Main Analysis") _n 					

* Row headings 
local lab0: label exposure 0
local lab1: label exposure 1
 
* First row, exposure = 0 (reference)

	qui safecount if exposure == 0 & `outcome' == 1
	local event = r(N)
    bysort exposure: egen total_follow_up = total(_t)
	su total_follow_up if exposure == 0
	local person_week = r(mean)/7
	local rate = 1000*(`event'/`person_week')
	
	file write tablecontent ("`lab0'") _tab
	file write tablecontent (`event') _tab %10.0f (`person_week') _tab %3.2f (`rate') _tab
	file write tablecontent ("1.00 (ref)") _tab _tab ("1.00 (ref)") ///
	_tab _tab ("1.00 (ref)") _tab _tab ("1.00 (ref)") _tab _tab ///
	("1.00 (ref)") _tab _tab ("1.00 (ref)") _n
	
* Second row, exposure = 1 

file write tablecontent ("`lab1'") _tab  

	qui safecount if exposure == 1 & `outcome' == 1
	local event = r(N)
	su total_follow_up if exposure == 1
	local person_week = r(mean)/7
	local rate = 1000*(`event'/`person_week')
	file write tablecontent (`event') _tab %10.0f (`person_week') _tab %3.2f (`rate') _tab

/* Main Model */ 
estimates use $tempdir/`outcome'_univar_ethn 
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 

estimates use $tempdir/`outcome'_multivar1_ethn
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 

estimates use $tempdir/`outcome'_multivar2_ethn
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab

estimates use $tempdir/`outcome'_multivar2_withoutethn
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab

estimates use $tempdir/`outcome'_multivar3_ethn
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 

estimates use $tempdir/`outcome'_multivar3_withoutethn
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _n 

file write tablecontent _n
file close tablecontent

restore 

* Close log file 
log close












