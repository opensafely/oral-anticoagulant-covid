/*==============================================================================
DO FILE NAME:			flow_chart_general_population
PROJECT:				Anticoagulant in COVID-19 
DATE: 					24 November 2020 
AUTHOR:					A Wong (modified from NSAID study by A Walker)								
DESCRIPTION OF FILE:	identify number of people included in each stage applying inclusion/exclusion criteria
DATASETS USED:			input_general_population_flow_chart

DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to output folder
						
							
==============================================================================*/

local global_option `1'

do `c(pwd)'/analysis/global_`global_option'.do

* Open a log file

cap log close
log using $logdir/flow_chart_general_population, replace t

/*
# General population (before matching)
    #    registration_history AND
    #    (age >=18 AND age <= 110) AND
    #    (sex="M" OR sex="F") AND
    #    imd >0 AND 
    #    gp_consult_count>0 AND NOT (
    #    af OR
    #    lmwh_last_four_months OR 
    #    warfarin_last_four_months OR
    #    doac_last_four_months
*/
safecount
drop if registration_history!=1
safecount
drop if age < 18 | age > 110
safecount
keep if sex=="M" | sex=="F"
safecount
keep if imd>0
safecount
keep if gp_consult_count>0
safecount
drop if !missing(af)
safecount
drop if !missing(lmwh_last_four_months)
safecount
drop if !missing(warfarin_last_four_months)
safecount
drop if !missing(doac_last_four_months)
safecount

log close