/*==============================================================================
DO FILE NAME:			00_cr_create_analysis_dataset
PROJECT:				Anticoauglant in COVID-19 
DATE: 					27 Oct 2020 
AUTHOR:					A Wong (modified from NSAID study)
								
DESCRIPTION OF FILE:	program 00, data management for anticoagulant project  
						reformat variables 
						categorise variables
						label variables 
DATASETS USED:			data in memory (from output/input_xxx.csv)

DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
							
==============================================================================*/

local global_option `1'
local inputfile `2'

do `c(pwd)'/analysis/global_`global_option'.do

* Open a log file

cap log close
log using $logdir/00_cr_create_analysis_dataset, replace t


*import the file===============================================================*/ 

import delimited `c(pwd)'/output/`inputfile'.csv, clear

/* describe VARAIBLES===========================================================*/
des, f

/* CONVERT STRINGS TO DATE====================================================*/
/* Comorb dates are given with month only, so adding day 15 to enable
   them to be processed as dates 											  */

foreach var of varlist 	aplastic_anaemia				///
						bmi_date_measured 				///
						copd            				///
						dementia						///
						creatinine_date  				///
						diabetes         				///
						heart_failure 					///
						hypertension     				///
						hba1c_percentage_date  			///
						hba1c_mmol_per_mol_date			///
						esrf 							///
                        cancer     				        ///
						other_respiratory 				///
						permanent_immunodeficiency   	///
						smoking_status_date				///
						temporary_immunodeficiency   	///
						af                              ///
						valvular_af                     ///
						stroke                          ///
						tia                             ///
						vte                             ///
						myocardial_infarct	            ///
						pad                             ///
						antiphospholipid_syndrome       ///
						lmwh_last_four_months           ///
						oestrogen                       ///
						antiplatelet                    ///
						nsaid							///
						aspirins						///
						hazardous_alcohol				///
						has_bled_score_date				///
                      {
		
		capture confirm string variable `var'
		if _rc!=0 {
			cap assert `var'==.
			rename `var' `var'_date
		}
	
		else {
				replace `var' = `var' + "-15"
				rename `var' `var'_dstr
				replace `var'_dstr = " " if `var'_dstr == "-15"
				gen `var'_date = date(`var'_dstr, "YMD") 
				order `var'_date, after(`var'_dstr)
				drop `var'_dstr
		}
	
	format `var'_date %td
}

* Note - outcome dates are handled separtely below 

/* RENAME VARAIBLES===========================================================*/
*  An extra 'date' added to the end of some variable names, remove 

rename creatinine_date_date 			creatinine_measured_date
rename smoking_status_date_date 		smoking_status_measured_date
rename bmi_date_measured_date  			bmi_measured_date
rename hba1c_percentage_date_date		hb1ac_percentage_date 
rename hba1c_mmol_per_mol_date_date		hba1c_mmol_per_mol_date

* Some names too long for loops below, shorten

rename permanent_immunodeficiency_date perm_immunodef_date
rename temporary_immunodeficiency_date temp_immunodef_date

/* CREATE BINARY VARIABLES====================================================*/
*  Make indicator variables for all conditions where relevant 

foreach var of varlist  bmi_measured_date 					///
						copd_date            				///
						dementia_date						///
						creatinine_measured_date  			///
						diabetes_date         				///
						heart_failure_date					///
						hypertension_date     				///
						esrf_date 							///
                        cancer_date    	          			///
						other_respiratory_date 				///
						smoking_status_measured_date		///
						stroke_date                         ///
						af_date                             ///
						valvular_af_date					///
						tia_date                            ///
						vte_date                            ///
						myocardial_infarct_date             ///
						pad_date                            ///
						antiphospholipid_syndrome_date      ///
						oestrogen_date                      ///
						antiplatelet_date                   ///	
						aspirins_date						///
						nsaid_date							///				
						hazardous_alcohol_date 	            ///
						{
	
	/* date ranges are applied in python, so presence of date indicates presence of 
	  disease in the correct time frame */ 
	local newvar =  substr("`var'", 1, length("`var'") - 5)
	gen `newvar' = (`var'!=. )
	order `newvar', after(`var')
	
}

/* CREATE VARIABLES===========================================================*/

