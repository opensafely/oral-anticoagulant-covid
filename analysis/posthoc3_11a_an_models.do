/*==============================================================================
DO FILE NAME:			posthoc3_11a_an_models
PROJECT:				Anticoagulant in COVID-19 
AUTHOR:					A Wong 
DATE: 					26 Jul 2021			
DESCRIPTION OF FILE:	program 05a
						Objective 1: comparing treated and untreated people 
						with atrial fibrillation
						DAG adjusted regression
						After initial run, some parameters didn't converge
						so further investigation

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
log using $logdir/posthoc3_11a_an_models_`outcome', replace t

* Open Stata dataset
use $tempdir/analysis_dataset_STSET_`outcome', clear

/* Sense check outcomes=======================================================*/ 

safetab exposure `outcome', missing row

/* Main Model=================================================================*/

* Create new diabetes variable, group Diabetes, no hba1c with uncontrolled diabetes
clonevar diab_control = diabcat
recode diab_control 4=3

* DAG adjusted model (removed PAD, stroke/TIA, oestrogen because these parameters cannot converge)
stcox i.exposure i.male age1 age2 age3 i.imd ///	
				  i.obese4cat			    ///
				  i.smoke_nomiss		    ///
				  i.diab_control			///
				  i.myocardial_infarct		///
				  i.hypertension			///		
				  i.heart_failure			///		
				  i.vte                     ///
				  i.antiplatelet            ///
				  i.flu_vaccine 			
				  
estimates save $tempdir/`outcome'_multivar2_correct, replace 	

/* Print table================================================================*/ 
*  Print the results for the main model 

cap file close tablecontent
file open tablecontent using $tabfigdir/table2_correct_parameter_`outcome'.txt, write text replace

* Column headings 
file write tablecontent ("Table 2: Association between current anticoagulant use and `outcome' - $population Population") _n
file write tablecontent _tab ("Number of events") _tab ("Total person-weeks") _tab ("Rate per 1,000") _tab	("DAG Adjusted") _tab _tab _n
file write tablecontent _tab _tab _tab _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ///
						("95% CI") _n
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
	file write tablecontent ("1.00 (ref)") _n
	
* Second row, exposure = 1 
file write tablecontent ("`lab1'") _tab  

	qui safecount if exposure == 1 & `outcome' == 1
	local event = r(N)
	qui su total_follow_up if exposure == 1
	local person_week = r(mean)/7
	local rate = 1000*(`event'/`person_week')
	file write tablecontent (`event') _tab %10.0f (`person_week') _tab %3.2f (`rate') _tab

/* Main Model */ 
estimates use $tempdir/`outcome'_multivar2_correct 
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _n

file write tablecontent _n
file close tablecontent


* Close log file 
log close












