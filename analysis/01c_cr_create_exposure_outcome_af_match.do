/*==============================================================================
DO FILE NAME:			01c_cr_create_exposure_outcome_af_match
PROJECT:				Anticoauglant in COVID-19 
DATE: 					24 Dec 2020  
AUTHOR:					A Wong (modified from NSAID study)
																	
DESCRIPTION OF FILE:	create exposures and outcomes of interest 
DATASETS USED:			data in memory (from analysis/input_af.csv)

DATASETS CREATED: 		cr_dataset_af.dta // for running different outcomes, no need to run program 00 and 01 again
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
							
==============================================================================*/

local global_option `1'

do `c(pwd)'/analysis/global_`global_option'.do


* Open a log file
cap log close
log using $logdir/01c_cr_create_exposure_outcome_af_match, replace t

/*==============================================================================*/
* import the dataset from 00 program
use $tempdir/format_dataset, clear

sort patient_id

* Date of cohort entry, 1 Mar 2020
gen enter_date = date("$indexdate", "DMY")
format enter_date %td

/* OUTCOME AND SURVIVAL TIME==================================================*/
* Date of data available
gen onscoviddeathcensor_date 	= date("$onscoviddeathcensor", 	"DMY")

* Format the dates
format 	enter_date					///
		onscoviddeathcensor_date 	%td

/*   Outcomes/censoring variable   */

* Dates of: ONS any death, hospital admission (Primary diagnosis) due to covid
* Recode to dates from the strings 
foreach var of varlist 	died_date_ons 	            ///
						first_tested_for_covid      ///
						first_positive_test_date    ///
						covid_admission_date        ///
						dereg_date					///
						{
						
	confirm string variable `var'
	rename `var' `var'_dstr
	gen `var' = date(`var'_dstr, "YMD")
	drop `var'_dstr
	format `var' %td 
	
}

* Add half-day buffer if outcome on indexdate
replace died_date_ons=died_date_ons+0.5 if died_date_ons==enter_date

* Generate date of Covid death in ONS
gen died_date_onscovid = died_date_ons if died_ons_covid_flag_any == 1

* Generate date of non-Covid death in ONS
gen died_date_onsnoncoviddeath = died_date_ons if died_ons_covid_flag_any != 1

* Generate date of hospital admission due to Covid
gen covid_admission_primary_date = covid_admission_date ///
if (covid_admission_primary_dx == "U071"| covid_admission_primary_dx == "U072")

* Add half-day buffer if outcome on indexdate
replace covid_admission_primary_date=covid_admission_primary_date+0.5 if covid_admission_primary_date==enter_date
replace first_tested_for_covid=first_tested_for_covid+0.5 if first_tested_for_covid==enter_date
replace first_positive_test_date=first_positive_test_date+0.5 if first_positive_test_date==enter_date

* Format outcome dates
format died_date_ons died_date_onscovid died_date_onsnoncoviddeath covid_admission_primary_date dereg_date %td

/*  Identify date of end of follow-up
(first: end data availability, death, deregistration from GP or outcome) */
* For looping later, name must be stime_binary_outcome_name

* Primary outcome: ONS covid-19 death (use onscoviddeathcensor_date because it is the earliest date in all linkage dataset - treat it as end of study)
gen stime_onscoviddeath = min(onscoviddeathcensor_date, died_date_ons, dereg_date)
gen stime_admitcovid = min(onscoviddeathcensor_date, died_date_ons, dereg_date, covid_admission_primary_date)

* Exploratory outcomes: ONS non-covid death; covid test; positive covid test
gen stime_onsnoncoviddeath = min(onscoviddeathcensor_date, died_date_ons, dereg_date)
gen stime_covidtest = min(onscoviddeathcensor_date, died_date_ons, dereg_date, first_tested_for_covid)
gen stime_positivecovidtest = min(onscoviddeathcensor_date, died_date_ons, dereg_date, first_positive_test_date)