/* DEMOGRAPHICS */ 

* Sex
gen male = 1 if sex == "M"
replace male = 0 if sex == "F"

* Ethnicity 
replace ethnicity = .u if ethnicity == .

label define ethnicity 	1 "White"  					///
						2 "Mixed" 					///
						3 "Asian or Asian British"	///
						4 "Black"  					///
						5 "Other"					///
						.u "Unknown"

label values ethnicity ethnicity

* STP 
rename stp stp_old
bysort stp_old: gen stp = 1 if _n==1
replace stp = sum(stp)
drop stp_old

* Care home residence
gen care_home_residence = 0 if care_home_type == "U"
replace care_home_residence = 1 if care_home_type != "" & care_home_type != "U"  

/*  IMD  */
* Group into 5 groups
rename imd imd_o
egen imd = cut(imd_o), group(5) icodes

* add one to create groups 1 - 5 
replace imd = imd + 1

* - 1 is missing, should be excluded from population 
replace imd = .u if imd_o == -1
drop imd_o

* Reverse the order (so high is more deprived)
recode imd 5 = 1 4 = 2 3 = 3 2 = 4 1 = 5 .u = .u

label define imd 1 "1 least deprived" 2 "2" 3 "3" 4 "4" 5 "5 most deprived" .u "Unknown"
label values imd imd 

/*  Age variables  */ 

* Create categorised age
gen     agegroup=1 if age>=18 & age<40
replace agegroup=2 if age>=40 & age<50
replace agegroup=3 if age>=50 & age<60
replace agegroup=4 if age>=60 & age<70
replace agegroup=5 if age>=70 & age<80
replace agegroup=6 if age>=80
replace agegroup=. if age==.

label define agegroup 	1 "18-<40" ///
						2 "40-<50" ///
						3 "50-<60" ///
						4 "60-<70" ///
						5 "70-<80" ///
						6 "80+"
						
label values agegroup agegroup

* Check there are no missing ages
assert age < .
datacheck agegroup !=. , nolist

* Create restricted cubic splines fir age
mkspline age = age, cubic nknots(4)

/*  Body Mass Index  */
* NB: watch for missingness

* Recode strange values 
replace bmi = . if bmi == 0 
replace bmi = . if !inrange(bmi, 15, 50)

* Restrict to within 10 years of index and aged > 16 
gen bmi_time = (date("$indexdate", "DMY") - bmi_measured_date)/365.25
gen bmi_age = age - bmi_time

replace bmi = . if bmi_age < 16 
replace bmi = . if bmi_time > 10 & bmi_time != . 

* Set to missing if no date, and vice versa 
replace bmi = . if bmi_measured_date == . 
replace bmi_measured_date = . if bmi == . 
replace bmi_measured_date = . if bmi == . 

gen 	bmicat = .
recode  bmicat . = 1 if bmi < 18.5
recode  bmicat . = 2 if bmi < 25
recode  bmicat . = 3 if bmi < 30
recode  bmicat . = 4 if bmi < 35
recode  bmicat . = 5 if bmi < 40
recode  bmicat . = 6 if bmi < .
replace bmicat = .u if bmi >= .

label define bmicat 1 "Underweight (<18.5)" 	///
					2 "Normal (18.5-24.9)"		///
					3 "Overweight (25-29.9)"	///
					4 "Obese I (30-34.9)"		///
					5 "Obese II (35-39.9)"		///
					6 "Obese III (40+)"			///
					.u "Unknown (.u)"
					
label values bmicat bmicat

* Create less  granular categorisation
recode bmicat 1/3 .u = 1 4 = 2 5 = 3 6 = 4, gen(obese4cat)

label define obese4cat 	1 "No record of obesity" 	///
						2 "Obese I (30-34.9)"		///
						3 "Obese II (35-39.9)"		///
						4 "Obese III (40+)"		

label values obese4cat obese4cat
order obese4cat, after(bmicat)

/*  Smoking  */

* Smoking 
label define smoke 1 "Never" 2 "Former" 3 "Current" .u "Unknown (.u)"

gen     smoke = 1  if smoking_status == "N"
replace smoke = 2  if smoking_status == "E"
replace smoke = 3  if smoking_status == "S"
replace smoke = .u if smoking_status == "M"
replace smoke = .u if smoking_status == "" 

