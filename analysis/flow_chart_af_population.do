/*==============================================================================
DO FILE NAME:			flow_chart_af_population
PROJECT:				Anticoagulant in COVID-19 
DATE: 					24 November 2020 
AUTHOR:					A Wong (modified from NSAID study by A Walker)								
DESCRIPTION OF FILE:	identify number of people included in each stage applying inclusion/exclusion criteria
DATASETS USED:			input_af_population_flow_chart

DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to output folder
						
							
==============================================================================*/

local global_option `1'

do `c(pwd)'/analysis/global_`global_option'.do

* Open a log file

cap log close
log using $logdir/flow_chart_af_population, replace t

/*
# AF population
registration_history AND
af AND
(age >=18 AND age <= 110) AND
imd >0
*/
safecount
drop if registration_history!=1
safecount
keep if !missing(af)
safecount
drop if age < 18 | age > 110
safecount
keep if imd>0
safecount

log close