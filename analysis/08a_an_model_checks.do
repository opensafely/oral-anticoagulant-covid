/*==============================================================================
DO FILE NAME:			08a_an_model_checks
PROJECT:				Anticoagulant in COVID-19 
AUTHOR:					A Wong (modified from NSAID study by A Schultze)
DATE: 					2 Nov 2020 	 									
DESCRIPTION OF FILE:	program 08a
						check the PH assumption, produce graphs 
						Objective 1: comparing treated and untreated people 
						with atrial fibrillation
DATASETS USED:			data in memory ($tempdir/analysis_dataset_STSET_outcome)

DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
						table5_`outcome' & table6_`outcome', printed to analysis/$outdir
						schoenplots1-x, printed to analysis?$outdir 
							
==============================================================================*/

local outcome `1'

local global_option `2'

do `c(pwd)'/analysis/global_`global_option'.do

* Open a log file

cap log close
log using $logdir/08a_an_model_checks_`outcome', replace t

/*==============================================================================*/
* Open Stata dataset
use $tempdir/analysis_dataset_STSET_`outcome', clear

/* In full cohort*/
/* Quietly run models, perform test and store results in local macro==========*/
qui stcox i.exposure 
estat phtest, detail
local univar_p = round(r(p),0.001)
di `univar_p'
 
estat phtest, plot(1.exposure) ///
			  graphregion(fcolor(white)) ///
			  ylabel(, nogrid labsize(small)) ///
			  xlabel(, labsize(small)) ///
			  xtitle("Time", size(small)) ///
			  ytitle("Scaled Schoenfeld Residuals", size(small)) ///
			  msize(small) ///
			  mcolor(gs6) ///
			  msymbol(circle_hollow) ///
			  scheme(s1mono) ///
			  title ("Schoenfeld residuals against time, univariable", position(11) size(medsmall)) 

graph export "$tabfigdir/`outcome'_schoenplot1.svg", as(svg) replace

* Close window 
graph close  
			  
stcox i.exposure i.male age1 age2 age3 
estat phtest, detail
local multivar1_p = round(r(phtest)[2,4],0.001)
 
estat phtest, plot(1.exposure) ///
			  graphregion(fcolor(white)) ///
			  ylabel(, nogrid labsize(small)) ///
			  xlabel(, labsize(small)) ///
			  xtitle("Time", size(small)) ///
			  ytitle("Scaled Schoenfeld Residuals", size(small)) ///
			  msize(small) ///
			  mcolor(gs6) ///
			  msymbol(circle_hollow) ///
			  scheme(s1mono) ///
			  title ("Schoenfeld residuals against time, age and sex adjusted", position(11) size(medsmall)) 			  

graph export "$tabfigdir/`outcome'_schoenplot2.svg", as(svg) replace

* Close window 
graph close
		  
stcox i.exposure i.male age1 age2 age3 $dagvarlist
estat phtest, detail
local multivar2_p = round(r(phtest)[2,4],0.001)
 
estat phtest, plot(1.exposure) ///
			  graphregion(fcolor(white)) ///
			  ylabel(, nogrid labsize(small)) ///
			  xlabel(, labsize(small)) ///
			  xtitle("Time", size(small)) ///
			  ytitle("Scaled Schoenfeld Residuals", size(small)) ///
			  msize(small) ///
			  mcolor(gs6) ///
			  msymbol(circle_hollow) ///
			  scheme(s1mono) ///
			  title ("Schoenfeld residuals against time, DAG adjusted", position(11) size(medsmall)) 		  
			  
graph export "$tabfigdir/`outcome'_schoenplot3.svg", as(svg) replace

stcox i.exposure i.male age1 age2 age3 $fullvarlist, strata(practice_id)
estat phtest, detail
local multivar3_p = round(r(phtest)[2,4],0.001)
 
