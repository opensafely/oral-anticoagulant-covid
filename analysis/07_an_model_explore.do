/*==============================================================================
DO FILE NAME:			07_an_model_explore
PROJECT:				Anticoagulant in COVID-19 
AUTHOR:					A Wong 
DATE: 					2 Nov 2020 						
DESCRIPTION OF FILE:	program 07
						explore different models 
						Objective 1: comparing treated and untreated people 
						with atrial fibrillation
DATASETS USED:			data in memory ($tempdir/analysis_dataset_STSET_outcome)

DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
						table4_`outcome', printed to analysis/$outdir
							
==============================================================================*/

local outcome `1'

local global_option `2'

do `c(pwd)'/analysis/global_`global_option'.do

* Open a log file

cap log close
log using $logdir/07_an_model_explore_`outcome', replace t

* Open Stata dataset
use $tempdir/analysis_dataset_STSET_`outcome', clear

/* Print table================================================================*/ 
*  Print the results for the main model 

cap file close tablecontent
file open tablecontent using $tabfigdir/table4_`outcome'.txt, write text replace

* Column headings 
file write tablecontent ("Table 4: 1 by 1 comorbidity adjustments (after age/sex and strata adjustments) - $population population") _n
file write tablecontent _tab ("HR") _tab ("95% CI") _n

/* Adjust one covariate at a time=============================================*/

foreach var in $fullvarlist { 
			       
	local var: subinstr local var "i." ""
	local lab: variable label `var'
	file write tablecontent ("`lab'") _n 
	
	qui stcox i.exposure i.male age1 age2 age3 i.`var', strata(practice_id)	
		
		local lab0: label exposure 0
		local lab1: label exposure 1

		file write tablecontent ("`lab0'") _tab
		file write tablecontent ("1.00 (ref)") _tab _n
		file write tablecontent ("`lab1'") _tab  
		
		qui lincom 1.exposure, eform
		file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _n _n
									
} 		

	
local lab: variable label ethnicity
file write tablecontent ("`lab'") _n 

preserve 
drop if ethnicity == .u

qui stcox i.exposure i.male age1 age2 age3 i.ethnicity, strata(practice_id)	
		
		local lab0: label exposure 0
		local lab1: label exposure 1

		file write tablecontent ("`lab0'") _tab
		file write tablecontent ("1.00 (ref)") _tab _n
		file write tablecontent ("`lab1'") _tab  
		
		qui lincom 1.exposure, eform
		file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _n _n
restore

file write tablecontent _n
file close tablecontent

log close
