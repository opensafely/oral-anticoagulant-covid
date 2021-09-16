/*==============================================================================
DO FILE NAME:			12a_an_models_ethnicity
PROJECT:				Anticoagulant in COVID-19 
DATE: 					3 March 2021 
AUTHOR:					A Wong 		
DESCRIPTION OF FILE:	program 12a, based on program 06a
						restrict to known ethnicity (complete case analysis)
						to fix parameters not being converged
						Objective 1: comparing treated and untreated people 
						with atrial fibrillation 
DATASETS USED:			data in memory ($tempdir/analysis_dataset_STSET_outcome)

DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
						table9, printed to analysis/$outdir
							
==============================================================================*/
local outcome `1'
local global_option `2'

do `c(pwd)'/analysis/global_`global_option'.do

global reviseddagvarlist i.imd 				///	
				  i.obese4cat			    ///
				  i.smoke_nomiss		    ///
				  i.diab_control			///
				  i.myocardial_infarct		///
				  i.pad						///
				  i.hypertension			///		
				  i.heart_failure			///		
				  i.stroke_tia              ///
				  i.vte                     ///
				  i.dementia				///
				  i.oestrogen 				///	
				  i.antiplatelet            ///
				  i.flu_vaccine 			
				  
global revisedfullvarlist i.imd 			///
				   i.obese4cat			    ///
				   i.smoke_nomiss		    ///
				   i.diab_control			///
				   i.myocardial_infarct		///
				   i.pad					///
				   i.hypertension			///		
				   i.heart_failure			///		
				   i.stroke_tia             ///
				   i.vte                    ///
				   i.oestrogen 				///	
				   i.antiplatelet           ///
				   i.flu_vaccine 			///
				   i.ckd	 				///		
				   i.copd                   ///
				   i.other_respiratory      ///
				   i.immunodef_any		 	///
				   i.cancer     		    ///
				   i.dementia				///
				   i.ae_attendance_last_year ///
				   i.gp_consult
				   
* Open a log file

cap log close
log using $logdir/12a_an_models_ethnicity_`outcome', replace t

/* Outcome: Admitcovid========================================================*/ 

* Open Stata dataset
use $tempdir/analysis_dataset_STSET_`outcome', clear

/* Restrict population========================================================*/ 

preserve 
drop if ethnicity == .u

* Create new diabetes variable, group Diabetes, no hba1c with uncontrolled diabetes
clonevar diab_control = diabcat
recode diab_control 4=3

/* Main Model=================================================================*/

* DAG adjusted WITH ETHNICITY
stcox i.exposure i.male age1 age2 age3  $reviseddagvarlist   ///
										i.ethnicity	
										
estimates save $tempdir/12a_`outcome'_multivar2_ethn, replace 

* DAG adjusted WITHOUT ETHNICITY
stcox i.exposure i.male age1 age2 age3 $reviseddagvarlist  	
										
estimates save $tempdir/12a_`outcome'_multivar2_withoutethn, replace 

* Fully adjusted WITH ETHNICITY
stcox i.exposure i.male age1 age2 age3 $revisedfullvarlist   ///
									   i.ethnicity, strata(practice_id)		
										
estimates save $tempdir/12a_`outcome'_multivar3_ethn, replace 

* Fully adjusted WITHOUT ETHNICITY
stcox i.exposure i.male age1 age2 age3 $revisedfullvarlist , strata(practice_id)		
										
estimates save $tempdir/12a_`outcome'_multivar3_withoutethn, replace 

/* Print table================================================================*/ 
*  Print the results for the main model 

cap file close tablecontent
file open tablecontent using $tabfigdir/table9_`outcome'.txt, write text replace

* Column headings 
file write tablecontent ("Table 9: Association between current anticoagulant use and `outcome' - $population Population, restrict to known ethnicity") _n
file write tablecontent _tab ("DAG Adjusted with ethnicity") _tab _tab ///
						("DAG Adjusted without ethnicity") _tab _tab ///
						("Fully Adjusted with ethnicity") _tab _tab ///
						("Fully Adjusted without ethnicity") _tab _tab ///
						_n
file write tablecontent _tab _tab _tab _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ///
						("95% CI") _tab ("HR") _tab ("95% CI") _tab ///
						("HR") _tab ("95% CI") _n
file write tablecontent ("Main Analysis") _n 					

* Row headings 
local lab0: label exposure 0
local lab1: label exposure 1
 
* First row, exposure = 0 (reference)

	file write tablecontent ("1.00 (ref)") _tab _tab ("1.00 (ref)") ///
	_tab _tab ("1.00 (ref)") _tab _tab ("1.00 (ref)") _n
	
* Second row, exposure = 1 

file write tablecontent ("`lab1'") _tab  

/* Main Model */ 
estimates use $tempdir/12a_`outcome'_multivar2_ethn
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab

estimates use $tempdir/12a_`outcome'_multivar2_withoutethn
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab

estimates use $tempdir/12a_`outcome'_multivar3_ethn
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 

estimates use $tempdir/12a_`outcome'_multivar3_withoutethn
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _n 

file write tablecontent _n
file close tablecontent

restore 

* Close log file 
log close












