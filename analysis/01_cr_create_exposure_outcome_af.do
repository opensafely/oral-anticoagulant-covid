/*==============================================================================
DO FILE NAME:			01_cr_create_exposure_outcome_af
PROJECT:				Anticoauglant in COVID-19 
DATE: 					29 Oct 2020  
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
log using $logdir/01_cr_create_exposure_outcome_af, replace t

/*==============================================================================*/
* import the dataset from 00 program
use $tempdir/format_dataset, clear

sort patient_id

* Date of cohort entry, 1 Mar 2020
gen enter_date = date("$indexdate", "DMY")
format enter_date %td

* Format treatment variables
foreach var of varlist 	warfarin_last_four_months   ///
						doac_last_four_months      ///
						{
						
	confirm string variable `var'
	rename `var' `var'_dstr
	gen `var' = date(`var'_dstr, "YMD")
	drop `var'_dstr
	format `var' %td 
	
}
/* TREATMENT EXPOSURE=========================================================*/	

*Derive oral anticoagulant (Warfarin/DOACs) exposure within 4 months before cohort entry
*Objective 1: comparison group - untreated people with atrial fibrillation
gen exposure = 1 if warfarin_last_four_months != .
replace exposure = 1 if doac_last_four_months != .
replace exposure = 0 if exposure == .

label var exposure "Oral anticoagulant Treatment Exposure"
label define exposure 0 "non-use" 1 "current use"
label values exposure exposure 

*Objective 2: comparing warfarin vs DOACs
*Derive warfarin & DOACs exposure within 4 months before cohort entry
gen exposure_warfarin = 1 if warfarin_last_four_months!=. & ///
warfarin_last_four_months == max(warfarin_last_four_months, doac_last_four_months)

replace exposure_warfarin = 0 if doac_last_four_months!=. & ///
doac_last_four_months == max(warfarin_last_four_months, doac_last_four_months)

*If the latest date of warfarin and DOAC are the same, classify it as warfarin exposure
replace exposure_warfarin = 1 if exposure == 1 & ///
warfarin_last_four_months == max(warfarin_last_four_months, doac_last_four_months) & ///
warfarin_last_four_months == doac_last_four_months

label var exposure_warfarin "warfarin vs DOACs"
label define exposure_warfarin 0 "DOAC use" 1 "warfarin use" 2 "warfarin & DOAC same latest prescription"
label values exposure_warfarin exposure_warfarin 

* Sensitivity analysis: exclude people who were prescribed both warfarin and DOACs on the same day as the latest OAC prescription
clonevar sens_exposure_warfarin = exposure_warfarin
replace sens_exposure_warfarin = 2 if exposure == 1 & ///
warfarin_last_four_months == max(warfarin_last_four_months, doac_last_four_months) & ///
warfarin_last_four_months == doac_last_four_months

label var sens_exposure_warfarin "sensitivity analysis: flag warfarin & DOAC same latest prescription"
label values sens_exposure_warfarin exposure_warfarin 


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
						mi_date_ons					///
						stroke_date_ons				///
						vte_date_ons				///
						gi_bleed_date_ons			///
						intracranial_bleed_date_ons	/// 
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

replace mi_date_ons=mi_date_ons+0.5 if mi_date_ons==enter_date
replace stroke_date_ons=stroke_date_ons+0.5 if stroke_date_ons==enter_date
replace vte_date_ons=vte_date_ons+0.5 if vte_date_ons==enter_date
replace gi_bleed_date_ons=gi_bleed_date_ons+0.5 if gi_bleed_date_ons==enter_date
replace intracranial_bleed_date_ons=intracranial_bleed_date_ons+0.5 if intracranial_bleed_date_ons==enter_date

* Format outcome dates
format died_date_ons died_date_onscovid died_date_onsnoncoviddeath covid_admission_primary_date dereg_date %td
format mi_date_ons stroke_date_ons vte_date_ons %td 
format gi_bleed_date_ons intracranial_bleed_date_ons %td

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

* Post-hoc analyses outcomes: 
* Death due to myocardial infarction, ischaemic stroke, vte, GI & intracranial bleed
gen stime_mi_ons = min(onscoviddeathcensor_date, died_date_ons, dereg_date)
gen stime_stroke_ons = min(onscoviddeathcensor_date, died_date_ons, dereg_date)
gen stime_vte_ons = min(onscoviddeathcensor_date, died_date_ons, dereg_date)
gen stime_gi_bleed_ons = min(onscoviddeathcensor_date, died_date_ons, dereg_date)
gen stime_intracranial_bleed_ons = min(onscoviddeathcensor_date, died_date_ons, dereg_date)

* Generate variables for follow-up person-days for each outcome
gen follow_up_onscoviddeath = stime_onscoviddeath - enter_date + 1
gen follow_up_admitcovid = stime_admitcovid - enter_date + 1
gen follow_up_onsnoncoviddeath = stime_onsnoncoviddeath - enter_date + 1
gen follow_up_covidtest = stime_covidtest - enter_date + 1
gen follow_up_positivecovidtest = stime_positivecovidtest - enter_date + 1

