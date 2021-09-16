/*==============================================================================
DO FILE NAME:			09a_an_models_plot
PROJECT:				Anticoagulant in COVID-19 
AUTHOR:					A Wong
DATE: 					2 Nov 2020 					
DESCRIPTION OF FILE:	program 09
						Using fully adjusted model
						Objective 1: comparing treated and untreated people 
						with atrial fibrillation
DATASETS USED:			data in memory ($tempdir/analysis_dataset_STSET_outcome)

DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
						Adj_survival_curves.svg
						difference_survival_curves.svg
							
==============================================================================*/
local outcome `1'

local global_option `2'

local df `3'

local cum_ymax `4'

local yscale `5'

do `c(pwd)'/analysis/global_`global_option'.do

* Open a log file
capture log close
log using $logdir/09a_an_models_plot_`outcome', replace t

* Open Stata dataset
use $tempdir/analysis_dataset_STSET_`outcome', clear

/*==============================================================================*/
* Fit the stpm2 model 
xi i.exposure i.male $fullvarlist
    
stpm2 _I* age1 age2 age3, scale(hazard) df(`df') eform nolog

* set timevar for time points to be plotted
summ _t
local tmax=r(max)
local tmaxplus1=r(max)+1

range timevar 0 `tmax' `tmaxplus1'

* Run stpm2 
stpm2_standsurv, at1(_Iexposure 0) at2(_Iexposure 1) timevar(timevar) ci contrast(difference) fail

* list the standardized curves for longest follow-up, followed by their difference.
list _at1* if timevar==`tmax', noobs
list _at2* if timevar==`tmax', noobs
list _contrast* if timevar==`tmax', noobs ab(16)

* Convert them to be expressed in %
for var _at1 _at2 _at1_lci _at1_uci _at2_lci _at2_uci ///
_contrast2_1 _contrast2_1_lci _contrast2_1_uci: replace X=100*X

* Plot the survival curves
twoway  (rarea _at1_lci _at1_uci timevar, color(blue%25)) ///
                (rarea _at2_lci _at2_uci timevar, color(red%25)) ///
                 (line _at1 timevar, sort lcolor(blue)) ///
                 (line _at2  timevar, sort lcolor(red)) ///
                 , legend(order(1 "Non-current anticoagulant use" 2 "Current anticoagulant use") ///
				 ring(0) cols(1) pos(4)) ///
                 ylabel(0 (`yscale') `cum_ymax' ,angle(h) format(%4.2f)) ///
                 ytitle("Cumulative incidence (%)") ///
                 xtitle("Days from 1 March 2020") ///
				 saving(adj_curves_`outcome' , replace)
				 
graph export "$tabfigdir/adj_curves_`outcome'.svg", as(svg) replace

* Close window 
graph close

* Delete unneeded graphs
erase adj_curves_`outcome'.gph

* Plot the difference in curves
twoway  (rarea _contrast2_1_lci _contrast2_1_uci timevar, color(red%25)) ///
                 (line _contrast2_1 timevar, sort lcolor(red)) ///
                 , legend(off) ///
                 ylabel(,angle(h) format(%4.2f)) ///
                 ytitle("Difference in curves (%)") ///
                 xtitle("Days from 1 March 2020") ///
				 saving(diff_curves_`outcome' , replace)
				 
graph export "$tabfigdir/diff_curves_`outcome'.svg", as(svg) replace

* Close window 
graph close

* Delete unneeded graphs
erase diff_curves_`outcome'.gph		 
	 
* Close log file 
log close