estat phtest, plot(1.exposure) ///
			  graphregion(fcolor(white)) ///
			  ylabel(, nogrid labsize(small)) ///
			  xlabel(, labsize(small)) ///
			  xtitle("Time", size(small)) ///
			  ytitle("Scaled Schoenfeld Residuals", size(small)) ///
			  msize(small) ///
			  mcolor(gs6) ///
			  msymbol(circle_hollow) ///
			  scheme(s1mono) ///
			  title ("Schoenfeld residuals against time, fully adjusted", position(11) size(medsmall)) 		  
			  
graph export "$tabfigdir/`outcome'_schoenplot4.svg", as(svg) replace

* Close window 
graph close

* Print table of results======================================================*/	
cap file close tablecontent
file open tablecontent using $tabfigdir/table5_`outcome'.txt, write text replace

* Column headings 
file write tablecontent ("Table 5: Testing the PH assumption - `outcome' - $population Population in Full cohort") _n
file write tablecontent _tab ("Univariable") _tab ("Age/Sex Adjusted") _tab ///
						("DAG Adjusted") _tab ("Fully Adjusted") _tab _n
						
file write tablecontent _tab ("p-value") _tab ("p-value") _tab ("p-value") _tab ///
 ("p-value") _tab _n

* Row heading and content  
file write tablecontent ("Treatment Exposure") _tab
file write tablecontent ("`univar_p'") _tab ("`multivar1_p'") ///
 _tab ("`multivar2_p'") _tab ("`multivar3_p'")

file write tablecontent _n
file close tablecontent

* =============================================================================*/	
/* In complete case cohort - restrict to people with known ethnicity*/
* Open Stata dataset
use $tempdir/analysis_dataset_STSET_`outcome', clear

drop if ethnicity == .u

/* Quietly run models, perform test and store results in local macro==========*/
qui stcox i.exposure 
estat phtest, detail
local univar_completecase_p = round(r(p),0.001)
di `univar_p'
 
estat phtest, plot(1.exposure) ///
			  graphregion(fcolor(white)) ///
			  ylabel(, nogrid labsize(small)) ///
			  xlabel(, labsize(small)) ///
			  xtitle("Time", size(small)) ///
			  ytitle("Scaled Schoenfeld Residuals", size(small)) ///
			  msize(small) ///
			  mcolor(gs6) ///
			  msymbol(circle_hollow) ///
			  scheme(s1mono) ///
			  title ("Schoenfeld residuals against time, univariable", position(11) size(medsmall)) 

graph export "$tabfigdir/`outcome'_schoenplot1_completecase.svg", as(svg) replace

* Close window 
graph close  
			  
stcox i.exposure i.male age1 age2 age3 
estat phtest, detail
local multivar1_completecase_p = round(r(phtest)[2,4],0.001)
 
estat phtest, plot(1.exposure) ///
			  graphregion(fcolor(white)) ///
			  ylabel(, nogrid labsize(small)) ///
			  xlabel(, labsize(small)) ///
			  xtitle("Time", size(small)) ///
			  ytitle("Scaled Schoenfeld Residuals", size(small)) ///
			  msize(small) ///
			  mcolor(gs6) ///
			  msymbol(circle_hollow) ///
			  scheme(s1mono) ///
			  title ("Schoenfeld residuals against time, age and sex adjusted", position(11) size(medsmall)) 			  

graph export "$tabfigdir/`outcome'_schoenplot2_completecase.svg", as(svg) replace

* Close window 
graph close
		  
stcox i.exposure i.male age1 age2 age3 $dagvarlist i.ethnicity
estat phtest, detail
local multivar2_completecase_ethn_p = round(r(phtest)[2,4],0.001)
 
estat phtest, plot(1.exposure) ///
			  graphregion(fcolor(white)) ///
			  ylabel(, nogrid labsize(small)) ///
			  xlabel(, labsize(small)) ///
			  xtitle("Time", size(small)) ///
			  ytitle("Scaled Schoenfeld Residuals", size(small)) ///
			  msize(small) ///
			  mcolor(gs6) ///
			  msymbol(circle_hollow) ///
			  scheme(s1mono) ///
			  title ("Schoenfeld residuals against time, DAG adjusted", position(11) size(medsmall)) 		  
			  
