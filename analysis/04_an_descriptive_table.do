/*==============================================================================
DO FILE NAME:			04_an_descriptive_table
PROJECT:				Anticoagulant in COVID-19  
AUTHOR:					A Wong (modified from ICS study by A Schultze)
DATE: 					29 Oct 2020
DESCRIPTION OF FILE:	Produce a table of baseline characteristics, by exposure
						Generalised to produce same columns as levels of exposure
						Output to a textfile for further formatting
DATASETS USED:			$Tempdir\analysis_dataset_`outcome'.dta
DATASETS CREATED: 		None
OTHER OUTPUT: 			Results in txt: $outdir\table1_`outcome'.txt 
						Log file: $logdir\04_an_descriptive_table_`outcome'
							
==============================================================================*/
local outcome `1'

local global_option `2'

do `c(pwd)'/analysis/global_`global_option'.do

* Open a log file
capture log close
log using $logdir/04_an_descriptive_table_`outcome', replace t

* Open Stata dataset
use $tempdir/analysis_dataset_`outcome', clear

/*==============================================================================*/

/* PROGRAMS TO AUTOMATE TABULATIONS===========================================*/ 

********************************************************************************
* All below code from K Baskharan 
* Generic code to output one row of table

cap prog drop generaterow
program define generaterow
syntax, variable(varname) condition(string) 
	
	qui safecount
	local overalldenom=r(N)
	
	qui sum `variable' if `variable' `condition'
	file write tablecontent (r(max)) _tab
	
	qui safecount if `variable' `condition'
	local rowdenom = r(N)
	local colpct = 100*(r(N)/`overalldenom')
	file write tablecontent %9.0gc (`rowdenom')  (" (") %3.1f (`colpct') (")") _tab

	qui safecount if exposure == 0 
	local rowdenom = r(N)
	qui safecount if exposure == 0 & `variable' `condition'
	local pct = 100*(r(N)/`rowdenom') 
	file write tablecontent %9.0gc (r(N)) (" (") %3.1f (`pct') (")") _tab

	qui safecount if exposure == 1 
	local rowdenom = r(N)
	qui safecount if exposure == 1 & `variable' `condition'
	local pct = 100*(r(N)/`rowdenom')
	file write tablecontent %9.0gc (r(N)) (" (") %3.1f  (`pct') (")") _n
	
end



/* Explanatory Notes 

defines a program (SAS macro/R function equivalent), generate row
the syntax row specifies two inputs for the program: 

	a VARNAME which is your variable 
	a CONDITION which is a string of some condition you impose 
	
the program counts if variable and condition and returns the counts
column percentages are then automatically generated
this is then written to the text file 'tablecontent' 
the number followed by space, brackets, formatted pct, end bracket and then tab

the format %3.1f specifies length of 3, followed by 1 dp. 

*/ 

********************************************************************************
* Generic code to output one section (varible) within table (calls above)

cap prog drop tabulatevariable
prog define tabulatevariable
syntax, variable(varname) min(real) max(real) [missing]

	local lab: variable label `variable'
	file write tablecontent ("`lab'") _n 

	forvalues varlevel = `min'/`max'{ 
		generaterow, variable(`variable') condition("==`varlevel'")
	}
	
	if "`missing'"!="" generaterow, variable(`variable') condition(">=.")

end

********************************************************************************

/* Explanatory Notes 

defines program tabulate variable 
syntax is : 

	- a VARNAME which you stick in variable 
	- a numeric minimum 
	- a numeric maximum 
	- optional missing option, default value is . 

forvalues lowest to highest of the variable, manually set for each var
run the generate row program for the level of the variable 
if there is a missing specified, then run the generate row for missing vals

*/ 

********************************************************************************
* Generic code to summarise a continuous variable 

cap prog drop summarizevariable 
prog define summarizevariable
syntax, variable(varname) 

	local lab: variable label `variable'
	file write tablecontent ("`lab'") _n 
	
	qui summarize `variable', d
	file write tablecontent ("Median (IQR)") _tab 
	file write tablecontent (r(p50)) (" (") (r(p25)) ("-") (r(p75)) (")") _tab
							
	qui summarize `variable' if exposure == 0, d
	file write tablecontent (r(p50)) (" (") (r(p25)) ("-") (r(p75)) (")") _tab

	qui summarize `variable' if exposure == 1, d
	file write tablecontent (r(p50)) (" (") (r(p25)) ("-") (r(p75)) (")") _n
	
	qui summarize `variable', d
	file write tablecontent ("Min, Max") _tab 
	file write tablecontent (r(min)) (", ") (r(max)) ("") _tab
							
	qui summarize `variable' if exposure == 0, d
	file write tablecontent (r(min)) (", ") (r(max)) ("") _tab

	qui summarize `variable' if exposure == 1, d
	file write tablecontent (r(min)) (", ") (r(max)) ("") _n
	
end


/* INVOKE PROGRAMS FOR TABLE 1================================================*/ 

*Set up output file
cap file close tablecontent
file open tablecontent using $tabfigdir/table1_`outcome'.txt, write text replace

file write tablecontent ("Table 1: Demographic and Clinical Characteristics - $population for `outcome'") _n

* Exposure labelled columns

local lab0: label exposure 0
local lab1: label exposure 1

file write tablecontent _tab ("Total")				  			  _tab ///
							 ("`lab0'")			 			      _tab ///
							 ("`lab1'")  						  _n

* DEMOGRAPHICS (more than one level, potentially missing) 

gen byte cons=1
tabulatevariable, variable(cons) min(1) max(1) 
file write tablecontent _n 

tabulatevariable, variable(agegroup) min(1) max(6) 
file write tablecontent _n 

tabulatevariable, variable(male) min(0) max(1) 
file write tablecontent _n 

tabulatevariable, variable(bmicat) min(1) max(6) missing
file write tablecontent _n 

tabulatevariable, variable(smoke) min(1) max(3) missing 
file write tablecontent _n 

tabulatevariable, variable(ethnicity) min(1) max(5) missing 
file write tablecontent _n 

tabulatevariable, variable(imd) min(1) max(5) missing
file write tablecontent _n 

tabulatevariable, variable(diabcat) min(1) max(4) missing
file write tablecontent _n 

foreach varlist in  hypertension		///
					heart_failure		///
					diabetes			///
					copd				///
					other_respiratory	///
					cancer				///
					immunodef_any		///
					ckd					///
					flu_vaccine			///
					oestrogen			///
					antiplatelet		///
					myocardial_infarct  ///
					pad					///
					stroke_tia			///
					vte					///
					stroke              ///
					tia                 ///
					dementia			///
					nsaid				///
					aspirins			///
					hazardous_alcohol	///
					suspect_onscoviddeath ///
					onscoviddeath         ///
					{
tabulatevariable, variable(`varlist') min(1) max(1)
}
file write tablecontent _n _n

* COMORBIDITIES (continuous)

summarizevariable, variable(gp_consult_count)
summarizevariable, variable(age)
summarizevariable, variable(ae_attendance_count)
summarizevariable, variable(has_bled_score_recent)
summarizevariable, variable(has_bled_score_ever)

file close tablecontent

* Close log file 
log close