label values smoke smoke
drop smoking_status

* Create non-missing 3-category variable for current smoking
* Assumes missing smoking is never smoking 
recode smoke .u = 1, gen(smoke_nomiss)
order smoke_nomiss, after(smoke)
label values smoke_nomiss smoke

/* CLINICAL COMORBIDITIES */ 

/* GP consultation rate */ 
replace gp_consult_count = 0 if gp_consult_count <1 

* those with no count assumed to have no visits 
replace gp_consult_count = 0 if gp_consult_count == . 
gen gp_consult = (gp_consult_count >=1)

/* A&E attendance rate */
rename ae_attendance_last_year ae_attendance_count
replace ae_attendance_count = 0 if ae_attendance_count <1 

* those with no count assumed to have no visits 
replace ae_attendance_count = 0 if ae_attendance_count == . 
gen ae_attendance_last_year = (ae_attendance_count >=1)

/* Vaccines */ 
replace flu_vaccine = 0 if flu_vaccine == . 

/* Immunosuppression */

* Immunosuppressed:
* permanent immunodeficiency ever, OR 
* temporary immunodeficiency or aplastic anaemia last year
* in python, index date not inclusive for defining temp_immunodef_date & aplastic_anaemia_date
gen temp1  = (perm_immunodef_date		< .)
gen temp2  = inrange(temp_immunodef_date, (date("$indexdate", "DMY") - 365), date("$indexdate", "DMY"))
gen temp3  = inrange(aplastic_anaemia_date, (date("$indexdate", "DMY") - 365), date("$indexdate", "DMY"))

egen immunodef_any = rowmax(temp1 temp2 temp3)
drop temp1 temp2 temp3
order immunodef_any, after(temp_immunodef_date)

/* eGFR */

* Set implausible creatinine values to missing (Note: zero changed to missing)
replace creatinine = . if !inrange(creatinine, 20, 3000) 

* Remove creatinine dates if no measurements, and vice versa 
replace creatinine = . if creatinine_measured_date == . 
replace creatinine_measured_date = . if creatinine == . 
replace creatinine_measured = . if creatinine == . 

* Divide by 88.4 (to convert umol/l to mg/dl)
gen SCr_adj = creatinine/88.4

gen min = .
replace min = SCr_adj/0.7 if male==0
replace min = SCr_adj/0.9 if male==1
replace min = min^-0.329  if male==0
replace min = min^-0.411  if male==1
replace min = 1 if min<1

gen max=.
replace max=SCr_adj/0.7 if male==0
replace max=SCr_adj/0.9 if male==1
replace max=max^-1.209
replace max=1 if max>1

gen egfr=min*max*141
replace egfr=egfr*(0.993^age)
replace egfr=egfr*1.018 if male==0
label var egfr "egfr calculated using CKD-EPI formula with no eth"

* Categorise into ckd stages
egen egfr_cat = cut(egfr), at(0, 15, 30, 45, 60, 5000)
recode egfr_cat 0 = 5 15 = 4 30 = 3 45 = 2 60 = 0, generate(ckd_egfr)

* 0 = "No CKD" 	2 "stage 3a" 3 "stage 3b" 4 "stage 4" 5 "stage 5"

* Add in end stage renal failure and create a single CKD variable 
* Missing assumed to not have CKD 
gen ckd = 0
replace ckd = 1 if ckd_egfr != . & ckd_egfr >= 1
replace ckd = 1 if esrf == 1

label define ckd 0 "No CKD" 1 "CKD"
label values ckd ckd
label var ckd "CKD stage calc without eth"

* Create date (most recent measure prior to index)
gen temp1_ckd_date = creatinine_measured_date if ckd_egfr >=1
gen temp2_ckd_date = esrf_date if esrf == 1
gen ckd_date = max(temp1_ckd_date,temp2_ckd_date) 
format ckd_date %td

* End stage kidney failure (For exclusion)
gen eskf_exclusion = 1 if egfr != . & egfr < 15
replace eskf_exclusion = 1 if esrf == 1
replace eskf_exclusion = 0 if eskf_exclusion == .

label define eskf_exclusion 0 "No End stage kidney failure" 1 "End stage kidney failure"
label values eskf_exclusion eskf_exclusion