* Generate variables for follow-up person-days for each outcome
gen follow_up_onscoviddeath = stime_onscoviddeath - enter_date + 1
gen follow_up_admitcovid = stime_admitcovid - enter_date + 1
gen follow_up_onsnoncoviddeath = stime_onsnoncoviddeath - enter_date + 1
gen follow_up_covidtest = stime_covidtest - enter_date + 1
gen follow_up_positivecovidtest = stime_positivecovidtest - enter_date + 1
 
* Format date variables
format stime* %td 

* Binary indicators for outcomes
* Primary outcome: ONS covid-19 death
gen onscoviddeath = 1 if died_date_onscovid!=. & ///
died_date_onscovid>=enter_date & died_date_onscovid<=stime_onscoviddeath

replace onscoviddeath = 0 if onscoviddeath == .

* Hospital admission due to COVID-19
gen admitcovid = 1 if covid_admission_primary_date!=. & ///
covid_admission_primary_date>=enter_date & covid_admission_primary_date<=stime_admitcovid

replace admitcovid = 0 if admitcovid == .
 
* Exploratory outcomes: Non-Covid death; Covid-19 test; positive Covid-19 test
* Non-Covid death
gen onsnoncoviddeath = 1 if died_date_onsnoncoviddeath!=. & ///
died_date_onsnoncoviddeath>=enter_date & died_date_onsnoncoviddeath<=stime_onsnoncoviddeath

replace onsnoncoviddeath = 0 if onsnoncoviddeath == .

* COVID test
gen covidtest = 1 if first_tested_for_covid!=. & ///
first_tested_for_covid>=enter_date & first_tested_for_covid<=stime_covidtest

replace covidtest = 0 if covidtest == .

* Positive COVID test
gen positivecovidtest = 1 if first_positive_test_date!=. & ///
first_positive_test_date>=enter_date & first_positive_test_date<=stime_positivecovidtest

replace positivecovidtest = 0 if positivecovidtest == .

/* LABEL VARIABLES============================================================*/

* Outcomes and follow-up
label var enter_date					"Date of study entry"
label var onscoviddeathcensor_date 		"Date of admin censoring for ONS deaths"

label var onscoviddeath					"Failure/censoring indicator for outcome: ONS covid death"
label var died_date_onscovid 			"Date of ONS Death (Covid-19 only)"
label var admitcovid    			    "Failure/censoring indicator for outcome: SUS covid"
label var covid_admission_primary_date  "Date of hospital admission due to covid as primary dx"
label var onsnoncoviddeath              "Failure/censoring indicator for outcome: ONS non-covid death"
label var died_date_onsnoncoviddeath    "Date of ONS non-covid death"
label var covidtest      		        "Failure/censoring indicator for outcome: first covid test"
label var first_tested_for_covid		"Date of first covid test"
label var positivecovidtest             "Failure/censoring indicator for outcome: first positive covid test"
label var first_positive_test_date		"Date of positive covid test"

label var died_date_ons                 "ONS death date (any cause)"

* End of follow-up (date)
label var stime_onscoviddeath 			"End of follow-up: ONS covid death"
label var stime_admitcovid     			"End of follow-up: SUS covid"
label var stime_onsnoncoviddeath 		"End of follow-up: ONS non-covid death"
label var stime_covidtest     			"End of follow-up: covid test"
label var stime_positivecovidtest 		"End of follow-up: positive covid test"

* Duration of follow-up
label var follow_up_onscoviddeath       "Number of days (follow-up) for ONS covid death"
label var follow_up_admitcovid 			"Number of days (follow-up) for covid hospital admission"
label var follow_up_onsnoncoviddeath	"Number of days (follow-up) for ONS non-covid death"
label var follow_up_covidtest 			"Number of days (follow-up) for covid test"
label var follow_up_positivecovidtest 	"Number of days (follow-up) for positive covid test"
/* ==========================================================================*/

save $tempdir/cr_dataset_af, replace

log close