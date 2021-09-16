/*==============================================================================
DO FILE NAME:			03_an_checks
PROJECT:				Anticoagulant in COVID-19 
AUTHOR:					A Wong (modified from ICS study by A Schultze)
DATE: 					29 Sep 2020 
DESCRIPTION OF FILE:	Run sanity checks on all variables
							- Check variables take expected ranges 
							- Explore expected relationships 
							- Check relationship between exposure and all covariates (same as table 1)
							
DATASETS USED:			$tempdir\analysis_dataset.dta
DATASETS CREATED: 		None
OTHER OUTPUT: 			Log file: $logdir\03_an_checks
							
==============================================================================*/

local outcome `1'

local global_option `2'

do `c(pwd)'/analysis/global_`global_option'.do

* Open a log file

capture log close
log using $logdir/03_an_checks_`outcome', replace t

* Open Stata dataset
use $tempdir/analysis_dataset_`outcome', clear

*Duplicate patient check
sort patient_id
datacheck _n==1, by(patient_id) nol

/* EXPECTED VALUES============================================================*/ 

* Age
datacheck age<., nol
datacheck inlist(agegroup, 1, 2, 3, 4, 5, 6), nol

* Sex
datacheck inlist(male, 0, 1), nol

* BMI 
datacheck inlist(obese4cat, 1, 2, 3, 4), nol
datacheck inlist(bmicat, 1, 2, 3, 4, 5, 6, .u), nol

* IMD
datacheck inlist(imd, 1, 2, 3, 4, 5), nol

* Ethnicity
datacheck inlist(ethnicity, 1, 2, 3, 4, 5, .u), nol

* Smoking
datacheck inlist(smoke, 1, 2, 3, .u), nol
datacheck inlist(smoke_nomiss, 1, 2, 3), nol 

* Check date ranges for all treatment variables  
foreach i in warfarin_last_four_months  ///
             doac_last_four_months      ///
              {
	
	summ `i', format

}

* Check date ranges for all comorbidities/ medications 
foreach var of varlist  ckd     					///			
						hypertension				///
						dementia					///
						other_respiratory 			///
						heart_failure				///
						copd 						///
						diabetes					///
						cancer 	        			///
						myocardial_infarct			///
						stroke						///
						tia							///
						pad							///
						vte							///
						antiplatelet                ///
						oestrogen                   ///
						has_bled_score				///
						 { 
						
	summ `var'_date, format

}

summ immunodef_any, format

* Death outcome flag (covid)
//Underlying Covid-death should be a subset of Any Covid-death
datacheck !(died_ons_covid_flag_underlying==1 & died_ons_covid_flag_any!=1), nolist

* Outcome dates
summ  stime_onscoviddeath stime_onsnoncoviddeath ///
stime_admitcovid stime_covidtest stime_positivecovidtest,  format
summ  died_date_ons died_date_onscovid, format
summ  covid_admission_date covid_admission_primary_date, format
summ  first_tested_for_covid, format
summ  first_positive_test_date, format
summ  mi_date_ons, format
summ  stroke_date_ons, format
summ  vte_date_ons, format
summ  gi_bleed_date_ons, format
summ  intracranial_bleed_date_ons, format

* Follow-up for outcomes
datacheck follow_up_`outcome' > 0, nol

summ  follow_up_`outcome', detail

* Outcome date day lags since cohort entry (only ONS dataset)
* check how the death count tail out
gen days_died_since_entry = died_date_ons - enter_date
su days_died_since_entry, detail

* check the dates of first positive covid test date and covid first test date
datacheck first_positive_test_date == first_tested_for_covid, nol

/* LOGICAL RELATIONSHIPS======================================================*/ 

* BMI
bysort bmicat: summ bmi
safetab bmicat obese4cat, m

* Age
bysort agegroup: summ age

* Smoking
safetab smoke smoke_nomiss, m

* Diabetes
safetab diabcat diabetes, m

* CKD
safetab ckd egfr_cat, m

/* RELATIONSHIP WITH EXPOSURE AND COVARIATES (past 4 months)=============*/

foreach var of varlist  agegroup                    ///
                        sex                         ///
						bmicat                      ///
						ethnicity                   ///
						care_home_residence			///
						imd                         ///
						smoke_nomiss                ///
						hypertension				///
						heart_failure				///
						diabcat   					///
						copd 						///						
						other_respiratory 			///
						cancer      				///
						immunodef_any				///
						ckd     					///
						myocardial_infarct			///
						pad							///
						stroke_tia					///
						vte							///
						dementia					///
						flu_vaccine					///						
						oestrogen					///
						antiplatelet				///
						gp_consult   				///
						ae_attendance_last_year	    ///
					      {
							
	safetab `var' exposure , col m
}

bysort exposure: su gp_consult_count, detail
bysort exposure: su has_bled_score_ever, detail
bysort exposure: su has_bled_score_recent, detail
bysort exposure: su ae_attendance_count , detail
bysort exposure: su age, detail
bysort exposure: su follow_up_`outcome', detail

/* SENSE CHECK OUTCOMES=======================================================*/

safetab `outcome', m

* Close log file 
log close