/* Hb1AC */

/* Diabetes severity */

* Set zero or negative to missing
replace hba1c_percentage   = . if hba1c_percentage <= 0
replace hba1c_mmol_per_mol = . if hba1c_mmol_per_mol <= 0

/* Express HbA1c as percentage  */ 

* Express all values as perecentage 
noi summ hba1c_percentage hba1c_mmol_per_mol 
gen 	 hba1c_pct = hba1c_percentage 
replace  hba1c_pct = (hba1c_mmol_per_mol/10.929)+2.15 if hba1c_mmol_per_mol<. 

* Valid % range between 0-20  
replace hba1c_pct = . if !inrange(hba1c_pct, 0, 20) 
replace hba1c_pct = round(hba1c_pct, 0.1)

/* Categorise hba1c and diabetes  */

* Group hba1c
gen 	hba1ccat = 0 if hba1c_pct <  6.5
replace hba1ccat = 1 if hba1c_pct >= 6.5  & hba1c_pct < 7.5
replace hba1ccat = 2 if hba1c_pct >= 7.5  & hba1c_pct < 8
replace hba1ccat = 3 if hba1c_pct >= 8    & hba1c_pct < 9
replace hba1ccat = 4 if hba1c_pct >= 9    & hba1c_pct !=.
label define hba1ccat 0 "<6.5%" 1">=6.5-7.4" 2">=7.5-7.9" 3">=8-8.9" 4">=9"
label values hba1ccat hba1ccat

* Create diabetes, split by control/not
gen     diabcat = 1 if diabetes==0
replace diabcat = 2 if diabetes==1 & inlist(hba1ccat, 0, 1)
replace diabcat = 3 if diabetes==1 & inlist(hba1ccat, 2, 3, 4)
replace diabcat = 4 if diabetes==1 & !inlist(hba1ccat, 0, 1, 2, 3, 4)

label define diabcat 	1 "No diabetes" 			///
						2 "Controlled diabetes"		///
						3 "Uncontrolled diabetes" 	///
						4 "Diabetes, no hba1c measure"
label values diabcat diabcat

* Delete unneeded variables
drop hba1c_pct hba1c_percentage hba1c_mmol_per_mol

* Group stroke and transient ischaemic attack into one variable
gen stroke_tia = 1 if stroke == 1 | tia == 1
replace stroke_tia = 0 if stroke_tia == .

/* Calculate CHA2DS2-VASc score */
* Age component
gen 	chadsvas_age = 0 if age >= 18 & age < 65
replace chadsvas_age = 1 if age >= 65 & age < 75
replace chadsvas_age = 2 if age >= 75

* Sex component
gen 	chadsvas_sex = 1 if sex == "F"
replace chadsvas_sex = 0 if sex == "M"

* Heart failure history component
gen 	chadsvas_hf = 1 if heart_failure == 1
replace chadsvas_hf = 0 if chadsvas_hf == .

* hypertension component
gen 	chadsvas_ht = 1 if hypertension == 1
replace chadsvas_ht = 0 if chadsvas_ht == .
						
* Stroke/TIA/thromboembolism history component
gen 	chadsvas_stroke= 2 if ///
		stroke == 1 | tia == 1 | vte == 1
		
replace chadsvas_stroke = 0 if chadsvas_stroke == .

* Vascular disease component (Mycardial infarction/Peripheral artery disease)
gen 	chadsvas_vascular = 1 if ///
		myocardial_infarct == 1 | pad == 1
		
replace chadsvas_vascular = 0 if chadsvas_vascular == .

* Diabetes component 
gen 	chadsvas_dm = 1 if ///
		diabcat !=. & diabcat > 1 
		
replace chadsvas_dm = 0 if chadsvas_dm == .

* Calculate the score
gen CHA2DS2_VASc_score = chadsvas_age + chadsvas_sex + chadsvas_hf + chadsvas_ht ///
						+ chadsvas_stroke + chadsvas_vascular + chadsvas_dm

* Records of HAS-BLED score ever appears 10 years before cohort entry (round up to integer)
gen has_bled_score_ever = ceil(has_bled_score) if has_bled_score_date != .