gen follow_up_mi_ons = stime_mi_ons - enter_date + 1
gen follow_up_stroke_ons = stime_stroke_ons - enter_date + 1
gen follow_up_vte_ons = stime_vte_ons - enter_date + 1
gen follow_up_gi_bleed_ons = stime_gi_bleed_ons - enter_date + 1
gen follow_up_intracranial_bleed_ons = stime_intracranial_bleed_ons - enter_date + 1
 
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

* Post-hoc analyses: death due to MI, ischaemic stroke, vte, GI & intracranial bleed
* Only explore the causes of death among non-COVID-death analyses
* Therefore set outcome to be 0 if the patients has a record of any underlying COVID-19 death

* MI
gen mi_ons = 1 if mi_date_ons!=. & mi_date_ons>=enter_date & mi_date_ons<=stime_mi_ons

replace mi_ons = 0 if mi_ons == .
replace mi_ons = 0 if onscoviddeath == 1

* Ischaemic stroke
gen stroke_ons = 1 if stroke_date_ons!=. & ///
stroke_date_ons>=enter_date & stroke_date_ons<=stime_stroke_ons

replace stroke_ons = 0 if stroke_ons == .
replace stroke_ons = 0 if onscoviddeath == 1

* VTE
gen vte_ons = 1 if vte_date_ons!=. & ///
vte_date_ons>=enter_date & vte_date_ons<=stime_vte_ons

replace vte_ons = 0 if vte_ons == .
replace vte_ons = 0 if onscoviddeath == 1

* GI bleed
gen gi_bleed_ons = 1 if gi_bleed_date_ons!=. & ///
gi_bleed_date_ons>=enter_date & gi_bleed_date_ons<=stime_gi_bleed_ons

replace gi_bleed_ons = 0 if gi_bleed_ons == .
replace gi_bleed_ons = 0 if onscoviddeath == 1

* Intracranial bleed
gen intracranial_bleed_ons = 1 if intracranial_bleed_date_ons!=. & ///
intracranial_bleed_date_ons>=enter_date & intracranial_bleed_date_ons<=stime_intracranial_bleed_ons

replace intracranial_bleed_ons = 0 if intracranial_bleed_ons == .
replace intracranial_bleed_ons = 0 if onscoviddeath == 1

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

label var mi_date_ons					"Date of ONS myocardial infarction death"
label var stroke_date_ons				"Date of ONS ischaemic stroke death"
label var vte_date_ons					"Date of ONS VTE death"
label var gi_bleed_date_ons				"Date of ONS GI bleed death"
label var intracranial_bleed_date_ons	"Date of ONS intracranial bleed death"

label var mi_ons						"Failure/censoring indicator for outcome: myocardial infarction death"
label var stroke_ons					"Failure/censoring indicator for outcome: ischaemic stroke death"
label var vte_ons						"Failure/censoring indicator for outcome: VTE death"
label var gi_bleed_ons					"Failure/censoring indicator for outcome: GI bleed death"
label var intracranial_bleed_ons		"Failure/censoring indicator for outcome: intracranial bleed death"

* End of follow-up (date)
label var stime_onscoviddeath 			"End of follow-up: ONS covid death"
label var stime_admitcovid     			"End of follow-up: SUS covid"
label var stime_onsnoncoviddeath 		"End of follow-up: ONS non-covid death"
label var stime_covidtest     			"End of follow-up: covid test"
label var stime_positivecovidtest 		"End of follow-up: positive covid test"

label var stime_mi_ons				    "End of follow-up: ONS myocardial infarction death"
label var stime_stroke_ons 				"End of follow-up: ONS ischaemic stroke death"
label var stime_vte_ons 				"End of follow-up: ONS VTE death"
label var stime_gi_bleed_ons 			"End of follow-up: ONS GI bleed death"
label var stime_intracranial_bleed_ons  "End of follow-up: ONS intracranial bleed death"

* Duration of follow-up
label var follow_up_onscoviddeath       "Number of days (follow-up) for ONS covid death"
label var follow_up_admitcovid 			"Number of days (follow-up) for covid hospital admission"
label var follow_up_onsnoncoviddeath	"Number of days (follow-up) for ONS non-covid death"
label var follow_up_covidtest 			"Number of days (follow-up) for covid test"
label var follow_up_positivecovidtest 	"Number of days (follow-up) for positive covid test"

label var follow_up_mi_ons 					"Number of days (follow-up) for ONS myocardial infarction death"
label var follow_up_stroke_ons				"Number of days (follow-up) for ONS ischaemic stroke death"
label var follow_up_vte_ons					"Number of days (follow-up) for ONS VTE death"
label var follow_up_gi_bleed_ons	"Number of days (follow-up) for ONS GI bleed death"
label var follow_up_intracranial_bleed_ons	"Number of days (follow-up) for ONS intracranial bleed death"
 
/* ==========================================================================*/

save $tempdir/cr_dataset_af, replace

log close