graph export "$tabfigdir/`outcome'_schoenplot3_completecase_ethn.svg", as(svg) replace

stcox i.exposure i.male age1 age2 age3 $dagvarlist
estat phtest, detail
local multivar2_completecase_p = round(r(phtest)[2,4],0.001)
 
estat phtest, plot(1.exposure) ///
			  graphregion(fcolor(white)) ///
			  ylabel(, nogrid labsize(small)) ///
			  xlabel(, labsize(small)) ///
			  xtitle("Time", size(small)) ///
			  ytitle("Scaled Schoenfeld Residuals", size(small)) ///
			  msize(small) ///
			  mcolor(gs6) ///
			  msymbol(circle_hollow) ///
			  scheme(s1mono) ///
			  title ("Schoenfeld residuals against time, DAG adjusted", position(11) size(medsmall)) 		  
			  
graph export "$tabfigdir/`outcome'_schoenplot3_completecase.svg", as(svg) replace

stcox i.exposure i.male age1 age2 age3 $fullvarlist i.ethnicity, strata(practice_id)
estat phtest, detail
local multivar3_completecase_ethn_p = round(r(phtest)[2,4],0.001)
 
estat phtest, plot(1.exposure) ///
			  graphregion(fcolor(white)) ///
			  ylabel(, nogrid labsize(small)) ///
			  xlabel(, labsize(small)) ///
			  xtitle("Time", size(small)) ///
			  ytitle("Scaled Schoenfeld Residuals", size(small)) ///
			  msize(small) ///
			  mcolor(gs6) ///
			  msymbol(circle_hollow) ///
			  scheme(s1mono) ///
			  title ("Schoenfeld residuals against time, fully adjusted", position(11) size(medsmall)) 		  
			  
graph export "$tabfigdir/`outcome'_schoenplot4_completecase_ethn.svg", as(svg) replace

stcox i.exposure i.male age1 age2 age3 $fullvarlist, strata(practice_id)
estat phtest, detail
local multivar3_completecase_p = round(r(phtest)[2,4],0.001)
 
estat phtest, plot(1.exposure) ///
			  graphregion(fcolor(white)) ///
			  ylabel(, nogrid labsize(small)) ///
			  xlabel(, labsize(small)) ///
			  xtitle("Time", size(small)) ///
			  ytitle("Scaled Schoenfeld Residuals", size(small)) ///
			  msize(small) ///
			  mcolor(gs6) ///
			  msymbol(circle_hollow) ///
			  scheme(s1mono) ///
			  title ("Schoenfeld residuals against time, fully adjusted", position(11) size(medsmall)) 		  
			  
graph export "$tabfigdir/`outcome'_schoenplot4_completecase.svg", as(svg) replace

* Close window 
graph close

* Print table of results======================================================*/	


cap file close tablecontent
file open tablecontent using $tabfigdir/table6_`outcome'.txt, write text replace

* Column headings 
file write tablecontent ("Table 6: Testing the PH assumption - `outcome' - $population Population in complete case cohort") _n
file write tablecontent _tab ("Univariable") _tab ("Age/Sex Adjusted") _tab ///
						("DAG Adjusted with ethnicity") _tab ///
						("DAG Adjusted without ethnicity") _tab ///
						("Fully Adjusted with ethnicity") _tab ///
						("Fully Adjusted without ethnicity") _tab _n
						
file write tablecontent _tab ("p-value") _tab ("p-value") _tab ("p-value") _tab ///
 ("p-value") _tab ("p-value") _tab ("p-value") _tab _n

* Row heading and content  
file write tablecontent ("Treatment Exposure") _tab
file write tablecontent ("`univar_completecase_p'") _tab ("`multivar1_completecase_p'") ///
 _tab ("`multivar2_completecase_ethn_p'") _tab ("`multivar2_completecase_p'") ///
 _tab ("`multivar3_completecase_ethn_p'") _tab ("`multivar3_completecase_p'")

file write tablecontent _n
file close tablecontent

* Close log file 
log close
		  
			  