* Set the variable to missing if the recorded score > 9 (max score is 9) or <0
replace has_bled_score_ever = . if has_bled_score_ever > 9
replace has_bled_score_ever = . if has_bled_score_ever < 0

* Recent records of HAS-BLED score (1 year) before cohort entry (round up to integer)
gen has_bled_score_recent = ceil(has_bled_score) if has_bled_score_date > (date("$indexdate", "DMY") - 365) & has_bled_score_date < date("$indexdate", "DMY")

* Set the variable to missing if the recorded score > 9 (max score is 9) or <0
replace has_bled_score_recent = . if has_bled_score_recent > 9
replace has_bled_score_ever = . if has_bled_score_ever < 0

/* LABEL VARIABLES============================================================*/
*  Label variables you are intending to keep, drop the rest 

* Demographics
label var patient_id				"Patient ID"
label var practice_id               "Practice ID"
label var care_home_residence       "Care home residence"
label var age 						"Age (years)"
label var agegroup					"Grouped age"
label var sex 						"Sex"
label var male 						"Male"
label var bmi 						"Body Mass Index (BMI, kg/m2)"
label var bmicat 					"Grouped BMI"
label var bmi_measured_date  		"Body Mass Index (BMI, kg/m2), date measured"
label var obese4cat					"Evidence of obesity (4 categories)"
label var smoke		 				"Smoking status"
label var smoke_nomiss	 			"Smoking status (missing set to non)"
label var imd 						"Index of Multiple Deprivation (IMD)"
label var ethnicity					"Ethnicity"
label var stp 						"Sustainability and Transformation Partnership"
label var CHA2DS2_VASc_score        "Calculated CHA2DS2_VASc_score"
label var has_bled_score_ever		"Ever record of HAS-BLED score in 10 years"
label var has_bled_score_recent		"Recent record of HAS-BLED score"
label var has_bled_score_date		"Date of ever record of HAS-BLED score in 10 years"

label var age1 						"Age spline 1"
label var age2 						"Age spline 2"
label var age3 						"Age spline 3"

* Exposure variables (date)
label var warfarin_last_four_months "latest date of warfarin Rx in past 4 months"
label var doac_last_four_months     "latest date of DOAC Rx in past 4 months"

* Exposure variables (Time-updated variable)
label var warfarin_march_first      "earliest date of warfarin Rx in March 2020"
label var doac_march_first          "earliest date of DOAC Rx in March 2020"
label var warfarin_apr_first        "earliest date of warfarin Rx in April 2020"
label var doac_apr_first            "earliest date of DOAC Rx in April 2020"
label var warfarin_may_first        "earliest date of warfarin Rx in May 2020"
label var doac_may_first            "earliest date of DOAC Rx in May 2020"
label var warfarin_jun_first        "earliest date of warfarin Rx in June 2020"
label var doac_jun_first            "earliest date of DOAC Rx in June 2020"
label var warfarin_jul_first        "earliest date of warfarin Rx in July 2020"
label var doac_jul_first            "earliest date of DOAC Rx in July 2020"
label var warfarin_aug_first        "earliest date of warfarin Rx in Aug 2020"
label var doac_aug_first            "earliest date of DOAC Rx in Aug 2020"
label var warfarin_sep_first        "earliest date of warfarin Rx in Sep 2020"
label var doac_sep_first            "earliest date of DOAC Rx in Sep 2020"

label var warfarin_march_last       "latest date of warfarin Rx in March 2020"
label var doac_march_last           "latest date of DOAC Rx in March 2020"
label var warfarin_apr_last         "latest date of warfarin Rx in April 2020"
label var doac_apr_last             "latest date of DOAC Rx in April 2020"
label var warfarin_may_last         "latest date of warfarin Rx in May 2020"
label var doac_may_last             "latest date of DOAC Rx in May 2020"
label var warfarin_jun_last         "latest date of warfarin Rx in June 2020"
label var doac_jun_last             "latest date of DOAC Rx in June 2020"
label var warfarin_jul_last         "latest date of warfarin Rx in July 2020"
label var doac_jul_last             "latest date of DOAC Rx in July 2020"
label var warfarin_aug_last         "latest date of warfarin Rx in Aug 2020"
label var doac_aug_last             "latest date of DOAC Rx in Aug 2020"
label var warfarin_sep_last         "latest date of warfarin Rx in Sep 2020"
label var doac_sep_last             "latest date of DOAC Rx in Sep 2020"

