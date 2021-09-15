/*==============================================================================
DO FILE NAME:			10a_an_models_interact
PROJECT:				Anticoagulant in COVID-19 
AUTHOR:					A Wong (modified from NSAID study by A Schultze)
DATE: 					14 Jan 2021 										
DESCRIPTION OF FILE:	program 10, evaluate care-home interaction 
DATASETS USED:			data in memory ($tempdir/analysis_dataset_STSET_outcome)

DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
						table7, printed to analysis/$outdir
							
==============================================================================*/
local outcome `1'

local global_option `2'

do `c(pwd)'/analysis/global_`global_option'.do

* Open a log file
cap log close
log using $logdir/10a_an_models_interact_`outcome', replace t

* Open Stata dataset
use $tempdir/analysis_dataset_STSET_`outcome', clear

/* Care-home Interaction============================================================*/ 

/* Check Counts */ 
drop if care_home_residence == .

bysort care_home_residence: safetab exposure `outcome', row

/* Univariable model */ 

stcox i.exposure i.care_home_residence
estimates store A

stcox i.exposure##i.care_home_residence
estimates store B
estimates save $tempdir/`outcome'_univar_int, replace 

lrtest A B
local univar_p = round(r(p),0.001)

/* Multivariable models */ 

* Age and Gender 

stcox i.exposure i.care_home_residence i.male age1 age2 age3 
estimates store A

stcox i.exposure##i.care_home_residence i.male age1 age2 age3 
estimates store B
estimates save $tempdir/`outcome'_multivar1_int, replace 

lrtest A B
local multivar1_p = round(r(p),0.001)

* DAG adjusted model 
stcox i.exposure i.care_home_residence i.male age1 age2 age3 $dagvarlist
							
estimates store A

stcox i.exposure##i.care_home_residence i.male age1 age2 age3 $dagvarlist		

estimates store B
estimates save $tempdir/`outcome'_multivar2_int, replace 

lrtest A B
local multivar2_p = round(r(p),0.001)

* Fully adjusted model
stcox i.exposure i.care_home_residence i.male age1 age2 age3 $fullvarlist, strata(practice_id)		
										
estimates store A

stcox i.exposure##i.care_home_residence i.male age1 age2 age3 $fullvarlist, strata(practice_id)		
estimates store B
estimates save $tempdir/`outcome'_multivar3_int, replace 

lrtest A B
local multivar3_p = round(r(p),0.001)


/* Print interaction table====================================================*/ 
cap file close tablecontent
file open tablecontent using $tabfigdir/table7_`outcome'.txt, write text replace

* Column headings 
file write tablecontent ("Table 7: Current anticoagulant use and `outcome', Care home Interaction - $population Population") _n
file write tablecontent  _tab ("Number of events") _tab ("Total person-weeks") _tab ("Rate per 1,000") _tab ("Univariable") _tab _tab _tab ("Age/Sex Adjusted") _tab _tab _tab  ///
						("DAG Adjusted") _tab _tab _tab ///
						("Fully Adjusted") _tab _tab _tab _n
file write tablecontent _tab _tab _tab _tab ("HR") _tab ("95% CI") _tab ///
						("p (interaction)") _tab ("HR") _tab ("95% CI") _tab ///
						("p (interaction)") _tab ("HR") _tab ("95% CI") _tab ///
						("p (interaction)") _tab ("HR") _tab ("95% CI") _tab ///
						("p (interaction)") _tab _n

* Overall p-values 
file write tablecontent ("care_home_residence") _tab _tab _tab _tab _tab _tab ///
						("`univar_p'") ///
						_tab _tab _tab ("`multivar1_p'") /// 
						_tab _tab _tab ("`multivar2_p'") ///
						_tab _tab _tab ("`multivar3_p'") _n
						
* Generic program to print model for a level of another variable 
cap prog drop printinteraction
prog define printinteraction 
syntax, variable(varname) outcome(varname) min(real) max(real) 

	forvalues varlevel = `min'/`max'{ 

		* Row headings 
		file write tablecontent ("`varlevel'") _n 	

		local lab0: label exposure 0
		local lab1: label exposure 1
		 
		/* Counts */
			
		* First row, exposure = 0 (reference)
		
    	file write tablecontent ("`lab0'") _tab

			safecount if exposure == 0  & `variable' == `varlevel' & `outcome' == 1
            local event = r(N)
		    bysort exposure `variable': egen total_follow_up = total(_t)
            qui su total_follow_up if exposure == 0 & `variable' == `varlevel'
            local person_week = r(mean)/7
            local rate = 1000*(`event'/`person_week')

			
		file write tablecontent (`event') _tab %10.0f (`person_week') _tab %3.2f (`rate') _tab
        file write tablecontent ("1.00 (ref)") _tab _tab _tab ("1.00 (ref)") ///
		_tab _tab _tab ("1.00 (ref)") _tab _tab _tab ("1.00 (ref)") _n

			
		* Second row, exposure = 1

		file write tablecontent ("`lab1'") _tab  


			safecount if exposure == 1 & `variable' == `varlevel' & `outcome' == 1
	        local event = r(N)
            qui su total_follow_up if exposure == 1 & `variable' == `varlevel'
            local person_week = r(mean)/7
            local rate = 1000*(`event'/`person_week')
            file write tablecontent (`event') _tab %10.0f (`person_week') _tab %3.2f (`rate') _tab

		* Print models 
		estimates use $tempdir/`outcome'_univar_int 
		qui lincom 1.exposure + 1.exposure#`varlevel'.`variable', eform
		file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab _tab

		estimates use $tempdir/`outcome'_multivar1_int
		qui lincom 1.exposure + 1.exposure#`varlevel'.`variable', eform
		file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab _tab
		
		estimates use $tempdir/`outcome'_multivar2_int
		qui lincom 1.exposure + 1.exposure#`varlevel'.`variable', eform
		file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab _tab

		estimates use $tempdir/`outcome'_multivar3_int
		qui lincom 1.exposure + 1.exposure#`varlevel'.`variable', eform
		file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab _n 

		drop total_follow_up
	} 
		
end

printinteraction, variable(care_home_residence) outcome(`outcome') min(0) max(1) 

file write tablecontent _n
file close tablecontent

* Close log file 
log close