* Comorbidities/medications of interest
label var ckd     					 	"Chronic kidney disease" 
label var dementia						"Dementia"
label var egfr_cat						"Calculated eGFR"
label var hypertension				    "Diagnosed hypertension"
label var heart_failure				    "Heart Failure"
label var other_respiratory 			"Other Respiratory Diseases"
label var copd 							"COPD"
label var diabetes						"Diabetes"
label var cancer 				    	"Cancer"
label var immunodef_any					"Immunosuppressed (combination algorithm)"
label var diabcat						"Diabetes Severity"
label var stroke                        "Stroke"
label var myocardial_infarct			"Myocardial infarction"
label var tia                           "Transient ischaemic attack"
label var stroke_tia					"Stroke/Transient ischaemic attack"
label var vte                           "Venous thromboembolism"
label var pad       					"Peripheral arterial disease"
label var oestrogen 					"Recent Oestrogen"
label var antiplatelet          	    "Recent antiplatelet"
label var flu_vaccine					"Flu vaccine"
label var aspirins						"Recent aspirin"
label var nsaid							"Recent NSAID"
label var hazardous_alcohol				"Hazardous alcohol use"
label var gp_consult					"GP consultation in last year (binary)"
label var gp_consult_count				"GP consultation count"
label var ae_attendance_last_year       "A&E attendance rate in last year (binary)"
label var ae_attendance_count           "A&E attendance count"
label var ckd_date     					"Chronic kidney disease Date" 
label var dementia_date					"Dementia Date"
label var hypertension_date			    "Diagnosed hypertension Date"
label var heart_failure_date			"Heart Failure Date"
label var other_respiratory_date 		"Other Respiratory Diseases Date"
label var copd_date 					"COPD Date"
label var diabetes_date					"Diabetes Date"
label var cancer_date 		     		"Cancer Date"
label var myocardial_infarct_date       "Myocardial infarction Date"
label var stroke_date 			        "Stroke Date"
label var tia_date 		  	 		    "Transient ischaemic attack Date"
label var vte_date 		 		        "Venous thromboembolism Date"
label var pad_date						"Peripheral arterial disease Date"
label var hazardous_alcohol_date		"Hazardous alcohol use Date"

label var oestrogen_date 				"Recent Oestrogen Date"
label var antiplatelet_date			 	"Recent antiplatelet Date"
label var nsaid_date					"Recent NSAID Date"
label var aspirins_date					"Recent aspirin Date"

*Inclusion/Exclusion criteria related variables
label var af_date					   "Atrial fibrillation Date"							
label var valvular_af_date             "Valvular atrial fibrillation Date"
label var antiphospholipid_syndrome_date "Antiphospholipid_syndrome Date"
label var lmwh_last_four_months_date   "latest date of LMWH exposure in past 4 months"
label var eskf_exclusion                "End stage kidney failure/kidney transplant/dialysis" 

*Outcome/right censoring related variables
label var died_date_ons                 "ONS death date (any cause)"
label var died_ons_covid_flag_any       "Binary indicator: ONS any covid"
label var suspected_died_ons_covid_flag_any "Binary indicator: ONS any suspected covid"
label var died_ons_covid_flag_underlying "Binary indicator: ONS underlying covid (subset of any)"
label var dereg_date                     "Deregistration date from GP"
label var covid_admission_date           "Date of hospital admission due to COVID"
label var covid_admission_primary_dx     "Primary hospitalisation admission due to COVID"
label var first_tested_for_covid         "Date of COVID-19 test"
label var first_positive_test_date       "Date of positive COVID-19 test"
label var mi_date_ons   				 "ONS death date due to myocardial infarction"
label var stroke_date_ons			     "ONS death date due to ischaemic stroke"
label var vte_date_ons				     "ONS death date due to venous thromboembolism"
label var gi_bleed_date_ons				 "ONS death date due to GI bleed"
label var intracranial_bleed_date_ons    "ONS death date due to intracranial bleed"

/* ==================================================================*/

save $tempdir/format_dataset, replace

* Close log file 
log close


